-- probe: a duel in turns on the original (Undermere) pack: strikes exist and it ends
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "Undermere"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local Pvp = Engine.Pvp
local function grown(seed)
	local life = sim:newLife({ seed = seed })
	life.age = 30
	life.pending = nil
	life.queue = {}
	return life
end
local a, b = grown(5101), grown(5102)
local lives = { [tostring(a.id)] = a, [tostring(b.id)] = b }
local d = Pvp.start(sim, a, b, false)
local va = Pvp.view(sim, d, lives, tostring(a.id))
local strikes = 0
for _, o in va.options do
	if o.action == "strike" then
		strikes += 1
	end
	print("  option", o.action, o.approach or "", o.stat or "", o.hit or "", o.odds or "")
end
assert(strikes >= 1, "no strikes in the original pack")
local turns = 0
while not d.done and turns < 40 do
	turns += 1
	Pvp.choose(sim, d, lives, tostring(a.id), "strike", va.options[1].approach)
	Pvp.choose(sim, d, lives, tostring(b.id), if turns % 3 == 0 then "feint" else "strike", va.options[2].approach)
	Pvp.resolve(sim, d, lives)
end
assert(d.done, "the duel never ended")
Pvp.finish(sim, d, lives)
print(string.format("undermere duel: %d strikes on offer, ended in %d turns, both alive: %s", strikes, turns, tostring(a.alive and b.alive)))
