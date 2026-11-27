local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local deaths = {}
for n = 0, 20 do
	local life = sim:newLife({ seed = 1300 + n * 101, rollOrigin = true })
	local guard = 0
	while life.alive and guard < 400 do
		guard += 1
		if life.run then life.run = nil
		elseif life.pending then
			local v = sim:view(life)
			local pick = nil
			for _, c in v.pending.choices do if c.enabled then pick = c.index break end end
			if not pick or not sim:choose(life, pick, nil) then life.pending = nil end
		elseif life.age >= 24 then break
		else Loader.ageUp(sim, life) end
	end
	print(n, life.age, life.alive, life.cause or (life.death and life.death.cause), guard, life.pending, life.battle ~= nil, life.duel ~= nil)
end
