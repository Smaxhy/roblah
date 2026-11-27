--[[
	Engine checks for the v0.5 systems, on a small test pack layered over the current pack:
	traits, the build (style + stat points), fights with status effects vs quick checks,
	mastery, lore unlocks, today's event, the chronicle ({actor}), announcements and rolls,
	heirs inheriting the family style, forceEvent, and the validator's new checks.
		lune run tests/v5_check
]]

local Loader = require("./loader")

local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
-- these are engine checks: they layer a small test pack over the original (Undermere) pack,
-- which has no lore, traits or chronicle of its own to collide with
Loader.require(root.Config).pack = "Undermere"
local base = Loader.require(root.Pack)
local Sim = Engine.Sim
local Validate = Engine.Validate

local function check(cond, msg)
	if not cond then
		error("FAIL: " .. msg, 2)
	end
end

-- ── a test pack: the real one plus the new sections ─────────────────────────
local pack = table.clone(base)
pack.events = table.clone(base.events)
pack.activities = table.clone(base.activities)
pack.quickChecks = true
pack.traitPicks = 2
pack.traits = {
	order = { "iron_will", "quick_hands", "family_blade", "hidden_one" },
	iron_will = { name = "Iron Will", desc = "Prudence +6.", pick = true, stats = { prudence = 6 }, sanity = 4 },
	quick_hands = { name = "Quick Hands", desc = "+1 base in Justice clashes.", pick = true, clash = { justice = { base = 1 } } },
	family_blade = { name = "Family Blade", desc = "+1 potency in fights.", pick = true, fight = { potency = 1 }, inherit = true },
	hidden_one = { name = "Hidden", desc = "Not pickable.", heads = 5 },
}
pack.styles = {
	order = { "tremor", "rupture", "bleed" },
	tremor = { name = "Tremor", desc = "Shake them apart.", color = { 214, 180, 92 } },
	rupture = { name = "Rupture", desc = "Crack them open.", color = { 96, 200, 170 } },
	bleed = { name = "Bleed", desc = "Make it cost them.", color = { 214, 64, 64 } },
}
pack.maxMastery = 5
pack.build = { points = 10, maxPer = 5, perPoint = 2 }
pack.codex = {
	categories = { { id = "city", name = "The City" } },
	entries = {
		{ id = "lore_a", category = "city", title = "A", text = "Entry A." },
		{ id = "lore_b", category = "city", title = "B", text = "Entry B.", secret = true },
	},
}
pack.chronicle = {
	big_deed = { text = "{name} did a big deed in {district}.", announce = true },
}
pack.daily = {
	order = { "test_day" },
	test_day = { name = "Test Day", desc = "Something happens.", event = "v5_daily_scene" },
}
local adult = { minAge = 0 }
for _, e in {
	{ id = "v5_fight", title = "A Fight", text = "Someone swings.", weight = 0, choices = {
		{ label = "Fight back", clash = { stat = "justice", foe = "Thug", coins = 2, base = 3, coinPower = 2, fight = true, status = "bleed" },
			win = { log = "You won.", codex = "lore_a", rolls = 2 }, lose = { log = "You lost." } },
	} },
	{ id = "v5_check", title = "A Check", text = "A lock.", weight = 0, choices = {
		{ label = "Pick it", clash = { stat = "prudence", foe = "The lock", coins = 1, base = 2, coinPower = 2 },
			win = { log = "Open.", announce = "{name} opened the lock." }, lose = { log = "Stuck." } },
	} },
	{ id = "v5_deed", title = "A Deed", text = "You could do it.", weight = 0, codex = "lore_b", choices = {
		{ label = "Do it", result = { log = "Done.", chronicle = "big_deed", addTrait = "hidden_one", mastery = 2 } },
	} },
	{ id = "v5_heard", title = "Word Gets Around", text = "They say {actor} did something in {actorDistrict}.", weight = 10,
		when = { chronicle = "big_deed" }, choices = {
			{ label = "Huh", result = { log = "You thought about {actor}." } },
		} },
	{ id = "v5_daily_scene", title = "Today", text = "Today's thing.", weight = 0, choices = {
		{ label = "Join in", result = { log = "You joined in.", money = 5 } },
	} },
} do
	e.when = e.when or adult
	table.insert(pack.events, e)
end
table.insert(pack.activities, { id = "v5_today", name = "Today in the City", desc = "Today's event.", daily = true, result = { log = "You went out to see." } })

local issues = Validate.run(pack)
for _, e in issues.errors do
	print("  error: " .. e)
end
check(#issues.errors == 0, "the test pack should validate")

-- ── the build ───────────────────────────────────────────────────────────────
local sim = Sim.new(pack)
local plain = sim:newLife({ seed = 77, originId = pack.origins[1].id })
local built = sim:newLife({
	seed = 77,
	originId = pack.origins[1].id,
	traits = { "iron_will", "quick_hands", "family_blade" }, -- only 2 may be picked
	style = "rupture",
	alloc = { fortitude = 5, prudence = 5, temperance = 5, justice = 5 }, -- only 10 points
})
check(#built.traits == 2, "only traitPicks traits are taken (got " .. #built.traits .. ")")
check(built.traits[1] == "iron_will" and built.traits[2] == "quick_hands", "picked traits kept in order")
check(built.style == "rupture", "style picked")
local spent = 0
for _, k in { "fortitude", "prudence", "temperance", "justice" } do
	spent += built.stats[k] - plain.stats[k]
end
-- 10 points x2 = 20, plus Iron Will's +6 prudence
check(spent == 26, "10 bonus points (x2) and Iron Will's +6 land on the stats (got " .. spent .. ")")
local cheat = sim:newLife({ seed = 78, originId = pack.origins[1].id, traits = { "hidden_one" } })
check(#cheat.traits == 0, "a trait that isn't pickable can't be picked")
print("build: traits, style and stat points are limited the way they should be")

-- ── fights vs checks ────────────────────────────────────────────────────────
local function present(life, id)
	life.pending = nil
	life.run = nil
	local report = assert(sim:forceEvent(life, id))
	check(life.pending == id or not sim.eventsById[id].choices, "forceEvent presents " .. id)
	return report
end
local life = sim:newLife({ seed = 91, originId = pack.origins[1].id, style = "bleed", traits = { "family_blade" } })
life.age = 25
life.stats.justice = 60
present(life, "v5_fight")
local report = assert(sim:choose(life, 1, "steady"))
check(report.clash and report.clash.fight == true, "a fight reports fight = true")
check(report.clash.player.status and report.clash.player.status.id == "bleed", "your style rides along in a fight")
check(report.clash.player.status.potency == 2, "Family Blade adds +1 potency (got " .. tostring(report.clash.player.status.potency) .. ")")
check(report.clash.foe.status and report.clash.foe.status.id == "bleed", "the foe's status is set")
local sawStatus = false
for _, r in report.clash.rounds do
	if r.pStatus or r.fStatus then
		sawStatus = true
	end
end
check(sawStatus, "fight rounds carry status counters")
if report.clash.won then
	check(life.codex.lore_a, "winning unlocks lore")
	check(report.rolls == 2, "winning earns 2 rolls")
end
present(life, "v5_check")
local r2 = assert(sim:choose(life, 1, "steady"))
check(r2.clash and not r2.clash.fight and r2.clash.player.status == nil, "a check has no statuses")
print(string.format("fights: style status (bleed x%d) and foe status in play; checks stay plain", report.clash.player.status.potency))

-- ── lore, mastery, traits from results, the chronicle ───────────────────────
local before = life.mastery
local r3 = present(life, "v5_deed")
check(life.codex.lore_b and r3.codex and table.find(r3.codex, "lore_b"), "an event's codex unlocks when it shows up")
local r4 = assert(sim:choose(life, 1))
check(life.mastery == math.min(5, before + 2), "mastery +2")
check(sim:hasTrait(life, "hidden_one"), "addTrait from a result")
check(r4.chronicle and r4.chronicle[1].act == "big_deed", "the deed goes to the chronicle")

-- another player's life on the same server hears about it
local other = sim:newLife({ seed = 120, originId = pack.origins[1].id })
other.age = 30
check(not sim:eligible(other, sim.eventsById.v5_heard), "no chronicle, no rumor")
sim:setChronicle({ { act = "big_deed", name = "Ada Vance", district = pack.districts.order[1], lifeId = life.id, userId = 1 } })
check(sim:eligible(other, sim.eventsById.v5_heard), "the rumor is eligible once someone did it")
check(not sim:eligible(life, sim.eventsById.v5_heard), "you don't hear rumors about yourself")
present(other, "v5_heard")
local text = sim:view(other).pending.text
check(string.find(text, "Ada Vance", 1, true) ~= nil, "{actor} is the other player: " .. text)
check(string.find(text, pack.districts[pack.districts.order[1]].name, 1, true) ~= nil, "{actorDistrict} is where they did it")
local r5 = assert(sim:choose(other, 1))
local logged = false
for _, e in r5.entries do
	if e.text and string.find(e.text, "Ada Vance", 1, true) then
		logged = true
	end
end
check(logged, "the result log names the actor too")
check(other.actor == nil, "the actor clears after the event")
print("chronicle: one player's deed reaches another's life by name")

-- announcements
present(life, "v5_check")
local r6
for _ = 1, 20 do
	life.stats.prudence = 100
	r6 = assert(sim:choose(life, 1, "careful"))
	if r6.clash.won then
		break
	end
	present(life, "v5_check")
end
check(r6.clash.won and r6.announce and string.find(r6.announce[1], life.first, 1, true), "announce renders the name")

-- ── today's event ───────────────────────────────────────────────────────────
local dl = sim:newLife({ seed = 140, originId = pack.origins[1].id })
dl.age = 20
local function dailyAct(l)
	for _, a in sim:view(l).activities do
		if a.daily then
			return a
		end
	end
	return nil
end
check(dailyAct(dl) and not dailyAct(dl).enabled, "no daily event set: the activity is off")
sim:setDaily("test_day", 20000)
check(dailyAct(dl).enabled, "today's event is on")
local rd = assert(sim:doActivity(dl, "v5_today"))
check(rd.dailyDone == 20000 and dl.pending == "v5_daily_scene", "doing it brings today's scene and marks the day")
assert(sim:choose(dl, 1))
dl.actionsLeft = 3
check(not dailyAct(dl).enabled, "once a day")
sim:setDaily("test_day", 20001)
check(dailyAct(dl).enabled, "back the next day")
check(sim:view(dl).daily.name == "Test Day", "the view carries today's event")
print("daily: one scene a day, the same id everywhere")

-- ── heirs keep the family style ─────────────────────────────────────────────
local parent = sim:newLife({ seed = 160, originId = pack.origins[1].id, style = "tremor", traits = { "family_blade", "iron_will" } })
parent.mastery = 4
parent.age = 40
local childRel = sim:addRelation(parent, { kind = "child", age = 18 })
sim:kill(parent, sim.newReport(), "Test")
local heir = sim:newLifeFromHeir(parent, childRel.id, 161)
check(heir.style == "tremor", "the heir fights the family way")
check(heir.mastery == 2, "half the mastery passes down")
check(sim:hasTrait(heir, "family_blade") and not sim:hasTrait(heir, "iron_will"), "only inherit = true traits pass down")
print("heirs: style, half the mastery, and family traits pass down")

-- ── the validator catches bad references ────────────────────────────────────
local bad = table.clone(pack)
bad.events = table.clone(pack.events)
table.insert(bad.events, { id = "v5_bad", title = "Bad", text = "Bad.", weight = 0, codex = "nope", choices = {
	{ label = "x", requires = { trait = "nope", style = "nope", chronicle = "nope", daily = "nope" },
		result = { log = "x", addTrait = "nope", style = "nope", codex = "nope", chronicle = "nope" } },
	{ label = "y", clash = { stat = "justice", foe = "z", status = "freezing" }, win = { log = "w" }, lose = { log = "l" } },
} })
local badIssues = Validate.run(bad)
local want = { "unknown codex entry 'nope'", "unknown trait 'nope'", "unknown style 'nope'", "unknown chronicle act 'nope'", "unknown daily event 'nope'", "clash.status must be one of" }
for _, w in want do
	local found = false
	for _, e in badIssues.errors do
		if string.find(e, w, 1, true) then
			found = true
		end
	end
	check(found, "validator reports: " .. w)
end
print("validator: unknown traits, styles, lore, chronicle acts, daily ids and statuses are errors")

print("OK")
