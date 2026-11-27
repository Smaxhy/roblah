local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local Pvp = Engine.Pvp
local acts = { "strike", "strike", "strike", "guard", "feint", "recover" }
for _, blood in { false, true } do
	local turnsTotal, n, deaths = 0, 30, 0
	for i = 1, n do
		local a = sim:newLife({ seed = 100 + i, rollOrigin = true })
		local b = sim:newLife({ seed = 900 + i, rollOrigin = true })
		for _, l in { a, b } do
			l.age = 30
			for _, k in pack.stats.order do l.stats[k] = 70 + math.random(0, 30) end
			l.stats.health = 140
			l.pending = nil
		end
		local d = Pvp.start(sim, a, b, blood)
		local lives = { [tostring(a.id)] = a, [tostring(b.id)] = b }
		local guard = 0
		while not d.done and guard < 60 do
			guard += 1
			for _, l in { a, b } do
				local opts = Pvp.options(sim, d, lives, tostring(l.id))
				local act = acts[math.random(1, #acts)]
				local approach = nil
				if act == "strike" then
					local strikes = {}
					for _, o in opts do if o.action == "strike" then table.insert(strikes, o) end end
					approach = strikes[math.random(1, #strikes)].approach
				end
				local ok, why = Pvp.choose(sim, d, lives, tostring(l.id), act, approach)
				if why then
					Pvp.choose(sim, d, lives, tostring(l.id), "guard", nil)
				end
			end
			Pvp.resolve(sim, d, lives)
		end
		local reports = Pvp.finish(sim, d, lives)
		turnsTotal += d.turn - 1
		if not a.alive or not b.alive then deaths += 1 end
		if i == 1 then
			local v = Pvp.view(sim, d, lives, tostring(a.id))
			print(string.format("  sample: %d turns, outcome %s, winner %s, hp %d/%d vs %d/%d", d.turn - 1, tostring(d.outcome), tostring(d.winner == tostring(a.id) and "A" or "B"), v.me.hp, v.me.start, v.them.hp, v.them.start))
			for _, e in d.log do print("    " .. e.text) end
		end
	end
	print(string.format("%s duels: avg %.1f turns, %d of %d ended in a death", if blood then "blood" else "friendly", turnsTotal / n, deaths, n))
end
