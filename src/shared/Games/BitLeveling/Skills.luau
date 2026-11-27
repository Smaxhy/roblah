--[[
	SKILLS AND TALENTS (BitLeveling, ORIGINAL game content on canon's Hunter classes).

	CLASS SKILLS: every awakened Hunter has a class (Fighter, Mage, Assassin, Tanker, Ranger,
	Healer: canon's names). Each class has six skills, learned in order on the DO tab. Each
	needs the one before it, a Hunter rank, and enough of the class's main stat; the last needs an
	S-rank. A skill is a trait: what it does to clashes, fights, wounds and years is in its def.
	In the live city a class's skills also power its two abilities (Q and R).

	TALENTS: every life is born with one, rolled by rarity (the odds are shown in the creator):
	Ordinary 52%, Promising 26%, Gifted 13%, Prodigy 6.5%, One in a Generation 2.2%, One in the
	World 0.3%. Each leans to a class: lean toward two classes in the creator and their talents
	are three times as likely (and an awakening leans to them too); a talent of a class you lean
	to resonates (+3% heads in every clash). Talents never decide whether you awaken.
]]

local RANKS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local function from(r: number)
	local out = {}
	for i = r, 6 do
		table.insert(out, RANKS[i])
	end
	return out
end

-- class, main stat, six skills: { id, name, desc, effects... } (requirements are by position)
local TREES = {
	{
		class = "fighter", name = "Fighter", stat = "strength",
		skills = {
			{ "power_strike", "Power Strike", "Put your whole body behind one blow. +1 base in fights, +1 in Strength checks.", { fight = { base = 1 }, clash = { strength = { base = 1 } } } },
			{ "whirlwind", "Whirlwind", "A spinning cut that catches everything around you. +1 power per heads in fights.", { fight = { coinPower = 1 } } },
			{ "iron_resolve", "Iron Resolve", "You stop flinching. +3% heads in every clash, +5 Composure now.", { heads = 3, sanity = 5 } },
			{ "sundering_blow", "Sundering Blow", "A strike that breaks armour and stone. +3 base in fights.", { fight = { base = 3 } } },
			{ "berserk", "Berserk", "Pain becomes fuel. +2 power per heads in fights, 10% less damage taken.", { fight = { coinPower = 2 }, toughness = 0.9 } },
			{ "bladestorm", "Bladestorm", "For a few seconds you are everywhere at once. +1 coin and +4 base in fights.", { fight = { coins = 1, base = 4 } } },
		},
	},
	{
		class = "mage", name = "Mage", stat = "intelligence",
		skills = {
			{ "mana_bolt", "Mana Bolt", "A bolt of raw mana. +2 base in Intelligence checks and fights you read.", { clash = { intelligence = { base = 2 } } } },
			{ "flame_lance", "Flame Lance", "A spear of fire that goes through the first thing it hits. +1 power per heads in Intelligence.", { clash = { intelligence = { coinPower = 1 } }, fight = { base = 1 } } },
			{ "frost_nova", "Frost Nova", "Everything near you freezes for a heartbeat. +3% heads, +1 coin in Intelligence.", { heads = 3, clash = { intelligence = { coins = 1 } } } },
			{ "chain_lightning", "Chain Lightning", "Lightning that jumps from monster to monster. +3 base in Intelligence, +1 in fights.", { clash = { intelligence = { base = 3 } }, fight = { base = 1 } } },
			{ "meteor", "Meteor", "You call something down from a sky that isn't there. +2 power per heads in Intelligence.", { clash = { intelligence = { coinPower = 2 } }, fight = { coinPower = 1 } } },
			{ "cataclysm", "Arcane Cataclysm", "The street remembers it for years. +1 coin, +5 base in Intelligence.", { clash = { intelligence = { coins = 1, base = 5 } } } },
		},
	},
	{
		class = "assassin", name = "Assassin", stat = "agility",
		skills = {
			{ "quick_strike", "Quick Strike", "Hit before they know you moved. +1 base in Agility.", { clash = { agility = { base = 1 } }, fight = { base = 1 } } },
			{ "stealth", "Stealth", "Be where nobody is looking. +4% heads in every clash.", { heads = 4 } },
			{ "venom_edge", "Venom Edge", "Coat the blade. Every cut keeps cutting. +1 power per heads in fights.", { fight = { coinPower = 1 } } },
			{ "shadow_step", "Shadow Step", "Close the distance in one step. +1 coin in fights.", { fight = { coins = 1 } } },
			{ "assassinate", "Assassinate", "Find the one place it can't defend. +4 base in fights.", { fight = { base = 4 } } },
			{ "phantom_dance", "Phantom Dance", "Afterimages everywhere; none of them are you. +1 coin, +3% heads, +2 power per heads in fights.", { fight = { coins = 1, coinPower = 2 }, heads = 3 } },
		},
	},
	{
		class = "tanker", name = "Tanker", stat = "vitality",
		skills = {
			{ "taunt", "Taunt", "Make it look at you, not them. +2 base in Vitality checks.", { clash = { vitality = { base = 2 } } } },
			{ "shield_wall", "Shield Wall", "Plant your feet. 10% less damage taken.", { toughness = 0.9 } },
			{ "iron_skin", "Iron Skin", "Mana hardens under your skin. +15 Vitality, 10% less damage.", { stats = { vitality = 15 }, toughness = 0.9 } },
			{ "fortress", "Fortress", "Nothing gets past you. +3 base in fights.", { fight = { base = 3 } } },
			{ "unbreakable", "Unbreakable", "You've stopped counting what you've taken. 15% less damage, +3% heads.", { toughness = 0.85, heads = 3 } },
			{ "bastion", "Bastion", "A wall a city stands behind. 15% less damage, +1 coin in fights, +30 Vitality.", { toughness = 0.85, fight = { coins = 1 }, stats = { vitality = 30 } } },
		},
	},
	{
		class = "ranger", name = "Ranger", stat = "agility",
		skills = {
			{ "aimed_shot", "Aimed Shot", "Breathe out, then shoot. +3% heads.", { heads = 3 } },
			{ "multishot", "Multishot", "Three arrows, one draw. +1 power per heads in fights.", { fight = { coinPower = 1 } } },
			{ "eagle_eye", "Eagle Eye", "You see the weak spot from across the street. +2 base in Agility and Intelligence.", { clash = { agility = { base = 2 }, intelligence = { base = 2 } } } },
			{ "piercing_arrow", "Piercing Arrow", "Through the shield, through the armour. +3 base in fights.", { fight = { base = 3 } } },
			{ "arrow_rain", "Arrow Rain", "The sky over them fills. +1 coin in fights.", { fight = { coins = 1 } } },
			{ "skypierce", "Skypierce", "An arrow that doesn't come down. +2 power per heads, +4 base in fights.", { fight = { coinPower = 2, base = 4 } } },
		},
	},
	{
		class = "healer", name = "Healer", stat = "willpower",
		skills = {
			{ "mend", "Mend", "Close a wound with your hands. +5 Vitality a year.", { yearly = { vitality = 5 } } },
			{ "purify", "Purify", "Wash the fear out of a mind. +3 Composure a year.", { yearly = { sanity = 3 } } },
			{ "barrier", "Barrier", "A shell of light around someone. 10% less damage taken.", { toughness = 0.9 } },
			{ "regeneration", "Regeneration", "Wounds close on their own now. +8 Vitality a year.", { yearly = { vitality = 8 } } },
			{ "sanctuary", "Sanctuary", "Where you stand, people stop being afraid. +4% heads, +2 Composure a year.", { heads = 4, yearly = { sanity = 2 } } },
			{ "grace", "Grace of the Healer", "You can pull someone back from almost anything. +40 Vitality, +10 Vitality a year.", { stats = { vitality = 40 }, yearly = { vitality = 10 } } },
		},
	},
}

-- what each step of a tree needs: a rank and the main stat
local NEEDS = { { rank = 1, stat = 0 }, { rank = 2, stat = 35 }, { rank = 3, stat = 60 }, { rank = 4, stat = 100 }, { rank = 5, stat = 160 }, { rank = 6, stat = 240 } }

local traits: any = { order = {} }
local activities = {}
for _, tree in TREES do
	local prev = nil
	for i, sk in tree.skills do
		local id = "sk_" .. sk[1]
		local def: any = { name = sk[2], desc = tree.name .. " skill " .. i .. ": " .. sk[3], category = "skill", class = tree.class }
		for k, v in sk[4] do
			def[k] = v
		end
		traits[id] = def
		table.insert(traits.order, id)
		local need = NEEDS[i]
		local when: any = { flags = { "class_" .. tree.class }, noTrait = id, form = from(need.rank) }
		if prev then
			when.trait = prev
		end
		if need.stat > 0 then
			when.min = { [tree.stat] = need.stat }
		end
		table.insert(activities, {
			id = "learn_" .. sk[1],
			category = "self",
			name = "Learn " .. sk[2],
			desc = tree.name .. " skill " .. i .. " of 6. " .. sk[3],
			minAge = 14,
			when = when,
			result = { addTrait = id, sanity = -1, log = "Weeks of drills, and then one day it just worked: " .. sk[2] .. "." },
		})
		prev = id
	end
end

-- ── talents ──
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
	},
	legendary = {
		{ "Born for the Gates", "fighter", { fight = { coins = 1, base = 3 }, toughness = 0.9 }, "+1 coin and +3 base in fights, 10% less damage." },
		{ "Archmage's Spark", "mage", { clash = { intelligence = { base = 4, coinPower = 2 } }, growth = { intelligence = 1.5 } }, "+4 base, +2 a heads in Intelligence; it grows 50% faster." },
		{ "Shadowborn", "assassin", { fight = { coins = 1, coinPower = 2 }, heads = 4 }, "+1 coin, +2 a heads in fights, +4% heads." },
		{ "Unbreaking", "tanker", { toughness = 0.65, stats = { vitality = 25 } }, "35% less damage, +25 Vitality." },
		{ "Starseeker", "ranger", { heads = 8, fight = { base = 3 } }, "+8% heads, +3 base in fights." },
		{ "Miracle Hands", "healer", { yearly = { vitality = 12, sanity = 3 }, heads = 3 }, "+12 Vitality and +3 Composure a year, +3% heads." },
	},
	unreal = {
		{ "Echo of a National Level", "fighter", { fight = { coins = 1, base = 5, coinPower = 2 }, toughness = 0.8 }, "+1 coin, +5 base, +2 a heads in fights; 20% less damage." },
		{ "Mana Without End", "mage", { clash = { intelligence = { coins = 1, base = 6, coinPower = 2 } }, growth = 1.4 }, "+1 coin, +6 base, +2 a heads in Intelligence; everything grows 40% faster." },
		{ "The One Nobody Sees", "assassin", { fight = { coins = 2, base = 3 }, heads = 8 }, "+2 coins, +3 base in fights, +8% heads." },
		{ "A Wall for a Country", "tanker", { toughness = 0.55, stats = { vitality = 40 }, heads = 4 }, "45% less damage, +40 Vitality, +4% heads." },
		{ "Arrow of Dawn", "ranger", { fight = { coins = 1, coinPower = 3 }, heads = 6 }, "+1 coin, +3 a heads in fights, +6% heads." },
		{ "Breath of Life", "healer", { yearly = { vitality = 18, sanity = 5 }, toughness = 0.8 }, "+18 Vitality and +5 Composure a year, 20% less damage." },
	},
}
local function slug(s: string): string
	return (string.gsub(string.lower(s), "[^%w]+", "_"))
end
for tier, list in T do
	for _, t in list do
		local id = "tal_" .. slug(t[1])
		local def: any = { name = t[1], desc = t[4], talent = tier, affinity = t[2] }
		for k, v in t[3] do
			def[k] = v
		end
		traits[id] = def
		table.insert(traits.order, id)
	end
end

return {
	traits = traits,
	activities = activities,
	trees = TREES,
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
	affinities = {
		order = { "fighter", "mage", "assassin", "tanker", "ranger", "healer" },
		fighter = { name = "Fighter", color = { 232, 142, 70 }, desc = "Swords, fists, the front line." },
		mage = { name = "Mage", color = { 120, 170, 255 }, desc = "Mana, shaped into fire, ice and lightning." },
		assassin = { name = "Assassin", color = { 170, 90, 220 }, desc = "Speed, shadows, one perfect cut." },
		tanker = { name = "Tanker", color = { 150, 160, 176 }, desc = "The wall everyone else stands behind." },
		ranger = { name = "Ranger", color = { 110, 200, 120 }, desc = "Distance, patience, a bow." },
		healer = { name = "Healer", color = { 120, 240, 200 }, desc = "The reason the raid comes home." },
	},
}
