--[[
	The live city's moves (Hunter/Abilities.luau) and their effects (client/SkillFx.luau):
	  - every move is valid data (class, slot, element, kind, shape, tier, cooldown, mana, cast)
	  - every unlocking skill exists in Games/BitLeveling/Skills.luau, and each school's skills
	    are the ones the moves expect
	  - every class has moves for every slot, and a new E-rank Hunter can fill Q E R T
	  - the scaling: every tier table rises; by slot, a higher tier hits harder, costs more mana
	    and heals, guards and buffs more; an S move clearly outclasses an E move
	  - every move's effect (and every cast, construct tick and storm tick) runs on real
	    @lune/roblox instances with stubbed services: every tween's goals are set on the real
	    instance (so property names and types are checked), delayed tasks are run, each effect
	    stays under SkillFx.MAX_PARTS, and everything it made is handed to Debris
	  - the walk HUD (client/HunterLive) starts: the skill bar's five slots, the cooldown sweep,
	    the mana bar, the loadout panel and its search, and a key press asking for a slot
	  - the server (server/HunterLive) is installed with stubbed services and a clock the test
	    moves: a Hunter of every class walks in at S-rank with every skill, and every move it can
	    reach is equipped (through hwSkillBar) and used on monsters in front of it; each resolves,
	    is drawn for everyone, and hurts something if it does damage; cooldowns hold, an E-rank
	    pool runs dry and is refused, a move above the Hunter's rank can't be equipped
		lune run tests/abilities_check
]]
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")
local I = roblox.Instance

local fails = 0
local function check(ok, msg, detail)
	print((if ok then "  ok    " else "  FAIL  ") .. msg .. (if ok or detail == nil then "" else ": " .. tostring(detail)))
	if not ok then
		fails += 1
	end
end

local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Abilities = Loader.require(shared.Hunter.Abilities)
local Skills = Loader.require(shared.Games.BitLeveling.Skills)

-- ── the data ──
local problems = Abilities.problems()
check(#problems == 0, string.format("all %d moves are valid data", #Abilities.list), table.concat(problems, "; ", 1, math.min(#problems, 8)))
check(#Abilities.list >= 200, "there are at least 200 moves", #Abilities.list)
local missing = {}
for _, ab in Abilities.list do
	if ab.unlock and not (Skills.traits[ab.unlock] and Skills.traits[ab.unlock].category == "skill") then
		table.insert(missing, ab.id .. " -> " .. ab.unlock)
	end
end
check(#missing == 0, "every unlocking skill exists in Skills.luau", table.concat(missing, ", "))
local schoolBad = {}
for _, sc in Abilities.SCHOOLS do
	for i, id in sc.skills do
		local def = Skills.traits[id]
		if not def or def.school ~= sc.id or def.step ~= i then
			table.insert(schoolBad, sc.id .. "/" .. id)
		end
	end
end
check(#schoolBad == 0, string.format("the %d schools' spells are the skills their moves expect", #Abilities.SCHOOLS), table.concat(schoolBad, ", "))
local groups, byGroup = Abilities.groups(), {}
for _, ab in Abilities.list do
	byGroup[ab.group] = (byGroup[ab.group] or 0) + 1
end
local thin = {}
for _, g in groups do
	if (byGroup[g.id] or 0) < 8 then
		table.insert(thin, g.id .. "=" .. tostring(byGroup[g.id] or 0))
	end
end
check(#thin == 0, string.format("every group (%d: classes, schools, arts, craft) has at least 8 moves", #groups), table.concat(thin, ", "))
local kinds, shapes, elements = {}, {}, {}
for _, ab in Abilities.list do
	kinds[ab.kind] = true
	shapes[ab.shape] = true
	elements[ab.element] = true
end
for k in Abilities.KINDS do
	check(kinds[k] == true, "some move is a " .. k)
end
local unusedShapes = {}
for s in Abilities.SHAPES do
	if not shapes[s] then
		table.insert(unusedShapes, s)
	end
end
check(#unusedShapes == 0, "every shape is used by some move", table.concat(unusedShapes, ", "))
local unusedEl = {}
for e in Abilities.ELEMENTS do
	if not elements[e] then
		table.insert(unusedEl, e)
	end
end
check(#unusedEl == 0, "every element is used by some move", table.concat(unusedEl, ", "))

-- ── classes and slots ──
for _, class in Abilities.CLASSES do
	local per, own = {}, 0
	for _, ab in Abilities.forClass(class) do
		per[ab.slot] = (per[ab.slot] or 0) + 1
		if ab.class == class then
			own += 1
		end
	end
	local missingSlots = {}
	for _, slot in Abilities.SLOTS do
		if (per[slot] or 0) == 0 then
			table.insert(missingSlots, slot)
		end
	end
	check(#missingSlots == 0 and own >= 6, string.format("%s: %d moves of its own, %d it can reach, every slot covered", class, own, #Abilities.forClass(class)), table.concat(missingSlots, ","))
	-- the class's own moves cover every slot too
	local ownSlots = {}
	for _, ab in Abilities.list do
		if ab.class == class then
			ownSlots[ab.slot] = true
		end
	end
	local gaps = {}
	for _, slot in Abilities.SLOTS do
		if not ownSlots[slot] then
			table.insert(gaps, slot)
		end
	end
	check(#gaps == 0, class .. " has a signature move for every slot", table.concat(gaps, ","))
	local fresh = Abilities.resolveBar(class, nil, {}, 1)
	check(fresh.Q ~= nil and fresh.E ~= nil and fresh.R ~= nil and fresh.T ~= nil and fresh.G == nil, class .. ": a new E-rank Hunter fills Q E R T with no skills (no ultimate yet)")
	-- with everything learned at S-rank, the bar takes S moves where there are some
	local all = {}
	for id, def in Skills.traits do
		if type(def) == "table" and def.category == "skill" then
			all[id] = true
		end
	end
	local full = Abilities.resolveBar(class, nil, all, 6)
	check(full.G ~= nil and Abilities.byId[full.G].tier == 6, class .. ": at S-rank with every skill, the ultimate is an S move")
	-- a saved pick that isn't usable falls back; a usable one stays
	local pick = nil
	for _, ab in Abilities.forClass(class) do
		if ab.slot == "Q" and Abilities.usable(ab, class, all, 6) and ab.id ~= full.Q then
			pick = ab.id
			break
		end
	end
	local saved = Abilities.resolveBar(class, { Q = pick, R = "not_a_move", E = "inferno" }, all, 6)
	check(pick == nil or saved.Q == pick, class .. ": a saved pick stays in its slot")
	check(saved.R ~= "not_a_move" and saved.E ~= "inferno", class .. ": an unknown id or a move of another slot falls back")
end
-- rank and class gates
local cleave = Abilities.byId.cleave
check(Abilities.usable(cleave, "fighter", {}, 1) and not Abilities.usable(cleave, "mage", {}, 6), "a class move is its class's alone")
local sunfall = Abilities.byId.sunfall
check(not Abilities.usable(sunfall, "mage", { [sunfall.unlock] = true }, 4) and Abilities.usable(sunfall, "mage", { [sunfall.unlock] = true }, 5), "a move needs a rank at least its tier")
check(not Abilities.usable(sunfall, "mage", {}, 6), "a school move needs its school's spell")
local swift = Abilities.byId.swift_cut
check(Abilities.usable(swift, "fighter", {}, 1) and Abilities.usable(swift, "assassin", {}, 1) and not Abilities.usable(swift, "healer", {}, 6), "the sword arts open by class and rank")
check(Abilities.lockReason(sunfall, "mage", {}, 3, function(id)
	return Skills.traits[id] and Skills.traits[id].name
end) == "A-rank", "a locked move says why")

-- ── the scaling ──
local T = Abilities.TIER
for key, list in T do
	local rising = true
	for i = 2, 6 do
		if not (list[i] > list[i - 1]) then
			rising = false
		end
	end
	check(rising and #list == 6, "the tier table '" .. key .. "' rises from E to S")
end
local function rating(ab: any): number
	local m = ab.mult
	if ab.kind == "projectile" then
		m *= ab.count or 1
	elseif ab.kind == "zone" then
		m *= ab.duration / ab.tick
	elseif ab.kind == "construct" then
		m *= ab.duration / 0.9
	elseif ab.kind == "chain" then
		local s = 1
		for i = 1, ab.chains or 0 do
			s += 0.85 ^ i
		end
		m *= s * 0.7
	end
	return m / (ab.power or 1)
end
local function median(xs: { number }): number?
	if #xs == 0 then
		return nil
	end
	table.sort(xs)
	return xs[math.floor((#xs + 1) / 2)]
end
for _, slot in Abilities.SLOTS do
	local byTier = {}
	for t = 1, 6 do
		byTier[t] = { dmg = {}, raw = {}, mana = {}, cd = {}, cast = {}, heal = {}, guard = {}, buff = {} }
	end
	for _, ab in Abilities.list do
		if ab.slot == slot then
			local b = byTier[ab.tier]
			if ab.mult > 0 then
				table.insert(b.dmg, rating(ab))
				table.insert(b.raw, rating(ab) * (ab.power or 1))
			end
			table.insert(b.mana, ab.mana / (ab.manaMul or 1))
			table.insert(b.cd, ab.cd / (ab.cdMul or 1))
			if ab.cast > 0 then
				table.insert(b.cast, ab.cast)
			end
			if ab.heal and not (ab.kind == "zone" or ab.kind == "construct" or ab.duration and ab.kind == "heal" and not ab.guard) then
				table.insert(b.heal, ab.heal / (ab.healMul or 1))
			end
			if ab.guard then
				table.insert(b.guard, 1 - ab.guard)
			end
			if ab.buff and ab.buff.dmg then
				table.insert(b.buff, ab.buff.dmg)
			end
		end
	end
	-- the same shape at a higher tier hits harder
	local shapeLines, shapeOk = 0, true
	local bad = {}
	for shapeId in Abilities.SHAPES do
		local prev = nil
		for t = 1, 6 do
			local xs = {}
			for _, ab in Abilities.list do
				if ab.slot == slot and ab.shape == shapeId and ab.tier == t and ab.mult > 0 then
					table.insert(xs, rating(ab))
				end
			end
			local m = median(xs)
			if m then
				if prev and not (m > prev) then
					shapeOk = false
					table.insert(bad, shapeId .. "@" .. Abilities.TIER_LETTER[t])
				end
				if prev then
					shapeLines += 1
				end
				prev = m
			end
		end
	end
	check(shapeOk, string.format("%s slot: the same shape hits harder at a higher tier (%d comparisons)", slot, shapeLines), table.concat(bad, ", "))
	for _, key in { "mana", "cd", "heal", "guard", "buff" } do
		local prev, prevT, ok, line = nil, nil, true, {}
		for t = 1, 6 do
			local m = median(byTier[t][key])
			if m then
				table.insert(line, string.format("%s %.2f", Abilities.TIER_LETTER[t], m))
				if prev and not (m > prev or (key == "cd" and m >= prev)) then
					ok = false
				end
				prev, prevT = m, t
			end
		end
		local _ = prevT
		if #line >= 2 then
			check(ok, string.format("%s slot: %s rises with tier (%s)", slot, key, table.concat(line, ", ")))
		end
	end
	-- a top-tier move clearly outclasses a bottom-tier one: the weakest move of the slot's
	-- highest tier beats the strongest of its lowest (and by the formula, an S move does
	-- 3.5x what an E move does)
	local lo, hi = nil, nil
	for t = 1, 6 do
		if #byTier[t].raw > 0 then
			lo = lo or t
			hi = t
		end
	end
	-- (by shape: the weakest of its highest tier beats the strongest of its lowest)
	local outBad, outN = {}, 0
	for shapeId in Abilities.SHAPES do
		local low, high, tl, th = {}, {}, nil, nil
		for _, ab in Abilities.list do
			if ab.slot == slot and ab.shape == shapeId and ab.mult > 0 then
				tl = if tl == nil or ab.tier < tl then ab.tier else tl
				th = if th == nil or ab.tier > th then ab.tier else th
			end
		end
		if tl and th and th - tl >= 2 then
			for _, ab in Abilities.list do
				if ab.slot == slot and ab.shape == shapeId and ab.mult > 0 then
					if ab.tier == tl then
						table.insert(low, rating(ab) * (ab.power or 1))
					elseif ab.tier == th then
						table.insert(high, rating(ab) * (ab.power or 1))
					end
				end
			end
			outN += 1
			local strongestLow, weakestHigh = 0, math.huge
			for _, x in low do
				strongestLow = math.max(strongestLow, x)
			end
			for _, x in high do
				weakestHigh = math.min(weakestHigh, x)
			end
			if not (weakestHigh > strongestLow) then
				table.insert(outBad, string.format("%s %s %.2f <= %s %.2f", shapeId, Abilities.TIER_LETTER[th], weakestHigh, Abilities.TIER_LETTER[tl], strongestLow))
			end
		end
	end
	if outN > 0 then
		check(#outBad == 0, string.format("%s slot: for every shape, its weakest top-tier move outclasses its strongest bottom-tier one (%d shapes)", slot, outN), table.concat(outBad, "; "))
	end
	local medLo, medHi = lo and median(byTier[lo].raw), hi and median(byTier[hi].raw)
	if medLo and medHi and hi - lo >= 2 then
		check(medHi > medLo * (Abilities.TIER.power[hi] / Abilities.TIER.power[lo]) * 0.6, string.format("%s slot: a typical %s move hits %.1fx a typical %s move", slot, Abilities.TIER_LETTER[hi], medHi / medLo, Abilities.TIER_LETTER[lo]))
	end
	local castOk = true
	for t = 2, 6 do
		local a, b = median(byTier[t - 1].cast), median(byTier[t].cast)
		if a and b and b < a then
			castOk = false
		end
	end
	check(castOk, slot .. " slot: cast times never shrink with tier")
end
check(Abilities.SLOT_BASE.Q.cast == 0 and Abilities.byId.cleave.cast == 0, "quick moves are instant")
check(Abilities.TIER.power[6] / Abilities.TIER.power[1] >= 3, "an S move does at least three times what an E move of its slot and shape does")
local tiersBySlot = {}
for _, ab in Abilities.list do
	tiersBySlot[ab.slot] = tiersBySlot[ab.slot] or {}
	tiersBySlot[ab.slot][ab.tier] = true
end
for _, slot in Abilities.SLOTS do
	local n = 0
	for _ in tiersBySlot[slot] or {} do
		n += 1
	end
	check(n >= (if slot == "G" then 3 else 5), string.format("%s slot has moves at %d of the six tiers", slot, n))
end
local pool1, regen1 = Abilities.manaPool(1, 10, 10)
local pool6, regen6 = Abilities.manaPool(6, 10, 10)
check(pool6 > pool1 * 5 and regen6 > regen1, string.format("a mana pool grows with rank (E %d, S %d)", pool1, pool6))
local ultS = Abilities.byId.inferno
check(ultS.mana < pool6 and ultS.mana > pool1, "an S ultimate costs more than an E-rank pool, and less than an S-rank one")

-- ── the effects ──
local REAL = setmetatable({}, { __mode = "k" })
local REMOTE: any, METHODS: any = {}, {}
local OURS = setmetatable({}, { __mode = "k" }) -- coroutines the test started (they may yield)
local function unwrap(v)
	return REAL[v] or v
end
local signal = { Connect = function()
	return { Disconnect = function() end, Connected = true }
end }
local emitted = 0
-- (@lune/roblox has real classes and properties but no events and no Emit: a thin proxy answers those)
local EVENTS = { Activated = true, MouseButton1Click = true, MouseEnter = true, MouseLeave = true, Changed = true, FocusLost = true, Died = true, Running = true, StateChanged = true, Triggered = true, DescendantAdded = true }
-- what the server says to clients, and the handler it listens with (the live server test)
local serverLog = { all = {}, one = {}, onServer = nil }
REMOTE = {
	FireAllClients = function(_, data)
		table.insert(serverLog.all, data)
	end,
	FireClient = function(_, _player, data)
		table.insert(serverLog.one, data)
	end,
	OnServerEvent = { Connect = function(_, fn)
		serverLog.onServer = fn
		return { Disconnect = function() end, Connected = true }
	end },
}
METHODS = {
	PivotTo = function(model, cf)
		local pp = model.PrimaryPart
		if pp then
			local delta = cf * pp.CFrame:Inverse()
			for _, d in model:GetDescendants() do
				if d:IsA("BasePart") then
					d.CFrame = delta * d.CFrame
				end
			end
		end
	end,
	GetPivot = function(model)
		return if model.PrimaryPart then model.PrimaryPart.CFrame else roblox.CFrame.new()
	end,
	MoveTo = function() end,
	SetNetworkOwner = function() end,
	TakeDamage = function(hum, n)
		hum.Health = math.max(0, hum.Health - n)
	end,
	LoadAnimation = function()
		return { Play = function() end, Stop = function() end, AdjustSpeed = function() end, Looped = false }
	end,
}
local wrap
-- anything an instance hands back (a child found, a part's parent, a method's result) is wrapped too
local function wrapOut(v: any): any
	if typeof(v) == "Instance" then
		return wrap(v)
	elseif type(v) == "table" and getmetatable(v) == nil then
		local out = {}
		for k, x in v do
			out[k] = if typeof(x) == "Instance" then wrap(x) else x
		end
		return out
	end
	return v
end
local function wrapAll(...)
	local out = table.pack(...)
	for i = 1, out.n do
		out[i] = wrapOut(out[i])
	end
	return table.unpack(out, 1, out.n)
end
local PROXY_META_EQ = function(a, b)
	return unwrap(a) == unwrap(b)
end
function wrap(real)
	local proxy = {}
	REAL[proxy] = real
	return setmetatable(proxy, {
		__eq = PROXY_META_EQ,
		__index = function(_, k)
			if k == "Emit" then
				return function(_, n)
					emitted += n or 0
				end
			end
			if EVENTS[k] then
				return signal
			end
			if k == "GetPropertyChangedSignal" or k == "GetAttributeChangedSignal" then
				return function()
					return signal
				end
			end
			if REMOTE[k] then
				return REMOTE[k]
			end
			-- (offline a part's Position isn't worked out from its CFrame: the engine does it)
			if k == "Position" and real:IsA("BasePart") then
				return real.CFrame.Position
			end
			local okGet, v = pcall(function()
				return real[k]
			end)
			if not okGet then
				-- methods the engine has and @lune/roblox doesn't (moving models, humanoids, remotes)
				local stub = METHODS[k]
				if stub then
					return function(_, ...)
						local args = table.pack(...)
						for i = 1, args.n do
							args[i] = unwrap(args[i])
						end
						return wrapAll(stub(real, table.unpack(args, 1, args.n)))
					end
				end
				error(v, 2)
			end
			if type(v) == "function" then
				return function(_, ...)
					local args = table.pack(...)
					for i = 1, args.n do
						args[i] = unwrap(args[i])
					end
					return wrapAll(v(real, table.unpack(args, 1, args.n)))
				end
			end
			return wrapOut(v)
		end,
		__newindex = function(_, k, v)
			if k == "Position" and real:IsA("BasePart") then
				local cf = real.CFrame
				real.CFrame = roblox.CFrame.new(v) * (cf - cf.Position)
				return
			end
			real[k] = unwrap(v)
		end,
	})
end
local ProxyInstance = { new = function(className, parent)
	local r = I.new(className)
	if parent then
		r.Parent = unwrap(parent)
	end
	return wrap(r)
end }
local queue = {}
local tweenErrors = {}
local warnings = {}
Loader.globals = {
	Instance = ProxyInstance, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font,
	NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, NumberRange = roblox.NumberRange,
	ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	TweenInfo = { new = function(...)
		return { ... }
	end },
	warn = function(...)
		table.insert(warnings, table.concat({ ... }, " "))
	end,
	task = {
		spawn = function(f, ...)
			f(...)
		end,
		defer = function(f, ...)
			f(...)
		end,
		delay = function(t, f, ...)
			table.insert(queue, { t = t, f = f, args = table.pack(...) })
		end,
		wait = function()
			return 0
		end,
	},
	game = { GetService = function(_, name)
		if name == "ReplicatedStorage" then
			return { WaitForChild = function()
				return shared
			end }
		elseif name == "TweenService" then
			return { Create = function(_, inst, _info, goals)
				-- set the goals on the real instance at once: every name and type is checked
				local real = unwrap(inst)
				for k, v in goals do
					local ok, err = pcall(function()
						real[k] = v
					end)
					if not ok then
						table.insert(tweenErrors, real.ClassName .. "." .. tostring(k) .. ": " .. tostring(err))
					end
				end
				return { Play = function() end, Cancel = function() end, Completed = signal }
			end }
		elseif name == "Debris" then
			return { AddItem = function(_, inst, t)
				unwrap(inst):SetAttribute("Debris", t)
			end }
		elseif name == "RunService" then
			return { RenderStepped = signal, Heartbeat = signal }
		end
		return {}
	end },
}
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local okLoad, SkillFx = pcall(Loader.require, client.SkillFx)
check(okLoad, "client/SkillFx loads", SkillFx)
if not okLoad then
	process.exit(1)
end
local root = I.new("Folder")
local shaken = 0
SkillFx.init({
	root = root,
	me = 1,
	shake = function(_at, amount)
		shaken = math.max(shaken, amount)
	end,
	sound = function() end,
	characterOf = function()
		return nil
	end,
})
local function flush()
	local n = 0
	while #queue > 0 and n < 20000 do
		table.sort(queue, function(a, b)
			return a.t < b.t
		end)
		local job = table.remove(queue, 1)
		job.f(table.unpack(job.args, 1, job.args.n))
		n += 1
	end
	return n
end
local function message(ab: any): any
	local P = function(x, y, z)
		return { x, y, z }
	end
	return {
		fx = "ability", ability = ab.id, element = ab.element, kind = ab.kind, shape = ab.shape, tier = ab.tier, slot = ab.slot,
		player = 1, rank = 6, at = P(0, 3, 0), dir = P(0, 0, -1), floor = 0,
		radius = ab.radius, range = ab.range, duration = ab.duration,
		to = P(0, 3, -22), from = P(0, 3, 0), target = P(0, 3, -22),
		targets = { P(4, 3, -16), P(-5, 3, -20), P(1, 3, -28) },
		healed = { P(0, 3, 0), P(5, 3, 3) }, allies = { P(0, 3, 0), P(5, 3, 3) },
		hits = ab.hits or 3, style = ab.construct and ab.construct.style,
	}
end
local function measure(fn): (boolean, any, number, number)
	SkillFx.made = 0
	emitted = 0
	local ok, err = pcall(fn)
	flush()
	return ok, err, SkillFx.made, emitted
end
local fxFails, heavy, maxParts, maxId, particles = {}, {}, 0, "", 0
for _, ab in Abilities.list do
	if not SkillFx.has(ab.id) then
		table.insert(fxFails, ab.id .. " (no effect)")
	end
	if ab.sig and not SkillFx.EFFECTS[ab.fx] then
		table.insert(fxFails, ab.id .. " (signature effect missing)")
	end
	local before = #warnings
	local played = false
	local ticking = ab.kind == "construct"
	local ok, err, made, emits = measure(function()
		played = SkillFx.play(message(ab))
		if ticking then
			-- the server's ticks: it walks, strikes, and goes
			SkillFx.tick({ fx = "abilityTick", ability = ab.id, player = 1, at = { 3, 3, -10 }, to = { 4, 3, -14 }, hit = true, floor = 0 })
			SkillFx.tick({ fx = "abilityTick", ability = ab.id, player = 1, at = { 6, 3, -14 }, floor = 0 })
			SkillFx.tick({ fx = "abilityTick", ability = ab.id, player = 1, done = true })
		end
	end)
	if not ok or not played or #warnings > before then
		table.insert(fxFails, ab.id .. ": " .. tostring(err or warnings[#warnings] or "didn't play"))
	end
	if made == 0 then
		table.insert(fxFails, ab.id .. " (drew nothing)")
	end
	particles += emits
	if made > maxParts then
		maxParts, maxId = made, ab.id
	end
	if made > SkillFx.MAX_PARTS then
		table.insert(heavy, ab.id .. "=" .. made)
	end
	-- a storm's bolts come with the server's ticks
	if ab.shape == "storm" then
		local okT, errT, madeT = measure(function()
			SkillFx.tick({ fx = "abilityTick", ability = ab.id, player = 1, at = { 0, 3, -20 }, floor = 0, targets = { { 2, 3, -12 }, { -3, 3, -18 } } })
		end)
		if not okT or #warnings > before then
			table.insert(fxFails, ab.id .. " tick: " .. tostring(errT or warnings[#warnings]))
		end
		if madeT == 0 then
			table.insert(fxFails, ab.id .. " tick drew nothing")
		end
	end
	if ab.cast > 0 then
		local okC, errC = measure(function()
			SkillFx.cast({ fx = "abilityCast", ability = ab.id, element = ab.element, tier = ab.tier, player = 1, at = { 0, 3, 0 }, cast = ab.cast, floor = 0 })
		end)
		if not okC or #warnings > before then
			table.insert(fxFails, ab.id .. " cast: " .. tostring(errC or warnings[#warnings]))
		end
	end
end
check(#fxFails == 0, string.format("every move's effect runs on real Roblox instance types (%d moves)", #Abilities.list), table.concat(fxFails, "; ", 1, math.min(#fxFails, 8)))
check(#tweenErrors == 0, "every tween's goals are real properties of the right type", table.concat(tweenErrors, "; ", 1, math.min(#tweenErrors, 6)))
check(#heavy == 0, string.format("every effect stays under %d parts (the biggest: %s, %d)", SkillFx.MAX_PARTS, maxId, maxParts), table.concat(heavy, ", "))
check(particles > #Abilities.list * 10, string.format("the effects emit particles (%d in all)", particles))
check(shaken > 1, "big moves shake the camera")
-- everything made is cleaned up: each part in the folder is Debris'd (or already gone)
local loose = {}
for _, c in root:GetChildren() do
	if type(c:GetAttribute("Debris")) ~= "number" then
		table.insert(loose, c.ClassName .. " " .. c.Name)
	end
	if c:IsA("BasePart") and (c.Anchored ~= true or c.CanCollide ~= false) then
		table.insert(loose, "a part that isn't anchored and non-colliding")
	end
end
check(#loose == 0, string.format("every one of the %d effect parts is anchored, non-colliding and handed to Debris", #root:GetChildren()), table.concat(loose, ", ", 1, math.min(#loose, 6)))
-- a crowded folder draws less
for _ = 1, 460 do
	I.new("Part").Parent = root
end
local _, _, crowdedParts = measure(function()
	SkillFx.play(message(Abilities.byId.ring_of_fire))
end)
root:ClearAllChildren()
local _, _, calmParts = measure(function()
	SkillFx.play(message(Abilities.byId.ring_of_fire))
end)
check(crowdedParts < calmParts, string.format("a crowded effect folder draws about half (%d parts, not %d)", crowdedParts, calmParts))
-- an unknown move or a bad message draws nothing and doesn't throw
check(SkillFx.play({ ability = "not_a_move" }) == false and SkillFx.play(nil) == false, "an unknown move draws nothing")


-- ── the walk HUD: the skill bar, the mana bar and the loadout panel build and work ──
do
	-- coroutines for spawned loops (the HUD's refresh loop runs a step each time it's resumed)
	local threads = {}
	local T = Loader.globals.task
	T.spawn = function(f, ...)
		local co = coroutine.create(f)
		table.insert(threads, co)
		OURS[co] = true
		local ok, err = coroutine.resume(co, ...)
		if not ok then
			error(err, 0)
		end
		return co
	end
	T.wait = function()
		-- (only the loops this test started yield; the main thread never does)
		if OURS[coroutine.running()] then
			coroutine.yield()
		end
		return 0
	end
	local captured = { client = nil, input = nil, charAdded = nil, rendered = {} }
	local fired = {}
	local function capture(key)
		return { Connect = function(_, fn)
			if key == "rendered" then
				table.insert(captured.rendered, fn)
			else
				captured[key] = fn
			end
			return { Disconnect = function() end, Connected = true }
		end }
	end
	local playerGui = I.new("PlayerGui")
	local lighting = I.new("Lighting")
	-- (offline, Lighting has no defaults until they're set)
	lighting.ClockTime = 14
	lighting.Brightness = 2
	lighting.FogEnd = 100000
	lighting.FogStart = 0
	local workspace = I.new("Workspace")
	local sampleBar = nil
	local localPlayer = { UserId = 1, Name = "Tester", DisplayName = "Tester", Character = nil, CharacterAdded = capture("charAdded") }
	function localPlayer:WaitForChild()
		return playerGui
	end
	local request = { InvokeServer = function(_, action, payload)
		if action == "hwSkillBar" then
			if type(payload) == "table" and payload.slot then
				sampleBar.slots[payload.slot] = payload.id or sampleBar.slots[payload.slot]
			end
			return { ok = true, bar = sampleBar }
		elseif action == "hwLive" then
			return { ok = true, incidents = {} }
		end
		return { ok = false }
	end }
	local remoteEvent = { OnClientEvent = capture("client"), FireServer = function(_, action, data)
		table.insert(fired, { action = action, data = data })
	end }
	Loader.attach(shared, "Remotes", { WaitForChild = function(_, name)
		return if name == "Request" then request else remoteEvent
	end })
	Loader.globals.RaycastParams = { new = function()
		return {}
	end }
	local services = {
		Players = { LocalPlayer = localPlayer, GetPlayerByUserId = function()
			return localPlayer
		end, GetPlayers = function()
			return { localPlayer }
		end },
		RunService = { RenderStepped = capture("rendered"), Heartbeat = signal },
		UserInputService = { InputBegan = capture("input"), MouseEnabled = false, TouchEnabled = true, KeyboardEnabled = true, GetMouseLocation = function()
			return roblox.Vector2.new(0, 0)
		end },
		Lighting = lighting,
		Workspace = wrap(workspace),
		ProximityPromptService = { PromptShown = signal, PromptHidden = signal },
	}
	local oldGet = Loader.globals.game.GetService
	Loader.globals.game.GetService = function(self, name)
		return services[name] or oldGet(self, name)
	end
	local okLive, HunterLive = pcall(Loader.require, client.HunterLive)
	check(okLive, "client/HunterLive loads with the skill bar", HunterLive)
	local okStart, errStart = pcall(function()
		HunterLive.start({ backdrops = {} })
	end)
	check(okStart, "the live city's client starts (dock, walk HUD, skill bar, loadout panel)", errStart)
	if okStart then
		-- a fighter at B-rank with a few skills
		local set = { sk_power_strike = true, sk_whirlwind = true, sk_shoulder_charge = true, sk_fire_fireball = true, sk_fire_ring = true }
		local unlocked, locked = {}, {}
		for _, ab in Abilities.forClass("fighter") do
			local why = Abilities.lockReason(ab, "fighter", set, 4, function(id)
				return Skills.traits[id] and Skills.traits[id].name
			end)
			if why then
				locked[ab.id] = why
			else
				table.insert(unlocked, ab.id)
			end
		end
		sampleBar = { class = "fighter", rank = 4, slots = Abilities.resolveBar("fighter", nil, set, 4), unlocked = unlocked, locked = locked, learned = 3 }
		local R6Rig = Loader.require(shared.Hunter.R6Rig)
		local Looks = Loader.require(shared.Hunter.Looks)
		local rig = R6Rig.build(Looks.DEFAULT, { name = "Tester", rank = 4 })
		rig:SetAttribute("HunterLive", true)
		local hum = rig:FindFirstChildOfClass("Humanoid")
		hum.MaxHealth = 420
		hum.Health = 300
		hum.CameraOffset = roblox.Vector3.zero
		rig:SetAttribute("Rank", 4)
		rig:SetAttribute("Class", "fighter")
		rig:SetAttribute("Mana", 200)
		rig:SetAttribute("ManaMax", 320)
		rig:SetAttribute("ManaRegen", 12.8)
		for slot, id in sampleBar.slots do
			rig:SetAttribute("AbilityId" .. slot, id)
		end
		localPlayer.Character = rig
		local okRun, errRun = pcall(function()
			if captured.charAdded then
				captured.charAdded(rig)
			end
			captured.client({ walk = true })
			captured.client({ bar = sampleBar })
			captured.client({ cooldown = { slot = "R", left = 6, id = sampleBar.slots.R }, mana = { cur = 200, max = 320, regen = 12.8 } })
			-- the HUD's refresh loop and a few frames
			for _ = 1, 3 do
				for _, co in threads do
					if coroutine.status(co) == "suspended" then
						local ok, err = coroutine.resume(co)
						if not ok then
							error(err, 0)
						end
					end
				end
				for _, fn in captured.rendered do
					fn(1 / 60)
				end
			end
		end)
		check(okRun, "walking: the HUD takes the bar, a cooldown and mana, and refreshes", errRun)
		local bar = playerGui:FindFirstChild("SkillBar", true)
		local slotsFound = 0
		for _, slot in Abilities.SLOTS do
			if bar and bar:FindFirstChild("Slot" .. slot) then
				slotsFound += 1
			end
		end
		check(bar ~= nil and bar.Visible and slotsFound == 5, "the skill bar shows five slot buttons (Q E R T G)")
		local qName = ""
		local qButton = bar and bar:FindFirstChild("SlotQ")
		for _, d in (qButton and qButton:GetDescendants()) or {} do
			if d:IsA("TextLabel") and d.Text == Abilities.byId[sampleBar.slots.Q].name then
				qName = d.Text
			end
		end
		check(qName ~= "", "the Q button names its move (" .. tostring(sampleBar.slots.Q) .. ")")
		local rSweep = false
		for _, d in (bar and bar:FindFirstChild("SlotR") and bar.SlotR:GetDescendants()) or {} do
			if d:IsA("Frame") and d.ZIndex == 3 and d.Size.Y.Scale > 0 then
				rSweep = true
			end
		end
		check(rSweep, "a slot on cooldown shows its sweep")
		local manaText = false
		for _, d in playerGui:GetDescendants() do
			if d:IsA("TextLabel") and string.find(d.Text, "MANA %d+ / 320") then
				manaText = true
			end
		end
		check(manaText, "the walk HUD shows a mana bar")
		-- the loadout panel
		local okOpen, errOpen = pcall(function()
			HunterLive.openLoadout()
		end)
		local panel = playerGui:FindFirstChild("Loadout", true)
		local function rows(): number
			local n = 0
			local list = panel and panel:FindFirstChildOfClass("ScrollingFrame") and nil
			for _, d in (panel and panel:GetDescendants()) or {} do
				if d:IsA("Frame") and d.Size.Y.Offset == 62 then
					n += 1
				end
			end
			local _ = list
			return n
		end
		local before = rows()
		check(okOpen and panel ~= nil and panel.Visible and before > 0, string.format("the loadout panel opens and lists the Q moves (%d)", before), errOpen)
		local box = panel and panel:FindFirstChildOfClass("TextBox")
		if box then
			box.Text = "fire"
		end
		local okSearch, errSearch = pcall(function()
			HunterLive.openLoadout() -- (closes)
			HunterLive.openLoadout() -- (opens again, with the search)
		end)
		local after = rows()
		check(okSearch and after > 0 and after < before, string.format("searching narrows the list (%d to %d)", before, after), errSearch)
		-- a key press uses the slot
		local okKey, errKey = pcall(function()
			captured.input({ KeyCode = roblox.Enum.KeyCode.Q, UserInputType = roblox.Enum.UserInputType.Keyboard }, false)
		end)
		local sent = nil
		for _, f in fired do
			if f.action == "skill" then
				sent = f.data
			end
		end
		check(okKey and sent ~= nil and sent.slot == "Q", "pressing Q asks the server to use the Q slot", errKey)
		fired = {}
		pcall(function()
			captured.input({ KeyCode = roblox.Enum.KeyCode.Q, UserInputType = roblox.Enum.UserInputType.Keyboard }, false)
		end)
		local again = false
		for _, f in fired do
			if f.action == "skill" then
				again = true
			end
		end
		check(not again, "a slot on cooldown doesn't fire again")
	end
end

-- ── the server: every move, cast for real in the live city (server/HunterLive) ──
-- The live server is installed on real instances with stubbed services and a clock the test
-- moves; a Hunter of each class walks in with every skill at S-rank, monsters stand in front,
-- and every move the class can reach is put in its slot and used. Each must be resolved
-- without an error, tell everyone to draw it, and (if it does damage) hurt something.
do
	process.env.LIFESIM_PACK = "BitLeveling"
	local Config = Loader.require(shared.Config)
	Config.pack = "BitLeveling"
	Config.hunterLive = Config.hunterLive or {}
	Config.hunterLive.civilians = 2
	Config.hunterLive.firstDelay = 1e9
	local Engine = Loader.require(shared.Engine)
	local pack = Loader.pack(shared)
	local sim = Engine.Sim.new(pack)
	local fakeNow = 1000
	Loader.globals.os = setmetatable({ clock = function()
		return fakeNow
	end }, { __index = os })
	local T = Loader.globals.task
	local spawnErrors = {}
	T.spawn = function(f, ...)
		local co = coroutine.create(f)
		OURS[co] = true
		local ok, err = coroutine.resume(co, ...)
		if not ok then
			table.insert(spawnErrors, tostring(err))
		end
		return co
	end
	local function serviceProxy(real: any, extra: any): any
		local proxy = setmetatable({}, { __index = function(_, k)
			if extra[k] ~= nil then
				return extra[k]
			end
			local v = real[k]
			if type(v) == "function" then
				return function(_, ...)
					return v(real, ...)
				end
			end
			return v
		end })
		REAL[proxy] = real
		return proxy
	end
	local rsReal = I.new("Folder")
	local remotes = I.new("Folder")
	remotes.Name = "Remotes"
	Loader.attach(shared, "Remotes", remotes)
	local wsReal = I.new("Workspace")
	local serverPlayer: any = { UserId = 7, Name = "Hunter", DisplayName = "Hunter", Parent = wsReal, Character = nil }
	local heartbeat = nil
	local services = {
		Players = { GetPlayers = function()
			return { serverPlayer }
		end, PlayerRemoving = signal, PlayerAdded = signal },
		ReplicatedStorage = serviceProxy(rsReal, { WaitForChild = function(_, _name)
			return shared
		end }),
		RunService = { Heartbeat = { Connect = function(_, fn)
			heartbeat = fn
			return { Disconnect = function() end }
		end }, RenderStepped = signal, IsStudio = function()
			return false
		end },
		InsertService = {},
		TextService = {},
		Workspace = serviceProxy(wsReal, { Raycast = function()
			return nil
		end }),
	}
	Loader.globals.game.GetService = function(_, name)
		return services[name] or {}
	end
	Loader.globals.Random = { new = function(seed)
		local st = { s = (seed or 7) % 2147483647 + 1 }
		function st:NextNumber(a, b)
			self.s = (self.s * 48271) % 2147483647
			return (a or 0) + self.s / 2147483647 * ((b or 1) - (a or 0))
		end
		function st:NextInteger(a, b)
			return a + math.floor(self:NextNumber() * (b - a + 1))
		end
		return st
	end }
	local server = Loader.preload(Loader.node("src/server", "Server", nil))
	local okReq, Live = pcall(Loader.require, server.HunterLive)
	check(okReq, "server/HunterLive loads", Live)
	local all = {}
	for id, def in Skills.traits do
		if type(def) == "table" and def.category == "skill" then
			table.insert(all, id)
		end
	end
	local life: any = {
		alive = true, form = "hunter_s", age = 30, year = 10, flags = {}, traits = all, gear = {},
		stats = { strength = 260, agility = 260, intelligence = 300, vitality = 300, willpower = 260, charisma = 60, luck = 12 },
	}
	local session = { profile = { Data = { life = life } } }
	local S = {
		Content = pack, sim = sim, Engine = Engine, Config = Config, handlers = {},
		sessions = { [serverPlayer] = session },
		pushTo = function() end,
		lifeResponse = function()
			return { ok = true }
		end,
	}
	local okInstall, errInstall = false, nil
	if okReq then
		okInstall, errInstall = pcall(Live.install, S)
	end
	check(okInstall and serverLog.onServer ~= nil and heartbeat ~= nil, "the live server installs and listens", errInstall)
	if okInstall and serverLog.onServer and heartbeat then
		local Npcs = Loader.require(server.HunterLive.Npcs)
		local bad, silent, harmless, casts, ticks = {}, {}, {}, 0, 0
		local before = #warnings
		for _, class in Abilities.CLASSES do
			life.flags = { ["class_" .. class] = true }
			session.profile.Data.hlBar = nil
			local okWalk, errWalk = pcall(S.handlers.hwWalk, serverPlayer, session, { on = true })
			local ch = serverPlayer.Character
			if not okWalk or not ch then
				table.insert(bad, class .. " walk: " .. tostring(errWalk))
				continue
			end
			local hum = ch:FindFirstChildOfClass("Humanoid")
			hum.HipHeight = 0
			local root = ch:FindFirstChild("HumanoidRootPart")
			local home = roblox.CFrame.new(0, 3, 0)
			-- the bar the server offers this class: everything visible should be unlocked
			local view = S.handlers.hwSkillBar(serverPlayer, session, nil)
			local reach = #Abilities.forClass(class)
			if not (view and view.bar and #view.bar.unlocked >= reach * 0.9) then
				table.insert(bad, class .. ": only " .. tostring(view and view.bar and #view.bar.unlocked) .. " of " .. reach .. " unlocked at S-rank with every skill")
			end
			-- monsters in front of the Hunter (and one behind)
			for _, m in table.clone(Npcs.monsters) do
				Npcs.removeMonster(m)
			end
			local spots = { roblox.Vector3.new(0, 0, -9), roblox.Vector3.new(-4, 0, -15), roblox.Vector3.new(5, 0, -21), roblox.Vector3.new(0, 0, -30), roblox.Vector3.new(2, 0, 6) }
			local mons = {}
			for i, at in spots do
				table.insert(mons, Npcs.spawnMonster(6, at, 1, if i % 2 == 0 then "colossus" else "dragonkin"))
			end
			for _, ab in Abilities.forClass(class) do
				-- put it in its slot (through the handler, as the loadout panel does)
				local res = S.handlers.hwSkillBar(serverPlayer, session, { slot = ab.slot, id = ab.id })
				if not (res and res.ok) then
					table.insert(bad, class .. "/" .. ab.id .. " equip: " .. tostring(res and res.error))
					continue
				end
				fakeNow += 200 -- cooldowns pass, mana refills
				for i, m in mons do
					m.hum.Health = m.hum.MaxHealth
					m.model:PivotTo(roblox.CFrame.new(spots[i] + roblox.Vector3.new(0, 4 * m.def.size + 1, 0)))
				end
				ch:PivotTo(home)
				hum.Health = hum.MaxHealth * 0.5
				local nAll = #serverLog.all
				local okCast, errCast = pcall(serverLog.onServer, serverPlayer, "skill", { slot = ab.slot, aim = { 0, 3, -18 } })
				-- a cast time, projectiles in flight, delayed blows; then the zones and constructs work
				flush()
				for _ = 1, 40 do
					fakeNow += 0.25
					heartbeat(0.25)
					flush()
				end
				casts += 1
				if not okCast then
					table.insert(bad, ab.id .. ": " .. tostring(errCast))
				end
				local drew, hit = false, false
				for k = nAll + 1, #serverLog.all do
					local d = serverLog.all[k]
					if d.fx == "ability" and d.ability == ab.id then
						drew = true
						if (d.hits or 0) > 0 then
							hit = true
						end
					elseif d.fx == "abilityTick" and d.ability == ab.id then
						ticks += 1
					end
				end
				for _, m in mons do
					if m.hum.Health < m.hum.MaxHealth then
						hit = true
					end
				end
				if not drew then
					table.insert(silent, ab.id)
				end
				if ab.mult > 0 and not hit then
					table.insert(harmless, class .. "/" .. ab.id)
				end
				if #warnings > before then
					table.insert(bad, ab.id .. " warned: " .. warnings[#warnings])
					before = #warnings
				end
			end
			pcall(S.handlers.hwWalk, serverPlayer, session, { on = false })
		end
		check(#bad == 0 and #spawnErrors == 0, string.format("every move resolves on the server, for every class that can reach it (%d casts)", casts), table.concat(bad, "; ", 1, math.min(#bad, 6)) .. table.concat(spawnErrors, "; ", 1, math.min(#spawnErrors, 3)))
		check(#silent == 0, "every cast tells everyone to draw it", table.concat(silent, ", ", 1, math.min(#silent, 10)))
		check(#harmless == 0, "every move that does damage hurts a monster in front of it", table.concat(harmless, ", ", 1, math.min(#harmless, 12)))
		check(ticks > 0, string.format("constructs and storms report their steps (%d ticks)", ticks))
		-- a cooldown holds: the same move twice in a row goes off once
		life.flags = { class_mage = true }
		pcall(S.handlers.hwWalk, serverPlayer, session, { on = true })
		session.profile.Data.hlBar = { G = "cataclysm" }
		fakeNow += 500
		local nOne = #serverLog.one
		for _ = 1, 6 do
			serverLog.onServer(serverPlayer, "skill", { slot = "G" })
			fakeNow += 0.3
		end
		local cooled = 0
		for k = nOne + 1, #serverLog.one do
			if serverLog.one[k].cooldown then
				cooled += 1
			end
		end
		check(cooled == 1, "a move on cooldown can't be cast again (" .. cooled .. " of 6 went off)")
		-- mana: an E-rank Mage using every slot as fast as the cooldowns allow runs dry, and is told
		life.form = "hunter_e"
		life.stats.intelligence, life.stats.willpower = 0, 0
		session.profile.Data.hlBar = nil
		pcall(S.handlers.hwWalk, serverPlayer, session, { on = true })
		fakeNow += 500
		local nTwo = #serverLog.one
		for _ = 1, 60 do
			for _, slot in Abilities.SLOTS do
				serverLog.onServer(serverPlayer, "skill", { slot = slot })
				fakeNow += 0.2
			end
			flush()
		end
		local refused, went = false, 0
		for k = nTwo + 1, #serverLog.one do
			if serverLog.one[k].noMana then
				refused = true
			elseif serverLog.one[k].cooldown then
				went += 1
			end
		end
		check(refused and went > 3, string.format("an E-rank pool runs dry and the cast is refused (%d casts went off first)", went))
		local ch2 = serverPlayer.Character
		check(ch2 and type(ch2:GetAttribute("ManaMax")) == "number" and ch2:GetAttribute("ManaMax") == Abilities.manaPool(1, 0, 0), "the character carries its mana pool for the HUD")
		life.stats.intelligence, life.stats.willpower = 300, 260
		-- an E-rank Hunter can't use an S-rank move, even if it's saved in the slot
		life.form = "hunter_e"
		session.profile.Data.hlBar = { G = "cataclysm" }
		local res = S.handlers.hwSkillBar(serverPlayer, session, { slot = "G", id = "cataclysm" })
		check(res and res.ok == false, "the loadout refuses a move above the Hunter's rank")
		life.form = "hunter_s"
	end
	Loader.globals.os = nil
end

print(string.format("\n%d moves: %s", #Abilities.list, (function()
	local per = {}
	for _, class in Abilities.CLASSES do
		local n = 0
		for _, ab in Abilities.list do
			if ab.class == class then
				n += 1
			end
		end
		table.insert(per, class .. " " .. n)
	end
	return table.concat(per, ", ")
end)()))
print("abilities_check: finished, " .. fails .. " failed")
if fails > 0 then
	process.exit(1)
end
