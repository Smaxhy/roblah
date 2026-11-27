--[[
	Which events hurt the most? Average Fortitude change per event (a clash
	counts its win and lose results half each), grouped by module.
		lune run tests/harm_report
]]
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local pack = Loader.pack(root)

local function avg(v)
	if type(v) == "number" then
		return v
	elseif type(v) == "table" then
		return (v[1] + v[2]) / 2
	end
	return 0
end
local function fort(r)
	if type(r) ~= "table" then
		return 0
	end
	return avg(r[pack.stats.vital or "fortitude"]) + (if r.die then -100 else 0)
end
local rows = {}
for _, e in pack.events do
	local total, n = 0, 0
	if e.result then
		total += fort(e.result)
		n += 1
	end
	for _, c in e.choices or {} do
		if c.clash then
			total += (fort(c.win) + fort(c.lose)) / 2
		else
			total += fort(c.result)
		end
		n += 1
	end
	if n > 0 then
		table.insert(rows, { id = e.id, harm = total / n, weight = e.weight or 10 })
	end
end
table.sort(rows, function(a, b)
	return a.harm * a.weight < b.harm * b.weight
end)
print("most harmful events (avg Fortitude per choice x weight):")
for i = 1, 20 do
	local r = rows[i]
	if r then
		print(string.format("  %-40s %6.1f  (weight %d)", r.id, r.harm, r.weight))
	end
end
