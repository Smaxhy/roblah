local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local life = sim:newLife({ seed = 11, rollOrigin = true })
life.age = 25
life.pending = nil
life.side = "backstreets"
local v = sim:view(life)
local arms = {}
for _, item in v.shop or {} do
	if item.slot == "arm" then table.insert(arms, item.id) end
end
print("arms in shop:", #arms, table.concat(arms, " "))
local acts = {}
for _, a in v.activities or {} do
	if string.sub(a.id, 1, 3) == "tr_" then table.insert(acts, a.id .. (if a.enabled == false then "(locked)" else "")) end
end
print("training activities:", table.concat(acts, " "))
