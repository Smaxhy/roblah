--[[
	Odds table: how likely a check is to pass at each value of a stat, for foes that don't grow
	(`fixed = true`). For tuning a check so it depends on the stat and nothing else.

		lune run tests/odds                 the usual foes, on the pack's `will` stat
		lune run tests/odds strength        on another stat
		lune run tests/odds mind 2/5/3      one foe: coins/base/coinPower
		lune run tests/odds mind at=55,75,90,100    at these values of the stat

	Reads the active pack (Config.pack, or LIFESIM_PACK).
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local Clash = Loader.require(root.Engine.Clash)
local pack = Loader.pack(root)
local sim = Engine.new(pack)

local stat = process.args[1] or sim.roles.will or sim.coreStats[1]
local foes = {}
local values = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 }
for i = 2, #process.args do
	local c, b, p = string.match(process.args[i], "^(%d+)/(%d+)/(%d+)$")
	if c then
		table.insert(foes, { tonumber(c), tonumber(b), tonumber(p) })
	end
	local at = string.match(process.args[i], "^at=(.+)$")
	if at then
		values = {}
		for n in string.gmatch(at, "%d+") do
			table.insert(values, tonumber(n))
		end
	end
end
if #foes == 0 then
	foes = { { 1, 2, 2 }, { 1, 3, 3 }, { 2, 3, 2 }, { 2, 3, 3 }, { 2, 4, 2 }, { 2, 4, 3 }, { 2, 5, 3 }, { 3, 5, 3 }, { 3, 6, 3 }, { 3, 7, 3 } }
end

local life = sim:newLife({ seed = 5, rollOrigin = true })
life.age = 30
life.traits = {}
life.gear = {}

local head = string.format("%-14s", stat .. ":")
for _, v in values do
	head ..= string.format(" %5d", v)
end
print(head)
local you = string.format("%-14s", "you bring")
for _, v in values do
	life.stats[stat] = v
	local p = sim:clashSides(life, { stat = stat, coins = 1, base = 1, coinPower = 1, ignoreSanity = true, fixed = true })
	you ..= string.format(" %d/%d/%d", p.coins, p.base, p.coinPower)
end
print(you)
for _, f in foes do
	local line = string.format("%-14s", string.format("foe %d/%d/%d", f[1], f[2], f[3]))
	for _, v in values do
		life.stats[stat] = v
		local p, foe = sim:clashSides(life, { stat = stat, coins = f[1], base = f[2], coinPower = f[3], ignoreSanity = true, fixed = true })
		line ..= string.format(" %4d%%", math.floor(Clash.estimate(p, foe, 4000) * 100 + 0.5))
	end
	print(line)
end
print("(coins/base/+power a heads; fair coins; no gear, traits or approach)")
