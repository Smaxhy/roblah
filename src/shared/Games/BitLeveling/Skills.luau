--[[
	SKILLS AND TALENTS (BitLeveling, ORIGINAL game content on canon's Hunter classes).

	CLASS SKILLS: every awakened Hunter has a class (Fighter, Mage, Assassin, Tanker, Ranger,
	Healer: canon's names). Each class has twelve skills on two paths, learned on the DO tab:
	the first path is six skills in a line (the last needs an S-rank), the second branches off
	its first skill and runs to S-rank too. Each skill needs the one before it, a Hunter rank and
	enough of the class's main stat. A skill is a trait: what it does to clashes, fights, wounds
	and years is in its def (and written out in its description, from the numbers).

	MAGIC SCHOOLS: twelve schools of four spells (fire, frost, lightning, wind, earth, water,
	holy, void, venom, life, arcane, sound). Each has a main class that can study all four (a
	Mage for most; a Healer for holy and life; an Assassin for venom); other classes that fit a
	school can learn its first two spells once they have their own class's third skill (a
	Fighter's fire, earth and sound, a Tanker's frost, earth, holy, life and sound...). Schools
	need Intelligence (holy and life: Willpower; venom: Agility). Each spell opens that school's
	moves in the city, by rank.

	HUNTER CRAFT: six skills any awakened Hunter can learn, whatever the class (Mana Sensing,
	Mana Armour, Blink...).

	THE LIVE CITY: skills unlock moves in the walkable city (Hunter/Abilities.luau, 250 of them):
	five slots, Q E R T and an ultimate on G. A skill's description says what it unlocks there;
	the physical arts (sword, spear, fist, archery, shield, assassination) open by class and rank.

	TALENTS: every life is born with one, rolled by rarity (the odds are shown in the creator):
	Ordinary 52%, Promising 26%, Gifted 13%, Prodigy 6.5%, One in a Generation 2.2%, One in the
	World 0.3%. Each leans to a class: lean toward two classes in the creator and their talents
	are three times as likely (and an awakening leans to them too); a talent of a class you lean
	to resonates (+3% heads in every clash). Talents never decide whether you awaken.

	Every name here is this game's own. None of it is the System's, or the Shadow Monarch's.
]]

local RANKS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local RANK_LETTER = { "E", "D", "C", "B", "A", "S" }
local function from(r: number)
	local out = {}
	for i = r, 6 do
		table.insert(out, RANKS[i])
	end
	return out
end

local STAT_ORDER = { "strength", "agility", "intelligence", "vitality", "willpower", "charisma", "luck" }
local STAT_NAME = {
	strength = "Strength", agility = "Agility", intelligence = "Intelligence", vitality = "Vitality",
	willpower = "Willpower", charisma = "Charisma", luck = "Luck",
}

-- the live-city abilities (Hunter/Abilities.luau), to say what a skill unlocks there. Found
-- with FindFirstChild (never a wait): the pack builds the same without them.
local liveByUnlock: { [string]: { any } } = {}
do
	local ok, Abilities = pcall(function()
		local root = script.Parent and script.Parent.Parent and script.Parent.Parent.Parent
		local hunter = root and root:FindFirstChild("Hunter")
		local mod = hunter and hunter:FindFirstChild("Abilities")
		return if mod then require(mod) else nil
	end)
	if ok and type(Abilities) == "table" and type(Abilities.list) == "table" then
		for _, ab in Abilities.list do
			if ab.unlock then
				liveByUnlock[ab.unlock] = liveByUnlock[ab.unlock] or {}
				table.insert(liveByUnlock[ab.unlock], ab)
			end
		end
	end
end

-- ── what a skill's numbers do, in words (so a description can never disagree with its def) ──
local function signed(n: number): string
	return (if n >= 0 then "+" else "") .. tostring(n)
end
local function pct(x: number): number
	return math.floor(x * 100 + 0.5)
end
local function summary(e: any, born: boolean?): string
	local parts = {}
	local f = e.fight
	if f then
		if f.coins then
			table.insert(parts, signed(f.coins) .. (if math.abs(f.coins) == 1 then " coin" else " coins") .. " in fights")
		end
		if f.base then
			table.insert(parts, signed(f.base) .. " base in fights")
		end
		if f.coinPower then
			table.insert(parts, signed(f.coinPower) .. " power per heads in fights")
		end
	end
	for _, stat in STAT_ORDER do
		local c = e.clash and e.clash[stat]
		if c then
			if c.coins then
				table.insert(parts, signed(c.coins) .. (if math.abs(c.coins) == 1 then " coin" else " coins") .. " in " .. STAT_NAME[stat] .. " checks")
			end
			if c.base then
				table.insert(parts, signed(c.base) .. " base in " .. STAT_NAME[stat] .. " checks")
			end
			if c.coinPower then
				table.insert(parts, signed(c.coinPower) .. " power per heads in " .. STAT_NAME[stat] .. " checks")
			end
		end
	end
	if e.heads then
		table.insert(parts, signed(e.heads) .. "% heads in every clash")
	end
	if e.toughness then
		table.insert(parts, pct(1 - e.toughness) .. "% less damage taken")
	end
	for _, stat in STAT_ORDER do
		if e.stats and e.stats[stat] then
			table.insert(parts, signed(e.stats[stat]) .. " " .. STAT_NAME[stat])
		end
	end
	if type(e.growth) == "number" then
		table.insert(parts, "every stat grows " .. pct(e.growth - 1) .. "% faster")
	elseif type(e.growth) == "table" then
		for _, stat in STAT_ORDER do
			if e.growth[stat] then
				table.insert(parts, STAT_NAME[stat] .. " grows " .. pct(e.growth[stat] - 1) .. "% faster")
			end
		end
	end
	if e.yearly then
		for _, stat in STAT_ORDER do
			if e.yearly[stat] then
				table.insert(parts, signed(e.yearly[stat]) .. " " .. STAT_NAME[stat] .. " a year")
			end
		end
		if e.yearly.sanity then
			table.insert(parts, signed(e.yearly.sanity) .. " Composure a year")
		end
	end
	if e.sanity then
		table.insert(parts, signed(e.sanity) .. (if born then " Composure" else " Composure now"))
	end
	if e.money then
		table.insert(parts, "start with " .. tostring(e.money) .. " million won")
	end
	if #parts == 0 then
		return ""
	end
	local text = table.concat(parts, ", ") .. "."
	return string.upper(string.sub(text, 1, 1)) .. string.sub(text, 2)
end
local function liveLine(id: string): string
	local list = liveByUnlock[id]
	if not list then
		return ""
	end
	local names = {}
	for i, ab in list do
		if i <= 4 then
			table.insert(names, ab.name .. " [" .. ab.slot .. "]")
		end
	end
	local more = if #list > 4 then string.format(" and %d more", #list - 4) else ""
	return " In the city: " .. table.concat(names, ", ") .. more .. "."
end

--[[ CLASS TREES. Each skill: { id, name, flavour, effects, rank (1 E .. 6 S), main stat, after }.
	The first six are the class's first path (in a line); the next six its second path, which
	branches off the first skill. ]]
local TREES = {
	{
		class = "fighter", name = "Fighter", stat = "strength", paths = { "Blade", "Vanguard" },
		skills = {
			{ "power_strike", "Power Strike", "Put your whole body behind one blow.", { fight = { base = 1 }, clash = { strength = { base = 1 } } }, 1, 0 },
			{ "whirlwind", "Whirlwind", "A spinning cut that catches everything around you.", { fight = { coinPower = 1 } }, 2, 35, "power_strike" },
			{ "iron_resolve", "Iron Resolve", "You stop flinching.", { heads = 3, sanity = 5 }, 3, 60, "whirlwind" },
			{ "sundering_blow", "Sundering Blow", "A strike that breaks armour and stone.", { fight = { base = 3 } }, 4, 100, "iron_resolve" },
			{ "berserk", "Berserk", "Pain becomes fuel.", { fight = { coinPower = 2 }, toughness = 0.9 }, 5, 160, "sundering_blow" },
			{ "bladestorm", "Bladestorm", "For a few seconds you are everywhere at once.", { fight = { coins = 1, base = 4 } }, 6, 240, "berserk" },
			{ "shoulder_charge", "Shoulder Charge", "Lower your shoulder and go through the line.", { fight = { base = 1 }, clash = { vitality = { base = 1 } } }, 1, 20, "power_strike" },
			{ "rising_cut", "Rising Cut", "An upward cut that lifts the thing off its feet.", { clash = { strength = { coinPower = 1 } } }, 2, 45, "shoulder_charge" },
			{ "war_cry", "War Cry", "A shout that steadies the whole raid behind you.", { heads = 2, sanity = 4, clash = { charisma = { base = 2 } } }, 3, 75, "rising_cut" },
			{ "leap_strike", "Leap Strike", "Cross the street in one jump and land blade first.", { fight = { base = 2 }, clash = { agility = { base = 1 } } }, 4, 115, "war_cry" },
			{ "earthsplitter", "Earthsplitter", "A downward blow that opens the street in a line.", { fight = { base = 3, coinPower = 1 } }, 5, 175, "leap_strike" },
			{ "unbowed", "Unbowed", "When the raid breaks, you are the one still standing.", { toughness = 0.9, heads = 3, yearly = { sanity = 1 } }, 6, 255, "earthsplitter" },
		},
	},
	{
		class = "mage", name = "Mage", stat = "intelligence", paths = { "Elements", "Arcane" },
		skills = {
			{ "mana_bolt", "Mana Bolt", "A bolt of raw mana.", { clash = { intelligence = { base = 2 } } }, 1, 0 },
			{ "flame_lance", "Flame Lance", "A spear of fire that goes through the first thing it hits.", { clash = { intelligence = { coinPower = 1 } }, fight = { base = 1 } }, 2, 35, "mana_bolt" },
			{ "frost_nova", "Frost Nova", "Everything near you freezes for a heartbeat.", { heads = 3, clash = { intelligence = { coins = 1 } } }, 3, 60, "flame_lance" },
			{ "chain_lightning", "Chain Lightning", "Lightning that jumps from monster to monster.", { clash = { intelligence = { base = 3 } }, fight = { base = 1 } }, 4, 100, "frost_nova" },
			{ "meteor", "Meteor", "You call something down from a sky that isn't there.", { clash = { intelligence = { coinPower = 2 } }, fight = { coinPower = 1 } }, 5, 160, "chain_lightning" },
			{ "cataclysm", "Arcane Cataclysm", "The street remembers it for years.", { clash = { intelligence = { coins = 1, base = 5 } } }, 6, 240, "meteor" },
			{ "mana_shield", "Mana Shield", "A pane of hard mana between you and the claw.", { toughness = 0.94 }, 1, 25, "mana_bolt" },
			{ "arcane_step", "Arcane Step", "Fold a few metres of street and step across them.", { clash = { agility = { base = 2 } } }, 2, 50, "mana_shield" },
			{ "spellweaving", "Spellweaving", "Two spells in the time it takes to cast one.", { clash = { intelligence = { coinPower = 1 } }, fight = { base = 1 } }, 3, 85, "arcane_step" },
			{ "deep_reserves", "Deep Reserves", "You stop running dry in the middle of a raid.", { growth = { intelligence = 1.15 }, heads = 2 }, 4, 125, "spellweaving" },
			{ "runic_circle", "Runic Circle", "A circle drawn in light; a guardian of mana stands up out of it.", { clash = { intelligence = { base = 3 } }, fight = { coinPower = 1 } }, 5, 185, "deep_reserves" },
			{ "arcanum", "Arcanum", "Every school you know answers at once.", { clash = { intelligence = { coins = 1 } }, heads = 3 }, 6, 265, "runic_circle" },
		},
	},
	{
		class = "assassin", name = "Assassin", stat = "agility", paths = { "Edge", "Night" },
		skills = {
			{ "quick_strike", "Quick Strike", "Hit before they know you moved.", { clash = { agility = { base = 1 } }, fight = { base = 1 } }, 1, 0 },
			-- (the id is older than the name; the name is this game's own)
			{ "stealth", "Quiet Presence", "Be where nobody is looking.", { heads = 4 }, 2, 35, "quick_strike" },
			{ "venom_edge", "Venom Edge", "Coat the blade. Every cut keeps working.", { fight = { coinPower = 1 } }, 3, 60, "stealth" },
			{ "shadow_step", "Shadow Step", "Close the distance in one step.", { fight = { coins = 1 } }, 4, 100, "venom_edge" },
			{ "assassinate", "Assassinate", "Find the one place it can't defend.", { fight = { base = 4 } }, 5, 160, "shadow_step" },
			{ "phantom_dance", "Phantom Dance", "Afterimages everywhere; none of them are you.", { fight = { coins = 1, coinPower = 2 }, heads = 3 }, 6, 240, "assassinate" },
			{ "smoke_bomb", "Smoke Bomb", "A pellet, a grey cloud, and you're somewhere else.", { clash = { agility = { base = 1 } }, heads = 1 }, 1, 20, "quick_strike" },
			{ "twin_fangs", "Twin Fangs", "Two blades, one motion.", { fight = { coinPower = 1 } }, 2, 45, "smoke_bomb" },
			{ "crippling_strike", "Crippling Strike", "A low cut that slows anything with legs.", { fight = { base = 2 } }, 3, 75, "twin_fangs" },
			{ "fan_of_knives", "Fan of Knives", "Six throwing knives in one arc.", { fight = { base = 1, coinPower = 1 } }, 4, 115, "crippling_strike" },
			{ "afterimage", "Afterimage", "The blow lands on a copy of you a step behind.", { toughness = 0.92, heads = 3 }, 5, 175, "fan_of_knives" },
			{ "silent_verdict", "Silent Verdict", "One step, one cut, and the street goes quiet.", { fight = { coins = 1, base = 2 } }, 6, 255, "afterimage" },
		},
	},
	{
		class = "tanker", name = "Tanker", stat = "vitality", paths = { "Wall", "Guardian" },
		skills = {
			{ "taunt", "Taunt", "Make it look at you, not them.", { clash = { vitality = { base = 2 } } }, 1, 0 },
			{ "shield_wall", "Shield Wall", "Plant your feet.", { toughness = 0.9 }, 2, 35, "taunt" },
			{ "iron_skin", "Iron Skin", "Mana hardens under your skin.", { stats = { vitality = 15 }, toughness = 0.9 }, 3, 60, "shield_wall" },
			{ "fortress", "Fortress", "Nothing gets past you.", { fight = { base = 3 } }, 4, 100, "iron_skin" },
			{ "unbreakable", "Unbreakable", "You've stopped counting what you've taken.", { toughness = 0.85, heads = 3 }, 5, 160, "fortress" },
			{ "bastion", "Bastion", "A wall a city stands behind.", { toughness = 0.85, fight = { coins = 1 }, stats = { vitality = 30 } }, 6, 240, "unbreakable" },
			{ "shield_bash", "Shield Bash", "The shield is a weapon too.", { fight = { base = 1 }, clash = { strength = { base = 1 } } }, 1, 25, "taunt" },
			{ "hold_the_line", "Hold the Line", "Stamp once and the street knows where the line is.", { heads = 2, sanity = 4 }, 2, 55, "shield_bash" },
			{ "bulwark_charge", "Bulwark Charge", "Shield first, at a run, through whatever is there.", { fight = { coinPower = 1 } }, 3, 90, "hold_the_line" },
			{ "guardian_oath", "Guardian's Oath", "Take the blow meant for someone else.", { clash = { willpower = { base = 2 } }, heads = 2 }, 4, 130, "bulwark_charge" },
			{ "rooted_stance", "Rooted Stance", "Mana runs down your legs into the ground and holds.", { toughness = 0.92, stats = { vitality = 15 } }, 5, 190, "guardian_oath" },
			{ "aegis", "Aegis", "A dome of mana a whole street can hide under.", { toughness = 0.9, fight = { base = 2 }, yearly = { vitality = 3 } }, 6, 270, "rooted_stance" },
		},
	},
	{
		class = "ranger", name = "Ranger", stat = "agility", paths = { "Bow", "Wild" },
		skills = {
			{ "aimed_shot", "Aimed Shot", "Breathe out, then shoot.", { heads = 3 }, 1, 0 },
			{ "multishot", "Multishot", "Three arrows, one draw.", { fight = { coinPower = 1 } }, 2, 35, "aimed_shot" },
			{ "eagle_eye", "Eagle Eye", "You see the weak spot from across the street.", { clash = { agility = { base = 2 }, intelligence = { base = 2 } } }, 3, 60, "multishot" },
			{ "piercing_arrow", "Piercing Arrow", "Through the shield, through the armour.", { fight = { base = 3 } }, 4, 100, "eagle_eye" },
			{ "arrow_rain", "Arrow Rain", "The sky over them fills.", { fight = { coins = 1 } }, 5, 160, "piercing_arrow" },
			{ "skypierce", "Skypierce", "An arrow that doesn't come down.", { fight = { coinPower = 2, base = 4 } }, 6, 240, "arrow_rain" },
			{ "trackers_eye", "Tracker's Eye", "Read a street the way other people read a trail.", { clash = { intelligence = { base = 1 } }, heads = 1 }, 1, 20, "aimed_shot" },
			{ "snare_trap", "Snare Trap", "A ring of mana on the ground that closes on whatever steps in.", { fight = { base = 1 }, heads = 1 }, 2, 45, "trackers_eye" },
			{ "backstep_shot", "Backstep Shot", "Jump back and loose an arrow before you land.", { clash = { agility = { coinPower = 1 } } }, 3, 75, "snare_trap" },
			{ "mana_hawk", "Mana Hawk", "A hawk shaped out of your own mana circles, then dives.", { fight = { coinPower = 1 } }, 4, 115, "backstep_shot" },
			{ "explosive_arrow", "Explosive Arrow", "An arrowhead packed with mana; it goes off on contact.", { fight = { base = 3 } }, 5, 175, "mana_hawk" },
			{ "starfall_volley", "Starfall Volley", "A sky of falling light, and all of it arrows.", { fight = { coins = 1, coinPower = 1 } }, 6, 260, "explosive_arrow" },
		},
	},
	{
		class = "healer", name = "Healer", stat = "willpower", paths = { "Mending", "Light" },
		skills = {
			{ "mend", "Mend", "Close a wound with your hands.", { yearly = { vitality = 5 } }, 1, 0 },
			{ "purify", "Purify", "Wash the fear out of a mind.", { yearly = { sanity = 3 } }, 2, 35, "mend" },
			{ "barrier", "Barrier", "A shell of light around someone.", { toughness = 0.9 }, 3, 60, "purify" },
			{ "regeneration", "Regeneration", "Wounds close on their own now.", { yearly = { vitality = 8 } }, 4, 100, "barrier" },
			{ "sanctuary", "Sanctuary", "Where you stand, people stop being afraid.", { heads = 4, yearly = { sanity = 2 } }, 5, 160, "regeneration" },
			{ "grace", "Grace of the Healer", "You can pull someone back from almost anything.", { stats = { vitality = 40 }, yearly = { vitality = 10 } }, 6, 240, "sanctuary" },
			{ "soothing_light", "Soothing Light", "A light that keeps working after you've moved on.", { yearly = { sanity = 2 } }, 1, 20, "mend" },
			{ "renewing_touch", "Renewing Touch", "A hand on a shoulder, and the shaking stops.", { yearly = { vitality = 3 }, clash = { charisma = { base = 1 } } }, 2, 50, "soothing_light" },
			{ "warding_sigil", "Warding Sigil", "A circle on the ground that blows can't cross easily.", { toughness = 0.94, heads = 1 }, 3, 85, "renewing_touch" },
			{ "mana_transfer", "Mana Transfer", "Pour your own mana into someone who's run out.", { clash = { willpower = { base = 2 } }, fight = { base = 1 } }, 4, 125, "warding_sigil" },
			{ "light_warden", "Light Warden", "A guardian made of light stands over the wounded.", { yearly = { vitality = 4 }, heads = 2 }, 5, 185, "mana_transfer" },
			{ "resurgence", "Resurgence", "Everyone in the street gets back up.", { stats = { vitality = 20 }, yearly = { vitality = 4, sanity = 2 } }, 6, 270, "light_warden" },
		},
	},
}

--[[ MAGIC SCHOOLS. Each spell: { id, name, flavour, effects }; spells 1-2 are open to the
	school's other classes (entry: their own skill that opens it), 3-4 to the main class. ]]
local SCHOOL_STEPS = { { rank = 1, stat = 30 }, { rank = 2, stat = 60 }, { rank = 3, stat = 100 }, { rank = 5, stat = 170 } }
local SCHOOLS = {
	{
		id = "fire", name = "Fire", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", fighter = "iron_resolve" },
		desc = "Heat shaped and thrown. The loudest school, and the one guilds love on the news.",
		log = "Weeks of scorched gloves and one ruined practice dummy, and then the flame did what you told it",
		spells = {
			{ "fire_fireball", "Fireball", "A ball of fire that bursts on whatever it hits.", { clash = { intelligence = { base = 1 } }, fight = { base = 1 } } },
			{ "fire_ring", "Ring of Fire", "A circle of flame that burns whatever stays in it.", { fight = { coinPower = 1 } } },
			{ "fire_focus", "Searing Focus", "Your fire stops wavering and starts cutting.", { clash = { intelligence = { base = 2, coinPower = 1 } } } },
			{ "fire_inferno", "Inferno", "The air itself goes up around you.", { fight = { base = 3, coinPower = 1 } } },
		},
	},
	{
		id = "frost", name = "Frost", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", tanker = "iron_skin" },
		desc = "Cold that slows, binds and breaks. Patient work.",
		log = "A winter of cold hands, and then the frost started forming where you looked",
		spells = {
			{ "frost_shard", "Frost Shard", "A sliver of ice that leaves its target sluggish.", { clash = { intelligence = { base = 1 } }, heads = 1 } },
			{ "frost_spikes", "Ice Spikes", "Spikes of ice erupt from the street in a line.", { fight = { base = 2 } } },
			{ "frost_deep", "Deep Winter", "The cold in you settles and stops scaring you.", { toughness = 0.94, sanity = 4 } },
			{ "frost_blizzard", "Blizzard", "A storm of ice over a whole block.", { fight = { coins = 1 }, heads = 2 } },
		},
	},
	{
		id = "lightning", name = "Lightning", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", assassin = "venom_edge", ranger = "eagle_eye" },
		desc = "Fast, loud, hard to aim, harder to stop. It jumps.",
		log = "Months of static in your hair and burnt-out light bulbs, and then the spark jumped where you meant it to",
		spells = {
			{ "storm_spark", "Static Spark", "A spark that jumps to the next thing, and the next.", { heads = 2 } },
			{ "storm_thunderclap", "Thunderclap", "A crack of thunder that stuns everything close.", { fight = { coinPower = 1 } } },
			{ "storm_conduit", "Storm Conduit", "Lightning runs through you now instead of at you.", { clash = { intelligence = { base = 2 }, agility = { base = 1 } } } },
			{ "storm_thunderstorm", "Thunderstorm", "A storm of your own over the street.", { fight = { base = 2, coinPower = 1 }, heads = 2 } },
		},
	},
	{
		id = "wind", name = "Wind", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", ranger = "eagle_eye", assassin = "venom_edge" },
		desc = "Air that cuts, pushes and carries you. The quickest school.",
		log = "A season on rooftops in bad weather, and then the wind started leaning the way you leaned",
		spells = {
			{ "wind_gale", "Gale Step", "Ride a gust across the street, knocking things aside.", { clash = { agility = { base = 2 } } } },
			{ "wind_blades", "Wind Blades", "Crescents of air sharp enough to cut steel.", { fight = { base = 1 }, heads = 1 } },
			{ "wind_rider", "Windrider", "The air holds you up a moment longer than it should.", { growth = { agility = 1.15 }, heads = 1 } },
			{ "wind_tempest", "Tempest", "A cyclone that drags a crowd of monsters into itself.", { fight = { coinPower = 2 } } },
		},
	},
	{
		id = "earth", name = "Earth", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", tanker = "iron_skin", fighter = "iron_resolve" },
		desc = "Stone raised, hardened and thrown. Slow, heavy and very hard to argue with.",
		log = "A year of cracked pavement in the practice yard, and then the stone lifted when you asked it to",
		spells = {
			{ "earth_skin", "Stone Skin", "A shell of stone over your skin for a few hard seconds.", { toughness = 0.95 } },
			{ "earth_pillars", "Earth Pillars", "Pillars of rock punch up out of the street.", { fight = { base = 2 }, clash = { vitality = { base = 1 } } } },
			{ "earth_bedrock", "Bedrock Will", "Something in you stops moving when it's pushed.", { stats = { vitality = 12 }, clash = { willpower = { base = 1 } } } },
			{ "earth_colossus", "Stone Colossus", "A giant of stone and mana stands up and fights for a while.", { fight = { base = 3 }, toughness = 0.93 } },
		},
	},
	{
		id = "holy", name = "Holy", main = "healer", stat = "willpower",
		entry = { healer = "mend", tanker = "iron_skin" },
		desc = "Light that mends allies and burns monsters. A Healer's school; some Tankers learn its first steps.",
		log = "Long nights in the infirmary with your hands warm and your eyes shut, and then the light came when you called",
		spells = {
			{ "holy_smite", "Smite", "A shaft of light drops on one monster.", { clash = { willpower = { base = 1 } }, fight = { base = 1 } } },
			{ "holy_pillar", "Pillar of Light", "A column of light that burns monsters and mends people.", { yearly = { vitality = 3 } } },
			{ "holy_ground", "Hallowed Ground", "Wherever you stand a while, people breathe easier.", { yearly = { sanity = 2 }, heads = 2 } },
			{ "holy_dawn", "Dawnbreak", "For a moment the street is lit like morning.", { fight = { base = 2 }, yearly = { vitality = 4 } } },
		},
	},
	{
		id = "void", name = "Void", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", assassin = "venom_edge" },
		desc = "Mana folded in on itself until it pulls. Few study it; it takes something from the ones who do.",
		log = "Nights staring into a point of nothing on your desk until it stared back, and then it started to pull",
		spells = {
			{ "void_orb", "Void Orb", "A dark orb that drifts out and collapses, pulling everything in.", { clash = { intelligence = { base = 2 } } } },
			{ "void_well", "Gravity Well", "A patch of street where everything is suddenly very heavy.", { fight = { coinPower = 1 }, sanity = -3 } },
			{ "void_null", "Null Mind", "You learn to look at nothing without flinching.", { heads = 3, sanity = -3 } },
			{ "void_singularity", "Singularity", "A point of nothing that swallows a crowd and then lets go.", { fight = { base = 3, coinPower = 1 } } },
		},
	},
	{
		id = "water", name = "Water", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", healer = "barrier", ranger = "eagle_eye" },
		desc = "Water pressed hard enough to cut, or warm enough to heal. It goes where it's told.",
		log = "A summer by the river, soaked to the skin every day, and then the water started rising when you lifted your hand",
		spells = {
			{ "water_bullet", "Water Bullet", "A bead of water hard as steel.", { clash = { intelligence = { base = 1 } }, fight = { base = 1 } } },
			{ "water_surge", "Tidal Surge", "A wave out of nowhere that sweeps the street.", { fight = { coinPower = 1 } } },
			{ "water_current", "Deep Current", "Something in you flows around trouble instead of into it.", { heads = 2, sanity = 3 } },
			{ "water_maelstrom", "Maelstrom", "A whirlpool on dry street that drags everything in.", { fight = { base = 3 }, heads = 1 } },
		},
	},
	{
		id = "venom", name = "Venom", main = "assassin", stat = "agility",
		entry = { assassin = "quick_strike", ranger = "eagle_eye", mage = "frost_nova" },
		desc = "Venom drawn out of mana: darts, mists and marks that keep working. An Assassin's school.",
		log = "Months of antidotes, gloves and a very patient teacher, and then the venom answered you and not the other way round",
		spells = {
			{ "venom_dart", "Toxic Dart", "A dart of venom that keeps working.", { fight = { base = 1 } } },
			{ "venom_miasma", "Miasma", "A green fog that eats at whatever is inside it.", { fight = { coinPower = 1 } } },
			{ "venom_tolerance", "Venom Tolerance", "Nothing you brew can hurt you any more.", { toughness = 0.95, heads = 1 } },
			{ "venom_bloom", "Toxic Bloom", "Venom blooms out of the ground under them.", { fight = { base = 2, coinPower = 1 } } },
		},
	},
	{
		id = "life", name = "Life", main = "healer", stat = "willpower",
		entry = { healer = "mend", ranger = "eagle_eye", tanker = "iron_skin" },
		desc = "Green light that grows things: wounds close, roots hold, groves rise. A Healer's second school.",
		log = "A year of tending the infirmary garden until it grew when you walked past",
		spells = {
			{ "life_touch", "Verdant Touch", "Green light that closes small wounds.", { yearly = { vitality = 2 } } },
			{ "life_bloom", "Lifebloom", "Flowers of light that keep healing.", { yearly = { vitality = 3 }, clash = { willpower = { base = 1 } } } },
			{ "life_wellspring", "Wellspring", "A spring of life you carry with you.", { yearly = { vitality = 3, sanity = 1 } } },
			{ "life_sanctum", "Evergreen Sanctum", "A grove of light where people heal and blows soften.", { stats = { vitality = 15 }, yearly = { vitality = 3 } } },
		},
	},
	{
		id = "arcane", name = "Arcane", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", healer = "barrier", assassin = "venom_edge" },
		desc = "Mana itself, shaped into missiles, runes and seals. Where every Mage starts, and some never leave.",
		log = "A hundred notebooks of rune diagrams, and then one of them lit up on the page",
		spells = {
			{ "arcane_missile", "Arcane Missiles", "Seeking bolts of pure mana.", { clash = { intelligence = { base = 1 } }, heads = 1 } },
			{ "arcane_ward", "Rune Ward", "Runes that turn about you and your allies.", { toughness = 0.96, clash = { intelligence = { base = 1 } } } },
			{ "arcane_flow", "Mana Flow", "Your mana comes back faster than anyone's.", { growth = { intelligence = 1.1 }, heads = 1 } },
			{ "arcane_barrage", "Astral Barrage", "A barrage of falling mana stars.", { clash = { intelligence = { base = 2, coinPower = 1 } } } },
		},
	},
	{
		id = "sound", name = "Sound", main = "mage", stat = "intelligence",
		entry = { mage = "mana_bolt", tanker = "iron_skin", fighter = "iron_resolve" },
		desc = "Mana as sound: pulses, booms and notes that crack armour. Loud, and impossible to ignore.",
		log = "A season of humming one note in an empty practice hall until the windows answered",
		spells = {
			{ "sound_pulse", "Resonant Pulse", "A pulse of sound you can see.", { clash = { charisma = { base = 1 } }, fight = { base = 1 } } },
			{ "sound_boom", "Sonic Boom", "A boom that throws monsters back.", { fight = { coinPower = 1 } } },
			{ "sound_ear", "Harmonic Ear", "You hear a monster's breath before you see it.", { heads = 3 } },
			{ "sound_crescendo", "Grand Crescendo", "Sound piled on sound until the street rings.", { fight = { base = 3 }, heads = 1 } },
		},
	},
}

--[[ HUNTER CRAFT: for any awakened Hunter. { id, name, flavour, effects, rank, needs, after } ]]
local CRAFT = {
	{ "mana_sensing", "Mana Sensing", "Feel mana the way you feel heat off a stove.", { heads = 2, clash = { intelligence = { base = 1 } } }, 1, { willpower = 15 } },
	{ "field_medicine", "Field Medicine", "Bandages, splints and staying calm.", { yearly = { vitality = 2 } }, 1, { intelligence = 25 } },
	{ "mana_armour", "Mana Armour", "Mana pulled tight over the skin like a second coat.", { toughness = 0.95 }, 2, { vitality = 40 }, "mana_sensing" },
	{ "mana_breathing", "Mana Breathing", "Slow breaths that put the mana back where it belongs.", { yearly = { sanity = 2 } }, 2, { willpower = 40 }, "mana_sensing" },
	{ "blink", "Blink", "Be somewhere else a few metres ahead, with nothing in between.", { clash = { agility = { base = 2 } } }, 3, { agility = 55, intelligence = 40 }, "mana_sensing" },
	{ "gate_instinct", "Gate Instinct", "The hair on your arms rises before the reading does.", { heads = 2, clash = { luck = { base = 1 } } }, 3, { intelligence = 60 }, "mana_sensing" },
}

local traits: any = { order = {} }
local activities = {}
local function addSkill(id: string, def: any, effects: any)
	for k, v in effects do
		def[k] = v
	end
	traits[id] = def
	table.insert(traits.order, id)
end

for _, tree in TREES do
	local n = #tree.skills
	for i, sk in tree.skills do
		local id = "sk_" .. sk[1]
		local rank, need, after = sk[5], sk[6], sk[7]
		local path = if i <= 6 then tree.paths[1] else tree.paths[2]
		local text = sk[3] .. " " .. summary(sk[4]) .. liveLine(id)
		addSkill(id, { name = sk[2], desc = string.format("%s skill %d of %d (%s): %s", tree.name, i, n, path, text), category = "skill", class = tree.class, path = path, step = i, rank = rank }, sk[4])
		local when: any = { flags = { "class_" .. tree.class }, noTrait = id, form = from(rank) }
		if after then
			when.trait = "sk_" .. after
		end
		if need > 0 then
			when.min = { [tree.stat] = need }
		end
		table.insert(activities, {
			id = "learn_" .. sk[1],
			category = "self",
			name = "Learn " .. sk[2],
			desc = string.format("%s skill %d of %d, %s path (%s-rank%s). %s", tree.name, i, n, path, RANK_LETTER[rank], if need > 0 then ", " .. STAT_NAME[tree.stat] .. " " .. need else "", text),
			minAge = 14,
			when = when,
			result = { addTrait = id, sanity = -1, log = "Weeks of drills, and then one day it just worked: " .. sk[2] .. "." },
		})
	end
end

for _, school in SCHOOLS do
	local classes = {}
	for c in school.entry do
		table.insert(classes, c)
	end
	table.sort(classes, function(a, b)
		return (if a == school.main then "0" else "1") .. a < (if b == school.main then "0" else "1") .. b
	end)
	local prev = nil
	for i, sp in school.spells do
		local id = "sk_" .. sp[1]
		local step = SCHOOL_STEPS[i]
		local names = {}
		local open: { string } = if i <= 2 then classes else { school.main }
		for _, c in open do
			table.insert(names, string.upper(string.sub(c, 1, 1)) .. string.sub(c, 2))
		end
		local who = table.concat(names, ", ") .. (if i > 2 then " only" else "")
		local text = sp[3] .. " " .. summary(sp[4]) .. liveLine(id)
		addSkill(id, {
			name = sp[2],
			desc = string.format("%s school, spell %d of 4: %s", school.name, i, text),
			category = "skill",
			school = school.id,
			classes = if i <= 2 then classes else { school.main },
			step = i,
			rank = step.rank,
		}, sp[4])
		local when: any = { noTrait = id, form = from(step.rank), min = { [school.stat] = step.stat } }
		if prev then
			when.trait = prev
		else
			local entry = {}
			for _, c in classes do
				table.insert(entry, "sk_" .. school.entry[c])
			end
			when.trait = entry
		end
		if i > 2 then
			when.flags = { "class_" .. school.main }
		end
		table.insert(activities, {
			id = "learn_" .. sp[1],
			category = "self",
			name = "Study " .. sp[2],
			desc = string.format("%s school, spell %d of 4 (%s-rank, %s %d; %s). %s", school.name, i, RANK_LETTER[step.rank], STAT_NAME[school.stat], step.stat, who, text),
			minAge = 14,
			when = when,
			result = { addTrait = id, sanity = -1, log = school.log .. ": " .. sp[2] .. "." },
		})
		prev = id
	end
	school.classes = classes
end

for _, c in CRAFT do
	local id = "sk_" .. c[1]
	local text = c[3] .. " " .. summary(c[4]) .. liveLine(id)
	addSkill(id, { name = c[2], desc = "Hunter craft (any class): " .. text, category = "skill", craft = true, rank = c[5] }, c[4])
	local when: any = { noTrait = id, form = from(c[5]), min = c[6] }
	if c[7] then
		when.trait = "sk_" .. c[7]
	end
	local needs = {}
	for _, stat in STAT_ORDER do
		if c[6][stat] then
			table.insert(needs, STAT_NAME[stat] .. " " .. c[6][stat])
		end
	end
	table.insert(activities, {
		id = "learn_" .. c[1],
		category = "self",
		name = "Learn " .. c[2],
		desc = string.format("Hunter craft, any class (%s-rank, %s). %s", RANK_LETTER[c[5]], table.concat(needs, ", "), text),
		minAge = 14,
		when = when,
		result = { addTrait = id, sanity = -1, log = "An older Hunter showed you how, once, and then made you do it a hundred times: " .. c[2] .. "." },
	})
end

-- ── talents ── { name, class it leans to, effects, desc (nil: written from the effects) }
local T = {
	common = {
		{ "Quick Learner", "fighter", { growth = { strength = 1.25 } }, "Strength grows 25% faster." },
		{ "Bookworm", "mage", { growth = { intelligence = 1.25 } }, "Intelligence grows 25% faster." },
		{ "Light Feet", "assassin", { growth = { agility = 1.25 } }, "Agility grows 25% faster." },
		{ "Sturdy", "tanker", { toughness = 0.92 }, "8% less damage taken." },
		{ "Good Eyes", "ranger", { heads = 2 }, "+2% heads in every clash." },
		{ "Gentle Hands", "healer", { growth = { willpower = 1.25 } }, "Willpower grows 25% faster." },
		{ "Scrapper", "fighter", { fight = { base = 1 } }, "+1 base in fights." },
		{ "Savings", "healer", { money = 6 }, "Start with 6 million won." },
		{ "Calm Breather", "mage", { sanity = 4, heads = 1 }, "+4 Composure, +1% heads." },
		{ "Street Smart", "assassin", { clash = { charisma = { base = 1 } } }, "+1 base in Charisma checks." },
		{ "Early Riser", "healer", { yearly = { sanity = 1 } } },
		{ "Steady Hands", "ranger", { clash = { agility = { base = 1 } }, heads = 1 } },
		{ "Thick Skin", "tanker", { stats = { vitality = 6 } } },
		{ "Spark of Mana", "mage", { clash = { intelligence = { base = 1 } } } },
	},
	uncommon = {
		{ "Fast Learner", "mage", { growth = 1.2 }, "Every stat grows 20% faster." },
		{ "Hard to Kill", "tanker", { toughness = 0.85 }, "15% less damage taken." },
		{ "Short Fuse", "fighter", { fight = { coinPower = 1 } }, "+1 power per heads in fights." },
		{ "Sharpshooter", "ranger", { clash = { agility = { base = 2 } } }, "+2 base in Agility." },
		{ "Unshaken", "healer", { heads = 3, sanity = 5 }, "+3% heads, +5 Composure." },
		{ "Silent Steps", "assassin", { heads = 3 }, "+3% heads in every clash." },
		{ "Big Frame", "tanker", { stats = { vitality = 10 } }, "+10 Vitality." },
		{ "Hunter's Instinct", "ranger", { clash = { intelligence = { base = 1 }, agility = { base = 1 } } }, "+1 base in Intelligence and Agility." },
		{ "Mana Sense", "mage", { clash = { intelligence = { base = 2 } } }, "+2 base in Intelligence." },
		{ "Brawler's Blood", "fighter", { clash = { strength = { base = 2 } } }, "+2 base in Strength." },
		{ "Iron Lungs", "fighter", { yearly = { vitality = 2 } } },
		{ "Quick Reflexes", "assassin", { heads = 2, fight = { base = 1 } } },
		{ "Warm Presence", "healer", { clash = { charisma = { base = 2 } }, sanity = 3 } },
		{ "Wind Reader", "ranger", { growth = { agility = 1.25 }, heads = 1 } },
	},
	rare = {
		{ "Battle Genius", "fighter", { fight = { base = 2 }, growth = { strength = 1.3 } }, "+2 base in fights; Strength grows 30% faster." },
		{ "Living Shield", "tanker", { toughness = 0.8 }, "20% less damage taken." },
		{ "Arcane Prodigy", "mage", { clash = { intelligence = { base = 2, coinPower = 1 } } }, "+2 base and +1 a heads in Intelligence." },
		{ "Ghost", "assassin", { fight = { coins = 1 } }, "+1 coin in fights." },
		{ "Hawkeye", "ranger", { heads = 5 }, "+5% heads in every clash." },
		{ "Warm Light", "healer", { yearly = { vitality = 4, sanity = 1 } }, "+4 Vitality and +1 Composure a year." },
		{ "Steel Nerves", "tanker", { heads = 3, sanity = 8 }, "+3% heads, +8 Composure." },
		{ "Duelist", "assassin", { fight = { coinPower = 1, base = 1 } }, "+1 base and +1 a heads in fights." },
		{ "Old Soul", "healer", { growth = { willpower = 1.5, intelligence = 1.2 } }, "Willpower grows 50% faster, Intelligence 20%." },
		{ "Born Raider", "ranger", { money = 15, clash = { luck = { base = 2 } } }, "Start with 15 million won; +2 base in Luck." },
		{ "Ember Heart", "mage", { clash = { intelligence = { base = 2 } }, fight = { base = 1 } } },
		{ "Cold Focus", "assassin", { clash = { agility = { coinPower = 1 } }, sanity = 5 } },
		{ "Bulwark Born", "tanker", { toughness = 0.88, clash = { vitality = { base = 1 } } } },
		{ "Battle Medic", "healer", { yearly = { vitality = 3 }, fight = { base = 1 } } },
	},
	epic = {
		{ "Monster's Bane", "fighter", { fight = { base = 3, coinPower = 1 } }, "+3 base, +1 a heads in fights." },
		{ "Mana Well", "mage", { clash = { intelligence = { base = 3, coins = 1 } } }, "+3 base and +1 coin in Intelligence." },
		{ "Untouchable", "assassin", { heads = 6, fight = { coins = 1 } }, "+6% heads, +1 coin in fights." },
		{ "Mountain", "tanker", { toughness = 0.75, stats = { vitality = 15 } }, "25% less damage, +15 Vitality." },
		{ "True Aim", "ranger", { fight = { coinPower = 2 } }, "+2 power per heads in fights." },
		{ "Lifebinder", "healer", { yearly = { vitality = 8 }, toughness = 0.9 }, "+8 Vitality a year, 10% less damage." },
		{ "Fearless", "fighter", { heads = 5, sanity = 10 }, "+5% heads, +10 Composure." },
		{ "Twin Souls", "mage", { growth = 1.35 }, "Every stat grows 35% faster." },
		{ "Storm-Touched", "mage", { clash = { intelligence = { coinPower = 2 } }, heads = 2 } },
		{ "Wolf's Patience", "ranger", { heads = 4, fight = { base = 2 } } },
		{ "Iron Will", "tanker", { heads = 4, sanity = 12, toughness = 0.92 } },
		{ "Saint's Patience", "healer", { yearly = { vitality = 5, sanity = 2 }, heads = 2 } },
	},
	legendary = {
		{ "Born for the Gates", "fighter", { fight = { coins = 1, base = 3 }, toughness = 0.9 }, "+1 coin and +3 base in fights, 10% less damage." },
		{ "Archmage's Spark", "mage", { clash = { intelligence = { base = 4, coinPower = 2 } }, growth = { intelligence = 1.5 } }, "+4 base, +2 a heads in Intelligence; it grows 50% faster." },
		{ "Shadowborn", "assassin", { fight = { coins = 1, coinPower = 2 }, heads = 4 }, "+1 coin, +2 a heads in fights, +4% heads." },
		{ "Unbreaking", "tanker", { toughness = 0.65, stats = { vitality = 25 } }, "35% less damage, +25 Vitality." },
		{ "Starseeker", "ranger", { heads = 8, fight = { base = 3 } }, "+8% heads, +3 base in fights." },
		{ "Miracle Hands", "healer", { yearly = { vitality = 12, sanity = 3 }, heads = 3 }, "+12 Vitality and +3 Composure a year, +3% heads." },
		{ "Blade Saint", "fighter", { fight = { base = 4, coinPower = 1 }, heads = 3 } },
		{ "Moonlit Step", "assassin", { fight = { coins = 1, base = 2 }, toughness = 0.9 } },
		{ "Eye of the Hawk", "ranger", { fight = { coinPower = 2, base = 2 }, heads = 3 } },
	},
	unreal = {
		{ "Echo of a National Level", "fighter", { fight = { coins = 1, base = 5, coinPower = 2 }, toughness = 0.8 }, "+1 coin, +5 base, +2 a heads in fights; 20% less damage." },
		{ "Mana Without End", "mage", { clash = { intelligence = { coins = 1, base = 6, coinPower = 2 } }, growth = 1.4 }, "+1 coin, +6 base, +2 a heads in Intelligence; everything grows 40% faster." },
		{ "The One Nobody Sees", "assassin", { fight = { coins = 2, base = 3 }, heads = 8 }, "+2 coins, +3 base in fights, +8% heads." },
		{ "A Wall for a Country", "tanker", { toughness = 0.55, stats = { vitality = 40 }, heads = 4 }, "45% less damage, +40 Vitality, +4% heads." },
		{ "Arrow of Dawn", "ranger", { fight = { coins = 1, coinPower = 3 }, heads = 6 }, "+1 coin, +3 a heads in fights, +6% heads." },
		{ "Breath of Life", "healer", { yearly = { vitality = 18, sanity = 5 }, toughness = 0.8 }, "+18 Vitality and +5 Composure a year, 20% less damage." },
		{ "Living Element", "mage", { clash = { intelligence = { coins = 1, base = 5, coinPower = 2 } }, toughness = 0.85, heads = 3 } },
	},
}
local TIER_ORDER = { "common", "uncommon", "rare", "epic", "legendary", "unreal" }
local function slug(s: string): string
	return (string.gsub(string.lower(s), "[^%w]+", "_"))
end
for _, tier in TIER_ORDER do
	for _, t in T[tier] do
		local id = "tal_" .. slug(t[1])
		local def: any = { name = t[1], desc = t[4] or summary(t[3], true), talent = tier, affinity = t[2] }
		for k, v in t[3] do
			def[k] = v
		end
		traits[id] = def
		table.insert(traits.order, id)
	end
end

-- more skills from their own files, when the game has them: MonarchSkills.luau (the Monarch
-- classes' authorities, non-canon) and Techniques.luau (techniques a long career teaches). Each
-- returns { traits = { [id] = def }, order = { id... }, activities = { ... }? }.
for _, name in { "MonarchSkills", "Techniques" } do
	local m = script.Parent:FindFirstChild(name)
	if m then
		local ext = require(m) :: any
		for _, id in ext.order or {} do
			local def = ext.traits and ext.traits[id]
			if def and traits[id] == nil then
				traits[id] = def
				table.insert(traits.order, id)
			end
		end
		for _, a in ext.activities or {} do
			table.insert(activities, a)
		end
	end
end

return {
	traits = traits,
	activities = activities,
	trees = TREES,
	schools = SCHOOLS,
	craft = CRAFT,
	summary = summary,
	talents = {
		tiers = {
			{ id = "common", name = "Ordinary", weight = 52, color = { 190, 190, 196 } },
			{ id = "uncommon", name = "Promising", weight = 26, color = { 120, 200, 140 } },
			{ id = "rare", name = "Gifted", weight = 13, color = { 100, 160, 240 } },
			{ id = "epic", name = "Prodigy", weight = 6.5, color = { 180, 110, 240 } },
			{ id = "legendary", name = "One in a Generation", weight = 2.2, color = { 255, 196, 80 } },
			{ id = "unreal", name = "One in the World", weight = 0.3, color = { 255, 70, 90 } },
		},
	},
	-- the classes (the creator shows name and desc on each card; `about`, `stat`, `role` and
	-- `schools` are the longer explanation, for any screen with room for it)
	affinities = {
		order = { "fighter", "mage", "assassin", "tanker", "ranger", "healer" },
		fighter = {
			name = "Fighter", color = { 232, 142, 70 }, stat = "strength", role = "Front line, melee",
			desc = "Strength. The front line: cleaves, charges, slams. Sword, spear and fist arts.",
			about = "The most common class, and the one most raids are built around. Fighters hit hardest up close: wide cuts, shoulder charges, ground slams, and a whirling storm of blades at S-rank. Twelve skills on two paths (Blade and Vanguard); in the city a Fighter also learns the sword, spear and fist arts by rank, and one with a head for it can learn the first spells of fire, earth and sound.",
			schools = { "fire", "earth", "sound" },
		},
		mage = {
			name = "Mage", color = { 120, 170, 255 }, stat = "intelligence", role = "Ranged magic, crowds",
			desc = "Intelligence. Mana shaped into ten schools of magic: fire, frost, storm, void...",
			about = "Mages turn mana into spells and hit whole crowds from across the street. Their own twelve skills (Elements and Arcane paths) end in meteors, cataclysms and a guardian made of mana; on top of that a Mage can study nine magic schools all the way through (fire, frost, lightning, wind, earth, water, void, arcane, sound) and the first spells of venom.",
			schools = { "fire", "frost", "lightning", "wind", "earth", "water", "void", "arcane", "sound", "venom" },
		},
		assassin = {
			name = "Assassin", color = { 170, 90, 220 }, stat = "agility", role = "Burst, mobility",
			desc = "Agility. Speed, venom, one perfect cut. Sword arts and assassination.",
			about = "Assassins are the fastest Hunters alive: they step across a street in an instant, cut six times before anything turns, and finish what's left in one blow. Twelve skills on the Edge and Night paths, the sword arts and assassination techniques by rank, the venom school all the way through, and the first spells of lightning, wind, void and arcane.",
			schools = { "venom", "lightning", "wind", "void", "arcane" },
		},
		tanker = {
			name = "Tanker", color = { 150, 160, 176 }, stat = "vitality", role = "Defence, taunts, shields",
			desc = "Vitality. The wall: taunts, shields, charges. Shield, spear and fist arts.",
			about = "Tankers make the monsters look at them instead of everyone else, then stand there and take it: taunts, shield walls, a dome of mana a whole street can hide under. Twelve skills on the Wall and Guardian paths, the shield, spear and fist arts by rank, and the first spells of frost, earth, holy, life and sound.",
			schools = { "frost", "earth", "holy", "life", "sound" },
		},
		ranger = {
			name = "Ranger", color = { 110, 200, 120 }, stat = "agility", role = "Long range, traps",
			desc = "Agility. Distance and patience: arrows, traps, a hawk of mana. Archery arts.",
			about = "Rangers fight from as far away as the street allows: piercing arrows, rains of them, snare traps, a hawk made of their own mana, and at S-rank an arrow that doesn't come down. Twelve skills on the Bow and Wild paths, the archery techniques by rank, and the first spells of lightning, wind, water, venom and life.",
			schools = { "lightning", "wind", "water", "venom", "life" },
		},
		healer = {
			name = "Healer", color = { 120, 240, 200 }, stat = "willpower", role = "Healing, support",
			desc = "Willpower. The reason the raid comes home: heals, barriers, holy and life magic.",
			about = "Healers keep everyone else standing: they close wounds, raise barriers, calm frozen people, and at the top raise a warden of light over the wounded. Twelve skills on the Mending and Light paths, the holy and life schools all the way through (light that mends people and burns monsters; green light that grows), and the first spells of water and arcane.",
			schools = { "holy", "life", "water", "arcane" },
		},
	},
}
