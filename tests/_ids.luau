local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local pack = Loader.require(root.Pack)
for _, cat in { "outfit", "accessory", "weapon", "hair", "hairColor", "skin", "eyes", "mark" } do
	local ids = {}
	for _, o in pack.cosmetics[cat].options do table.insert(ids, o.id) end
	print(cat .. " (" .. #ids .. "): " .. table.concat(ids, " "))
end
