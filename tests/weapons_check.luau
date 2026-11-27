--[[
	WEAPONS (Hunter/Weapons.luau and the loot in Engine/HunterWorld.luau):
		lune run tests/weapons_check
	every weapon at every rarity is a gear item; ids round-trip; drop odds match what the game
	shows (stars 70/24/6, Shiny about 1 in 60); a higher rarity is always stronger; loot equips
	an upgrade and stashes the rest; a life with loot still saves.
	The list itself: ids and names unique and original (no canon item names); every weapon has a
	known family, grade, element and class, four colours, a description; prices only on low
	workshop weapons; every family has weapons, a builder in Hunter/WeaponModels, a class and a
	swing style; every class has several weapons at every grade; drops come from the right grades.
]]
local process = require("@lune/process")
local serde = require("@lune/serde")
local Loader = require("./loader")
process.env.LIFESIM_PACK = "BitLeveling"
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local Weapons = Loader.require(root.Hunter.Weapons)
local Rng = Engine.Rng
-- the models need Roblox's value types (Lune has them in @lune/roblox)
local roblox = require("@lune/roblox")
for _, k in { "Instance", "Vector3", "Vector2", "CFrame", "Color3", "Enum", "NumberRange", "NumberSequence", "NumberSequenceKeypoint", "ColorSequence" } do
	Loader.globals[k] = (roblox :: any)[k]
end
local WeaponModels = Loader.require(root.Hunter.WeaponModels)

local fails = 0
local function check(ok, msg)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		fails += 1
	end
end

local missing, weaker = 0, 0
for _, w in Weapons.list do
	local last = 0
	for stars = 1, 3 do
		for _, shiny in { false, true } do
			local id = Weapons.gearId(w.id, stars, shiny)
			if not pack.gear[id] then
				missing += 1
			end
			local b, s, sh = Weapons.parse(id)
			if b ~= w.id or s ~= stars or sh ~= shiny then
				missing += 1
			end
		end
		local p = Weapons.power(w.id, stars, false)
		if p <= last then
			weaker += 1
		end
		last = p
		if Weapons.power(w.id, stars, true) <= p then
			weaker += 1
		end
	end
end
print(string.format("        %d weapons, %d gear variants", #Weapons.list, #Weapons.list * 6))
check(#Weapons.gearList() == #Weapons.list * 6, "gearList has every weapon at ★, ★★, ★★★, each shiny or not")

-- ── the list ──
local problems = {}
local function problem(msg)
	if #problems < 10 then
		table.insert(problems, msg)
	end
end
local ids, names, nFamilies = {}, {}, 0
for _ in Weapons.FAMILIES do
	nFamilies += 1
end
-- canon item and character names the list must not borrow (checked in names and descriptions)
local CANON = { "kasaka", "knight killer", "baruka", "demon king", "avarice", "kamish", "jinwoo", "sung ", "monarch", "the system", "igris", "beru", "ashborn", "esil", "cerberus", "rasaka" }
local perFamily, perElement, grid = {}, {}, {}
for _, c in Weapons.CLASSES do
	grid[c] = { 0, 0, 0, 0, 0, 0 }
end
for _, w in Weapons.list do
	if ids[w.id] then
		problem("id " .. w.id .. " twice")
	end
	ids[w.id] = true
	if names[w.name] then
		problem("name " .. w.name .. " twice")
	end
	names[w.name] = true
	local lower = string.lower(w.name .. " " .. w.desc)
	for _, bad in CANON do
		if string.find(lower, bad, 1, true) then
			problem(w.id .. " borrows a canon name (" .. bad .. ")")
		end
	end
	local fam = Weapons.FAMILIES[w.family]
	if not fam then
		problem(w.id .. " has no family " .. tostring(w.family))
		continue
	end
	if type(w.grade) ~= "number" or w.grade ~= math.floor(w.grade) or w.grade < 1 or w.grade > 6 then
		problem(w.id .. " has grade " .. tostring(w.grade))
		continue
	end
	if not Weapons.ELEMENTS[w.element] or not table.find(Weapons.ELEMENT_LIST, w.element) then
		problem(w.id .. " has element " .. tostring(w.element))
	end
	if w.class ~= fam.class or not grid[w.class] then
		problem(w.id .. " has class " .. tostring(w.class))
	else
		grid[w.class][w.grade] += 1
	end
	if type(w.c) ~= "table" or #w.c ~= 4 then
		problem(w.id .. " needs four colours")
	else
		for _, col in w.c do
			if #col ~= 3 or col[1] < 0 or col[1] > 255 or col[2] < 0 or col[2] > 255 or col[3] < 0 or col[3] > 255 then
				problem(w.id .. " has a bad colour")
			end
		end
	end
	if type(w.desc) ~= "string" or #w.desc < 10 or type(w.p) ~= "table" then
		problem(w.id .. " needs a description and shape knobs")
	end
	if w.price ~= nil and (w.grade > 3 or w.price <= 0) then
		problem(w.id .. " is priced but isn't a low workshop weapon")
	end
	if Weapons.elementOf(w.id) ~= w.element or Weapons.classOf(w.id) ~= w.class then
		problem(w.id .. ": elementOf / classOf disagree")
	end
	perFamily[w.family] = (perFamily[w.family] or 0) + 1
	perElement[w.element] = (perElement[w.element] or 0) + 1
end
local builders = {}
for _, f in WeaponModels.FAMILY_LIST do
	builders[f] = true
end
local styles = { slash = true, smash = true, thrust = true, shot = true, throw = true, spell = true, gust = true, heal = true, punch = true, lash = true, bash = true }
local ordered = {}
for _, f in Weapons.FAMILY_ORDER do
	if ordered[f] then
		problem("family " .. f .. " is in FAMILY_ORDER twice")
	end
	ordered[f] = true
end
for id, fam in Weapons.FAMILIES do
	if not builders[id] then
		problem("family " .. id .. " has no builder")
	end
	if (perFamily[id] or 0) == 0 then
		problem("family " .. id .. " has no weapons")
	end
	if not styles[fam.fx] or not table.find(Weapons.CLASSES, fam.class) or not ordered[id] then
		problem("family " .. id .. " needs a swing style, a class and a place in FAMILY_ORDER")
	end
end
check(#problems == 0, "every weapon has a unique id and name, a family, grade, element, class and colours; no canon names", table.concat(problems, "; "))
local elementLine = {}
for _, e in Weapons.ELEMENT_LIST do
	table.insert(elementLine, e .. " " .. (perElement[e] or 0))
end
print(string.format("        %d families; per element: %s", nFamilies, table.concat(elementLine, ", ")))
check(#Weapons.list >= 150 and nFamilies >= 40, "at least 150 weapons in at least 40 families")
local thin = {}
for _, c in Weapons.CLASSES do
	local g = grid[c]
	print(string.format("        %-9s E %d  D %d  C %d  B %d  A %d  S %d", Weapons.CLASS_NAMES[c], g[1], g[2], g[3], g[4], g[5], g[6]))
	for gr = 1, 6 do
		if g[gr] < 4 then
			table.insert(thin, c .. " " .. Weapons.GRADES[gr])
		end
	end
end
check(#thin == 0, "every class has at least four weapons at every grade", table.concat(thin, ", "))
local fewElements = {}
for _, e in Weapons.ELEMENT_LIST do
	if (perElement[e] or 0) < 8 then
		table.insert(fewElements, e)
	end
end
check(#fewElements == 0, "every element has at least eight weapons", table.concat(fewElements, ", "))
local powerOk = true
for _, w in Weapons.list do
	if Weapons.power(w.id, 1, false) ~= Weapons.POWER[w.grade] then
		powerOk = false
	end
end
check(powerOk and Weapons.parse("w_nothing_1") == nil and Weapons.parse("x") == nil and Weapons.parse(nil) == nil, "a ★ weapon's power is its grade's; parse turns away what isn't a weapon")
check(missing == 0, "every weapon at every rarity is a gear item, and its id reads back")
check(weaker == 0, "more stars are always stronger, and Shiny is stronger still")

local st = { rng = Rng.seed(99) }
local counts, shinies, N = { 0, 0, 0 }, 0, 30000
for _ = 1, N do
	local _, stars, shiny = Weapons.roll(3, function(n)
		return Rng.int(st, 1, n)
	end, function()
		return Rng.next(st)
	end)
	counts[stars] += 1
	if shiny then
		shinies += 1
	end
end
print(string.format("        %d drops: ★ %.1f%%  ★★ %.1f%%  ★★★ %.1f%%  Shiny 1 in %.0f", N, counts[1] / N * 100, counts[2] / N * 100, counts[3] / N * 100, N / math.max(1, shinies)))
check(math.abs(counts[1] / N - 0.70) < 0.02 and math.abs(counts[2] / N - 0.24) < 0.02 and math.abs(counts[3] / N - 0.06) < 0.01, "star odds match the ones shown (70 / 24 / 6)")
check(math.abs(shinies / N - 1 / 60) < 0.006, "Shiny odds match the ones shown (about 1 in 60)")
local nearOk = true
for rank = 1, 6 do
	for _ = 1, 400 do
		local base = Weapons.roll(rank, function(n)
			return Rng.int(st, 1, n)
		end, function()
			return Rng.next(st)
		end)
		local w = Weapons.byId[base]
		if not w or math.abs(w.grade - rank) > 1 then
			nearOk = false
		end
	end
end
check(nearOk, "a Gate of each rank drops weapons of its grade or the next one over")

local sim = Engine.new(pack)
local life = sim:newLife({ seed = 777, birthEra = "first_gen" })
life.age = 25
local extra = {}
for _ = 1, 40 do
	sim.lootHook(sim, life, { rank = 4, chance = 1 }, extra)
end
local b = Weapons.parse(life.gear and life.gear.weapon)
check(b ~= nil, "loot puts a weapon in the hand")
check(#(life.stash or {}) > 0, "loot that isn't better goes in the stash")
check(pcall(function()
	serde.decode("json", serde.encode("json", life))
end), "a life full of loot still saves")
if fails > 0 then
	process.exit(1)
end
