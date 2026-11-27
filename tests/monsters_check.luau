--[[
	THE BESTIARY, CHECKED (Hunter/Monsters, Hunter/Bestiary, client/MonsterAnim,
	server/HunterLive/MonsterAI and Npcs' packs), on @lune/roblox instances:
		lune run tests/monsters_check
	  1. at least 120 kinds, every rank well stocked, every family with variants
	  2. every kind builds (root, joints, humanoid with its numbers, standing on the floor) and
	     has a bestiary entry, a known family, behaviour, role, gait and attack style
	  3. numbers scale with rank (the median fighter of each rank beats the one below)
	  4. every special ability is known to MonsterAI; ranged kinds have a shot; summoners
	     know what to call
	  5. a Gate's pack is one family, at or under its rank, with one leader at most
	  6. client/MonsterAnim animates every gait in every state (moving, attacking, casting,
	     charging, burrowed, airborne, hurt, dying) and draws every effect it's sent
	  7. MonsterAI runs: every special on a built monster against a dummy target, and whole
	     packs for a while against a target that moves
	  8. no canon named individual is a monster's name
	Exit code 1 on any failure.
]]
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")
local I = roblox.Instance

local RandomStub = {}
RandomStub.__index = RandomStub
function RandomStub.new(seed)
	return setmetatable({ s = (seed or 1) % 2147483647 + 1 }, RandomStub)
end
function RandomStub:NextNumber(a, b)
	self.s = (self.s * 48271) % 2147483647
	local r = self.s / 2147483647
	return (a or 0) + r * ((b or 1) - (a or 0))
end
function RandomStub:NextInteger(a, b)
	return a + math.floor(self:NextNumber() * (b - a + 1))
end

local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local players = { GetPlayers = function()
	return {}
end }
local warnings = {}
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font, Random = RandomStub,
	ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, NumberRange = roblox.NumberRange,
	warn = function(...)
		table.insert(warnings, table.concat({ ... }, " "))
	end,
	task = { spawn = function() end, delay = function() end, wait = function() return 0 end },
	game = { GetService = function(_, name)
		if name == "ReplicatedStorage" then
			return { WaitForChild = function()
				return shared
			end, FindFirstChild = function()
				return nil
			end }
		elseif name == "Players" then
			return players
		elseif name == "RunService" then
			return { RenderStepped = { Connect = function() end } }
		end
		return {}
	end },
}
local server = Loader.preload(Loader.node("src/server", "Server", nil))
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local Monsters = Loader.require(server.HunterLive.Monsters)
local Bestiary = Loader.require(shared.Hunter.Bestiary)
local MonsterAI = Loader.require(server.HunterLive.MonsterAI)
local MonsterAnim = Loader.require(client.MonsterAnim)
local Npcs = Loader.require(server.HunterLive.Npcs)

local failures = 0
local function check(ok: boolean, msg: string)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		failures += 1
	end
end
local function list(t: { string }, n: number?): string
	local out = {}
	for i = 1, math.min(#t, n or 8) do
		table.insert(out, t[i])
	end
	return table.concat(out, "; ") .. (if #t > (n or 8) then string.format(" (+%d more)", #t - (n or 8)) else "")
end
local LETTERS = { "E", "D", "C", "B", "A", "S" }
local function set(t: { string }): { [string]: boolean }
	local s = {}
	for _, v in t do
		s[v] = true
	end
	return s
end

-- ── 1. how many ──
print("== the roster")
local total = #Monsters.ORDER
local perRank = {}
for r = 1, 6 do
	perRank[r] = #Monsters.KINDS[r]
end
print(string.format("        %d kinds: E %d, D %d, C %d, B %d, A %d, S %d; %d families", total, perRank[1], perRank[2], perRank[3], perRank[4], perRank[5], perRank[6], #Monsters.FAMILY_ORDER))
check(total >= 120, string.format("at least 120 kinds (%d)", total))
local thin = {}
for r = 1, 6 do
	if perRank[r] < 18 then
		table.insert(thin, LETTERS[r])
	end
end
check(#thin == 0, "every rank has at least 18 kinds" .. (if #thin > 0 then ": " .. table.concat(thin, ", ") else ""))
local lonely = {}
for _, f in Monsters.FAMILY_ORDER do
	if #Monsters.FAMILIES[f] < 2 then
		table.insert(lonely, f)
	end
end
check(#lonely == 0 and #Monsters.FAMILY_ORDER >= 35, string.format("%d families, every one with variants", #Monsters.FAMILY_ORDER) .. (if #lonely > 0 then ": " .. list(lonely) else ""))

-- ── 2. every kind builds, and is known ──
print("== every kind")
local GAITS, BEH, ATK, ROLES = set(Monsters.GAITS), set(Monsters.BEHAVIOURS), set(Monsters.ATTACKS), Monsters.ROLES
local bad, floorBad, noEntry, jointsByGait = {}, {}, {}, {}
for _, id in Monsters.ORDER do
	local d = Monsters.DEFS[id]
	local ok, err = pcall(function()
		assert(GAITS[d.gait], "unknown gait " .. tostring(d.gait))
		assert(BEH[d.beh], "unknown behaviour " .. tostring(d.beh))
		assert(ATK[d.atk], "unknown attack style " .. tostring(d.atk))
		assert(ROLES[d.role], "unknown role " .. tostring(d.role))
		assert(Bestiary.FAMILIES[d.family], "family " .. d.family .. " has no bestiary entry")
		local model, hum = Monsters.build(id)
		assert(model.PrimaryPart and model.PrimaryPart.Name == "HumanoidRootPart", "no root")
		assert(hum.MaxHealth == d.hp and hum.WalkSpeed == d.speed, "the humanoid doesn't carry its numbers")
		assert(hum.HipHeight > 0, "no hip height")
		assert(model:GetAttribute("Gait") == d.gait and model:GetAttribute("Family") == d.family and model:GetAttribute("Attack") == d.atk, "attributes")
		local joints, parts, lowest = 0, 0, math.huge
		local names = {}
		for _, x in model:GetDescendants() do
			if x:IsA("Motor6D") then
				joints += 1
				assert(x.Part0 and x.Part1, "a joint without both parts")
				assert(not names[x.Name], "two joints named " .. x.Name)
				names[x.Name] = true
			elseif x:IsA("BasePart") then
				parts += 1
				if x.Transparency < 0.95 then
					local h = x.Size / 2
					for _, sx in { -1, 1 } do
						for _, sy in { -1, 1 } do
							for _, sz in { -1, 1 } do
								lowest = math.min(lowest, (x.CFrame * roblox.Vector3.new(h.X * sx, h.Y * sy, h.Z * sz)).Y)
							end
						end
					end
				end
			end
		end
		assert(joints >= 2, "fewer than two joints")
		assert(parts >= 5 and parts < 180, "parts: " .. parts)
		-- (built standing on the ground: its lowest part near y = 0)
		if lowest < -0.6 * d.size - 0.4 or lowest > 0.5 * d.size + 0.4 then
			table.insert(floorBad, string.format("%s lowest %.2f", id, lowest))
		end
		jointsByGait[d.gait] = (jointsByGait[d.gait] or 0) + 1
	end)
	if not ok then
		table.insert(bad, id .. ": " .. tostring(err))
	end
	local e = Bestiary.entry(id)
	if not (e and type(e.text) == "string" and #e.text > 10 and e.habitat and e.weakness and e.rankLetter == LETTERS[d.rank] and type(e.canon) == "boolean") then
		table.insert(noEntry, id)
	end
end
check(#bad == 0, string.format("all %d kinds build, with joints, numbers and known gait, behaviour, role and attack style", total) .. (if #bad > 0 then ": " .. list(bad, 5) else ""))
check(#floorBad == 0, "every kind is built standing on the ground" .. (if #floorBad > 0 then ": " .. list(floorBad) else ""))
check(#noEntry == 0, "every kind has a bestiary entry (text, habitat, weakness, rank, canon or original)" .. (if #noEntry > 0 then ": " .. list(noEntry) else ""))
local famBad, canonN, origN = {}, 0, 0
for id, f in Bestiary.FAMILIES do
	if not Monsters.FAMILIES[id] then
		table.insert(famBad, id .. " has no kinds")
	end
	if type(f.canon) ~= "boolean" or type(f.note) ~= "string" or not (string.find(f.note, "Canon type", 1, true) or string.find(f.note, "ORIGINAL", 1, true)) then
		table.insert(famBad, id .. " doesn't say canon type or ORIGINAL")
	end
end
for _, id in Monsters.ORDER do
	if Bestiary.entry(id) and Bestiary.entry(id).canon then
		canonN += 1
	else
		origN += 1
	end
end
check(#famBad == 0, string.format("every family says canon type or ORIGINAL (%d canon-type kinds, %d original)", canonN, origN) .. (if #famBad > 0 then ": " .. list(famBad) else ""))
local gaitsSeen = {}
for g in jointsByGait do
	table.insert(gaitsSeen, g)
end
table.sort(gaitsSeen)
check(#gaitsSeen >= 15, string.format("%d gaits in use: %s", #gaitsSeen, table.concat(gaitsSeen, ", ")))

-- ── 3. numbers by rank ──
print("== numbers")
local function median(xs: { number }): number
	table.sort(xs)
	local n = #xs
	return if n % 2 == 1 then xs[(n + 1) // 2] else (xs[n // 2] + xs[n // 2 + 1]) / 2
end
local mh, md = {}, {}
for r = 1, 6 do
	local hs, ds = {}, {}
	for _, id in Monsters.KINDS[r] do
		table.insert(hs, Monsters.DEFS[id].hp)
		table.insert(ds, Monsters.DEFS[id].dmg)
	end
	mh[r], md[r] = median(hs), median(ds)
end
print(string.format("        median hp  %s", table.concat({ mh[1], mh[2], mh[3], mh[4], mh[5], mh[6] }, " / ")))
print(string.format("        median dmg %s", table.concat({ md[1], md[2], md[3], md[4], md[5], md[6] }, " / ")))
local mono = true
for r = 2, 6 do
	if not (mh[r] > mh[r - 1] * 1.6 and md[r] > md[r - 1] * 1.4) then
		mono = false
	end
end
check(mono, "the median monster of every rank has far more health and hits far harder than the rank below")
local oddNums = {}
for _, id in Monsters.ORDER do
	local d = Monsters.DEFS[id]
	if not (d.hp > 0 and d.dmg > 0 and d.speed >= 8 and d.speed <= 30 and d.reach > 0 and d.aggro > 0 and d.cd > 0) then
		table.insert(oddNums, id)
	end
end
check(#oddNums == 0, "every kind has sane hp, damage, speed, reach, aggro range and attack cooldown" .. (if #oddNums > 0 then ": " .. list(oddNums) else ""))
-- (the 24 first kinds kept their numbers)
local KEPT = { goblin = 60, giant_rat = 45, cave_bat = 35, slime = 70, hobgoblin = 130, beetle = 150, spider = 120, dire_wolf = 110, orc = 300, lizardman = 260, troll = 380, naga = 280, ice_bear = 560, ogre = 700, wraith = 420, iron_golem = 820, warlord = 1200, stone_golem = 1500, wyvern = 1000, minotaur = 1300, dragonkin = 2800, colossus = 3600, abyss_serpent = 2600, hollow_king = 2400 }
local moved = {}
for id, hp in KEPT do
	if not Monsters.DEFS[id] or Monsters.DEFS[id].hp ~= hp then
		table.insert(moved, id)
	end
end
check(#moved == 0, "the first 24 kinds keep their ids and their balance" .. (if #moved > 0 then ": " .. list(moved) else ""))

-- ── 4. specials ──
print("== special abilities")
local spBad, used = {}, {}
for _, id in Monsters.ORDER do
	local d = Monsters.DEFS[id]
	if #d.sp < 1 or #d.sp > 3 then
		table.insert(spBad, id .. " has " .. #d.sp .. " specials")
	end
	for _, s in d.sp do
		local sp = MonsterAI.SPECIALS[s]
		if not sp then
			table.insert(spBad, id .. ": unknown special " .. s)
		else
			used[s] = true
			if sp.mech == "summon" and not (d.sum and Monsters.DEFS[d.sum]) and not Monsters.DEFS[id] then
				table.insert(spBad, id .. " summons nothing")
			end
		end
		if (s == "split" or s == "summon" or s == "raise") and not (d.sum and Monsters.DEFS[d.sum]) then
			table.insert(spBad, id .. ": " .. s .. " without a kind to call")
		end
	end
	if d.basic then
		local b = MonsterAI.SPECIALS[d.basic]
		if not b or not (b.mech == "shot" or b.mech == "lob" or b.mech == "mark") then
			table.insert(spBad, id .. ": its basic attack isn't a shot")
		end
	end
	if (d.beh == "ranged" or d.beh == "caster") and not d.basic then
		local any = false
		for _, s in d.sp do
			local m = MonsterAI.SPECIALS[s] and MonsterAI.SPECIALS[s].mech
			if m == "shot" or m == "lob" or m == "mark" or m == "aoe" or m == "drain" then
				any = true
			end
		end
		if not any then
			table.insert(spBad, id .. " is " .. d.beh .. " with nothing to throw")
		end
	end
end
local mechs = set(MonsterAI.MECHS)
for s, sp in MonsterAI.SPECIALS do
	if not mechs[sp.mech] or type(sp.name) ~= "string" then
		table.insert(spBad, s .. ": unknown mechanic")
	end
	if sp.mech ~= "passive" and not (sp.windup and sp.windup > 0 and sp.cd and sp.cd > 0 and (sp.tele == "Casting" or sp.tele == "Charging")) then
		table.insert(spBad, s .. ": no wind-up, cooldown or telegraph")
	end
end
local unusedSp = {}
for s in MonsterAI.SPECIALS do
	if not used[s] then
		table.insert(unusedSp, s)
	end
end
local nSp = 0
for _ in MonsterAI.SPECIALS do
	nSp += 1
end
check(#spBad == 0, string.format("every kind has 1-3 valid specials (%d specials known, every one telegraphed)", nSp) .. (if #spBad > 0 then ": " .. list(spBad) else ""))
check(#unusedSp == 0, "every special is used by some kind" .. (if #unusedSp > 0 then ": " .. list(unusedSp) else ""))
local behSeen = {}
for _, id in Monsters.ORDER do
	behSeen[Monsters.DEFS[id].beh] = true
end
local behMissing = {}
for _, b in Monsters.BEHAVIOURS do
	if not behSeen[b] or not MonsterAI.BEHAVIOURS[b] then
		table.insert(behMissing, b)
	end
end
check(#behMissing == 0, "all ten behaviours are used and known to MonsterAI" .. (if #behMissing > 0 then ": " .. list(behMissing) else ""))

-- ── 5. packs ──
print("== a Gate's pack")
local packBad = {}
local seed = 7
local function rand(a, b)
	seed = (seed * 1103515245 + 12345) % 2147483648
	return a + seed % (b - a + 1)
end
for _, id in Monsters.ORDER do
	local d = Monsters.DEFS[id]
	for _ = 1, 3 do
		local pack = Monsters.packFor(id, d.rank, 10, rand)
		local leaders, healers = 0, 0
		for _, k in pack do
			local kd = Monsters.DEFS[k]
			if kd.family ~= d.family then
				table.insert(packBad, id .. " brought " .. k)
			elseif kd.rank > d.rank then
				table.insert(packBad, id .. "'s pack has a stronger " .. k)
			end
			if kd.beh == "leader" then
				leaders += 1
			elseif kd.beh == "healer" then
				healers += 1
			end
		end
		if #pack ~= 10 or leaders > 1 or healers > 1 then
			table.insert(packBad, string.format("%s: %d kinds, %d leaders, %d healers", id, #pack, leaders, healers))
		end
	end
end
check(#packBad == 0, "every Gate's pack is one family, none stronger than the Gate, one leader and one healer at most" .. (if #packBad > 0 then ": " .. list(packBad) else ""))
print("        e.g. " .. table.concat(Monsters.packFor("goblin", 2, 7, rand), ", "))
print("        e.g. " .. table.concat(Monsters.packFor("ice_elf_hunter", 5, 5, rand), ", "))

-- ── 6. the animation ──
print("== client/MonsterAnim")
local animBad, gaitMoved = {}, {}
local STATES = {
	{ "idle" }, { "moving" }, { "Attacking", 1 }, { "Casting", "fire_breath" }, { "Charging", "charge" },
	{ "Burrowed", true }, { "Airborne", true }, { "Disguised", true }, { "Enraged", true }, { "hurt" }, { "death" },
}
for _, id in Monsters.ORDER do
	local d = Monsters.DEFS[id]
	local ok, err = pcall(function()
		local model, hum = Monsters.build(id)
		local r = MonsterAnim.rig(model)
		assert(r and r.gait == d.gait, "no rig")
		local t = 0
		local root = model.PrimaryPart
		for _, st in STATES do
			if st[1] == "moving" then
				for k = 1, 12 do
					root.CFrame = root.CFrame * roblox.CFrame.new(0, 0, -0.5)
					t += 1 / 30
					MonsterAnim.animate(r, 1 / 30, t)
				end
			elseif st[1] == "hurt" then
				hum.Health = hum.MaxHealth * 0.5
			elseif st[1] == "death" then
				hum.Health = 0
			elseif st[1] ~= "idle" then
				model:SetAttribute(st[1], st[2])
			end
			for k = 1, 10 do
				t += 1 / 30
				MonsterAnim.animate(r, 1 / 30, t)
			end
			if st[1] ~= "idle" and st[1] ~= "moving" and st[1] ~= "hurt" and st[1] ~= "death" then
				model:SetAttribute(st[1], nil)
			end
		end
		local movedAny = false
		for _, j in r.joints do
			local okT, tf = pcall(function()
				return j.Transform
			end)
			if okT and tf ~= roblox.CFrame.new() then
				movedAny = true
			end
		end
		assert(movedAny, "no joint moved")
		gaitMoved[d.gait] = true
	end)
	if not ok then
		table.insert(animBad, id .. ": " .. tostring(err))
	end
end
check(#animBad == 0, string.format("every kind animates through every state (%d states, %d gaits)", #STATES, #gaitsSeen) .. (if #animBad > 0 then ": " .. list(animBad, 4) else ""))
local gaitsNot = {}
for _, g in Monsters.GAITS do
	if jointsByGait[g] and not gaitMoved[g] then
		table.insert(gaitsNot, g)
	end
end
check(#gaitsNot == 0, "every gait moves its joints" .. (if #gaitsNot > 0 then ": " .. list(gaitsNot) else ""))
-- the effects the server announces
do
	local fxFolder = I.new("Folder")
	MonsterAnim.fxParent = fxFolder
	local kinds = { "tele_ring", "tele_cone", "tele_line", "shot", "burst", "cone", "beam", "rain", "bolt", "meteor", "quake", "heal", "buff", "summon", "dust", "cloud", "blink", "shield" }
	local ok, err = pcall(function()
		for _, w in kinds do
			MonsterAnim.fx({ fx = "monster", what = w, at = { 0, 3, 0 }, to = { 10, 3, 4 }, dir = { 0, 0, -1 }, r = 6, len = 14, angle = 30, t = 0.5, c = { 255, 120, 40 }, points = { { 2, 3, 2 } }, lob = true, kind = "boulder" })
		end
		assert(#MonsterAnim.effects >= #kinds, "effects weren't made")
		for _ = 1, 120 do
			MonsterAnim.stepFx(1 / 30)
		end
	end)
	check(ok and #MonsterAnim.effects == 0 and #fxFolder:GetChildren() == 0, string.format("every special's effect is drawn and cleaned up (%d kinds)", #kinds) .. (if not ok then ": " .. tostring(err) else ""))
end

-- ── 7. MonsterAI ──
print("== server/HunterLive/MonsterAI")
local street = I.new("Folder")
local function makeMonster(kind: string, at: any, incident: number?): any
	local model, hum = Monsters.build(kind)
	model.Parent = street
	local root = model.PrimaryPart
	local from = root.CFrame
	local to = roblox.CFrame.new(at)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = to * from:ToObjectSpace(d.CFrame)
		end
	end
	local def = Monsters.DEFS[kind]
	local m = { model = model, hum = hum, rank = def.rank, kind = kind, def = table.clone(def), incident = incident or 1, cool = 0, home = at }
	return m
end
-- a dummy to fight: it stands (or walks) on the street and counts what hits it
local function makeWorld()
	local w = { hits = 0, hitBy = {}, fx = {}, spawned = 0, monsters = {} }
	w.dummy = { model = I.new("Model"), pos = roblox.Vector3.new(0, 3, -12) }
	w.ctx = {
		now = 100,
		onHit = function(m, kind, victim)
			w.hits += 1
			w.hitBy[m.kind] = (w.hitBy[m.kind] or 0) + m.def.dmg
			local _ = kind
			local _2 = victim
		end,
		targets = function(pos, radius)
			if (w.dummy.pos - pos).Magnitude <= radius then
				return { { kind = "responder", victim = w.dummy, pos = w.dummy.pos } }
			end
			return {}
		end,
		allies = function(m, radius)
			local out = {}
			for _, o in w.monsters do
				if o ~= m and o.hum.Health > 0 and (o.model.PrimaryPart.CFrame.Position - m.model.PrimaryPart.CFrame.Position).Magnitude <= radius then
					table.insert(out, o)
				end
			end
			return out
		end,
		spawn = function(kind, pos, master)
			w.spawned += 1
			local s = makeMonster(kind, pos, master.incident)
			s.summoned = true
			MonsterAI.prepare(s, w.ctx.now)
			table.insert(w.monsters, s)
			return s
		end,
		fx = function(d)
			table.insert(w.fx, d.what)
		end,
		move = function(m, pos)
			-- (no Humanoid:MoveTo offline: step the root toward the goal at its walk speed)
			local root = m.model.PrimaryPart
			local here = root.CFrame.Position
			local d = roblox.Vector3.new(pos.X - here.X, 0, pos.Z - here.Z)
			local stepLen = math.min(d.Magnitude, m.hum.WalkSpeed * 0.25)
			if stepLen > 0.01 then
				local nxt = here + d.Unit * stepLen
				local from = root.CFrame
				local to = roblox.CFrame.lookAt(nxt, nxt + d.Unit)
				for _, p in m.model:GetDescendants() do
					if p:IsA("BasePart") then
						p.CFrame = to * from:ToObjectSpace(p.CFrame)
					end
				end
			end
		end,
		whereIs = function()
			return w.dummy.pos
		end,
		rand = function()
			return 0.3
		end,
	}
	return w
end
local function run(w, seconds: number, stepping: boolean?)
	for _ = 1, math.floor(seconds / 0.25) do
		w.ctx.now += 0.25
		MonsterAI.update(w.monsters, w.ctx)
		if stepping then
			for _, m in table.clone(w.monsters) do
				if m.hum.Health > 0 then
					local d = (w.dummy.pos - m.model.PrimaryPart.CFrame.Position).Magnitude
					MonsterAI.step(m, w.dummy, "responder", w.dummy.pos, d, w.ctx)
				end
			end
		end
	end
end
-- every special, started on a kind that has it, against a dummy in its range
local spRun, spErr = {}, {}
local DAMAGES = { shot = true, lob = true, mark = true, line = true, aoe = true, cone = true, dash = true, jump = true, burrow = true, blink = true, drain = true, reach = true }
for s, sp in MonsterAI.SPECIALS do
	if sp.mech ~= "passive" then
		local kind = nil
		for _, id in Monsters.ORDER do
			if table.find(Monsters.DEFS[id].sp, s) then
				kind = id
				break
			end
		end
		if kind then
			MonsterAI.reset()
			local w = makeWorld()
			local m = makeMonster(kind, roblox.Vector3.new(0, 3, 0))
			table.insert(w.monsters, m)
			local ally = makeMonster(kind, roblox.Vector3.new(4, 3, 2))
			table.insert(w.monsters, ally)
			MonsterAI.prepare(m, w.ctx.now)
			MonsterAI.prepare(ally, w.ctx.now)
			ally.hum.Health = ally.hum.MaxHealth * 0.4
			m.hum.Health = m.hum.MaxHealth * 0.7
			-- (the dummy stands where this special reaches)
			local dist = if sp.mech == "aoe" then 3 elseif sp.mech == "cone" then 4 elseif sp.mech == "reach" then m.def.reach else math.max(sp.min or 0, 3) + 2
			w.dummy.pos = roblox.Vector3.new(0, 3, -dist)
			local ok, err = pcall(function()
				local tgt = { kind = "responder", victim = w.dummy, pos = w.dummy.pos, live = function()
					return w.dummy.pos
				end }
				assert(MonsterAI.start(m, s, tgt, w.ctx), "didn't start")
				local tele = m.model:GetAttribute(sp.tele)
				assert(tele == s, "no " .. tostring(sp.tele) .. " wind-up shown")
				run(w, 5)
				assert(m.model:GetAttribute("Casting") == nil and m.model:GetAttribute("Charging") == nil, "the wind-up never ended")
				assert((m.model:GetAttribute("Special") or 0) >= 1, "it never went off")
				if DAMAGES[sp.mech] then
					assert(w.hits > 0, "it never hit the dummy standing in it")
				elseif sp.mech == "buff" then
					assert(m.model:GetAttribute("Empowered") == true or (m.empoweredUntil or 0) > 0, "nobody was driven on")
				elseif sp.mech == "heal" then
					assert(ally.hum.Health > ally.hum.MaxHealth * 0.4 or m.hum.Health > m.hum.MaxHealth * 0.7, "nobody was mended")
				elseif sp.mech == "summon" then
					assert(w.spawned > 0, "nothing was called up")
				end
				assert(#w.fx > 0, "nothing was drawn")
			end)
			if ok then
				table.insert(spRun, s)
			else
				table.insert(spErr, s .. " (" .. kind .. "): " .. tostring(err))
			end
		end
	end
end
check(#spErr == 0, string.format("every special winds up, shows it, goes off and lands (%d run)", #spRun) .. (if #spErr > 0 then ": " .. list(spErr, 6) else ""))
-- passives: a slime splits, a berserker frenzies, a troll mends, a mimic waits
do
	MonsterAI.reset()
	local w = makeWorld()
	local slime = makeMonster("slime", roblox.Vector3.new(0, 3, 0))
	local orc = makeMonster("orc_berserker", roblox.Vector3.new(6, 3, 0))
	local troll = makeMonster("troll", roblox.Vector3.new(-6, 3, 0))
	local mimic = makeMonster("mimic", roblox.Vector3.new(0, 3, 30))
	for _, m in { slime, orc, troll, mimic } do
		table.insert(w.monsters, m)
		MonsterAI.prepare(m, w.ctx.now)
	end
	w.dummy.pos = roblox.Vector3.new(0, 3, 200)
	slime.hum.Health = slime.hum.MaxHealth * 0.3
	orc.hum.Health = orc.hum.MaxHealth * 0.3
	troll.hum.Health = troll.hum.MaxHealth * 0.5
	local ok, err = pcall(function()
		run(w, 1)
		troll.lastHurt = w.ctx.now - 10
		run(w, 4)
	end)
	check(ok and w.spawned >= 2 and orc.model:GetAttribute("Enraged") == true and troll.hum.Health > troll.hum.MaxHealth * 0.5 and mimic.model:GetAttribute("Disguised") == true, "passives: a slime splits, a berserker frenzies, a troll regrows, a mimic lies in wait" .. (if not ok then ": " .. tostring(err) else ""))
end
-- whole packs, fighting a dummy that walks about, for a while
do
	local packErr, hitPacks, families = {}, 0, 0
	for _, fam in Monsters.FAMILY_ORDER do
		local first = Monsters.FAMILIES[fam][1]
		local d = Monsters.DEFS[first]
		MonsterAI.reset()
		local w = makeWorld()
		local ok, err = pcall(function()
			for i, k in Monsters.packFor(first, d.rank, 5, rand) do
				local m = makeMonster(k, roblox.Vector3.new(i * 3, 3, 20 + i))
				MonsterAI.prepare(m, w.ctx.now)
				table.insert(w.monsters, m)
			end
			for step = 1, 80 do
				w.dummy.pos = roblox.Vector3.new(math.sin(step * 0.1) * 8, 3, math.cos(step * 0.13) * 8)
				run(w, 0.25, true)
			end
		end)
		families += 1
		if not ok then
			table.insert(packErr, fam .. ": " .. tostring(err))
		elseif w.hits > 0 then
			hitPacks += 1
		end
	end
	check(#packErr == 0 and hitPacks >= families - 2, string.format("every family's pack fights a moving target for 20 seconds without error (%d of %d landed blows)", hitPacks, families) .. (if #packErr > 0 then ": " .. list(packErr, 4) else ""))
end
-- a ranged kind keeps its distance; a melee kind closes in
do
	MonsterAI.reset()
	local w = makeWorld()
	local archer = makeMonster("orc_archer", roblox.Vector3.new(0, 3, -16))
	local brute = makeMonster("orc", roblox.Vector3.new(30, 3, 0))
	for _, m in { archer, brute } do
		table.insert(w.monsters, m)
		MonsterAI.prepare(m, w.ctx.now)
	end
	w.dummy.pos = roblox.Vector3.new(0, 3, -12)
	run(w, 6, true)
	local da = (archer.model.PrimaryPart.CFrame.Position - w.dummy.pos).Magnitude
	local db = (brute.model.PrimaryPart.CFrame.Position - w.dummy.pos).Magnitude
	check(da > 10 and db < 12, string.format("an archer backs off to shoot (%.0f studs) while an orc closes in (%.0f)", da, db))
end

-- ── Npcs: a break lets out one family ──
print("== server/HunterLive/Npcs")
do
	local okInit, e = pcall(Npcs.init, I.new("Folder"))
	check(okInit, "the NPC layer starts" .. (if okInit then "" else ": " .. tostring(e)))
	local fams, ok, err = {}, true, nil
	ok, err = pcall(function()
		for k = 1, 7 do
			local m = Npcs.spawnMonster(3, roblox.Vector3.new(0, 0, 0), 77, if k % 3 == 0 then "naga" else "orc")
			fams[m.def.family] = (fams[m.def.family] or 0) + 1
		end
		Npcs.aiCtx.move = function() end
		Npcs.stepMonsters(function() end)
		local s = Npcs.spawnSummon("spiderling", roblox.Vector3.new(0, 0, 0), Npcs.monsters[1])
		assert(s and s.summoned, "no summon")
		for _, m in table.clone(Npcs.monsters) do
			Npcs.removeMonster(m)
		end
		assert(Npcs.packs[77] == nil, "the pack wasn't forgotten")
	end)
	local n = 0
	for _ in fams do
		n += 1
	end
	check(ok and n == 1 and fams.orcs == 7, "a C-rank break that starts with an orc lets out an orc war band, not a mix" .. (if not ok then ": " .. tostring(err) else ""))
end

-- ── the life's side: family foes, family bosses ──
print("== foes and bosses (Games/BitLeveling)")
do
	local Foes = Loader.require(shared.Games.BitLeveling.Foes)
	local Bosses = Loader.require(shared.Games.BitLeveling.Bosses)
	local foeIds = {}
	for _, f in Foes do
		foeIds[f.id] = f
	end
	local missing = {}
	for _, id in Monsters.ORDER do
		local d = Monsters.DEFS[id]
		local fid = Bestiary.foeFor(d.family, d.rank)
		if not fid or not foeIds[fid] then
			table.insert(missing, d.family .. "@" .. d.rank .. " -> " .. tostring(fid))
		end
	end
	check(#missing == 0, "every family, at every rank it has, has a foe on the fight screen" .. (if #missing > 0 then ": " .. list(missing) else ""))
	-- (bosses of a rank are tuned alike: the new ones sit inside the old ones' band)
	local BAND = { goblin_chief = 1, bat_matriarch = 1, kobold_tunnel_boss = 1, brood_mother = 2, hob_captain = 2, bone_captain = 2, orc_warlord = 3, naga_matriarch = 3, elf_huntmaster = 3, frost_bear = 4, wraith_lord = 4, forge_lord = 4, golem_lord = 5, wyvern_queen = 5, ice_elf_warchief = 5, hive_matron = 5, dark_matriarch = 5, dragonkin_tyrant = 6, hollow_king = 6, frost_jarl = 6, lich_archivist = 6, demon_noble = 6 }
	local HP = { { 80, 120 }, { 140, 180 }, { 210, 260 }, { 350, 390 }, { 590, 650 }, { 990, 1110 } }
	local BASE = { { 4, 7 }, { 7, 12 }, { 13, 16 }, { 22, 27 }, { 24, 29 }, { 53, 56 } }
	local off = {}
	for id, r in BAND do
		local b = Bosses[id]
		if not b then
			table.insert(off, id .. " is missing")
		elseif not foeIds[b.enemy] then
			table.insert(off, id .. "'s foe " .. tostring(b.enemy) .. " doesn't exist")
		elseif b.hp < HP[r][1] or b.hp > HP[r][2] or b.base < BASE[r][1] or b.base > BASE[r][2] then
			table.insert(off, id .. " is out of its rank's band")
		end
	end
	check(#off == 0, "the family bosses (kobold tunnel-boss to demon noble) are tuned with their rank's others and show a real foe" .. (if #off > 0 then ": " .. list(off) else ""))
end

-- ── 8. names ──
print("== names")
local FORBIDDEN = { "Kasaka", "Cerberus", "Baruka", "Vulcan", "Beru", "Kamish", "Igris", "Tusk", "Kaisel", "Greed", "Antares", "Ashborn", "Querehsha", "Rakan", "Baran", "Yogumunt", "Legia", "Tarnak", "Sillad", "Kargalgan", "Bellion", "Monarch", "Ant King", "Ant Queen", "Steel-fanged" }
local named = {}
for _, id in Monsters.ORDER do
	local nm = Monsters.DEFS[id].name .. " "
	if Monsters.DEFS[id].name == "Iron" or Monsters.DEFS[id].name == "Tank" then
		table.insert(named, id)
	end
	for _, f in FORBIDDEN do
		if string.find(string.lower(nm), string.lower(f), 1, true) then
			table.insert(named, id .. " (" .. f .. ")")
		end
	end
end
check(#named == 0, "no monster is named for a canon individual" .. (if #named > 0 then ": " .. list(named) else ""))

if #warnings > 0 then
	print("        warnings: " .. #warnings .. ": " .. tostring(warnings[1]))
end
if failures > 0 then
	print(string.format("\n%d check(s) failed.", failures))
	process.exit(1)
end
print("\nThe bestiary builds, fights and moves.")
