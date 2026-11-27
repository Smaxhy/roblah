--[[
	BASE SYSTEMS: the rules every BitLife-style game in this kit shares, in neutral words.
	Base.build (Base/init.luau) puts these on the pack; a game's spec can change any of them
	(`spec.tuning`, `spec.fighting`, `spec.difficulties`, `spec.people`...).

	Every table here is the City pack's tuning (v0.18), which was balanced with headless lives:
	the numbers are a good start for a dangerous world. A gentler game lowers `lethality`,
	`hardness` and the dread roll (spec.tuning).
]]

local Systems = {}

local function deepCopy(t: any): any
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in t do
		out[k] = deepCopy(v)
	end
	return out
end
Systems.deepCopy = deepCopy

-- merge `over` into a copy of `base`, table by table (lists are replaced, not merged)
local function isList(t: any): boolean
	return type(t) == "table" and #t > 0
end
function Systems.merge(base: any, over: any): any
	if over == nil then
		return deepCopy(base)
	end
	if type(base) ~= "table" or type(over) ~= "table" or isList(over) then
		return deepCopy(over)
	end
	local out = deepCopy(base)
	for k, v in over do
		if type(v) == "table" and type(out[k]) == "table" and not isList(v) then
			out[k] = Systems.merge(out[k], v)
		else
			out[k] = deepCopy(v)
		end
	end
	return out
end

-- ── how dangerous the world is ─────────────────────────────────────────────────────
Systems.TUNING = {
	-- the clash curve: one more coin every coinsEvery points of Speed (to maxCoins), +1 base
	-- every baseEvery, +1 per-heads power every powerEvery
	clash = {
		coinsEvery = 32,
		maxCoins = 4,
		extraCoinsAt = { 200, 350 },
		baseEvery = 22,
		powerEvery = 50,
		foeGrowth = { fromAge = 16, everyYears = 6, maxBase = 8 },
		fightBase = 1,
	},
	lethality = 1.6, -- adults: every Health loss lands this much harder
	youthLethality = 1.05,
	childHazard = 0.5,
	dangerByAge = { { from = 18, mult = 1.25 }, { from = 24, mult = 1.5 }, { from = 46, mult = 1.25 } },
	eventsPerYear = { { upTo = 0, n = 0 }, { upTo = 3, n = 1 }, { upTo = 59, n = 1.4 }, { upTo = 999, n = 1.2 } },
	natureDraw = 1.6,
	bondPerks = { backAt = 80, saveAt = 92, saveHealth = 6, minAge = 16 },
	-- HARDER CARDS (Engine/Sim.luau): every clash on a card is stronger, a dangerous one (tag
	-- "danger" or `dread = true`) more so, and it grows with you; the dread roll sends one
	-- more dangerous card in some years
	hardness = {
		fromAge = 14,
		cardBase = 1,
		dangerBase = 2,
		dangerCoins = 1,
		match = { from = 50, every = 35, max = 5 },
		dangerWeight = 1.5,
		dreadWeight = 2.5,
		dread = { fromAge = 16, chance = 0.2, byAge = { { from = 24, chance = 0.28 }, { from = 46, chance = 0.22 } }, focusMult = 0.5 },
	},
	-- RICHER HARD RUNS (Engine/Expedition.luau): a run's tier is its strongest clash
	expeditionPay = {
		tiers = { 9, 11, 13, 14 },
		[2] = { money = 1.5, stats = 1.25, renown = 1.25 },
		[3] = { money = 2.5, stats = 1.5, renown = 1.75, bonus = { money = { 1200, 2800 }, renown = 8 } },
		[4] = { money = 4, stats = 2, renown = 2.5, bonus = { money = { 4000, 9000 }, renown = 20, limitBreakFight = 2 } },
		[5] = { money = 6, stats = 3, renown = 3.5, bonus = { money = { 12000, 26000 }, renown = 45, limitBreakFight = 5 } },
	},
	-- FOCUS (Engine/Focus.luau): what starts a thread is what the next years are about
	focus = { years = 3, boost = 6, others = 0.5, minTopic = 4, topics = {}, names = {} },
}

-- ── how you fight ────────────────────────────────────────────────────────────────
-- Every foe has a TEMPER; each way of fighting beats one temper and is poor against another.
Systems.TEMPERS = {
	order = { "brute", "quick", "cunning" },
	brute = { name = "Brute", desc = "Heavy and slow.", weakTo = "speed", strongTo = "wits", color = { 214, 96, 72 } },
	quick = { name = "Quick", desc = "Fast and light.", weakTo = "wits", strongTo = "power", color = { 96, 200, 210 } },
	cunning = { name = "Cunning", desc = "Has a plan.", weakTo = "power", strongTo = "speed", color = { 150, 130, 230 } },
}

function Systems.approaches(spec: any, roles: any, names: any): any
	local f = spec.fighting or {}
	local function n(role: string, key: string, default: any): any
		local own = f[role]
		return (own and own[key]) or default
	end
	local out: any = {
		order = { "power", "speed", "wits", "talk" },
		power = {
			name = names.fight, short = n("fight", "short", "Wins +25%"), desc = n("fight", "desc", "Fight with " .. roles.fight.name .. ". Wins pay a quarter more."),
			stat = roles.fight.id, fightOnly = true, beats = "cunning", loses = "quick", gain = 1.25,
		},
		speed = {
			name = names.speed, short = n("speed", "short", "Losses -40%"), desc = n("speed", "desc", "Fight with " .. roles.speed.name .. ". A loss costs you less."),
			stat = roles.speed.id, fightOnly = true, beats = "brute", loses = "cunning", loss = 0.6,
		},
		wits = {
			name = names.work, short = n("work", "short", "Their coins -10%"), desc = n("work", "desc", "Fight with " .. roles.work.name .. ". Their coins land worse."),
			stat = roles.work.id, fightOnly = true, beats = "quick", loses = "brute", foeHeads = -10,
		},
		talk = {
			name = names.charm, short = n("charm", "short", "No blood"), desc = n("charm", "desc", "Fight with " .. roles.charm.name .. ". People only. Win, and nobody holds it against you."),
			stat = roles.charm.id, fightOnly = true, only = "person", bloodless = true,
		},
	}
	-- a game's own ways of fighting (a spell, a technique, a pet...): same shape as above,
	-- usually with `requires` (a flag, a trait, gear) and a cost
	for id, def in f.extra or {} do
		out[id] = def
		table.insert(out.order, id)
	end
	return out
end

Systems.ABILITIES = {
	guard = { name = "Guard", desc = "The first clash you lose costs you no coin." },
	riposte = { name = "Riposte", desc = "Lose a clash with heads in it, and they hit weaker next clash." },
	crush = { name = "Crush", desc = "The first clash you win knocks off a second coin." },
	reach = { name = "Reach", desc = "Their first clash can't take a coin from you." },
	volley = { name = "Volley", desc = "Your first clash: every heads hits much harder." },
	quick = { name = "Quick", desc = "You strike first even when you're only a little faster." },
	drink = { name = "Drink", desc = "Every clash you win, you heal: Health back after the fight." },
	pierce = { name = "Pierce", desc = "Their base power counts for less: armor doesn't help them." },
	bleed = { name = "Bleed", desc = "Your heads make them Bleed: they lose power whenever they hit." },
	burn = { name = "Burn", desc = "Your heads set them burning: they lose power every clash." },
	tremor = { name = "Tremor", desc = "Your heads shake them; shake them enough and a coin comes loose." },
	rupture = { name = "Rupture", desc = "Your heads crack their guard: your next hits land harder." },
	sinking = { name = "Sinking", desc = "Your heads drag them down: their coins land heads less." },
	poise = { name = "Poise", desc = "Your heads build Poise: heads that may count twice." },
	charge = { name = "Charge", desc = "You build Charge every clash, and spend it in one big hit." },
}

-- the seven statuses the engine knows (Engine/Clash.luau). A game renames them or tints them
-- with spec.vfx.statuses = { burn = { name = "Fire", color = {...} } }; the client's 3D effects
-- follow the same table (client/UI/Fx3D.luau).
Systems.STATUSES = {
	tremor = { name = "Tremor", color = { 214, 180, 92 } },
	rupture = { name = "Rupture", color = { 96, 200, 170 } },
	bleed = { name = "Bleed", color = { 214, 64, 64 } },
	burn = { name = "Burn", color = { 238, 120, 44 } },
	sinking = { name = "Sinking", color = { 92, 120, 220 } },
	poise = { name = "Poise", color = { 140, 210, 240 } },
	charge = { name = "Charge", color = { 120, 200, 255 } },
}

Systems.DIFFICULTIES = {
	order = { "gentle", "normal", "hard" },
	default = "normal",
	gentle = {
		name = "Gentle",
		desc = "For learning. Wounds land softer, bad years come less often, and what you meet is a little weaker.",
		lethality = 0.7, foeBase = -1, hazard = 0.6, hardness = 0.34, score = 0.7, color = { 120, 200, 140 },
	},
	normal = {
		name = "Normal",
		desc = "As it is. Life is hard, and it's usually something you chose.",
		lethality = 1, foeBase = 0, hazard = 1, score = 1, color = { 207, 163, 73 },
	},
	hard = {
		name = "Hard",
		desc = "Every wound lands harder, everything you meet is stronger, and bad luck knows your address. Life scores count for more.",
		lethality = 1.3, foeBase = 1, hazard = 1.35, hardness = 1.34, score = 1.4, color = { 214, 64, 64 },
	},
}

-- ── people ───────────────────────────────────────────────────────────────────────
Systems.RELATION_KINDS = {
	mother = { name = "Mother", family = true, ageGap = { 20, 36 } },
	father = { name = "Father", family = true, ageGap = { 21, 42 } },
	sibling = { name = "Sibling", family = true, ageGap = { -8, 8 } },
	child = { name = "Child", family = true, heir = true },
	friend = { name = "Friend" },
	mentor = { name = "Mentor" },
	rival = { name = "Rival" },
	acquaintance = { name = "Someone you've met" },
}

function Systems.acquaintances(spec: any): any
	local own = spec.people and spec.people.met
	return {
		minAge = 6,
		chance = 0.35,
		cap = 6,
		drift = 4,
		roles = own or {
			{ text = "a neighbor from down the street" },
			{ text = "a kid from the next house", when = { maxAge = 15 } },
			{ text = "someone from your class", when = { maxAge = 17 } },
			{ text = "a stall-keeper at the market", when = { minAge = 12 } },
			{ text = "a coworker", when = { anyCareer = true } },
			{ text = "a coworker who eats lunch alone", when = { anyCareer = true } },
			{ text = "a regular at the place you eat", when = { minAge = 16 } },
			{ text = "someone from the healer's waiting room", when = { minAge = 16 } },
		},
	}
end

function Systems.interactions(roles: any): any
	return {
		order = { "spend_time", "teach", "ask_help", "make_peace", "send_word" },
		spend_time = {
			name = "Spend time together",
			desc = "An evening with {rel}, doing nothing much.",
			cooldown = 1,
			result = { bond = { 6, 12 }, sanity = { 1, 3 }, log = "You spent an evening with {rel}." },
			logs = {
				mother = "You helped your mother, {rel}, with the chores, and she told you about the year she was your age.",
				father = "You sat on the step with your father, {rel}, fixing something that didn't need fixing.",
				sibling = "You and {rel} stayed up arguing about nothing, like when you were small.",
				child = "You took {rel} out to see something new.",
				friend = "You and {rel} shared a meal and all the gossip worth having.",
				mentor = "{rel} walked you through an old lesson and told you which parts were lies.",
				rival = "You and {rel} called an uneasy truce. It held for the evening.",
			},
		},
		teach = {
			name = "Teach them something",
			desc = "Teaching sharpens you too.",
			kinds = { "child", "sibling" },
			relMinAge = 5,
			relMaxAge = 17,
			minAge = 16,
			cooldown = 1,
			result = { bond = { 4, 8 }, [roles.work.id] = { 1, 2 }, log = "You taught {rel} something you know. They got it faster than you did." },
		},
		ask_help = {
			name = "Ask for help",
			desc = "A little {currency} to get through the year. They'll remember it.",
			kinds = { "mother", "father", "sibling", "mentor" },
			minAge = 16,
			minBond = 55,
			cooldown = 3,
			result = { wage = { 25, 60 }, bond = { -6, -2 }, log = "{rel} pressed some {currency} into your hand and told you not to make a habit of it." },
		},
		make_peace = {
			name = "Make peace",
			desc = "Old grudges don't go quietly. Say the hard thing and see what happens.",
			linked = false,
			maxBond = 40,
			cooldown = 2,
			clash = { stat = roles.will.id, foe = "Old grudges", coins = 2, base = 4, coinPower = 3 },
			win = { bond = { 14, 24 }, sanity = 2, log = "You and {rel} talked until late. Something mended." },
			lose = { bond = { -6, -2 }, sanity = -2, log = "It turned into the same old fight with {rel}." },
		},
		send_word = {
			name = "Send word",
			desc = "A note to {rel}, wherever their life has taken them.",
			linked = true,
			online = true,
			cooldown = 1,
			result = {
				bond = { 4, 8 },
				log = "You sent {rel} a note.",
				linked = { sanity = { 1, 3 }, log = "{sender} sent word: a short note, thinking of you." },
			},
		},
	}
end

-- ── what goes wrong ──────────────────────────────────────────────────────────────
function Systems.conditions(roles: any): any
	local fight, work, will, health = roles.fight.id, roles.work.id, roles.will.id, roles.health.id
	return {
		broken_arm = { name = "Broken Arm", years = 2, desc = "-1 coin in " .. roles.fight.name .. " clashes, -1 base in " .. roles.work.name .. " clashes.", gainLog = "Your arm is broken. It will take a long time to set.", clash = { [fight] = { coins = -1 }, [work] = { base = -1 } }, look = "cast" },
		broken_ribs = { name = "Broken Ribs", years = 2, desc = "-1 base in " .. roles.fight.name .. " clashes, and a little " .. roles.health.name .. " lost every year.", gainLog = "Something cracked in your side. Every breath reminds you.", clash = { [fight] = { base = -1 } }, yearly = { [health] = { -2, -1 } }, look = "bandaged" },
		fever = { name = "Fever", years = 1, desc = "Lose a little " .. roles.health.name .. " this year.", gainLog = "A fever took hold and wouldn't let go.", yearly = { [health] = { -3, -1 } }, look = "pale" },
		burns = { name = "Burns", years = 2, desc = "-2 base in " .. roles.work.name .. " clashes.", gainLog = "Your hands are burned and bandaged.", clash = { [work] = { base = -2 } }, look = "bandaged" },
		night_terrors = { name = "Night Terrors", years = 2, desc = "-2 mood a year, -1 base in " .. roles.will.name .. " clashes.", gainLog = "You started waking up shouting.", yearly = { sanity = -2 }, clash = { [will] = { base = -1 } }, look = "shadows" },
		grief = { name = "Grief", years = 1, curable = false, desc = "-2 mood this year.", gainLog = "Grief moved in and sat at the table.", healLog = "The grief eased into something you could carry.", yearly = { sanity = -2 }, look = "armband" },
		scarred = { name = "Scarred", years = 3, desc = "-1 base in every fight for a while.", gainLog = "It healed badly. You'll carry the mark.", clash = { [fight] = { base = -1 } }, look = "bandaged" },
	}
end

function Systems.hazards(roles: any, sides: { string }): any
	local health = roles.health.id
	local poor = sides[#sides]
	return {
		{ id = "base_hz_robbed", title = "Robbed", side = poor, weight = 12, when = { minAge = 12 }, result = { money = { -60, -10 }, [health] = { -8, -2 }, sanity = -2, log = "Three shapes in the dark took your coat, your coins, and some of your nerve.", cause = "Beaten in a robbery" } },
		{ id = "base_hz_fire", title = "Fire!", side = poor, weight = 6, result = { condition = "burns", money = { -80, -20 }, [health] = { -10, -3 }, sanity = -4, log = "A lamp tipped over on the floor below. You got out with the clothes you were wearing.", cause = "Caught in a fire" } },
		{ id = "base_hz_fever", title = "A Bad Winter", weight = 10, result = { condition = "fever", [health] = { -6, -2 }, log = "The winter got into your chest and stayed there." } },
		{ id = "base_hz_fall", title = "A Bad Fall", weight = 8, when = { minAge = 6 }, result = { condition = "broken_arm", [health] = { -8, -3 }, log = "You missed a step in the dark. Your arm took the fall." } },
		{ id = "base_hz_lost_pay", title = "Lost Wages", weight = 8, when = { anyCareer = true }, result = { money = { -90, -20 }, sanity = -2, log = "Your pay went missing between the counting house and your hand. Nobody knows anything." } },
		{ id = "base_hz_quiet_year", title = "A Grey Year", weight = 6, when = { minAge = 14 }, result = { sanity = -5, log = "Nothing went wrong this year. Nothing went right either. The grey got into everything." } },
	}
end

-- ── how a life is remembered ───────────────────────────────────────────────────────
function Systems.records(roles: any): any
	return {
		{ id = "old_bones", name = "Old Bones", desc = "Live to 80.", check = { when = { minAge = 80 } } },
		{ id = "gone_too_soon", name = "Gone Too Soon", desc = "Die before 25.", check = { when = { maxAge = 24 } } },
		{ id = "heavy_purse", name = "Heavy Purse", desc = "Hold 10,000 {currency} at once.", check = { minPeakMoney = 10000 } },
		{ id = "top_of_the_ladder", name = "Top of the Ladder", desc = "Reach the top rank of any job.", check = { minPeakRank = 5 } },
		{ id = "wanderer", name = "Wanderer", desc = "Move house four times in one life.", check = { minMoves = 4 } },
		{ id = "family_line", name = "Family Line", desc = "Raise two children.", check = { minChildren = 2 } },
		{ id = "carried_on", name = "Carried On", desc = "Finish a life as someone's heir.", check = { heir = true } },
		{ id = "brawler", name = "Hard to Put Down", desc = "Win 25 fights in one life.", check = { tally = { clashesWon = 25 } } },
		{ id = "explorer", name = "Explorer", desc = "Finish 5 expeditions in one life.", check = { tally = { expeditions = 5 } } },
		{ id = "not_alone", name = "Not Alone", desc = "Link lives with a friend.", check = { when = { flags = { "had_linked" } } } },
	}
end

function Systems.ambitions(roles: any, currency: string): any
	local fight, work, charm, will, health = roles.fight.id, roles.work.id, roles.charm.id, roles.will.id, roles.health.id
	return {
		{ id = "first_friend", name = "Someone in your corner", desc = "Make a friend.", minAge = 4, maxAge = 16, check = { when = { hasRelation = "friend" } }, reward = { sanity = 3, log = "Having a friend made the whole world smaller and safer." } },
		{ id = "book_learning", name = "Book learning", desc = "Reach 30 " .. roles.work.name .. ".", minAge = 6, maxAge = 18, check = { when = { min = { [work] = 30 } } }, progress = { stat = work, target = 30 }, reward = { [work] = 2, log = "You know things now that most grown-ups don't." } },
		{ id = "scrapper", name = "Scrapper", desc = "Win 3 fights.", minAge = 8, maxAge = 30, check = { tally = { clashesWon = 3 } }, progress = { tally = "clashesWon", target = 3 }, reward = { [fight] = 2, log = "Word got around: you don't back down." } },
		{ id = "steady_nerves", name = "Steady nerves", desc = "Reach 30 " .. roles.will.name .. ".", minAge = 8, maxAge = 25, check = { when = { min = { [will] = 30 } } }, progress = { stat = will, target = 30 }, reward = { sanity = 3, log = "Things that used to frighten you just make you think now." } },
		{ id = "first_job", name = "Earn your keep", desc = "Get a job.", minAge = 14, maxAge = 45, check = { when = { anyCareer = true } }, reward = { wage = { 20, 40 }, log = "Your first proper wage. You spent some and hid the rest." } },
		{ id = "save_500", name = "Something put by", desc = "Hold 500 " .. currency .. " at once.", minAge = 16, maxAge = 60, check = { when = { min = { money = 500 } } }, progress = { money = 500 }, reward = { sanity = 3, log = "A little money put by, for the first time. You slept better." } },
		{ id = "save_5000", name = "A real nest egg", desc = "Hold 5,000 " .. currency .. " at once.", minAge = 20, maxAge = 75, check = { when = { min = { money = 5000 } } }, progress = { money = 5000 }, reward = { sanity = 4, log = "Five thousand. People started asking you for advice." } },
		{ id = "moving_up", name = "Moving up", desc = "Reach rank 3 in any job.", minAge = 18, maxAge = 60, check = { when = { anyCareer = true, minRank = 3 } }, progress = { rank = 3 }, reward = { wage = { 40, 80 }, log = "Rank three. A key of your own, and people who answer to you." } },
		{ id = "top_rank", name = "Top of the ladder", desc = "Reach rank 5 in any job.", minAge = 25, maxAge = 80, weight = 6, check = { when = { anyCareer = true, minRank = 5 } }, progress = { rank = 5 }, reward = { sanity = 6, log = "The top rank. Nobody above you but the weather." } },
		{ id = "fighter", name = "Hard to put down", desc = "Win 12 fights.", minAge = 16, maxAge = 70, check = { tally = { clashesWon = 12 } }, progress = { tally = "clashesWon", target = 12 }, reward = { [health] = 4, log = "Twelve fights won. You walk differently now." } },
		{ id = "expedition_one", name = "Out past the edge", desc = "Finish an expedition.", minAge = 14, maxAge = 70, check = { tally = { expeditions = 1 } }, progress = { tally = "expeditions", target = 1 }, reward = { sanity = 3, log = "You went somewhere most people never go, and came back." } },
		{ id = "people_person", name = "People person", desc = "Reach 40 " .. roles.charm.name .. ".", minAge = 12, maxAge = 50, check = { when = { min = { [charm] = 40 } } }, progress = { stat = charm, target = 40 }, reward = { sanity = 3, log = "Rooms warm up when you walk in now." } },
		{ id = "a_family", name = "A family of your own", desc = "Raise a child.", minAge = 22, maxAge = 60, check = { minChildren = 1 }, reward = { sanity = 5, log = "Someone small calls you by a new name now." } },
		{ id = "old_age", name = "See your hair go grey", desc = "Live to 60.", minAge = 40, maxAge = 59, check = { when = { minAge = 60 } }, progress = { age = 60 }, reward = { sanity = 5, log = "Sixty. Most of the people you grew up with didn't get here." } },
	}
end

function Systems.ribbons(): any
	return {
		{ id = "gilded", name = "The Gilded", desc = "Held more money than most people see in a lifetime.", check = { minPeakMoney = 20000 } },
		{ id = "legend", name = "A Legend", desc = "Came back from more expeditions than anyone can count.", check = { tally = { expeditions = 8 } } },
		{ id = "undying", name = "The Undying", desc = "Outlived nearly everyone they ever knew.", check = { when = { minAge = 88 } } },
		{ id = "matriarch", name = "Head of the Family", desc = "Raised a table full of children.", check = { minChildren = 3 } },
		{ id = "line_keeper", name = "Keeper of the Line", desc = "A third generation or more of the same family.", check = { minGeneration = 3 } },
		{ id = "brawler", name = "The Unbowed", desc = "Won fight after fight after fight.", check = { tally = { clashesWon = 40 } } },
		{ id = "climber", name = "The Climber", desc = "Reached the top of their trade.", check = { minPeakRank = 5 } },
		{ id = "young", name = "Gone Too Soon", desc = "The world didn't give them long.", check = { when = { maxAge = 24 } } },
		{ id = "quiet", name = "A Quiet Life", desc = "Nothing much happened, and that was its own kind of luck." },
	}
end

Systems.EPITAPHS = {
	generic = {
		"{first} kept a lamp lit for somebody.",
		"{first} owed nobody anything, in the end.",
		"Gone home for the last time.",
		"{first} did what they could with what they had.",
		"Somebody still tells {first}'s stories.",
	},
}

Systems.DEATH_CAUSES = {
	wounds = "Their body gave out",
	oldAge = {
		"Died in their sleep, old and tired",
		"Fell asleep by the window, watching the lights come on",
		"Went quietly, with the kettle still warm",
		"Died in their chair, halfway through a story",
		"Went to sleep and didn't wake, the kindest way there is",
		"Died old, in their own bed, with the rent paid",
	},
}

Systems.NAMES = {
	first = {
		"Ada", "Bram", "Cleo", "Dario", "Elin", "Felix", "Greta", "Hugo", "Ines", "Jonas",
		"Kira", "Leo", "Mira", "Nico", "Odette", "Pavel", "Quinn", "Rosa", "Silas", "Tess",
		"Uma", "Viktor", "Wren", "Xavi", "Yara", "Zane", "Alma", "Basil", "Cora", "Dmitri",
	},
	last = {
		"Ashford", "Brook", "Caldwell", "Dunmore", "Ellery", "Fairfax", "Garner", "Holloway", "Irving", "Jansen",
		"Kessler", "Lindqvist", "Marlow", "Norland", "Oakes", "Pryor", "Quill", "Ravel", "Stroud", "Thorne",
	},
}

-- the two tutorial lessons about the pack's own stats (client/App.luau)
function Systems.tutorial(roles: any, names: any): any
	return {
		stats = {
			title = "Your stats",
			text = string.format("%s is your body. The rest are what you do things with. Every 20 points is a tier with a perk, and your highest stat is your nature. Hover any of them to see what it's doing for you.", roles.health.name),
		},
		fights = {
			title = "Fights and checks",
			text = string.format("A check tests one stat: the card shows the odds. In a fight you pick how to fight (%s, %s, %s or %s). Every foe has a temper, and one way of fighting beats it.", names.fight, names.speed, names.work, names.charm),
		},
	}
end

return Systems
