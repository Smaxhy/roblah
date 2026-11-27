-- probe: a boss battle, fought by the plain-minded fighter in tests/loader, at a few stat levels
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local bossIds = { "capo_brandimarte", "sottocapo_ferrante", "big_brother_ugo", "the_bellringer", "rcorp_rhino" }
local eventOf = { capo_brandimarte = "b15_thumb_capo", sottocapo_ferrante = "b15_thumb_sottocapo", big_brother_ugo = "b15_middle_big", the_bellringer = "b15_bellringer", rcorp_rhino = "b15_rcorp_rhino" }
for _, boss in bossIds do
	for _, lvl in { 60, 75, 90 } do
		local won, died, turns, n = 0, 0, 0, 40
		for i = 1, n do
			local life = sim:newLife({ seed = 880000 + i * 17, rollOrigin = true })
			life.age = 30
			for _, k in pack.stats.order do
				life.stats[k] = lvl
			end
			life.stats.health = 100
			life.pending = nil
			life.queue = {}
			local ev = sim.eventsById[eventOf[boss]]
			local idx = nil
			for ci, c in ev.choices do
				if c.battle == boss then
					idx = ci
				end
			end
			life.pending = ev.id
			local rep = sim:choose(life, idx, nil)
			assert(rep and life.battle, "the battle didn't start for " .. boss)
			Loader.finishBattle(sim, life)
			local d = life.battleDone
			if d and d.outcome == "won" and life.alive then
				won += 1
			end
			if not life.alive then
				died += 1
			end
			turns += (d and d.last and d.last.turn) or 0
		end
		print(string.format("%-20s stats %3d: won %3.0f%%  died %3.0f%%  turns %.1f", boss, lvl, won / n * 100, died / n * 100, turns / n))
	end
end
