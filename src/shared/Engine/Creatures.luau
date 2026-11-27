--[[
	Creatures: the things across the fight screen that aren't people any more, as lists of
	simple parts in the same format Engine/Avatar uses, so the same kind of view draws them
	(the Roblox client builds Parts in a ViewportFrame: UI/CreatureView).

		local parts, frame = Creatures.build(def, opts?)

	def = {
		shape = "bird" | "beast" | "tall" | ...   -- one of Creatures.shapes; unknown -> Creatures.default
		color = { r, g, b }?,   -- the body color (each shape has its own default)
		eye = { r, g, b }?,     -- the lit color: eyes, lamps, glowing seams
		seed = number?,         -- varies the details; without it the name (or id) is hashed,
		name = string?,         --   so "The Doorkeeper" always looks like itself
		pose = "idle" | "strike" | "hurt" | "down"?,
	}
	A shape can name one of its variants after a colon: "blob:doll", "mass:gears"
	(Creatures.variants[shape] lists them). Without one, the seed picks.
	opts.ground = false leaves out the dark disc under the creature.

	Each part: { name, shape = "box" | "ball" | "cyl", size = { x, y, z }, pos = { x, y, z },
	             rot = { rx, ry, rz }? (degrees, applied like CFrame.Angles),
	             color = { r, g, b }, material = "plastic" | "neon" | "metal" | "fabric" | "wood",
	             transparency = number? (0..1, a few glass and glow parts),
	             anim = string? (the tag of the moving group this part belongs to) }
	"cyl" is an upright cylinder: size.x is the diameter and size.y the height.
	The creature stands on y = 0, faces -Z, and its right side is at +X, like an Avatar figure.

	frame = {
		height, top, headY, headSize,   -- as Avatar's frame, so the same camera code works
		center = { x, y, z }, size = { x, y, z },   -- the idle pose's bounding box
		focus = { x, y, z },            -- the face (or what stands in for one), for portraits
		angle = number,                 -- a good camera angle (degrees; + turns it to face screen-left)
		shape, variant, seed, pose,     -- what was built
		anim = { ... },                 -- idle motion, see below
	}
	The frame always describes the idle pose, whatever pose was asked for, so a camera aimed
	with it stays put while the creature lunges, recoils or drops.

	frame.anim is a list, parents before children, of the moving groups:
		{ tag = string, parent = string?, pivot = { x, y, z }, motions = { motion, ... } }
	A view moves every part whose `anim` is that tag (and the parts of its child groups)
	by the group's motions, in order. Motions (rate in cycles per second, phase 0..1):
		{ kind = "swing",  axis, amp = degrees, rate, phase }   rocks about the pivot
		{ kind = "twitch", axis, amp = degrees, rate, phase }   still, then a quick jerk and back
		{ kind = "spin",   axis, rate, phase }                  turns all the way round
		{ kind = "bob",    dir, amp = studs, rate, phase }      slides back and forth along dir
		{ kind = "blink" | "pulse" | "flicker", rate, phase, off = { r, g, b } }
		                                                        the group's neon parts go dim
	A creature that is "down" has no motions.

	Creatures.shapes     the shape ids, in a sensible order for a contact sheet
	Creatures.variants   { [shape] = { variant ids } } for the shapes that have them
	Creatures.poses      { "idle", "strike", "hurt", "down" }
	Creatures.default    the shape an unknown id draws
	Creatures.signature(def) -> string   changes whenever the drawn creature would change
	Creatures.resolve(def) -> shape, variant?, seed

	Pure Luau: no Roblox types, so it runs under Lune and in tests.
]]

local Detail = require(script.Parent.CreatureDetail)

local Creatures = {}

Creatures.poses = { "idle", "strike", "hurt", "down" }
Creatures.shapes = {}
Creatures.variants = {}
Creatures.default = "blob"

-- ── vectors and rotations (plain arrays; a rotation is a 3x3 matrix, row by row) ──

local sin, cos, rad, deg, abs, sqrt = math.sin, math.cos, math.rad, math.deg, math.abs, math.sqrt

local IDENTITY = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }

local function mmul(a, b)
	return {
		a[1] * b[1] + a[2] * b[4] + a[3] * b[7], a[1] * b[2] + a[2] * b[5] + a[3] * b[8], a[1] * b[3] + a[2] * b[6] + a[3] * b[9],
		a[4] * b[1] + a[5] * b[4] + a[6] * b[7], a[4] * b[2] + a[5] * b[5] + a[6] * b[8], a[4] * b[3] + a[5] * b[6] + a[6] * b[9],
		a[7] * b[1] + a[8] * b[4] + a[9] * b[7], a[7] * b[2] + a[8] * b[5] + a[9] * b[8], a[7] * b[3] + a[8] * b[6] + a[9] * b[9],
	}
end

local function mapply(m, v)
	return {
		m[1] * v[1] + m[2] * v[2] + m[3] * v[3],
		m[4] * v[1] + m[5] * v[2] + m[6] * v[3],
		m[7] * v[1] + m[8] * v[2] + m[9] * v[3],
	}
end

local function mtranspose(m)
	return { m[1], m[4], m[7], m[2], m[5], m[8], m[3], m[6], m[9] }
end

-- degrees -> matrix, composed like CFrame.Angles(rx, ry, rz): Rx * Ry * Rz
local function euler(rx: number, ry: number, rz: number)
	local ca, sa = cos(rad(rx)), sin(rad(rx))
	local cb, sb = cos(rad(ry)), sin(rad(ry))
	local cc, sc = cos(rad(rz)), sin(rad(rz))
	return {
		cb * cc, -cb * sc, sb,
		ca * sc + sa * sb * cc, ca * cc - sa * sb * sc, -sa * cb,
		sa * sc - ca * sb * cc, sa * cc + ca * sb * sc, ca * cb,
	}
end

-- matrix -> { rx, ry, rz } in degrees (the inverse of euler)
local function toEuler(m)
	local sb = math.clamp(m[3], -1, 1)
	local ry = math.asin(sb)
	local rx, rz
	if abs(sb) < 0.99999 then
		rx = math.atan2(-m[6], m[9])
		rz = math.atan2(-m[2], m[1])
	else
		rx = math.atan2(m[8], m[5])
		rz = 0
	end
	return { deg(rx), deg(ry), deg(rz) }
end

local function isIdentity(m): boolean
	return abs(m[1] - 1) < 1e-6 and abs(m[5] - 1) < 1e-6 and abs(m[9] - 1) < 1e-6
end

local function vadd(a, b)
	return { a[1] + b[1], a[2] + b[2], a[3] + b[3] }
end

local function vsub(a, b)
	return { a[1] - b[1], a[2] - b[2], a[3] - b[3] }
end

local function vscale(a, k: number)
	return { a[1] * k, a[2] * k, a[3] * k }
end

local function vlen(a): number
	return sqrt(a[1] * a[1] + a[2] * a[2] + a[3] * a[3])
end

local function vlerp(a, b, t: number)
	return { a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t }
end

-- The smallest turn that points a part's own Y axis along `dir` (so a bone keeps its width
-- across and its depth front to back, as far as the direction allows), then `roll` about it.
local function alongY(dir, roll: number?)
	local len = vlen(dir)
	local m = IDENTITY
	if len > 1e-9 then
		local x, y, z = dir[1] / len, dir[2] / len, dir[3] / len
		if y < 0 then
			x, y, z = -x, -y, -z -- a box is the same either way up; this keeps the turn small
		end
		local s = sqrt(x * x + z * z)
		if s > 1e-9 then
			-- Rodrigues about k = Y x dir = (z, 0, -x) / s, by the angle with cos = y, sin = s
			local kx, kz = z / s, -x / s
			local c, t = y, 1 - y
			m = {
				c + t * kx * kx, -s * kz, t * kx * kz,
				s * kz, c, -s * kx,
				t * kx * kz, s * kx, c + t * kz * kz,
			}
		end
	end
	if roll and roll ~= 0 then
		m = mmul(m, euler(0, roll, 0))
	end
	return m
end

-- ── colors ──

local function clamp255(n: number): number
	return math.clamp(math.floor(n + 0.5), 0, 255)
end

local function shade(c, f: number)
	return { clamp255(c[1] * f), clamp255(c[2] * f), clamp255(c[3] * f) }
end

local function mix(a, b, t: number)
	return { clamp255(a[1] + (b[1] - a[1]) * t), clamp255(a[2] + (b[2] - a[2]) * t), clamp255(a[3] + (b[3] - a[3]) * t) }
end

local function isColor(c): boolean
	if type(c) ~= "table" then
		return false
	end
	for i = 1, 3 do
		local n = c[i]
		if type(n) ~= "number" or n ~= n or n < 0 or n > 255 then
			return false
		end
	end
	return true
end

local _WHITE = { 255, 255, 255 }
local _BLACK = { 0, 0, 0 }
local BRASS = { 196, 154, 72 }
local STEEL = { 156, 160, 168 }
local IRON = { 74, 76, 84 }
local _RUST = { 136, 78, 46 }
local BONE = { 226, 220, 204 }
local SOOT = { 26, 26, 30 }
local GROUND = { 20, 21, 27 }

-- ── a small seeded generator (MINSTD), so a seed always draws the same creature ──

local MOD = 2147483647

local function newRng(seed: number)
	local state = math.floor(abs(seed)) % MOD
	if state == 0 then
		state = 1
	end
	local rng = {}
	-- a float in [0, 1)
	function rng.next(): number
		state = (state * 48271) % MOD
		return (state - 1) / (MOD - 1)
	end
	-- a float in [a, b)
	function rng.range(a: number, b: number): number
		return a + (b - a) * rng.next()
	end
	-- an integer in a..b
	function rng.int(a: number, b: number): number
		return a + math.floor(rng.next() * (b - a + 1))
	end
	function rng.chance(p: number): boolean
		return rng.next() < p
	end
	function rng.pick(list)
		return list[rng.int(1, #list)]
	end
	-- the first few values of MINSTD follow the seed closely; throw them away
	for _ = 1, 4 do
		rng.next()
	end
	return rng
end

local function hashString(s: string): number
	local h = 5381
	for i = 1, #s do
		h = (h * 33 + string.byte(s, i)) % MOD
	end
	return if h == 0 then 1 else h
end

-- ── the builder: parts hung on joints, posed, then flattened into a plain list ──

local Builder = {}
Builder.__index = Builder

local function newBuilder(pose: string, rng, body, eye)
	return setmetatable({
		pose = pose,
		down = pose == "down",
		rng = rng,
		body = body, -- the body color asked for
		eye = eye, -- the lit color asked for
		parts = {},
		joints = {},
		order = {},
		current = nil, -- the joint new parts hang on
		M = IDENTITY, -- where new parts go: world = M * (local * S) + T
		T = { 0, 0, 0 },
		S = 1,
		focus = nil,
		headSize = nil,
		angle = nil,
		height = nil,
		groundSize = nil,
	}, Builder)
end

function Builder:_add(name: string, shape: string, size, pos, m, color, material: string?)
	local S = self.S
	local part = {
		name = name,
		shape = shape,
		size = { size[1] * S, size[2] * S, size[3] * S },
		pos = vadd(mapply(self.M, vscale(pos, S)), self.T),
		m = mmul(self.M, m),
		color = color,
		material = material or "plastic",
		joint = self.current,
	}
	table.insert(self.parts, part)
	return part
end

function Builder:box(name: string, size, pos, color, material: string?, rot)
	return self:_add(name, "box", size, pos, if rot then euler(rot[1], rot[2], rot[3]) else IDENTITY, color, material)
end

function Builder:ball(name: string, diameter: number, pos, color, material: string?)
	return self:_add(name, "ball", { diameter, diameter, diameter }, pos, IDENTITY, color, material)
end

-- an upright cylinder (its axis is its own Y), turned by rot
function Builder:cyl(name: string, diameter: number, height: number, pos, color, material: string?, rot)
	return self:_add(name, "cyl", { diameter, height, diameter }, pos, if rot then euler(rot[1], rot[2], rot[3]) else IDENTITY, color, material)
end

-- a box from a to b: `width` across, `depth` the other way, `extra` longer than the gap
function Builder:bone(name: string, a, b, width: number, depth: number, color, material: string?, roll: number?, extra: number?)
	local d = vsub(b, a)
	return self:_add(name, "box", { width, vlen(d) + (extra or 0), depth }, vlerp(a, b, 0.5), alongY(d, roll), color, material)
end

-- a cylinder from a to b
function Builder:rod(name: string, a, b, diameter: number, color, material: string?, extra: number?)
	local d = vsub(b, a)
	return self:_add(name, "cyl", { diameter, vlen(d) + (extra or 0), diameter }, vlerp(a, b, 0.5), alongY(d), color, material)
end

-- a flat cylinder at `center` whose faces look along `normal` (a lens, a saw, a wheel)
function Builder:disc(name: string, center, normal, diameter: number, thickness: number, color, material: string?)
	return self:_add(name, "cyl", { diameter, thickness, diameter }, center, alongY(normal), color, material)
end

-- a lit part: neon in the eye color, or a dull dark one when the creature is down
function Builder:lit(color)
	if self.down then
		return mix(shade(color, 0.22), { 30, 30, 34 }, 0.5), "plastic"
	end
	return color, "neon"
end

-- Builds a sub-figure somewhere else: `fn` draws at the origin and it lands at `at`,
-- turned by yaw (then pitch, roll) and scaled.
function Builder:place(at, yaw: number?, scale: number?, fn, pitch: number?, roll: number?)
	local M, T, S = self.M, self.T, self.S
	self.T = vadd(mapply(M, vscale(at, S)), T)
	self.M = mmul(M, euler(pitch or 0, yaw or 0, roll or 0))
	self.S = S * (scale or 1)
	fn()
	self.M, self.T, self.S = M, T, S
end

-- A joint: parts added inside `fn` hang on it, and it hangs on the joint around it.
-- `pivot` is where it turns (in the coordinates being drawn in).
function Builder:group(name: string, pivot, fn)
	assert(self.joints[name] == nil, "duplicate joint " .. name)
	local joint = {
		name = name,
		parent = self.current,
		pivot = vadd(mapply(self.M, vscale(pivot, self.S)), self.T),
		frame = self.M,
		scale = self.S,
		rot = IDENTITY,
		shift = { 0, 0, 0 },
		motions = {},
	}
	self.joints[name] = joint
	table.insert(self.order, joint)
	local before = self.current
	self.current = name
	fn()
	self.current = before
end

-- pose: turn a joint about its pivot (degrees, in its own frame), on top of earlier turns
function Builder:turn(name: string, rx: number, ry: number?, rz: number?)
	local joint = self.joints[name]
	if joint then
		joint.rot = mmul(euler(rx, ry or 0, rz or 0), joint.rot)
	end
end

-- pose: slide a joint
function Builder:shift(name: string, dx: number, dy: number, dz: number)
	local joint = self.joints[name]
	if joint then
		joint.shift = { joint.shift[1] + dx, joint.shift[2] + dy, joint.shift[3] + dz }
	end
end

-- idle motion on a joint (see the header for the kinds)
function Builder:motion(name: string, spec)
	local joint = self.joints[name]
	if joint and not self.down then
		table.insert(joint.motions, spec)
	end
end

-- common motions, so shapes read like a list of what moves
function Builder:swing(name: string, axis, amp: number, rate: number, phase: number?)
	self:motion(name, { kind = "swing", axis = axis, amp = amp, rate = rate, phase = phase or 0 })
end

function Builder:twitch(name: string, axis, amp: number, rate: number, phase: number?)
	self:motion(name, { kind = "twitch", axis = axis, amp = amp, rate = rate, phase = phase or 0 })
end

function Builder:bob(name: string, amp: number, rate: number, phase: number?, dir)
	self:motion(name, { kind = "bob", dir = dir or { 0, 1, 0 }, amp = amp, rate = rate, phase = phase or 0 })
end

function Builder:spin(name: string, axis, rate: number, phase: number?)
	self:motion(name, { kind = "spin", axis = axis, rate = rate, phase = phase or 0 })
end

function Builder:glow(name: string, kind: string, rate: number, phase: number?, off)
	self:motion(name, { kind = kind, rate = rate, phase = phase or 0, off = off })
end

-- where the face is, and how big (a portrait shows about two and a half head sizes)
function Builder:face(pos, headSize: number)
	self.focus = vadd(mapply(self.M, vscale(pos, self.S)), self.T)
	self.headSize = headSize * self.S
end

-- Flattens joints and poses into finished parts and the list of moving groups.
function Builder:bake()
	local joints = self.joints
	for _, j in self.order do
		local parent = j.parent and joints[j.parent]
		local pm = if parent then parent.M else IDENTITY
		local pt = if parent then parent.T else { 0, 0, 0 }
		local rw = mmul(mmul(j.frame, j.rot), mtranspose(j.frame)) -- the turn, seen from outside
		local sw = mapply(j.frame, vscale(j.shift, j.scale))
		local moved = vadd(j.pivot, sw)
		j.M = mmul(pm, rw)
		j.T = vadd(mapply(pm, vsub(moved, mapply(rw, j.pivot))), pt)
		j.at = vadd(mapply(pm, moved), pt) -- where the pivot ends up
		j.axes = mmul(pm, j.frame) -- maps a motion's axis into the finished pose
		-- the nearest joint at or above this one that moves by itself
		j.tag = if #j.motions > 0 then j.name else (parent and parent.tag or nil)
		j.parentTag = parent and parent.tag or nil
	end
	local parts = {}
	for _, p in self.parts do
		local j = p.joint and joints[p.joint]
		local pos, m = p.pos, p.m
		if j then
			pos = vadd(mapply(j.M, pos), j.T)
			m = mmul(j.M, m)
		end
		table.insert(parts, {
			name = p.name,
			shape = p.shape,
			size = p.size,
			pos = pos,
			rot = if isIdentity(m) then nil else toEuler(m),
			color = p.color,
			material = p.material,
			transparency = p.transparency,
			anim = j and j.tag or nil,
			m = m, -- dropped before the list leaves this module
		})
	end
	local anim = {}
	for _, j in self.order do
		if #j.motions > 0 then
			local motions = {}
			for _, spec in j.motions do
				local out = table.clone(spec)
				if spec.axis then
					out.axis = mapply(j.axes, spec.axis)
				end
				if spec.dir then
					out.dir = mapply(j.axes, spec.dir)
					out.amp = (spec.amp or 0) * j.scale
				end
				table.insert(motions, out)
			end
			table.insert(anim, { tag = j.name, parent = j.parentTag, pivot = j.at, motions = motions })
		end
	end
	return parts, anim
end

-- the box around the finished parts
local function boundsOf(parts)
	local lo = { math.huge, math.huge, math.huge }
	local hi = { -math.huge, -math.huge, -math.huge }
	for _, p in parts do
		local hx, hy, hz
		local s = p.size
		if p.shape == "ball" then
			hx, hy, hz = s[1] / 2, s[1] / 2, s[1] / 2
		else
			local m = p.m
			local x, y, z = s[1] / 2, s[2] / 2, s[3] / 2
			hx = abs(m[1]) * x + abs(m[2]) * y + abs(m[3]) * z
			hy = abs(m[4]) * x + abs(m[5]) * y + abs(m[6]) * z
			hz = abs(m[7]) * x + abs(m[8]) * y + abs(m[9]) * z
		end
		local c = p.pos
		lo[1], lo[2], lo[3] = math.min(lo[1], c[1] - hx), math.min(lo[2], c[2] - hy), math.min(lo[3], c[3] - hz)
		hi[1], hi[2], hi[3] = math.max(hi[1], c[1] + hx), math.max(hi[2], c[2] + hy), math.max(hi[3], c[3] + hz)
	end
	return lo, hi
end

-- ── the shapes ──────────────────────────────────────────────────────────────
-- Each is a function(b, ctx) that draws with the builder `b`. ctx = { pose, rng, body, eye,
-- variant }. They draw the idle pose first, then turn joints for the pose asked for.

local SHAPES = {}
local DEFAULTS = {} -- shape -> { color, eye }

local function register(id: string, defaults, variants, fn)
	SHAPES[id] = fn
	DEFAULTS[id] = defaults
	table.insert(Creatures.shapes, id)
	if variants then
		Creatures.variants[id] = variants
	end
end

-- beast: a stray Backstreets hound. Lean, ribs showing, one ear torn, a snapped chain.
register("beast", { color = { 96, 82, 72 }, eye = { 240, 200, 80 } }, nil, function(b, ctx)
	local rng = ctx.rng
	local fur = ctx.body
	local dark = shade(fur, 0.6)
	local pale = mix(fur, { 176, 160, 142 }, 0.4)
	local rib = mix(fur, { 206, 192, 172 }, 0.45)
	local muzzle = shade(fur, 0.42)
	local eye, eyeMat = b:lit(ctx.eye)
	local tornLeft = rng.chance(0.75)
	local patchZ = rng.range(-0.5, 0.2)

	b:group("root", { 0, 1.3, 0.2 }, function()
		-- the barrel of the chest, and a waist that tucks up behind it
		b:group("chest", { 0, 2.0, -0.4 }, function()
			b:bone("Ribcage", { 0, 1.98, -1.5 }, { 0, 2.12, 0.5 }, 1.06, 1.34, fur, "fabric")
			b:bone("Keel", { 0, 1.42, -1.35 }, { 0, 1.62, 0.15 }, 0.62, 0.4, pale, "fabric")
			for _, side in { -1, 1 } do
				for i = 0, 3 do
					local z = -1.18 + i * 0.4
					b:bone("Rib", { 0.545 * side, 2.52, z + 0.1 }, { 0.545 * side, 1.56 + i * 0.07, z - 0.14 }, 0.07, 0.11, rib, "fabric")
				end
				b:bone("Shoulder", { 0.5 * side, 2.72, -1.0 }, { 0.56 * side, 1.95, -1.28 }, 0.2, 0.62, dark, "fabric")
			end
			for i = 0, 3 do
				b:box("Spine", { 0.24, 0.16, 0.26 }, { 0, 2.78 - i * 0.012, -1.1 + i * 0.44 }, dark, "fabric", { -4, 0, 0 })
			end
			b:bone("Scar", { -0.55, 2.3, patchZ }, { -0.55, 1.9, patchZ + 0.42 }, 0.04, 0.07, mix(rib, { 220, 150, 140 }, 0.4), "plastic")
		end)
		b:bone("Loin", { 0, 2.24, 0.4 }, { 0, 2.3, 1.45 }, 0.74, 0.78, fur, "fabric")
		b:box("Hips", { 0.98, 0.92, 0.86 }, { 0, 2.24, 1.6 }, fur, "fabric", { 8, 0, 0 })
		for i = 0, 2 do
			b:box("Spine", { 0.22, 0.14, 0.24 }, { 0, 2.72 - i * 0.02, 0.72 + i * 0.42 }, dark, "fabric", { 4, 0, 0 })
		end
		for _, side in { -1, 1 } do
			b:box("HipBone", { 0.12, 0.3, 0.34 }, { 0.47 * side, 2.56, 1.42 }, pale, "fabric", { 20, 0, 0 })
		end

		-- neck, collar, the end of a chain
		b:group("neck", { 0, 2.36, -1.3 }, function()
			b:bone("Neck", { 0, 2.38, -1.25 }, { 0, 2.3, -2.35 }, 0.6, 0.72, fur, "fabric")
			b:rod("Collar", { 0, 2.36, -1.62 }, { 0, 2.345, -1.8 }, 0.96, IRON, "metal")
			b:box("CollarStud", { 0.2, 0.2, 0.1 }, { 0, 1.9, -1.72 }, STEEL, "metal")
			b:group("chain", { 0, 1.86, -1.72 }, function()
				b:box("Link", { 0.2, 0.26, 0.07 }, { 0, 1.7, -1.72 }, STEEL, "metal")
				b:box("Link", { 0.07, 0.26, 0.2 }, { 0, 1.5, -1.72 }, STEEL, "metal")
				b:box("Link", { 0.2, 0.26, 0.07 }, { 0.03, 1.3, -1.72 }, STEEL, "metal", { 0, 0, 14 })
				b:box("LinkEnd", { 0.07, 0.2, 0.16 }, { 0.09, 1.12, -1.72 }, IRON, "metal", { 0, 0, 34 })
			end)

			b:group("head", { 0, 2.3, -2.3 }, function()
				b:box("Skull", { 0.76, 0.66, 0.8 }, { 0, 2.34, -2.62 }, fur, "fabric")
				b:box("Brow", { 0.8, 0.13, 0.34 }, { 0, 2.6, -2.92 }, dark, "fabric", { -16, 0, 0 })
				b:bone("Muzzle", { 0, 2.26, -2.9 }, { 0, 2.14, -3.82 }, 0.44, 0.4, muzzle, "fabric")
				b:box("Nose", { 0.26, 0.2, 0.16 }, { 0, 2.2, -3.86 }, SOOT, "plastic")
				b:bone("Teeth", { 0, 1.99, -3.0 }, { 0, 1.9, -3.72 }, 0.4, 0.1, BONE, "plastic")
				for _, side in { -1, 1 } do
					b:box("Fang", { 0.07, 0.24, 0.08 }, { 0.17 * side, 1.82, -3.7 }, BONE, "plastic")
					b:box("Eye", { 0.1, 0.13, 0.2 }, { 0.36 * side, 2.44, -2.9 }, eye, eyeMat)
				end
				b:face({ 0, 2.3, -3.0 }, 1.25)
				-- one ear up, one torn down to a stub
				for _, side in { -1, 1 } do
					local torn = (side == -1) == tornLeft
					b:group(if side == -1 then "earL" else "earR", { 0.27 * side, 2.62, -2.34 }, function()
						if torn then
							b:box("Ear", { 0.26, 0.26, 0.1 }, { 0.29 * side, 2.76, -2.34 }, dark, "fabric", { -12, 0, -14 * side })
							b:box("EarShred", { 0.09, 0.26, 0.08 }, { 0.4 * side, 2.94, -2.33 }, dark, "fabric", { -12, 0, -30 * side })
						else
							b:box("Ear", { 0.26, 0.52, 0.1 }, { 0.3 * side, 2.88, -2.34 }, dark, "fabric", { -12, 0, -14 * side })
							b:box("EarTip", { 0.14, 0.22, 0.09 }, { 0.36 * side, 3.18, -2.32 }, dark, "fabric", { -12, 0, -14 * side })
						end
					end)
				end
				b:group("jaw", { 0, 2.04, -2.78 }, function()
					b:bone("Jaw", { 0, 1.96, -2.8 }, { 0, 1.74, -3.62 }, 0.36, 0.15, muzzle, "fabric")
					for _, side in { -1, 1 } do
						b:box("Fang", { 0.06, 0.2, 0.07 }, { 0.13 * side, 1.87, -3.52 }, BONE, "plastic", { -14, 0, 0 })
					end
				end)
			end)
		end)

		-- a thin tail carried low
		b:group("tail", { 0, 2.42, 1.92 }, function()
			b:bone("Tail", { 0, 2.44, 1.9 }, { 0, 2.02, 2.8 }, 0.2, 0.2, fur, "fabric")
			b:group("tailTip", { 0, 2.02, 2.8 }, function()
				b:bone("Tail", { 0, 2.02, 2.78 }, { 0, 1.92, 3.62 }, 0.14, 0.14, dark, "fabric")
			end)
		end)

		-- long legs, mid-step
		local function foreleg(name: string, side: number, dz: number)
			local x = 0.42 * side
			b:group(name, { x, 2.3, -1.05 }, function()
				b:bone("UpperLeg", { x, 2.3, -1.02 }, { x, 1.34, -1.2 + dz * 0.4 }, 0.34, 0.5, fur, "fabric")
				b:bone("Foreleg", { x, 1.38, -1.2 + dz * 0.4 }, { x, 0.2, -1.08 + dz }, 0.2, 0.25, pale, "fabric")
				b:box("Paw", { 0.3, 0.2, 0.48 }, { x, 0.1, -1.2 + dz }, dark, "fabric")
			end)
		end
		local function hindleg(name: string, side: number, dz: number)
			local x = 0.44 * side
			b:group(name, { x, 2.28, 1.5 }, function()
				b:bone("Thigh", { x, 2.3, 1.5 }, { x, 1.42, 1.22 + dz * 0.3 }, 0.38, 0.66, fur, "fabric")
				b:bone("Shank", { x, 1.46, 1.2 + dz * 0.3 }, { x, 0.78, 1.8 + dz * 0.7 }, 0.22, 0.3, pale, "fabric")
				b:bone("Hock", { x, 0.8, 1.8 + dz * 0.7 }, { x, 0.18, 1.62 + dz }, 0.18, 0.22, pale, "fabric")
				b:box("Paw", { 0.3, 0.2, 0.48 }, { x, 0.1, 1.5 + dz }, dark, "fabric")
			end)
		end
		foreleg("legFL", -1, -0.34)
		foreleg("legFR", 1, 0.22)
		hindleg("legHL", -1, 0.3)
		hindleg("legHR", 1, -0.22)
	end)
	b.angle = 52
	b.height = 3.0

	-- idle: breathing, a slow tail, an ear that won't keep still
	b:bob("chest", 0.03, 0.42)
	b:swing("neck", { 0, 1, 0 }, 4, 0.16)
	b:swing("head", { 1, 0, 0 }, 2.5, 0.42, 0.2)
	b:swing("jaw", { 1, 0, 0 }, 3, 0.84, 0.1)
	b:swing("chain", { 0, 0, 1 }, 9, 0.5)
	b:swing("tail", { 0, 1, 0 }, 9, 0.3)
	b:swing("tailTip", { 0, 1, 0 }, 12, 0.3, 0.8)
	b:twitch(if tornLeft then "earR" else "earL", { 1, 0, 0 }, 16, 0.22)

	if ctx.pose == "strike" then
		-- a lunge: forelegs thrown out, hind legs driving, jaws wide
		b:shift("root", 0, 0.3, -0.75)
		b:turn("root", 13)
		b:turn("legFL", 58)
		b:turn("legFR", 42)
		b:turn("legHL", -38)
		b:turn("legHR", -26)
		b:turn("neck", -6)
		b:turn("head", 12)
		b:turn("jaw", -30)
		b:turn("earL", 28)
		b:turn("earR", 28)
		b:turn("tail", -22)
		b:turn("tailTip", -8)
	elseif ctx.pose == "hurt" then
		-- knocked back onto its haunches, head turned away
		b:shift("root", 0, -0.12, 0.55)
		b:turn("root", -7, 0, 5)
		b:turn("legFL", 26)
		b:turn("legFR", 20)
		b:turn("legHL", 20)
		b:turn("legHR", 26)
		b:turn("neck", 10, -24)
		b:turn("head", -18, -14, 10)
		b:turn("jaw", -9)
		b:turn("earL", 34)
		b:turn("earR", 34)
		b:turn("tail", 52)
		b:turn("tailTip", 26)
	elseif ctx.pose == "down" then
		-- on its side, legs out, done
		b:turn("root", 0, 0, 86)
		b:shift("root", 1.55, -0.72, 0)
		b:turn("legFL", 22, 0, 10)
		b:turn("legFR", -16, 0, -6)
		b:turn("legHL", -14, 0, 10)
		b:turn("legHR", 24, 0, -6)
		b:turn("neck", 0, 0, -8)
		b:turn("head", -8, 14)
		b:turn("jaw", -5)
		b:turn("tail", 20, 12)
	end
end)

-- bird: carrion crows. One the size of a dog up front, hunched over something, and two more
-- behind it, waiting their turn.
register("bird", { color = { 24, 24, 30 }, eye = { 220, 60, 60 } }, nil, function(b, ctx)
	-- crows are black, and black on a dark stage is nothing at all: the feathers carry a blue
	-- sheen and a paler edge so the shape reads
	local black = mix(ctx.body, { 58, 62, 84 }, 0.45)
	local sheen = mix(ctx.body, { 96, 108, 160 }, 0.6)
	local dull = mix(ctx.body, { 40, 42, 56 }, 0.5)
	local horn = { 96, 90, 84 }
	local eye, eyeMat = b:lit(ctx.eye)

	local function crow(p: string)
		b:group(p .. "body", { 0, 1.5, 0.1 }, function()
			b:bone("Body", { 0, 1.72, -0.55 }, { 0, 1.28, 0.8 }, 1.08, 1.04, black, "fabric")
			b:ball("Breast", 1.08, { 0, 1.64, -0.58 }, black, "fabric")
			b:ball("Rump", 0.82, { 0, 1.3, 0.76 }, dull, "fabric")
			b:group(p .. "tail", { 0, 1.24, 0.9 }, function()
				for i = -1, 1 do
					b:bone("TailFeather", { 0.14 * i, 1.24, 0.86 }, { 0.36 * i, 0.84, 2.05 }, 0.32, 0.06, if i == 0 then black else sheen, "fabric")
				end
			end)
			for _, side in { -1, 1 } do
				b:group(p .. (if side < 0 then "wingL" else "wingR"), { 0.54 * side, 1.92, -0.4 }, function()
					b:bone("Wing", { 0.6 * side, 1.94, -0.52 }, { 0.62 * side, 1.34, 0.92 }, 0.12, 0.9, sheen, "fabric")
					b:bone("Covert", { 0.67 * side, 2.0, -0.56 }, { 0.69 * side, 1.68, 0.3 }, 0.1, 0.52, black, "fabric")
					b:bone("Primary", { 0.64 * side, 1.5, 0.3 }, { 0.58 * side, 0.96, 1.56 }, 0.08, 0.52, black, "fabric")
					b:bone("Primary", { 0.66 * side, 1.42, 0.36 }, { 0.62 * side, 0.82, 1.3 }, 0.06, 0.3, dull, "fabric")
				end)
			end
			b:group(p .. "neck", { 0, 1.95, -0.75 }, function()
				b:bone("Neck", { 0, 1.9, -0.7 }, { 0, 2.44, -1.08 }, 0.64, 0.66, black, "fabric")
				for i = -1, 1 do
					b:bone("Hackle", { 0.16 * i, 2.2, -1.12 }, { 0.2 * i, 1.84, -1.26 }, 0.14, 0.08, sheen, "fabric")
				end
				b:group(p .. "head", { 0, 2.46, -1.1 }, function()
					b:ball("Head", 0.8, { 0, 2.56, -1.18 }, black, "fabric")
					b:bone("Brow", { -0.3, 2.78, -1.4 }, { 0.3, 2.78, -1.4 }, 0.12, 0.3, dull, "fabric")
					b:bone("BeakTop", { 0, 2.58, -1.42 }, { 0, 2.36, -2.22 }, 0.26, 0.22, horn, "plastic")
					b:bone("BeakHook", { 0, 2.38, -2.16 }, { 0, 2.2, -2.36 }, 0.15, 0.13, horn, "plastic")
					b:group(p .. "jaw", { 0, 2.44, -1.44 }, function()
						b:bone("BeakLow", { 0, 2.42, -1.44 }, { 0, 2.26, -2.1 }, 0.19, 0.1, shade(horn, 0.75), "plastic")
					end)
					for _, side in { -1, 1 } do
						b:ball("Eye", 0.15, { 0.31 * side, 2.64, -1.38 }, eye, eyeMat)
					end
				end)
			end)
			for _, side in { -1, 1 } do
				b:group(p .. (if side < 0 then "legL" else "legR"), { 0.26 * side, 1.02, 0.14 }, function()
					b:bone("Thigh", { 0.26 * side, 1.24, 0.2 }, { 0.26 * side, 0.84, 0.12 }, 0.3, 0.34, dull, "fabric")
					b:rod("Shank", { 0.26 * side, 0.86, 0.12 }, { 0.26 * side, 0.08, 0.0 }, 0.1, horn, "plastic")
					for t = -1, 1 do
						b:bone("Toe", { 0.26 * side, 0.05, 0.0 }, { 0.26 * side + 0.18 * t, 0.04, -0.46 }, 0.07, 0.07, horn, "plastic")
					end
					b:bone("Toe", { 0.26 * side, 0.05, 0.0 }, { 0.26 * side, 0.04, 0.3 }, 0.07, 0.07, horn, "plastic")
				end)
			end
		end)
	end

	b:group("root", { 0, 1.2, 0 }, function()
		-- the big one is the size of a dog
		b:place({ 0, 0, 0 }, 0, 1.5, function()
			crow("a")
		end)
		b:face({ 0, 3.84, -2.2 }, 1.8)
		b:place({ -2.2, 0, 1.3 }, 26, 0.86, function()
			crow("b")
		end)
		b:place({ 2.1, 0, 1.6 }, -34, 0.74, function()
			crow("c")
		end)
		-- what they're standing around: a boot
		b:box("Boot", { 0.6, 0.4, 1.06 }, { 0.9, 0.2, -3.0 }, { 92, 70, 54 }, "fabric", { 0, 30, 0 })
	end)
	b.angle = 40
	b.height = 4.4

	b:swing("ahead", { 0, 1, 0 }, 14, 0.18)
	b:twitch("ahead", { 1, 0, 0 }, 12, 0.3, 0.4)
	b:twitch("bhead", { 0, 1, 0 }, 26, 0.24, 0.1)
	b:twitch("chead", { 0, 1, 0 }, -22, 0.2, 0.6)
	b:swing("atail", { 1, 0, 0 }, 5, 0.4)
	b:bob("abody", 0.03, 0.5)

	if ctx.pose == "strike" then
		-- wings thrown open, head down and forward, beak wide
		b:shift("root", 0, 0.45, -0.8)
		b:turn("abody", 18)
		b:turn("awingL", 0, 0, -74)
		b:turn("awingR", 0, 0, 74)
		b:turn("aneck", 14)
		b:turn("ajaw", -28)
		b:turn("bwingL", 0, 0, -50)
		b:turn("bwingR", 0, 0, 50)
	elseif ctx.pose == "hurt" then
		b:shift("root", 0, 0.2, 0.6)
		b:turn("abody", -16, 0, 10)
		b:turn("awingL", 0, 0, -40)
		b:turn("awingR", 0, 0, 58)
		b:turn("aneck", -20, 26)
		b:turn("ajaw", -14)
	elseif ctx.pose == "down" then
		b:turn("abody", 0, 0, 82)
		b:turn("awingL", 0, 0, -30)
		b:turn("awingR", 0, 0, 70)
		b:turn("aneck", 0, 0, -20)
		-- the others have left
		b:shift("bbody", -6, 0, 6)
		b:shift("cbody", 6, 0, 6)
	end
end)

-- tall: a Sweeper. Too tall, coat to the knee, one long red visor, a tank of something on its
-- back, and a pole with a crescent on the end for what it does at 3:13.
register("tall", { color = { 34, 34, 40 }, eye = { 236, 70, 52 } }, nil, function(b, ctx)
	local coat = ctx.body
	local dark = shade(coat, 0.6)
	local rubber = mix(coat, { 78, 82, 94 }, 0.5)
	local eye, eyeMat = b:lit(ctx.eye)

	b:group("root", { 0, 3.2, 0 }, function()
		for _, side in { -1, 1 } do
			b:group(if side < 0 then "legL" else "legR", { 0.34 * side, 3.1, 0 }, function()
				b:bone("Thigh", { 0.34 * side, 3.1, 0 }, { 0.38 * side, 1.6, -0.14 * side }, 0.38, 0.42, dark, "fabric")
				b:bone("Shin", { 0.38 * side, 1.62, -0.14 * side }, { 0.36 * side, 0.3, 0.06 }, 0.3, 0.34, dark, "fabric")
				b:box("Boot", { 0.46, 0.3, 0.84 }, { 0.36 * side, 0.15, -0.12 }, rubber, "plastic")
			end)
		end
		b:group("torso", { 0, 3.2, 0 }, function()
			b:bone("Skirt", { 0, 1.9, 0.04 }, { 0, 3.4, 0.04 }, 1.36, 0.84, coat, "fabric")
			b:box("Hem", { 1.42, 0.12, 0.9 }, { 0, 1.92, 0.04 }, rubber, "plastic")
			b:bone("Chest", { 0, 3.3, 0 }, { 0, 5.0, -0.12 }, 1.2, 0.74, coat, "fabric")
			b:box("Belt", { 1.28, 0.18, 0.82 }, { 0, 3.42, 0 }, rubber, "plastic")
			b:box("Buckle", { 0.3, 0.24, 0.06 }, { 0, 3.42, -0.43 }, STEEL, "metal")
			b:box("Shoulders", { 1.74, 0.36, 0.86 }, { 0, 5.0, -0.1 }, coat, "fabric")
			for i = 0, 3 do
				b:box("Button", { 0.12, 0.12, 0.05 }, { 0.22, 3.8 + i * 0.3, -0.42 - i * 0.02 }, STEEL, "metal")
			end
			b:cyl("Tank", 0.64, 1.5, { 0, 4.1, 0.64 }, IRON, "metal")
			b:cyl("TankCap", 0.42, 0.16, { 0, 4.93, 0.64 }, STEEL, "metal")
			b:cyl("TankBand", 0.68, 0.1, { 0, 3.8, 0.64 }, BRASS, "metal")
			b:rod("Hose", { 0.3, 4.7, 0.64 }, { 0.66, 5.14, 0.1 }, 0.12, rubber, "plastic")
			b:group("head", { 0, 5.2, -0.1 }, function()
				b:bone("Neck", { 0, 5.1, -0.1 }, { 0, 5.42, -0.14 }, 0.42, 0.42, dark, "fabric")
				b:box("Hood", { 0.94, 1.02, 0.98 }, { 0, 5.88, -0.1 }, coat, "fabric")
				b:box("HoodPeak", { 0.98, 0.2, 0.54 }, { 0, 6.32, -0.44 }, coat, "fabric", { -18, 0, 0 })
				b:box("Mask", { 0.76, 0.72, 0.12 }, { 0, 5.8, -0.6 }, SOOT, "plastic")
				b:box("Visor", { 0.64, 0.13, 0.08 }, { 0, 5.92, -0.67 }, eye, eyeMat)
				b:cyl("Filter", 0.28, 0.26, { 0, 5.56, -0.72 }, IRON, "metal", { 90, 0, 0 })
				b:face({ 0, 5.84, -0.62 }, 1.3)
			end)
			b:group("armL", { -0.88, 4.96, -0.08 }, function()
				b:bone("UpperArm", { -0.88, 4.9, -0.08 }, { -1.02, 3.5, -0.2 }, 0.36, 0.4, coat, "fabric")
				b:bone("Forearm", { -1.02, 3.52, -0.2 }, { -0.98, 2.2, -0.5 }, 0.28, 0.32, coat, "fabric")
				b:box("Glove", { 0.36, 0.42, 0.36 }, { -0.98, 2.04, -0.54 }, rubber, "plastic")
				b:bone("HookShaft", { -0.98, 2.0, -0.56 }, { -0.98, 1.0, -0.8 }, 0.1, 0.18, STEEL, "metal")
				b:bone("Hook", { -0.98, 1.02, -0.8 }, { -0.98, 1.2, -1.3 }, 0.1, 0.18, STEEL, "metal")
			end)
			b:group("armR", { 0.88, 4.96, -0.08 }, function()
				b:bone("UpperArm", { 0.88, 4.9, -0.08 }, { 1.04, 3.7, -0.5 }, 0.36, 0.4, coat, "fabric")
				b:bone("Forearm", { 1.04, 3.72, -0.5 }, { 0.94, 3.2, -1.3 }, 0.28, 0.32, coat, "fabric")
				b:box("Glove", { 0.36, 0.36, 0.42 }, { 0.94, 3.18, -1.4 }, rubber, "plastic")
				b:rod("Pole", { 0.94, 0.3, -1.1 }, { 0.94, 6.3, -1.72 }, 0.13, IRON, "metal")
				b:bone("Crescent", { 0.94, 6.2, -1.7 }, { 0.94, 6.72, -2.4 }, 0.08, 0.36, STEEL, "metal")
				b:bone("CrescentTip", { 0.94, 6.7, -2.38 }, { 0.94, 6.4, -2.94 }, 0.08, 0.26, STEEL, "metal")
			end)
		end)
	end)
	b.angle = 30
	b.height = 6.8

	b:swing("torso", { 0, 0, 1 }, 1.4, 0.2)
	b:swing("head", { 0, 1, 0 }, 10, 0.11)
	b:glow("head", "flicker", 0.6)
	b:swing("armL", { 1, 0, 0 }, 3, 0.24, 0.3)

	if ctx.pose == "strike" then
		b:shift("root", 0, 0, -0.5)
		b:turn("torso", 16)
		b:turn("armR", 44)
		b:turn("armL", 30)
		b:turn("head", 8)
	elseif ctx.pose == "hurt" then
		b:shift("root", 0, 0, 0.5)
		b:turn("torso", -14, 0, 6)
		b:turn("head", -16, 20)
		b:turn("armR", -22)
	elseif ctx.pose == "down" then
		b:turn("root", -86)
		b:turn("armR", -40, 0, 30)
		b:turn("armL", -20, 0, -24)
		b:turn("head", 0, 30)
	end
end)

-- mass: a Distortion. It was a person in an apron. One arm kept growing. Where the face was
-- there's a porcelain mask, cracked, with light behind the crack.
register("mass", { color = { 120, 34, 52 }, eye = { 250, 210, 90 } }, nil, function(b, ctx)
	local flesh = ctx.body
	local dark = shade(flesh, 0.55)
	local pale = { 226, 220, 206 }
	local cloth = { 196, 186, 168 }
	local eye, eyeMat = b:lit(ctx.eye)

	b:group("root", { 0, 2.0, 0.2 }, function()
		for _, side in { -1, 1 } do
			b:bone("Leg", { 0.6 * side, 1.5, 0.3 }, { 0.72 * side, 0.2, 0.1 }, 0.62, 0.68, dark, "fabric")
			b:box("Foot", { 0.72, 0.3, 1.04 }, { 0.72 * side, 0.15, -0.12 }, dark, "fabric")
		end
		b:group("body", { 0, 1.8, 0.3 }, function()
			b:ball("Belly", 2.5, { 0, 2.2, 0.4 }, flesh, "fabric")
			b:ball("Hump", 2.3, { 0.2, 3.5, 0.5 }, flesh, "fabric")
			b:ball("Shoulder", 1.7, { -1.3, 3.4, -0.1 }, flesh, "fabric")
			b:ball("Growth", 0.9, { 1.1, 2.6, 0.9 }, dark, "fabric")
			b:box("Apron", { 1.5, 1.9, 0.1 }, { 0.1, 1.9, -0.92 }, cloth, "fabric", { 8, 0, 3 })
			b:box("ApronBib", { 0.9, 0.8, 0.1 }, { 0.1, 3.0, -0.98 }, cloth, "fabric", { 14, 0, 3 })
			b:bone("ApronString", { -1.1, 2.9, -0.4 }, { 1.2, 2.8, -0.4 }, 0.08, 0.08, shade(cloth, 0.8), "fabric")
			b:box("Stain", { 0.5, 0.6, 0.04 }, { -0.2, 1.7, -1.0 }, dark, "fabric", { 8, 0, 20 })
			for i = 0, 4 do
				local off = math.abs(i - 2)
				b:bone("Spine", { -0.6 + i * 0.35, 4.3 - off * 0.15, 0.6 }, { -0.9 + i * 0.5, 5.3 - off * 0.3, 1.0 }, 0.16, 0.16, pale, "plastic")
			end
			b:group("head", { 0.1, 3.6, -0.7 }, function()
				b:box("Mask", { 0.92, 1.14, 0.14 }, { 0.1, 3.5, -0.98 }, pale, "plastic", { 10, 0, -6 })
				b:box("Slit", { 0.24, 0.07, 0.05 }, { -0.14, 3.7, -1.07 }, SOOT, "plastic", { 10, 0, -6 })
				b:box("Mouth", { 0.3, 0.05, 0.05 }, { 0.06, 3.18, -1.02 }, SOOT, "plastic", { 10, 0, -14 })
				b:bone("Crack", { 0.34, 4.0, -1.1 }, { 0.08, 3.34, -1.1 }, 0.07, 0.05, eye, eyeMat)
				b:bone("Crack", { 0.08, 3.36, -1.1 }, { 0.3, 3.0, -1.06 }, 0.06, 0.05, eye, eyeMat)
				b:bone("Crack", { 0.2, 3.66, -1.1 }, { 0.44, 3.6, -1.08 }, 0.05, 0.05, eye, eyeMat)
				b:face({ 0.1, 3.5, -1.0 }, 1.5)
			end)
			b:group("armBig", { -1.5, 3.4, -0.2 }, function()
				b:bone("Upper", { -1.5, 3.5, -0.2 }, { -2.3, 2.2, -0.9 }, 1.1, 1.1, flesh, "fabric")
				b:ball("Elbow", 1.25, { -2.3, 2.2, -0.9 }, dark, "fabric")
				b:bone("Fore", { -2.3, 2.2, -0.9 }, { -2.0, 0.8, -1.9 }, 1.0, 1.0, flesh, "fabric")
				b:box("Hand", { 1.1, 0.5, 1.0 }, { -2.0, 0.5, -2.1 }, dark, "fabric")
				for i = -1, 1 do
					b:bone("Claw", { -2.0 + 0.36 * i, 0.5, -2.5 }, { -2.0 + 0.46 * i, 0.12, -3.2 }, 0.17, 0.2, pale, "plastic")
				end
			end)
			b:group("armSmall", { 1.2, 3.2, -0.3 }, function()
				b:bone("Upper", { 1.2, 3.2, -0.3 }, { 1.6, 2.4, -0.8 }, 0.34, 0.36, flesh, "fabric")
				b:bone("Fore", { 1.6, 2.4, -0.8 }, { 1.4, 2.6, -1.6 }, 0.28, 0.3, flesh, "fabric")
				b:box("Hand", { 0.3, 0.14, 0.36 }, { 1.4, 2.62, -1.76 }, pale, "plastic")
			end)
		end)
	end)
	b.angle = 34
	b.height = 5.6

	b:bob("body", 0.05, 0.3)
	b:swing("armBig", { 1, 0, 0 }, 3, 0.2)
	b:twitch("armSmall", { 1, 0, 0 }, 10, 0.3, 0.5)
	b:swing("head", { 0, 0, 1 }, 5, 0.15)
	b:glow("head", "pulse", 0.4)

	if ctx.pose == "strike" then
		b:shift("root", 0, 0.1, -0.7)
		b:turn("body", 14)
		b:turn("armBig", -64)
	elseif ctx.pose == "hurt" then
		b:shift("root", 0, 0, 0.6)
		b:turn("body", -12, 0, 8)
		b:turn("head", 0, 24, 14)
		b:turn("armSmall", -40)
	elseif ctx.pose == "down" then
		b:turn("root", 0, 0, -80)
		b:turn("armBig", 30)
	end
end)

-- blob: an Abnormality. A soft bell that hangs in the air with more eyes than it needs, a ring
-- over it, and arms with one joint too many. Nothing about it is angry. That's the worst part.
register("blob", { color = { 60, 70, 110 }, eye = { 230, 230, 255 } }, nil, function(b, ctx)
	local skin = ctx.body
	local deep = shade(skin, 0.6)
	local rng = ctx.rng
	local eye, eyeMat = b:lit(ctx.eye)

	b:group("root", { 0, 2.6, 0 }, function()
		b:group("body", { 0, 2.6, 0 }, function()
			b:ball("Bell", 2.6, { 0, 3.4, 0 }, skin, "plastic")
			b:ball("Belly", 2.1, { 0, 2.5, 0 }, skin, "plastic")
			b:ball("Lower", 1.5, { 0, 1.8, 0 }, deep, "plastic")
			b:ball("Tip", 0.9, { 0, 1.25, 0 }, deep, "plastic")
			b:ball("Drip", 0.42, { 0, 0.82, 0 }, deep, "plastic")
			b:ball("Drip", 0.22, { 0, 0.5, 0 }, deep, "plastic")
			local spots = {
				{ 0, 3.6, -1.26, 0.56 }, { -0.62, 3.1, -1.1, 0.32 }, { 0.64, 3.3, -1.08, 0.36 }, { -0.3, 2.5, -1.0, 0.28 },
				{ 0.42, 2.3, -0.96, 0.24 }, { 0.92, 3.8, -0.78, 0.22 }, { -0.96, 3.7, -0.72, 0.26 }, { 0.1, 1.9, -0.7, 0.2 },
			}
			for i, s in spots do
				b:group("eye" .. i, { s[1], s[2], s[3] }, function()
					b:ball("EyeWhite", s[4], { s[1], s[2], s[3] }, eye, eyeMat)
					b:ball("Pupil", s[4] * 0.46, { s[1], s[2], s[3] - s[4] * 0.36 }, SOOT, "plastic")
				end)
				b:glow("eye" .. i, "blink", 0.1 + rng.range(0, 0.22), rng.range(0, 1))
			end
			b:face({ 0, 3.4, -1.2 }, 2.0)
			b:group("halo", { 0, 5.25, 0 }, function()
				for i = 0, 11 do
					local a = i * math.pi / 6
					local a2 = (i + 1) * math.pi / 6
					b:rod("Halo", { math.cos(a) * 0.95, 5.25, math.sin(a) * 0.95 }, { math.cos(a2) * 0.95, 5.25, math.sin(a2) * 0.95 }, 0.11, eye, eyeMat, 0.06)
				end
			end)
			for _, side in { -1, 1 } do
				b:group(if side < 0 then "armL" else "armR", { 1.2 * side, 3.2, 0 }, function()
					b:bone("Arm", { 1.2 * side, 3.2, 0 }, { 1.72 * side, 2.3, -0.2 }, 0.2, 0.2, deep, "plastic")
					b:bone("Arm", { 1.72 * side, 2.3, -0.2 }, { 1.5 * side, 1.4, -0.4 }, 0.17, 0.17, deep, "plastic")
					b:bone("Arm", { 1.5 * side, 1.4, -0.4 }, { 1.78 * side, 0.6, -0.5 }, 0.14, 0.14, deep, "plastic")
					for f = -1, 1 do
						b:bone("Finger", { 1.78 * side, 0.6, -0.5 }, { 1.78 * side + 0.14 * f, 0.18, -0.58 + 0.06 * f }, 0.06, 0.06, deep, "plastic")
					end
				end)
			end
		end)
	end)
	b.angle = 26
	b.height = 5.6

	b:bob("body", 0.14, 0.22)
	b:swing("halo", { 1, 0, 0 }, 7, 0.16)
	b:spin("halo", { 0, 1, 0 }, 0.08)
	b:swing("armL", { 0, 0, 1 }, 6, 0.2)
	b:swing("armR", { 0, 0, 1 }, 6, 0.2, 0.5)

	if ctx.pose == "strike" then
		b:shift("root", 0, 0.3, -0.8)
		b:turn("body", 10)
		b:turn("armL", -70)
		b:turn("armR", -70)
	elseif ctx.pose == "hurt" then
		b:shift("root", 0, -0.2, 0.6)
		b:turn("body", -10, 0, 10)
		b:turn("halo", 0, 0, 26)
	elseif ctx.pose == "down" then
		b:shift("root", 0, -1.6, 0)
		b:turn("body", 0, 0, 30)
		b:turn("halo", 0, 0, 70)
		b:shift("halo", 1.2, -3.4, 0)
		b:turn("armL", 0, 0, -50)
		b:turn("armR", 0, 0, 50)
	end
end)

-- machine: an Ordeal's small machine. A painted drum on four spider legs, one lamp, one saw.
register("machine", { color = { 64, 120, 70 }, eye = { 170, 255, 120 } }, nil, function(b, ctx)
	local paint = ctx.body
	local worn = mix(paint, IRON, 0.5)
	local eye, eyeMat = b:lit(ctx.eye)

	b:group("root", { 0, 1.6, 0 }, function()
		b:group("body", { 0, 1.7, 0 }, function()
			b:cyl("Drum", 1.9, 1.3, { 0, 1.9, 0 }, paint, "metal")
			b:cyl("Rim", 2.06, 0.18, { 0, 1.3, 0 }, IRON, "metal")
			b:cyl("Rim", 2.06, 0.18, { 0, 2.5, 0 }, IRON, "metal")
			b:ball("Dome", 1.5, { 0, 2.55, 0 }, worn, "metal")
			b:disc("LampRing", { 0, 2.0, -0.96 }, { 0, 0, 1 }, 0.92, 0.12, IRON, "metal")
			b:group("lamp", { 0, 2.0, -1.0 }, function()
				b:disc("Lamp", { 0, 2.0, -1.03 }, { 0, 0, 1 }, 0.68, 0.1, eye, eyeMat)
			end)
			b:face({ 0, 2.0, -1.0 }, 1.6)
			b:rod("Antenna", { 0.4, 3.2, 0.2 }, { 0.62, 4.3, 0.3 }, 0.06, STEEL, "metal")
			b:group("tip", { 0.62, 4.3, 0.3 }, function()
				b:ball("AntennaTip", 0.17, { 0.62, 4.3, 0.3 }, eye, eyeMat)
			end)
			b:box("Plate", { 0.6, 0.34, 0.06 }, { -0.56, 1.6, -0.82 }, BRASS, "metal", { 0, 32, 0 })
			for i = 0, 5 do
				local a = i * math.pi / 3 + 0.5
				b:ball("Rivet", 0.12, { math.cos(a) * 0.98, 2.5, math.sin(a) * 0.98 }, STEEL, "metal")
			end
			b:group("arm", { 1.0, 2.1, -0.2 }, function()
				b:bone("ArmA", { 1.0, 2.1, -0.2 }, { 1.7, 2.7, -0.8 }, 0.26, 0.3, worn, "metal")
				b:ball("Joint", 0.36, { 1.7, 2.7, -0.8 }, IRON, "metal")
				b:bone("ArmB", { 1.7, 2.7, -0.8 }, { 1.6, 2.0, -1.8 }, 0.22, 0.26, worn, "metal")
				b:group("saw", { 1.6, 2.0, -1.9 }, function()
					b:disc("Saw", { 1.6, 2.0, -1.9 }, { 1, 0, 0 }, 1.3, 0.06, STEEL, "metal")
					for i = 0, 7 do
						local a = i * math.pi / 4
						b:box("Tooth", { 0.07, 0.2, 0.2 }, { 1.6, 2.0 + math.sin(a) * 0.7, -1.9 + math.cos(a) * 0.7 }, STEEL, "metal", { -math.deg(a) + 45, 0, 0 })
					end
					b:disc("Hub", { 1.6, 2.0, -1.9 }, { 1, 0, 0 }, 0.32, 0.12, IRON, "metal")
				end)
			end)
		end)
		for i, l in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
			local sx, sz = l[1], l[2]
			b:group("leg" .. i, { 0.8 * sx, 1.5, 0.7 * sz }, function()
				b:bone("LegA", { 0.8 * sx, 1.5, 0.7 * sz }, { 1.7 * sx, 2.3, 1.4 * sz }, 0.2, 0.22, IRON, "metal")
				b:ball("Knee", 0.32, { 1.7 * sx, 2.3, 1.4 * sz }, worn, "metal")
				b:bone("LegB", { 1.7 * sx, 2.3, 1.4 * sz }, { 2.2 * sx, 0.06, 1.9 * sz }, 0.14, 0.16, STEEL, "metal")
			end)
		end
	end)
	b.angle = 40
	b.height = 4.4

	b:spin("saw", { 1, 0, 0 }, 1.6)
	b:glow("lamp", "flicker", 0.5)
	b:glow("tip", "blink", 0.8)
	b:bob("body", 0.05, 0.6)
	for i = 1, 4 do
		b:twitch("leg" .. i, { 0, 1, 0 }, 6, 0.2, i * 0.23)
	end

	if ctx.pose == "strike" then
		b:shift("root", 0, 0.2, -0.8)
		b:turn("body", 14)
		b:turn("arm", 38)
	elseif ctx.pose == "hurt" then
		b:shift("root", 0, 0, 0.6)
		b:turn("body", -16, 0, 12)
		b:turn("arm", -40)
	elseif ctx.pose == "down" then
		b:turn("body", 0, 0, 100)
		b:shift("body", 0.6, -0.9, 0)
		for i = 1, 4 do
			b:turn("leg" .. i, 0, 0, if i % 2 == 1 then 50 else -50)
		end
	end
end)

-- swarm: Peccatula. Five of them, spined shells with one eye each, and they don't come alone.
register("swarm", { color = { 90, 60, 40 }, eye = { 255, 160, 60 } }, nil, function(b, ctx)
	local shell = ctx.body
	local dark = shade(shell, 0.55)
	local eye, eyeMat = b:lit(ctx.eye)

	local function crawler(tag: string, spikes: number)
		b:group(tag, { 0, 0.5, 0 }, function()
			b:ball("Shell", 1.2, { 0, 0.7, 0.1 }, shell, "plastic")
			b:ball("ShellBack", 0.9, { 0, 0.62, 0.6 }, dark, "plastic")
			b:ball("Head", 0.7, { 0, 0.6, -0.6 }, dark, "plastic")
			b:ball("Eye", 0.36, { 0, 0.68, -0.9 }, eye, eyeMat)
			b:ball("Pupil", 0.14, { 0, 0.68, -1.06 }, SOOT, "plastic")
			for i = 1, spikes do
				local a = (i / spikes) * math.pi * 2
				b:bone("Spike", { math.cos(a) * 0.38, 1.1, 0.1 + math.sin(a) * 0.38 }, { math.cos(a) * 0.82, 1.72, 0.1 + math.sin(a) * 0.82 }, 0.14, 0.14, BONE, "plastic")
			end
			b:bone("Spike", { 0, 1.2, 0.1 }, { 0, 2.0, 0.2 }, 0.16, 0.16, BONE, "plastic")
			for _, side in { -1, 1 } do
				for j = -1, 1 do
					b:bone("Leg", { 0.5 * side, 0.5, 0.1 + j * 0.34 }, { 0.96 * side, 0.03, 0.1 + j * 0.52 }, 0.08, 0.08, dark, "plastic")
				end
				b:bone("Mandible", { 0.16 * side, 0.44, -0.84 }, { 0.08 * side, 0.3, -1.14 }, 0.07, 0.07, BONE, "plastic")
			end
		end)
	end

	local spots = { { 0, -0.9, 1.25, 0 }, { -1.7, 0.2, 0.9, 20 }, { 1.6, 0.0, 1.0, -16 }, { -0.7, 1.5, 0.75, 8 }, { 0.9, 1.6, 0.8, -24 } }
	b:group("root", { 0, 0.5, 0 }, function()
		for i, s in spots do
			b:place({ s[1], 0, s[2] }, s[4], s[3], function()
				crawler("c" .. i, 5 + (i % 2))
			end)
		end
		b:face({ 0, 0.85, -2.0 }, 1.5)
	end)
	b.angle = 36
	b.height = 2.5
	for i = 1, #spots do
		b:bob("c" .. i, 0.05, 0.9 + i * 0.13, i * 0.21)
		b:twitch("c" .. i, { 0, 1, 0 }, 10, 0.3, i * 0.17)
	end

	if ctx.pose == "strike" then
		b:shift("root", 0, 0, -0.9)
		b:shift("c1", 0, 0.7, -0.4)
		b:turn("c1", -24)
		b:shift("c2", 0, 0.3, -0.3)
		b:shift("c3", 0, 0.4, -0.3)
	elseif ctx.pose == "hurt" then
		b:shift("root", 0, 0, 0.6)
		b:turn("c1", 0, 0, 40)
		b:shift("c1", 0, 0.4, 0)
		b:turn("c3", 0, 60)
	elseif ctx.pose == "down" then
		for i = 1, #spots do
			b:turn("c" .. i, 0, i * 40, if i % 2 == 0 then 170 else -170)
			b:shift("c" .. i, 0, 0.5, 0)
		end
	end
end)

-- ════ v0.10: more of what lives in the City. All original designs, by category. ════

-- CRAB: a low armored shell, two heavy claws, eye stalks (the Great Lake's trash crabs)
register("crab", { color = { 122, 84, 62 }, eye = { 250, 220, 90 } }, nil, function(b, ctx)
	local shell, dark = ctx.body, shade(ctx.body, 0.6)
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 1.2, 0 }, function()
		b:group("body", { 0, 1.2, 0 }, function()
			b:box("Shell", { 3.4, 1.0, 2.4 }, { 0, 1.5, 0 }, shell, "metal", { -6, 0, 0 })
			b:box("ShellTop", { 2.6, 0.5, 1.8 }, { 0, 2.1, 0.1 }, shade(shell, 1.15), "metal", { -6, 0, 0 })
			b:box("Belly", { 2.8, 0.5, 2.0 }, { 0, 0.95, 0 }, dark, "plastic")
			for i = -2, 2 do
				b:box("Barnacle", { 0.34, 0.3, 0.34 }, { i * 0.6, 2.42, 0.2 + (i % 2) * 0.3 }, BONE, "plastic")
			end
			for _, side in { -1, 1 } do
				b:rod("Stalk", { 0.5 * side, 1.9, -1.0 }, { 0.6 * side, 2.7, -1.3 }, 0.12, dark, "plastic")
				b:ball("Eye", 0.36, { 0.6 * side, 2.8, -1.32 }, eye, eyeMat)
				for j = 0, 2 do
					b:group("leg" .. side .. j, { 1.6 * side, 1.3, -0.5 + j * 0.7 }, function()
						b:bone("Leg", { 1.6 * side, 1.3, -0.5 + j * 0.7 }, { 2.5 * side, 1.7, -0.6 + j * 0.8 }, 0.2, 0.2, dark, "metal")
						b:bone("Leg", { 2.5 * side, 1.7, -0.6 + j * 0.8 }, { 2.9 * side, 0.05, -0.7 + j * 0.9 }, 0.16, 0.16, dark, "metal")
					end)
					b:swing("leg" .. side .. j, { 0, 0, 1 }, 5, 0.9, j * 0.33)
				end
			end
			for _, side in { -1, 1 } do
				b:group(if side < 0 then "clawL" else "clawR", { 1.3 * side, 1.4, -1.0 }, function()
					b:bone("Arm", { 1.3 * side, 1.4, -1.0 }, { 2.0 * side, 1.7, -2.0 }, 0.4, 0.4, shell, "metal")
					b:box("Claw", { 1.0, 0.7, 1.3 }, { 2.1 * side, 1.9, -2.8 }, shell, "metal", { -10, 0, 0 })
					b:box("Pincer", { 0.5, 0.3, 1.1 }, { 2.1 * side, 2.4, -3.0 }, shade(shell, 1.2), "metal", { -24, 0, 0 })
					b:box("Pincer", { 0.5, 0.26, 1.0 }, { 2.1 * side, 1.5, -3.0 }, dark, "metal", { 8, 0, 0 })
				end)
			end
			b:face({ 0, 2.2, -1.3 }, 2.2)
		end)
	end)
	b.angle = 24
	b.height = 3.4
	b:bob("body", 0.06, 0.5)
	b:swing("clawL", { 1, 0, 0 }, 8, 0.4)
	b:swing("clawR", { 1, 0, 0 }, 8, 0.4, 0.5)
	if ctx.pose == "strike" then
		b:shift("root", 0, 0.2, -0.9)
		b:turn("clawL", -40)
		b:turn("clawR", -50)
	elseif ctx.pose == "hurt" then
		b:shift("root", 0, 0, 0.6)
		b:turn("body", -12, 0, 8)
	elseif ctx.pose == "down" then
		b:turn("body", 0, 0, 178)
		b:shift("root", 0, 0.6, 0)
		b:turn("clawL", 60)
		b:turn("clawR", 60)
	end
end)

-- SERPENT: a long body rearing out of the ground, jaws, a lit belly (drains, cisterns, the Lake)
register("serpent", { color = { 46, 70, 92 }, eye = { 150, 230, 255 } }, nil, function(b, ctx)
	local skin, dark = ctx.body, shade(ctx.body, 0.6)
	local eye, eyeMat = b:lit(ctx.eye)
	local spine = { { 0, 0.4, 2.4 }, { 0.9, 0.5, 1.4 }, { -0.7, 0.7, 0.4 }, { 0.5, 1.4, -0.3 }, { -0.2, 2.6, -0.6 }, { 0.1, 3.8, -0.9 }, { 0, 4.7, -1.5 } }
	b:group("root", { 0, 0.6, 0 }, function()
		b:group("body", { 0, 1.0, 0 }, function()
			for i = 1, #spine - 1 do
				local w = 1.25 - i * 0.07
				b:bone("Coil", spine[i], spine[i + 1], w, w, if i % 2 == 0 then skin else shade(skin, 0.85), "plastic", nil, 0.3)
				local mid = vlerp(spine[i], spine[i + 1], 0.5)
				b:ball("Belly", w * 0.5, { mid[1], mid[2] - 0.1, mid[3] - w * 0.36 }, eye, eyeMat)
				b:box("Fin", { 0.1, 0.5, 0.4 }, { mid[1], mid[2] + w * 0.5, mid[3] + 0.3 }, dark, "plastic", { -30, 0, 0 })
			end
			b:group("head", { 0, 4.7, -1.5 }, function()
				b:box("Skull", { 1.2, 0.8, 1.7 }, { 0, 5.0, -2.2 }, skin, "plastic", { 12, 0, 0 })
				b:box("Jaw", { 1.0, 0.3, 1.5 }, { 0, 4.45, -2.3 }, dark, "plastic", { 24, 0, 0 })
				for i = -2, 2 do
					b:box("Tooth", { 0.12, 0.36, 0.12 }, { i * 0.2, 4.7, -2.95 }, BONE, "plastic")
				end
				for _, side in { -1, 1 } do
					b:ball("Eye", 0.3, { 0.5 * side, 5.3, -2.5 }, eye, eyeMat)
					b:rod("Whisker", { 0.5 * side, 4.8, -3.0 }, { 1.2 * side, 4.4, -3.6 }, 0.06, dark, "plastic")
				end
			end)
			b:face({ 0, 4.9, -2.4 }, 1.8)
		end)
	end)
	b.angle = 30
	b.height = 5.8
	b:swing("body", { 0, 0, 1 }, 4, 0.25)
	b:swing("head", { 0, 1, 0 }, 10, 0.3)
	b:glow("body", "pulse", 0.4)
	if ctx.pose == "strike" then
		b:turn("body", 26)
		b:turn("head", 20)
		b:shift("root", 0, 0, -0.6)
	elseif ctx.pose == "hurt" then
		b:turn("body", -16, 0, 14)
	elseif ctx.pose == "down" then
		b:turn("body", 78, 0, 20)
		b:shift("root", 0, -0.3, 0)
	end
end)

-- LAMP: a very tall thin figure with a street lamp where its head should be
register("lamp", { color = { 40, 38, 36 }, eye = { 255, 214, 130 } }, nil, function(b, ctx)
	local coat, brass = ctx.body, BRASS
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 3, 0 }, function()
		b:group("body", { 0, 3, 0 }, function()
			for _, side in { -1, 1 } do
				b:bone("Leg", { 0.3 * side, 2.6, 0 }, { 0.36 * side, 0.1, 0.1 }, 0.3, 0.3, SOOT, "fabric")
			end
			b:box("Coat", { 1.3, 3.2, 0.8 }, { 0, 3.9, 0 }, coat, "fabric")
			b:box("CoatTail", { 1.5, 1.6, 0.9 }, { 0, 1.9, 0.06 }, shade(coat, 0.85), "fabric")
			b:box("Collar", { 1.6, 0.4, 1.0 }, { 0, 5.5, 0 }, shade(coat, 0.7), "fabric")
			for i = 0, 3 do
				b:ball("Button", 0.14, { 0, 5.0 - i * 0.6, -0.42 }, brass, "metal")
			end
			b:rod("Neck", { 0, 5.6, 0 }, { 0, 6.6, -0.1 }, 0.16, brass, "metal")
			b:group("head", { 0, 6.6, -0.1 }, function()
				b:box("Cage", { 0.9, 1.0, 0.9 }, { 0, 7.2, -0.1 }, IRON, "metal")
				b:box("Light", { 0.7, 0.8, 0.7 }, { 0, 7.2, -0.1 }, eye, eyeMat)
				b:box("Cap", { 1.2, 0.16, 1.2 }, { 0, 7.78, -0.1 }, IRON, "metal")
				b:box("Finial", { 0.2, 0.3, 0.2 }, { 0, 8.0, -0.1 }, brass, "metal")
			end)
			for _, side in { -1, 1 } do
				b:group(if side < 0 then "armL" else "armR", { 0.7 * side, 5.3, 0 }, function()
					b:bone("Arm", { 0.7 * side, 5.3, 0 }, { 1.1 * side, 3.6, -0.3 }, 0.24, 0.24, coat, "fabric")
					b:bone("Arm", { 1.1 * side, 3.6, -0.3 }, { 0.9 * side, 2.2, -0.9 }, 0.2, 0.2, coat, "fabric")
					b:ball("Hand", 0.3, { 0.9 * side, 2.1, -0.95 }, BONE, "plastic")
				end)
			end
			b:group("pole", { 0.9, 2.1, -0.95 }, function()
				b:rod("Pole", { 0.9, 0.1, -1.0 }, { 0.9, 6.4, -0.9 }, 0.1, brass, "metal")
				b:box("Hook", { 0.08, 0.08, 0.5 }, { 0.9, 6.4, -1.14 }, brass, "metal")
				b:ball("Wick", 0.2, { 0.9, 6.3, -1.4 }, eye, eyeMat)
			end)
			b:face({ 0, 7.2, -0.6 }, 1.6)
		end)
	end)
	b.angle = 20
	b.height = 8.4
	b:bob("body", 0.05, 0.2)
	b:swing("head", { 0, 0, 1 }, 5, 0.18)
	b:glow("head", "flicker", 0.7)
	if ctx.pose == "strike" then
		b:turn("body", 14)
		b:turn("pole", -50)
		b:turn("armR", -50)
	elseif ctx.pose == "hurt" then
		b:turn("body", -10, 0, 8)
		b:turn("head", 0, 0, 30)
	elseif ctx.pose == "down" then
		b:turn("body", 84, 0, 0)
		b:shift("root", 0, -2.2, 1.0)
		b:turn("head", 0, 0, 60)
	end
end)

-- BOOK: an open book that hangs in the air, pages for wings, thread and reading glasses
register("book", { color = { 96, 60, 44 }, eye = { 236, 226, 190 } }, nil, function(b, ctx)
	local cover, page = ctx.body, BONE
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 3.2, 0 }, function()
		b:group("body", { 0, 3.2, 0 }, function()
			b:box("Spine", { 0.3, 2.6, 0.4 }, { 0, 3.2, 0.2 }, shade(cover, 0.7), "fabric")
			for _, side in { -1, 1 } do
				b:group(if side < 0 then "wingL" else "wingR", { 0, 3.2, 0.1 }, function()
					b:box("Cover", { 2.0, 2.7, 0.12 }, { 1.02 * side, 3.2, -0.1 }, cover, "fabric", { 0, 22 * side, 0 })
					for i = 0, 3 do
						b:box("Page", { 1.8 - i * 0.1, 2.4, 0.03 }, { (0.95 - i * 0.03) * side, 3.2, -0.22 - i * 0.07 }, page, "plastic", { 0, (26 + i * 6) * side, 0 })
					end
					for l = 0, 4 do
						b:box("Line", { 1.1, 0.05, 0.02 }, { 0.9 * side, 3.9 - l * 0.34, -0.5 }, SOOT, "plastic", { 0, 44 * side, 0 })
					end
				end)
			end
			for i = 0, 4 do
				local x = -1.0 + i * 0.5
				b:rod("Thread", { x, 4.5, 0 }, { x * 1.3, 5.7, 0.2 }, 0.03, { 150, 30, 40 }, "fabric")
				b:group("lens" .. i, { x, 2.6 + (i % 2) * 0.9, -0.9 }, function()
					b:disc("Rim", { x, 2.6 + (i % 2) * 0.9, -0.9 }, { 0, 0, 1 }, 0.42, 0.05, BRASS, "metal")
					b:disc("Lens", { x, 2.6 + (i % 2) * 0.9, -0.93 }, { 0, 0, 1 }, 0.32, 0.03, eye, eyeMat)
				end)
				b:glow("lens" .. i, "blink", 0.12 + i * 0.03, i * 0.2)
			end
			b:bone("Ribbon", { 0, 2.0, 0.1 }, { 0.2, 0.8, -0.1 }, 0.16, 0.03, { 150, 30, 40 }, "fabric")
			b:face({ 0, 3.3, -0.6 }, 2.4)
		end)
	end)
	b.angle = 16
	b.height = 5.8
	b:bob("body", 0.2, 0.3)
	b:swing("wingL", { 0, 1, 0 }, 10, 0.5)
	b:swing("wingR", { 0, 1, 0 }, 10, 0.5, 0.5)
	if ctx.pose == "strike" then
		b:shift("root", 0, 0.3, -1.0)
		b:turn("wingL", 0, 40)
		b:turn("wingR", 0, -40)
	elseif ctx.pose == "hurt" then
		b:turn("body", -14, 0, 16)
	elseif ctx.pose == "down" then
		b:shift("root", 0, -2.9, 0)
		b:turn("body", 86, 0, 0)
		b:turn("wingL", 0, -30)
		b:turn("wingR", 0, 30)
	end
end)

-- DOOR: a door standing by itself, ajar, with hands on the frame and something behind it
register("door", { color = { 92, 62, 44 }, eye = { 255, 120, 90 } }, nil, function(b, ctx)
	local wood, dark = ctx.body, shade(ctx.body, 0.55)
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 0, 0 }, function()
		b:group("body", { 0, 0, 0 }, function()
			b:box("PostL", { 0.3, 5.2, 0.4 }, { -1.3, 2.6, 0 }, dark, "wood")
			b:box("PostR", { 0.3, 5.2, 0.4 }, { 1.3, 2.6, 0 }, dark, "wood")
			b:box("Lintel", { 2.9, 0.3, 0.4 }, { 0, 5.3, 0 }, dark, "wood")
			b:box("Step", { 3.2, 0.2, 1.0 }, { 0, 0.1, -0.2 }, IRON, "plastic")
			b:box("Dark", { 2.3, 5.0, 0.06 }, { 0, 2.6, 0.1 }, SOOT, "plastic")
			b:group("leaf", { -1.15, 2.6, 0 }, function()
				b:box("Door", { 2.3, 5.0, 0.16 }, { 0, 2.6, -0.1 }, wood, "wood")
				for i = 0, 1 do
					b:box("Panel", { 1.6, 1.8, 0.05 }, { 0, 1.5 + i * 2.2, -0.2 }, shade(wood, 0.8), "wood")
				end
				b:ball("Knob", 0.26, { 0.85, 2.5, -0.28 }, BRASS, "metal")
				b:box("Keyhole", { 0.12, 0.24, 0.05 }, { 0.85, 2.1, -0.2 }, eye, eyeMat)
			end)
			for i = 0, 2 do
				b:ball("Eye", 0.24, { 0.5 - i * 0.2, 1.6 + i * 1.3, 0.02 }, eye, eyeMat)
			end
			for _, s in { { 1.3, 3.6 }, { 1.3, 1.6 }, { -1.3, 4.4 } } do
				b:group("hand" .. s[2], { s[1], s[2], -0.2 }, function()
					for f = 0, 3 do
						b:bone("Finger", { s[1] * 0.75, s[2] - 0.24 + f * 0.16, 0.1 }, { s[1] * 1.04, s[2] - 0.24 + f * 0.16, -0.5 }, 0.1, 0.1, BONE, "plastic")
					end
				end)
				b:swing("hand" .. s[2], { 0, 1, 0 }, 6, 0.5, s[2] * 0.1)
			end
			b:face({ 0, 3.2, -0.3 }, 2.6)
		end)
	end)
	b.angle = 22
	b.height = 5.8
	b:swing("leaf", { 0, 1, 0 }, 9, 0.2)
	if ctx.pose == "strike" then
		b:turn("leaf", 0, -70)
		b:shift("root", 0, 0, -0.5)
	elseif ctx.pose == "hurt" then
		b:turn("body", -8, 0, 6)
		b:turn("leaf", 0, 30)
	elseif ctx.pose == "down" then
		b:turn("body", 88)
		b:shift("root", 0, 0.3, 1.0)
	end
end)

-- DOLL: a wooden puppet hung from its own strings
register("doll", { color = { 176, 140, 104 }, eye = { 90, 200, 255 } }, nil, function(b, ctx)
	local wood, dark = ctx.body, shade(ctx.body, 0.62)
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 3, 0 }, function()
		b:group("cross", { 0, 6.6, 0 }, function()
			b:box("Bar", { 2.6, 0.14, 0.14 }, { 0, 6.6, 0 }, dark, "wood")
			b:box("Bar", { 0.14, 0.14, 1.6 }, { 0, 6.6, 0 }, dark, "wood")
		end)
		b:group("body", { 0, 3.4, 0 }, function()
			b:box("Chest", { 1.3, 1.5, 0.8 }, { 0, 3.7, 0 }, wood, "wood")
			b:box("Hips", { 1.1, 0.6, 0.7 }, { 0, 2.6, 0 }, dark, "wood")
			b:ball("Joint", 0.4, { 0, 3.0, 0 }, dark, "wood")
			b:group("head", { 0, 4.6, 0 }, function()
				b:ball("Head", 1.3, { 0, 5.2, 0 }, wood, "wood")
				b:box("Jaw", { 0.6, 0.3, 0.5 }, { 0, 4.72, -0.42 }, dark, "wood")
				for _, side in { -1, 1 } do
					b:disc("Eye", { 0.3 * side, 5.3, -0.6 }, { 0, 0, 1 }, 0.34, 0.06, eye, eyeMat)
					b:ball("Cheek", 0.2, { 0.44 * side, 4.95, -0.5 }, { 200, 80, 80 }, "plastic")
				end
				b:rod("String", { 0, 5.8, 0 }, { 0, 6.6, 0 }, 0.03, BONE, "fabric")
			end)
			for _, side in { -1, 1 } do
				b:group(if side < 0 then "armL" else "armR", { 0.8 * side, 4.3, 0 }, function()
					b:bone("Arm", { 0.8 * side, 4.3, 0 }, { 1.3 * side, 3.4, -0.2 }, 0.26, 0.26, wood, "wood")
					b:ball("Elbow", 0.3, { 1.3 * side, 3.4, -0.2 }, dark, "wood")
					b:bone("Arm", { 1.3 * side, 3.4, -0.2 }, { 1.2 * side, 2.5, -0.7 }, 0.22, 0.22, wood, "wood")
					b:rod("String", { 1.2 * side, 2.6, -0.7 }, { 1.25 * side, 6.6, 0 }, 0.03, BONE, "fabric")
				end)
				b:group(if side < 0 then "legL" else "legR", { 0.34 * side, 2.4, 0 }, function()
					b:bone("Leg", { 0.34 * side, 2.4, 0 }, { 0.4 * side, 1.3, -0.1 }, 0.3, 0.3, wood, "wood")
					b:ball("Knee", 0.32, { 0.4 * side, 1.3, -0.1 }, dark, "wood")
					b:bone("Leg", { 0.4 * side, 1.3, -0.1 }, { 0.4 * side, 0.3, 0 }, 0.26, 0.26, wood, "wood")
					b:box("Foot", { 0.34, 0.2, 0.6 }, { 0.4 * side, 0.2, -0.16 }, dark, "wood")
				end)
			end
			b:face({ 0, 5.2, -0.6 }, 1.5)
		end)
	end)
	b.angle = 22
	b.height = 7.0
	b:bob("body", 0.12, 0.35)
	b:swing("armL", { 1, 0, 0 }, 14, 0.4)
	b:swing("armR", { 1, 0, 0 }, 14, 0.4, 0.5)
	b:swing("legL", { 1, 0, 0 }, 8, 0.35, 0.25)
	b:swing("legR", { 1, 0, 0 }, 8, 0.35, 0.75)
	b:swing("head", { 0, 0, 1 }, 10, 0.3)
	if ctx.pose == "strike" then
		b:shift("body", 0, 0.3, -1.0)
		b:turn("armL", -80)
		b:turn("armR", -80)
	elseif ctx.pose == "hurt" then
		b:turn("body", -16, 0, 20)
	elseif ctx.pose == "down" then
		b:shift("body", 0, -2.6, 0)
		b:turn("body", 30, 0, 40)
		b:turn("head", 0, 0, 70)
		b:turn("cross", 0, 0, 30)
	end
end)

-- ARMOR: a suit of plate with nobody in it, and a light where the face should be
register("armor", { color = { 104, 108, 118 }, eye = { 120, 190, 255 } }, nil, function(b, ctx)
	local plate, dark = ctx.body, shade(ctx.body, 0.55)
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 2.6, 0 }, function()
		b:group("body", { 0, 2.6, 0 }, function()
			for _, side in { -1, 1 } do
				b:box("Greave", { 0.7, 1.4, 0.8 }, { 0.5 * side, 0.8, 0 }, plate, "metal")
				b:box("Thigh", { 0.76, 1.2, 0.84 }, { 0.5 * side, 2.0, 0 }, dark, "metal")
				b:box("Boot", { 0.8, 0.3, 1.1 }, { 0.5 * side, 0.15, -0.14 }, dark, "metal")
				b:box("Pauldron", { 1.2, 0.7, 1.3 }, { 1.5 * side, 4.9, 0 }, plate, "metal", { 0, 0, -12 * side })
			end
			b:box("Cuirass", { 2.3, 2.0, 1.3 }, { 0, 3.9, 0 }, plate, "metal")
			b:box("Tasset", { 2.4, 0.7, 1.4 }, { 0, 2.7, 0 }, dark, "metal")
			b:box("Ridge", { 0.16, 1.8, 0.1 }, { 0, 3.9, -0.68 }, shade(plate, 1.25), "metal")
			b:group("head", { 0, 5.0, 0 }, function()
				b:box("Helm", { 1.2, 1.3, 1.2 }, { 0, 5.7, 0 }, plate, "metal")
				b:box("Visor", { 0.9, 0.16, 0.1 }, { 0, 5.76, -0.62 }, eye, eyeMat)
				b:box("Crest", { 0.14, 0.6, 1.3 }, { 0, 6.5, 0.1 }, { 150, 30, 40 }, "fabric")
			end)
			b:group("armR", { 1.5, 4.7, 0 }, function()
				b:bone("Arm", { 1.5, 4.7, 0 }, { 1.7, 3.3, -0.4 }, 0.6, 0.6, dark, "metal")
				b:bone("Gauntlet", { 1.7, 3.3, -0.4 }, { 1.5, 2.6, -1.3 }, 0.56, 0.56, plate, "metal")
				b:box("Blade", { 0.14, 4.2, 0.6 }, { 1.5, 4.5, -1.5 }, STEEL, "metal", { -8, 0, 0 })
				b:box("Guard", { 1.1, 0.16, 0.3 }, { 1.5, 2.6, -1.36 }, BRASS, "metal")
			end)
			b:group("armL", { -1.5, 4.7, 0 }, function()
				b:bone("Arm", { -1.5, 4.7, 0 }, { -1.8, 3.2, -0.2 }, 0.6, 0.6, dark, "metal")
				b:box("Shield", { 0.2, 2.6, 1.8 }, { -2.2, 3.2, -0.4 }, plate, "metal")
				b:ball("Boss", 0.6, { -2.34, 3.3, -0.4 }, BRASS, "metal")
			end)
			b:face({ 0, 5.7, -0.7 }, 1.6)
		end)
	end)
	b.angle = 24
	b.height = 7.2
	b:bob("body", 0.05, 0.22)
	b:swing("armR", { 1, 0, 0 }, 4, 0.2)
	b:glow("head", "pulse", 0.3)
	if ctx.pose == "strike" then
		b:shift("root", 0, 0, -0.8)
		b:turn("armR", -70)
		b:turn("body", 10)
	elseif ctx.pose == "hurt" then
		b:turn("body", -10, 0, 8)
		b:turn("head", 0, 30)
	elseif ctx.pose == "down" then
		b:turn("body", 86)
		b:shift("root", 0, -1.6, 0.8)
		b:shift("head", 1.4, 0, -0.8)
	end
end)

-- BRANCHES: a trunk that used to be a person, and what's growing out of it
register("branches", { color = { 74, 58, 46 }, eye = { 255, 190, 80 } }, nil, function(b, ctx)
	local bark, dark = ctx.body, shade(ctx.body, 0.6)
	local eye, eyeMat = b:lit(ctx.eye)
	local rng = ctx.rng
	b:group("root", { 0, 0, 0 }, function()
		for i = 0, 4 do
			local a = i * 1.26
			b:bone("Root", { 0, 0.5, 0 }, { math.cos(a) * 1.8, 0.05, math.sin(a) * 1.8 }, 0.4, 0.3, dark, "wood")
		end
		b:group("body", { 0, 0.5, 0 }, function()
			b:bone("Trunk", { 0, 0.3, 0 }, { 0.2, 2.6, -0.1 }, 1.2, 1.1, bark, "wood")
			b:bone("Trunk", { 0.2, 2.6, -0.1 }, { -0.1, 4.6, -0.3 }, 0.9, 0.9, bark, "wood")
			b:box("Hollow", { 0.5, 0.8, 0.1 }, { 0.1, 3.0, -0.56 }, SOOT, "plastic")
			b:ball("Core", 0.34, { 0.1, 3.0, -0.5 }, eye, eyeMat)
			local limbs = { { -0.1, 4.6, -0.3, -1.9, 6.2, -0.6 }, { -0.1, 4.6, -0.3, 1.6, 6.5, -0.2 }, { 0.1, 3.6, -0.2, 2.2, 4.4, -1.0 }, { 0, 3.9, -0.2, -2.3, 4.0, -1.2 }, { -0.1, 4.6, -0.3, 0.1, 7.0, 0.4 } }
			for i, l in limbs do
				b:group("limb" .. i, { l[1], l[2], l[3] }, function()
					b:bone("Branch", { l[1], l[2], l[3] }, { l[4], l[5], l[6] }, 0.32, 0.3, bark, "wood")
					for t = 1, 3 do
						local at = vlerp({ l[1], l[2], l[3] }, { l[4], l[5], l[6] }, 0.4 + t * 0.2)
						b:bone("Twig", at, { at[1] + rng.range(-0.7, 0.7), at[2] + rng.range(0.2, 0.8), at[3] + rng.range(-0.6, 0.2) }, 0.1, 0.1, dark, "wood")
					end
					b:rod("Stem", { l[4], l[5], l[6] }, { l[4], l[5] - 0.6, l[6] - 0.1 }, 0.04, dark, "wood")
					b:ball("Fruit", 0.4, { l[4], l[5] - 0.8, l[6] - 0.1 }, eye, eyeMat)
				end)
				b:swing("limb" .. i, { 0, 0, 1 }, 4, 0.2, i * 0.2)
			end
			b:face({ 0.1, 3.4, -0.6 }, 2.4)
		end)
	end)
	b.angle = 18
	b.height = 7.4
	b:glow("body", "pulse", 0.25)
	if ctx.pose == "strike" then
		b:turn("body", 16)
		b:turn("limb3", -50)
		b:turn("limb4", -50)
	elseif ctx.pose == "hurt" then
		b:turn("body", -10, 0, 8)
	elseif ctx.pose == "down" then
		b:turn("body", 80, 0, 10)
		b:shift("root", 0, 0.2, 0.6)
	end
end)

-- WATCHER: one great eye, lidded, hanging in a ring of smaller ones
register("watcher", { color = { 70, 40, 70 }, eye = { 255, 220, 120 } }, nil, function(b, ctx)
	local flesh, dark = ctx.body, shade(ctx.body, 0.6)
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 3.6, 0 }, function()
		b:group("body", { 0, 3.6, 0 }, function()
			b:ball("Globe", 2.8, { 0, 3.6, 0 }, BONE, "plastic")
			b:disc("Iris", { 0, 3.6, -1.3 }, { 0, 0, 1 }, 1.5, 0.2, eye, eyeMat)
			b:disc("Pupil", { 0, 3.6, -1.42 }, { 0, 0, 1 }, 0.3, 0.08, SOOT, "plastic")
			b:group("lidTop", { 0, 4.3, 0 }, function()
				b:box("Lid", { 3.0, 0.8, 3.0 }, { 0, 4.95, 0.1 }, flesh, "plastic", { -10, 0, 0 })
			end)
			b:group("lidLow", { 0, 2.9, 0 }, function()
				b:box("Lid", { 3.0, 0.6, 3.0 }, { 0, 2.2, 0.1 }, dark, "plastic", { 8, 0, 0 })
			end)
			for i = 0, 4 do
				b:bone("Nerve", { -0.8 + i * 0.4, 2.2, 0.6 }, { -1.2 + i * 0.6, 0.4, 1.0 + (i % 2) * 0.4 }, 0.16, 0.16, dark, "plastic")
			end
			b:face({ 0, 3.6, -1.3 }, 2.8)
		end)
		b:group("ring", { 0, 3.6, 0 }, function()
			for i = 0, 7 do
				local a = i * math.pi / 4
				b:ball("Small", 0.44, { math.cos(a) * 2.4, 3.6 + math.sin(a) * 2.4, -0.2 }, eye, eyeMat)
			end
		end)
	end)
	b.angle = 14
	b.height = 6.6
	b:bob("body", 0.16, 0.25)
	b:spin("ring", { 0, 0, 1 }, 0.06)
	b:swing("lidTop", { 1, 0, 0 }, 6, 0.14)
	b:glow("ring", "blink", 0.2)
	if ctx.pose == "strike" then
		b:shift("root", 0, 0, -1.0)
		b:turn("lidTop", -26)
		b:turn("lidLow", 20)
	elseif ctx.pose == "hurt" then
		b:turn("lidTop", 34)
		b:turn("body", 0, 0, 14)
	elseif ctx.pose == "down" then
		b:shift("root", 0, -2.4, 0)
		b:turn("lidTop", 40)
		b:turn("lidLow", -16)
	end
end)

-- MANTIS: something built for the Smoke War and never switched off: plates, scythes, six legs
register("mantis", { color = { 62, 78, 60 }, eye = { 255, 80, 60 } }, nil, function(b, ctx)
	local plate, dark = ctx.body, shade(ctx.body, 0.55)
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 2.2, 0 }, function()
		b:group("body", { 0, 2.2, 0 }, function()
			b:bone("Abdomen", { 0, 2.2, 2.4 }, { 0, 2.4, 0.4 }, 1.3, 1.1, plate, "metal")
			b:bone("Thorax", { 0, 2.4, 0.4 }, { 0, 3.8, -0.8 }, 1.0, 0.9, dark, "metal")
			for i = 0, 3 do
				b:box("Plate", { 1.4, 0.12, 0.5 }, { 0, 2.9, 2.0 - i * 0.5 }, shade(plate, 1.2), "metal", { -8, 0, 0 })
			end
			b:group("head", { 0, 3.8, -0.8 }, function()
				b:box("Head", { 1.0, 0.6, 0.8 }, { 0, 4.2, -1.2 }, plate, "metal", { 20, 0, 0 })
				for _, side in { -1, 1 } do
					b:ball("Eye", 0.4, { 0.5 * side, 4.3, -1.4 }, eye, eyeMat)
					b:rod("Antenna", { 0.3 * side, 4.5, -1.1 }, { 0.9 * side, 5.6, -0.6 }, 0.05, dark, "metal")
					b:box("Mandible", { 0.14, 0.14, 0.5 }, { 0.2 * side, 3.95, -1.7 }, STEEL, "metal")
				end
			end)
			for _, side in { -1, 1 } do
				b:group(if side < 0 then "scytheL" else "scytheR", { 0.6 * side, 3.6, -0.6 }, function()
					b:bone("Arm", { 0.6 * side, 3.6, -0.6 }, { 1.4 * side, 4.6, -1.2 }, 0.3, 0.3, dark, "metal")
					b:bone("Blade", { 1.4 * side, 4.6, -1.2 }, { 1.2 * side, 2.6, -2.4 }, 0.12, 0.5, STEEL, "metal")
					b:bone("Edge", { 1.2 * side, 2.6, -2.4 }, { 0.9 * side, 1.6, -2.2 }, 0.08, 0.3, STEEL, "metal")
				end)
				for j = 0, 1 do
					b:group("leg" .. side .. j, { 0.6 * side, 2.3, 0.6 + j * 1.0 }, function()
						b:bone("Leg", { 0.6 * side, 2.3, 0.6 + j * 1.0 }, { 1.9 * side, 3.0, 0.8 + j * 1.2 }, 0.18, 0.18, dark, "metal")
						b:bone("Leg", { 1.9 * side, 3.0, 0.8 + j * 1.2 }, { 2.3 * side, 0.05, 1.0 + j * 1.4 }, 0.14, 0.14, dark, "metal")
					end)
					b:swing("leg" .. side .. j, { 0, 0, 1 }, 4, 0.7, j * 0.5)
				end
			end
			b:face({ 0, 4.2, -1.5 }, 1.8)
		end)
	end)
	b.angle = 30
	b.height = 5.8
	b:bob("body", 0.08, 0.5)
	b:swing("scytheL", { 1, 0, 0 }, 8, 0.5)
	b:swing("scytheR", { 1, 0, 0 }, 8, 0.5, 0.5)
	b:swing("head", { 0, 1, 0 }, 14, 0.6)
	if ctx.pose == "strike" then
		b:shift("root", 0, 0, -1.0)
		b:turn("scytheL", -60)
		b:turn("scytheR", -70)
	elseif ctx.pose == "hurt" then
		b:turn("body", -14, 0, 10)
	elseif ctx.pose == "down" then
		b:turn("body", 0, 0, 96)
		b:shift("root", 0, -1.0, 0)
	end
end)

-- RUSTBACK: a heavy four-legged thing from past the wall, plated in whatever rusted onto it
register("rustback", { color = { 110, 78, 58 }, eye = { 255, 170, 60 } }, nil, function(b, ctx)
	local hide, rust = ctx.body, { 150, 84, 44 }
	local dark = shade(hide, 0.55)
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 2.4, 0 }, function()
		b:group("body", { 0, 2.4, 0 }, function()
			b:box("Barrel", { 2.6, 2.2, 4.2 }, { 0, 2.9, 0.4 }, hide, "plastic")
			b:box("Hump", { 2.2, 1.0, 2.0 }, { 0, 4.3, -0.4 }, dark, "plastic")
			for i = 0, 4 do
				b:box("Plate", { 2.9, 0.26, 0.8 }, { 0, 4.2 - (i % 2) * 0.3, -1.2 + i * 0.8 }, rust, "metal", { (i - 2) * 5, 0, (i % 2) * 6 - 3 })
			end
			for _, side in { -1, 1 } do
				for _, z in { -1.2, 1.9 } do
					b:group("leg" .. side .. z, { 1.0 * side, 2.0, z }, function()
						b:box("Leg", { 0.8, 2.0, 0.9 }, { 1.0 * side, 1.0, z }, dark, "plastic")
						b:box("Hoof", { 0.9, 0.3, 1.0 }, { 1.0 * side, 0.15, z - 0.06 }, IRON, "metal")
					end)
				end
			end
			b:group("head", { 0, 3.0, -1.8 }, function()
				b:box("Skull", { 1.6, 1.4, 1.8 }, { 0, 2.6, -2.6 }, hide, "plastic", { 16, 0, 0 })
				b:box("Brow", { 1.8, 0.4, 0.6 }, { 0, 3.2, -2.9 }, rust, "metal", { 16, 0, 0 })
				b:bone("Horn", { 0, 2.6, -3.4 }, { 0, 3.9, -4.3 }, 0.4, 0.4, BONE, "plastic")
				for _, side in { -1, 1 } do
					b:ball("Eye", 0.26, { 0.66 * side, 2.8, -3.3 }, eye, eyeMat)
					b:bone("Tusk", { 0.6 * side, 2.0, -3.2 }, { 0.9 * side, 2.4, -3.9 }, 0.2, 0.2, BONE, "plastic")
				end
			end)
			b:bone("Tail", { 0, 3.2, 2.5 }, { 0, 1.8, 3.5 }, 0.24, 0.24, dark, "plastic")
			b:face({ 0, 2.8, -3.2 }, 2.4)
		end)
	end)
	b.angle = 34
	b.height = 5.4
	b:bob("body", 0.05, 0.3)
	b:swing("head", { 1, 0, 0 }, 6, 0.25)
	if ctx.pose == "strike" then
		b:shift("root", 0, 0, -1.4)
		b:turn("head", -24)
	elseif ctx.pose == "hurt" then
		b:turn("body", -8, 0, 8)
		b:shift("root", 0, 0, 0.6)
	elseif ctx.pose == "down" then
		b:turn("body", 0, 0, 84)
		b:shift("root", 0, -1.2, 0)
	end
end)

-- PARASOL: an umbrella that opened by itself, on one leg, and is delighted to see you
register("parasol", { color = { 150, 40, 60 }, eye = { 255, 240, 200 } }, nil, function(b, ctx)
	local cloth, dark = ctx.body, shade(ctx.body, 0.6)
	local eye, eyeMat = b:lit(ctx.eye)
	b:group("root", { 0, 2.4, 0 }, function()
		b:group("body", { 0, 2.4, 0 }, function()
			b:rod("Shaft", { 0, 0.4, 0 }, { 0, 4.6, 0 }, 0.14, SOOT, "metal")
			b:box("Shoe", { 0.5, 0.26, 0.9 }, { 0, 0.13, -0.16 }, { 30, 26, 30 }, "plastic")
			b:group("canopy", { 0, 4.6, 0 }, function()
				for i = 0, 7 do
					local a = i * math.pi / 4
					local out = { math.cos(a) * 2.2, 3.7, math.sin(a) * 2.2 }
					b:bone("Rib", { 0, 4.7, 0 }, out, 0.08, 0.08, SOOT, "metal")
					b:bone("Panel", { 0, 4.74, 0 }, { math.cos(a + 0.39) * 2.0, 3.86, math.sin(a + 0.39) * 2.0 }, 1.5, 0.06, if i % 2 == 0 then cloth else dark, "fabric")
					b:ball("Bead", 0.16, out, BRASS, "metal")
				end
				b:ball("Tip", 0.24, { 0, 4.9, 0 }, BRASS, "metal")
			end)
			for _, side in { -1, 1 } do
				b:disc("Eye", { 0.5 * side, 3.5, -1.6 }, { 0, -0.4, 1 }, 0.5, 0.06, eye, eyeMat)
				b:ball("Pupil", 0.16, { 0.5 * side, 3.46, -1.66 }, SOOT, "plastic")
			end
			for i = -3, 3 do
				b:box("Tooth", { 0.16, 0.26, 0.06 }, { i * 0.2, 3.0 - math.abs(i) * 0.06, -1.5 }, BONE, "plastic")
			end
			b:face({ 0, 3.4, -1.6 }, 2.6)
		end)
	end)
	b.angle = 20
	b.height = 5.4
	b:bob("body", 0.3, 0.9)
	b:swing("body", { 0, 0, 1 }, 8, 0.45)
	b:spin("canopy", { 0, 1, 0 }, 0.12)
	if ctx.pose == "strike" then
		b:shift("root", 0, 0.6, -1.2)
		b:turn("body", 30)
	elseif ctx.pose == "hurt" then
		b:turn("body", -20, 0, 16)
	elseif ctx.pose == "down" then
		b:turn("body", 0, 0, 100)
		b:shift("root", 0, -1.8, 0)
	end
end)

-- (v0.17) twelve more shapes, in their own module, registered the same way
require(script.Parent.Creatures17)(register, { BRASS = BRASS, STEEL = STEEL, IRON = IRON, BONE = BONE, SOOT = SOOT, shade = shade, mix = mix })

-- ── putting it together ─────────────────────────────────────────────────────

-- def -> the shape id that will be drawn, its variant (if it has them), and the seed
function Creatures.resolve(def)
	def = if type(def) == "table" then def else {}
	local raw = if type(def.shape) == "string" then def.shape else Creatures.default
	local shape, variant = string.match(raw, "^([^:]+):(.+)$")
	shape = shape or raw
	if not SHAPES[shape] then
		shape, variant = Creatures.default, nil
	end
	local seed = def.seed
	if type(seed) ~= "number" or seed ~= seed or abs(seed) == math.huge then
		local key = def.name or def.id
		seed = hashString(if type(key) == "string" and key ~= "" then key else shape)
	end
	seed = math.floor(abs(seed)) % MOD
	local list = Creatures.variants[shape]
	if list then
		if not (variant and table.find(list, variant)) then
			variant = list[seed % #list + 1]
		end
	else
		variant = nil
	end
	return shape, variant, seed
end

local function colorKey(c): string
	return if isColor(c) then string.format("%d,%d,%d", c[1], c[2], c[3]) else "-"
end

-- Short string that changes whenever the drawn creature would change.
function Creatures.signature(def): string
	if type(def) ~= "table" then
		return ""
	end
	local shape, variant, seed = Creatures.resolve(def)
	local pose = if table.find(Creatures.poses, def.pose) then def.pose else "idle"
	return table.concat({ shape, variant or "", tostring(seed), colorKey(def.color), colorKey(def.eye), pose }, "|")
end

local function construct(shape: string, variant: string?, seed: number, pose: string, body, eye)
	local b = newBuilder(pose, newRng(seed), body, eye)
	SHAPES[shape](b, { pose = pose, rng = b.rng, body = body, eye = eye, variant = variant, seed = seed })
	local parts, anim = b:bake()
	return b, parts, anim
end

function Creatures.build(def, opts)
	def = if type(def) == "table" then def else {}
	opts = opts or {}
	local shape, variant, seed = Creatures.resolve(def)
	local pose = if table.find(Creatures.poses, def.pose) then def.pose else "idle"
	local defaults = DEFAULTS[shape]
	local body = if isColor(def.color) then def.color else defaults.color
	local eye = if isColor(def.eye) then def.eye else defaults.eye

	-- the idle pose decides where the camera looks, whatever pose is drawn
	local idleB, idleParts, idleAnim = construct(shape, variant, seed, "idle", body, eye)
	local lo, hi = boundsOf(idleParts)
	local cx, cz = (lo[1] + hi[1]) / 2, (lo[3] + hi[3]) / 2
	local _, parts, anim = idleB, idleParts, idleAnim
	if pose ~= "idle" then
		_, parts, anim = construct(shape, variant, seed, pose, body, eye)
	end

	-- centre it over the origin and stand it on the floor
	for _, p in parts do
		p.pos = { p.pos[1] - cx, p.pos[2] - lo[2], p.pos[3] - cz }
		p.m = nil
	end
	for _, g in anim do
		g.pivot = { g.pivot[1] - cx, g.pivot[2] - lo[2], g.pivot[3] - cz }
	end
	local top = hi[2] - lo[2]
	local width, depth = hi[1] - lo[1], hi[3] - lo[3]
	if opts.detail ~= false then
		parts = Detail.apply(parts :: any) :: any
	end
	if opts.ground ~= false then
		local d = idleB.groundSize or math.clamp(math.max(width, depth) * 0.9, 2.4, 9)
		table.insert(parts, 1, { name = "Ground", shape = "cyl", size = { d, 0.04, d }, pos = { 0, 0.02, 0 }, color = GROUND, material = "plastic" })
	end

	local focus = idleB.focus or { cx, lo[2] + top * 0.75, cz }
	focus = { focus[1] - cx, focus[2] - lo[2], focus[3] - cz }
	local headSize = idleB.headSize or math.max(1, top * 0.3)
	local frame = {
		height = math.min(top, idleB.height or top),
		top = top,
		headY = focus[2],
		headSize = headSize,
		center = { 0, top / 2, 0 },
		size = { width, top, depth },
		focus = focus,
		angle = idleB.angle or 30,
		shape = shape,
		variant = variant,
		seed = seed,
		pose = pose,
		anim = anim,
	}
	return parts, frame
end

return Creatures
