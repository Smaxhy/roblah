--[[
	GATE INCIDENT CARDS (ORIGINAL GAME CONTENT, built on canon rules).

	These cards are never drawn at random (weight 0). Engine/HunterWorld.luau queues one when
	the world's own simulation puts this life somewhere a Gate is: a Gate opening in its
	street, a raid it's called to, a Dungeon Break around it, a Gate that turns red behind
	the raid, a dungeon with a second dungeon inside. Its words come from the incident
	({gRank}, {gPlace}, {gMonster}, {gScene}... see pack.hunterWorld.lines in Spec.luau), so
	the same card reads differently every time.

	One card per situation per Gate rank (E to S): the fight on it is as strong as the rank,
	whoever you are. An E-rank Hunter can be standing in front of an A-rank break; the odds
	preview will say so, and so will the card. Choices that need a Hunter licence say so.
	`hw` on a choice tells the incident what the player did (Engine/HunterWorld.afterChoice).
]]

local HW = require(script.Parent.Parent.Parent.Parent:WaitForChild("Engine"):WaitForChild("HunterWorld"))

local RANKS = HW.RANKS
local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }

-- what a Gate of each rank pays (million won) and what it does to a body that loses to it
local PAY = { { 1, 3 }, { 3, 9 }, { 10, 30 }, { 40, 120 }, { 200, 600 }, { 2000, 8000 } }
local HURT = { { -14, -6 }, { -26, -11 }, { -44, -20 }, { -75, -34 }, { -130, -60 }, { -240, -110 } }
local FAME = { 1, 2, 4, 7, 12, 25 }
-- the boss rooms (Bosses.luau): a raid's boss by the Gate's rank, a Red Gate's by its real rank
local RAID_BOSS = { "goblin_chief", "brood_mother", "orc_warlord", "frost_bear", "golem_lord", "dragonkin_tyrant" }
local RED_BOSS = { "bat_matriarch", "hob_captain", "naga_matriarch", "wraith_lord", "wyvern_queen", "hollow_king" }

local function share(range, f: number)
	return { math.max(1, math.floor(range[1] * f)), math.max(1, math.floor(range[2] * f)) }
end
local function hurt(r: number, f: number)
	local h = HURT[r]
	return { math.floor(h[1] * f), math.floor(h[2] * f) }
end
-- a monster of the Gate's rank (fixed: the card doesn't grow with your age, the rank does)
local function monster(r: number, f: number?, extra: any?)
	local foe = HW.foe(r)
	local c = {
		stat = "strength",
		foe = "{gMonster}",
		enemy = "gate_" .. string.lower(RANKS[r]),
		coins = foe.coins,
		base = math.max(1, math.floor(foe.base * (f or 1) + 0.5)),
		coinPower = foe.coinPower,
		fight = true,
		fixed = true,
	}
	for k, v in extra or {} do
		c[k] = v
	end
	return c
end
-- a check against the situation (running, hiding, keeping a crowd moving)
local function check(stat: string, r: number, base: number, foe: string)
	return { stat = stat, foe = foe, coins = 1 + math.floor(r / 3), base = base, coinPower = 2 + math.floor(r / 2), fixed = true }
end

local cards = {}
local function add(e)
	e.weight = 0
	e.when = { flags = { "hw_on_" .. e.id } }
	table.insert(cards, e)
end

for r = 1, 6 do
	local L = RANKS[r]
	local lower = string.lower(L)
	local pay = PAY[r]

	-- ── a Gate opens where you are ───────────────────────────────────────
	local cityGetClear = {
		label = "Get clear of the cordon",
		hint = "Do what the officers say. Nobody's a hero for walking.",
		hw = "evacuated",
		result = { sanity = -1 - math.floor(r / 2), log = "You walked out past the tape with everyone else and didn't look back until you were three streets away." },
	}
	local cityCrowd = {
		label = "Keep the crowd moving",
		hint = "Somebody has to stop the crush at the crossing.",
		hw = "helped",
		clash = check("charisma", r, 2 + r, "A panicking crowd"),
		win = { charisma = 2, sanity = 2, log = "You got an old man, two kids and a stroller through the crush. A patrol officer nodded at you on the way past." },
		lose = { vitality = { -12, -4 }, sanity = -3, log = "The crowd surged. You went down on the curb and someone stepped on your hand.", cause = "Crushed in a crowd fleeing a Gate" },
	}
	local cityCards = {
		{ suffix = "", choices = {
			cityGetClear,
			cityCrowd,
			{
				label = "Film it",
				hint = if r >= 4 then "This close to a Gate this strong, the mana itself is a weight on your chest." else "Everyone else is.",
				hw = "filmed",
				clash = check("willpower", r, r * 2, "The pressure off the Gate"),
				win = { charisma = 1, money = { 0, 1 }, log = "The clip got passed around for a week. You can see your own hand shaking in it." },
				lose = { vitality = hurt(r, 0.18), sanity = -4, log = "The air went heavy. You woke up on the pavement with a paramedic shining a light in your eyes.", cause = "Collapsed beside a Gate" },
			},
			{
				label = "Call it in to the Association hotline",
				hint = "Location, size, colour. They'll want a reading.",
				hw = "reported",
				result = { intelligence = 1, log = "You gave the operator the street, the size and the colour. A measurement team was there in minutes." },
			},
		} },
		{ suffix = "_h", choices = {
			{
				label = "Show your licence and hold the cordon",
				hint = "Keep people back until {gAssoc} arrives.",
				hw = "held",
				clash = check("willpower", r, 1 + r, "Holding a cordon"),
				win = { charisma = 2, money = share(pay, 0.1), log = "You held the line at the tape until the Association's van pulled up. They thanked you and took your licence number." },
				lose = { sanity = -3, log = "People pushed past you to get a look. The Association team arrived to a mess, and said so." },
			},
			{
				label = "Go in before the Association arrives",
				hint = "Entering a Gate you don't hold the rights to is against the law. Whatever's inside is {gRank}.",
				hw = "entered",
				clash = monster(r, 1.1),
				win = { strength = 2, money = share(pay, 0.6), sanity = -2, loot = { rank = r, chance = 0.4 }, log = "You came out with a pack of mana crystals and an Association officer waiting with a citation. The fine took a third of it." },
				lose = { vitality = hurt(r, 0.8), sanity = -6, log = "You got three rooms in before you knew you'd made a mistake. The measurement team found you at the entrance.", cause = "Killed alone inside an unregistered Gate" },
			},
			cityCrowd,
			cityGetClear,
		} },
	}
	for _, v in cityCards do
		add({
			id = "hw_city_" .. L .. v.suffix,
			title = "{gARank} Gate in {gCity}",
			text = "{gTime} {gScene} {gCrowd} {gWarn}",
			art = "street",
			tags = if r >= 4 then { "danger", "gate" } else { "gate" },
			choices = v.choices,
		})
	end

	-- ── the monsters are out ─────────────────────────────────────────────
	local breakRun = {
		label = "Run",
		hint = "Away from the noise. Don't stop.",
		hw = "fled",
		clash = check("agility", r, 1 + r * 2, "{gMonster} in the street"),
		win = { sanity = -2 - r, log = "You ran until your lungs gave out, and then you walked. You were alive when the all-clear came." },
		lose = { vitality = hurt(r, 0.6), sanity = -6, log = "Something caught up with you at the corner.", cause = "Killed in a Dungeon Break" },
	}
	local breakCards = {
		{ suffix = "", choices = {
			breakRun,
			{
				label = "Get inside and keep quiet",
				hint = "A locked door, a basement, a stairwell. Wait it out.",
				hw = "sheltered",
				clash = check("luck", r, 1 + r, "{gMonster} searching the block"),
				win = { sanity = -3 - r, log = "You sat in the dark with strangers and listened to it go past the door. Twice." },
				lose = { vitality = hurt(r, 0.32), sanity = -8, log = "The door didn't hold. You got out through a back window, hurt.", cause = "Found by monsters in a Dungeon Break" },
			},
			{
				label = "Pull a stranger out with you",
				hint = "A kid has frozen in the middle of the road.",
				hw = "helped",
				clash = check("agility", r, 1 + r * 2, "{gMonster} closing in"),
				win = { charisma = 3, willpower = 2, sanity = 1, log = "You grabbed the kid and didn't let go until you found their mother at the evacuation point." },
				lose = { vitality = hurt(r, 0.7), sanity = -6, log = "You got the kid clear. You didn't get yourself clear.", cause = "Killed saving a child in a Dungeon Break" },
			},
		} },
		{ suffix = "_h", choices = {
			{
				label = "Fight them",
				hint = "These are {gTrueRank} monsters, and they're already out.",
				hw = "fought",
				clash = monster(r, 1),
				win = { strength = 2 + math.floor(r / 2), money = share(pay, 0.5), sanity = -2, loot = { rank = r, chance = 0.3 }, log = "You put down what was in your street. The Association's response team arrived to find you sitting on a bus bench, shaking." },
				lose = { vitality = hurt(r, 1), sanity = -8, log = "There were more of them than you.", cause = "Killed fighting a Dungeon Break" },
			},
			{
				label = "Hold the line while people get out",
				hint = "Don't win. Just don't move.",
				hw = "held",
				clash = monster(r, 0.85, { stat = "vitality" }),
				win = { vitality = { 1, 3 }, willpower = 3, charisma = 2, money = share(pay, 0.3), log = "You held a street corner for eleven minutes. Every one of the people behind you got out." },
				lose = { vitality = hurt(r, 1.05), sanity = -6, log = "The line broke. You were where it broke.", cause = "Killed holding the line in a Dungeon Break" },
			},
			{
				label = "Guide the evacuation",
				hint = "You know how monsters move; the officers don't.",
				hw = "helped",
				clash = check("intelligence", r, 1 + r * 2, "A street in panic"),
				win = { intelligence = 2, charisma = 2, money = share(pay, 0.15), log = "You read where they were going and sent the crowd the other way. The police captain asked your name." },
				lose = { vitality = hurt(r, 0.5), sanity = -4, log = "You sent them the wrong way. You'll think about it for a long time.", cause = "Killed guiding an evacuation" },
			},
			breakRun,
		} },
	}
	for _, v in breakCards do
		add({
			id = "hw_break_" .. L .. v.suffix,
			title = "Dungeon Break: {gPlace}",
			text = "{gTime} {gScene} {gCrowd} {gWarn}",
			art = "street",
			tags = { "danger", "gate" },
			choices = v.choices,
		})
	end

	-- ── a raid you're called to ──────────────────────────────────────────
	add({
		id = "hw_raid_" .. L,
		title = "Raid: {gRank} Gate at {gPlace}",
		text = "{gTime} {gScene} {gCrowd} {gWarn}",
		art = "underpass",
		tags = if r >= 3 then { "danger", "gate" } else { "gate" },
		choices = {
			{
				label = "Take the boss room",
				hint = "A boss, fought in turns. Friends on the server can join you. The kill is yours, and so is the best of the drop.",
				hw = "raided",
				battle = RAID_BOSS[r],
				clash = monster(r, 0.95, { boss = true }),
				win = { strength = 2 + math.floor(r / 2), willpower = 1 + math.floor(r / 3), money = share(pay, 1.5), sanity = 1, charisma = 1 + math.floor(FAME[r] / 6), loot = { rank = r, chance = 0.85, shinyBoost = 1.5 }, log = "You took the boss. The Gate shivered when it died, and an hour later it folded shut behind the collection team. Your name went on the report first." },
				lose = { vitality = hurt(r, 1), sanity = -7, log = "The boss put you through a wall. The rest of the team finished it while a healer kept you breathing.", cause = "Killed by a Gate's boss" },
				fled = { sanity = -4, log = "You backed out of the boss room. The team finished it without you, and the share reflected it." },
			},
			{
				label = "Join the raid",
				hint = "Front line with the team. The share is by contribution.",
				hw = "raided",
				clash = monster(r, 0.72),
				win = { strength = 1 + math.floor(r / 2), agility = 1, money = pay, sanity = 1, loot = { rank = r, chance = 0.45 }, log = "The boss went down in the last chamber. The Gate started to close an hour after, with the collection team still filling crates." },
				lose = { vitality = hurt(r, 0.7), sanity = -5, log = "You were carried out by the healer before the boss room.", cause = "Killed on a Gate raid" },
			},
			{
				label = "Take the rear: collection and support",
				hint = "Carry, mine crystals, watch the flanks. Safer, and it pays less.",
				hw = "raided",
				clash = check("intelligence", r, r * 2, "The dungeon's stragglers"),
				win = { intelligence = 1, money = share(pay, 0.35), loot = { rank = r, chance = 0.15 }, log = "You mined the boss room's crystals while the strikers rested. Honest work, and nobody bled for it." },
				lose = { vitality = hurt(r, 0.35), sanity = -3, log = "A straggler came out of a side tunnel at the collection team. You took the worst of it.", cause = "Killed on a collection team" },
			},
			{
				label = "Turn it down",
				hint = "There'll be other Gates.",
				hw = "declined",
				result = { sanity = 1, log = "You said no. The raid went on without you." },
			},
		},
	})

	-- ── the Gate turned red ──────────────────────────────────────────────
	add({
		id = "hw_red_" .. L,
		title = "Red Gate",
		text = "{gScene} {gCrowd} Nobody outside can come in. The way out won't open until the boss is dead. The reading said {gRank}. It was wrong.",
		art = "hall",
		tags = { "danger", "gate", "strange" },
		choices = {
			{
				label = "Push for the boss",
				hint = "The only way out is through it, in turns, with whoever's left. This is {gTrueRank} now.",
				hw = "fought",
				battle = RED_BOSS[math.min(6, r + 1)],
				clash = monster(math.min(6, r + 1), 0.8, { boss = true }),
				fled = { sanity = -10, log = "You fell back from the throne room. Someone else ended it, days later by the Gate's clock. You were alive to see the sky go blue." },
				win = { strength = 3, willpower = 3, money = share(PAY[math.min(6, r + 1)], 1.2), sanity = -6, loot = { rank = math.min(6, r + 1), chance = 1, minStars = 2, shinyBoost = 2 }, log = "You were there when the boss fell. The red went out of the sky, the Gate opened, and you walked out into an afternoon that hadn't noticed you were gone." },
				lose = { vitality = hurt(math.min(6, r + 1), 1), sanity = -10, log = "You didn't reach the boss.", cause = "Lost inside a Red Gate" },
			},
			{
				label = "Hold a shelter and keep the group alive",
				hint = "Ration, keep watch, keep people sane. Wait for the strikers.",
				hw = "held",
				clash = check("willpower", math.min(6, r + 1), 3 + r * 3, "The cold and the dark"),
				win = { willpower = 4, charisma = 2, sanity = -4, money = share(pay, 0.5), log = "You kept a fire going and nine people talking. When the Gate opened, all nine walked out." },
				lose = { vitality = hurt(r, 0.8), sanity = -12, log = "The things outside the shelter found a way in.", cause = "Lost inside a Red Gate" },
			},
			{
				label = "Search for another way out",
				hint = "There isn't one. Everyone knows there isn't one.",
				hw = "fled",
				clash = check("luck", math.min(6, r + 1), 6 + r * 4, "A Red Gate's walls"),
				win = { luck = 2, sanity = -6, log = "There was no other way out. But the search kept you away from where the worst of it happened." },
				lose = { vitality = hurt(r, 0.9), sanity = -10, log = "You wandered too far from the others.", cause = "Lost inside a Red Gate" },
			},
		},
	})

	-- ── a dungeon inside the dungeon ─────────────────────────────────────
	add({
		id = "hw_double_" .. L,
		title = "Double Dungeon",
		text = "{gScene} {gCrowd} The reading was {gRank}. Whatever is through that second entrance is not.",
		art = "hall",
		tags = { "danger", "gate", "strange" },
		choices = {
			{
				label = "Go through",
				hint = "The others are going. What's inside reads like {gTrueRank}.",
				hw = "entered",
				clash = monster(math.min(6, r + 3), 0.7),
				win = { strength = 3, willpower = 4, intelligence = 2, luck = 2, money = share(PAY[math.min(6, r + 2)], 1), sanity = -12, loot = { rank = math.min(6, r + 2), chance = 1, minStars = 2, shinyBoost = 6 }, log = "You came out. Most of them didn't. You don't talk about the room at the end, even to the Association's investigators." },
				lose = { vitality = hurt(math.min(6, r + 3), 1), sanity = -14, log = "Nobody who went through that door with you came back to say what happened.", cause = "Killed in a Double Dungeon" },
			},
			{
				label = "Study it before anyone moves",
				hint = "There's a pattern to the room. If you can find it before someone triggers it...",
				hw = "helped",
				clash = check("intelligence", math.min(6, r + 2), 4 + r * 3, "A room built to kill"),
				win = { intelligence = 4, willpower = 2, sanity = -6, log = "You saw it a second before anyone else did and shouted. Half the party made it back to the first dungeon because of you." },
				lose = { vitality = hurt(math.min(6, r + 2), 0.8), sanity = -12, log = "You were still working it out when it started.", cause = "Killed in a Double Dungeon" },
			},
			{
				label = "Turn back the way you came",
				hint = "Leave now, while the way back is still open.",
				hw = "declined",
				result = { sanity = -8, willpower = 1, log = "You turned around. Behind you, the door closed on everyone who'd gone in. You were questioned for three days." },
			},
		},
	})
end

return cards
