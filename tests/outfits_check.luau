--[[
	OUTFITS, ROBES, ACCESSORIES AND THE CREATOR (BitLeveling): every option of every look field
	builds on a real R6 rig (@lune/roblox: real classes and property names), every preset is a
	valid look that builds, old saves still load, every accessory builds and is scaled by its
	grade, the accessories' gear passes the game's validator, part counts stay in budget,
	civilians never get combat gear, faces stay visible, and the creator opens on every tab.
		lune run tests/outfits_check            (add `-- report` for the heaviest rigs, piece by piece)
]]
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")
local I = roblox.Instance

-- (`-- creator`: only the creator, every tab and every shelf, on proxied GUI instances like
-- tests/live_ui_check; the main run starts this)
if table.find(process.args, "creator") then
	local failures = 0
	local function check(ok: boolean, msg: string, detail: any?)
		print((if ok then "  ok    " else "  FAIL  ") .. msg .. (if ok or detail == nil then "" else ": " .. tostring(detail)))
		if not ok then
			failures += 1
		end
	end
	local function first(list: { string }, n: number?): string
		local out = {}
		for i = 1, math.min(#list, n or 6) do
			out[i] = list[i]
		end
		return table.concat(out, "; ")
	end
	local Looks
	local signalStub = { Connect = function()
		return { Disconnect = function() end, Connected = true }
	end }
	local REAL = setmetatable({}, { __mode = "k" })
	local function unwrap(v)
		return REAL[v] or v
	end
	local EVENTS = { Activated = true, MouseEnter = true, MouseLeave = true, MouseButton1Click = true, MouseButton1Down = true, InputBegan = true, InputChanged = true, InputEnded = true, MouseWheelForward = true, MouseWheelBackward = true, Changed = true }
	local function wrap(real)
		local proxy = {}
		REAL[proxy] = real
		return setmetatable(proxy, {
			__index = function(_, k)
				if EVENTS[k] then
					return signalStub
				end
				if k == "GetPropertyChangedSignal" then
					return function()
						return signalStub
					end
				end
				local v = real[k]
				if type(v) == "function" then
					return function(_, ...)
						local args = table.pack(...)
						for i = 1, args.n do
							args[i] = unwrap(args[i])
						end
						return v(real, table.unpack(args, 1, args.n))
					end
				end
				return v
			end,
			__newindex = function(_, k, v)
				real[k] = unwrap(v)
			end,
		})
	end
	local ProxyInstance = { new = function(className, parent)
		local r = roblox.Instance.new(className)
		if parent then
			r.Parent = unwrap(parent)
		end
		return wrap(r)
	end }
	local hairCache = I.new("Folder")
	local g = table.clone(Loader.globals)
	for k, v in { UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3, CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font, ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint, NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, NumberRange = roblox.NumberRange } do
		g[k] = v
	end
	g.Instance = ProxyInstance
	g.TweenInfo = { new = function(...)
		return { ... }
	end }
	g.task = { spawn = function(f, ...)
		f(...)
	end, delay = function() end, wait = function()
		return 0
	end, defer = function(f, ...)
		f(...)
	end }
	local shared2 -- (the shared modules again, making proxied instances)
	g.game = { GetService = function(_, name)
		if name == "ReplicatedStorage" then
			return { WaitForChild = function(_, child)
				if child == "HunterHairCache" then
					return hairCache
				end
				return shared2
			end }
		elseif name == "RunService" then
			return { RenderStepped = signalStub, Heartbeat = signalStub }
		elseif name == "UserInputService" then
			return { InputChanged = signalStub, InputEnded = signalStub, TouchPinch = signalStub, TouchEnabled = false }
		elseif name == "TweenService" then
			return { Create = function()
				return { Play = function() end }
			end }
		end
		return {}
	end }
	Loader.globals = g
	shared2 = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
	local client = Loader.preload(Loader.node("src/client", "Client", nil))
	local Creator = Loader.require(client.UI.R6Creator)
	Looks = Loader.require(shared2.Hunter.Looks)
	local cR6 = Loader.require(shared2.Hunter.R6Rig)
	local saved = nil
	local function call(action, payload)
		if action == "r6Get" then
			return { ok = true, look = { skin = "tan", top = "robe", gloves = true }, rank = 5, class = "mage" }
		elseif action == "r6Save" then
			saved = payload and payload.look
			return { ok = true, look = Looks.clean(saved) }
		end
		return { ok = true }
	end
	local bad = {}
	local opened = 0
	for _, tab in Looks.TABS do
		local cats = if tab.presets then Looks.CATEGORIES else { { id = "" } }
		for _, cat in cats do
			local gui = ProxyInstance.new("ScreenGui")
			local ok, err = pcall(Creator.open, gui, call, cR6, { tab = tab.id, cat = cat.id })
			if ok then
				opened += 1
				local n = 0
				for _, d in unwrap(gui):GetDescendants() do
					if d:IsA("GuiObject") then
						n += 1
					end
				end
				if n < 40 then
					table.insert(bad, tab.id .. "/" .. cat.id .. " is nearly empty (" .. n .. ")")
				end
			else
				table.insert(bad, tab.id .. "/" .. cat.id .. ": " .. tostring(err))
			end
			pcall(Creator.close)
		end
	end
	check(#bad == 0, string.format("the creator opens on every tab and every preset shelf (%d screens)", opened), first(bad))
	local ok3, err3 = pcall(Creator.open, ProxyInstance.new("ScreenGui"), call, cR6)
	check(ok3, "Creator.open(gui, call, R6Rig) still works with three arguments", err3)
	pcall(Creator.close)
	process.exit(if failures > 0 then 1 else 0)
end

local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font,
	ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, NumberRange = roblox.NumberRange,
	game = { GetService = function(_, name)
		if name == "ReplicatedStorage" then
			return { WaitForChild = function()
				return shared
			end, FindFirstChild = function()
				return nil
			end }
		end
		return {}
	end },
}
local Looks = Loader.require(shared.Hunter.Looks)
local R6Rig = Loader.require(shared.Hunter.R6Rig)
local Accessories = Loader.require(shared.Hunter.Accessories)
local REPORT = table.find(process.args, "report") ~= nil

local failures = 0
local function check(ok: boolean, msg: string, detail: any?)
	print((if ok then "  ok    " else "  FAIL  ") .. msg .. (if ok or detail == nil then "" else ": " .. tostring(detail)))
	if not ok then
		failures += 1
	end
end
local function first(list: { string }, n: number?): string
	local out = {}
	for i = 1, math.min(#list, n or 6) do
		out[i] = list[i]
	end
	return table.concat(out, "; ") .. (if #list > (n or 6) then string.format(" (+%d more)", #list - (n or 6)) else "")
end

-- the parts a look adds to the six R6 parts (clothes, gear, accessories; not the face plate,
-- block hair or a weapon)
local BODY = { HumanoidRootPart = true, Torso = true, Head = true, ["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true, FacePlate = true }
local function extraParts(model): number
	local n = 0
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and not BODY[d.Name] and string.sub(d.Name, 1, 4) ~= "Hair" and string.sub(d.Name, 1, 6) ~= "Weapon" then
			n += 1
		end
	end
	return n
end
local function build(look, opts)
	opts = opts or {}
	if opts.weapon == nil then
		opts.weapon = false
	end
	return R6Rig.build(look, opts)
end
local BUDGET = 60

-- ── every option of every field builds ──
do
	local built, bad = 0, {}
	local combos = {
		{ armor = "plate" },
		{ top = "archmage", bottom = "long_robe", armor = "full_plate", gloves = "gauntlets", headwear = "winged_helm", back = "long_cape" },
		{ top = "tee", bottom = "shorts", armor = "none" },
	}
	for field, listName in Looks.FIELDS do
		if field ~= "hair" then
			for _, o in Looks[listName] do
				for _, combo in combos do
					local look = table.clone(Looks.DEFAULT)
					for k, v in combo do
						look[k] = v
					end
					look[field] = o.id
					local ok, err = pcall(build, look, { name = "Opt", rank = 4 })
					if ok then
						built += 1
					else
						table.insert(bad, field .. "=" .. tostring(o.id) .. ": " .. tostring(err))
					end
				end
				-- and on a civilian
				local okC, errC = pcall(build, { [field] = o.id }, { civilian = true, npc = true })
				if not okC then
					table.insert(bad, "civilian " .. field .. "=" .. tostring(o.id) .. ": " .. tostring(errC))
				end
			end
		end
	end
	check(#bad == 0, string.format("every option of every field builds on a real R6 rig (%d builds, 3 outfits each, and on a civilian)", built), first(bad))
	local counts = {}
	for _, k in { "TOPS", "BOTTOMS", "SHOES", "GLOVES", "ARMOR", "HEADWEAR", "BACK", "EXTRAS", "PRESETS", "PALETTE" } do
		table.insert(counts, string.lower(k) .. " " .. #Looks[k])
	end
	print("        " .. table.concat(counts, ", ") .. ", accessories " .. #Accessories.list)
	check(#Looks.TOPS >= 45 and #Looks.BOTTOMS >= 20 and #Looks.SHOES >= 12 and #Looks.ARMOR >= 18, "at least 45 tops, 20 bottoms, 12 shoes, 18 armours")
	check(#Looks.HEADWEAR >= 25 and #Looks.BACK >= 25 and #Looks.EXTRAS >= 25 and #Looks.GLOVES >= 10, "at least 25 headwear, back items and face/neck pieces, 10 gloves")
	local robes = 0
	for _, t in Looks.TOPS do
		if t.group == "Robes" then
			robes += 1
		end
	end
	check(robes >= 8, string.format("%d robes", robes))
end

-- ── every option id is unique in its list, and every list is what R6Rig draws ──
do
	local dup = {}
	for _, listName in { "TOPS", "BOTTOMS", "SHOES", "GLOVES", "ARMOR", "HEADWEAR", "BACK", "EXTRAS", "PRESETS", "PALETTE", "AURA", "MARKS" } do
		local seen = {}
		for _, o in Looks[listName] do
			if seen[o.id] then
				table.insert(dup, listName .. "." .. tostring(o.id))
			end
			seen[o.id] = true
		end
	end
	check(#dup == 0, "option ids are unique in every list", first(dup))
end

-- ── presets ──
do
	local bad = {}
	local cats = {}
	for _, c in Looks.CATEGORIES do
		cats[c.id] = 0
	end
	for _, p in Looks.PRESETS do
		if cats[p.cat] == nil then
			table.insert(bad, p.id .. " is on an unknown shelf " .. tostring(p.cat))
		else
			cats[p.cat] += 1
		end
		local look = Looks.applyPreset(Looks.DEFAULT, p.id)
		for k, v in p.look do
			if look[k] ~= v then
				table.insert(bad, p.id .. " lost " .. k .. "=" .. tostring(v))
			end
		end
		for i, id in p.acc or {} do
			if look.accessories[i] ~= id then
				table.insert(bad, p.id .. " lost accessory " .. tostring(id))
			end
		end
		local ok, err = pcall(build, look, { rank = 4, weapon = nil })
		if not ok then
			table.insert(bad, p.id .. " doesn't build: " .. tostring(err))
		end
		if type(p.name) ~= "string" or type(p.desc) ~= "string" then
			table.insert(bad, p.id .. " needs a name and a desc")
		end
	end
	check(#bad == 0, string.format("all %d presets are valid looks, on known shelves, and build", #Looks.PRESETS), first(bad))
	check(#Looks.PRESETS >= 45, "at least 45 presets")
	local tiers = {}
	for _, cls in Looks.CLASSES do
		local ranks = {}
		for _, p in Looks.presetsIn(cls.id) do
			if p.rank then
				ranks[p.rank] = true
			end
		end
		if not (ranks.E and ranks.C and ranks.A and ranks.S) then
			table.insert(tiers, cls.id)
		end
		for r = 0, 6 do
			local id = Looks.classPreset(cls.id, r)
			local p = id and Looks.find("PRESETS", id)
			if not p or p.cat ~= cls.id then
				table.insert(tiers, cls.id .. " at rank " .. r)
			end
		end
	end
	check(#tiers == 0, "every class has a set from E-rank to S-rank, and 'wear your class' finds one at every rank", first(tiers))
	local shelves = {}
	for id, n in cats do
		if n == 0 then
			table.insert(shelves, id)
		end
	end
	check(#shelves == 0, "every preset shelf has presets", first(shelves))
	-- a preset takes off what it doesn't name (no helmet left over from the last one)
	local worn = Looks.applyPreset(Looks.applyPreset(Looks.DEFAULT, "tank_a"), "student")
	check(worn.headwear == "none" and worn.armor == "none" and #worn.accessories == 0, "a preset takes the last outfit off")
end

-- ── old saves still load ──
do
	local bad = {}
	local saves = {
		{ skin = "warm", top = "jacket", gloves = true },
		{ skin = "warm", top = "robe", gloves = false, armor = "plate" },
		{ top = "medic", trim = "teal" },
		{ top = "no_such_top", bottom = 12, gloves = "maybe", accessories = "acc_lucky_coin" },
		{ accessories = { "acc_lucky_coin", "acc_jade_ring", "acc_guild_signet", "nope", "acc_dragonheart", "acc_silver_studs", "acc_deep_pearl", "acc_twin_orbs" } },
		{ accessories = { [1] = "acc_lucky_coin", foo = "acc_jade_ring" } },
		{},
		"not a table",
	}
	for i, raw in saves do
		local look = Looks.clean(raw)
		for field, listName in Looks.FIELDS do
			if not Looks.find(listName, look[field]) then
				table.insert(bad, "save " .. i .. ": " .. field .. "=" .. tostring(look[field]))
			end
		end
		if type(look.accessories) ~= "table" or #look.accessories > Looks.MAX_ACCESSORIES then
			table.insert(bad, "save " .. i .. ": accessories")
		else
			local slots = {}
			for _, id in look.accessories do
				local a = Accessories.find(id)
				if not a or slots[a.slot] then
					table.insert(bad, "save " .. i .. ": accessory " .. tostring(id))
				elseif a then
					slots[a.slot] = true
				end
			end
		end
		local ok, err = pcall(build, raw)
		if not ok then
			table.insert(bad, "save " .. i .. " doesn't build: " .. tostring(err))
		end
	end
	check(#bad == 0, "old saves (gloves yes/no, missing fields, junk, too many accessories) clean to valid looks", first(bad))
	check(Looks.clean({ gloves = true }).gloves == "gloves" and Looks.clean({ gloves = false }).gloves == "none" and Looks.clean({}).gloves == "none", "an old `gloves = true` is gloves, false or missing is none")
	local five = Looks.clean(saves[5])
	check(#five.accessories == 4 and five.accessories[1] == "acc_lucky_coin" and five.accessories[2] == "acc_jade_ring", "accessories: one per slot, at most four, first come first kept")
	local a1 = Looks.toggleAccessory({ "acc_lucky_coin" }, "acc_dragonheart")
	local a2 = Looks.toggleAccessory(a1, "acc_dragonheart")
	check(#a1 == 1 and a1[1] == "acc_dragonheart" and #a2 == 0, "putting an accessory on swaps out its slot, twice takes it off")
end

-- ── accessories ──
do
	local bad = {}
	local seen = {}
	local per = {}
	for _, a in Accessories.list do
		if seen[a.id] then
			table.insert(bad, "duplicate " .. a.id)
		end
		seen[a.id] = true
		if string.sub(a.id, 1, 4) ~= "acc_" then
			table.insert(bad, a.id .. " isn't acc_<slug>")
		end
		per[a.class] = (per[a.class] or 0) + 1
		if not Accessories.GRADE_OF[a.grade] then
			table.insert(bad, a.id .. " has no grade")
		end
		if not (Accessories.KINDS[a.slot] and Accessories.KINDS[a.slot][a.kind]) then
			table.insert(bad, a.id .. ": the rig can't draw a " .. tostring(a.kind) .. " on the " .. tostring(a.slot))
		end
		local cheap = false
		for _, k in a.mix do
			if Accessories.COST[k] == 1 then
				cheap = true
			end
			if (k == "power" or k == "edge" or k == "growth") and a.class == "any" then
				table.insert(bad, a.id .. " (general) can't give a class stat")
			end
		end
		if not cheap then
			table.insert(bad, a.id .. " has nothing to spend its leftover points on")
		end
		if type(a.desc) ~= "string" or #a.desc < 10 then
			table.insert(bad, a.id .. " needs a desc")
		end
		local look = table.clone(Looks.DEFAULT)
		look.accessories = { a.id }
		local ok, m = pcall(build, look, { rank = 3 })
		if not ok then
			table.insert(bad, a.id .. " doesn't build: " .. tostring(m))
		elseif extraParts(m) <= extraParts(build(Looks.DEFAULT)) then
			table.insert(bad, a.id .. " draws nothing")
		end
	end
	check(#bad == 0, string.format("all %d accessories have unique acc_ ids, a grade, a drawable kind, and build on a rig", #Accessories.list), first(bad))
	local few = {}
	for _, c in Accessories.CLASSES do
		if (per[c] or 0) < 15 then
			table.insert(few, c .. " " .. tostring(per[c] or 0))
		end
	end
	check(#few == 0, "at least 15 accessories per class and in the general set", first(few))
	-- grade scaling: an accessory is worth exactly its grade's budget, and budgets climb
	local mono = {}
	for i = 2, #Accessories.BUDGET do
		if Accessories.BUDGET[i] <= Accessories.BUDGET[i - 1] or Accessories.PRICE[i] <= Accessories.PRICE[i - 1] then
			table.insert(mono, "grade " .. Accessories.GRADES[i])
		end
	end
	for _, a in Accessories.list do
		if Accessories.score(a) ~= Accessories.BUDGET[Accessories.GRADE_OF[a.grade]] then
			table.insert(mono, a.id .. " is worth " .. Accessories.score(a))
		end
	end
	-- and within a class the best of each grade beats the best of the grade under it, stat by stat
	for _, c in Accessories.CLASSES do
		local best = {}
		for _, a in Accessories.ofClass(c) do
			local g = Accessories.GRADE_OF[a.grade]
			best[g] = math.max(best[g] or 0, Accessories.score(a))
		end
		for g = 2, 6 do
			if best[g] and best[g - 1] and best[g] <= best[g - 1] then
				table.insert(mono, c .. " grade " .. Accessories.GRADES[g])
			end
		end
	end
	check(#mono == 0, "stats climb with grade (E 2 points .. S 14; every accessory worth exactly its grade)", first(mono))
	-- every slot at once, and four accessories on a heavy outfit, still build
	local all = {}
	for _, s in Accessories.SLOTS do
		for _, a in Accessories.list do
			if a.slot == s.id then
				table.insert(all, a.id)
				break
			end
		end
	end
	local okAll, errAll = pcall(build, { top = "archmage", armor = "full_plate", accessories = all }, { rank = 5, accessories = { "acc_gate_key" } })
	check(okAll, "accessories in every slot (and a life's own charm passed in) build together", errAll)
end

-- ── the accessories' gear ──
do
	local bad = {}
	local CORE = { vitality = true, strength = true, agility = true, intelligence = true, charisma = true, luck = true, willpower = true }
	local Weapons = Loader.require(shared.Hunter.Weapons)
	local taken = {}
	for _, w in Weapons.gearList() do
		taken[w.id] = true
	end
	local gear = Accessories.gearList()
	for _, g in gear do
		if taken[g.id] then
			table.insert(bad, g.id .. " collides")
		end
		taken[g.id] = true
		if g.slot ~= "charm" or type(g.price) ~= "number" or type(g.effect) ~= "string" or type(g.name) ~= "string" then
			table.insert(bad, g.id .. " isn't a charm with a name, price and effect")
		end
		for stat in g.clash or {} do
			if not CORE[stat] then
				table.insert(bad, g.id .. " has a clash bonus in " .. stat)
			end
		end
		if g.toughness and (g.toughness <= 0.5 or g.toughness >= 1) then
			table.insert(bad, g.id .. " toughness " .. g.toughness)
		end
	end
	check(#gear == #Accessories.list and #bad == 0, string.format("%d accessory gear items, charms with stats the engine knows", #gear), first(bad))
	local r = process.exec("lune", { "run", "tools/checkgame", "BitLeveling", "--", "--quick" })
	local out = r.stdout .. r.stderr
	local errors = string.match(out, "BitLeveling: (%d+) errors")
	check(r.ok and errors == "0", "the game's validator passes with the accessories in its gear (tools/checkgame BitLeveling --quick)", string.sub(out, -400))
	local inGame = string.match(out, "gear (%d+)")
	check(inGame ~= nil and tonumber(inGame) >= #gear, "the accessories are in the game's gear list (" .. tostring(inGame) .. " items)")
end

-- ── part budget ──
do
	local over = {}
	local heaviest = {}
	for _, p in Looks.PRESETS do
		local n = extraParts(build(Looks.applyPreset(Looks.DEFAULT, p.id), { rank = 4 }))
		table.insert(heaviest, { id = p.id, n = n })
		if n > BUDGET then
			table.insert(over, p.id .. " " .. n)
		end
	end
	table.sort(heaviest, function(a, b)
		return a.n > b.n
	end)
	check(#over == 0, string.format("every preset adds at most %d parts to its rig (heaviest: %s %d)", BUDGET, heaviest[1].id, heaviest[1].n), first(over))
	local seed = 11
	local function rand(a, b)
		seed = (seed * 48271) % 2147483647
		return a + seed % (b - a + 1)
	end
	local worst, worstLook = 0, nil
	local overR = 0
	for i = 1, 300 do
		local look = Looks.random(rand, if i % 3 == 0 then { civilian = true } else nil)
		local n = extraParts(build(look, { rank = 4 }))
		if n > worst then
			worst, worstLook = n, look
		end
		if n > BUDGET then
			overR += 1
		end
	end
	check(overR == 0, string.format("300 random looks stay within %d parts (worst %d)", BUDGET, worst), worstLook and (worstLook.top .. "/" .. worstLook.armor .. "/" .. worstLook.back .. "/" .. worstLook.headwear))
	if REPORT then
		-- the heaviest presets, piece by piece (what each field adds)
		local BLANK = { top = "tee", bottom = "jeans", shoes = "sneakers", gloves = "none", armor = "none", extra = "none", headwear = "none", back = "none" }
		for i = 1, math.min(8, #heaviest) do
			local look = Looks.applyPreset(Looks.DEFAULT, heaviest[i].id)
			local total = extraParts(build(look))
			local bits = {}
			for field, blank in BLANK do
				local l = table.clone(look)
				l[field] = blank
				table.insert(bits, field .. " " .. (total - extraParts(build(l))))
			end
			local l = table.clone(look)
			l.accessories = {}
			table.insert(bits, "accessories " .. (total - extraParts(build(l))))
			print(string.format("        %-16s %3d  %s", heaviest[i].id, total, table.concat(bits, ", ")))
		end
	end
end

-- ── civilians ──
do
	local bad = {}
	local seed = 5
	local function rand(a, b)
		seed = (seed * 16807) % 2147483647
		return a + seed % (b - a + 1)
	end
	for _ = 1, 400 do
		local look = Looks.random(rand, { civilian = true })
		local hw = Looks.find("HEADWEAR", look.headwear)
		local b = Looks.find("BACK", look.back)
		if not hw or hw.combat or not hw.civ then
			table.insert(bad, "headwear " .. tostring(look.headwear))
		end
		if not b or b.combat or not b.civ then
			table.insert(bad, "back " .. tostring(look.back))
		end
		for field, listName in { top = "TOPS", bottom = "BOTTOMS", shoes = "SHOES", gloves = "GLOVES", extra = "EXTRAS" } do
			local o = Looks.find(listName, look[field])
			if not o or not o.civ then
				table.insert(bad, field .. " " .. tostring(look[field]))
			end
		end
		if look.armor ~= "none" or look.weapon ~= "none" or look.aura ~= "none" or look.eyeGlow ~= "none" then
			table.insert(bad, "armour, weapon or mana on a civilian")
		end
		for _, id in look.accessories or {} do
			local a = Accessories.find(id)
			if not a or a.class ~= "any" then
				table.insert(bad, "accessory " .. tostring(id))
			end
		end
	end
	check(#bad == 0, "400 civilian randoms: civilian clothes only, never combat headwear, armour, weapons or a Hunter's accessory", first(bad))
	-- a civilian rig never draws combat gear even if its look has it
	local m = build({ headwear = "knight_helm", back = "greatsword", armor = "full_plate" }, { civilian = true })
	check(m:FindFirstChild("Helm") == nil and m:FindFirstChild("GreatBlade") == nil and m:FindFirstChild("Cuirass") == nil, "a civilian rig leaves combat headwear, back weapons and armour off")
	-- class dice give class clothes
	local wrong = {}
	for _, cls in Looks.CLASSES do
		for _ = 1, 30 do
			local look = Looks.random(rand, { class = cls.id })
			if not Looks.suits(Looks.find("TOPS", look.top), cls.id) then
				table.insert(wrong, cls.id .. " top " .. look.top)
			end
			for _, id in look.accessories do
				local a = Accessories.find(id)
				if a.class ~= cls.id and a.class ~= "any" then
					table.insert(wrong, cls.id .. " wears " .. id)
				end
			end
		end
	end
	check(#wrong == 0, "the class dice dress a Hunter in that class's clothes and accessories", first(wrong))
end

-- ── faces stay visible ──
do
	-- the eyes and the mouth, in the head's space (the face plate's gui is at z = -0.68)
	local WINDOWS = {
		{ x0 = -0.33, x1 = -0.15, y0 = -0.07, y1 = 0.07 },
		{ x0 = 0.15, x1 = 0.33, y0 = -0.07, y1 = 0.07 },
		{ x0 = -0.12, x1 = 0.12, y0 = -0.32, y1 = -0.26 },
	}
	local function covers(model): string?
		local head = model:FindFirstChild("Head")
		for _, p in model:GetDescendants() do
			if p:IsA("BasePart") and not BODY[p.Name] and p.Transparency < 0.4 and string.sub(p.Name, 1, 6) ~= "Weapon" then
				local cf = head.CFrame:ToObjectSpace(p.CFrame)
				local s = p.Size / 2
				local lo, hi = roblox.Vector3.new(math.huge, math.huge, math.huge), roblox.Vector3.new(-math.huge, -math.huge, -math.huge)
				for _, sx in { -1, 1 } do
					for _, sy in { -1, 1 } do
						for _, sz in { -1, 1 } do
							local c = cf * roblox.Vector3.new(sx * s.X, sy * s.Y, sz * s.Z)
							lo = roblox.Vector3.new(math.min(lo.X, c.X), math.min(lo.Y, c.Y), math.min(lo.Z, c.Z))
							hi = roblox.Vector3.new(math.max(hi.X, c.X), math.max(hi.Y, c.Y), math.max(hi.Z, c.Z))
						end
					end
				end
				if lo.Z < -0.69 and hi.Z > -1.4 then
					for _, w in WINDOWS do
						-- (a box's bounds overstate a rotated part; it must reach well into a window)
						if lo.X < w.x1 - 0.03 and hi.X > w.x0 + 0.03 and lo.Y < w.y1 - 0.02 and hi.Y > w.y0 + 0.02 then
							return p.Name
						end
					end
				end
			end
		end
		return nil
	end
	local bad = {}
	local base = { skin = "light", hair = 0, top = "tee", bottom = "jeans", armor = "none" }
	for field, listName in { top = "TOPS", armor = "ARMOR", headwear = "HEADWEAR", extra = "EXTRAS", back = "BACK", gloves = "GLOVES", bottom = "BOTTOMS" } do
		for _, o in Looks[listName] do
			if not o.coversFace then
				local look = table.clone(base)
				look[field] = o.id
				local hit = covers(build(look))
				if hit then
					table.insert(bad, field .. "=" .. o.id .. " (" .. hit .. ")")
				end
			end
		end
	end
	for _, a in Accessories.list do
		local hit = covers(build({ skin = "light", hair = 0, accessories = { a.id } }))
		if hit then
			table.insert(bad, a.id .. " (" .. hit .. ")")
		end
	end
	check(#bad == 0, "nothing covers the eyes or the mouth unless it's meant to (masks, closed helms)", first(bad))
end

-- ── mesh roles the kit is asked for ──
do
	local ROLES = { robe_skirt = "y", robe_sleeve = "y", hood_cowl = "any", pauldron_spiked = "any", helm_winged = "any", helm_horned = "any", crown = "any", gauntlet = "y", boot = "any", belt_pouch = "any", cape_skinned = "z", scarf_skinned = "z" }
	local bad, used = {}, {}
	local function scan(model)
		for _, p in model:GetDescendants() do
			if p:IsA("BasePart") then
				local r = p:GetAttribute("MeshRole")
				if r ~= nil then
					local axis = ROLES[r]
					used[r] = true
					local s = p.Size
					if not axis then
						table.insert(bad, p.Name .. " asks for unknown role " .. tostring(r))
					elseif axis == "y" and not (s.Y >= math.max(s.X, s.Z) * 0.35) then
						-- (a bell can be squat, never a disc)
						table.insert(bad, p.Name .. " (" .. r .. ") is flat along Y")
					elseif axis == "z" and not (s.Z <= s.X and s.Z <= s.Y) then
						table.insert(bad, p.Name .. " (" .. r .. ") isn't thin along Z")
					end
				end
				local by = p:GetAttribute("CoveredBy")
				if by ~= nil and not model:FindFirstChild(by) then
					table.insert(bad, p.Name .. " is covered by a missing " .. tostring(by))
				end
			end
		end
	end
	for field, listName in Looks.FIELDS do
		if field ~= "hair" and field ~= "weapon" then
			for _, o in Looks[listName] do
				local look = table.clone(Looks.DEFAULT)
				look[field] = o.id
				scan(build(look))
			end
		end
	end
	for _, a in Accessories.list do
		scan(build({ accessories = { a.id } }))
	end
	local roles = {}
	for r in used do
		table.insert(roles, r)
	end
	table.sort(roles)
	check(#bad == 0, "every MeshRole is one of the kit's new roles, on a part shaped for it (" .. table.concat(roles, ", ") .. ")", first(bad))
end

-- ── the creator (in its own run: its modules must be loaded with proxied instances) ──
do
	local r = process.exec("lune", { "run", "tests/outfits_check", "--", "creator" })
	local out = r.stdout .. r.stderr
	for line in string.gmatch(out, "[^\n]+") do
		if string.find(line, "^  ") then
			print(line)
		end
	end
	check(r.ok, "the creator's checks pass", if r.ok then nil else string.sub(out, -600))
end

if failures > 0 then
	print(string.format("\n%d check(s) failed.", failures))
	process.exit(1)
end
print("\nOutfits, robes, accessories and the creator: all good.")
