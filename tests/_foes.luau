local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local sim = Engine.Sim.new(pack)
local counts, names = {}, {}
local function visit(t, depth)
	if type(t) ~= "table" or depth > 9 then return end
	if type(t.clash) == "table" and t.clash.fight then
		local f = sim:foeFor(t.clash)
		local key = f.id .. (if f.kind == "creature" then " [" .. tostring(f.shape) .. "]" else "")
		counts[key] = (counts[key] or 0) + 1
		names[key] = names[key] or {}
		if #names[key] < 200 then table.insert(names[key], tostring(t.clash.foe)) end
	end
	for _, v in t do
		if type(v) == "table" then visit(v, depth + 1) end
	end
end
visit(pack.events, 0)
visit(pack.activities, 0)
visit(pack.expeditions, 0)
local keys = {}
for k in counts do table.insert(keys, k) end
table.sort(keys, function(a, b) return counts[a] > counts[b] end)
for _, k in keys do
	print(counts[k], k)
end
print("---- strangers and creatures:")
for _, k in { "stranger", "distortion [mass]", "abnormality [blob]", "beast [beast]", "ordeal [machine]", "sweeper [tall]", "peccatula [swarm]", "crow [bird]" } do
	if names[k] then print(k .. ": " .. table.concat(names[k], " | ")) end
end
