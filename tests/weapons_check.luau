--[[
	WEAPONS (Hunter/Weapons.luau and the loot in Engine/HunterWorld.luau):
		lune run tests/weapons_check
	every weapon at every rarity is a gear item; ids round-trip; drop odds match what the game
	shows (stars 70/24/6, Shiny about 1 in 60); a higher rarity is always stronger; loot equips
	an upgrade and stashes the rest; a life with loot still saves.
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
