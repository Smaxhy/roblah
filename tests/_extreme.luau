-- probe: the extreme bosses (v0.17) at stats 200..400, fought by tests/loader's plain fighter
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)
local eventOf = { night_sweepers = "ex17_night_out", index_messenger_ex = "ex17_prescript", color_umber = "ex17_color_contract", clocktower_distortion = "ex17_clocktower", head_claw = "ex17_claw", last_hunter = "ex17_last_hunter", aleph_breach = "ex17_aleph" }
local only = process.args[1]
local levels = { 200, 250, 300, 350, 400 }
for _, boss in { "night_sweepers", "index_messenger_ex", "last_hunter", "aleph_breach", "color_umber", "clocktower_distortion", "head_claw" } do
	if only and boss ~= only then continue end
	local row = {}
	for _, lvl in levels do
		local won, died, turns, n = 0, 0, 0, 24
		for i = 1, n do
			local life = sim:newLife({ seed = 770000 + i * 31, rollOrigin = true })
			life.age = 40
			life.capBonus = { all = lvl }
			for _, k in pack.stats.order do
				life.stats[k] = lvl
			end
			life.stats.health = sim:maxHealthOf(life)
			life.pending = nil
			life.queue = {}
			local ev = sim.eventsById[eventOf[boss]]
			local idx = nil
			for ci, c in ev.choices do
				if c.battle == boss then idx = ci end
			end
			life.pending = ev.id
			local rep = sim:choose(life, idx, nil)
			assert(rep and life.battle, "no battle for " .. boss)
			Loader.finishBattle(sim, life)
			local d = life.battleDone
			if d and d.outcome == "won" and life.alive then won += 1 end
			if not life.alive then died += 1 end
			turns += (d and d.last and d.last.turn) or 0
		end
		table.insert(row, string.format("%d: won %3.0f%% died %3.0f%% t%.0f", lvl, won / n * 100, died / n * 100, turns / n))
	end
	print(string.format("%-22s %s", boss, table.concat(row, " | ")))
end
