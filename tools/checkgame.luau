--[[
	CHECK A GAME made with the blueprint: everything the content needs to be right, in one go.

		lune run tools/checkgame <Id>              validate, count, lint, 40 headless lives
		lune run tools/checkgame <Id> --lives 200  more lives (slower, steadier numbers)
		lune run tools/checkgame <Id> --quick      validate, count and lint only

	1. VALIDATE: Engine/Validate.luau on the built pack (every key, every id, every reference)
	2. COUNT: what the game has (cards by age, careers, dungeons by tier, bosses, places...)
	3. LINT: things the validator can't know are wrong: a fight whose `enemy` isn't a foe, a
	   `battle` with no boss, a boss whose `enemy` has no look, stat keys that aren't stats,
	   ages with no cards, careers nobody can reach, a store item with no grants
	4. PLAY: headless lives (tests/run.luau): runtime errors, lifespans, fights won, events seen
	Exit code 1 if anything is an error.
]]

local process = require("@lune/process")
local Loader = require("../tests/loader")

local args = process.args
local id = args[1]
if not id or string.sub(id, 1, 2) == "--" then
	print("usage: lune run tools/checkgame <Id> [--lives N] [--quick]")
	process.exit(1)
end
local livesN = 40
for i, a in args do
	if a == "--lives" then
		livesN = tonumber(args[i + 1]) or livesN
	end
end
local quick = table.find(args, "--quick") ~= nil

process.env.LIFESIM_PACK = id
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Config = Loader.require(root.Config)
Config.pack = id
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
if pack.id ~= id then
	print(string.format("checkgame: the pack that loaded is %s, not %s (is src/shared/Games/%s there?)", tostring(pack.id), id, id))
	process.exit(1)
end

local errors, warnings = 0, 0
local function err(msg: string)
	errors += 1
	print("  ERROR " .. msg)
end
local function warn(msg: string)
	warnings += 1
	print("  warn  " .. msg)
end

-- ── 1. validate ──
print(string.format("== %s: %s", id, tostring(pack.meta and pack.meta.title)))
local issues = Engine.Validate.run(pack)
for _, e in issues.errors do
	err(e)
end
for _, w in issues.warnings do
	warn(w)
end
for _, m in pack.mergeIssues or {} do
	err(m)
end

-- ── 2. count ──
local own, base = 0, 0
local byAge = { child = 0, teen = 0, adult = 0, elder = 0 }
local dangerous, fights, bossCards = 0, 0, 0
for _, e in pack.events do
	if e.source == "Base" then
		base += 1
	else
		own += 1
		local w = e.when or {}
		local lo, hi = w.minAge or 0, w.maxAge or 120
		if lo <= 12 then
			byAge.child += 1
		end
		if lo <= 17 and hi >= 13 then
			byAge.teen += 1
		end
		if hi >= 18 and lo <= 55 then
			byAge.adult += 1
		end
		if hi >= 56 then
			byAge.elder += 1
		end
		for _, t in e.tags or {} do
			if t == "danger" then
				dangerous += 1
			end
		end
		for _, c in e.choices or {} do
			if type(c) == "table" and c.clash and c.clash.fight then
				fights += 1
			end
			if type(c) == "table" and c.battle then
				bossCards += 1
			end
		end
	end
end
local Expedition = Engine.Expedition
local tiers = { 0, 0, 0, 0, 0 }
local sim = Engine.Sim.new(pack)
for _, xid in pack.expeditions.order do
	local t = Expedition.tier(sim, pack.expeditions[xid])
	tiers[t] += 1
end
local nBosses, nFoes, nStore = 0, #pack.foes.order, 0
for _ in pack.bosses or {} do
	nBosses += 1
end
for _ in (pack.store and pack.store.items) or {} do
	nStore += 1
end
print(string.format("cards: %d of its own (+%d from Base): child %d, teen %d, adult %d, elder %d; %d dangerous, %d fights, %d boss battles",
	own, base, byAge.child, byAge.teen, byAge.adult, byAge.elder, dangerous, fights, bossCards))
print(string.format("careers %d, activities %d, origins %d, gear %d, foes %d, bosses %d", #pack.careers.order, #pack.activities, #pack.origins, #pack.gear.order, nFoes, nBosses))
print(string.format("dungeons %d (tier I %d, II %d, III %d, IV %d, V %d), places %d, store items %d",
	#pack.expeditions.order, tiers[1], tiers[2], tiers[3], tiers[4], tiers[5], #(pack.places or {}), nStore))

-- ── 3. lint ──
local statIds = {}
for _, s in pack.stats.order do
	statIds[s] = true
end
local ROLE_WORDS = { fight = true, work = true, charm = true, will = true }
local function lintResult(where: string, r: any)
	if type(r) ~= "table" then
		return
	end
	for k in r do
		if ROLE_WORDS[k] and not statIds[k] then
			err(string.format("%s: `%s` is a role, not one of this game's stats (use the stat's id)", where, k))
		end
	end
end
local function lintClash(where: string, c: any)
	if type(c) ~= "table" then
		return
	end
	if c.stat and not statIds[c.stat] then
		err(string.format("%s: clash stat '%s' isn't a stat of this game", where, tostring(c.stat)))
	end
	if c.enemy and not pack.foes[c.enemy] then
		warn(string.format("%s: enemy '%s' isn't in the foes (the fight shows a stranger)", where, tostring(c.enemy)))
	end
end
for _, e in pack.events do
	if e.source ~= "Base" then
		lintResult(e.id, e.result)
		for i, c in e.choices or {} do
			local where = e.id .. " choice " .. i
			if type(c) == "table" then
				lintClash(where, c.clash)
				lintResult(where, c.result)
				lintResult(where, c.win)
				lintResult(where, c.lose)
				-- (one boss, or a list of bosses: each time, one of them)
				for _, b in (if type(c.battle) == "table" then c.battle else { c.battle }) do
					if not (pack.bosses and pack.bosses[b]) then
						err(where .. ": battle '" .. tostring(b) .. "' isn't a boss")
					end
				end
				if c.battle and not c.clash then
					warn(where .. ": a battle with no clash falls back to nothing when battles are off")
				end
			end
		end
	end
end
for bid, b in pack.bosses or {} do
	if not (b.enemy and pack.foes[b.enemy]) then
		warn("boss " .. bid .. ": enemy '" .. tostring(b.enemy) .. "' isn't a foe, so it has no look")
	end
	if not b.moves or #b.moves == 0 then
		err("boss " .. bid .. ": no moves")
	end
end
for _, xid in pack.expeditions.order do
	for sid, stage in pack.expeditions[xid].stages or {} do
		for i, c in stage.choices or {} do
			lintClash(string.format("dungeon %s stage %s choice %d", xid, sid, i), c.clash)
		end
	end
end
for cid, c in pack.careers do
	if type(c) == "table" and cid ~= "order" then
		if c.promoteStat and not statIds[c.promoteStat] then
			err("career " .. cid .. ": promoteStat '" .. tostring(c.promoteStat) .. "' isn't a stat")
		end
		if c.ranks and c.salary and #c.ranks ~= #c.salary then
			err("career " .. cid .. ": " .. #c.ranks .. " ranks but " .. #c.salary .. " salaries")
		end
	end
end
for _, item in (pack.store and pack.store.items) or {} do
	if not item.grants or #item.grants == 0 then
		err("store item " .. tostring(item.key) .. ": grants nothing")
	end
	if item.random and not item.odds then
		err("store item " .. tostring(item.key) .. ": random, with no odds shown (Roblox requires them)")
	end
end
local AGE_WORDS = { child = "childhood (0-12)", teen = "the teen years (13-17)", adult = "adult life (18-55)", elder = "old age (56+)" }
for _, age in { "child", "teen", "adult", "elder" } do
	if byAge[age] == 0 then
		warn("no cards of the game's own for " .. AGE_WORDS[age] .. ": those years are only Base's filler")
	end
end
if own < 40 then
	warn(string.format("only %d cards of its own: a life will repeat itself (aim for 150+, 300+ for a full game)", own))
end

-- ── 4. play ──
if not quick then
	print(string.format("== %d headless lives (tests/run.luau)", livesN))
	local r = process.exec("lune", { "run", "tests/run", tostring(livesN) }, { env = { LIFESIM_PACK = id } })
	local out = r.stdout .. "\n" .. r.stderr
	local keep = { "Played", "Lifespan", "Reached", "Clashes", "Expeditions", "Boss battles", "Events fired", "Causes of death" }
	for line in string.gmatch(out, "[^\n]+") do
		for _, k in keep do
			if string.find(line, k, 1, true) == 1 then
				print("  " .. line)
			end
		end
	end
	if string.find(out, "RUNTIME ERRORS", 1, true) then
		local after = string.match(out, "RUNTIME ERRORS:(.*)") or ""
		local n = 0
		for line in string.gmatch(after, "[^\n]+") do
			n += 1
			if n <= 8 then
				err("runtime: " .. line)
			end
		end
	end
	if not r.ok and not string.find(out, "RUNTIME ERRORS", 1, true) then
		err("the headless run failed: " .. string.sub(out, -600))
	end
end

print(string.format("\n%s: %d errors, %d warnings", id, errors, warnings))
if errors > 0 then
	process.exit(1)
end
