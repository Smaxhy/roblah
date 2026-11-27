--[[
	Charter balance probe: a sensible player born in the Charter who never moves
	Ward, takes the best-paying job at 18 and keeps training. How often do they
	get evicted for debt, and when?
		lune run tests/charter_probe [lives] [legacy]
]]
local process = require("@lune/process")
local Loader = require("./loader")

local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local N = tonumber(process.args[1]) or 300
if process.args[2] == "legacy" then
	pack.sides.charter.costMult = 3
	pack.sides.charter.evictGrace = 0
end
local sim = Engine.new(pack)
local Rng = Engine.Rng

local evicted, ages, inCharter40, born, total = 0, {}, 0, 0, 0
local died, stuck, noChoice = 0, 0, 0
local byEvent = 0
for i = 1, N * 4 do
	if born >= N then
		break
	end
	local life = sim:newLife({ seed = 50000 + i * 13, originId = "company_family" })
	if life.side == "charter" then
		born += 1
		local brain = { rng = Rng.seed(i * 7 + 3) }
		local firstEviction = nil
		local guard = 0
		while life.alive and life.age < 60 and guard < 300 do
			guard += 1
			if life.pending then
				local v = sim:view(life)
				local best, bestScore = nil, -math.huge
				for idx, c in v.pending.choices do
					if c.enabled then
						local score = Rng.next(brain) + (if c.clash then (c.clash.odds - 0.5) * 2 else 0)
						if score > bestScore then
							best, bestScore = idx, score
						end
					end
				end
				if not best then
					noChoice += 1
					break
				end
				sim:choose(life, best, "steady")
			else
				if not life.career and life.age >= 18 then
					local v = sim:view(life)
					local pick, pay = nil, -1
					for _, c in v.careers do
						if c.enabled and c.salary > pay then
							pick, pay = c.id, c.salary
						end
					end
					if pick then
						sim:joinCareer(life, pick)
					end
				end
				for _ = 1, 2 do
					if life.pending or not life.alive or life.actionsLeft <= 0 then
						break
					end
					local v = sim:view(life)
					local open = {}
					for _, a in v.activities do
						if a.enabled and not a.move and not a.shop and not a.market and not a.clash then
							open[a.id] = true
						end
					end
					local id = if open.study then "study" elseif open.train then "train" elseif open.still then "still" else nil
					if not id then
						break
					end
					sim:doActivity(life, id)
				end
				if not life.pending and life.alive then
					local before = life.side
					Loader.ageUp(sim, life)
					if before == "charter" and life.side ~= "charter" and not firstEviction then
						firstEviction = life.age
					end
				end
			end
			if life.side ~= "charter" and not firstEviction then
				-- left through an event or activity rather than the rent
				byEvent += 1
				break
			end
			if life.age == 40 and life.side == "charter" and not life.pending then
				inCharter40 += 1
						break
			end
		end
		total += 1
		if not life.alive and life.age < 40 then
			died += 1
		elseif guard >= 300 then
			stuck += 1
		end
		if firstEviction then
			evicted += 1
			table.insert(ages, firstEviction)
		end
	end
end
table.sort(ages)
print(string.format("  died before 40: %d   stuck: %d   no enabled choice: %d", died, stuck, noChoice))
print(string.format("Charter-born sensible players: %d", total))
print(string.format("  evicted for debt before 40: %d (%d%%)", evicted, math.floor(evicted / math.max(1, total) * 100 + 0.5)))
print(string.format("  still in the Charter at 40: %d (%d%%)", inCharter40, math.floor(inCharter40 / math.max(1, total) * 100 + 0.5)))
if #ages > 0 then
	print(string.format("  age when they left: median %d, earliest %d", ages[math.max(1, #ages // 2)], ages[1]))
end
print(string.format("  left through an event instead: %d (%d%%)", byEvent, math.floor(byEvent / math.max(1, total) * 100 + 0.5)))
