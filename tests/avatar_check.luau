--[[
	Avatar checks: every cosmetic option, gear look, condition look and form
	builds a figure made of well-formed parts, at every age stage.
		lune run tests/avatar_check
]]
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local Avatar = Engine.Avatar

local problems = 0
local builds = 0
local function check(ap, opts, label)
	local parts, frame = Avatar.build(pack, ap, opts)
	builds += 1
	assert(#parts > 5, label .. ": too few parts")
	for i, p in parts do
		local where = label .. " part " .. i .. " (" .. tostring(p.name) .. ")"
		local function vec(v, n)
			if type(v) ~= "table" or #v ~= 3 then
				print("BAD " .. n .. ": " .. where)
				problems += 1
				return
			end
			for _, x in v do
				if type(x) ~= "number" or x ~= x then
					print("BAD " .. n .. " value: " .. where)
					problems += 1
				end
			end
		end
		vec(p.size, "size")
		vec(p.pos, "pos")
		vec(p.color, "color")
		if p.rot then
			vec(p.rot, "rot")
		end
		if p.shape ~= "box" and p.shape ~= "ball" and p.shape ~= "cyl" then
			print("BAD shape: " .. where)
			problems += 1
		end
		if p.shape == "cyl" and math.abs(p.size[1] - p.size[3]) > 1e-6 then
			print("BAD cylinder (x and z must match): " .. where)
			problems += 1
		end
		for _, c in p.color do
			if c < 0 or c > 255 then
				print("BAD color range: " .. where)
				problems += 1
			end
		end
	end
	assert(frame.height > frame.headY and frame.headY > 0, label .. ": bad frame")
	return parts, frame
end

local base = Avatar.defaultLook(pack)
for _, category in Avatar.CATEGORIES do
	for _, o in (pack.cosmetics[category] and pack.cosmetics[category].options) or {} do
		local look = table.clone(base)
		look[category] = o.id
		for _, age in { 2, 7, 11, 15, 30, 72 } do
			check({ look = look, age = age, form = "human", sanity = 0 }, nil, category .. "=" .. o.id .. " age " .. age)
		end
	end
end
for id, g in pack.gear do
	if type(g) == "table" and g.slot then
		check({ look = base, age = 30, gear = { [g.slot] = id } }, nil, "gear " .. id)
	end
end
for id in pack.conditions do
	check({ look = base, age = 30, conditions = { id } }, nil, "condition " .. id)
end
for id in pack.forms do
	check({ look = base, age = 30, form = id, sanity = -30 }, { portrait = true }, "form " .. id)
end
-- everything at once (taken from the pack, so this works for any pack)
local function firstFree(category)
	for _, o in (pack.cosmetics[category] and pack.cosmetics[category].options) or {} do
		if not o.record and not o.store and not o.daily and not (o.glow and o.glow > 0) then
			return o.id
		end
	end
	return base[category]
end
local everyLook = table.clone(base)
for _, category in { "skin", "hair", "hairColor", "outfit", "mark", "eyes", "accessory" } do
	if pack.cosmetics[category] then
		everyLook[category] = firstFree(category)
	end
end
local oddForm = "human"
for id in pack.forms do
	if id ~= "human" then
		oddForm = id
		break
	end
end
local everyGear = {}
for _, id in pack.gear.order or {} do
	local g = pack.gear[id]
	if g and g.slot and not everyGear[g.slot] then
		everyGear[g.slot] = id
	end
end
local someConditions = {}
for id in pack.conditions do
	if #someConditions < 4 then
		table.insert(someConditions, id)
	end
end
local full = check({
	look = everyLook,
	age = 44,
	form = oddForm,
	sanity = 20,
	gear = everyGear,
	conditions = someConditions,
}, { ground = true }, "everything")
local portrait = check({ look = base, age = 30 }, { portrait = true }, "portrait")
local whole = check({ look = base, age = 30 }, nil, "whole")
assert(#portrait < #whole, "portrait should skip the legs")

-- sanitize: locked and unknown picks fall back (using whatever locked options the pack has)
local function lockedOption(category, kind)
	for _, o in (pack.cosmetics[category] and pack.cosmetics[category].options) or {} do
		if (kind == "record" and o.record) or (kind == "glow" and o.glow and o.glow > 0 and not o.record and not o.store) then
			return o
		end
	end
	return nil
end
local freeSkin = firstFree("skin")
local recordHair = lockedOption("hair", "record")
local glowOutfit = lockedOption("outfit", "glow")
local clean = Avatar.sanitize(pack, { skin = freeSkin, hair = recordHair and recordHair.id, hairColor = "nope", outfit = glowOutfit and glowOutfit.id, mark = 7 }, function(category, option)
	return Avatar.usable(category, option, {}, {})
end)
assert(clean.skin == freeSkin, "free skin kept")
if recordHair then
	assert(clean.hair == base.hair, "record-locked hair dropped")
end
assert(clean.hairColor == base.hairColor, "unknown color dropped")
if glowOutfit then
	assert(clean.outfit == base.outfit, "glow-locked outfit dropped")
end
assert(clean.mark == base.mark, "bad type dropped")
if recordHair and glowOutfit then
	local unlocked = Avatar.sanitize(pack, { outfit = glowOutfit.id, hair = recordHair.id }, function(category, option)
		return Avatar.usable(category, option, { ["outfit:" .. glowOutfit.id] = true }, { [recordHair.record] = 1 })
	end)
	assert(unlocked.outfit == glowOutfit.id and unlocked.hair == recordHair.id, "unlocked picks kept")
end

-- engine: looks on new lives, families resemble you, heirs keep theirs
local sim = Engine.new(pack)
local life = sim:newLife({ seed = 777, originId = pack.origins[1].id, look = { skin = "umber", hairColor = "straw", hair = "bun" } })
assert(life.look.skin == "umber" and life.look.hair == "bun", "chosen look kept")
local same = 0
local family = 0
for _, rel in life.relations do
	assert(rel.look and rel.look.skin, "relations get looks")
	family += 1
	if rel.look.skin == life.look.skin then
		same += 1
	end
end
local v = sim:view(life)
assert(v.appearance and v.appearance.look.skin == "umber", "view has appearance")
for _, r in v.relations do
	assert(r.appearance and r.appearance.look, "relation views have appearance")
end
assert(Avatar.signature(v.appearance) ~= "", "signature")
-- old saves without looks get a stable one without touching the RNG
life.look = nil
local rngBefore = life.rng
local a1 = sim:appearance(life).look.skin
life.look = nil
local a2 = sim:appearance(life).look.skin
assert(a1 == a2 and life.rng == rngBefore, "old-save look is stable and leaves the RNG alone")

print(string.format("%d figures built, %d problems; family members sharing your skin: %d of %d", builds, problems, same, family))
print(string.format("everything-at-once figure: %d parts; plain figure: %d; portrait: %d", #full, #whole, #portrait))
if problems > 0 then
	error("avatar check failed")
end
print("OK")

-- interactions: spend time raises the bond, cooldowns hold, the clash one works
do
	local isim = Engine.new(pack)
	local l = isim:newLife({ seed = 4242, originId = pack.origins[1].id })
	l.age = 20
	local mother = nil
	for _, rel in l.relations do
		if rel.kind == "mother" and rel.alive then
			mother = rel
		end
	end
	assert(mother, "test life needs a mother")
	local v0 = isim:view(l)
	local mv = nil
	for _, r in v0.relations do
		if r.id == mother.id then
			mv = r
		end
	end
	assert(mv and mv.interactions and #mv.interactions >= 2, "mother should have interactions")
	local before = mother.bond
	l.pending = nil
	l.actionsLeft = 3
	l.money = math.max(l.money, 500)
	local rep, err = isim:interact(l, mother.id, "spend_time")
	assert(rep, "spend_time failed: " .. tostring(err))
	local scenes = 0
	if l.pending then
		-- an evening with someone is a scene with choices (v0.11): take the first plain one
		local pv = isim:view(l).pending
		assert(pv and #pv.choices >= 2, "a scene with someone should offer choices")
		local pick = nil
		for i, c in pv.choices do
			if not c.clash and c.enabled ~= false then
				pick = i
				break
			end
		end
		assert(pick, "a scene with someone should have a choice that is no test")
		assert(isim:choose(l, pick, nil), "the scene's choice should go through")
		scenes = 1
	end
	assert(mother.bond > before or mother.bond == 100, "bond should go up")
	l.pending = nil
	local again = isim:interact(l, mother.id, "spend_time")
	assert(again == nil, "spend_time should be on cooldown this year")
	mother.bond = 20
	l.pending = nil
	l.actionsLeft = 3
	-- packs that fight by stat have no Careful; the others still take an approach here
	local careful = if pack.approaches and pack.approaches.careful then "careful" else nil
	local peace = isim:interact(l, mother.id, "make_peace", careful)
	assert(peace and peace.clash, "make_peace should run a clash")
	assert(careful == nil or peace.clash.approach == "careful", "make_peace should use the approach it was given")
	print(string.format("interactions: spend time (%s), cooldown and make peace all work", if scenes > 0 then "as a scene" else "plain"))
end
print("OK")
