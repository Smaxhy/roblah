-- probe: a Bloodfiend (and a human) lived out as long as they last, picking the first open choice
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local form = process.args[1] or "bloodfiend"
local n = tonumber(process.args[2]) or 4
local ages = {}
for i = 1, n do
	local life = sim:newLife({ seed = 900 + i, rollOrigin = true })
	local guard = 0
	while life.alive and guard < 2000 do
		guard += 1
		if life.age == 20 and form == "bloodfiend" and life.form ~= "bloodfiend" then
			sim:setForm(life, "bloodfiend", {})
		end
		if life.pending then
			local v = sim:view(life)
			local pick = nil
			for ci, c in v.pending.choices do
				if c.enabled then
					pick = ci
					break
				end
			end
			if not pick or not sim:choose(life, pick, "power") then
				life.pending = nil
			end
		else
			Loader.ageUp(sim, life)
			if life.stats.health < 60 then
				life.stats.health = 80
			end
		end
	end
	local v = sim:view(life)
	print(string.format("life %d: form %s died at %d (%s), lifespan %d, blood %s, str %d spd %d (caps %d/%d)", i, tostring(life.form), life.age, tostring(life.cause or (life.death and life.death.cause)), v.lifespan or -1, tostring(life.bloodStage), life.stats.strength, life.stats.speed, sim:statCap(life, "strength"), sim:statCap(life, "speed")))
	table.insert(ages, life.age)
end
