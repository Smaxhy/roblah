-- stat curve and clash win rates for a random-but-busy player
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local sim = Engine.Sim.new(pack)
local N = tonumber((...)) or 150
local at = { [12] = {}, [20] = {}, [30] = {}, [40] = {}, [50] = {} }
local wins, total = {}, {}
local deaths = {}
local rngState = 7
local rng = { NextInteger = function(_, a, b) rngState = (rngState * 48271) % 2147483647; return a + (rngState % (b - a + 1)) end }
for i = 1, N do
	local life = sim:newLife({ seed = i * 104729, rollOrigin = true })
	while life.alive and life.age < 70 do
		local rep = Loader.ageUp(sim, life)
		local guard = 0
		while life.alive and life.pending and guard < 30 do
			guard += 1
			local v = sim:view(life)
			local opts = {}
			for ci, c in v.pending.choices do if c.enabled then table.insert(opts, ci) end end
			if #opts == 0 then life.pending = nil break end
			local ci = opts[rng:NextInteger(1, #opts)]
			local c = v.pending.choices[ci]
			local ap = nil
			if c.clash then ap = ({ "steady", "steady", "reckless", "careful" })[rng:NextInteger(1, 4)] end
			local r = sim:choose(life, ci, ap)
			if r and r.clash then
				local band = math.floor(life.age / 10) * 10
				total[band] = (total[band] or 0) + 1
				if r.clash.won then wins[band] = (wins[band] or 0) + 1 end
			end
		end
		for _ = 1, 3 do
			if not life.alive or life.pending then break end
			local v = sim:view(life)
			local acts = {}
			local heal = nil
			for _, a in v.activities do
				if a.enabled and not a.move and not a.shop and not a.market then
					table.insert(acts, a.id)
					if (a.id == "clinic" or a.id == "stitcher" or a.id == "rest") and life.stats.health < 35 then heal = a.id end
				end
			end
			if heal then acts = { heal } end
			if #acts == 0 then break end
			local r = sim:doActivity(life, acts[rng:NextInteger(1, #acts)])
			if r and r.clash then
				local band = math.floor(life.age / 10) * 10
				total[band] = (total[band] or 0) + 1
				if r.clash.won then wins[band] = (wins[band] or 0) + 1 end
			end
		end
		if at[life.age] and life.alive then
			local s = life.stats
			table.insert(at[life.age], { (s.health + s.mind + s.intelligence + s.strength) / 4, math.max(s.health, s.mind, s.intelligence, s.strength) })
		end
	end
	table.insert(deaths, life.age)
end
for _, a in { 12, 20, 30, 40, 50 } do
	local m, mx = 0, 0
	for _, r in at[a] do m += r[1]; mx += r[2] end
	local n = math.max(1, #at[a])
	print(string.format("age %d: alive %3d  mean virtue %5.1f  best virtue %5.1f", a, #at[a], m / n, mx / n))
end
local bands = {}
for b in total do table.insert(bands, b) end
table.sort(bands)
for _, b in bands do print(string.format("clashes at %2d-%2d: %4d, won %3d%%", b, b + 9, total[b], math.floor(100 * (wins[b] or 0) / total[b] + 0.5))) end
table.sort(deaths)
print("median death age", deaths[math.floor(#deaths / 2) + 1])
