--[[
	BASE STATS: a game's seven stats, built from its spec.

	The engine has seven stat ROLES. Their mechanics are fixed; what a game calls them is not:
		health   your body. At zero, you die. (the "vital" stat)
		fight    how hard you hit: power in every fight
		speed    how many coins you bring to a fight, and who strikes first; more to do a year
		work     study, skill and jobs: promotions, wages, more to do a year
		charm    people: bonds grow faster, prices come down, talking works
		luck     dealt at birth, hard to change: tilts every coin, dodges bad years
		will     how much a mind can carry: lose less mood, hold on at the breaking point
	plus MOOD (the engine's "sanity"), which runs -45..45 and tilts every coin.

	spec.stats = {
		health = { id = "health", name = "Health", short = "HP", color = { r, g, b }, desc = "..." },
		fight  = { id = "might", name = "Might", ... },
		...
		mood   = { name = "Spirit" },           (what the game calls Sanity)
		tierEvery = 20, tierMax = 21, cap = 100, (optional)
	}
	Every field is optional: a role left out gets the default below. Perks per tier come from
	PERKS (their wording uses the game's own stat and approach names); a role's `perks` in the
	spec replaces them.
]]

local Stats = {}

Stats.ROLES = { "health", "fight", "speed", "work", "charm", "luck", "will" }

Stats.DEFAULTS = {
	health = { id = "health", name = "Health", short = "HP", color = { 214, 96, 88 }, desc = "Your body. At zero, you die." },
	fight = { id = "strength", name = "Strength", short = "STR", color = { 232, 142, 70 }, desc = "How hard you hit. Your power in every fight." },
	speed = { id = "speed", name = "Speed", short = "SPD", color = { 96, 206, 196 }, desc = "How many clashes you can take in a fight, and who moves first. The faster side strikes first." },
	work = { id = "smarts", name = "Smarts", short = "INT", color = { 120, 170, 226 }, desc = "Study, skill and craft. How well you work and how far a job takes you." },
	charm = { id = "charm", name = "Charm", short = "CHA", color = { 226, 126, 178 }, desc = "How people take to you. Bonds grow faster, prices come down, and talking works." },
	luck = { id = "luck", name = "Luck", short = "LCK", color = { 136, 204, 110 }, desc = "Dealt at birth and hard to change: tilts every coin flip, dodges bad years, brings finds.", birth = { 1, 22 } },
	will = { id = "will", name = "Willpower", short = "WIL", color = { 168, 120, 222 }, desc = "How much your mind can carry. Decides whether you hold together when your mood hits the bottom." },
}

-- the default names of the four ways to fight (Base/Systems: approaches); a spec's
-- `fighting` renames them, and the perks below say the new names
Stats.APPROACH_NAMES = { fight = "Overpower", speed = "Outpace", work = "Outthink", charm = "Talk down" }

-- PERKS by role and tier (tier = floor(stat / tierEvery) + 1): the City pack's tuning, in
-- neutral words. %s is the stat's name, %a the approach that fights with it, %m the mood's name.
local PERKS = {
	health = {
		[3] = { name = "Thick skin", desc = "Wounds take 10% less.", toughness = 0.10 },
		[5] = { name = "Hard to kill", desc = "Wounds take 20% less.", toughness = 0.10 },
		[6] = { name = "Unbroken", desc = "Wounds take 30% less.", toughness = 0.10 },
		[7] = { name = "Walking wall", desc = "Wounds take 40% less.", toughness = 0.10 },
		[11] = { name = "Iron frame", desc = "Wounds take 45% less.", toughness = 0.05 },
		[16] = { name = "Like stone", desc = "Wounds take 50% less.", toughness = 0.05 },
		[21] = { name = "Unbreakable", desc = "Wounds take 55% less.", toughness = 0.05 },
	},
	fight = {
		[3] = { name = "Heavy hands", desc = "+1 power when you %a.", stance = { base = 1 } },
		[5] = { name = "Breaker", desc = "Each heads hits 1 harder when you %a.", stance = { coinPower = 1 } },
		[6] = { name = "Crusher", desc = "+2 more power when you %a.", stance = { base = 2 } },
		[7] = { name = "One blow", desc = "Each heads hits 1 harder again when you %a.", stance = { coinPower = 1 } },
		[11] = { name = "Wall-breaker", desc = "+2 power, and each heads 1 harder, when you %a.", stance = { base = 2, coinPower = 1 } },
		[16] = { name = "A legend's arm", desc = "+3 more power when you %a.", stance = { base = 3 } },
		[21] = { name = "One blow, one army", desc = "+3 power and each heads 1 harder again when you %a.", stance = { base = 3, coinPower = 1 } },
	},
	speed = {
		[3] = { name = "Spare hours", desc = "+1 thing to do every year.", actions = 1 },
		[5] = { name = "Never still", desc = "+1 more thing to do every year.", actions = 1 },
		[6] = { name = "Blur", desc = "+2 power when you %a.", stance = { base = 2 } },
		[7] = { name = "Gone before the echo", desc = "Each heads hits 1 harder when you %a.", stance = { coinPower = 1 } },
		[11] = { name = "Afterimage", desc = "+2 power when you %a. At 200 %s you carry a fifth coin into every fight.", stance = { base = 2 } },
		[16] = { name = "Between heartbeats", desc = "Each heads hits 1 harder again when you %a.", stance = { coinPower = 1 } },
		[21] = { name = "Already there", desc = "+3 power when you %a. (A sixth coin came at 350.)", stance = { base = 3 } },
	},
	work = {
		[3] = { name = "Worth more", desc = "Wages +15%%.", wage = 0.15 },
		[4] = { name = "Quick study", desc = "Whatever you do teaches you 1 more.", training = 1 },
		[5] = { name = "Ahead of the day", desc = "+1 thing to do every year.", actions = 1 },
		[6] = { name = "Mastermind", desc = "Wages +15%% more, and +2 power when you %a.", wage = 0.15, stance = { base = 2 } },
		[7] = { name = "A rare mind", desc = "Whatever you do teaches you 1 more again.", training = 1 },
		[11] = { name = "Three moves ahead", desc = "Wages +20%% more, and +2 power when you %a.", wage = 0.2, stance = { base = 2 } },
		[16] = { name = "Reads the room", desc = "Whatever you do teaches you 1 more again.", training = 1 },
		[21] = { name = "A mind for the ages", desc = "+3 power and each heads 1 harder when you %a.", stance = { base = 3, coinPower = 1 } },
	},
	charm = {
		[3] = { name = "Good company", desc = "+1 time for people every year.", social = 1 },
		[4] = { name = "Known face", desc = "Prices 10%% lower.", price = 0.10 },
		[5] = { name = "Everyone's friend", desc = "+1 more time for people every year.", social = 1 },
		[6] = { name = "Silver tongue", desc = "Prices 10%% lower again, and +2 power when you %a.", price = 0.10, stance = { base = 2 } },
		[7] = { name = "The room listens", desc = "+1 more time for people every year.", social = 1 },
		[11] = { name = "Rooms go quiet", desc = "Prices 5%% lower again, and +2 power when you %a.", price = 0.05, stance = { base = 2 } },
		[16] = { name = "A name people repeat", desc = "+1 more time for people every year.", social = 1 },
		[21] = { name = "Everyone listens", desc = "+3 power and each heads 1 harder when you %a.", stance = { base = 3, coinPower = 1 } },
	},
	will = {
		[2] = { name = "Steady", desc = "You lose 15%% less %m.", sanityGuard = 0.15 },
		[4] = { name = "Unshaken", desc = "You lose 30%% less %m.", sanityGuard = 0.15 },
		[6] = { name = "Still water", desc = "You lose 45%% less %m.", sanityGuard = 0.15 },
		[7] = { name = "Anchor", desc = "You lose 60%% less %m.", sanityGuard = 0.15 },
		[11] = { name = "Deep water", desc = "You lose 70%% less %m.", sanityGuard = 0.1 },
		[16] = { name = "Bedrock", desc = "You lose 80%% less %m.", sanityGuard = 0.1 },
		[21] = { name = "Nothing reaches the bottom", desc = "You lose 90%% less %m.", sanityGuard = 0.1 },
	},
}

local NATURES = {
	fight = { "The Strong", "+1 on %s. Trouble comes looking for you." },
	speed = { "The Quick", "+1 on %s. Chases and close calls find you." },
	work = { "The Sharp", "+1 on %s. Puzzles and offers find you." },
	charm = { "The Charming", "+1 on %s. People bring you their business." },
	will = { "The Unshaken", "+1 on %s. The strange finds you." },
}

local function merged(base: any, over: any): any
	local out = table.clone(base)
	for k, v in over or {} do
		out[k] = v
	end
	return out
end

local function words(text: string, statName: string, approach: string, mood: string): string
	-- (%% stays a percent sign; %s, %a and %m are filled)
	local out = string.gsub(text, "%%([sam%%])", function(c)
		if c == "s" then
			return statName
		elseif c == "a" then
			return approach
		elseif c == "m" then
			return mood
		end
		return "%"
	end)
	return out
end

-- the role -> stat def table every other part of Base reads
function Stats.roles(spec: any): any
	local out = {}
	for _, role in Stats.ROLES do
		out[role] = merged(Stats.DEFAULTS[role], spec.stats and spec.stats[role])
	end
	return out
end

-- pack.stats for the engine
function Stats.build(spec: any): any
	local s = spec.stats or {}
	local roles = Stats.roles(spec)
	local moodName = (s.mood and s.mood.name) or "Sanity"
	local approachNames = table.clone(Stats.APPROACH_NAMES)
	for role, def in (spec.fighting or {}) do
		if type(def) == "table" and def.name and approachNames[role] then
			approachNames[role] = def.name
		end
	end
	local out: any = {
		order = {},
		vital = roles.health.id,
		word = s.word or "stat",
		roles = {
			fight = roles.fight.id,
			work = roles.work.id,
			will = roles.will.id,
			speed = roles.speed.id,
			charm = roles.charm.id,
			luck = roles.luck.id,
		},
		grow = { roles.fight.id, roles.speed.id, roles.work.id, roles.charm.id, roles.will.id },
		growPicks = 4,
		tierEvery = s.tierEvery or 20,
		tierMax = s.tierMax or 21,
		cap = s.cap or 100,
		perks = {},
		sanity = { name = moodName, min = -45, max = 45, start = 12, rest = 0, drift = 1 },
	}
	for _, role in Stats.ROLES do
		local def = roles[role]
		table.insert(out.order, def.id)
		out[def.id] = { name = def.name, short = def.short, color = def.color, desc = def.desc, birth = def.birth }
		local perks = def.perks or PERKS[role]
		if perks then
			local p = {}
			for tier, perk in perks do
				local copy = table.clone(perk)
				copy.name = words(copy.name, def.name, approachNames[role] or "", moodName)
				copy.desc = words(copy.desc, def.name, approachNames[role] or "", moodName)
				p[tier] = copy
			end
			out.perks[def.id] = p
		end
	end
	-- NATURE: the stat you lean on (your highest of these, once it's 25)
	out.natures = { order = {}, min = 25 }
	for _, role in { "fight", "speed", "work", "charm", "will" } do
		local def = roles[role]
		local n = NATURES[role]
		table.insert(out.natures.order, def.id)
		local own = def.nature or {}
		out.natures[def.id] = { name = own.name or n[1], desc = own.desc or words(n[2], def.name, "", moodName) }
	end
	return out, roles, approachNames, moodName
end

return Stats
