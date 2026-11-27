local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local sim = Engine.new(pack)
local t0 = os.clock()
local x = 0
for i = 1, 5e6 do x += i % 7 end
print("5e6 loop", os.clock() - t0)
local life = sim:newLife({ seed = 77, rollOrigin = true })
t0 = os.clock()
local views = 0
for _ = 1, 20 do
	local guard = 0
	while life.pending and life.alive and guard < 20 do
		guard += 1
		local v = sim:view(life)
		views += 1
		local idx = 1
		for _, c in v.pending.choices do
			if c.enabled then idx = c.index break end
		end
		sim:choose(life, idx)
	end
	if not life.alive then break end
	sim:ageUp(life)
end
print("20 years", os.clock() - t0, "age", life.age, life.alive, "views", views)
t0 = os.clock()
for _ = 1, 20 do sim:view(life) end
print("20 views", os.clock() - t0)
t0 = os.clock()
for _ = 1, 100 do sim:rollEvents(life, 2); life.queue = {} end
print("100 rollEvents", os.clock() - t0)
