--[[
	THE PARTY AND BONDS (Engine/Party.luau, Games/BitLeveling/Interactions.luau,
	server/HunterParty.luau, client/UI/PartySheet.luau and NpcProfile.luau).
		lune run tests/party_check [lives]          (add `shot` to write the screens' dumps to
		                                              tools/ui/shots/party*.json for shoot.js)
	  1. the odds of a yes rise with the bond and Charisma, and fall with the rank gap, a
	     dangerous life, a proud or greedy person's terms, a fuller party, being unawakened
	  2. asking: people accept and refuse (both happen), in their own words, about as often as
	     the odds said
	  3. a party helps in a Gate's clash (the odds before you choose are better with them, a
	     Tanker and a Healer take some of a loss, they take their shares) and acts every turn of
	     a boss battle (strike, guard, heal: in the battle log)
	  4. over many simulated years: members get hurt, die (rarely in a Gate at their rank, more
	     in a Red Gate), leave (with a card), retire, and a scheming one betrays the party, at
	     sensible rates
	  5. lives with a party save and load (plain tables, JSON round trip) and carry on
	  6. the roster contract: Roster.luau NPCs (a stand-in roster here) are met once, bring
	     their rank, class, personality, likes, lines and story; Validate accepts the fields and
	     catches bad ones; people without a roster entry get a profile of their own
	  7. the saga's own people come through their cards (pack.party.cast, castMeet, adopt)
	  8. the server's handlers check every request (bad payloads, linked players, unknown
	     gifts, interactions that aren't the party's) and run the good ones
	  9. the PARTY screen and an NPC profile build on Roblox instance types, with an R6
	     portrait for everyone, and their buttons call the server
	 10. the pack still validates clean
	Exit code 1 on any failure.
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local Loader = require("./loader")
local I = roblox.Instance

local failures = 0
local function check(ok: any, msg: string)
	if ok then
		print("  ok    " .. msg)
	else
		failures += 1
		print("  FAIL  " .. msg)
	end
end
local N = tonumber(process.args[1]) or 60
local SHOTS = table.find(process.args, "shot") ~= nil
-- (a screen size for the shots: 1600x900 unless an argument says WxH)
local SHOT_W, SHOT_H = 1600, 900
for _, a in process.args do
	local w, h = string.match(a, "^(%d+)x(%d+)$")
	if w then
		SHOT_W, SHOT_H = tonumber(w) :: number, tonumber(h) :: number
	end
end

-- ── a Roblox-ish world for the client screens (as tests/title_check.luau) ──
roblox.implementMethod("Model", "GetPivot", function(self)
	local pp = self.PrimaryPart
	return if pp then pp.CFrame else roblox.CFrame.new()
end)
roblox.implementMethod("Model", "PivotTo", function(self, cf)
	local delta = cf * self:GetPivot():Inverse()
	for _, d in self:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = delta * d.CFrame
		end
	end
end)
roblox.implementMethod("ParticleEmitter", "Emit", function() end)
local buttonHandlers = {}
for _, cls in { "TextButton", "ImageButton" } do
	for _, ev in { "Activated", "MouseEnter", "MouseLeave", "MouseButton1Click" } do
		roblox.implementProperty(cls, ev, function(self)
			return { Connect = function(_, fn)
				local tag = self:GetAttribute("_h")
				if not tag then
					tag = tostring(math.random(1, 1e9))
					self:SetAttribute("_h", tag)
				end
				buttonHandlers[tag] = buttonHandlers[tag] or {}
				table.insert(buttonHandlers[tag], { event = ev, fn = fn })
				return { Disconnect = function() end }
			end }
		end)
	end
end
local function press(btn: any): number
	local n = 0
	for _, h in buttonHandlers[btn:GetAttribute("_h") or ""] or {} do
		if h.event == "Activated" then
			h.fn()
			n += 1
		end
	end
	return n
end
local function find(root: any, name: string): any
	for _, d in root:GetDescendants() do
		if d.Name == name then
			return d
		end
	end
	return nil
end
local function signal()
	return { Connect = function()
		return { Disconnect = function() end }
	end }
end
local services = {
	RunService = { RenderStepped = signal(), Heartbeat = signal() },
	TweenService = { Create = function(_, obj, _info, goal)
		return { Play = function()
			for k, v in goal do
				pcall(function()
					obj[k] = v
				end)
			end
		end, Cancel = function() end, Completed = signal() }
	end },
	UserInputService = { InputBegan = signal() },
}
process.env.LIFESIM_PACK = "BitLeveling"
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3, CFrame = roblox.CFrame,
	Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font, NumberRange = roblox.NumberRange, NumberSequence = roblox.NumberSequence,
	NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	TweenInfo = { new = function(t)
		return { Time = t }
	end },
	task = { spawn = function(f, ...)
		f(...)
	end, defer = function(f, ...)
		f(...)
	end, delay = function(_, f, ...)
		f(...)
	end, wait = function() end },
	game = { GetService = function(_, name)
		return services[name] or { WaitForChild = function()
			return shared
		end }
	end },
}

local Engine = Loader.require(shared.Engine)
local pack = Loader.pack(shared)
local Party = Loader.require(shared.Engine.Party)
local Battle = Engine.Battle
local Rng = Engine.Rng
local HW = Engine.HunterWorld
assert(pack.id == "BitLeveling" and pack.party, "the BitLeveling pack with its party didn't load")
local sim = Engine.new(pack)

-- ── helpers ──
-- one life grown to 24 (the slow part), copied for every test with its own id and dice
local grown: string? = nil
local function adultLife(seed: number, rank: number?): any
	if not grown then
		local base = sim:newLife({ seed = 4242, birthEra = "under" })
		local g = 0
		while base.age < 24 and base.alive and g < 60 do
			g += 1
			base.pending = nil
			base.queue = {}
			Loader.ageUp(sim, base)
		end
		grown = serde.encode("json", base)
	end
	local life = serde.decode("json", grown :: string)
	life.id = if type(life.id) == "number" then 100000 + seed else ("t" .. tostring(seed))
	life.rng = Rng.seed(seed)
	life.alive = true
	life.cause = nil
	life.pending = nil
	life.queue = {}
	life.form = if (rank or 3) > 0 then "hunter_" .. string.lower(HW.RANKS[rank or 3]) else "human"
	life.gw = life.gw or HW.state(life)
	life.gw.mode = "normal"
	life.gw.class = "fighter"
	life.stats.vitality = 400
	life.stats.charisma = 30
	life.stats.strength = 60
	life.money = 60
	life.socialLeft = 3
	-- (nobody left over from growing up gets in the way of what's being measured)
	for i = #life.relations, 1, -1 do
		if life.relations[i].kind == "acquaintance" then
			table.remove(life.relations, i)
		end
	end
	return life
end
-- someone with a profile we choose (rank 0..6, class, traits)
local function person(life: any, rank: number, class: string?, traits: { string }?, bond: number?, age: number?): any
	local rel = sim:addRelation(life, { kind = "friend", bond = bond or 50, age = age or 28 })
	rel.rank = rank
	rel.class = if rank > 0 then (class or "fighter") else nil
	rel.traits = traits or { "honest" }
	rel.bond = bond or 50
	return rel
end
local function oddsOf(life: any, rel: any): number
	local p = Party.odds(sim, life, rel)
	return p
end
-- the best way the life has of fighting (for boss turns)
local function bestApproach(life: any): string?
	local best, bestV = nil, -1
	for _, id in pack.approaches.order do
		local a = pack.approaches[id]
		if a.stat and not a.bloodless and (life.stats[a.stat] or 0) > bestV and sim:approachOpen(life, a, { fight = true, stat = a.stat }) then
			best, bestV = id, life.stats[a.stat] or 0
		end
	end
	return best
end
local function fightOut(life: any)
	local turns = 0
	while life.battle and turns < 80 do
		turns += 1
		local key = tostring(life.id)
		local _, err = Battle.act(sim, life, { [key] = life }, key, "strike", bestApproach(life))
		if err then
			Battle.act(sim, life, { [key] = life }, key, "flee")
		end
	end
end
local function answer(life: any)
	local g = 0
	while life.alive and life.pending and g < 30 do
		g += 1
		local ev = sim.eventsById[life.pending]
		local open = {}
		for i, c in (ev and ev.choices) or {} do
			if Engine.Conditions.check(c.requires, life, pack, { noChance = true }) then
				table.insert(open, i)
			end
		end
		if #open == 0 then
			life.pending = nil
			break
		end
		sim:choose(life, open[Rng.int(life, 1, #open)], nil)
		fightOut(life)
	end
end

-- ══ 1. the odds ══════════════════════════════════════════════════════════════
print("== 1. the odds of a yes")
do
	local life = adultLife(11, 3)
	local rel = person(life, 3, "tanker", { "honest" }, 50)
	rel.bond = 30
	local pLo = oddsOf(life, rel)
	rel.bond = 50
	local pMid = oddsOf(life, rel)
	rel.bond = 85
	local pHi = oddsOf(life, rel)
	check(pLo < pMid and pMid < pHi, string.format("a closer bond, better odds (bond 30: %d%%, 50: %d%%, 85: %d%%)", pLo * 100, pMid * 100, pHi * 100))
	rel.bond = 50
	life.stats.charisma = 10
	local cLo = oddsOf(life, rel)
	life.stats.charisma = 70
	local cHi = oddsOf(life, rel)
	life.stats.charisma = 30
	check(cLo < cHi, string.format("more Charisma, better odds (10: %d%%, 70: %d%%)", cLo * 100, cHi * 100))
	-- the rank gap: they outrank you by 0, 1, 2; you outrank them
	local r = {}
	for i, rk in { 3, 4, 5, 2 } do
		rel.rank = rk
		r[i] = oddsOf(life, rel)
	end
	check(r[1] > r[2] and r[2] > r[3], string.format("a stronger Hunter won't follow a weaker one (C: %d%%, B: %d%%, A: %d%%)", r[1] * 100, r[2] * 100, r[3] * 100))
	check(r[4] > r[1], string.format("a weaker one may jump at it (D under your C: %d%%)", r[4] * 100))
	rel.rank = 4
	rel.traits = { "proud" }
	local proud = oddsOf(life, rel)
	rel.traits = { "honest" }
	check(proud < r[2], string.format("a proud one refuses the weaker more (%d%% vs %d%%)", proud * 100, r[2] * 100))
	rel.rank = 3
	-- a dangerous life, to a cautious person
	rel.traits = { "cautious" }
	local calm = oddsOf(life, rel)
	life.gw.mode = "crisis"
	life.party = Party.state(life)
	life.party.fallen, life.party.lastFall = 2, life.age
	local scared = oddsOf(life, rel)
	life.gw.mode = "normal"
	life.party.fallen, life.party.lastFall = 0, nil
	check(scared < calm, string.format("a cautious person won't follow a dangerous life (%d%% vs %d%%)", scared * 100, calm * 100))
	-- greedy: a fee you can't pay
	rel.traits = { "greedy" }
	life.money = 1000
	local rich = oddsOf(life, rel)
	life.money = 0
	local broke = oddsOf(life, rel)
	life.money = 60
	check(broke < rich, string.format("a greedy one wants paying (can pay: %d%%, can't: %d%%)", rich * 100, broke * 100))
	-- loyal people count the bond more
	rel.traits = { "loyal" }
	rel.bond = 85
	local loyalHi = oddsOf(life, rel)
	rel.traits = { "honest" }
	check(loyalHi >= pHi, string.format("the loyal value the bond (loyal at bond 85: %d%%, others: %d%%)", loyalHi * 100, pHi * 100))
	rel.bond = 50
	-- a fuller party
	local empty = oddsOf(life, rel)
	for k = 1, 3 do
		Party.addMember(sim, life, person(life, 3, "fighter", { "honest" }, 60), nil)
	end
	local fuller = oddsOf(life, rel)
	check(fuller < empty, string.format("a fuller party, worse odds (empty: %d%%, three in it: %d%%)", empty * 100, fuller * 100))
	-- unawakened
	life.party.members = {}
	life.form = "human"
	local civ = oddsOf(life, rel)
	life.form = "hunter_c"
	check(civ < empty, string.format("Hunters don't follow the unawakened into Gates (%d%% vs %d%%)", civ * 100, empty * 100))
	-- the odds come with their reasons
	rel.bond, life.stats.charisma = 72, 44
	local _p, factors = Party.odds(sim, life, rel)
	rel.bond, life.stats.charisma = 50, 30
	check(#factors >= 2, "the odds are explained factor by factor (" .. #factors .. ")")
	-- nobody too young, nobody about to retire
	local kid = person(life, 0, nil, nil, 70, 12)
	local _a, _b, why = Party.odds(sim, life, kid)
	check(why ~= nil, "a child can't be asked (" .. tostring(why) .. ")")
	local old = person(life, 3, "fighter", nil, 70, 61)
	local _c, _d, why2 = Party.odds(sim, life, old)
	check(why2 ~= nil, "nor someone about to retire (" .. tostring(why2) .. ")")
end

-- ══ 2. asking ═══════════════════════════════════════════════════════════════
print("== 2. asking: yes and no")
do
	local yes, no, lines, buckets = 0, 0, 0, { lo = { 0, 0 }, hi = { 0, 0 } }
	local spoken = {}
	for i = 1, 240 do
		local life = adultLife(300 + i, (i % 3) + 2)
		life.socialLeft = 3
		local traits = { Party.TRAITS.order[(i % 12) + 1] }
		local rel = person(life, ((i * 7) % 6) + 1, ({ "fighter", "mage", "assassin", "tanker", "ranger", "healer" })[(i % 6) + 1], traits, 20 + (i * 13) % 75)
		local p = oddsOf(life, rel)
		local rep = sim:interact(life, rel.id, "bl_ask")
		if rep and rep.party then
			local r = rep.party
			if r.accepted then
				yes += 1
			else
				no += 1
			end
			if type(r.line) == "string" and #r.line > 0 then
				lines += 1
				spoken[r.line] = true
			end
			local b = if p < 0.3 then buckets.lo elseif p > 0.6 then buckets.hi else nil
			if b then
				b[1] += 1
				b[2] += if r.accepted then 1 else 0
			end
		end
	end
	local distinct = 0
	for _ in spoken do
		distinct += 1
	end
	check(yes > 20 and no > 20, string.format("people accept and refuse (%d yes, %d no)", yes, no))
	check(lines >= (yes + no) * 0.95, string.format("every answer comes in their own words (%d of %d, %d different lines)", lines, yes + no, distinct))
	local loRate = buckets.lo[2] / math.max(1, buckets.lo[1])
	local hiRate = buckets.hi[2] / math.max(1, buckets.hi[1])
	check(hiRate > loRate + 0.25, string.format("they say yes about as often as the odds said (odds < 30%%: %d%% said yes; > 60%%: %d%%)", loRate * 100, hiRate * 100))
	-- asking takes the year's time for people, and once a year a person
	local life = adultLife(777, 3)
	local rel = person(life, 3, "fighter", { "honest" }, 40)
	local before = life.socialLeft
	sim:interact(life, rel.id, "bl_ask")
	check(life.socialLeft == before - 1, "asking uses time for people")
	local again, why = sim:interact(life, rel.id, "bl_ask")
	check(again == nil and why ~= nil, "and can't be asked again this year (" .. tostring(why) .. ")")
end

-- a life with a party of three (C Tanker, C Mage, C Healer), for the rest
local function partyLife(seed: number, rank: number?, memberRank: number?): any
	local life = adultLife(seed, rank or 3)
	local mr = memberRank or rank or 3
	for _, c in { "tanker", "mage", "healer" } do
		local rel = person(life, mr, c, { "honest" }, 70)
		Party.addMember(sim, life, rel, nil)
	end
	return life
end

-- ══ 3. help ═════════════════════════════════════════════════════════════════
print("== 3. they help: clashes and boss battles")
do
	local life = partyLife(4040, 3)
	local raid = sim.eventsById.hw_raid_C
	local join = raid.choices[2]
	check(join.clash.party ~= nil and join.clash.party.kind == "raid", "a raid's fight is fought with the party (clash.party)")
	local withP = sim:clashPreview(life, join.clash)
	local saved = life.party.members
	life.party.members = {}
	local alone = sim:clashPreview(life, join.clash)
	life.party.members = saved
	check(withP.party ~= nil and #withP.party.who == 3, "the odds preview names who's with you (" .. tostring(withP.party and #withP.party.who) .. ")")
	check((withP.bestOdds or withP.odds) > (alone.bestOdds or alone.odds) + 0.05, string.format("and the odds are better with them (%d%% vs %d%% alone)", (withP.bestOdds or withP.odds) * 100, (alone.bestOdds or alone.odds) * 100))
	check((withP.party.absorb or 0) > 0, string.format("a Tanker and a Healer take %d%% off a loss", (withP.party.absorb or 0) * 100))
	check((withP.party.share or 0) > 0, string.format("and they take %d%% of the pay", (withP.party.share or 0) * 100))
	-- the card says so
	sim:forceEvent(life, "hw_raid_C")
	local v = sim:view(life)
	local hint = ""
	for _, c in (v.pending and v.pending.choices) or (v.event and v.event.choices) or {} do
		if c.index == 2 then
			hint = c.hint or ""
		end
	end
	check(string.find(hint, "With you:", 1, true) ~= nil, "the card's choice says who's with you and what they add")
	life.pending = nil
	life.queue = {}
	-- shares come out of a win, a loss is softened
	local wins, shares, softened = 0, 0, 0
	for i = 1, 40 do
		local l = partyLife(5000 + i, 3)
		local rep = sim.newReport()
		local money = l.money
		sim:resolveOption(l, join, rep, bestApproach(l), nil)
		for _, e in rep.entries do
			if e.text and string.find(e.text, "Their shares of the take", 1, true) then
				shares += 1
			end
			if e.text and string.find(e.text, "took some of it for you", 1, true) then
				softened += 1
			end
		end
		if rep.clash and rep.clash.won then
			wins += 1
		end
		local _ = money
	end
	check(wins > 0 and shares > 0, string.format("a won raid pays their shares (%d of %d wins)", shares, wins))
	-- a fight the party can't win: the Tanker and the Healer take some of the loss
	local hopeless = table.clone(join)
	hopeless.clash = table.clone(join.clash)
	hopeless.clash.base, hopeless.clash.coins, hopeless.clash.coinPower = 400, 6, 40
	local function lossOf(withParty: boolean): number
		local total = 0
		for i = 1, 20 do
			local l = partyLife(5500 + i, 3)
			if not withParty then
				l.party.members = {}
			end
			l.stats.vitality = sim:maxHealthOf(l)
			local before = l.stats.vitality
			local rep = sim.newReport()
			sim:resolveOption(l, hopeless, rep, bestApproach(l), nil)
			total += before - (l.stats.vitality or 0)
			if withParty then
				for _, e in rep.entries do
					if e.text and string.find(e.text, "took some of it for you", 1, true) then
						softened += 1
					end
				end
			end
		end
		return total / 20
	end
	local lostAlone, lostWith = lossOf(false), lossOf(true)
	check(softened > 0 and lostWith < lostAlone * 0.9, string.format("a lost one is softened by the Tanker and the Healer (%.0f Vitality lost with them, %.0f alone)", lostWith, lostAlone))
	-- a non-fight check: they help too
	local crowd = sim.eventsById.hw_city_C.choices[2]
	local s = Party.support(sim, life, crowd.clash)
	check(s ~= nil and s.base > 0, "they help with a crowd too (+" .. tostring(s and s.base) .. ")")
	-- a Red Gate counts at its true rank
	local red = sim.eventsById.hw_red_C.choices[1]
	check(red.clash.party.rank == 4 and red.clash.party.kind == "red", "a Red Gate's fight is at its true rank (B for a C reading)")

	-- boss battles: allies every turn
	local bl = partyLife(6060, 3)
	bl.stats.vitality = 60
	Battle.begin(sim, bl, "orc_warlord", { eventId = "hw_raid_C", choice = 1 })
	local b = bl.battle
	check(b and b.allies and #b.allies == 3, "the party goes into the boss room (" .. tostring(b and b.allies and #b.allies) .. " allies)")
	local bv = Battle.view(sim, bl, { [tostring(bl.id)] = bl }, tostring(bl.id))
	check(bv and bv.allies and #bv.allies == 3, "the battle view shows them")
	local logText = {}
	local turns = 0
	while bl.battle and turns < 60 do
		turns += 1
		local key = tostring(bl.id)
		for _, e in bl.battle.log do
			logText[e.text] = true
		end
		Battle.act(sim, bl, { [key] = bl }, key, "strike", bestApproach(bl))
	end
	local struck, healed, shielded = false, false, false
	for t in logText do
		struck = struck or string.find(t, "damage", 1, true) ~= nil and (string.find(t, "hits it with a spell", 1, true) ~= nil or string.find(t, "shield-bashes", 1, true) ~= nil or string.find(t, "strikes when it turns", 1, true) ~= nil)
		healed = healed or string.find(t, "mends", 1, true) ~= nil
		shielded = shielded or string.find(t, "plants a shield", 1, true) ~= nil or string.find(t, "takes the blow", 1, true) ~= nil
	end
	check(struck, "allies strike in the battle log")
	check(shielded, "the Tanker guards (plants a shield, takes blows)")
	check(healed, "the Healer heals you when you're hurt")
	check(bl.battleDone ~= nil, "the battle ends (" .. tostring(bl.battleDone and bl.battleDone.outcome) .. ")")
	local fought = 0
	for _, m in Party.members(bl) do
		fought += (m.wins or 0) + (m.losses or 0)
	end
	check(fought > 0 or #Party.members(bl) < 3, "and they remember fighting it (wins and losses)")
	-- a battle without a party is unchanged
	local solo = adultLife(6061, 3)
	Battle.begin(sim, solo, "orc_warlord", {})
	check(solo.battle and solo.battle.allies == nil and solo.battle.hp == pack.bosses.orc_warlord.hp, "a fight alone is the same fight it always was")
	solo.battle = nil
end

-- ══ 4. the years ════════════════════════════════════════════════════════════
print(string.format("== 4. %d lives with a party, 25 years each", N))
local function runYears(seedBase: number, gateRankOffset: number, kind: string): any
	local st = { memberFights = 0, hurt = 0, dead = 0, memberYears = 0, left = 0, cards = {}, betrayed = 0, retired = 0, joined = 0, lives = 0, unsaveable = 0 }
	local origRemove = Party.removeMember
	Party.removeMember = function(s, life, relId, reason, extra)
		local r = origRemove(s, life, relId, reason, extra)
		if r then
			if reason and string.find(reason, "retired", 1, true) then
				st.retired += 1
			elseif not (reason and string.find(reason, "is gone", 1, true)) then
				st.left += 1
			end
		end
		return r
	end
	for i = 1, N do
		local life = adultLife(seedBase + i * 17, 3)
		st.lives += 1
		-- four of their own: generated personalities (one in four scheming)
		for k = 1, 4 do
			local traits = Party.TRAITS.order
			local t1 = traits[((i + k * 5) % #traits) + 1]
			local rel = person(life, 3, ({ "fighter", "mage", "tanker", "healer", "ranger", "assassin" })[((i + k) % 6) + 1], { t1 }, 55 + (k * 7) % 25, 24 + k * 3)
			Party.addMember(sim, life, rel, nil)
		end
		st.joined += #Party.members(life)
		local spec = { stat = "strength", foe = "A Gate's monsters", coins = 3, base = 10, coinPower = 5, fight = true, fixed = true, party = { rank = math.clamp(3 + gateRankOffset, 1, 6), kind = kind } }
		local option = { clash = spec, win = { money = { 8, 24 }, log = "Cleared." }, lose = { sanity = -2, log = "It went badly." } }
		for _ = 1, 25 do
			if not life.alive then
				break
			end
			life.stats.vitality = 400
			for _ = 1, 3 do
				st.memberFights += #Party.members(life)
				local before = 0
				for _, m in Party.members(life) do
					if m.condition ~= "fine" then
						before += 1
					end
				end
				sim:resolveOption(life, option, sim.newReport(), bestApproach(life), nil)
				local after = 0
				for _, m in Party.members(life) do
					if m.condition ~= "fine" then
						after += 1
					end
				end
				st.hurt += math.max(0, after - before)
			end
			st.memberYears += #Party.members(life)
			-- a few people to keep it alive: someone might ask to join
			if #Party.members(life) < 2 then
				local rel = person(life, 3, "fighter", { "kind" }, 70, 30)
				Party.addMember(sim, life, rel, nil)
				st.joined += 1
			end
			answer(life)
			life.stats.vitality = 400
			Loader.ageUp(sim, life)
			-- (the year's party cards, before they're answered)
			for id in (life.party and life.party.cards) or {} do
				st.cards[id] = (st.cards[id] or 0) + 1
			end
			answer(life)
		end
		local p = life.party
		if p then
			st.dead += p.fallen or 0
			if p.betrayed then
				st.betrayed += 1
			end
		end
		local ok = pcall(serde.encode, "json", life)
		if not ok then
			st.unsaveable += 1
		end
	end
	Party.removeMember = origRemove
	return st
end
do
	local even = runYears(9000, 0, "raid")
	local red = runYears(9000, 1, "red")
	local deadEven = even.dead / math.max(1, even.memberFights)
	local deadRed = red.dead / math.max(1, red.memberFights)
	local hurtEven = even.hurt / math.max(1, even.memberFights)
	print(string.format("     at their rank: %d member-fights, %d hurt (%.1f%%), %d dead (%.2f%%), %d left, %d retired, %d betrayals",
		even.memberFights, even.hurt, hurtEven * 100, even.dead, deadEven * 100, even.left, even.retired, even.betrayed))
	print(string.format("     Red Gates a rank up: %d member-fights, %d dead (%.2f%%)", red.memberFights, red.dead, deadRed * 100))
	local cardList = {}
	for id, n in even.cards do
		table.insert(cardList, id .. " " .. n)
	end
	table.sort(cardList)
	print("     party cards: " .. table.concat(cardList, ", "))
	check(even.hurt > 0 and hurtEven < 0.25, string.format("members get hurt, not constantly (%.1f%% of fights)", hurtEven * 100))
	check(deadEven < 0.01, string.format("rarely killed in a Gate at their rank (%.2f%% of fights)", deadEven * 100))
	check(deadRed > deadEven * 2 and red.dead > 0, string.format("far more often in a Red Gate a rank up (%.2f%%)", deadRed * 100))
	check(even.left > 0, "people leave the party (" .. even.left .. ")")
	local leaveCards = 0
	for id, n in even.cards do
		if string.find(id, "pt_leave_", 1, true) then
			leaveCards += n
		end
	end
	check(leaveCards > 0, "some leave for their own reasons, with a card (" .. leaveCards .. ")")
	check(even.betrayed > 0 and even.betrayed <= even.lives * 0.5, string.format("a scheming one betrays the party, once, now and then (%d of %d lives)", even.betrayed, even.lives))
	check(even.unsaveable == 0 and red.unsaveable == 0, "every life with a party still saves")
end

-- ══ 5. save and load ════════════════════════════════════════════════════════
print("== 5. save and load")
do
	local life = partyLife(7070, 3)
	local m1 = Party.members(life)[1]
	local rel1 = sim:relationById(life, m1.rel)
	sim:interact(life, rel1.id, "spend_time")
	sim:interact(life, rel1.id, "bl_past")
	local ok, json = pcall(serde.encode, "json", life)
	check(ok, "a life with a party encodes as JSON")
	local back = serde.decode("json", json)
	check(#back.party.members == 3 and back.party.members[1].rel == m1.rel and back.party.members[1].loyalty == m1.loyalty, "and decodes with its party intact")
	local brel = sim:relationById(back, m1.rel)
	check(brel and brel.rank == rel1.rank and brel.class == rel1.class and #brel.traits == #rel1.traits and #brel.history == #rel1.history, "their rank, class, personality and history too")
	back.socialLeft = 3
	local okI = pcall(sim.interact, sim, back, m1.rel, "spend_time")
	local okV = pcall(Party.view, sim, back)
	local okY = pcall(Loader.ageUp, sim, back)
	check(okI and okV and okY, "and the loaded life carries on (interact, the view, a year)")
end

-- ══ 6. the roster contract ═══════════════════════════════════════════════════
print("== 6. Roster.luau NPCs (a stand-in roster)")
do
	local pack2 = table.clone(pack)
	pack2.roster = {
		{
			id = "npc_test_minji", first = "Minji", last = "Seol", born = -6, rank = "B", class = "ranger", guild = "the Ironvale Guild", role = "Strike team archer", home = "seoul_mapo",
			personality = { "brave", "loyal" }, likes = { "spicy tteokbokki", "old jazz records" }, dislikes = { "being lied to" },
			backstory = { "Line one.", "Line two.", "Line three." },
			lines = { greet = { "Hey, {first}." }, accept = { "Roster yes." }, refuse = { "Roster no." }, gift = { "Roster thanks." } },
			look = { preset = "ranger_c" }, recruit = { difficulty = 2, minRank = "D", wantsPay = 5 },
		},
		{ id = "npc_test_civ", first = "Dami", last = "Yoo", born = 2, role = "Bakery owner", personality = { "kind" }, backstory = { "Only line." } },
		-- (a public figure the roster marks canon: seen on the news, never in anyone's party)
		{ id = "npc_test_public", first = "Public", last = "Figure", born = -20, rank = "S", class = "fighter", role = "A famous Hunter", canon = true, personality = { "proud" } },
	}
	pack2.events = table.clone(pack.events)
	table.insert(pack2.events, { id = "test_meet_minji", title = "A test", text = "A test card.", weight = 0, when = { flags = { "never" } }, choices = { { label = "Meet", result = { addRelation = { kind = "friend", name = "Minji Seol", age = 20, bond = 40, roster = "npc_test_minji" }, setFlags = { "met_npc_test_minji" }, log = "You met someone." } } } })
	local v = Engine.Validate.run(pack2)
	check(#v.errors == 0, "Validate accepts the roster's fields (" .. #v.errors .. " errors" .. (if #v.errors > 0 then ": " .. v.errors[1] else "") .. ")")
	local bad = table.clone(pack2)
	bad.roster = { { id = "npc_bad", first = "X", rank = "Z", personality = { "sneaky" } } }
	local vb = Engine.Validate.run(bad)
	check(#vb.errors >= 2, "and catches bad ones (" .. #vb.errors .. " errors)")
	local s2 = Engine.new(pack2)
	local life = s2:newLife({ seed = 31, birthEra = "under" })
	life.form = "hunter_c"
	life.pending = nil
	life.queue = {}
	s2:forceEvent(life, "test_meet_minji")
	if life.pending == "test_meet_minji" then
		s2:choose(life, 1, nil)
	end
	local found = nil
	for _, r in life.relations do
		if r.roster == "npc_test_minji" then
			found = r
		end
	end
	check(found ~= nil, "a card's addRelation with a roster id introduces them")
	if found then
		check(found.rank == 4 and found.class == "ranger", "with the roster's rank and class (B Ranger)")
		check(table.find(found.traits, "brave") ~= nil and table.find(found.traits, "loyal") ~= nil, "and personality")
		check(found.age == (life.year - -6), "their age from the Gate Year they were born (" .. tostring(found.age) .. ")")
		check(life.flags.met_npc_test_minji == true, "met_<npc id> is set")
		local before = #life.relations
		s2:addRelation(life, { kind = "friend", roster = "npc_test_minji", bond = 60 })
		check(#life.relations == before and found.bond >= 60, "meeting them again is the same person (no double)")
		local likes = Party.likesOf(s2, life, found)
		check(likes[1] == "spicy tteokbokki", "likes come from the roster")
		local g = Party.gift(s2, "g_spicy")
		check(Party.giftMatches(g, likes) ~= nil, "and a gift matches them by word (fire noodles: spicy tteokbokki)")
		local rec = Party.gift(s2, "g_records")
		check(Party.giftMatches(rec, likes) ~= nil, "(records: old jazz records)")
		local tea = Party.gift(s2, "g_tea")
		check(Party.giftMatches(tea, { "steamed buns" }) == nil, "but not inside another word (tea is not in steamed)")
		check(Party.line(s2, life, found, "accept") == "Roster yes.", "their own lines")
		check(#Party.backstory(s2, life, found) == 3, "their own story, three lines")
		local look = Party.lookOf(s2, life, found)
		check(look.preset == "ranger_c", "their own look")
		check(Party.feeOf(s2, found) == 5, "their own price (wantsPay)")
		local _p, factors = Party.odds(s2, life, found)
		local saidHard = false
		for _, f in factors do
			saidHard = saidHard or string.find(f.text, "Hard to win over", 1, true) ~= nil
		end
		check(saidHard, "their recruit difficulty is in the odds")
	end
	-- a canon public figure, even if a card puts them in a life, is never a party member
	local pub = s2:addRelation(life, { kind = "acquaintance", roster = "npc_test_public", bond = 90 })
	local realAge = life.age
	life.age = 30
	local _pp, _pf, pubWhy = Party.odds(s2, life, pub)
	check(pubWhy ~= nil and string.find(pubWhy, "public figure", 1, true) ~= nil and Party.addMember(s2, life, pub, nil) == nil, "a canon public figure can't be asked or added (" .. tostring(pubWhy) .. ")")
	local listed = false
	for _, c in Party.view(s2, life).candidates do
		listed = listed or c.relId == pub.id
	end
	check(not listed, "and isn't among the people you could ask")
	life.age = realAge
	local metPublic = false
	for k = 1, 30 do
		local l = s2:newLife({ seed = 700 + k, birthEra = "first_gen" })
		l.age, l.year = 30, 16
		for _ = 1, 10 do
			Party.rosterMeet(s2, l, s2.newReport())
		end
		metPublic = metPublic or l.flags.met_npc_test_public == true
	end
	check(not metPublic, "nor ever met by chance")
	-- someone with no roster entry: a profile of their own, the same every time
	local plain = s2:addRelation(life, { kind = "acquaintance", bond = 30, age = 30 })
	check(plain.traits and #plain.traits >= 2 and plain.rank ~= nil, "everyone else gets a personality and a rank of their own")
	local again = table.clone(plain)
	again.prof, again.traits, again.rank, again.class = nil, nil, nil, nil
	Party.ensure(s2, life, again)
	check(again.rank == plain.rank and again.traits[1] == plain.traits[1], "the same every time (from their ids, not the life's dice)")
	check(#Party.backstory(s2, life, plain) >= 4, "and a story made of who they are (" .. #Party.backstory(s2, life, plain) .. " lines)")
	-- the yearly meeting
	local met = 0
	for k = 1, 40 do
		local l = s2:newLife({ seed = 600 + k, birthEra = "first_gen" })
		l.age, l.year = 30, 16
		for _ = 1, 10 do
			Party.rosterMeet(s2, l, s2.newReport())
		end
		if l.flags.met_npc_test_minji or l.flags.met_npc_test_civ then
			met += 1
		end
	end
	check(met > 10, "the roster's people turn up in lives on their own (" .. met .. " of 40 lives in ten years)")
end

-- ══ 7. the saga's own people ═════════════════════════════════════════════════
print("== 7. the saga cast")
do
	local life = adultLife(8080, 3)
	sim:forceEvent(life, "sg_guild_01")
	if life.pending == "sg_guild_01" then
		sim:choose(life, 1, nil)
	end
	local founders = {}
	for _, r in life.relations do
		if r.roster == "npc_sg_taeho_yoon" or r.roster == "npc_sg_ara_seo" or r.roster == "npc_sg_junho_bae" then
			founders[r.roster] = r
		end
	end
	check(founders.npc_sg_taeho_yoon and founders.npc_sg_ara_seo and founders.npc_sg_junho_bae, "founding a guild brings its three founding members into your life")
	local t = founders.npc_sg_taeho_yoon
	check(t and t.rank == 2 and t.class == "tanker" and t.kind == "friend", "each the cast's own (Taeho: a D-rank Tanker, a friend)")
	check(t and #Party.backstory(sim, life, t) == 5, "with their own story")
	-- the Wall's rookie: the card adds them, the cast says who they are
	local l2 = adultLife(8081, 3)
	sim:forceEvent(l2, "sg_wall_03")
	if l2.pending == "sg_wall_03" then
		sim:choose(l2, 1, nil)
	end
	local rookie = nil
	local count = 0
	for _, r in l2.relations do
		if r.roster == "npc_sg_hayoung_song" then
			rookie = r
			count += 1
		end
	end
	check(rookie and count == 1 and rookie.rank == 2 and rookie.class == "tanker" and rookie.first == "Hayoung", "the rookie with the shield becomes Hayoung Song, once (adopt)")
	-- incidents introduce the people who were there
	local met, nearRank = 0, 0
	for k = 1, 40 do
		local l = adultLife(8200 + k, 3)
		local n = #l.relations
		local opt = sim.eventsById.hw_raid_C.choices[2]
		local o = table.clone(opt)
		o.win = table.clone(opt.win)
		o.win.meet = table.clone(opt.win.meet)
		o.win.meet.chance = 1
		Engine.Effects.apply(sim, l, o.win, sim.newReport())
		if #l.relations > n then
			met += 1
			local r = l.relations[#l.relations]
			if (r.rank or 0) >= 2 and (r.rank or 0) <= 3 then
				nearRank += 1
			end
		end
	end
	check(met == 40, "the raid team's Hunters become people you've met (" .. met .. ")")
	check(nearRank == met, "each a Hunter near the Gate's rank (" .. nearRank .. " of " .. met .. ")")
end

-- ══ 8. the server ═══════════════════════════════════════════════════════════
print("== 8. server/HunterParty")
local server = Loader.preload(Loader.node("src/server", "Server", nil))
local HunterParty = Loader.require(server.HunterParty)
local uiLife = partyLife(9090, 3)
uiLife.money = 80
pack.acquaintances.cap = 60
for k, spec in {
	{ role = "a rookie who asked you about their first raid", rank = "E", class = "ranger", bond = { 48, 48 }, age = { 19, 19 } },
	{ role = "a raider you keep seeing on the public raid board", rank = "D", class = "assassin", bond = { 40, 40 }, age = { 26, 26 } },
	{ roster = "npc_sg_haneul_ryu", role = "the B-rank rookie who signed with your guild", bond = { 44, 44 }, age = { 21, 21 } },
	{ role = "a guild officer who noticed you at a briefing", rank = "A", class = "fighter", bond = { 30, 30 }, age = { 41, 41 } },
	{ role = "the owner of the convenience store on your corner", rank = 0, bond = { 55, 55 }, age = { 52, 52 } },
} do
	local _ = k
	sim:meetSomeone(uiLife, {}, spec)
end
local linked = sim:linkFriend(uiLife, { userId = 4242, first = "Player", last = "Two", age = 25 })
local S = {
	Content = pack, sim = sim, handlers = {},
	syncLinks = function() end, shareWithFriends = function() end,
	lifeResponse = function(_session, report)
		return { ok = true, life = sim:view(uiLife), entries = report and report.entries }
	end,
}
HunterParty.install(S)
local session = { profile = { Data = { life = uiLife } } }
local calls = {}
local function call(action: string, payload: any?): any
	table.insert(calls, { action = action, payload = payload })
	local h = S.handlers[action]
	if not h then
		return { ok = false, error = "Unknown action." }
	end
	return h(nil, session, payload)
end
do
	local v = call("partyView")
	check(v.ok and v.party and v.party.count == 3 and #v.party.candidates >= 4, "partyView: the members and the people you could ask")
	check(not call("partyAsk", "nope").ok, "a payload that isn't a table is refused")
	check(not call("partyAsk", { relId = "1" }).ok, "a relId that isn't a number is refused")
	check(not call("partyAsk", { relId = 0 / 0 }).ok, "nor NaN")
	check(not call("partyAsk", { relId = 99999 }).ok, "someone not in your life is refused")
	check(not call("partyAsk", { relId = linked.id }).ok, "another player (a linked friend) can't be asked as an NPC")
	local cand = v.party.candidates[1]
	check(not call("partyGift", { relId = cand.relId, gift = "g_nonsense" }).ok, "an unknown gift is refused")
	check(not call("partyDo", { relId = cand.relId, id = "ask_help" }).ok, "an interaction that isn't the party's is refused")
	local before = uiLife.money
	local g = call("partyGift", { relId = cand.relId, gift = "g_cake" })
	check(g.ok and g.result and g.result.gift == "g_cake" and uiLife.money == before - 1, "a good gift goes through, and costs what it costs")
	local p = call("partyProfile", { relId = cand.relId })
	check(p.ok and p.profile and p.profile.name == cand.name and #p.profile.interactions > 3, "partyProfile: who they are and what you can do together")
	uiLife.socialLeft = 3
	local a = call("partyAsk", { relId = cand.relId })
	check(a.ok and a.result and a.result.accepted ~= nil and a.party, "partyAsk: an answer, and the party screen again")
	uiLife.socialLeft = 3
end

-- ══ 9. the screens ══════════════════════════════════════════════════════════
print("== 9. the PARTY screen and an NPC profile")
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local PartySheet = Loader.require(client.UI.PartySheet)
local NpcProfile = Loader.require(client.UI.NpcProfile)
-- the screenshot dump (gui-snapshot/1)
local defaults = {}
local function num(x)
	if x ~= x or x == math.huge or x == -math.huge then
		return 0
	end
	return math.floor(x * 1000 + 0.5) / 1000
end
local function byte(x)
	return math.clamp(math.floor(x * 255 + 0.5), 0, 255)
end
local ENCODE = {
	number = num,
	string = function(v)
		return v
	end,
	boolean = function(v)
		return v
	end,
	UDim2 = function(v)
		return { num(v.X.Scale), num(v.X.Offset), num(v.Y.Scale), num(v.Y.Offset) }
	end,
	UDim = function(v)
		return { num(v.Scale), num(v.Offset) }
	end,
	Vector2 = function(v)
		return { num(v.X), num(v.Y) }
	end,
	Vector3 = function(v)
		return { num(v.X), num(v.Y), num(v.Z) }
	end,
	Color3 = function(c)
		return { byte(c.R), byte(c.G), byte(c.B) }
	end,
	EnumItem = function(e)
		return e.Name
	end,
	Font = function(f)
		return { family = f.Family, weight = f.Weight.Name, style = f.Style.Name }
	end,
	CFrame = function(cf)
		local out = {}
		for _, x in { cf:GetComponents() } do
			table.insert(out, math.floor(x * 100000 + 0.5) / 100000)
		end
		return out
	end,
	ColorSequence = function(cs)
		local out = {}
		for _, k in cs.Keypoints do
			table.insert(out, { num(k.Time), byte(k.Value.R), byte(k.Value.G), byte(k.Value.B) })
		end
		return out
	end,
	NumberSequence = function(ns)
		local out = {}
		for _, k in ns.Keypoints do
			table.insert(out, { num(k.Time), num(k.Value), num(k.Envelope) })
		end
		return out
	end,
}
local GUI = { "Visible", "Size", "Position", "AnchorPoint", "AutomaticSize", "Rotation", "ZIndex", "LayoutOrder", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "ClipsDescendants", "SizeConstraint", "CanvasSize", "CanvasPosition", "AutomaticCanvasSize", "ScrollingDirection", "ScrollBarThickness" }
local TEXT = { "Text", "RichText", "FontFace", "TextSize", "TextScaled", "TextWrapped", "TextColor3", "TextTransparency", "TextXAlignment", "TextYAlignment", "TextTruncate", "TextStrokeColor3", "TextStrokeTransparency" }
local VIEWPORT = { "Ambient", "LightColor", "LightDirection", "ImageColor3", "ImageTransparency" }
local MODS = {
	UICorner = { "CornerRadius" },
	UIStroke = { "Color", "Thickness", "Transparency", "ApplyStrokeMode" },
	UIGradient = { "Color", "Transparency", "Rotation", "Offset", "Enabled" },
	UIPadding = { "PaddingTop", "PaddingRight", "PaddingBottom", "PaddingLeft" },
	UIListLayout = { "Padding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder", "Wraps" },
	UIGridLayout = { "CellSize", "CellPadding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder" },
	UISizeConstraint = { "MinSize", "MaxSize" },
	UIScale = { "Scale" },
}
local SCREEN = { "Enabled", "DisplayOrder", "IgnoreGuiInset", "ZIndexBehavior" }
local function propsFor(real)
	if MODS[real.ClassName] then
		return MODS[real.ClassName]
	elseif real:IsA("LayerCollector") then
		return SCREEN
	end
	local list = table.clone(GUI)
	if real:IsA("TextLabel") or real:IsA("TextButton") or real:IsA("TextBox") then
		for _, k in TEXT do
			table.insert(list, k)
		end
	elseif real:IsA("ViewportFrame") then
		for _, k in VIEWPORT do
			table.insert(list, k)
		end
	end
	return list
end
local function readAll(real)
	local out = {}
	for _, key in propsFor(real) do
		local ok, v = pcall(function()
			return real[key]
		end)
		if ok and v ~= nil then
			local e = ENCODE[typeof(v)]
			if e then
				out[key] = e(v)
			end
		end
	end
	return out
end
local function node(real)
	if defaults[real.ClassName] == nil then
		defaults[real.ClassName] = readAll(I.new(real.ClassName))
	end
	local out: any = { class = real.ClassName, name = real.Name, props = readAll(real) }
	local kids = {}
	if real:IsA("ViewportFrame") then
		local parts = {}
		for _, d in real:GetDescendants() do
			if d:IsA("BasePart") then
				table.insert(parts, { class = d.ClassName, shape = if d:IsA("Part") then d.Shape.Name else "Block", size = ENCODE.Vector3(d.Size), cframe = ENCODE.CFrame(d.CFrame), color = ENCODE.Color3(d.Color), material = d.Material.Name, transparency = num(d.Transparency) })
			end
		end
		local cam = real:FindFirstChildOfClass("Camera")
		out.viewport = { camera = cam and { cframe = ENCODE.CFrame(cam.CFrame), fov = num(cam.FieldOfView) }, parts = parts }
		for _, child in real:GetChildren() do
			if MODS[child.ClassName] then
				table.insert(kids, node(child))
			end
		end
	elseif not MODS[real.ClassName] then
		for _, child in real:GetChildren() do
			if child:IsA("GuiObject") or MODS[child.ClassName] then
				table.insert(kids, node(child))
			end
		end
	end
	if #kids > 0 then
		out.children = kids
	end
	return out
end
local function shot(screen: any, name: string)
	if not SHOTS then
		return
	end
	if not fs.isDir("tools/ui/shots") then
		fs.writeDir("tools/ui/shots")
	end
	screen.IgnoreGuiInset = true
	local doc = { format = "gui-snapshot/1", state = name, note = "BitLeveling " .. name, device = "pc", screen = { SHOT_W, SHOT_H }, inset = 0, defaults = defaults, guis = { node(screen) } }
	fs.writeFile("tools/ui/shots/" .. name .. ".json", serde.encode("json", doc, false))
	print("     wrote tools/ui/shots/" .. name .. ".json")
end
do
	local screen = I.new("ScreenGui")
	screen.Name = "Party"
	local responses = 0
	local view = call("partyView").party
	local ok, ui = pcall(PartySheet.open, screen, call, { view = view, onResponse = function()
		responses += 1
	end })
	check(ok, "the PARTY screen builds" .. (if ok then "" else ": " .. tostring(ui)))
	if ok then
		local root = screen:FindFirstChild("PartySheet")
		local cards, open, rows, rigs, vps = 0, 0, 0, 0, 0
		for _, d in root:GetDescendants() do
			if string.sub(d.Name, 1, 7) == "Member_" then
				cards += 1
			elseif string.sub(d.Name, 1, 5) == "Open_" then
				open += 1
			elseif string.sub(d.Name, 1, 10) == "Candidate_" then
				rows += 1
			elseif d:IsA("ViewportFrame") then
				vps += 1
				for _, m in d:GetChildren() do
					if m:IsA("Model") and m:GetAttribute("R6Look") then
						rigs += 1
					end
				end
			end
		end
		check(cards == 3 and open == 1, string.format("three member cards and one open place (%d, %d)", cards, open))
		check(rows == #view.candidates or rows == 24, string.format("a row for everyone you could ask (%d)", rows))
		check(vps > 0 and rigs == vps, string.format("every portrait is an R6 Hunter (%d of %d)", rigs, vps))
		local badge = find(root, "RankBadge")
		check(badge and badge:FindFirstChild("Letter") ~= nil, "rank badges with their letters")
		shot(screen, "party")
		-- the buttons call the server
		local function lastCall(): any
			return calls[#calls]
		end
		local member = root:FindFirstChild("Member_" .. tostring(view.members[1].relId), true)
		press(member:FindFirstChild("Talk", true))
		check(lastCall().action == "partyTalk" and lastCall().payload.relId == view.members[1].relId, "TALK calls partyTalk for them")
		uiLife.socialLeft = 3
		member = root:FindFirstChild("Member_" .. tostring(view.members[1].relId), true)
		press(member:FindFirstChild("Gift", true))
		local picker = root:FindFirstChild("GiftPicker", true)
		check(picker ~= nil, "GIFT opens the gift picker")
		shot(screen, "party_gift")
		if picker then
			press(picker:FindFirstChild("Gift_g_letter", true))
			check(lastCall().action == "partyGift" and lastCall().payload.gift == "g_letter", "a gift in it calls partyGift")
		end
		uiLife.socialLeft = 3
		-- someone who can be asked right now (the one asked in 8. can't, this year)
		local fresh = call("partyView").party
		local cand = fresh.candidates[1]
		for _, c in fresh.candidates do
			if c.why == nil then
				cand = c
				break
			end
		end
		ui.set(fresh)
		local row = root:FindFirstChild("Candidate_" .. tostring(cand.relId), true)
		local askBtn = row and row:FindFirstChild("AskButton", true)
		check(askBtn ~= nil and askBtn:GetAttribute("Enabled") == (cand.why == nil), "ASK is there, and enabled when they can be asked")
		if askBtn and askBtn:GetAttribute("Enabled") then
			press(askBtn)
			check(lastCall().action == "partyAsk" and lastCall().payload.relId == cand.relId, "ASK calls partyAsk")
			local res = root:FindFirstChild("Result", true)
			local stamp = res and res:FindFirstChild("Stamp", true)
			check(stamp and (stamp.Text == "JOINED YOUR PARTY" or stamp.Text == "SAID NO"), "their answer comes up: " .. tostring(stamp and stamp.Text))
			local line = res and res:FindFirstChild("Line", true)
			check(line and #line.Text > 4, "in their own words: " .. tostring(line and line.Text))
			shot(screen, "party_answer")
			if res then
				press(res:FindFirstChild("Ok", true))
			end
		end
		uiLife.socialLeft = 3
		member = root:FindFirstChild("Member_" .. tostring(view.members[2].relId), true)
		press(member:FindFirstChild("Dismiss", true))
		check(lastCall().action == "partyDismiss" and Party.memberOf(uiLife, view.members[2].relId) == nil, "PART WAYS calls partyDismiss, and they go")
		-- a profile
		member = root:FindFirstChild("Member_" .. tostring(view.members[1].relId), true)
		press(member:FindFirstChild("Profile", true))
		local prof = screen:FindFirstChild("NpcProfile")
		check(prof ~= nil, "PROFILE opens their profile")
		check(lastCall().action == "partyProfile", "which asks the server who they are")
		if prof then
			check(find(prof, "Portrait") ~= nil and find(prof, "Heading") ~= nil, "with their portrait and what you know")
			shot(screen, "party_profile")
			-- (and scrolled down to what you can do together)
			local pbody = find(prof, "Body")
			if pbody and SHOTS then
				pbody.CanvasPosition = roblox.Vector2.new(0, 420)
				shot(screen, "party_profile_do")
				pbody.CanvasPosition = roblox.Vector2.new(0, 0)
			end
			local go = find(prof, "Go_bl_past")
			check(go ~= nil, "and what you can do together")
			if go and go:GetAttribute("Enabled") then
				press(go)
				check(lastCall().action == "partyDo" and lastCall().payload.id == "bl_past", "doing it calls partyDo")
			end
		end
		check(responses > 0, "every reply is handed to the app (" .. responses .. ")")
		PartySheet.close()
		check(screen:FindFirstChild("PartySheet") == nil and screen:FindFirstChild("NpcProfile") == nil, "CLOSE takes it all down")
		-- a profile opened on its own (from PEOPLE)
		local okP = pcall(NpcProfile.open, screen, call, { relId = view.candidates[1].relId })
		check(okP and screen:FindFirstChild("NpcProfile") ~= nil, "a person's profile opens on its own too")
		NpcProfile.close()
	end
end

-- ══ 10. the pack ════════════════════════════════════════════════════════════
print("== 10. the pack")
do
	local v = Engine.Validate.run(pack)
	check(#v.errors == 0, "BitLeveling validates with the party in it (" .. #v.errors .. " errors" .. (if #v.errors > 0 then ": " .. v.errors[1] else "") .. ")")
	local packNo = table.clone(pack)
	packNo.party = nil
	local s3 = Engine.new(packNo)
	local l = s3:newLife({ seed = 99, birthEra = "under" })
	for _ = 1, 12 do
		l.pending = nil
		l.queue = {}
		Loader.ageUp(s3, l)
	end
	check(l.party == nil and s3:view(l).party == nil, "a pack without a party never makes one")
end

print(if failures == 0 then "\nparty_check: all passed" else string.format("\nparty_check: %d failure(s)", failures))
if failures > 0 then
	process.exit(1)
end
