--[[
	Avatar: turns an appearance into a list of simple parts (boxes, balls and
	upright cylinders) that any renderer can draw. The Roblox client builds Parts
	inside a ViewportFrame; the browser preview draws the same list with WebGL.

		local parts, frame = Avatar.build(pack, appearance, opts?)

	appearance = {
		look = { skin, hair, hairColor, outfit, mark, eyes, accessory, weapon },  -- cosmetic option ids
		age, form, sanity,
		gear = { [slot] = gearId },
		conditions = { conditionId, ... },
	}
	opts.portrait = true leaves out the legs (cheaper for small faces in lists).
	opts.ground = true adds a shadow disc under the feet.

	Each part: { name, shape = "box" | "ball" | "cyl", size = { x, y, z },
	             pos = { x, y, z }, rot = { rx, ry, rz }? (degrees),
	             color = { r, g, b }, material = "plastic" | "neon" | "metal" | "fabric" | "wood" }
	"cyl" is an upright cylinder: size.x is the diameter and size.y the height.
	The figure stands on y = 0, faces -Z, and its right hand is at +X.
	frame = { height, top, headY, headSize } for pointing a camera at it (top includes hats).
]]

local Arms = require(script.Parent.Arms)

local Avatar = {}

-- every kind of thing a hand can hold (Engine/Arms.luau draws them): a gear item's
-- look.kind for the tool slot, and a cosmetic weapon's kind
Avatar.toolKinds = Arms.has

-- eyes, accessory and weapon are optional: a pack without them just doesn't show them.
-- weapon is a signature weapon: drawn in the hand from 16 on, unless real gear is held.
local CATEGORIES = { "skin", "hair", "hairColor", "outfit", "mark", "eyes", "accessory", "weapon", "frame", "body" }
Avatar.CATEGORIES = CATEGORIES

local GREY_HAIR = { 206, 204, 198 }
local WHITE_CLOTH = { 236, 232, 222 }
local DARK = { 30, 26, 26 }
local BRASS = { 204, 162, 72 }

local function clamp255(n: number): number
	return math.clamp(math.floor(n + 0.5), 0, 255)
end

local function lerp(a, b, t: number)
	return { clamp255(a[1] + (b[1] - a[1]) * t), clamp255(a[2] + (b[2] - a[2]) * t), clamp255(a[3] + (b[3] - a[3]) * t) }
end

local function shade(c, f: number)
	return { clamp255(c[1] * f), clamp255(c[2] * f), clamp255(c[3] * f) }
end

-- ── (v0.17) AUGMENT ARMS: the left arm, replaced (Gear/Augments.luau) ────────
-- Drawn from the shoulder down; look.color is the arm itself, look.trim its metal or its glow
-- (look.glow = true lights it). Parts are named Aug* so the body-shape pass treats them as arm.
local ARM_KINDS = {
	arm_piston = true, arm_blade = true, arm_chain = true, arm_furnace = true, arm_carapace = true,
	arm_rhino = true, arm_grown = true, arm_spring = true, arm_needle = true,
}
Avatar.armKinds = ARM_KINDS

local function augmentArm(add, body, look, x: number)
	local c = look.color or { 150, 150, 156 }
	local t = look.trim or BRASS
	local lit = if look.glow then "neon" else "metal"
	local kind = look.kind
	local o = if x < 0 then -1 else 1 -- outward
	if kind == "arm_piston" then
		add(body, "AugJoint", "ball", { 0.8, 0.8, 0.8 }, { x, 3.42, 0 }, shade(c, 0.8), "metal")
		add(body, "AugForearm", "box", { 0.86, 1.2, 0.86 }, { x, 2.78, 0 }, c, "metal")
		add(body, "AugPiston", "cyl", { 0.34, 1.1, 0.34 }, { x + 0.52 * o, 2.86, 0 }, shade(c, 1.25), "metal")
		add(body, "AugPistonRod", "cyl", { 0.14, 0.5, 0.14 }, { x + 0.52 * o, 2.16, 0 }, t, "metal")
		for _, y in { 3.15, 2.45 } do
			add(body, "AugBand", "box", { 0.92, 0.12, 0.92 }, { x, y, 0 }, t, "metal")
		end
		add(body, "AugFist", "box", { 0.92, 0.5, 0.92 }, { x, 1.98, 0 }, shade(c, 0.9), "metal")
		add(body, "AugKnuckles", "box", { 0.94, 0.16, 0.3 }, { x, 2.06, -0.36 }, t, "metal")
	elseif kind == "arm_blade" then
		add(body, "AugJoint", "ball", { 0.7, 0.7, 0.7 }, { x, 3.42, 0 }, shade(c, 1.3), "metal")
		add(body, "AugForearm", "box", { 0.72, 1.3, 0.72 }, { x, 2.76, 0 }, c, "metal")
		add(body, "AugSeam", "box", { 0.05, 1.2, 0.74 }, { x + 0.37 * o, 2.76, 0 }, t, "metal")
		add(body, "AugBlade", "box", { 0.06, 1.7, 0.42 }, { x + 0.42 * o, 2.25, -0.12 }, t, "metal", { 8, 0, 0 })
		add(body, "AugBladeTip", "box", { 0.06, 0.4, 0.26 }, { x + 0.42 * o, 1.32, -0.26 }, t, "metal", { 34, 0, 0 })
		add(body, "AugHand", "box", { 0.74, 0.46, 0.74 }, { x, 2.0, 0 }, shade(c, 0.85), "metal")
	elseif kind == "arm_chain" then
		add(body, "AugJoint", "ball", { 0.78, 0.78, 0.78 }, { x, 3.42, 0 }, shade(c, 0.85), "metal")
		add(body, "AugForearm", "box", { 0.86, 1.2, 0.86 }, { x, 2.78, 0 }, c, "metal")
		add(body, "AugDrum", "cyl", { 0.62, 0.5, 0.62 }, { x + 0.38 * o, 2.95, 0 }, shade(t, 0.8), "metal", { 0, 0, 90 })
		add(body, "AugHand", "box", { 0.88, 0.46, 0.88 }, { x, 2.0, 0 }, shade(c, 0.9), "metal")
		for i = 0, 3 do
			add(body, "AugLink", "box", { 0.12, 0.24, 0.2 }, { x + 0.1 * o, 1.62 - i * 0.24, -0.05 }, t, "metal", { 0, if i % 2 == 0 then 0 else 90, 0 })
		end
		add(body, "AugHook", "box", { 0.1, 0.36, 0.3 }, { x + 0.1 * o, 0.62, -0.14 }, shade(t, 1.2), "metal", { 30, 0, 0 })
	elseif kind == "arm_furnace" then
		add(body, "AugJoint", "ball", { 0.84, 0.84, 0.84 }, { x, 3.42, 0 }, shade(c, 1.3), "metal")
		add(body, "AugForearm", "box", { 0.96, 1.24, 0.96 }, { x, 2.78, 0 }, c, "metal")
		for _, y in { 3.05, 2.78, 2.51 } do
			add(body, "AugVent", "box", { 0.5, 0.08, 0.06 }, { x, y, -0.5 }, t, lit)
			add(body, "AugVent", "box", { 0.06, 0.08, 0.5 }, { x + 0.5 * o, y, 0 }, t, lit)
		end
		add(body, "AugFist", "box", { 0.98, 0.52, 0.98 }, { x, 1.98, 0 }, shade(c, 0.9), "metal")
		add(body, "AugKnuckles", "box", { 0.9, 0.14, 0.12 }, { x, 2.06, -0.5 }, t, lit)
	elseif kind == "arm_carapace" then
		add(body, "AugJoint", "ball", { 0.82, 0.82, 0.82 }, { x, 3.42, 0 }, shade(c, 0.8), "plastic")
		for i = 0, 2 do
			add(body, "AugPlate", "box", { 0.94 - i * 0.04, 0.48, 0.94 - i * 0.04 }, { x, 3.05 - i * 0.42, 0 }, if i % 2 == 0 then c else shade(c, 1.2), "plastic", { 0, 0, 6 * o })
			add(body, "AugRidge", "box", { 0.12, 0.4, 0.5 }, { x + 0.48 * o, 3.05 - i * 0.42, 0.1 }, t, "plastic", { 0, 0, -12 * o })
		end
		add(body, "AugHand", "box", { 0.8, 0.4, 0.8 }, { x, 2.04, 0 }, shade(c, 0.7), "plastic")
		for _, dx in { -0.26, 0, 0.26 } do
			add(body, "AugClaw", "box", { 0.1, 0.56, 0.14 }, { x + dx, 1.64, -0.22 }, t, "plastic", { 18, 0, dx * 30 })
		end
	elseif kind == "arm_rhino" then
		add(body, "AugPauldron", "box", { 1.24, 0.5, 1.24 }, { x + 0.04 * o, 3.84, 0 }, c, "metal", { 0, 0, -8 * o })
		add(body, "AugForearm", "box", { 1.14, 1.4, 1.14 }, { x, 2.86, 0 }, c, "metal")
		add(body, "AugCell", "box", { 0.3, 0.7, 0.08 }, { x, 2.95, -0.6 }, { 255, 170, 80 }, lit)
		add(body, "AugTrim", "box", { 1.18, 0.14, 1.18 }, { x, 3.5, 0 }, t, "metal")
		add(body, "AugTrim", "box", { 1.18, 0.14, 1.18 }, { x, 2.25, 0 }, t, "metal")
		add(body, "AugFist", "box", { 1.12, 0.62, 1.12 }, { x, 1.86, 0 }, shade(c, 0.85), "metal")
	elseif kind == "arm_grown" then
		add(body, "AugUpper", "box", { 0.92, 0.6, 0.92 }, { x, 3.32, 0 }, c, "plastic")
		add(body, "AugForearm", "box", { 0.9, 0.96, 0.9 }, { x, 2.62, 0 }, c, "plastic")
		add(body, "AugGraft", "box", { 0.96, 0.08, 0.96 }, { x, 3.66, 0 }, shade(t, 0.7), lit)
		for _, s in { { 0.2, -0.47, 4 }, { -0.18, -0.47, -6 }, { 0.47, 0.1, 0 } } do
			local dx, dz, r = s[1], s[2], s[3]
			if dz < 0 then
				add(body, "AugVein", "box", { 0.06, 1.3, 0.04 }, { x + dx, 2.9, dz }, t, lit, { 0, 0, r })
			else
				add(body, "AugVein", "box", { 0.04, 1.3, 0.06 }, { x + dx * o, 2.9, dz }, t, lit)
			end
		end
		add(body, "AugHand", "box", { 0.9, 0.44, 0.9 }, { x, 2.0, 0 }, c, "plastic")
	elseif kind == "arm_spring" then
		add(body, "AugJoint", "ball", { 0.66, 0.66, 0.66 }, { x, 3.42, 0 }, t, "metal")
		add(body, "AugCore", "cyl", { 0.4, 1.3, 0.4 }, { x, 2.75, 0 }, shade(c, 0.8), "metal")
		for i = 0, 4 do
			add(body, "AugCoil", "cyl", { 0.78, 0.1, 0.78 }, { x, 3.2 - i * 0.24, 0 }, if i % 2 == 0 then c else t, "metal")
		end
		add(body, "AugHand", "box", { 0.8, 0.44, 0.8 }, { x, 2.0, 0 }, c, "metal")
	elseif kind == "arm_needle" then
		add(body, "AugJoint", "ball", { 0.6, 0.6, 0.6 }, { x, 3.42, 0 }, shade(c, 0.85), "metal")
		add(body, "AugUpper", "box", { 0.5, 0.5, 0.5 }, { x, 3.08, 0 }, c, "metal")
		add(body, "AugElbow", "ball", { 0.46, 0.46, 0.46 }, { x, 2.78, 0 }, t, "metal")
		add(body, "AugForearm", "box", { 0.46, 0.7, 0.46 }, { x, 2.4, 0 }, c, "metal")
		add(body, "AugHand", "box", { 0.62, 0.34, 0.62 }, { x, 1.98, 0 }, shade(c, 0.9), "metal")
		add(body, "AugNeedle", "box", { 0.05, 0.9, 0.05 }, { x, 1.42, -0.08 }, t, "neon")
	else
		add(body, "AugForearm", "box", { 0.9, 1.5, 0.9 }, { x, 2.7, 0 }, c, "metal")
	end
end

-- ── (v0.17) BODY SHAPE ───────────────────────────────────────────────────────
-- A feminine build (look.body = "feminine") draws the torso in bands: chest, upper waist,
-- waist and hips, so the waist is narrow (snatched) and everything worn over it follows the
-- same line. Shoulders and arms (and what the hands hold) sit a little closer in, the legs are
-- a touch slimmer. Done as one pass over the finished parts, so every outfit, coat and
-- augment arm gets it without drawing anything twice.
local FEM_BANDS = { { 1.96, 2.5, 0.96 }, { 2.5, 3.0, 0.7 }, { 3.0, 3.45, 0.8 }, { 3.45, 4.06, 0.9 } }
local FEM_LOW, FEM_HIGH = 1.96, 4.06
local FEM_INWARD = 0.1
-- things that hang behind or over the shape rather than following it
local DRAPE = {
	Cape = true, CapeClasp = true, Pack = true, PackFlap = true, Mantle = true, MantleBack = true,
	HalfCape = true, HalfCapeHem = true, HalfCapeClasp = true, Fur = true, ScarfTail = true, Ground = true,
}
local ARM_PARTS = {
	Sleeve = true, Hand = true, Glove = true, Armband = true, CoatSleeve = true, Pauldron = true,
	PauldronRim = true, Epaulette = true, Fringe = true,
}
local LEG_PARTS = { Leg = true, Shoe = true, Boot = true, BootCuff = true, Kneepad = true, Stripe = true, Hakama = true, Pleat = true }

local function femFactor(y: number): number
	for _, b in FEM_BANDS do
		if y >= b[1] and y < b[2] then
			return b[3]
		end
	end
	return 1
end

local function copyPart(p, pos, size)
	local q = table.clone(p)
	q.pos = pos
	q.size = size
	return q
end

local function shapeFeminine(body, toolFrom: number?)
	local out = {}
	for i, p in body do
		local name = p.name
		local x, y, z = p.pos[1], p.pos[2], p.pos[3]
		local sx, sy, sz = p.size[1], p.size[2], p.size[3]
		local rotated = p.rot ~= nil and (p.rot[1] ~= 0 or p.rot[2] ~= 0 or p.rot[3] ~= 0)
		if (toolFrom and i >= toolFrom) or ARM_PARTS[name] or string.sub(name, 1, 3) == "Aug" then
			-- arms, and what the right hand holds, sit closer in with the narrower shoulders
			local side = if toolFrom and i >= toolFrom then 1 elseif x < 0 then -1 else 1
			table.insert(out, copyPart(p, { x - FEM_INWARD * side, y, z }, { sx, sy, sz }))
		elseif DRAPE[name] then
			table.insert(out, p)
		elseif LEG_PARTS[name] then
			table.insert(out, copyPart(p, { x * 0.96, y, z }, { sx * 0.94, sy, sz }))
		elseif not rotated and math.abs(x) < sx / 2 and y + sy / 2 > FEM_LOW and y - sy / 2 < FEM_HIGH then
			-- something across the body: cut into the bands it covers, each as wide as its band
			local y0, y1 = y - sy / 2, y + sy / 2
			local cuts = {}
			if y0 < FEM_LOW then
				table.insert(cuts, { y0, FEM_LOW, 1 })
			end
			for _, b in FEM_BANDS do
				local a, c = math.max(y0, b[1]), math.min(y1, b[2])
				if c - a > 0.005 then
					table.insert(cuts, { a, c, b[3] })
				end
			end
			if y1 > FEM_HIGH then
				table.insert(cuts, { FEM_HIGH, y1, 1 })
			end
			for _, c in cuts do
				table.insert(out, copyPart(p, { x * c[3], (c[1] + c[2]) / 2, z }, { sx * c[3], c[2] - c[1], sz }))
			end
		elseif math.abs(x) < 1.02 and y > FEM_LOW and y < FEM_HIGH then
			-- on the front of the body, off center (lapels, buttons, straps): follows the line in
			local f = femFactor(y)
			table.insert(out, copyPart(p, { x * f, y, z }, if rotated then { sx, sy, sz } else { sx * math.max(f, 0.85), sy, sz }))
		else
			table.insert(out, p)
		end
	end
	return out
end
Avatar.bodies = { masculine = true, feminine = true }

-- ── catalog helpers ─────────────────────────────────────────────────────────

function Avatar.category(pack, category: string)
	local cosmetics = pack.cosmetics
	local cat = cosmetics and cosmetics[category]
	if type(cat) ~= "table" or type(cat.options) ~= "table" then
		return nil
	end
	return cat
end

function Avatar.option(pack, category: string, id: string?)
	local cat = Avatar.category(pack, category)
	if not cat or type(id) ~= "string" then
		return nil
	end
	for _, o in cat.options do
		if o.id == id then
			return o
		end
	end
	return nil
end

function Avatar.unlockKey(category: string, id: string): string
	return category .. ":" .. id
end

-- free options need nothing; glow options need an unlock; record options need the record
function Avatar.usable(category: string, option, unlocked, records): boolean
	if not option then
		return false
	end
	if option.uniform then
		return false -- worn while you work for whoever issues it, not picked
	end
	if option.record then
		return records ~= nil and records[option.record] ~= nil
	end
	if option.store or option.daily then
		return unlocked ~= nil and unlocked[Avatar.unlockKey(category, option.id)] == true
	end
	if option.glow and option.glow > 0 then
		return unlocked ~= nil and unlocked[Avatar.unlockKey(category, option.id)] == true
	end
	return true
end

local function freeOptions(cat)
	local list = {}
	for _, o in (cat and cat.options) or {} do
		-- (a uniform is issued by an organisation: never part of a random or a chosen look)
		if not o.record and not o.store and not o.daily and not (o.glow and o.glow > 0) and not o.uniform then
			table.insert(list, o)
		end
	end
	return list
end

function Avatar.defaultLook(pack)
	local look = {}
	for _, category in CATEGORIES do
		local free = freeOptions(Avatar.category(pack, category))
		if free[1] then
			look[category] = free[1].id
		end
	end
	return look
end

-- Cleans a look sent by a player: unknown or locked picks fall back to defaults.
-- canUse(category, option) -> boolean decides what's unlocked for this player.
function Avatar.sanitize(pack, look, canUse)
	local clean = Avatar.defaultLook(pack)
	if type(look) ~= "table" then
		return clean
	end
	for _, category in CATEGORIES do
		local id = look[category]
		if type(id) == "string" then
			local option = Avatar.option(pack, category, id)
			if option and (canUse == nil or canUse(category, option)) then
				clean[category] = id
			end
		end
	end
	return clean
end

-- A random look from the free options. `roll(n)` returns an integer in 1..n.
-- With `base` (a parent's look), skin and hair color usually carry over.
function Avatar.randomLook(pack, roll, base)
	local look = {}
	for _, category in CATEGORIES do
		local free = freeOptions(Avatar.category(pack, category))
		if #free > 0 then
			local pick = free[roll(#free)]
			look[category] = pick.id
			if base and base[category] and (category == "skin" or category == "hairColor") and roll(10) <= 7 then
				look[category] = base[category]
			end
		end
	end
	-- most people have no marks, and carry nothing
	if look.mark and roll(10) <= 6 then
		local none = freeOptions(Avatar.category(pack, "mark"))[1]
		look.mark = none and none.id or look.mark
	end
	if look.weapon and roll(10) <= 7 then
		local none = freeOptions(Avatar.category(pack, "weapon"))[1]
		look.weapon = none and none.id or look.weapon
	end
	return look
end

-- Short string that changes whenever the drawn figure would change.
function Avatar.signature(ap): string
	if not ap then
		return ""
	end
	local look = ap.look or {}
	local parts = {}
	for _, category in CATEGORIES do
		table.insert(parts, tostring(look[category]))
	end
	local age = ap.age or 0
	table.insert(parts, tostring(if age < 17 then age else (if age >= 50 then age // 4 else 17)))
	table.insert(parts, tostring(ap.form))
	local gear = {}
	for slot, id in ap.gear or {} do
		table.insert(gear, slot .. "=" .. tostring(id))
	end
	table.sort(gear)
	table.insert(parts, table.concat(gear, ","))
	local conditions = table.clone(ap.conditions or {})
	table.sort(conditions)
	table.insert(parts, table.concat(conditions, ","))
	local s = ap.sanity or 0
	table.insert(parts, if s >= 15 then "up" elseif s <= -20 then "down" else "mid")
	return table.concat(parts, "|")
end

-- ── the figure ──────────────────────────────────────────────────────────────

local function ageScale(age: number): (number, number)
	if age < 4 then
		return 0.5, 0.74
	elseif age < 9 then
		return 0.62, 0.8
	elseif age < 13 then
		return 0.75, 0.87
	elseif age < 17 then
		return 0.88, 0.94
	end
	return 1, 1
end

function Avatar.build(pack, ap, opts)
	opts = opts or {}
	ap = ap or {}
	local look = ap.look or {}
	local function pick(category: string)
		local o = Avatar.option(pack, category, look[category])
		if not o then
			o = freeOptions(Avatar.category(pack, category))[1]
		end
		return o or {}
	end
	local skinO, hairO, hairColorO, outfitO, markO = pick("skin"), pick("hair"), pick("hairColor"), pick("outfit"), pick("mark")
	local feminine = look.body == "feminine" -- (v0.17)
	local eyesO, accessoryO = pick("eyes"), pick("accessory")
	local age = ap.age or 25

	-- what conditions and form do to the look
	local cond = {}
	for _, id in ap.conditions or {} do
		local def = pack.conditions and pack.conditions[id]
		if def and def.look then
			cond[def.look] = true
		end
	end
	local skin = skinO.color or { 222, 183, 150 }
	if cond.pale then
		skin = lerp(skin, { 196, 198, 204 }, 0.3)
	end
	local formDef = pack.forms and pack.forms[ap.form or "human"]
	local formLook = formDef and formDef.look
	if formLook and formLook.tint then
		skin = lerp(skin, formLook.tint, formLook.amount or 0.3)
	end
	-- a form's eyes win (they show what you've become); otherwise your own, maybe augmented
	local eyeColor = (formLook and formLook.eyes) or eyesO.color or { 28, 24, 24 }
	local eyeMaterial = if (formLook and formLook.eyes and formLook.glow) or (not (formLook and formLook.eyes) and eyesO.glow) then "neon" else "plastic"
	local hairColor = hairColorO.color or { 60, 42, 32 }
	if age >= 50 then
		hairColor = lerp(hairColor, GREY_HAIR, math.clamp((age - 50) / 28, 0, 0.85))
	end

	local shirt = outfitO.shirt or { 120, 110, 100 }
	local pants = outfitO.pants or { 70, 64, 60 }
	local shoes = outfitO.shoes or { 40, 34, 30 }

	local gearLook = {}
	for slot, id in ap.gear or {} do
		local def = pack.gear and pack.gear[id]
		if def and def.look then
			gearLook[slot] = def.look
		end
	end
	local coat = gearLook.coat
	local tool = gearLook.tool
	local charm = gearLook.charm
	-- a signature weapon (look.weapon) when nothing real is in hand
	if not tool and age >= 16 then
		local weaponO = pick("weapon")
		if weaponO.kind then
			tool = { kind = weaponO.kind, color = weaponO.color, trim = weaponO.trim }
		end
	end

	local body, head = {}, {}
	local function add(list, name: string, shape: string, size, pos, color, material: string?, rot, legs: boolean?)
		table.insert(list, {
			name = name,
			shape = shape,
			size = size,
			pos = pos,
			color = color,
			material = material or "plastic",
			rot = rot,
			legs = legs,
		})
	end

	-- legs
	local legColor = if outfitO.robe then shirt else pants
	for _, side in { -1, 1 } do
		add(body, "Shoe", "box", { 0.98, 0.32, 1.12 }, { 0.5 * side, 0.16, -0.07 }, shoes, "plastic", nil, true)
		add(body, "Leg", "box", { 0.96, 1.7, 0.96 }, { 0.5 * side, 1.17, 0 }, legColor, "fabric", nil, true)
	end
	if opts.ground then
		add(body, "Ground", "cyl", { 3.2, 0.04, 3.2 }, { 0, 0.02, 0 }, { 16, 16, 20 }, "plastic", nil, true)
	end

	-- torso and arms
	add(body, "Torso", "box", { 2, 2, 1 }, { 0, 3, 0 }, shirt, "fabric")
	local handColor = if cond.bandaged then WHITE_CLOTH else skin
	-- A weapon is HELD: the right forearm comes up in front of the body and the grip goes
	-- through the fist (things that hang from a lowered hand keep the straight arm).
	local raised = tool ~= nil and Arms.has[tool.kind] == true and not Arms.low[tool.kind]
	local sleeveC = outfitO.jacket or shirt -- an open jacket's sleeves are the jacket's
	local HAND = { 1.5, 3.0, -1.2 } -- the fist of a raised arm
	-- (v0.17) an augment arm replaces the left arm below a short sleeve
	local aug = if gearLook.arm and ARM_KINDS[gearLook.arm.kind] then gearLook.arm else nil
	for _, side in { -1, 1 } do
		local x = 1.5 * side
		local cast = cond.cast and side == -1 and not aug
		if side == -1 and aug then
			add(body, "Sleeve", "box", { 0.96, 0.56, 0.96 }, { x, 3.72, 0 }, sleeveC, "fabric")
			augmentArm(add, body, aug, x)
		elseif side == 1 and raised then
			add(body, "Sleeve", "box", { 0.96, 0.94, 0.96 }, { x, 3.53, 0 }, sleeveC, "fabric")
			add(body, "Sleeve", "box", { 0.9, 0.9, 1.04 }, { x, 3.0, -0.5 }, sleeveC, "fabric")
			add(body, "Hand", "box", { 0.84, 0.84, 0.44 }, { x, HAND[2], HAND[3] }, handColor, "plastic")
		else
			add(body, "Sleeve", "box", { 0.96, 1.56, 0.96 }, { x, 3.22, 0 }, if cast then WHITE_CLOTH else sleeveC, "fabric")
			add(body, "Hand", "box", { 0.9, 0.44, 0.9 }, { x, 2.22, 0 }, if cast then WHITE_CLOTH else handColor, "plastic")
		end
	end

	-- outfit details
	if outfitO.robe then
		add(body, "Robe", "box", { 2.06, 1.9, 1.06 }, { 0, 1.2, 0 }, shade(shirt, 0.94), "fabric", nil, true)
	end
	if outfitO.belt then
		add(body, "Belt", "box", { 2.04, 0.24, 1.04 }, { 0, 2.14, 0 }, outfitO.belt, "fabric")
	end
	if outfitO.apron then
		add(body, "Apron", "box", { 1.7, 2.5, 0.08 }, { 0, 2.1, -0.54 }, outfitO.apron, "fabric")
	end
	if outfitO.vest then
		add(body, "Vest", "box", { 2.04, 1.5, 1.04 }, { 0, 3.2, 0 }, outfitO.vest, "fabric")
	end
	if outfitO.tie then
		add(body, "Tie", "box", { 0.2, 1.3, 0.06 }, { 0, 3.3, -0.54 }, outfitO.tie, "fabric")
	end
	if outfitO.buttons and not coat then
		for _, y in { 3.65, 3.15, 2.65 } do
			for _, x in { -0.32, 0.32 } do
				add(body, "Button", "box", { 0.14, 0.14, 0.06 }, { x, y, -0.52 }, outfitO.buttons, "metal")
			end
		end
	end
	if outfitO.collar then
		add(body, "Collar", "box", { 2.1, 0.3, 1.1 }, { 0, 3.92, 0 }, outfitO.collar, "metal")
	end

	if outfitO.gloves then
		for _, side in { -1, 1 } do
			if side == -1 and aug then
				continue
			elseif side == 1 and raised then
				add(body, "Glove", "box", { 0.9, 0.9, 0.5 }, { 1.5, HAND[2], HAND[3] }, outfitO.gloves, "fabric")
			else
				add(body, "Glove", "box", { 0.94, 0.48, 0.94 }, { 1.5 * side, 2.22, 0 }, outfitO.gloves, "fabric")
			end
		end
	end
	if outfitO.armband and not aug then
		add(body, "Armband", "box", { 1.0, 0.3, 1.0 }, { -1.5, 3.42, 0 }, outfitO.armband, "fabric")
	end
	if outfitO.sash then
		add(body, "Sash", "box", { 0.34, 2.5, 1.06 }, { 0, 3.0, 0 }, outfitO.sash, "fabric", { 0, 0, 38 })
	end
	if outfitO.cape and not gearLook.coat then
		add(body, "Cape", "box", { 2.3, 2.6, 0.14 }, { 0, 2.75, 0.62 }, outfitO.cape, "fabric")
		add(body, "CapeClasp", "box", { 2.2, 0.26, 1.12 }, { 0, 3.94, 0 }, shade(outfitO.cape, 0.8), "fabric")
	end

	-- ── v0.10: more to wear. Each is a color { r, g, b } on the outfit. ──
	-- under a coat
	if outfitO.hakama then
		-- wide pleated trousers
		for _, side in { -1, 1 } do
			add(body, "Hakama", "box", { 1.12, 1.78, 1.24 }, { 0.56 * side, 1.2, 0 }, outfitO.hakama, "fabric", nil, true)
			for _, px in { -0.3, 0, 0.3 } do
				add(body, "Pleat", "box", { 0.04, 1.7, 0.04 }, { 0.56 * side + px, 1.2, -0.63 }, shade(outfitO.hakama, 0.7), "fabric", nil, true)
			end
		end
	end
	if outfitO.skirt then
		add(body, "Skirt", "box", { 2.1, 1.05, 1.12 }, { 0, 1.56, 0 }, outfitO.skirt, "fabric", nil, true)
		add(body, "SkirtHem", "box", { 2.14, 0.1, 1.16 }, { 0, 1.08, 0 }, shade(outfitO.skirt, 0.75), "fabric", nil, true)
	end
	if outfitO.stripe then
		for _, side in { -1, 1 } do
			add(body, "Stripe", "box", { 0.05, 1.7, 0.26 }, { 0.99 * side, 1.17, 0 }, outfitO.stripe, "fabric", nil, true)
		end
	end
	if outfitO.boots then
		for _, side in { -1, 1 } do
			add(body, "Boot", "box", { 1.02, 0.86, 1.02 }, { 0.5 * side, 0.74, 0 }, outfitO.boots, "plastic", nil, true)
			add(body, "BootCuff", "box", { 1.06, 0.14, 1.06 }, { 0.5 * side, 1.16, 0 }, shade(outfitO.boots, 1.3), "plastic", nil, true)
		end
	end
	if outfitO.kneepads then
		for _, side in { -1, 1 } do
			add(body, "Kneepad", "box", { 0.72, 0.44, 0.14 }, { 0.5 * side, 1.36, -0.5 }, outfitO.kneepads, "metal", nil, true)
		end
	end
	if outfitO.jacket and not coat and not outfitO.longcoat then
		-- an open jacket: the back and sides, two front panels, and lapels; the shirt shows between
		local j = outfitO.jacket
		add(body, "Jacket", "box", { 2.08, 2.1, 0.94 }, { 0, 2.98, 0.07 }, j, "fabric")
		for _, side in { -1, 1 } do
			add(body, "JacketFront", "box", { 0.66, 2.1, 0.08 }, { 0.71 * side, 2.98, -0.53 }, j, "fabric")
			add(body, "Lapel", "box", { 0.22, 1.0, 0.05 }, { 0.36 * side, 3.46, -0.585 }, outfitO.lapels or shade(j, 0.72), "fabric", { 0, 0, 14 * side })
		end
	elseif outfitO.lapels and not coat then
		for _, side in { -1, 1 } do
			add(body, "Lapel", "box", { 0.24, 1.1, 0.05 }, { 0.3 * side, 3.42, -0.53 }, outfitO.lapels, "fabric", { 0, 0, 16 * side })
		end
	end
	if outfitO.wrap and not coat then
		-- a crossed collar, left over right
		add(body, "Wrap", "box", { 0.3, 2.3, 0.06 }, { 0, 3.0, -0.53 }, outfitO.wrap, "fabric", { 0, 0, 28 })
		add(body, "Wrap", "box", { 0.3, 1.3, 0.06 }, { 0.32, 3.4, -0.535 }, outfitO.wrap, "fabric", { 0, 0, -28 })
	end
	if outfitO.suspenders and not coat then
		for _, side in { -1, 1 } do
			add(body, "Suspender", "box", { 0.2, 2.02, 1.06 }, { 0.52 * side, 3.0, 0 }, outfitO.suspenders, "fabric")
		end
	end
	if outfitO.plate then
		-- a breastplate, front and back
		add(body, "Plate", "box", { 1.92, 1.5, 0.12 }, { 0, 3.2, -0.56 }, outfitO.plate, "metal")
		add(body, "Plate", "box", { 1.92, 1.5, 0.12 }, { 0, 3.2, 0.56 }, outfitO.plate, "metal")
		add(body, "PlateRidge", "box", { 1.94, 0.06, 0.14 }, { 0, 2.9, -0.56 }, shade(outfitO.plate, 0.6), "metal")
		add(body, "PlateFauld", "box", { 1.6, 0.4, 0.1 }, { 0, 2.3, -0.55 }, shade(outfitO.plate, 0.8), "metal")
	end
	if outfitO.tabard and not coat then
		local tb = outfitO.tabard
		add(body, "Tabard", "box", { 1.3, 2.0, 0.07 }, { 0, 3.0, -0.555 }, tb, "fabric")
		add(body, "Tabard", "box", { 1.3, 2.0, 0.07 }, { 0, 3.0, 0.555 }, tb, "fabric")
		add(body, "TabardSkirt", "box", { 1.3, 1.1, 0.07 }, { 0, 1.5, -0.555 }, tb, "fabric", nil, true)
		add(body, "TabardSkirt", "box", { 1.3, 1.1, 0.07 }, { 0, 1.5, 0.555 }, tb, "fabric", nil, true)
		add(body, "TabardHem", "box", { 1.34, 0.12, 0.08 }, { 0, 1.0, -0.56 }, shade(tb, 0.65), "fabric", nil, true)
	end
	if outfitO.straps and not coat then
		for _, z in { -0.54, 0.54 } do
			add(body, "Strap", "box", { 0.24, 2.6, 0.06 }, { 0, 3.0, z }, outfitO.straps, "fabric", { 0, 0, 40 })
			add(body, "Strap", "box", { 0.24, 2.6, 0.06 }, { 0, 3.0, z }, outfitO.straps, "fabric", { 0, 0, -40 })
		end
		add(body, "Buckle", "box", { 0.3, 0.3, 0.08 }, { 0, 3.0, -0.56 }, BRASS, "metal")
	end
	if outfitO.bandolier and not coat then
		add(body, "Bandolier", "box", { 0.3, 2.7, 1.08 }, { 0, 3.0, 0 }, outfitO.bandolier, "fabric", { 0, 0, -38 })
		for i = -1, 1 do
			add(body, "Pouch", "box", { 0.3, 0.3, 0.14 }, { 0.42 * i, 3.0 + 0.54 * i, -0.6 }, shade(outfitO.bandolier, 0.7), "fabric", { 0, 0, -38 })
		end
	end
	if outfitO.cuffs then
		for _, side in { -1, 1 } do
			if side == 1 and raised then
				add(body, "Cuff", "box", { 0.98, 0.98, 0.22 }, { 1.5, 3.0, -0.94 }, outfitO.cuffs, "fabric")
			else
				add(body, "Cuff", "box", { 1.02, 0.24, 1.02 }, { 1.5 * side, 2.58, 0 }, outfitO.cuffs, "fabric")
			end
		end
	end

	-- coat (worn over the clothes): gear first, else an outfit's own long coat
	if not coat and outfitO.longcoat then
		coat = { kind = "greatcoat", color = outfitO.longcoat }
	end
	local chestZ = -0.54
	if coat then
		local c = coat.color or { 140, 120, 80 }
		chestZ = -0.6
		local sleeve = 1.04
		if coat.kind == "jacket" then
			add(body, "Coat", "box", { 2.14, 1.7, 1.14 }, { 0, 3.15, 0 }, c, "fabric")
			for _, y in { 2.75, 3.25, 3.75 } do
				add(body, "Quilting", "box", { 2.16, 0.05, 1.16 }, { 0, y, 0 }, shade(c, 0.72), "fabric")
			end
		else
			add(body, "Coat", "box", { 2.12, 2.06, 1.12 }, { 0, 3.02, 0 }, c, "fabric")
			if coat.kind == "greatcoat" then
				add(body, "CoatTails", "box", { 2.16, 1.75, 1.16 }, { 0, 1.125, 0 }, shade(c, 0.95), "fabric", nil, true)
				add(body, "CoatCollar", "box", { 1.7, 0.45, 1.24 }, { 0, 4.12, 0 }, shade(c, 0.85), "fabric")
				for _, y in { 3.6, 3.1, 2.6 } do
					for _, x in { -0.34, 0.34 } do
						add(body, "Button", "box", { 0.14, 0.14, 0.06 }, { x, y, -0.58 }, BRASS, "metal")
					end
				end
			else
				add(body, "CoatTails", "box", { 2.14, 1.0, 1.14 }, { 0, 1.5, 0 }, shade(c, 0.95), "fabric", nil, true)
				add(body, "CoatCollar", "box", { 1.5, 0.22, 1.16 }, { 0, 4.05, 0 }, shade(c, 0.85), "fabric")
				add(body, "CoatSeam", "box", { 0.05, 3.0, 0.03 }, { 0, 2.5, -0.575 }, shade(c, 0.6), "fabric")
			end
		end
		for _, side in { -1, 1 } do
			if side == 1 and raised then
				-- the arm that holds the weapon: the sleeve bends with it
				add(body, "CoatSleeve", "box", { sleeve, 1.0, sleeve }, { 1.5, 3.53, 0 }, c, "fabric")
				add(body, "CoatSleeve", "box", { sleeve - 0.06, sleeve - 0.06, 1.1 }, { 1.5, 3.0, -0.48 }, c, "fabric")
			elseif side == -1 and aug then
				-- (v0.17) the coat's sleeve is cut short over an augment arm
				add(body, "CoatSleeve", "box", { sleeve, 0.62, sleeve }, { -1.5, 3.7, 0 }, c, "fabric")
			elseif not (cond.cast and side == -1) then
				add(body, "CoatSleeve", "box", { sleeve, 1.6, sleeve }, { 1.5 * side, 3.2, 0 }, c, "fabric")
			end
		end
	end

	-- ── v0.10: worn over everything ──
	local backZ = if coat then 0.62 else 0.56
	if outfitO.pauldrons then
		for _, side in { -1, 1 } do
			add(body, "Pauldron", "box", { 1.2, 0.42, 1.2 }, { 1.52 * side, 3.92, 0 }, outfitO.pauldrons, "metal", { 0, 0, -10 * side })
			add(body, "PauldronRim", "box", { 1.14, 0.2, 1.14 }, { 1.58 * side, 3.6, 0 }, shade(outfitO.pauldrons, 0.7), "metal", { 0, 0, -10 * side })
		end
	end
	if outfitO.epaulettes then
		for _, side in { -1, 1 } do
			add(body, "Epaulette", "box", { 0.9, 0.12, 0.7 }, { 1.5 * side, 4.08, 0 }, outfitO.epaulettes, "metal")
			add(body, "Fringe", "box", { 0.14, 0.24, 0.7 }, { 1.98 * side, 3.94, 0 }, outfitO.epaulettes, "fabric")
		end
	end
	if outfitO.halfcape then
		-- a cape over the left shoulder only
		add(body, "HalfCape", "box", { 1.3, 2.5, 1.34 }, { -1.46, 2.92, 0.04 }, outfitO.halfcape, "fabric")
		add(body, "HalfCapeClasp", "box", { 0.3, 0.3, 0.1 }, { -0.9, 3.9, chestZ - 0.04 }, BRASS, "metal")
		add(body, "HalfCapeHem", "box", { 1.34, 0.12, 1.38 }, { -1.46, 1.72, 0.04 }, shade(outfitO.halfcape, 0.7), "fabric")
	end
	if outfitO.mantle then
		-- a short cape over both shoulders, open at the front
		add(body, "Mantle", "box", { 3.16, 0.9, 1.36 }, { 0, 3.6, 0.06 }, outfitO.mantle, "fabric")
		add(body, "MantleBack", "box", { 2.5, 1.2, 0.14 }, { 0, 2.8, backZ + 0.04 }, shade(outfitO.mantle, 0.9), "fabric")
		add(body, "MantleClasp", "box", { 0.3, 0.3, 0.1 }, { 0, 3.9, chestZ - 0.14 }, BRASS, "metal")
	end
	if outfitO.fur then
		add(body, "Fur", "box", { 2.5, 0.5, 1.5 }, { 0, 3.96, 0.06 }, outfitO.fur, "fabric")
		for _, side in { -1, 1 } do
			add(body, "FurFront", "box", { 0.5, 0.9, 0.2 }, { 0.5 * side, 3.6, chestZ - 0.06 }, outfitO.fur, "fabric")
		end
	end
	if outfitO.scarf then
		add(body, "Scarf", "box", { 1.5, 0.36, 1.36 }, { 0, 4.02, 0 }, outfitO.scarf, "fabric")
		add(body, "ScarfTail", "box", { 0.4, 1.7, 0.1 }, { 0.5, 3.2, backZ + 0.02 }, outfitO.scarf, "fabric", { 0, 0, 6 })
	end
	if outfitO.pack then
		add(body, "Pack", "box", { 1.5, 1.7, 0.7 }, { 0, 3.05, backZ + 0.3 }, outfitO.pack, "fabric")
		add(body, "PackFlap", "box", { 1.54, 0.5, 0.74 }, { 0, 3.7, backZ + 0.3 }, shade(outfitO.pack, 0.75), "fabric")
		for _, side in { -1, 1 } do
			add(body, "PackStrap", "box", { 0.22, 1.9, 0.06 }, { 0.62 * side, 3.05, chestZ - 0.02 }, shade(outfitO.pack, 0.6), "fabric")
		end
	end
	if outfitO.emblem then
		-- the mark of whoever you answer to, on the back and small on the chest
		add(body, "Emblem", "box", { 0.8, 0.8, 0.05 }, { 0, 3.2, backZ + 0.03 }, outfitO.emblem, "metal", { 0, 0, 45 })
		add(body, "EmblemSmall", "box", { 0.3, 0.3, 0.05 }, { 0.52, 3.56, chestZ - 0.03 }, outfitO.emblem, "metal", { 0, 0, 45 })
	end

	-- conditions you can see
	if cond.cast and not aug then
		add(body, "Sling", "box", { 0.26, 2.4, 0.06 }, { -0.35, 3.15, chestZ - 0.02 }, WHITE_CLOTH, "fabric", { 0, 0, -38 })
	end
	if cond.armband then
		local w = if coat then 1.08 else 1.0
		add(body, "Armband", "box", { w, 0.22, w }, { -1.5, 3.62, 0 }, { 24, 22, 22 }, "fabric")
	end

	-- (v0.17) from here on it's what the right hand holds (the body-shape pass moves it with the arm)
	local toolFrom = #body + 1
	-- what's in the hands: Engine/Arms.luau has a model for every kind
	if tool and Arms.has[tool.kind] then
		-- Parts of a raised weapon sit along one line through the fist: tilted a little forward
		-- and outward so the blade clears the head. `t` is the distance from the fist along
		-- that line (up the blade is positive); opts push a part forward or sideways, or turn it.
		local TILT_X, TILT_Z = -14, -6
		local ax, az = math.rad(TILT_X), math.rad(TILT_Z)
		local dir = { -math.sin(az), math.cos(az) * math.cos(ax), math.cos(az) * math.sin(ax) }
		Arms.draw(tool.kind, {
			hand = HAND,
			color = tool.color,
			trim = tool.trim,
			held = function(name: string, shape: string, size, t: number, color, material: string, opts)
				local fwd = (opts and opts.fwd) or 0
				local sideways = (opts and opts.side) or 0
				local rot = { TILT_X + ((opts and opts.rx) or 0), 0, TILT_Z + ((opts and opts.rz) or 0) }
				add(body, name, shape, size, { HAND[1] + dir[1] * t + sideways, HAND[2] + dir[2] * t, HAND[3] + dir[3] * t - fwd }, color, material, rot)
			end,
			add = function(name: string, shape: string, size, pos, color, material: string, rot)
				add(body, name, shape, size, pos, color, material, rot)
			end,
		})
	end

	-- charm, on a cord over the chest
	if charm then
		for _, side in { -1, 1 } do
			add(body, "Cord", "box", { 0.04, 0.6, 0.04 }, { 0.16 * side, 3.72, chestZ - 0.02 }, { 40, 34, 30 }, "fabric", { 0, 0, 28 * side })
		end
		if charm.kind == "stone" then
			add(body, "Charm", "ball", { 0.3, 0.3, 0.3 }, { 0, 3.38, chestZ - 0.06 }, charm.color or { 150, 152, 150 }, "plastic")
		elseif charm.kind == "bell" then
			add(body, "Charm", "cyl", { 0.28, 0.3, 0.28 }, { 0, 3.38, chestZ - 0.06 }, charm.color or BRASS, "metal")
		else
			add(body, "Charm", "box", { 0.3, 0.3, 0.06 }, { 0, 3.4, chestZ - 0.03 }, charm.color or BRASS, "metal", { 0, 0, 45 })
		end
	end

	-- ── head (positions relative to the head's center) ──
	add(head, "Head", "cyl", { 1.25, 1.2, 1.25 }, { 0, 0, 0 }, skin, "plastic")
	local patch = markO.id == "patch"
	if feminine then
		-- (v0.17) lashes over the eyes
		for _, side in { -1, 1 } do
			if not (patch and side == 1) then
				add(head, "Lash", "box", { 0.24, 0.05, 0.06 }, { 0.26 * side, 0.215, -0.6 }, DARK, "plastic", { 0, 0, -14 * side })
			end
		end
	end
	add(head, "Eye", "box", { 0.16, 0.2, 0.08 }, { -0.24, 0.08, -0.585 }, eyeColor, eyeMaterial)
	if not patch then
		add(head, "Eye", "box", { 0.16, 0.2, 0.08 }, { 0.24, 0.08, -0.585 }, eyeColor, eyeMaterial)
	end
	local s = ap.sanity or 0
	local mouthW = if s >= 15 then 0.42 elseif s <= -20 then 0.26 else 0.34
	local mouthY = if s <= -20 then -0.27 else -0.25
	add(head, "Mouth", "box", { mouthW, 0.06, 0.06 }, { 0, mouthY, -0.6 }, { 60, 38, 36 }, "plastic")
	if cond.shadows then
		for _, side in { -1, 1 } do
			add(head, "Shadow", "box", { 0.2, 0.05, 0.05 }, { 0.24 * side, -0.06, -0.59 }, { 96, 64, 92 }, "plastic")
		end
	end
	if cond.kinmark then
		add(head, "KinMark", "box", { 0.1, 0.34, 0.05 }, { -0.36, -0.04, -0.54 }, { 60, 170, 160 }, "neon", { 0, 0, 12 })
	end

	-- marks
	local markId = markO.style or markO.id
	if markId == "freckles" then
		for _, side in { -1, 1 } do
			for _, d in { { 0.3, -0.06, -0.565 }, { 0.38, -0.1, -0.53 }, { 0.24, -0.13, -0.585 } } do
				add(head, "Freckle", "box", { 0.05, 0.05, 0.04 }, { d[1] * side, d[2], d[3] }, markO.color or shade(skin, 0.72), if markO.color then "metal" else "plastic")
			end
		end
	elseif markId == "scar" then
		add(head, "Scar", "box", { 0.05, 0.42, 0.05 }, { 0.33, 0.02, -0.55 }, lerp(skin, { 170, 90, 84 }, 0.6), "plastic", { 0, 0, 18 })
	elseif markId == "ink" then
		add(head, "Ink", "box", { 0.28, 0.045, 0.05 }, { -0.3, -0.12, -0.56 }, { 40, 56, 96 }, "plastic")
		add(head, "Ink", "box", { 0.28, 0.045, 0.05 }, { -0.3, -0.2, -0.56 }, { 40, 56, 96 }, "plastic")
	elseif patch then
		add(head, "Patch", "box", { 0.28, 0.28, 0.07 }, { 0.24, 0.08, -0.6 }, { 20, 20, 22 }, "fabric")
		add(head, "PatchStrap", "cyl", { 1.3, 0.06, 1.3 }, { 0, 0.2, 0 }, { 20, 20, 22 }, "fabric", { 0, 0, -14 })
	end

	-- accessories
	local acc = accessoryO.style or accessoryO.id
	local accColor = accessoryO.color or DARK
	if acc == "sunglasses" then
		add(head, "Shades", "box", { 0.86, 0.22, 0.08 }, { 0, 0.09, -0.62 }, accColor, "metal")
		for _, side in { -1, 1 } do
			add(head, "ShadesArm", "box", { 0.05, 0.06, 0.72 }, { 0.64 * side, 0.12, -0.26 }, accColor, "metal")
		end
	elseif acc == "glasses" or acc == "roundglasses" then
		for _, side in { -1, 1 } do
			add(head, "Lens", "box", { 0.3, 0.26, 0.04 }, { 0.24 * side, 0.08, -0.62 }, { 200, 220, 236 }, "plastic")
			add(head, "Rim", "box", { 0.34, 0.05, 0.05 }, { 0.24 * side, 0.22, -0.625 }, accColor, "metal")
		end
		add(head, "Bridge", "box", { 0.18, 0.04, 0.04 }, { 0, 0.16, -0.625 }, accColor, "metal")
	elseif acc == "monocle" then
		add(head, "Monocle", "cyl", { 0.32, 0.05, 0.32 }, { 0.24, 0.08, -0.62 }, accessoryO.color or BRASS, "metal", { 90, 0, 0 })
		add(head, "MonocleChain", "box", { 0.03, 0.5, 0.03 }, { 0.38, -0.2, -0.6 }, accessoryO.color or BRASS, "metal")
	elseif acc == "mask" then
		add(head, "Mask", "box", { 1.05, 0.42, 0.1 }, { 0, -0.2, -0.62 }, accColor, "fabric")
	elseif acc == "halfmask" then
		add(head, "HalfMask", "box", { 0.62, 0.56, 0.1 }, { 0.22, 0.08, -0.62 }, accessoryO.color or WHITE_CLOTH, "plastic")
	elseif acc == "visor" then
		add(head, "Visor", "box", { 1.12, 0.2, 0.1 }, { 0, 0.1, -0.62 }, accessoryO.color or { 255, 70, 70 }, "neon")
	elseif acc == "scarf" then
		add(head, "Scarf", "cyl", { 1.4, 0.36, 1.4 }, { 0, -0.66, 0 }, accColor, "fabric")
		add(head, "ScarfTail", "box", { 0.3, 0.9, 0.12 }, { 0.36, -1.1, -0.66 }, accColor, "fabric", { 0, 0, -8 })
	elseif acc == "headband" then
		add(head, "Headband", "cyl", { 1.3, 0.14, 1.3 }, { 0, 0.34, 0 }, accColor, "fabric")
	elseif acc == "earring" then
		add(head, "Earring", "ball", { 0.14, 0.14, 0.14 }, { 0.64, -0.14, 0 }, accessoryO.color or BRASS, "metal")
	elseif acc == "fedora" then
		add(head, "HatBrim", "cyl", { 1.7, 0.07, 1.7 }, { 0, 0.62, 0 }, accColor, "fabric")
		add(head, "Hat", "cyl", { 1.24, 0.5, 1.24 }, { 0, 0.86, 0 }, accColor, "fabric")
		add(head, "HatBand", "cyl", { 1.26, 0.1, 1.26 }, { 0, 0.68, 0 }, shade(accColor, 0.6), "fabric")
	end
	local hatOn = acc == "fedora"

	-- hair: built from a few shapes that sit ON the head (a crown over the top, a fall down
	-- the back, sides over the ears, a fringe above the eyes), so every style has volume and
	-- reads at portrait size. The head is a cylinder 1.25 across and 1.2 tall, centered at 0;
	-- the face is on -Z and the eyes sit at y = 0.08.
	local style = hairO.style or "crop"
	local hc = hairColor
	local hd = shade(hairColor, 0.82) -- a darker tone for the under-layers
	local function cap(height: number, y: number, d: number?)
		add(head, "Hair", "cyl", { d or 1.32, height, d or 1.32 }, { 0, y, 0 }, hc, "fabric")
	end
	local function crown(h: number, d: number?)
		add(head, "Hair", "cyl", { d or 1.4, h, d or 1.4 }, { 0, 0.5 + h / 2, 0.02 }, hc, "fabric")
	end
	local function back(len: number, w: number?, z: number?)
		add(head, "Hair", "box", { w or 1.36, len, 0.38 }, { 0, 0.56 - len / 2, z or 0.52 }, hd, "fabric")
	end
	local function sides(len: number, depth: number?)
		for _, side in { -1, 1 } do
			add(head, "Hair", "box", { 0.2, len, depth or 0.86 }, { 0.66 * side, 0.56 - len / 2, 0.14 }, hd, "fabric")
		end
	end
	local function bangs(h: number, w: number?, x: number?, tilt: number?)
		add(head, "Bangs", "box", { w or 1.24, h, 0.16 }, { x or 0, 0.62 - h / 2, -0.63 }, hc, "fabric", if tilt then { 0, 0, tilt } else nil)
	end
	local function stubble()
		add(head, "Hair", "cyl", { 1.3, 0.1, 1.3 }, { 0, 0.6, 0 }, hd, "fabric")
		add(head, "Hair", "box", { 1.28, 0.5, 0.05 }, { 0, 0.33, 0.63 }, hd, "fabric")
		for _, side in { -1, 1 } do
			add(head, "Hair", "box", { 0.05, 0.42, 0.8 }, { 0.63 * side, 0.36, 0.16 }, hd, "fabric")
		end
	end
	local function ball(d: number, x: number, y: number, z: number, dark: boolean?)
		add(head, "Hair", "ball", { d, d, d }, { x, y, z }, if dark then hd else hc, "fabric")
	end
	if hatOn and style ~= "long" and style ~= "ponytail" and style ~= "braid" and style ~= "hime" and style ~= "wavy" and style ~= "lowtails" then
		style = "shorn"
	end
	if style == "shorn" then
		stubble()
	elseif style == "crop" then
		crown(0.26)
		back(0.72)
		sides(0.46)
		bangs(0.2)
	elseif style == "slick" then
		crown(0.2)
		add(head, "Hair", "box", { 1.3, 0.3, 1.2 }, { 0, 0.72, 0.1 }, hc, "fabric", { -9, 0, 0 })
		back(0.66)
		sides(0.4)
	elseif style == "spiky" then
		crown(0.22)
		back(0.5)
		sides(0.36)
		for _, sp in { { -0.4, 0.86, -0.3, -24, 18 }, { 0.4, 0.86, -0.3, -24, -18 }, { 0, 0.98, -0.1, -10, 0 }, { -0.42, 0.86, 0.3, 14, 20 }, { 0.42, 0.86, 0.3, 14, -20 }, { 0, 0.9, 0.5, 26, 0 }, { 0, 0.82, -0.56, -40, 0 } } do
			add(head, "Spike", "box", { 0.3, 0.62, 0.3 }, { sp[1], sp[2], sp[3] }, hc, "fabric", { sp[4], 0, sp[5] })
		end
	elseif style == "ponytail" then
		crown(0.28)
		back(0.5)
		sides(0.4)
		bangs(0.2)
		ball(0.3, 0, 0.44, 0.76, true)
		add(head, "Tail", "box", { 0.38, 1.3, 0.36 }, { 0, -0.2, 0.98 }, hc, "fabric", { 16, 0, 0 })
	elseif style == "bob" then
		crown(0.3)
		back(1.06)
		sides(1.0)
		bangs(0.3)
	elseif style == "twintails" then
		crown(0.28)
		back(0.5)
		sides(0.4)
		bangs(0.24)
		for _, side in { -1, 1 } do
			ball(0.3, 0.74 * side, 0.36, 0.14, true)
			add(head, "Tail", "box", { 0.36, 1.5, 0.36 }, { 0.98 * side, -0.42, 0.14 }, hc, "fabric", { 0, 0, 12 * side })
		end
	elseif style == "sidecut" then
		stubble()
		add(head, "Hair", "box", { 0.86, 0.46, 1.42 }, { -0.24, 0.76, 0 }, hc, "fabric")
		add(head, "Fringe", "box", { 0.56, 0.72, 0.16 }, { -0.36, 0.32, -0.64 }, hc, "fabric", { 0, 0, -8 })
	elseif style == "messy" then
		crown(0.32)
		back(0.72)
		sides(0.5)
		bangs(0.18, 0.5, -0.32)
		bangs(0.3, 0.34, 0.12, 8)
		bangs(0.14, 0.3, 0.46)
		for _, tf in { { -0.56, 0.74, -0.2, 0, 30 }, { 0.56, 0.78, 0.1, 0, -34 }, { 0.1, 0.94, -0.3, -30, 8 }, { -0.2, 0.96, 0.3, 24, -6 }, { 0.36, 0.9, 0.44, 30, -20 } } do
			add(head, "Tuft", "box", { 0.3, 0.44, 0.3 }, { tf[1], tf[2], tf[3] }, hc, "fabric", { tf[4], 0, tf[5] })
		end
	elseif style == "long" then
		crown(0.28)
		back(1.95)
		sides(1.4)
		bangs(0.22, 0.56, -0.34, 6)
		bangs(0.22, 0.56, 0.34, -6)
	elseif style == "bun" then
		crown(0.24)
		back(0.6)
		sides(0.44)
		bangs(0.2)
		ball(0.7, 0, 0.78, 0.46)
	elseif style == "braid" then
		crown(0.28)
		back(0.7)
		sides(0.46)
		bangs(0.22)
		for i, y in { -0.26, -0.62, -0.96, -1.28 } do
			ball(0.42 - i * 0.03, 0, y, 0.74)
		end
		ball(0.2, 0, -1.52, 0.74, true)
	elseif style == "curls" then
		ball(1.0, 0, 0.72, 0.06)
		for _, c in { { -0.46, 0.66, -0.3 }, { 0.46, 0.66, -0.3 }, { 0, 0.8, -0.42 }, { -0.62, 0.42, 0.14 }, { 0.62, 0.42, 0.14 }, { -0.42, 0.52, 0.52 }, { 0.42, 0.52, 0.52 }, { 0, 0.3, 0.68 }, { -0.6, 0.04, 0.32 }, { 0.6, 0.04, 0.32 } } do
			ball(0.56, c[1], c[2], c[3])
		end
	elseif style == "ridge" then
		stubble()
		add(head, "Hair", "box", { 0.32, 0.5, 1.42 }, { 0, 0.84, 0 }, hc, "fabric")
	elseif style == "wavy" then
		crown(0.3)
		back(1.5)
		sides(1.2)
		bangs(0.26, 0.9, -0.14, 7)
		for _, x in { -0.5, 0, 0.5 } do
			ball(0.5, x, -0.96, 0.52)
		end
		for _, side in { -1, 1 } do
			ball(0.42, 0.68 * side, -0.62, 0.14)
		end
	elseif style == "hime" then
		crown(0.28)
		back(2.05)
		sides(0.5)
		bangs(0.34)
		for _, side in { -1, 1 } do
			add(head, "Lock", "box", { 0.24, 1.1, 0.34 }, { 0.62 * side, -0.02, -0.4 }, hc, "fabric")
		end
	elseif style == "afro" then
		ball(1.7, 0, 0.62, 0.08)
		for _, c in { { -0.7, 0.3, 0.1 }, { 0.7, 0.3, 0.1 }, { 0, 0.3, 0.72 }, { -0.5, 0.86, -0.4 }, { 0.5, 0.86, -0.4 }, { 0, 1.16, 0.1 } } do
			ball(0.9, c[1], c[2], c[3])
		end
	elseif style == "topknot" then
		stubble()
		crown(0.16, 1.2)
		add(head, "Hair", "cyl", { 0.3, 0.26, 0.3 }, { 0, 0.86, 0.12 }, hd, "fabric")
		ball(0.46, 0, 1.08, 0.12)
	elseif style == "pompadour" then
		crown(0.24)
		back(0.62)
		sides(0.46)
		add(head, "Hair", "ball", { 1.1, 0.66, 0.78 }, { 0, 0.92, -0.34 }, hc, "fabric")
	elseif style == "undercut" then
		stubble()
		add(head, "Hair", "box", { 1.02, 0.34, 1.34 }, { 0, 0.78, 0.04 }, hc, "fabric", { -6, 0, 0 })
		add(head, "Hair", "box", { 0.92, 0.3, 0.34 }, { 0, 0.86, -0.52 }, hc, "fabric", { -24, 0, 0 })
	elseif style == "lowtails" then
		crown(0.28)
		back(0.56)
		sides(0.44)
		bangs(0.24)
		for _, side in { -1, 1 } do
			ball(0.26, 0.5 * side, -0.14, 0.6, true)
			add(head, "Tail", "box", { 0.32, 1.1, 0.32 }, { 0.54 * side, -0.82, 0.62 }, hc, "fabric", { 6, 0, 4 * side })
		end
	elseif style == "locs" then
		crown(0.3)
		for _, l in { { -0.6, 0.2, 1.3 }, { -0.5, 0.5, 1.5 }, { -0.2, 0.66, 1.6 }, { 0.2, 0.66, 1.6 }, { 0.5, 0.5, 1.5 }, { 0.6, 0.2, 1.3 }, { -0.66, -0.12, 1.1 }, { 0.66, -0.12, 1.1 }, { 0, 0.7, 1.4 } } do
			add(head, "Loc", "box", { 0.2, l[3], 0.2 }, { l[1], 0.56 - l[3] / 2, l[2] }, if (l[1] * 10) % 2 == 0 then hc else hd, "fabric")
		end
		bangs(0.18)
	elseif style == "sidebraid" then
		crown(0.28)
		back(0.6)
		sides(0.46)
		bangs(0.26, 0.9, 0.14, -7)
		for i, y in { -0.1, -0.44, -0.78, -1.1 } do
			ball(0.4 - i * 0.03, 0.62, y, -0.3)
		end
		ball(0.2, 0.62, -1.34, -0.3, true)
	elseif style == "halfup" then
		crown(0.28)
		back(1.6)
		sides(1.1)
		bangs(0.22)
		ball(0.5, 0, 0.86, 0.36)
	elseif style == "bowl" then
		crown(0.36)
		add(head, "Hair", "cyl", { 1.48, 0.42, 1.48 }, { 0, 0.47, 0.02 }, hc, "fabric")
	elseif style == "shaggy" then
		crown(0.32)
		back(1.2, 0.5, 0.52)
		add(head, "Hair", "box", { 0.44, 0.9, 0.38 }, { -0.46, 0.11, 0.52 }, hd, "fabric")
		add(head, "Hair", "box", { 0.44, 1.05, 0.38 }, { 0.46, 0.04, 0.52 }, hd, "fabric")
		sides(0.8)
		bangs(0.34, 0.3, -0.42, 6)
		bangs(0.4, 0.26, -0.06)
		bangs(0.3, 0.34, 0.36, -8)
	elseif style == "curtains" then
		crown(0.26)
		back(0.9)
		sides(0.8)
		for _, side in { -1, 1 } do
			add(head, "Bangs", "box", { 0.5, 0.5, 0.16 }, { 0.42 * side, 0.42, -0.63 }, hc, "fabric", { 0, 0, 16 * side })
		end
	elseif style == "hood" then
		local wool = { 66, 60, 56 }
		cap(0.14, 0.56, 1.28)
		add(head, "Hood", "box", { 1.5, 0.28, 1.46 }, { 0, 0.72, 0.06 }, wool, "fabric")
		for _, side in { -1, 1 } do
			add(head, "Hood", "box", { 0.2, 1.22, 1.42 }, { 0.74 * side, 0.12, 0.06 }, wool, "fabric")
		end
		add(head, "Hood", "box", { 1.5, 1.4, 0.22 }, { 0, 0.02, 0.76 }, wool, "fabric")
		add(head, "Hood", "box", { 2.1, 0.3, 1.16 }, { 0, -0.72, 0.04 }, wool, "fabric")
	elseif style == "cap" then
		local navy = { 34, 40, 62 }
		cap(0.14, 0.56, 1.28)
		add(head, "Cap", "cyl", { 1.36, 0.36, 1.36 }, { 0, 0.7, 0 }, navy, "fabric")
		add(head, "CapBand", "cyl", { 1.38, 0.1, 1.38 }, { 0, 0.56, 0 }, DARK, "fabric")
		add(head, "CapBrim", "box", { 0.95, 0.07, 0.5 }, { 0, 0.52, -0.78 }, DARK, "plastic")
		add(head, "CapBadge", "box", { 0.18, 0.18, 0.05 }, { 0, 0.7, -0.69 }, BRASS, "metal")
	elseif style == "tophat" then
		local felt = { 30, 28, 32 }
		cap(0.14, 0.56, 1.28)
		add(head, "HatBrim", "cyl", { 1.62, 0.08, 1.62 }, { 0, 0.6, 0 }, felt, "fabric")
		add(head, "Hat", "cyl", { 1.12, 0.95, 1.12 }, { 0, 1.1, 0 }, felt, "fabric")
		add(head, "HatBand", "cyl", { 1.14, 0.16, 1.14 }, { 0, 0.74, 0 }, BRASS, "metal")
		add(head, "HatLamp", "ball", { 0.24, 0.24, 0.24 }, { 0.5, 0.78, -0.3 }, { 255, 210, 120 }, "neon")
	elseif style == "veil" then
		local pale = { 222, 228, 232 }
		add(head, "Veil", "cyl", { 1.36, 0.18, 1.36 }, { 0, 0.64, 0 }, pale, "fabric")
		add(head, "Veil", "box", { 1.4, 1.7, 0.2 }, { 0, -0.2, 0.72 }, pale, "fabric")
		for _, side in { -1, 1 } do
			add(head, "Veil", "box", { 0.16, 1.2, 1.2 }, { 0.72 * side, 0.05, 0.15 }, pale, "fabric")
		end
	end

	-- (v0.17) a feminine build: the waist, and everything over it
	if feminine then
		body = shapeFeminine(body, toolFrom)
	end

	-- ── put it together at the right size for the age ──
	local bs, hs = ageScale(age)
	local parts = {}
	for _, p in body do
		if not (opts.portrait and p.legs) then
			p.size = { p.size[1] * bs, p.size[2] * bs, p.size[3] * bs }
			p.pos = { p.pos[1] * bs, p.pos[2] * bs, p.pos[3] * bs }
			p.legs = nil
			table.insert(parts, p)
		end
	end
	local headY = 4.0 * bs + 0.62 * hs
	for _, p in head do
		p.size = { p.size[1] * hs, p.size[2] * hs, p.size[3] * hs }
		p.pos = { p.pos[1] * hs, headY + p.pos[2] * hs, p.pos[3] * hs }
		p.legs = nil
		-- (v0.18) everything built on the head (hair of every kind, hats, veils, masks...) moves
		-- with the head: an animator must never swing it with an arm or a leg
		p.onHead = true
		table.insert(parts, p)
	end
	-- the highest point of any part (tall hats stick up past the head)
	local top = headY + 0.78 * hs
	for _, p in parts do
		local reach = if p.rot then math.max(p.size[1], p.size[2], p.size[3]) / 2 else p.size[2] / 2
		top = math.max(top, p.pos[2] + reach)
	end
	return parts, { height = headY + 0.78 * hs, top = top, headY = headY, headSize = 1.25 * hs, bodyScale = bs }
end

return Avatar
