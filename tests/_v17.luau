local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local life = sim:newLife({ seed = 4242, rollOrigin = true })
life.age = 25
life.pending = nil
life.queue = {}
for _, k in pack.stats.order do life.stats[k] = 60 end
life.stats.health = 100
life.money = 50000
life.side = "backstreets"
print("buy piston:", sim:buyGear(life, "aug_piston") ~= nil, life.gear.arm)
print("cap strength:", sim:statCap(life, "strength"))
-- approaches open in a fight
local spec = { stat = "strength", foe = "x", fight = true, coins = 2, base = 4, coinPower = 3 }
local open = {}
for _, id in pack.approaches.order do
	local a = pack.approaches[id]
	if sim:approachOpen(life, a, spec) then table.insert(open, id) end
end
print("open approaches:", table.concat(open, ", "))
-- a trainer
life.stats.strength = 50
life.queue = { "tr_meet_hesketh" }
sim:advance(life, sim.newReport())
print("pending:", life.pending)
local rep = sim:choose(life, 1, nil)
print("chose ask:", rep ~= nil, life.trainer, life.flags.tr_hesketh)
local n = 0
while life.trainer and n < 40 do
	n += 1
	life.actionsLeft = 5
	local r, why = sim:doActivity(life, "tr_lesson_hesketh")
	if not r then print("lesson failed:", why) break end
	life.pending = nil
	life.queue = {}
end
print("lessons:", n, "techniques:", life.flags.tq_counter, life.flags.tq_hook, "cap:", sim:statCap(life, "strength"), "str:", life.stats.strength, "done:", life.flags.tr_hesketh_done)
-- find
life.trainer = nil
local r2 = sim:doActivity(life, "tr_find")
print("find:", r2 ~= nil, life.pending)
