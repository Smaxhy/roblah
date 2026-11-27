--[[
	Clash odds table: player stat vs the standard foe tiers, at sanity 0, using
	the content pack's curve (pack.clash). Pass numbers to try another curve:
		lune run tests/clash_table [coinsEvery baseEvery powerEvery maxCoins]
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Clash = Loader.require(root.Engine.Clash)
local pack = Loader.pack(root)

local curve = pack.clash or Clash.DEFAULT_CURVE
if process.args[1] then
	curve = {
		coinsEvery = tonumber(process.args[1]),
		baseEvery = tonumber(process.args[2]),
		powerEvery = tonumber(process.args[3]),
		maxCoins = tonumber(process.args[4]) or 4,
	}
end
print(string.format("curve: a coin every %s, +1 base every %s, +1 power every %s, max %s coins", tostring(curve.coinsEvery), tostring(curve.baseEvery), tostring(curve.powerEvery), tostring(curve.maxCoins or 4)))

local tiers = {
	{ "easy", { coins = 1, base = 2, coinPower = 2 } },
	{ "medium", { coins = 2, base = 4, coinPower = 3 } },
	{ "med-hard", { coins = 2, base = 5, coinPower = 3 } },
	{ "hard", { coins = 3, base = 6, coinPower = 3 } },
	{ "boss", { coins = 4, base = 8, coinPower = 4 } },
}
local header = string.format("%-6s %-10s", "stat", "side")
for _, t in tiers do
	header ..= string.format("%9s", t[1])
end
print(header)
for _, stat in { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 } do
	local p = Clash.playerSide("You", stat, 0, nil, false, curve)
	local line = string.format("%-6d %-10s", stat, string.format("%d/%d/%d", p.coins, p.base, p.coinPower))
	for _, t in tiers do
		local f = Clash.foeSide(t[2])
		line ..= string.format("%8d%%", math.floor(Clash.estimate(p, f) * 100 + 0.5))
	end
	print(line)
end
