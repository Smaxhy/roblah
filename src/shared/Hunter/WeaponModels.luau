--[[
	WEAPON MODELS (BitLeveling): every weapon in Hunter/Weapons.luau as a 3D model on an R6
	rig, built from Parts, WedgeParts, Balls and Cylinders welded to the hand (or both hands, or
	the left arm for a shield, or the torso for a quiver or a bandolier). One builder per family
	(Weapons.FAMILIES); each weapon's colours and shape knobs (Weapons.list c and p) make it its
	own. Every part is named "Weapon<Piece>".

		WeaponModels.attach(model, base, stars, shiny)   -- on a rig built by R6Rig; returns the parts
		WeaponModels.detach(model)                        -- take a weapon (and its effects) off again
		WeaponModels.FAMILY_LIST                          -- the families it can draw
		WeaponModels.MESH_ROLES                           -- the MeshRole values it asks the mesh kit for

	RARITY AND ELEMENT, SHOWN (runs on the server and the client; kept cheap: low rates, small
	particles, at most one light):
		★      the element breathes a little (one faint emitter), no light
		★★     edges glow, a second emitter, a dim light
		★★★    obvious: busier emitters and a real light
		Shiny  gold trim, gold sparkles, a gold-tinged light, and a gold swing trail
	Each element has its own particles: fire embers and flame licks, frost mist and glints,
	lightning sparks, venom drips and haze, void motes and dark haze, holy motes and a glow,
	wind streaks and leaves, earth dust and grit; "none" only glints (★★ up).
	Every weapon also gets a swing trail: Attachments "TrailTop" / "TrailBottom" along the blade
	or head and a Trail "WeaponTrail" between them, DISABLED (client/WeaponFx switches it on
	for a swing), element-coloured, longer and brighter with stars, gold when Shiny.
	Emitters are "WeaponAura", "WeaponAura2", "WeaponShine"; the light is "WeaponLight".

	On the rig model, attach stamps attributes the client reads (client/WeaponFx):
		WeaponBase, WeaponFamily, WeaponElement, WeaponStars, WeaponShiny, WeaponClass,
		WeaponGrade, WeaponStyle (Weapons.FAMILIES[f].fx: slash, smash, thrust, shot, ...)

	THE MESH KIT (Hunter/MeshLibrary): part names the kit already knows (Grip, Guard, Blade,
	Point, Haft, Shaft, Head, Shield, Bit, Crescent) are kept where the shape matches. A part can
	also ASK for a mesh with the attribute MeshRole (MESH_ROLES below), always sized and turned
	so its own box matches that mesh (X right, Y up, -Z forward in the part's space).
	Where the parts-only look of a piece can't be one box (a trident's prongs, a crescent, a fan,
	a caged orb, a flanged head, a double axe, a kite shield, a leaf point), the MeshRole part is
	a SOCKET: its box is the whole piece, it has a SpecialMesh "FallbackShape" scaled to nothing
	(so it's invisible as parts), and an attribute MeshId. The parts that draw the piece without
	the kit carry MeshCover = that MeshId: when the kit dresses the socket, they should hide.
]]

local Weapons = require(script.Parent:WaitForChild("Weapons"))

local WeaponModels = {}

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local FIRE_TEX = "rbxasset://textures/particles/fire_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"

-- the mesh roles a part may ask for, and the shape its box must have (thin: the thinnest axis;
-- square: these two axes are equal; cube: all three equal)
WeaponModels.MESH_ROLES = {
	shield_round = { thin = "X", square = "YZ" },
	shield_kite = { thin = "X" },
	shield_tower = { thin = "X" },
	shield_buckler = { thin = "X", square = "YZ" },
	blade_curved = { thin = "X", long = "Z" },
	blade_wide = { thin = "X", long = "Z" },
	axe_double = { thin = "X", long = "Z" },
	spear_leaf = { thin = "X", long = "Y" },
	trident_head = { thin = "X", long = "Y" },
	mace_flanged = { square = "XZ" },
	orb_cage = { cube = true },
	staff_crescent = { thin = "X" },
	fan_blade = { thin = "X" },
}

local function c3(t: { number }): Color3
	return Color3.fromRGB(t[1], t[2], t[3])
end

-- one piece of a weapon, welded to a limb. offset is from the limb's centre, in its space.
local function piece(model: Model, limb: BasePart, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?, kind: string?): BasePart
	local p: BasePart
	if kind == "wedge" then
		p = Instance.new("WedgePart")
	else
		p = Instance.new("Part")
		if kind == "ball" then
			(p :: Part).Shape = Enum.PartType.Ball
		elseif kind == "cyl" then
			(p :: Part).Shape = Enum.PartType.Cylinder
		end
	end
	p.Name = "Weapon" .. name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CFrame = limb.CFrame * offset
	p:SetAttribute("WeaponPiece", true)
	local w = Instance.new("WeldConstraint")
	w.Part0 = limb
	w.Part1 = p
	w.Parent = p
	p.Parent = model
	return p
end

-- the hand: the bottom of an arm, the blade pointing forward and a little down
local HAND = CFrame.new(0, -1.05, -0.15)
local FORWARD = HAND * CFrame.Angles(math.rad(-22), 0, 0)
-- held upright: a staff or a spear stands along the arm
local UPRIGHT = HAND * CFrame.Angles(math.rad(-8), 0, 0)
-- a long two-hander, held nearer level
local LEVEL = HAND * CFrame.Angles(math.rad(-12), 0, 0)
-- a short club or scepter, raised: the head forward and up, in front of the chest
local RAISED = HAND * CFrame.Angles(math.rad(-50), 0, 0)

local METAL = Enum.Material.Metal
local NEON = Enum.Material.Neon
local WOOD = Enum.Material.Wood
local FABRIC = Enum.Material.Fabric
local LEATHER = Enum.Material.Leather
local GLASS = Enum.Material.Glass
local SLATE = Enum.Material.Slate

local R90 = math.rad(90)

-- a CFrame at `from` whose -Z looks at `to` (CFrame.lookAt, written out: the same on every
-- runtime, the offline sheets included)
local function aim(from: Vector3, to: Vector3): CFrame
	local look = (to - from).Unit
	local up = if math.abs(look.Y) > 0.99 then Vector3.new(1, 0, 0) else Vector3.new(0, 1, 0)
	local right = look:Cross(up).Unit
	local up2 = right:Cross(look)
	return CFrame.new(from.X, from.Y, from.Z, right.X, up2.X, -look.X, right.Y, up2.Y, -look.Y, right.Z, up2.Z, -look.Z)
end

-- ── shape helpers ──────────────────────────────────────────────────────────
-- a disc (a short cylinder) whose axis runs along `at`'s Z (default), Y or X
local function disc(ctx, limb, name: string, at: CFrame, d: number, thick: number, color: Color3, mat: Enum.Material?, axis: string?): BasePart
	local rot = if axis == "y" then CFrame.Angles(0, 0, R90) elseif axis == "x" then CFrame.new() else CFrame.Angles(0, R90, 0)
	return ctx.piece(limb, name, Vector3.new(thick, d, d), at * rot, color, mat, "cyl")
end
-- a round rod along `at`'s Z (default), Y or X
local function rod(ctx, limb, name: string, at: CFrame, len: number, d: number, color: Color3, mat: Enum.Material?, axis: string?): BasePart
	return disc(ctx, limb, name, at, d, len, color, mat, axis)
end
-- a ring of n short bars around `at`'s X axis (in its Y-Z plane), from angle a0 to a1 (degrees;
-- 0 is -Z, 90 is +Y)
local function hoop(ctx, limb, name: string, at: CFrame, r: number, thick: number, n: number, color: Color3, mat: Enum.Material?, a0: number?, a1: number?): { BasePart }
	local from, to = a0 or 0, a1 or 360
	local span = math.rad(to - from)
	local seg = math.abs(span) * r / n * 1.12
	local out = {}
	for k = 0, n - 1 do
		local a = math.rad(from) + span * (k + 0.5) / n
		table.insert(out, ctx.piece(limb, name .. k, Vector3.new(thick, seg, thick), at * CFrame.Angles(a, 0, 0) * CFrame.new(0, 0, -r), color, mat))
	end
	return out
end
-- a symmetric point running out along `base`'s -Z: two wedges back to back (width along Y)
local function point2(ctx, limb, name: string, base: CFrame, width: number, len: number, thick: number, color: Color3, mat: Enum.Material?)
	ctx.piece(limb, name .. "A", Vector3.new(thick, width / 2, len), base * CFrame.new(0, width / 4, -len / 2), color, mat, "wedge")
	ctx.piece(limb, name .. "B", Vector3.new(thick, width / 2, len), base * CFrame.new(0, -width / 4, -len / 2) * CFrame.Angles(0, 0, math.pi), color, mat, "wedge")
end
-- the same point standing up along `base`'s +Y (width along Z)
local function spike(ctx, limb, name: string, base: CFrame, width: number, len: number, thick: number, color: Color3, mat: Enum.Material?)
	point2(ctx, limb, name, base * CFrame.Angles(R90, 0, 0), width, len, thick, color, mat)
end
-- wrap bands along a grip (z from z0 to z1 in `at`'s space)
local function wraps(ctx, limb, at: CFrame, z0: number, z1: number, n: number, d: number, color: Color3)
	for k = 1, n do
		disc(ctx, limb, "Wrap" .. k, at * CFrame.new(0, 0, z0 + (z1 - z0) * k / (n + 1)), d, 0.06, color, FABRIC)
	end
end
local function darker(c: Color3, t: number): Color3
	return c:Lerp(Color3.new(0, 0, 0), t)
end

-- ── blades ─────────────────────────────────────────────────────────────────
-- a straight blade along -Z from the hand: grip, guard, body, a wedge for the point
local function blade(ctx, limb, at: CFrame, len: number, width: number, opts: any?)
	opts = opts or {}
	local P = ctx.piece
	local c = ctx.colors
	local thick = opts.thick or 0.09
	local gripLen = opts.grip or 0.75
	P(limb, "Grip", Vector3.new(0.2, 0.2, gripLen), at * CFrame.new(0, 0, gripLen / 2 - 0.15), c.grip, FABRIC)
	P(limb, "Pommel", Vector3.new(0.28, 0.28, 0.28), at * CFrame.new(0, 0, gripLen - 0.1), c.trim, METAL, "ball")
	if opts.wrap then
		wraps(ctx, limb, at, -0.1, gripLen - 0.25, opts.wrap, 0.23, darker(c.grip, 0.35))
	end
	if not opts.noGuard then
		P(limb, "Guard", Vector3.new(opts.guard or (width * 2.6 + 0.25), 0.16, 0.18), at * CFrame.new(0, 0, -0.25), c.trim, METAL)
	end
	local bodyLen = len * 0.86
	local body = at * CFrame.new(0, 0, -0.32 - bodyLen / 2)
	if opts.curve and opts.curve > 0 then
		-- a curved blade: three segments, each turned a little more
		local seg = bodyLen / 3
		local cf = at * CFrame.new(0, 0, -0.32)
		local first
		for k = 1, 3 do
			cf = cf * CFrame.Angles(math.rad(opts.curve * 9), 0, 0)
			local b = P(limb, "Blade" .. k, Vector3.new(thick, width, seg + 0.05), cf * CFrame.new(0, 0, -seg / 2), c.blade, METAL)
			first = first or b
			if ctx.edge then
				P(limb, "Edge" .. k, Vector3.new(thick * 0.6, 0.05, seg), cf * CFrame.new(0, -width / 2, -seg / 2), c.glow, NEON)
			end
			cf = cf * CFrame.new(0, 0, -seg)
		end
		local tipCf = cf * CFrame.Angles(math.rad(opts.curve * 9), 0, 0)
		P(limb, "Point", Vector3.new(thick, width, len * 0.16), tipCf * CFrame.new(0, 0, -len * 0.08), c.blade, METAL, "wedge")
		if opts.gem then
			P(limb, "Gem", Vector3.new(0.24, 0.24, 0.24), at * CFrame.new(0, 0, -0.25), c.glow, NEON, "ball")
		end
		ctx.trail(limb, first, tipCf * CFrame.new(0, -width * 0.3, -len * 0.14), at * CFrame.new(0, 0, -0.45))
		ctx.focus(first)
		return
	end
	local main = P(limb, "Blade", Vector3.new(thick, width, bodyLen), body, c.blade, METAL)
	if opts.role then
		ctx.role(main, opts.role)
	end
	-- the point: a wedge (its tall end against the blade, its slope running out to the tip)
	P(limb, "Point", Vector3.new(thick, width, len * 0.18), at * CFrame.new(0, 0, -0.32 - bodyLen - len * 0.09), c.blade, METAL, "wedge")
	if opts.fuller or ctx.edge then
		P(limb, "Fuller", Vector3.new(thick + 0.02, width * 0.18, bodyLen * 0.85), body, c.glow, NEON)
	end
	if opts.notched then
		for k = 1, 3 do
			P(limb, "Notch" .. k, Vector3.new(thick + 0.02, 0.12, 0.18), body * CFrame.new(0, width / 2, -bodyLen / 2 + k * bodyLen / 4), c.grip, METAL)
		end
	end
	if opts.gem then
		P(limb, "Gem", Vector3.new(0.24, 0.24, 0.24), at * CFrame.new(0, 0, -0.25), c.glow, NEON, "ball")
	end
	if opts.wave then
		for k = 1, 4 do
			P(limb, "Wave" .. k, Vector3.new(thick + 0.01, 0.1, 0.12), body * CFrame.new(0, (if k % 2 == 0 then 1 else -1) * width * 0.45, -bodyLen / 2 + k * bodyLen / 5), c.glow, NEON)
		end
	end
	ctx.trail(limb, main, at * CFrame.new(0, 0, -0.32 - bodyLen - len * 0.14), at * CFrame.new(0, 0, -0.45))
	ctx.focus(main)
end

local BUILD = {}

BUILD.dagger = function(ctx, w)
	blade(ctx, ctx.right, FORWARD, (w.p.len or 1) * 1.1, 0.2, { grip = 0.55, guard = 0.5, curve = w.p.curve, wave = w.p.wave, wrap = 2 })
end
BUILD.daggers = function(ctx, w)
	blade(ctx, ctx.right, FORWARD, (w.p.len or 1) * 1.1, 0.18, { grip = 0.5, guard = 0.45, wrap = 2 })
	blade(ctx, ctx.left, FORWARD, (w.p.len or 1) * 1.1, 0.18, { grip = 0.5, guard = 0.45, wrap = 2 })
end
BUILD.sword = function(ctx, w)
	local width = w.p.width or 0.32
	blade(ctx, ctx.right, FORWARD, w.p.len or 3, width, { fuller = w.p.fuller, gem = w.p.gem, notched = w.p.notched, curve = w.p.curve, wrap = 2, role = if width >= 0.45 and not w.p.curve then "blade_wide" else nil })
end
BUILD.katana = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	blade(ctx, ctx.right, FORWARD, w.p.len or 3.2, 0.2, { curve = 0.35, noGuard = true, grip = 1, wrap = 3 })
	disc(ctx, ctx.right, "Tsuba", FORWARD * CFrame.new(0, 0, -0.26), 0.5, 0.06, c.trim, METAL)
	P(ctx.right, "Habaki", Vector3.new(0.13, 0.26, 0.12), FORWARD * CFrame.new(0, 0, -0.34), c.trim, METAL)
end
-- the odachi: a katana's big sibling, a long grip for two hands, held nearer level
BUILD.odachi = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local at = LEVEL * CFrame.new(0, 0, 0.3)
	blade(ctx, ctx.right, at, w.p.len or 4.6, 0.24, { curve = 0.32, noGuard = true, grip = 1.6, wrap = 5 })
	disc(ctx, ctx.right, "Tsuba", at * CFrame.new(0, 0, -0.26), 0.62, 0.07, c.trim, METAL)
	P(ctx.right, "Habaki", Vector3.new(0.14, 0.3, 0.16), at * CFrame.new(0, 0, -0.35), c.trim, METAL)
	P(ctx.right, "Cord", Vector3.new(0.05, 0.5, 0.05), at * CFrame.new(0, -0.3, 1.42), c.glow, FABRIC)
	P(ctx.right, "Tassel", Vector3.new(0.16, 0.16, 0.16), at * CFrame.new(0, -0.58, 1.42), c.glow, NEON, "ball")
	if w.p.gem then
		P(ctx.right, "Gem", Vector3.new(0.2, 0.2, 0.2), at * CFrame.new(0, 0.24, -0.26), c.glow, NEON, "ball")
	end
end
-- twin swords: a matched pair, one in each hand
BUILD.twinswords = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	for _, limb in { ctx.right, ctx.left } do
		blade(ctx, limb, FORWARD, w.p.len or 2.6, 0.26, { guard = 0.7, grip = 0.75, curve = w.p.curve, fuller = w.p.fuller, gem = w.p.gem, wrap = 2 })
		P(limb, "Ribbon", Vector3.new(0.04, 0.55, 0.1), FORWARD * CFrame.new(0, -0.3, 0.68), c.glow, FABRIC)
	end
end
BUILD.greatsword = function(ctx, w)
	blade(ctx, ctx.right, FORWARD, w.p.len or 4.4, w.p.width or 0.62, { thick = 0.14, grip = 1.2, fuller = true, gem = w.p.gem, wrap = 3, role = "blade_wide" })
end
BUILD.cleaver = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len, wid = w.p.len or 2, w.p.width or 0.9
	P(ctx.right, "Grip", Vector3.new(0.22, 0.22, 0.9), FORWARD * CFrame.new(0, 0, 0.3), c.grip, FABRIC)
	local main = P(ctx.right, "Blade", Vector3.new(0.12, wid, len), FORWARD * CFrame.new(0, -wid / 2 + 0.1, -len / 2 - 0.1), c.blade, METAL)
	P(ctx.right, "Spine", Vector3.new(0.16, 0.12, len), FORWARD * CFrame.new(0, 0.12, -len / 2 - 0.1), c.trim, METAL)
	P(ctx.right, "Edge", Vector3.new(0.13, 0.06, len), FORWARD * CFrame.new(0, -wid + 0.13, -len / 2 - 0.1), c.glow, NEON)
	P(ctx.right, "Hole", Vector3.new(0.14, 0.22, 0.22), FORWARD * CFrame.new(0, -0.15, -len + 0.1), c.grip, METAL, "cyl")
	ctx.trail(ctx.right, main, FORWARD * CFrame.new(0, -wid + 0.13, -len), FORWARD * CFrame.new(0, -wid + 0.13, -0.2))
	ctx.focus(main)
end
BUILD.rapier = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	blade(ctx, ctx.right, FORWARD, w.p.len or 3.6, 0.1, { thick = 0.08, guard = 0.3 })
	-- the swept hilt: a cup and a knuckle bow
	disc(ctx, ctx.right, "Cup", FORWARD * CFrame.new(0, 0, -0.2), 0.55, 0.12, c.trim, METAL)
	P(ctx.right, "Bow", Vector3.new(0.06, 0.06, 0.7), FORWARD * CFrame.new(0.22, 0, 0.1), c.trim, METAL)
	P(ctx.right, "Quillon", Vector3.new(0.06, 0.5, 0.06), FORWARD * CFrame.new(0, 0, -0.26) * CFrame.Angles(math.rad(25), 0, 0), c.trim, METAL)
end

-- ── pole weapons (held upright: the shaft runs along Y through the hand) ───
local function shaft(ctx, limb, len: number, below: number?)
	local c = ctx.colors
	ctx.piece(limb, "Shaft", Vector3.new(0.17, len, 0.17), UPRIGHT * CFrame.new(0, len / 2 - (below or 1), 0), c.grip, WOOD)
	ctx.piece(limb, "Cap", Vector3.new(0.22, 0.22, 0.22), UPRIGHT * CFrame.new(0, -(below or 1), 0), c.trim, METAL, "ball")
	return UPRIGHT * CFrame.new(0, len - (below or 1), 0) -- the top of the shaft
end
-- a leaf-shaped spearhead standing on `top` (a socket for the kit's spear_leaf; parts draw a
-- diamond until then)
local function leafHead(ctx, limb, top: CFrame, width: number, h: number)
	local c = ctx.colors
	local base = 0.2
	local mid = top * CFrame.new(0, base + h * 0.28, 0)
	local leaf = ctx.socket(limb, "Leaf", Vector3.new(0.09, h, width), top * CFrame.new(0, base + h / 2, 0), "spear_leaf", c.blade, METAL)
	spike(ctx, limb, "LeafTip", mid, width, h * 0.72, 0.08, c.blade, METAL)
	point2(ctx, limb, "LeafBase", mid * CFrame.Angles(-R90, 0, 0), width, h * 0.28, 0.08, c.blade, METAL)
	ctx.cover = nil
	ctx.piece(limb, "Socket", Vector3.new(0.2, 0.32, 0.2), top * CFrame.new(0, 0.1, 0), c.trim, METAL)
	ctx.piece(limb, "Rib", Vector3.new(0.1, h * 0.75, 0.05), top * CFrame.new(0, base + h * 0.42, 0), c.glow, NEON)
	ctx.trail(limb, leaf, top * CFrame.new(0, base + h, 0), top * CFrame.new(0, base, 0))
	ctx.focus(leaf)
	return leaf
end
BUILD.spear = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local top = shaft(ctx, ctx.right, w.p.len or 6)
	if w.p.lance then
		local first
		for k = 0, 3 do
			local r = 0.7 - k * 0.15
			local p = rod(ctx, ctx.right, "Cone" .. k, top * CFrame.new(0, 0.25 + k * 0.45, 0), 0.5, r, c.blade, METAL, "y")
			first = first or p
		end
		disc(ctx, ctx.right, "Vamplate", top, 1.1, 0.12, c.trim, METAL, "y")
		ctx.trail(ctx.right, first, top * CFrame.new(0, 2, 0), top * CFrame.new(0, 0.2, 0))
		ctx.focus(first)
		return
	end
	leafHead(ctx, ctx.right, top, 0.4, 1.05)
	P(ctx.right, "Tassel", Vector3.new(0.26, 0.26, 0.26), top * CFrame.new(0, -0.15, 0), c.glow, NEON, "ball")
	if w.p.prongs then
		for _, s in { -1, 1 } do
			P(ctx.right, "Prong", Vector3.new(0.07, 0.6, 0.12), top * CFrame.new(0, 0.55, s * 0.36) * CFrame.Angles(math.rad(s * 16), 0, 0), c.glow, NEON)
		end
	end
end
-- the trident: three prongs on a crossbar (a socket for the kit's trident_head)
BUILD.trident = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local top = shaft(ctx, limb, w.p.len or 5.8, 1.1)
	disc(ctx, limb, "Ferrule", top * CFrame.new(0, -0.3, 0), 0.24, 0.12, c.trim, METAL, "y")
	local fork = ctx.socket(limb, "Fork", Vector3.new(0.12, 1.55, 1.1), top * CFrame.new(0, 0.95, 0), "trident_head", c.blade, METAL)
	P(limb, "Neck", Vector3.new(0.14, 0.4, 0.16), top * CFrame.new(0, 0.38, 0), c.blade, METAL)
	P(limb, "Crossbar", Vector3.new(0.12, 0.16, 1.02), top * CFrame.new(0, 0.58, 0), c.blade, METAL)
	P(limb, "Prong", Vector3.new(0.1, 0.92, 0.13), top * CFrame.new(0, 1.07, 0), c.blade, METAL)
	spike(ctx, limb, "ProngTip", top * CFrame.new(0, 1.52, 0), 0.24, 0.2, 0.1, c.blade, METAL)
	for _, s in { -1, 1 } do
		P(limb, "SideProng", Vector3.new(0.1, 0.72, 0.12), top * CFrame.new(0, 0.97, s * 0.45), c.blade, METAL)
		spike(ctx, limb, "SideTip", top * CFrame.new(0, 1.32, s * 0.45), 0.2, 0.18, 0.1, c.blade, METAL)
		if w.p.barbs then
			P(limb, "Barb", Vector3.new(0.08, 0.22, 0.1), top * CFrame.new(0, 1.12, s * 0.54) * CFrame.Angles(math.rad(-s * 35), 0, 0), c.blade, METAL)
		end
	end
	ctx.cover = nil
	if ctx.edge then
		P(limb, "ProngGlow", Vector3.new(0.12, 0.7, 0.04), top * CFrame.new(0, 1.05, 0), c.glow, NEON)
		for _, s in { -1, 1 } do
			P(limb, "SideGlow", Vector3.new(0.12, 0.5, 0.04), top * CFrame.new(0, 0.97, s * 0.45), c.glow, NEON)
		end
	end
	P(limb, "Pearl", Vector3.new(0.22, 0.22, 0.22), top * CFrame.new(0, 0.58, 0), c.glow, NEON, "ball")
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.18, 0.18, 0.18), top * CFrame.new(0, 0.2, 0), c.glow, NEON, "ball")
	end
	ctx.trail(limb, fork, top * CFrame.new(0, 1.65, 0), top * CFrame.new(0, 0.4, 0))
	ctx.focus(fork)
end
BUILD.halberd = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local top = shaft(ctx, ctx.right, w.p.len or 6.4)
	spike(ctx, ctx.right, "Spike", top * CFrame.new(0, 0.25, 0), 0.26, 0.9, 0.08, c.blade, METAL)
	local axe = P(ctx.right, "Axe", Vector3.new(0.09, 0.95, 0.9), top * CFrame.new(0, -0.2, -0.5), c.blade, METAL)
	P(ctx.right, "AxeEdge", Vector3.new(0.1, 1, 0.08), top * CFrame.new(0, -0.2, -0.96), c.glow, NEON)
	P(ctx.right, "Hook", Vector3.new(0.08, 0.3, 0.45), top * CFrame.new(0, -0.15, 0.3), c.trim, METAL, "wedge")
	P(ctx.right, "Langet", Vector3.new(0.2, 0.7, 0.2), top * CFrame.new(0, -0.55, 0), c.trim, METAL)
	ctx.trail(ctx.right, axe, top * CFrame.new(0, 0.3, -0.96), top * CFrame.new(0, -0.7, -0.96))
	ctx.focus(axe)
end
-- the glaive: one broad, gently curved blade on a pole (the kit's blade_curved, set along the
-- shaft: the part's -Z runs up the pole and its edge, -Y, faces forward)
BUILD.glaive = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local top = shaft(ctx, limb, w.p.len or 6, 1.1)
	local bl = 1.8
	local bcf = top * CFrame.new(0, 0.2 + bl / 2, -0.12) * CFrame.Angles(R90, 0, 0)
	local main = P(limb, "Blade", Vector3.new(0.1, 0.6, bl), bcf, c.blade, METAL)
	ctx.role(main, "blade_curved")
	P(limb, "Point", Vector3.new(0.1, 0.6, 0.55), bcf * CFrame.new(0, 0, -bl / 2 - 0.27), c.blade, METAL, "wedge")
	P(limb, "Edge", Vector3.new(0.12, 0.06, bl), bcf * CFrame.new(0, -0.3, 0), c.glow, NEON)
	P(limb, "Collar", Vector3.new(0.26, 0.3, 0.3), top * CFrame.new(0, 0.12, 0), c.trim, METAL)
	disc(ctx, limb, "Ring", top * CFrame.new(0, -0.15, 0), 0.26, 0.08, c.trim, METAL, "y")
	if w.p.hook then
		P(limb, "Hook", Vector3.new(0.09, 0.36, 0.42), bcf * CFrame.new(0, 0.45, 0.45), c.trim, METAL, "wedge")
	end
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.2, 0.2, 0.2), bcf * CFrame.new(0, 0.05, bl / 2 - 0.15), c.glow, NEON, "ball")
	end
	P(limb, "Tassel", Vector3.new(0.05, 0.55, 0.05), top * CFrame.new(0, -0.45, 0.12), c.glow, FABRIC)
	ctx.trail(limb, main, top * CFrame.new(0, 0.2 + bl + 0.4, -0.3), top * CFrame.new(0, 0.3, -0.3))
	ctx.focus(main)
end
-- the lance: a long cone behind a round vamplate, a pennant near the point
BUILD.lance = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local len = w.p.len or 6.4
	P(limb, "Grip", Vector3.new(0.22, 1.3, 0.22), UPRIGHT * CFrame.new(0, -0.1, 0), c.grip, LEATHER)
	P(limb, "Pommel", Vector3.new(0.34, 0.34, 0.34), UPRIGHT * CFrame.new(0, -0.8, 0), c.trim, METAL, "ball")
	disc(ctx, limb, "Vamplate", UPRIGHT * CFrame.new(0, 0.62, 0), 1.35, 0.14, c.trim, METAL, "y")
	disc(ctx, limb, "Vamplate2", UPRIGHT * CFrame.new(0, 0.78, 0), 0.95, 0.2, c.blade, METAL, "y")
	local cone = len - 1.6
	local n = 6
	local first
	for k = 0, n - 1 do
		local d = 0.62 - k * 0.085
		local h = cone / n
		local p = rod(ctx, limb, "Cone" .. k, UPRIGHT * CFrame.new(0, 0.88 + h * (k + 0.5), 0), h + 0.02, d, c.blade, METAL, "y")
		first = first or p
		if ctx.edge and k % 2 == 1 then
			disc(ctx, limb, "Band" .. k, UPRIGHT * CFrame.new(0, 0.88 + h * k, 0), d + 0.06, 0.06, c.glow, NEON, "y")
		end
	end
	local tipBase = UPRIGHT * CFrame.new(0, 0.88 + cone, 0)
	spike(ctx, limb, "Tip", tipBase, 0.16, 0.5, 0.16, c.blade, METAL)
	P(limb, "Pennant", Vector3.new(0.03, 0.42, 0.8), UPRIGHT * CFrame.new(0, 0.88 + cone * 0.72, 0.5), c.trim, FABRIC)
	P(limb, "PennantTail", Vector3.new(0.03, 0.42, 0.4), UPRIGHT * CFrame.new(0, 0.88 + cone * 0.72, 1.1), c.trim, FABRIC, "wedge")
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.24, 0.24, 0.24), UPRIGHT * CFrame.new(0, 0.78, -0.45), c.glow, NEON, "ball")
	end
	ctx.trail(limb, first, tipBase * CFrame.new(0, 0.4, 0), UPRIGHT * CFrame.new(0, 1.2, 0))
	ctx.focus(first)
end
BUILD.scythe = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local top = shaft(ctx, ctx.right, w.p.len or 5.2, 1.4)
	-- the crescent: four segments sweeping forward and down
	local cf = top
	local first
	for k = 1, 4 do
		cf = cf * CFrame.Angles(math.rad(-22), 0, 0)
		local s = P(ctx.right, "Crescent" .. k, Vector3.new(0.08, 0.42 - k * 0.05, 0.75), cf * CFrame.new(0, 0, -0.38), c.blade, METAL)
		first = first or s
		P(ctx.right, "CrescentEdge" .. k, Vector3.new(0.09, 0.05, 0.75), cf * CFrame.new(0, -(0.42 - k * 0.05) / 2, -0.38), c.glow, NEON)
		cf = cf * CFrame.new(0, 0, -0.72)
	end
	P(ctx.right, "Collar", Vector3.new(0.26, 0.3, 0.26), top, c.trim, METAL)
	ctx.trail(ctx.right, first, cf, top * CFrame.new(0, 0, -0.4))
	ctx.focus(first)
end

-- ── axes and hammers ───────────────────────────────────────────────────────
-- a double-bitted head (a socket for the kit's axe_double: thin X, the bits at both Z ends)
local function doubleHead(ctx, limb, head: CFrame, s: number)
	local P, c = ctx.piece, ctx.colors
	local sock = ctx.socket(limb, "AxeHead", Vector3.new(0.14, 1.7 * s, 2.5 * s), head, "axe_double", c.blade, METAL)
	for _, side in { -1, 1 } do
		local flip = if side > 0 then CFrame.new() else CFrame.Angles(0, math.pi, 0)
		local flipDown = if side > 0 then CFrame.Angles(0, 0, math.pi) else CFrame.Angles(math.pi, 0, 0)
		P(limb, "Cheek", Vector3.new(0.12, 0.5 * s, 0.5 * s), head * CFrame.new(0, 0, side * 0.42 * s), c.blade, METAL)
		P(limb, "Wing", Vector3.new(0.1, 1.15 * s, 0.5 * s), head * CFrame.new(0, 0, side * 0.9 * s), c.blade, METAL)
		P(limb, "FlareUp", Vector3.new(0.1, 0.27 * s, 0.5 * s), head * CFrame.new(0, 0.71 * s, side * 0.9 * s) * flip, c.blade, METAL, "wedge")
		P(limb, "FlareDown", Vector3.new(0.1, 0.27 * s, 0.5 * s), head * CFrame.new(0, -0.71 * s, side * 0.9 * s) * flipDown, c.blade, METAL, "wedge")
		P(limb, "WingEdge", Vector3.new(0.12, 1.62 * s, 0.07), head * CFrame.new(0, 0, side * 1.17 * s), c.glow, NEON)
	end
	spike(ctx, limb, "Crown", head * CFrame.new(0, 0.25 * s, 0), 0.24, 0.5 * s, 0.12, c.blade, METAL)
	ctx.cover = nil
	P(limb, "Eye", Vector3.new(0.3, 0.6 * s, 0.38 * s), head, c.trim, METAL)
	return sock
end
BUILD.axe = function(ctx, w, limb, at)
	local P, c = ctx.piece, ctx.colors
	limb = limb or ctx.right
	at = at or UPRIGHT
	local len = w.p.len or 2.6
	P(limb, "Haft", Vector3.new(0.18, len, 0.18), at * CFrame.new(0, len / 2 - 0.5, 0), c.grip, WOOD)
	local head = at * CFrame.new(0, len - 0.8, 0)
	if w.p.double then
		local sock = doubleHead(ctx, limb, head, 0.7)
		if w.p.gem then
			P(limb, "Gem", Vector3.new(0.2, 0.2, 0.2), head * CFrame.new(0.16, 0, 0), c.glow, NEON, "ball")
		end
		ctx.trail(limb, sock, head * CFrame.new(0, 0.5, -0.85), head * CFrame.new(0, -0.5, -0.85))
		ctx.focus(sock)
		return
	end
	local bit = P(limb, "Bit", Vector3.new(0.1, 0.8, 0.7), head * CFrame.new(0, 0, -0.45), c.blade, METAL)
	P(limb, "BitEdge", Vector3.new(0.11, 0.85, 0.07), head * CFrame.new(0, 0, -0.82), c.glow, NEON)
	P(limb, "Beard", Vector3.new(0.1, 0.26, 0.45), head * CFrame.new(0, -0.5, -0.55) * CFrame.Angles(0, 0, math.pi), c.blade, METAL, "wedge")
	P(limb, "Eye", Vector3.new(0.26, 0.3, 0.3), head, c.trim, METAL)
	P(limb, "Poll", Vector3.new(0.2, 0.24, 0.2), head * CFrame.new(0, 0, 0.22), c.trim, METAL)
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.2, 0.2, 0.2), head * CFrame.new(0.14, 0, 0), c.glow, NEON, "ball")
	end
	ctx.trail(limb, bit, head * CFrame.new(0, 0.42, -0.82), head * CFrame.new(0, -0.42, -0.82))
	ctx.focus(bit)
end
BUILD.axes = function(ctx, w)
	BUILD.axe(ctx, w, ctx.right, UPRIGHT)
	BUILD.axe(ctx, w, ctx.left, UPRIGHT)
end
-- the greataxe: a long haft for two hands and a great double head
BUILD.greataxe = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local len = w.p.len or 4.4
	P(limb, "Haft", Vector3.new(0.2, len, 0.2), UPRIGHT * CFrame.new(0, len / 2 - 1.2, 0), c.grip, WOOD)
	for k = 0, 2 do
		disc(ctx, limb, "Wrap" .. k, UPRIGHT * CFrame.new(0, -0.6 + k * 0.45, 0), 0.25, 0.08, darker(c.grip, 0.4), LEATHER, "y")
	end
	spike(ctx, limb, "Butt", UPRIGHT * CFrame.new(0, -1.2, 0) * CFrame.Angles(math.pi, 0, 0), 0.18, 0.35, 0.18, c.trim, METAL)
	local head = UPRIGHT * CFrame.new(0, len - 1.75, 0)
	local sock = doubleHead(ctx, limb, head, 1)
	P(limb, "Langet", Vector3.new(0.24, 0.8, 0.08), head * CFrame.new(0, -0.65, 0), c.trim, METAL)
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.26, 0.26, 0.26), head * CFrame.new(0.17, 0, 0), c.glow, NEON, "ball")
	end
	ctx.trail(limb, sock, head * CFrame.new(0, 0.75, -1.2), head * CFrame.new(0, -0.75, -1.2))
	ctx.focus(sock)
end
BUILD.hammer = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 3.4
	local big = if w.p.big then 1.35 else 1
	P(ctx.right, "Haft", Vector3.new(0.2, len, 0.2), UPRIGHT * CFrame.new(0, len / 2 - 0.6, 0), c.grip, WOOD)
	local head = UPRIGHT * CFrame.new(0, len - 0.7, 0)
	local h = P(ctx.right, "Head", Vector3.new(0.8 * big, 0.8 * big, 1.5 * big), head, c.blade, METAL)
	for _, z in { -0.62, 0.62 } do
		P(ctx.right, "Band", Vector3.new(0.84 * big, 0.84 * big, 0.1), head * CFrame.new(0, 0, z * big), c.trim, METAL)
	end
	P(ctx.right, "Face", Vector3.new(0.6 * big, 0.6 * big, 0.06), head * CFrame.new(0, 0, -0.77 * big), c.glow, NEON)
	if w.p.gem then
		P(ctx.right, "Gem", Vector3.new(0.3, 0.3, 0.3), head * CFrame.new(0.42 * big, 0, 0), c.glow, NEON, "ball")
	end
	ctx.trail(ctx.right, h, head * CFrame.new(0, 0.4 * big, -0.75 * big), head * CFrame.new(0, -0.4 * big, -0.75 * big))
	ctx.focus(h)
end
-- the warhammer: a two-handed haft, a heavy face, a spike behind and one on top
BUILD.warhammer = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local len = w.p.len or 4.4
	P(limb, "Haft", Vector3.new(0.22, len, 0.22), UPRIGHT * CFrame.new(0, len / 2 - 1.2, 0), c.grip, WOOD)
	for k = 0, 3 do
		disc(ctx, limb, "Wrap" .. k, UPRIGHT * CFrame.new(0, -0.8 + k * 0.32, 0), 0.27, 0.07, darker(c.grip, 0.4), LEATHER, "y")
	end
	P(limb, "Pommel", Vector3.new(0.34, 0.34, 0.34), UPRIGHT * CFrame.new(0, -1.25, 0), c.trim, METAL, "ball")
	local head = UPRIGHT * CFrame.new(0, len - 1.55, 0)
	local h = P(limb, "Head", Vector3.new(0.85, 0.85, 1.25), head * CFrame.new(0, 0, -0.2), c.blade, METAL)
	disc(ctx, limb, "Face", head * CFrame.new(0, 0, -0.86), 0.8, 0.12, c.trim, METAL)
	disc(ctx, limb, "FaceGlow", head * CFrame.new(0, 0, -0.93), 0.56, 0.04, c.glow, NEON)
	P(limb, "Band", Vector3.new(0.9, 0.9, 0.12), head * CFrame.new(0, 0, -0.2), c.trim, METAL)
	point2(ctx, limb, "Beak", head * CFrame.new(0, 0, 0.42) * CFrame.Angles(0, math.pi, 0), 0.5, 0.95, 0.3, c.blade, METAL)
	spike(ctx, limb, "Crown", head * CFrame.new(0, 0.42, -0.2), 0.3, 0.45, 0.3, c.trim, METAL)
	for _, s in { -1, 1 } do
		P(limb, "Langet", Vector3.new(0.06, 1, 0.26), head * CFrame.new(s * 0.13, -0.85, 0), c.trim, METAL)
	end
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.3, 0.3, 0.3), head * CFrame.new(0.44, 0, -0.2), c.glow, NEON, "ball")
	end
	ctx.trail(limb, h, head * CFrame.new(0, 0.45, -0.9), head * CFrame.new(0, -0.45, -0.9))
	ctx.focus(h)
end
-- a flanged mace head (a socket for the kit's mace_flanged: flanges around Y)
local function flangedHead(ctx, limb, head: CFrame, s: number)
	local P, c = ctx.piece, ctx.colors
	local sock = ctx.socket(limb, "Flanges", Vector3.new(0.95 * s, 1 * s, 0.95 * s), head, "mace_flanged", c.blade, METAL)
	rod(ctx, limb, "Core", head, 0.85 * s, 0.4 * s, c.blade, METAL, "y")
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		P(limb, "Flange" .. k, Vector3.new(0.07, 0.82 * s, 0.3 * s), head * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -0.32 * s), c.blade, METAL)
	end
	ctx.cover = nil
	if ctx.edge then
		for k = 0, 5 do
			local a = k / 6 * math.pi * 2
			ctx.piece(limb, "FlangeEdge" .. k, Vector3.new(0.08, 0.7 * s, 0.04), head * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -0.475 * s), c.glow, NEON)
		end
	end
	spike(ctx, limb, "Crown", head * CFrame.new(0, 0.5 * s, 0), 0.2, 0.3, 0.2, c.trim, METAL)
	disc(ctx, limb, "Collar", head * CFrame.new(0, -0.5 * s, 0), 0.32, 0.12, c.trim, METAL, "y")
	return sock
end
BUILD.mace = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 2.4
	P(ctx.right, "Haft", Vector3.new(0.18, len, 0.18), RAISED * CFrame.new(0, len / 2 - 0.5, 0), c.grip, WOOD)
	disc(ctx, ctx.right, "Wrap", RAISED * CFrame.new(0, -0.3, 0), 0.24, 0.3, darker(c.grip, 0.4), LEATHER, "y")
	local head = RAISED * CFrame.new(0, len - 0.4, 0)
	local core
	if w.p.flanged then
		core = flangedHead(ctx, ctx.right, head, 1)
		if w.p.gem then
			P(ctx.right, "Gem", Vector3.new(0.22, 0.22, 0.22), head * CFrame.new(0, 0.7, 0), c.glow, NEON, "ball")
		end
	else
		core = P(ctx.right, "Ball", Vector3.new(0.75, 0.75, 0.75), head, c.blade, METAL, "ball")
		local n = if w.p.spikes then 8 else 4
		for k = 0, n - 1 do
			local a = k / n * math.pi * 2
			P(ctx.right, "Spike" .. k, Vector3.new(0.12, 0.34, 0.18), head * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -0.42) * CFrame.Angles(math.rad(-90), 0, 0), c.trim, METAL, "wedge")
		end
		if w.p.spikes then
			P(ctx.right, "Crown", Vector3.new(0.14, 0.36, 0.14), head * CFrame.new(0, 0.45, 0), c.trim, METAL)
		end
	end
	ctx.trail(ctx.right, core, head * CFrame.new(0, 0.45, 0), head * CFrame.new(0, -0.45, 0))
	ctx.focus(core)
end
-- the flail: a handle, a hanging chain, a spiked ball resting near the ground
local function flailHead(ctx, limb, from: Vector3, drop: number, lean: number, w, s: number): BasePart
	local P, c = ctx.piece, ctx.colors
	local links = 6
	for k = 1, links do
		local pos = from + Vector3.new(0, -drop * k / (links + 1), -lean * k / (links + 1))
		disc(ctx, limb, "Link" .. k, CFrame.new(pos) * CFrame.Angles(0, if k % 2 == 0 then R90 else 0, 0), 0.2, 0.05, c.trim, METAL, "x")
	end
	local at = CFrame.new(from + Vector3.new(0, -drop, -lean))
	local ball = P(limb, "Ball", Vector3.new(0.72, 0.72, 0.72) * s, at, c.blade, METAL, "ball")
	if w.p.spikes then
		for k = 0, 5 do
			local a = k / 6 * math.pi * 2
			P(limb, "Spike" .. k, Vector3.new(0.1, 0.3, 0.16) * s, at * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -0.4 * s) * CFrame.Angles(math.rad(-90), 0, 0), c.trim, METAL, "wedge")
		end
		spike(ctx, limb, "SpikeTop", at * CFrame.new(0, 0.3 * s, 0), 0.16 * s, 0.3 * s, 0.16 * s, c.trim, METAL)
		spike(ctx, limb, "SpikeLow", at * CFrame.new(0, -0.3 * s, 0) * CFrame.Angles(math.pi, 0, 0), 0.16 * s, 0.3 * s, 0.16 * s, c.trim, METAL)
	end
	if ctx.edge or w.p.big then
		for k = 0, 2 do
			P(limb, "Crack" .. k, Vector3.new(0.05, 0.5, 0.05) * s, at * CFrame.Angles(k * 1.1, k * 2.1, k * 0.7) * CFrame.new(0, 0, -0.34 * s), c.glow, NEON)
		end
	end
	return ball
end
BUILD.flail = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	P(limb, "Handle", Vector3.new(0.2, 0.2, 1.3), FORWARD * CFrame.new(0, 0, -0.25), c.grip, WOOD)
	P(limb, "Pommel", Vector3.new(0.28, 0.28, 0.28), FORWARD * CFrame.new(0, 0, 0.45), c.trim, METAL, "ball")
	local capCf = FORWARD * CFrame.new(0, 0, -0.95)
	P(limb, "Cap", Vector3.new(0.26, 0.26, 0.26), capCf, c.trim, METAL)
	local from = capCf.Position
	local s = if w.p.big then 1.3 else 1
	local ball = flailHead(ctx, limb, from, 1.25, 0.25, w, s)
	if w.p.twin then
		flailHead(ctx, limb, from + Vector3.new(0.05, 0, 0.05), 0.95, -0.25, w, 0.8)
	end
	ctx.trail(limb, ball, CFrame.new(from + Vector3.new(0, -1.25, -0.25 - 0.4 * s)), CFrame.new(from + Vector3.new(0, -1.25, -0.25 + 0.4 * s)))
	ctx.focus(ball)
end

-- ── magic ──────────────────────────────────────────────────────────────────
local function orbTrail(ctx, limb, part: BasePart, at: CFrame, r: number)
	ctx.trail(limb, part, at * CFrame.new(0, r, 0), at * CFrame.new(0, -r, 0))
	ctx.focus(part)
end
BUILD.staff = function(ctx, w, limb)
	local P, c = ctx.piece, ctx.colors
	limb = limb or ctx.right
	local top = shaft(ctx, limb, w.p.len or 5, 1.2)
	local orb = P(limb, "Orb", Vector3.new(0.55, 0.55, 0.55), top * CFrame.new(0, 0.5, 0), c.glow, NEON, "ball")
	-- a crown of prongs holding the orb
	for k = 0, 3 do
		local a = k / 4 * math.pi * 2
		P(limb, "Prong" .. k, Vector3.new(0.08, 0.6, 0.08), top * CFrame.Angles(0, a, 0) * CFrame.new(0, 0.35, -0.22) * CFrame.Angles(math.rad(-18), 0, 0), c.trim, METAL)
	end
	if w.p.prongs then
		for _, s in { -1, 1 } do
			P(limb, "Horn", Vector3.new(0.08, 0.9, 0.16), top * CFrame.new(s * 0.35, 0.3, 0) * CFrame.Angles(0, 0, math.rad(-s * 24)), c.blade, METAL, "wedge")
		end
	end
	if w.p.rings then
		for k = 1, 3 do
			disc(ctx, limb, "Ring" .. k, top * CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(k * 50), math.rad(k * 35), 0), 0.95 + k * 0.18, 0.06, c.trim, NEON, "x").Transparency = 0.45
		end
	end
	orbTrail(ctx, limb, orb, top * CFrame.new(0, 0.5, 0), 0.35)
end
BUILD.rod = function(ctx, w)
	BUILD.staff(ctx, w)
end
BUILD.wand = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 1.6
	local wand = P(ctx.right, "Wand", Vector3.new(0.12, 0.12, len), FORWARD * CFrame.new(0, 0, -len / 2 + 0.3), c.blade, WOOD)
	P(ctx.right, "Band", Vector3.new(0.16, 0.16, 0.12), FORWARD * CFrame.new(0, 0, 0.05), c.trim, METAL)
	P(ctx.right, "Band2", Vector3.new(0.15, 0.15, 0.08), FORWARD * CFrame.new(0, 0, -len + 0.4), c.trim, METAL)
	local crystal = P(ctx.right, "Crystal", Vector3.new(0.18, 0.18, 0.4), FORWARD * CFrame.new(0, 0, -len + 0.1), c.glow, NEON)
	ctx.trail(ctx.right, wand, FORWARD * CFrame.new(0, 0, -len - 0.1), FORWARD * CFrame.new(0, 0, -len * 0.4))
	ctx.focus(crystal)
end
BUILD.orb = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local s = w.p.size or 0.8
	local at = HAND * CFrame.new(0, -0.6, -0.5)
	local orb = P(ctx.right, "Orb", Vector3.new(s, s, s), at, c.glow, NEON, "ball")
	orb.Transparency = 0.15
	P(ctx.right, "Shell", Vector3.new(s * 1.15, s * 1.15, s * 1.15), at, c.blade, GLASS, "ball").Transparency = 0.6
	disc(ctx, ctx.right, "Halo", at * CFrame.Angles(0, 0, math.rad(70)), s * 1.6, 0.05, c.trim, NEON, "x").Transparency = 0.3
	orbTrail(ctx, ctx.right, orb, at, s * 0.6)
end
-- the crystal focus: a crystal core in a gyroscope cage, floating under the hand (a socket for
-- the kit's orb_cage)
BUILD.crystal = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local s = w.p.size or 0.85
	local at = HAND * CFrame.new(0, -0.95, -0.55)
	local cage = ctx.socket(limb, "Cage", Vector3.new(s * 1.5, s * 1.5, s * 1.5), at, "orb_cage", c.trim, METAL, "ball")
	hoop(ctx, limb, "Band", at, s * 0.72, 0.07, 10, c.trim, METAL)
	hoop(ctx, limb, "BandB", at * CFrame.Angles(0, R90, 0), s * 0.72, 0.07, 10, c.trim, METAL)
	ctx.cover = nil
	local core = P(limb, "Core", Vector3.new(s * 0.5, s * 0.5, s * 0.5), at * CFrame.Angles(math.rad(45), 0, math.rad(45)), c.glow, NEON)
	P(limb, "Crystal", Vector3.new(s * 0.3, s * 0.85, s * 0.3), at, c.blade, GLASS).Transparency = 0.25
	P(limb, "Hook", Vector3.new(0.07, 0.45, 0.07), at * CFrame.new(0, s * 0.75 + 0.2, 0), c.trim, METAL)
	disc(ctx, limb, "Loop", at * CFrame.new(0, s * 0.75 + 0.45, 0), 0.22, 0.05, c.trim, METAL, "x")
	if w.p.rings then
		hoop(ctx, limb, "Orbit", at * CFrame.Angles(0, math.rad(45), math.rad(20)), s * 1.05, 0.05, 12, c.glow, NEON)
	end
	ctx.trail(limb, cage, at * CFrame.new(0, s * 0.6, 0), at * CFrame.new(0, -s * 0.6, 0))
	ctx.focus(core)
end
BUILD.tome = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local s = w.p.size or 1
	local at = HAND * CFrame.new(0, -0.3, -0.45) * CFrame.Angles(math.rad(-60), 0, 0)
	local cover = P(ctx.right, "Cover", Vector3.new(0.9 * s, 1.15 * s, 0.32 * s), at, c.blade, LEATHER)
	P(ctx.right, "Pages", Vector3.new(0.82 * s, 1.07 * s, 0.26 * s), at * CFrame.new(0.05, 0, 0), Color3.fromRGB(238, 228, 200))
	local rune = P(ctx.right, "Rune", Vector3.new(0.4 * s, 0.4 * s, 0.04), at * CFrame.new(0, 0, -0.17 * s), c.glow, NEON)
	P(ctx.right, "Clasp", Vector3.new(0.1, 0.3 * s, 0.36 * s), at * CFrame.new(0.46 * s, 0, 0), c.trim, METAL)
	for _, y in { -0.5, 0.5 } do
		P(ctx.right, "Corner", Vector3.new(0.92 * s, 0.1, 0.34 * s), at * CFrame.new(0, y * s, 0), c.trim, METAL)
	end
	ctx.trail(ctx.right, cover, at * CFrame.new(0, 0.6 * s, 0), at * CFrame.new(0, -0.6 * s, 0))
	ctx.focus(rune)
end
-- the floating grimoire: open in the air in front of the hand, pages fanning, a sigil above it
BUILD.codex = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local s = (w.p.size or 1) * 1.3
	local at = HAND * CFrame.new(0, 0.5, -1.3) * CFrame.Angles(math.rad(30), 0, 0)
	local paper = Color3.fromRGB(240, 232, 208)
	local covers = {}
	for _, side in { -1, 1 } do
		local hinge = at * CFrame.Angles(0, 0, side * math.rad(-12))
		table.insert(covers, P(limb, "Cover", Vector3.new(0.6 * s, 0.06, 0.84 * s), hinge * CFrame.new(side * 0.3 * s, 0, 0), c.blade, LEATHER))
		P(limb, "Pages", Vector3.new(0.54 * s, 0.1, 0.76 * s), hinge * CFrame.new(side * 0.29 * s, 0.07, 0), paper)
		for k = 1, 2 do
			P(limb, "Line" .. k, Vector3.new(0.34 * s, 0.03, 0.04), hinge * CFrame.new(side * 0.29 * s, 0.13, -0.2 * s + k * 0.16 * s), c.glow, NEON)
		end
	end
	rod(ctx, limb, "Spine", at, 0.86 * s, 0.12, c.trim, METAL)
	for k = 1, 3 do
		P(limb, "Page" .. k, Vector3.new(0.5 * s, 0.015, 0.72 * s), at * CFrame.Angles(0, 0, math.rad(-35 + k * 22)) * CFrame.new(0.25 * s, 0.03, 0), paper)
	end
	local sigil = disc(ctx, limb, "Sigil", at * CFrame.new(0, 0.55, 0), 0.7 * s, 0.03, c.glow, NEON, "y")
	sigil.Transparency = 0.35
	for k = 0, 2 do
		local a = k / 3 * math.pi * 2
		P(limb, "Glyph" .. k, Vector3.new(0.1, 0.1, 0.1), at * CFrame.new(math.cos(a) * 0.65 * s, 0.35, math.sin(a) * 0.65 * s) * CFrame.Angles(a, a, 0), c.glow, NEON)
	end
	P(limb, "Ribbon", Vector3.new(0.06, 0.6, 0.02), at * CFrame.new(0, -0.3, 0.38 * s), c.trim, FABRIC)
	ctx.trail(limb, covers[1], at * CFrame.new(-0.6 * s, 0, 0), at * CFrame.new(0.6 * s, 0, 0))
	ctx.focus(sigil)
end
-- the rune tablet: a stone slab held up, runes burning in it
BUILD.tablet = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local s = if w.p.big then 1.2 else 1
	local at = HAND * CFrame.new(0, -0.55, -0.55) * CFrame.Angles(math.rad(-12), 0, 0)
	local slab = P(limb, "Slab", Vector3.new(0.95 * s, 1.15 * s, 0.16), at, c.blade, SLATE)
	disc(ctx, limb, "Arch", at * CFrame.new(0, 0.575 * s, 0), 0.95 * s, 0.16, c.blade, SLATE, "z")
	P(limb, "FrameL", Vector3.new(0.07, 1.15 * s, 0.2), at * CFrame.new(-0.47 * s, 0, 0), c.trim, METAL)
	P(limb, "FrameR", Vector3.new(0.07, 1.15 * s, 0.2), at * CFrame.new(0.47 * s, 0, 0), c.trim, METAL)
	P(limb, "FrameB", Vector3.new(0.98 * s, 0.08, 0.2), at * CFrame.new(0, -0.575 * s, 0), c.trim, METAL)
	-- the runes: a few strokes each, on the face
	local strokes = {
		{ -0.22, 0.3, 0.05, 0.3, 0 }, { -0.22, 0.3, 0.22, 0.05, 0 }, { 0.18, 0.32, 0.05, 0.26, 30 },
		{ 0.18, 0.32, 0.05, 0.26, -30 }, { -0.2, -0.05, 0.28, 0.05, 45 }, { 0.2, -0.05, 0.05, 0.3, 0 },
		{ 0, -0.34, 0.5, 0.05, 0 }, { 0, -0.24, 0.05, 0.16, 0 },
	}
	for k, st in strokes do
		P(limb, "Rune" .. k, Vector3.new(st[3] * s, st[4] * s, 0.04), at * CFrame.new(st[1] * s, st[2] * s, -0.08) * CFrame.Angles(0, 0, math.rad(st[5])), c.glow, NEON)
	end
	P(limb, "Crack", Vector3.new(0.04, 0.5 * s, 0.03), at * CFrame.new(0.32 * s, -0.25 * s, -0.08) * CFrame.Angles(0, 0, math.rad(20)), darker(c.blade, 0.6))
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.22, 0.22, 0.22), at * CFrame.new(0, 0.66 * s, -0.08), c.glow, NEON, "ball")
	end
	if w.p.big then
		for k, off in { Vector3.new(0.75, 0.4, 0), Vector3.new(-0.72, -0.3, 0.1) } do
			P(limb, "Shard" .. k, Vector3.new(0.18, 0.24, 0.1), at * CFrame.new(off) * CFrame.Angles(0.4 * k, 0.3, 0.8 * k), c.blade, SLATE)
			P(limb, "ShardRune" .. k, Vector3.new(0.05, 0.14, 0.11), at * CFrame.new(off) * CFrame.Angles(0.4 * k, 0.3, 0.8 * k), c.glow, NEON)
		end
	end
	ctx.trail(limb, slab, at * CFrame.new(0, 0.7 * s, 0), at * CFrame.new(0, -0.6 * s, 0))
	ctx.focus(slab)
end
-- the war fan: ribs spread in a fan from the hand (a socket for the kit's fan_blade: thin X,
-- the fan spread in its Y-Z plane)
BUILD.warfan = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local r = 1.05 * (w.p.size or 1.3)
	local pivot = HAND * CFrame.new(0, 0.05, -0.15) * CFrame.Angles(math.rad(-18), 0, 0)
	local spread, ribs = 62, 7
	local sock = ctx.socket(limb, "Fan", Vector3.new(0.1, 2 * r * math.sin(math.rad(spread)) + 0.2, r + 0.3), pivot * CFrame.new(0, 0, -r / 2 + 0.15), "fan_blade", c.blade, FABRIC)
	for k = 0, ribs - 1 do
		local a = math.rad(-spread + 2 * spread * k / (ribs - 1))
		local outer = k == 0 or k == ribs - 1
		P(limb, "Rib" .. k, Vector3.new(if outer then 0.08 else 0.05, if outer then 0.08 else 0.05, r), pivot * CFrame.Angles(a, 0, 0) * CFrame.new(0, 0, -r / 2), if outer then c.trim else c.grip, if outer then METAL else WOOD)
		if k < ribs - 1 then
			local m = math.rad(-spread + 2 * spread * (k + 0.5) / (ribs - 1))
			local wseg = 2 * math.sin(math.rad(spread) / (ribs - 1)) * r * 0.78
			P(limb, "Panel" .. k, Vector3.new(0.03, wseg, r * 0.58), pivot * CFrame.Angles(m, 0, 0) * CFrame.new(0, 0, -r * 0.62), if k % 2 == 0 then c.blade else c.blade:Lerp(c.trim, 0.25), FABRIC)
		end
	end
	ctx.cover = nil
	for k = 0, ribs - 1, 2 do
		local a = math.rad(-spread + 2 * spread * k / (ribs - 1))
		if w.p.tips then
			point2(ctx, limb, "Tip" .. k, pivot * CFrame.Angles(a, 0, 0) * CFrame.new(0, 0, -r), 0.14, 0.28, 0.05, c.glow, NEON)
		else
			P(limb, "Dot" .. k, Vector3.new(0.06, 0.12, 0.12), pivot * CFrame.Angles(a, 0, 0) * CFrame.new(0, 0, -r * 0.92), c.glow, NEON)
		end
	end
	P(limb, "Rivet", Vector3.new(0.2, 0.2, 0.2), pivot, c.trim, METAL, "ball")
	P(limb, "Cord", Vector3.new(0.04, 0.45, 0.04), pivot * CFrame.new(0, -0.25, 0.1), c.glow, FABRIC)
	P(limb, "Tassel", Vector3.new(0.14, 0.14, 0.14), pivot * CFrame.new(0, -0.5, 0.1), c.glow, NEON, "ball")
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.16, 0.16, 0.16), pivot * CFrame.new(0.06, 0, -0.25), c.glow, NEON, "ball")
	end
	ctx.trail(limb, sock, pivot * CFrame.Angles(math.rad(spread), 0, 0) * CFrame.new(0, 0, -r), pivot * CFrame.Angles(math.rad(-spread), 0, 0) * CFrame.new(0, 0, -r))
	ctx.focus(sock)
end
BUILD.censer = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local s = if w.p.big then 1.2 else 1
	for k = 0, 3 do
		P(ctx.right, "Chain" .. k, Vector3.new(0.06, 0.22, 0.06), HAND * CFrame.new(0, -0.15 - k * 0.22, -0.1), c.trim, METAL)
	end
	local lamp = HAND * CFrame.new(0, -1.15 - 0.4 * s, -0.1)
	local cage = P(ctx.right, "Cage", Vector3.new(0.6, 0.75, 0.6) * s, lamp, c.blade, GLASS)
	cage.Transparency = 0.35
	local flame = P(ctx.right, "Flame", Vector3.new(0.32, 0.42, 0.32) * s, lamp, c.glow, NEON, "ball")
	P(ctx.right, "Top", Vector3.new(0.7 * s, 0.12, 0.7 * s), lamp * CFrame.new(0, 0.42 * s, 0), c.trim, METAL)
	P(ctx.right, "Base", Vector3.new(0.7 * s, 0.12, 0.7 * s), lamp * CFrame.new(0, -0.42 * s, 0), c.trim, METAL)
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			P(ctx.right, "Post", Vector3.new(0.06, 0.75 * s, 0.06), lamp * CFrame.new(x * 0.3 * s, 0, z * 0.3 * s), c.trim, METAL)
		end
	end
	spike(ctx, ctx.right, "Finial", lamp * CFrame.new(0, 0.48 * s, 0), 0.3 * s, 0.22, 0.3 * s, c.trim, METAL)
	orbTrail(ctx, ctx.right, flame, lamp, 0.4 * s)
end
-- the thurible: a censer swung on three chains, light leaking through its vents
BUILD.thurible = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local s = if w.p.big then 1.2 else 1
	local hand = HAND * CFrame.new(0, -0.05, -0.12)
	local body = HAND * CFrame.new(0, -1.55, -0.2)
	disc(ctx, limb, "Ring", hand, 0.3, 0.06, c.trim, METAL, "x")
	for k = 0, 2 do
		local a = k / 3 * math.pi * 2
		local from = hand.Position
		local to = (body * CFrame.new(math.cos(a) * 0.28 * s, 0.36 * s, math.sin(a) * 0.28 * s)).Position
		local len = (to - from).Magnitude
		P(limb, "Chain" .. k, Vector3.new(0.04, 0.04, len), aim((from + to) / 2, to), c.trim, METAL)
	end
	local bowl = P(limb, "Bowl", Vector3.new(0.7, 0.7, 0.7) * s, body * CFrame.new(0, -0.05 * s, 0), c.blade, METAL, "ball")
	P(limb, "Lid", Vector3.new(0.56, 0.56, 0.56) * s, body * CFrame.new(0, 0.2 * s, 0), c.trim, METAL, "ball")
	disc(ctx, limb, "Rim", body * CFrame.new(0, 0.07 * s, 0), 0.76 * s, 0.08, c.trim, METAL, "y")
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		P(limb, "Vent" .. k, Vector3.new(0.1, 0.1, 0.1) * s, body * CFrame.new(math.cos(a) * 0.3 * s, 0.17 * s, math.sin(a) * 0.3 * s), c.glow, NEON, "ball")
	end
	spike(ctx, limb, "Spire", body * CFrame.new(0, 0.45 * s, 0), 0.16 * s, 0.3 * s, 0.16 * s, c.trim, METAL)
	disc(ctx, limb, "Foot", body * CFrame.new(0, -0.42 * s, 0), 0.34 * s, 0.1, c.trim, METAL, "y")
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.16, 0.16, 0.16), body * CFrame.new(0, 0.62 * s, 0), c.glow, NEON, "ball")
	end
	orbTrail(ctx, limb, bowl, body, 0.4 * s)
end
-- the handbell: a handle in the fist, the bell hanging under it
BUILD.bell = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local s = w.p.size or 1
	rod(ctx, limb, "Handle", HAND * CFrame.new(0, 0.05, -0.1), 0.6, 0.16, c.grip, WOOD, "y")
	P(limb, "Knob", Vector3.new(0.22, 0.22, 0.22), HAND * CFrame.new(0, 0.38, -0.1), c.trim, METAL, "ball")
	local top = HAND * CFrame.new(0, -0.3, -0.1)
	P(limb, "Crown", Vector3.new(0.26, 0.26, 0.26) * s, top, c.blade, METAL, "ball")
	local body
	for k = 1, 4 do
		local d = (0.32 + k * 0.1) * s
		local p = rod(ctx, limb, "Bell" .. k, top * CFrame.new(0, -0.08 * s - k * 0.15 * s, 0), 0.16 * s, d, c.blade, METAL, "y")
		body = body or p
	end
	disc(ctx, limb, "Lip", top * CFrame.new(0, -0.8 * s, 0), 0.86 * s, 0.08, c.trim, METAL, "y")
	disc(ctx, limb, "Band", top * CFrame.new(0, -0.45 * s, 0), 0.62 * s, 0.05, c.glow, NEON, "y")
	P(limb, "Clapper", Vector3.new(0.2, 0.2, 0.2) * s, top * CFrame.new(0, -0.9 * s, 0), c.trim, METAL, "ball")
	if w.p.chimes then
		for k = 0, 2 do
			local a = k / 3 * math.pi * 2 + 0.5
			rod(ctx, limb, "Chime" .. k, top * CFrame.new(math.cos(a) * 0.55 * s, -0.2, math.sin(a) * 0.55 * s), 0.45, 0.07, c.trim, METAL, "y")
			P(limb, "ChimeCord" .. k, Vector3.new(0.02, 0.2, 0.02), top * CFrame.new(math.cos(a) * 0.55 * s, 0.1, math.sin(a) * 0.55 * s), c.glow, FABRIC)
		end
		disc(ctx, limb, "ChimeRing", top * CFrame.new(0, 0.2, 0), 1.15 * s, 0.04, c.trim, METAL, "y").Transparency = 0.2
	end
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.14, 0.14, 0.14), top * CFrame.new(0, 0.12 * s, -0.12 * s), c.glow, NEON, "ball")
	end
	orbTrail(ctx, limb, body, top * CFrame.new(0, -0.5 * s, 0), 0.45 * s)
end
-- the scepter: a short rod with a sun in a halo, wings for the higher ones
BUILD.scepter = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local len = w.p.len or 2
	local at = RAISED
	rod(ctx, limb, "Shaft", at * CFrame.new(0, len / 2 - 0.55, 0), len, 0.14, c.grip, METAL, "y")
	for k = 0, 1 do
		disc(ctx, limb, "Wrap" .. k, at * CFrame.new(0, -0.3 + k * 0.4, 0), 0.19, 0.08, c.trim, METAL, "y")
	end
	P(limb, "Butt", Vector3.new(0.22, 0.22, 0.22), at * CFrame.new(0, -0.6, 0), c.trim, METAL, "ball")
	local top = at * CFrame.new(0, len - 0.55, 0)
	P(limb, "Knop", Vector3.new(0.28, 0.28, 0.28), top, c.trim, METAL, "ball")
	local headAt = top * CFrame.new(0, 0.5, 0)
	hoop(ctx, limb, "Halo", headAt, 0.34, 0.07, 10, c.trim, METAL)
	local sun = P(limb, "Sun", Vector3.new(0.34, 0.34, 0.34), headAt, c.glow, NEON, "ball")
	for k = 0, 7 do
		local a = k / 8 * math.pi * 2
		P(limb, "Ray" .. k, Vector3.new(0.05, 0.06, 0.18), headAt * CFrame.Angles(a, 0, 0) * CFrame.new(0, 0, -0.5), c.blade, METAL)
	end
	if w.p.wings then
		for _, side in { -1, 1 } do
			for k = 0, 2 do
				P(limb, "Feather" .. k, Vector3.new(0.05, 0.14, 0.42 - k * 0.08), top * CFrame.new(0, 0.2 + k * 0.12, side * (0.3 + k * 0.06)) * CFrame.Angles(math.rad(side * (30 + k * 18)), 0, 0) * CFrame.new(0, 0, side * 0.12), c.blade, METAL)
			end
		end
	end
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.16, 0.16, 0.16), headAt * CFrame.new(0, 0.5, 0), c.glow, NEON, "ball")
	end
	orbTrail(ctx, limb, sun, headAt, 0.45)
end
-- the crescent staff: a moon opening upward at the top, an orb in its bowl (a socket for the
-- kit's staff_crescent: thin X, the crescent in its Y-Z plane, opening toward +Y)
BUILD.crescent = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local top = shaft(ctx, limb, w.p.len or 5.2, 1.2)
	local r = 0.62
	local center = top * CFrame.new(0, 0.78, 0)
	-- the arc runs around the bottom from one horn to the other (angles about X: 0 is -Z, 90 is +Y)
	local a0, a1 = -195, 15
	local moon = ctx.socket(limb, "Moon", Vector3.new(0.12, 1.24, 1.5), top * CFrame.new(0, 0.63, 0), "staff_crescent", c.trim, METAL)
	local n = 8
	for k = 0, n - 1 do
		local t = (k + 0.5) / n
		local a = a0 + (a1 - a0) * t
		local fat = 1 - math.abs(t - 0.5) * 1.6
		P(limb, "Arc" .. k, Vector3.new(0.1, 2 * math.pi * r * ((a1 - a0) / 360) / n * 1.15, 0.07 + 0.22 * fat), center * CFrame.Angles(math.rad(a), 0, 0) * CFrame.new(0, 0, -r), c.trim, METAL)
	end
	for _, side in { -1, 1 } do
		local horn = math.rad(a1)
		spike(ctx, limb, "Horn", center * CFrame.new(0, r * math.sin(horn), side * r * math.cos(horn)), 0.1, 0.28, 0.08, c.trim, METAL)
	end
	ctx.cover = nil
	if ctx.edge then
		hoop(ctx, limb, "Inner", center, r - 0.14, 0.04, 7, c.glow, NEON, a0 + 25, a1 - 25)
	end
	local orb = P(limb, "Orb", Vector3.new(0.42, 0.42, 0.42), center * CFrame.new(0, 0.05, 0), c.glow, NEON, "ball")
	if w.p.rings then
		hoop(ctx, limb, "Halo", center * CFrame.new(0, 0.05, 0) * CFrame.Angles(0, 0, R90), 0.36, 0.04, 10, c.glow, NEON)
	end
	disc(ctx, limb, "Collar", top * CFrame.new(0, -0.05, 0), 0.26, 0.14, c.trim, METAL, "y")
	P(limb, "Tassel", Vector3.new(0.05, 0.6, 0.05), top * CFrame.new(0, -0.4, 0.12), c.glow, FABRIC)
	if w.p.vines then
		for k = 0, 3 do
			P(limb, "Sprig" .. k, Vector3.new(0.04, 0.12, 0.26), top * CFrame.new(0, -0.6 - k * 0.6, 0) * CFrame.Angles(0, k * 1.6, 0) * CFrame.new(0, 0, -0.16) * CFrame.Angles(math.rad(25), 0, 0), c.glow, Enum.Material.Grass)
		end
	end
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.18, 0.18, 0.18), top * CFrame.new(0, 0.14, -0.1), c.glow, NEON, "ball")
	end
	ctx.trail(limb, moon, center * CFrame.new(0, 0.2, -0.75), center * CFrame.new(0, 0.2, 0.75))
	ctx.focus(orb)
end

-- ── ranged ─────────────────────────────────────────────────────────────────
local function quiver(ctx, w, arrows: number, s: number?)
	local P, c = ctx.piece, ctx.colors
	if not ctx.torso then
		return
	end
	local at = CFrame.new(0.5, 0.25, 0.72) * CFrame.Angles(0, 0, math.rad(-20))
	P(ctx.torso, "Quiver", Vector3.new(0.45, 1.6 * (s or 1), 0.45), at, c.grip, LEATHER)
	disc(ctx, ctx.torso, "QuiverRim", at * CFrame.new(0, 0.8 * (s or 1), 0), 0.5, 0.08, c.trim, METAL, "y")
	for k = 1, arrows do
		local off = CFrame.new((k - (arrows + 1) / 2) * 0.12, 0.8 * (s or 1) + 0.2, (k % 2) * 0.1 - 0.05)
		P(ctx.torso, "Fletch" .. k, Vector3.new(0.03, 0.28, 0.14), at * off * CFrame.new(0, 0.05, 0), c.glow, if ctx.edge then NEON else FABRIC)
	end
end
BUILD.bow = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 3.6
	local limb = ctx.left
	local grip = HAND * CFrame.new(0, 0.05, -0.15)
	P(limb, "Grip", Vector3.new(0.18, 0.5, 0.2), grip, c.grip, LEATHER)
	-- each limb of the bow: three segments bending back
	for _, dir in { 1, -1 } do
		local cf = grip * CFrame.new(0, dir * 0.25, 0)
		local seg = (len / 2 - 0.25) / 3
		for k = 1, 3 do
			cf = cf * CFrame.Angles(math.rad(dir * 11), 0, 0)
			P(limb, "Limb" .. dir .. k, Vector3.new(0.12, seg + 0.04, 0.16), cf * CFrame.new(0, dir * seg / 2, 0), c.blade, WOOD)
			cf = cf * CFrame.new(0, dir * seg, 0)
		end
		P(limb, "Tip" .. dir, Vector3.new(0.14, 0.18, 0.18), cf, c.trim, METAL)
	end
	local string = P(limb, "String", Vector3.new(0.03, len * 0.9, 0.03), grip * CFrame.new(0, 0, 0.55), c.glow, NEON)
	quiver(ctx, w, 3)
	ctx.trail(limb, string, grip * CFrame.new(0, len * 0.42, 0.3), grip * CFrame.new(0, -len * 0.42, 0.3))
	ctx.focus(string)
end
-- the longbow: taller, four segments a limb and recurved tips, an arrow on the string
BUILD.longbow = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 5.2
	local limb = ctx.left
	local grip = HAND * CFrame.new(0, 0.75, -0.2) * CFrame.Angles(math.rad(-14), 0, 0)
	P(limb, "Grip", Vector3.new(0.2, 0.6, 0.22), grip, c.grip, LEATHER)
	P(limb, "Rest", Vector3.new(0.22, 0.08, 0.26), grip * CFrame.new(0, 0.32, 0), c.trim, METAL)
	local half = len / 2 - 0.3
	local seg = half / 4
	local tips = {}
	for _, dir in { 1, -1 } do
		local cf = grip * CFrame.new(0, dir * 0.3, 0)
		for k = 1, 4 do
			cf = cf * CFrame.Angles(math.rad(dir * (if k == 4 then -24 else 9)), 0, 0)
			P(limb, "Limb" .. dir .. k, Vector3.new(0.12, seg + 0.04, 0.15 - k * 0.015), cf * CFrame.new(0, dir * seg / 2, 0), c.blade, WOOD)
			if k == 2 and ctx.edge then
				P(limb, "LimbGlow" .. dir, Vector3.new(0.13, seg * 0.8, 0.04), cf * CFrame.new(0, dir * seg / 2, -0.07), c.glow, NEON)
			end
			cf = cf * CFrame.new(0, dir * seg, 0)
		end
		P(limb, "Nock" .. dir, Vector3.new(0.14, 0.12, 0.14), cf, c.trim, METAL)
		tips[dir] = cf
	end
	local a, b = (tips[1] * CFrame.new(0, 0, 0.04)).Position, (tips[-1] * CFrame.new(0, 0, 0.04)).Position
	P(limb, "String", Vector3.new(0.03, 0.03, (b - a).Magnitude), aim((a + b) / 2, b), c.glow, NEON)
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.16, 0.16, 0.16), grip * CFrame.new(-0.1, 0, 0), c.glow, NEON, "ball")
	end
	quiver(ctx, w, 4, 1.15)
	local ref = P(limb, "Riser", Vector3.new(0.14, 0.9, 0.14), grip, c.blade, WOOD)
	ctx.trail(limb, ref, tips[1], tips[-1])
	ctx.focus(ref)
end
BUILD.crossbow = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local s = if w.p.small then 0.7 else 1
	local at = FORWARD * CFrame.new(0, 0.1, -0.3)
	P(ctx.right, "Stock", Vector3.new(0.22, 0.26, 2 * s), at * CFrame.new(0, 0, -0.5 * s), c.grip, WOOD)
	local prod = P(ctx.right, "Prod", Vector3.new(2.2 * s, 0.14, 0.16), at * CFrame.new(0, 0.05, -1.3 * s), c.blade, METAL)
	P(ctx.right, "String", Vector3.new(2.1 * s, 0.03, 0.03), at * CFrame.new(0, 0.05, -0.9 * s), c.glow, NEON)
	P(ctx.right, "Bolt", Vector3.new(0.06, 0.06, 1.4 * s), at * CFrame.new(0, 0.18, -1 * s), c.trim, METAL)
	point2(ctx, ctx.right, "BoltHead", at * CFrame.new(0, 0.18, -1.7 * s), 0.14, 0.2, 0.05, c.glow, NEON)
	if not w.p.small then
		P(ctx.right, "Magazine", Vector3.new(0.3, 0.35, 0.8), at * CFrame.new(0, 0.32, -0.6), c.trim, METAL)
	end
	P(ctx.right, "Trigger", Vector3.new(0.06, 0.2, 0.08), at * CFrame.new(0, -0.2, 0.1), c.trim, METAL)
	ctx.trail(ctx.right, prod, at * CFrame.new(1.05 * s, 0.05, -1.3 * s), at * CFrame.new(-1.05 * s, 0.05, -1.3 * s))
	ctx.focus(prod)
end
-- the arbalest: a heavy crossbow, a steel prod swept back, a windlass at the butt
BUILD.arbalest = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local s = if w.p.big then 1.15 else 1
	local at = FORWARD * CFrame.new(0, 0.12, -0.2)
	P(limb, "Stock", Vector3.new(0.28, 0.32, 2.3 * s), at * CFrame.new(0, 0, -0.55 * s), c.grip, WOOD)
	P(limb, "Butt", Vector3.new(0.32, 0.55, 0.45), at * CFrame.new(0, -0.08, 0.62 * s), c.grip, WOOD)
	P(limb, "Rail", Vector3.new(0.12, 0.06, 1.9 * s), at * CFrame.new(0, 0.19, -0.75 * s), c.trim, METAL)
	local front = at * CFrame.new(0, 0.06, -1.62 * s)
	local prods = {}
	for _, side in { -1, 1 } do
		table.insert(prods, P(limb, "Prod", Vector3.new(1.3 * s, 0.18, 0.2), front * CFrame.new(side * 0.62 * s, 0, 0.12) * CFrame.Angles(0, math.rad(-side * 16), 0), c.blade, METAL))
		P(limb, "ProdTip", Vector3.new(0.16, 0.26, 0.22), front * CFrame.new(side * 1.24 * s, 0, 0.32 * s), c.trim, METAL)
		local tip = (front * CFrame.new(side * 1.24 * s, 0.02, 0.36 * s)).Position
		local nut = (at * CFrame.new(0, 0.2, -0.75 * s)).Position
		P(limb, "String" .. side, Vector3.new(0.03, 0.03, (nut - tip).Magnitude), aim((tip + nut) / 2, nut), c.glow, NEON)
	end
	P(limb, "Stirrup", Vector3.new(0.5, 0.06, 0.06), front * CFrame.new(0, 0, -0.42), c.trim, METAL)
	for _, side in { -1, 1 } do
		P(limb, "StirrupSide", Vector3.new(0.06, 0.06, 0.4), front * CFrame.new(side * 0.22, 0, -0.22), c.trim, METAL)
	end
	P(limb, "Bolt", Vector3.new(0.07, 0.07, 1.5 * s), at * CFrame.new(0, 0.26, -1.1 * s), c.grip, WOOD)
	point2(ctx, limb, "BoltHead", at * CFrame.new(0, 0.26, -1.85 * s), 0.2, 0.3, 0.06, c.glow, NEON)
	rod(ctx, limb, "Windlass", at * CFrame.new(0, 0.05, 0.9 * s), 0.7, 0.24, c.trim, METAL, "x")
	for _, side in { -1, 1 } do
		P(limb, "Crank", Vector3.new(0.06, 0.4, 0.06), at * CFrame.new(side * 0.36, -0.12, 0.9 * s), c.trim, METAL)
	end
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.2, 0.2, 0.2), at * CFrame.new(0.16, 0, -0.4), c.glow, NEON, "ball")
	end
	ctx.trail(limb, prods[2], front * CFrame.new(1.24 * s, 0, 0.32 * s), front * CFrame.new(-1.24 * s, 0, 0.32 * s))
	ctx.focus(prods[2])
end
-- javelins: one in the hand, more in a case on the back
BUILD.javelin = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local len = w.p.len or 4.2
	local top = shaft(ctx, limb, len, 1.3)
	disc(ctx, limb, "Grip", UPRIGHT * CFrame.new(0, 0, 0), 0.22, 0.5, darker(c.grip, 0.3), LEATHER, "y")
	leafHead(ctx, limb, top, 0.34, 0.8)
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.16, 0.16, 0.16), top * CFrame.new(0, 0.05, -0.12), c.glow, NEON, "ball")
	end
	if ctx.torso then
		local at = CFrame.new(-0.45, 0.2, 0.72) * CFrame.Angles(0, 0, math.rad(18))
		P(ctx.torso, "Case", Vector3.new(0.5, 1.5, 0.4), at, c.grip, LEATHER)
		for k = 1, 2 do
			local x = (k - 1.5) * 0.16
			P(ctx.torso, "Spare" .. k, Vector3.new(0.08, 1, 0.08), at * CFrame.new(x, 1.1, 0), c.grip, WOOD)
			spike(ctx, ctx.torso, "SpareTip" .. k, at * CFrame.new(x, 1.6, 0), 0.18, 0.32, 0.05, c.blade, METAL)
		end
	end
end
-- throwing knives: a kunai in the hand, more on a strap across the chest
BUILD.kunai = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local at = FORWARD
	disc(ctx, limb, "Ring", at * CFrame.new(0, 0, 0.62), 0.3, 0.05, c.trim, METAL, "x")
	disc(ctx, limb, "RingHole", at * CFrame.new(0, 0, 0.62), 0.16, 0.06, darker(c.grip, 0.5), METAL, "x")
	P(limb, "Grip", Vector3.new(0.12, 0.12, 0.55), at * CFrame.new(0, 0, 0.22), c.grip, FABRIC)
	wraps(ctx, limb, at, -0.02, 0.48, 3, 0.15, c.trim)
	local b = P(limb, "Blade", Vector3.new(0.06, 0.32, 0.5), at * CFrame.new(0, 0, -0.3), c.blade, METAL)
	point2(ctx, limb, "Tip", at * CFrame.new(0, 0, -0.55), 0.32, 0.4, 0.06, c.blade, METAL)
	P(limb, "Rib", Vector3.new(0.08, 0.05, 0.6), at * CFrame.new(0, 0, -0.4), c.glow, NEON)
	if ctx.torso then
		local strap = CFrame.new(0, 0, -0.56) * CFrame.Angles(0, 0, math.rad(38))
		P(ctx.torso, "Strap", Vector3.new(0.24, 2.6, 0.08), strap, c.grip, LEATHER)
		for k = 1, 5 do
			local y = -0.9 + k * 0.32
			local hold = strap * CFrame.new(0, y, -0.06)
			P(ctx.torso, "Sheath" .. k, Vector3.new(0.18, 0.12, 0.1), hold, c.trim, METAL)
			P(ctx.torso, "Hilt" .. k, Vector3.new(0.07, 0.3, 0.07), hold * CFrame.new(0.14, 0.05, 0) * CFrame.Angles(0, 0, math.rad(-90)), c.grip, FABRIC)
			disc(ctx, ctx.torso, "Pommel" .. k, hold * CFrame.new(0.32, 0.05, 0), 0.13, 0.03, c.trim, METAL, "z")
			if ctx.edge then
				P(ctx.torso, "Glint" .. k, Vector3.new(0.05, 0.05, 0.11), hold * CFrame.new(-0.1, 0, 0), c.glow, NEON)
			end
		end
		if w.p.gem then
			P(ctx.torso, "Gem", Vector3.new(0.18, 0.18, 0.18), strap * CFrame.new(0, 0.85, -0.08), c.glow, NEON, "ball")
		end
	end
	ctx.trail(limb, b, at * CFrame.new(0, 0, -0.95), at * CFrame.new(0, 0, -0.1))
	ctx.focus(b)
end

-- ── hands ──────────────────────────────────────────────────────────────────
local function fist(ctx, limb, w, claws: boolean)
	local P, c = ctx.piece, ctx.colors
	local big = if w.p.big then 1.2 else 1
	local g = P(limb, "Gauntlet", Vector3.new(1.14 * big, 0.95, 1.14 * big), CFrame.new(0, -0.6, 0), c.blade, METAL)
	P(limb, "Cuff", Vector3.new(1.18 * big, 0.14, 1.18 * big), CFrame.new(0, -0.12, 0), c.trim, METAL)
	local k1 = P(limb, "Knuckle", Vector3.new(1.18 * big, 0.22, 0.3), CFrame.new(0, -0.95, -0.5 * big), c.glow, NEON)
	if w.p.studs then
		for k = -1, 1 do
			P(limb, "Stud" .. k, Vector3.new(0.18, 0.18, 0.18), CFrame.new(k * 0.32, -0.95, -0.62), c.trim, METAL, "ball")
		end
	end
	if claws then
		for k = -1, 1 do
			P(limb, "Claw" .. k, Vector3.new(0.1, 0.8, 0.22), CFrame.new(k * 0.32, -1.45, -0.35) * CFrame.Angles(math.rad(20), 0, 0), c.trim, METAL, "wedge")
		end
	end
	ctx.trail(limb, g, CFrame.new(0, -1.1, -0.6), CFrame.new(0, -0.5, -0.6))
	ctx.focus(k1)
end
BUILD.gauntlets = function(ctx, w)
	fist(ctx, ctx.right, w, false)
	fist(ctx, ctx.left, w, false)
end
BUILD.claws = function(ctx, w)
	fist(ctx, ctx.right, w, true)
	fist(ctx, ctx.left, w, true)
end
-- katars: a broad triangular blade straight out of the fist, on an H-shaped grip
BUILD.katar = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 1.3
	for _, limb in { ctx.right, ctx.left } do
		local at = HAND * CFrame.new(0, 0.05, -0.05) * CFrame.Angles(math.rad(-72), 0, 0)
		for _, side in { -1, 1 } do
			P(limb, "Bar", Vector3.new(0.07, 0.12, 0.95), at * CFrame.new(side * 0.36, 0, 0.42), c.trim, METAL)
		end
		P(limb, "Grip", Vector3.new(0.66, 0.13, 0.13), at * CFrame.new(0, 0, 0.3), c.grip, LEATHER)
		P(limb, "Grip2", Vector3.new(0.66, 0.11, 0.11), at * CFrame.new(0, 0, 0.55), c.grip, LEATHER)
		P(limb, "Forte", Vector3.new(0.8, 0.12, 0.2), at * CFrame.new(0, 0, -0.04), c.trim, METAL)
		local bl = len * 0.55
		local b = P(limb, "Blade", Vector3.new(0.1, 0.46, bl), at * CFrame.new(0, 0, -0.14 - bl / 2), c.blade, METAL)
		point2(ctx, limb, "Tip", at * CFrame.new(0, 0, -0.14 - bl), 0.46, len * 0.45, 0.1, c.blade, METAL)
		P(limb, "Fuller", Vector3.new(0.12, 0.08, bl + len * 0.2), at * CFrame.new(0, 0, -0.14 - (bl + len * 0.2) / 2), c.glow, NEON)
		if w.p.notched then
			for k = 1, 2 do
				P(limb, "Notch" .. k, Vector3.new(0.12, 0.1, 0.12), at * CFrame.new(0, (if k == 1 then 1 else -1) * 0.22, -0.14 - bl * 0.6), c.grip, METAL)
			end
		end
		if w.p.gem then
			P(limb, "Gem", Vector3.new(0.16, 0.16, 0.16), at * CFrame.new(0, 0, -0.04), c.glow, NEON, "ball")
		end
		ctx.trail(limb, b, at * CFrame.new(0, 0, -0.14 - bl - len * 0.45), at * CFrame.new(0, 0, -0.14))
		ctx.focus(b)
	end
end
-- sai: a round prong and two curled tines, one in each hand
BUILD.sai = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 1.7
	for _, limb in { ctx.right, ctx.left } do
		local at = FORWARD
		P(limb, "Grip", Vector3.new(0.16, 0.16, 0.62), at * CFrame.new(0, 0, 0.2), c.grip, FABRIC)
		wraps(ctx, limb, at, -0.05, 0.45, 2, 0.19, darker(c.grip, 0.4))
		P(limb, "Pommel", Vector3.new(0.22, 0.22, 0.22), at * CFrame.new(0, 0, 0.56), c.trim, METAL, "ball")
		P(limb, "Hilt", Vector3.new(0.16, 0.22, 0.16), at * CFrame.new(0, 0, -0.1), c.trim, METAL)
		local prong = rod(ctx, limb, "Prong", at * CFrame.new(0, 0, -0.18 - len / 2), len, 0.1, c.blade, METAL)
		point2(ctx, limb, "Tip", at * CFrame.new(0, 0, -0.18 - len), 0.1, 0.16, 0.1, c.blade, METAL)
		for _, side in { -1, 1 } do
			P(limb, "Tine", Vector3.new(0.07, 0.34, 0.08), at * CFrame.new(0, side * 0.24, -0.1) * CFrame.Angles(math.rad(side * 20), 0, 0), c.blade, METAL)
			P(limb, "TineUp", Vector3.new(0.07, 0.08, 0.42), at * CFrame.new(0, side * 0.4, -0.34) * CFrame.Angles(math.rad(side * -12), 0, 0), c.blade, METAL)
		end
		if ctx.edge then
			P(limb, "Glow", Vector3.new(0.12, 0.04, len * 0.8), at * CFrame.new(0, 0, -0.18 - len * 0.45), c.glow, NEON)
		end
		if w.p.gem then
			P(limb, "Gem", Vector3.new(0.14, 0.14, 0.14), at * CFrame.new(0, 0, -0.1) * CFrame.new(0.09, 0, 0), c.glow, NEON, "ball")
		end
		ctx.trail(limb, prong, at * CFrame.new(0, 0, -0.18 - len - 0.12), at * CFrame.new(0, 0, -0.3))
		ctx.focus(prong)
	end
end
BUILD.shield = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local big = if w.p.big then 1.25 else 1
	local face = CFrame.new(-0.65, -0.5, -0.1)
	local main
	if w.p.round then
		-- a round shield: the kit's shield_round (thin X, the face in Y-Z)
		local d = 2.3
		main = P(ctx.left, "Shield", Vector3.new(0.2, d, d), face, c.blade, WOOD, "cyl")
		ctx.role(main, "shield_round")
		disc(ctx, ctx.left, "Rim", face * CFrame.new(0.05, 0, 0), d + 0.14, 0.14, c.trim, METAL, "x")
		P(ctx.left, "Boss", Vector3.new(0.6, 0.6, 0.6), face * CFrame.new(-0.12, 0, 0), c.trim, METAL, "ball")
		for _, a in { 0, 90 } do
			P(ctx.left, "Strap" .. a, Vector3.new(0.22, d * 0.92, 0.14), face * CFrame.Angles(math.rad(a), 0, 0), c.grip, LEATHER)
		end
		disc(ctx, ctx.left, "BossGlow", face * CFrame.new(-0.4, 0, 0), 0.3, 0.04, c.glow, NEON, "x")
		-- a hand axe in the other hand
		BUILD.axe(ctx, { p = { len = 2.2 } }, ctx.right, UPRIGHT)
	elseif w.p.kite then
		-- a kite shield: a socket for the kit's shield_kite; parts draw a plate and a point
		local h, wd = 3, 1.7
		main = ctx.socket(ctx.left, "Shield", Vector3.new(0.22, h, wd), face * CFrame.new(0, -0.3, 0), "shield_kite", c.blade, METAL)
		P(ctx.left, "Plate", Vector3.new(0.22, 1.9, wd), face * CFrame.new(0, 0.25, 0), c.blade, METAL)
		P(ctx.left, "PointL", Vector3.new(0.22, 1.1, wd / 2), face * CFrame.new(0, -1.25, -wd / 4) * CFrame.Angles(0, 0, math.pi), c.blade, METAL, "wedge")
		P(ctx.left, "PointR", Vector3.new(0.22, 1.1, wd / 2), face * CFrame.new(0, -1.25, wd / 4) * CFrame.Angles(math.pi, 0, 0), c.blade, METAL, "wedge")
		ctx.cover = nil
		P(ctx.left, "RimTop", Vector3.new(0.26, 0.12, wd + 0.04), face * CFrame.new(0, 1.2, 0), c.trim, METAL)
		P(ctx.left, "Stripe", Vector3.new(0.25, 2.4, 0.18), face * CFrame.new(0, -0.15, 0), c.trim, METAL)
		P(ctx.left, "Band", Vector3.new(0.25, 0.18, wd), face * CFrame.new(0, 0.6, 0), c.trim, METAL)
		P(ctx.left, "Emblem", Vector3.new(0.27, 0.36, 0.36), face * CFrame.new(-0.02, 0.6, 0) * CFrame.Angles(math.rad(45), 0, 0), c.glow, NEON)
		-- an arming sword in the other hand
		blade(ctx, ctx.right, FORWARD, 2.6, 0.28, { guard = 0.8, wrap = 2 })
		ctx.focus(main)
		return
	else
		-- the rectangular ones (riot, tower, bulwark): the kit's shield_tower
		main = P(ctx.left, "Shield", Vector3.new(0.22, 2.4 * big, 1.6 * big), face, c.blade, METAL)
		ctx.role(main, "shield_tower")
		P(ctx.left, "Rim", Vector3.new(0.26, 2.5 * big, 0.14), face * CFrame.new(0, 0, 0.8 * big), c.trim, METAL)
		P(ctx.left, "Rim2", Vector3.new(0.26, 2.5 * big, 0.14), face * CFrame.new(0, 0, -0.8 * big), c.trim, METAL)
		P(ctx.left, "Boss", Vector3.new(0.3, 0.6, 0.6), face * CFrame.new(-0.1, 0, 0), c.glow, NEON)
		if w.p.gem then
			P(ctx.left, "Crest", Vector3.new(0.28, 1.2 * big, 0.12), face * CFrame.new(-0.08, 0.2, 0), c.trim, NEON)
		end
		-- and something to hit with in the other hand
		P(ctx.right, "Baton", Vector3.new(0.2, 0.2, 1.8), FORWARD * CFrame.new(0, 0, -0.6), c.grip, METAL)
		P(ctx.right, "BatonGrip", Vector3.new(0.24, 0.24, 0.5), FORWARD * CFrame.new(0, 0, 0.15), darker(c.grip, 0.3), FABRIC)
	end
	ctx.trail(ctx.left, main, face * CFrame.new(-0.2, 1.1, 0), face * CFrame.new(-0.2, -1.1, 0))
	ctx.focus(main)
end
-- buckler and a short sword: the kit's shield_buckler (a small disc, thin X)
BUILD.buckler = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local d = w.p.size or 1.35
	local face = CFrame.new(-0.62, -0.6, -0.05)
	local main = P(ctx.left, "Shield", Vector3.new(0.16, d, d), face, c.blade, METAL, "cyl")
	ctx.role(main, "shield_buckler")
	disc(ctx, ctx.left, "Rim", face * CFrame.new(0.05, 0, 0), d + 0.12, 0.12, c.trim, METAL, "x")
	P(ctx.left, "Boss", Vector3.new(0.46, 0.46, 0.46), face * CFrame.new(-0.1, 0, 0), c.trim, METAL, "ball")
	disc(ctx, ctx.left, "BossRing", face * CFrame.new(-0.09, 0, 0), 0.62, 0.03, c.glow, NEON, "x")
	if w.p.studs then
		for k = 0, 7 do
			local a = k / 8 * math.pi * 2
			P(ctx.left, "Stud" .. k, Vector3.new(0.12, 0.12, 0.12), face * CFrame.new(-0.08, math.sin(a) * d * 0.37, math.cos(a) * d * 0.37), c.trim, METAL, "ball")
		end
	end
	if w.p.gem then
		P(ctx.left, "Gem", Vector3.new(0.2, 0.2, 0.2), face * CFrame.new(-0.3, 0, 0), c.glow, NEON, "ball")
	end
	blade(ctx, ctx.right, FORWARD, w.p.len or 2.1, 0.3, { guard = 0.7, grip = 0.6, wrap = 2, gem = w.p.gem })
	ctx.focus(main)
end
-- the tower shield (a pavise) and a mace: the kit's shield_tower
BUILD.towershield = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local big = if w.p.big then 1.12 else 1
	local h, wd = 3.4 * big, 1.9 * big
	local face = CFrame.new(-0.68, -0.75, -0.1)
	local main = P(ctx.left, "Shield", Vector3.new(0.26, h, wd), face, c.blade, METAL)
	ctx.role(main, "shield_tower")
	for _, z in { -1, 1 } do
		P(ctx.left, "Rim" .. z, Vector3.new(0.3, h, 0.14), face * CFrame.new(0, 0, z * wd / 2), c.trim, METAL)
	end
	P(ctx.left, "RimTop", Vector3.new(0.3, 0.14, wd), face * CFrame.new(0, h / 2, 0), c.trim, METAL)
	P(ctx.left, "RimLow", Vector3.new(0.3, 0.14, wd), face * CFrame.new(0, -h / 2, 0), c.trim, METAL)
	P(ctx.left, "Slit", Vector3.new(0.3, 0.1, wd * 0.45), face * CFrame.new(0, h * 0.36, 0), Color3.fromRGB(12, 12, 16))
	P(ctx.left, "Spine", Vector3.new(0.3, h * 0.62, 0.16), face * CFrame.new(-0.01, -h * 0.08, 0), c.trim, METAL)
	P(ctx.left, "Emblem", Vector3.new(0.32, 0.5, 0.5), face * CFrame.new(-0.02, h * 0.08, 0) * CFrame.Angles(math.rad(45), 0, 0), c.glow, NEON)
	for _, y in { -1, 1 } do
		for _, z in { -1, 1 } do
			P(ctx.left, "Rivet", Vector3.new(0.12, 0.12, 0.12), face * CFrame.new(-0.13, y * h * 0.4, z * wd * 0.36), c.trim, METAL, "ball")
		end
	end
	if w.p.gem then
		P(ctx.left, "Gem", Vector3.new(0.24, 0.24, 0.24), face * CFrame.new(-0.2, h * 0.08, 0), c.glow, NEON, "ball")
	end
	-- the mace
	local len = 2.2
	P(ctx.right, "Haft", Vector3.new(0.16, len, 0.16), UPRIGHT * CFrame.new(0, len / 2 - 0.5, 0), c.grip, WOOD)
	local head = UPRIGHT * CFrame.new(0, len - 0.4, 0)
	P(ctx.right, "Ball", Vector3.new(0.55, 0.55, 0.55), head, c.trim, METAL, "ball")
	for k = 0, 3 do
		P(ctx.right, "Flange" .. k, Vector3.new(0.06, 0.5, 0.22), head * CFrame.Angles(0, k * R90, 0) * CFrame.new(0, 0, -0.28), c.trim, METAL)
	end
	ctx.trail(ctx.left, main, face * CFrame.new(-0.2, h / 2, 0), face * CFrame.new(-0.2, -h / 2, 0))
	ctx.focus(main)
end

-- ── chains and lashes ──────────────────────────────────────────────────────
BUILD.chainblade = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	blade(ctx, ctx.right, FORWARD, w.p.len or 2.4, 0.26, { guard = 0.6 })
	for k = 0, 5 do
		P(ctx.right, "Link" .. k, Vector3.new(0.12, 0.22, 0.12), HAND * CFrame.new(0.15, 0.25 + k * 0.2, 0.25) * CFrame.Angles(0, math.rad(k * 90), 0), c.trim, METAL)
	end
end
BUILD.chakram = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local s = w.p.size or 1.1
	for _, limb in { ctx.right, ctx.left } do
		-- held flat against the outside of the hand, the ring's face to the side
		local side = if limb == ctx.right then 1 else -1
		local at = HAND * CFrame.new(side * 0.22, -0.25, -0.25)
		local ring = disc(ctx, limb, "Ring", at, s, 0.08, c.blade, METAL, "x")
		disc(ctx, limb, "Hole", at, s * 0.62, 0.09, c.grip, METAL, "x")
		P(limb, "Glint", Vector3.new(0.1, s * 1.04, 0.05), at, c.glow, NEON)
		P(limb, "Grip", Vector3.new(0.12, 0.1, s * 0.6), at * CFrame.new(0, s * 0.36, 0), c.grip, LEATHER)
		if w.p.rays then
			for k = 0, 5 do
				local a = k / 6 * math.pi * 2
				P(limb, "Ray" .. k, Vector3.new(0.06, 0.18, 0.06), at * CFrame.Angles(a, 0, 0) * CFrame.new(0, s * 0.57, 0), c.glow, NEON)
			end
		end
		ctx.trail(limb, ring, at * CFrame.new(0, s * 0.5, 0), at * CFrame.new(0, -s * 0.5, 0))
		ctx.focus(ring)
	end
end
BUILD.kusarigama = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	-- the sickle in the right hand, the weight in the left, the chain between
	P(ctx.right, "Handle", Vector3.new(0.18, 0.18, 1.2), FORWARD * CFrame.new(0, 0, -0.3), c.grip, WOOD)
	local sickle = P(ctx.right, "Sickle", Vector3.new(0.08, 0.9, 0.24), FORWARD * CFrame.new(0, 0.4, -0.85) * CFrame.Angles(math.rad(-30), 0, 0), c.blade, METAL, "wedge")
	P(ctx.right, "SickleEdge", Vector3.new(0.09, 0.85, 0.04), FORWARD * CFrame.new(0, 0.38, -0.97) * CFrame.Angles(math.rad(-30), 0, 0), c.glow, NEON)
	for k = 0, 4 do
		P(ctx.left, "Link" .. k, Vector3.new(0.1, 0.2, 0.1), HAND * CFrame.new(0, 0.2 + k * 0.18, 0.2), c.trim, METAL)
	end
	P(ctx.left, "Weight", Vector3.new(0.35, 0.35, 0.35), HAND * CFrame.new(0, -0.25, -0.1), c.trim, METAL, "ball")
	ctx.trail(ctx.right, sickle, FORWARD * CFrame.new(0, 0.8, -1), FORWARD * CFrame.new(0, 0, -0.9))
	ctx.focus(sickle)
end
-- the whip: a handle, and a lash that falls forward and curls on the ground
BUILD.whip = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local limb = ctx.right
	local len = w.p.len or 5.5
	P(limb, "Handle", Vector3.new(0.18, 0.18, 0.95), FORWARD * CFrame.new(0, 0, 0.05), c.grip, LEATHER)
	P(limb, "Knob", Vector3.new(0.26, 0.26, 0.26), FORWARD * CFrame.new(0, 0, 0.55), c.trim, METAL, "ball")
	disc(ctx, limb, "Keeper", FORWARD * CFrame.new(0, 0, -0.42), 0.24, 0.1, c.trim, METAL)
	local n = 10
	local seg = len / n
	local bends = { -18, -16, -14, -8, -2, 6, 14, 20, 26, 30 }
	local cf = FORWARD * CFrame.new(0, 0, -0.45)
	local first
	for k = 1, n do
		cf = cf * CFrame.Angles(math.rad(bends[k]), math.rad(if k % 2 == 0 then 5 else -5), 0)
		local t = 0.13 - k * 0.008
		local p
		if w.p.chain then
			p = P(limb, "Link" .. k, Vector3.new(t * 0.6, t * 1.4, seg * 0.95), cf * CFrame.new(0, 0, -seg / 2) * CFrame.Angles(0, 0, if k % 2 == 0 then R90 else 0), c.blade, METAL)
		else
			p = P(limb, "Lash" .. k, Vector3.new(t, t, seg + 0.04), cf * CFrame.new(0, 0, -seg / 2), c.blade, LEATHER)
		end
		if w.p.thorns and k % 2 == 1 then
			P(limb, "Thorn" .. k, Vector3.new(0.05, 0.14, 0.1), cf * CFrame.new(0, t / 2 + 0.05, -seg / 2), c.glow, METAL, "wedge")
		end
		first = first or p
		cf = cf * CFrame.new(0, 0, -seg)
	end
	if w.p.chain then
		point2(ctx, limb, "Dart", cf, 0.24, 0.4, 0.06, c.trim, METAL)
	end
	P(limb, "Popper", Vector3.new(0.12, 0.12, 0.12), cf, c.glow, NEON, "ball")
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.16, 0.16, 0.16), FORWARD * CFrame.new(0, 0, 0.72), c.glow, NEON, "ball")
	end
	ctx.trail(limb, first, cf, FORWARD * CFrame.new(0, 0, -0.5))
	ctx.focus(first)
end

WeaponModels.FAMILY_LIST = {}
for id in BUILD do
	table.insert(WeaponModels.FAMILY_LIST, id)
end
table.sort(WeaponModels.FAMILY_LIST)
WeaponModels.BUILDERS = BUILD

-- ── effects ────────────────────────────────────────────────────────────────
local function cs(a: Color3, b: Color3): ColorSequence
	return ColorSequence.new(a, b)
end
local function ns(a: number, b: number): NumberSequence
	return NumberSequence.new(a, b)
end
local function emitter(part: BasePart, name: string, o: any): ParticleEmitter
	local pe = Instance.new("ParticleEmitter")
	pe.Name = name
	pe.Texture = o.tex or SPARKLE
	pe.Color = o.color
	pe.LightEmission = o.emission or 1
	pe.LightInfluence = o.influence or 0
	pe.Rate = o.rate
	pe.Lifetime = NumberRange.new(o.life[1], o.life[2])
	pe.Speed = NumberRange.new(o.speed[1], o.speed[2])
	pe.SpreadAngle = Vector2.new(o.spread or 180, o.spread or 180)
	pe.Size = o.size
	pe.Transparency = o.transp or ns(0.15, 1)
	pe.Acceleration = o.accel or Vector3.zero
	pe.Drag = o.drag or 0
	pe.Rotation = NumberRange.new(0, 360)
	pe.RotSpeed = NumberRange.new(-(o.spin or 40), o.spin or 40)
	pe.EmissionDirection = o.dir or Enum.NormalId.Top
	if o.streak then
		pe.Orientation = Enum.ParticleOrientation.VelocityParallel
	end
	pe.Parent = part
	return pe
end

-- what each element throws off: { primary, secondary (★★ and up) }, at stars-scaled size k and
-- rate r. col/deep/light: the element's colours; glow: the weapon's own glow.
local AURA = {
	fire = function(k, r, e)
		return {
			{ tex = FIRE_TEX, color = cs(e.light, e.deep), size = ns(0.3 * k, 0.04), life = { 0.3, 0.6 }, speed = { 0.3, 0.9 }, accel = Vector3.new(0, 3.5, 0), rate = r, spread = 14, transp = ns(0.25, 1) },
			{ color = cs(e.color, e.deep), size = ns(0.13 * k, 0), life = { 0.6, 1.2 }, speed = { 0.6, 1.6 }, accel = Vector3.new(0, 2.5, 0), rate = r * 0.8, spread = 60, drag = 1 },
		}
	end,
	frost = function(k, r, e)
		return {
			{ tex = SMOKE, color = cs(e.light, e.color), size = ns(0.25 * k, 0.6 * k), life = { 1, 1.6 }, speed = { 0.1, 0.4 }, accel = Vector3.new(0, -0.6, 0), rate = r * 0.8, emission = 0.25, transp = ns(0.65, 1) },
			{ color = cs(e.light, e.light), size = ns(0.16 * k, 0), life = { 0.4, 0.8 }, speed = { 0, 0.3 }, rate = r * 0.7 },
		}
	end,
	lightning = function(k, r, e)
		return {
			{ color = cs(e.light, e.color), size = ns(0.14 * k, 0), life = { 0.06, 0.16 }, speed = { 4, 8 }, rate = r * 1.3, streak = true },
			{ color = cs(e.deep, e.light), size = ns(0.3 * k, 0), life = { 0.05, 0.1 }, speed = { 0, 0.2 }, rate = r * 0.6 },
		}
	end,
	venom = function(k, r, e)
		return {
			{ color = cs(e.light, e.color), size = ns(0.14 * k, 0.05), life = { 0.5, 0.9 }, speed = { 0, 0.2 }, accel = Vector3.new(0, -7, 0), rate = r, emission = 0.6, spread = 20, dir = Enum.NormalId.Bottom },
			{ tex = SMOKE, color = cs(e.color, e.deep), size = ns(0.2 * k, 0.5 * k), life = { 0.8, 1.4 }, speed = { 0.1, 0.3 }, accel = Vector3.new(0, 0.5, 0), rate = r * 0.5, emission = 0.3, transp = ns(0.75, 1) },
		}
	end,
	void = function(k, r, e)
		return {
			{ color = cs(e.light, e.color), size = ns(0.2 * k, 0), life = { 0.9, 1.5 }, speed = { 0.2, 0.6 }, accel = Vector3.new(0, 0.6, 0), rate = r, emission = 0.8, spin = 120 },
			{ tex = SMOKE, color = cs(e.color, e.deep), size = ns(0.3 * k, 0.7 * k), life = { 0.8, 1.3 }, speed = { 0, 0.3 }, rate = r * 0.5, emission = 0, transp = ns(0.6, 1) },
		}
	end,
	holy = function(k, r, e)
		return {
			{ color = cs(e.light, e.color), size = ns(0.2 * k, 0), life = { 1, 1.8 }, speed = { 0.2, 0.5 }, accel = Vector3.new(0, 1.4, 0), rate = r },
			{ color = cs(e.light, e.deep), size = ns(0.45 * k, 0), life = { 0.3, 0.5 }, speed = { 0, 0.1 }, rate = r * 0.5, transp = ns(0.5, 1) },
		}
	end,
	wind = function(k, r, e)
		return {
			{ color = cs(e.light, e.color), size = ns(0.1 * k, 0), life = { 0.25, 0.45 }, speed = { 3, 5 }, rate = r * 1.2, spread = 30, dir = Enum.NormalId.Front, streak = true, emission = 0.6, transp = ns(0.3, 1) },
			{ color = cs(e.color, e.deep), size = ns(0.12 * k, 0.1 * k), life = { 0.8, 1.2 }, speed = { 1, 2 }, accel = Vector3.new(0, -0.5, 0), rate = r * 0.4, emission = 0.4, spin = 200 },
		}
	end,
	earth = function(k, r, e)
		return {
			{ tex = SMOKE, color = cs(e.light, e.deep), size = ns(0.18 * k, 0.4 * k), life = { 0.6, 1 }, speed = { 0.1, 0.4 }, accel = Vector3.new(0, -2.5, 0), rate = r * 0.8, emission = 0, transp = ns(0.55, 1) },
			{ color = cs(e.color, e.deep), size = ns(0.12 * k, 0), life = { 0.5, 1 }, speed = { 0.3, 0.8 }, accel = Vector3.new(0, -3, 0), rate = r * 0.6, emission = 0.8 },
		}
	end,
	none = function(k, r, e)
		return {
			{ color = cs(e.glow, e.light), size = ns(0.15 * k, 0), life = { 0.5, 1 }, speed = { 0.1, 0.4 }, rate = r * 0.5 },
		}
	end,
}
WeaponModels.AURA_ELEMENTS = AURA

local K_SIZE = { 0.75, 1, 1.3 }
local K_RATE = { 1.5, 3.5, 8 }
local TRAIL_LIFE = { 0.12, 0.2, 0.3 }
local TRAIL_ALPHA = { 0.55, 0.35, 0.15 }
-- the families whose weapon is itself a light (a lamp, a censer, a crystal): a faint light at ★
local LAMPS = { censer = true, thurible = true, crystal = true, orb = true }

local function addTrail(part: BasePart, top: Attachment, bottom: Attachment, stars: number, shiny: boolean, e: any, gold: Color3)
	local t = Instance.new("Trail")
	t.Name = "WeaponTrail"
	t.Attachment0 = top
	t.Attachment1 = bottom
	t.Enabled = false
	t.FaceCamera = false
	t.Lifetime = TRAIL_LIFE[stars] + (if shiny then 0.06 else 0)
	t.MinLength = 0.05
	t.LightEmission = 0.5 + stars * 0.17
	t.LightInfluence = 0
	t.Color = if shiny then cs(gold, e.color) else cs(e.light, e.color)
	t.Transparency = ns(TRAIL_ALPHA[stars], 1)
	t.WidthScale = ns(1, 0.25)
	t.Parent = part
	return t
end

-- take a weapon off a rig: its parts, the kit's meshes over them, its attributes
function WeaponModels.detach(model: Model)
	for _, d in model:GetChildren() do
		if d:IsA("BasePart") then
			local weld = d:FindFirstChildOfClass("WeldConstraint")
			local over = weld and weld.Part0
			if d:GetAttribute("WeaponPiece") or (d:IsA("MeshPart") and over and over:GetAttribute("WeaponPiece")) then
				d:Destroy()
			end
		end
	end
	for _, key in { "WeaponBase", "WeaponFamily", "WeaponElement", "WeaponStars", "WeaponShiny", "WeaponClass", "WeaponGrade", "WeaponStyle" } do
		model:SetAttribute(key, nil)
	end
end

-- put a weapon in a rig's hands; returns the pieces
function WeaponModels.attach(model: Model, base: string, stars: number?, shiny: boolean?): { BasePart }
	local w = Weapons.byId[base]
	local right = model:FindFirstChild("Right Arm") :: BasePart?
	local left = model:FindFirstChild("Left Arm") :: BasePart?
	if not w or not right or not left then
		return {}
	end
	if model:GetAttribute("WeaponBase") ~= nil then
		WeaponModels.detach(model)
	end
	local nStars = math.clamp(math.floor(stars or 1), 1, 3)
	local isShiny = shiny == true
	local fam = Weapons.FAMILIES[w.family]
	local made: { BasePart } = {}
	local gold = Color3.fromRGB(255, 214, 110)
	local colors = {
		blade = c3(w.c[1]),
		grip = c3(w.c[2]),
		trim = if isShiny then gold else c3(w.c[3]),
		glow = c3(w.c[4]),
	}
	local el = Weapons.ELEMENTS[w.element] or Weapons.ELEMENTS.none
	local elementColors = {
		color = if w.element == "none" then colors.glow else c3(el.color),
		deep = if w.element == "none" then colors.glow:Lerp(Color3.new(0, 0, 0), 0.4) else c3(el.deep),
		light = c3(el.light),
		glow = colors.glow,
	}
	local trails, foci = {}, {}
	local sockets = 0
	local ctx: any = {
		right = right,
		left = left,
		torso = model:FindFirstChild("Torso"),
		colors = colors,
		edge = nStars >= 2,
		cover = nil,
	}
	ctx.piece = function(limb, name, size, offset, color, material, kind)
		-- a ★ weapon's glow parts are muted; ★★ and up burn (lamps and cores always glow)
		local mat = material
		if mat == NEON and nStars == 1 and not isShiny then
			local keep = false
			for _, k in { "Orb", "Flame", "Crystal", "Core", "Sun", "Vent", "Sigil" } do
				if string.find(name, k, 1, true) then
					keep = true
					break
				end
			end
			if not keep then
				mat = METAL
			end
		end
		local p = piece(model, limb, name, size, offset, color, mat, kind)
		if ctx.cover then
			p:SetAttribute("MeshCover", ctx.cover)
		end
		table.insert(made, p)
		return p
	end
	ctx.role = function(p: BasePart, role: string)
		p:SetAttribute("MeshRole", role)
	end
	ctx.socket = function(limb, name, size, offset, role, color, material, kind)
		local p = ctx.piece(limb, name, size, offset, color, material, kind)
		sockets += 1
		local id = name .. sockets
		p:SetAttribute("MeshRole", role)
		p:SetAttribute("MeshId", id)
		local sm = Instance.new("SpecialMesh")
		sm.Name = "FallbackShape"
		sm.MeshType = Enum.MeshType.Brick
		sm.Scale = Vector3.new(0.001, 0.001, 0.001) -- drawn by its MeshCover parts until the kit dresses it
		sm.Parent = p
		ctx.cover = id
		return p
	end
	ctx.trail = function(limb, p: BasePart, tip: CFrame, root: CFrame)
		local top = Instance.new("Attachment")
		top.Name = "TrailTop"
		top.CFrame = CFrame.new(p.CFrame:PointToObjectSpace((limb.CFrame * tip).Position))
		top.Parent = p
		local bottom = Instance.new("Attachment")
		bottom.Name = "TrailBottom"
		bottom.CFrame = CFrame.new(p.CFrame:PointToObjectSpace((limb.CFrame * root).Position))
		bottom.Parent = p
		table.insert(trails, { part = p, top = top, bottom = bottom })
	end
	ctx.focus = function(p: BasePart)
		table.insert(foci, p)
	end
	local build = BUILD[w.family] or BUILD.sword
	build(ctx, w)
	ctx.cover = nil

	-- the swing trail(s)
	if #trails == 0 and #made > 0 then
		local p = made[1]
		local top = Instance.new("Attachment")
		top.Name = "TrailTop"
		top.CFrame = CFrame.new(0, 0, -p.Size.Z / 2)
		top.Parent = p
		local bottom = Instance.new("Attachment")
		bottom.Name = "TrailBottom"
		bottom.CFrame = CFrame.new(0, 0, p.Size.Z / 2)
		bottom.Parent = p
		table.insert(trails, { part = p, top = top, bottom = bottom })
	end
	for _, t in trails do
		addTrail(t.part, t.top, t.bottom, nStars, isShiny, elementColors, gold)
	end
	-- the aura: the element's emitters on the focus part(s), split between them
	if #foci == 0 and #made > 0 then
		table.insert(foci, made[#made])
	end
	local specs = (AURA[w.element] or AURA.none)(K_SIZE[nStars], K_RATE[nStars], elementColors)
	local count = if w.element == "none" then (if nStars >= 2 then 1 else 0) else (if nStars >= 2 then 2 else 1)
	for i = 1, math.min(count, #specs) do
		for _, f in foci do
			local spec = table.clone(specs[i])
			spec.rate = spec.rate / #foci
			emitter(f, if i == 1 then "WeaponAura" else "WeaponAura2", spec)
		end
	end
	local core = foci[1]
	if core and isShiny then
		emitter(core, "WeaponShine", { color = cs(gold, elementColors.color), size = ns(0.3, 0), life = { 0.5, 1 }, speed = { 0.5, 1.5 }, rate = 4 + nStars * 2 })
	end
	-- the light: dim at ★★, real at ★★★, gold-tinged when shiny (lamps glow at ★ too)
	if core and (nStars >= 2 or isShiny or LAMPS[w.family]) then
		local light = Instance.new("PointLight")
		light.Name = "WeaponLight"
		light.Shadows = false
		light.Color = if isShiny then elementColors.color:Lerp(gold, 0.5) else elementColors.color
		light.Range = if isShiny then 10 elseif nStars == 3 then 8 elseif nStars == 2 then 5 else 4
		light.Brightness = if isShiny then 2 elseif nStars == 3 then 1.6 elseif nStars == 2 then 0.7 else 0.5
		light.Parent = core
	end

	model:SetAttribute("WeaponBase", w.id)
	model:SetAttribute("WeaponFamily", w.family)
	model:SetAttribute("WeaponElement", w.element)
	model:SetAttribute("WeaponStars", nStars)
	model:SetAttribute("WeaponShiny", isShiny)
	model:SetAttribute("WeaponClass", w.class)
	model:SetAttribute("WeaponGrade", w.grade)
	model:SetAttribute("WeaponStyle", if fam then fam.fx else "slash")
	return made
end

return WeaponModels
