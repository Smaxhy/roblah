--[[
	WEAPON MODELS (BitLeveling): every weapon in Hunter/Weapons.luau as a 3D model on an R6
	rig, built from Parts and WedgeParts welded to the hand (or both hands, or the left arm for
	a shield). One builder per family; each weapon's colours and shape knobs (Weapons.list
	c and p) make it its own. Rarity shows: ★★ edges glow, ★★★ the weapon gives light, and a
	Shiny one shimmers gold and throws off sparkles.

		WeaponModels.attach(model, base, stars, shiny)   -- on a rig built by R6Rig
		WeaponModels.FAMILY_LIST                          -- the families it can draw
]]

local Weapons = require(script.Parent:WaitForChild("Weapons"))

local WeaponModels = {}

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"

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
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CFrame = limb.CFrame * offset
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

local METAL = Enum.Material.Metal
local NEON = Enum.Material.Neon
local WOOD = Enum.Material.Wood

-- ── blades ─────────────────────────────────────────────────────────────────
-- a straight blade along -Z from the hand: grip, guard, body, a wedge for the point
local function blade(ctx, limb, at: CFrame, len: number, width: number, opts: any?)
	opts = opts or {}
	local P = ctx.piece
	local c = ctx.colors
	local thick = opts.thick or 0.09
	local gripLen = opts.grip or 0.75
	P(limb, "Grip", Vector3.new(0.2, 0.2, gripLen), at * CFrame.new(0, 0, gripLen / 2 - 0.15), c.grip, Enum.Material.Fabric)
	P(limb, "Pommel", Vector3.new(0.28, 0.28, 0.28), at * CFrame.new(0, 0, gripLen - 0.1), c.trim, METAL, "ball")
	if not opts.noGuard then
		P(limb, "Guard", Vector3.new(opts.guard or (width * 2.6 + 0.25), 0.16, 0.18), at * CFrame.new(0, 0, -0.25), c.trim, METAL)
	end
	local bodyLen = len * 0.86
	local body = at * CFrame.new(0, 0, -0.32 - bodyLen / 2)
	if opts.curve and opts.curve > 0 then
		-- a curved blade: three segments, each turned a little more
		local seg = bodyLen / 3
		local cf = at * CFrame.new(0, 0, -0.32)
		for k = 1, 3 do
			cf = cf * CFrame.Angles(math.rad(opts.curve * 9), 0, 0)
			P(limb, "Blade" .. k, Vector3.new(thick, width, seg + 0.05), cf * CFrame.new(0, 0, -seg / 2), c.blade, METAL)
			if ctx.edge then
				P(limb, "Edge" .. k, Vector3.new(thick * 0.6, 0.05, seg), cf * CFrame.new(0, -width / 2, -seg / 2), c.glow, NEON)
			end
			cf = cf * CFrame.new(0, 0, -seg)
		end
		P(limb, "Point", Vector3.new(thick, width, len * 0.16), cf * CFrame.Angles(math.rad(opts.curve * 9), 0, 0) * CFrame.new(0, 0, -len * 0.08), c.blade, METAL, "wedge")
		return
	end
	P(limb, "Blade", Vector3.new(thick, width, bodyLen), body, c.blade, METAL)
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
end

local BUILD = {}

BUILD.dagger = function(ctx, w)
	blade(ctx, ctx.right, FORWARD, (w.p.len or 1) * 1.1, 0.2, { grip = 0.55, guard = 0.5, curve = w.p.curve, wave = w.p.wave })
end
BUILD.daggers = function(ctx, w)
	blade(ctx, ctx.right, FORWARD, (w.p.len or 1) * 1.1, 0.18, { grip = 0.5, guard = 0.45 })
	blade(ctx, ctx.left, FORWARD, (w.p.len or 1) * 1.1, 0.18, { grip = 0.5, guard = 0.45 })
end
BUILD.sword = function(ctx, w)
	blade(ctx, ctx.right, FORWARD, w.p.len or 3, w.p.width or 0.32, { fuller = w.p.fuller, gem = w.p.gem, notched = w.p.notched, curve = w.p.curve })
end
BUILD.katana = function(ctx, w)
	blade(ctx, ctx.right, FORWARD, w.p.len or 3.2, 0.2, { curve = 0.35, guard = 0.42, grip = 1 })
	ctx.piece(ctx.right, "Tsuba", Vector3.new(0.44, 0.44, 0.06), FORWARD * CFrame.new(0, 0, -0.25), ctx.colors.trim, METAL, "cyl")
end
BUILD.greatsword = function(ctx, w)
	blade(ctx, ctx.right, FORWARD, w.p.len or 4.4, w.p.width or 0.62, { thick = 0.14, grip = 1.2, fuller = true, gem = w.p.gem })
end
BUILD.cleaver = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len, wid = w.p.len or 2, w.p.width or 0.9
	P(ctx.right, "Grip", Vector3.new(0.22, 0.22, 0.9), FORWARD * CFrame.new(0, 0, 0.3), c.grip, Enum.Material.Fabric)
	P(ctx.right, "Blade", Vector3.new(0.12, wid, len), FORWARD * CFrame.new(0, -wid / 2 + 0.1, -len / 2 - 0.1), c.blade, METAL)
	P(ctx.right, "Spine", Vector3.new(0.16, 0.12, len), FORWARD * CFrame.new(0, 0.12, -len / 2 - 0.1), c.trim, METAL)
	P(ctx.right, "Edge", Vector3.new(0.13, 0.06, len), FORWARD * CFrame.new(0, -wid + 0.13, -len / 2 - 0.1), c.glow, NEON)
	P(ctx.right, "Hole", Vector3.new(0.14, 0.22, 0.22), FORWARD * CFrame.new(0, -0.15, -len + 0.1), c.grip, METAL, "cyl")
end
BUILD.rapier = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	blade(ctx, ctx.right, FORWARD, w.p.len or 3.6, 0.1, { thick = 0.08, guard = 0.3 })
	-- the swept hilt: a ring and a cup
	P(ctx.right, "Cup", Vector3.new(0.12, 0.55, 0.55), FORWARD * CFrame.new(0, 0, -0.2) * CFrame.Angles(0, math.rad(90), 0), c.trim, METAL, "cyl")
	P(ctx.right, "Bow", Vector3.new(0.06, 0.06, 0.7), FORWARD * CFrame.new(0.22, 0, 0.1), c.trim, METAL)
end

-- ── pole weapons (held upright: the shaft runs along Y through the hand) ───
local function shaft(ctx, limb, len: number, below: number?)
	local c = ctx.colors
	ctx.piece(limb, "Shaft", Vector3.new(0.17, len, 0.17), UPRIGHT * CFrame.new(0, len / 2 - (below or 1), 0), c.grip, WOOD)
	ctx.piece(limb, "Cap", Vector3.new(0.22, 0.22, 0.22), UPRIGHT * CFrame.new(0, -(below or 1), 0), c.trim, METAL, "ball")
	return UPRIGHT * CFrame.new(0, len - (below or 1), 0) -- the top of the shaft
end
BUILD.spear = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local top = shaft(ctx, ctx.right, w.p.len or 6)
	if w.p.lance then
		for k = 0, 3 do
			local r = 0.7 - k * 0.15
			P(ctx.right, "Cone" .. k, Vector3.new(0.5, r, r), top * CFrame.new(0, 0.25 + k * 0.45, 0) * CFrame.Angles(0, 0, math.rad(90)), c.blade, METAL, "cyl")
		end
		P(ctx.right, "Vamplate", Vector3.new(0.12, 1.1, 1.1), top * CFrame.Angles(0, 0, math.rad(90)), c.trim, METAL, "cyl")
		return
	end
	-- the head: two wedges back to back make a diamond
	P(ctx.right, "Socket", Vector3.new(0.22, 0.4, 0.22), top * CFrame.new(0, 0.15, 0), c.trim, METAL)
	P(ctx.right, "HeadA", Vector3.new(0.08, 0.9, 0.36), top * CFrame.new(0, 0.8, 0), c.blade, METAL, "wedge")
	P(ctx.right, "HeadB", Vector3.new(0.08, 0.3, 0.36), top * CFrame.new(0, 0.2, 0) * CFrame.Angles(math.rad(180), 0, 0), c.blade, METAL, "wedge")
	P(ctx.right, "Tassel", Vector3.new(0.26, 0.26, 0.26), top * CFrame.new(0, -0.15, 0), c.glow, NEON, "ball")
	if w.p.prongs then
		for _, s in { -1, 1 } do
			P(ctx.right, "Prong", Vector3.new(0.07, 0.6, 0.12), top * CFrame.new(0, 0.55, s * 0.32) * CFrame.Angles(math.rad(s * 16), 0, 0), c.glow, NEON)
		end
	end
end
BUILD.halberd = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local top = shaft(ctx, ctx.right, w.p.len or 6.4)
	P(ctx.right, "Spike", Vector3.new(0.08, 0.9, 0.24), top * CFrame.new(0, 0.6, 0), c.blade, METAL, "wedge")
	P(ctx.right, "Axe", Vector3.new(0.09, 0.95, 0.9), top * CFrame.new(0, -0.2, -0.5), c.blade, METAL)
	P(ctx.right, "AxeEdge", Vector3.new(0.1, 1, 0.08), top * CFrame.new(0, -0.2, -0.96), c.glow, NEON)
	P(ctx.right, "Hook", Vector3.new(0.08, 0.3, 0.45), top * CFrame.new(0, -0.15, 0.3), c.trim, METAL, "wedge")
end
BUILD.scythe = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local top = shaft(ctx, ctx.right, w.p.len or 5.2, 1.4)
	-- the crescent: four segments sweeping forward and down
	local cf = top * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0)
	for k = 1, 4 do
		cf = cf * CFrame.Angles(math.rad(-22), 0, 0)
		P(ctx.right, "Crescent" .. k, Vector3.new(0.08, 0.42 - k * 0.05, 0.75), cf * CFrame.new(0, 0, -0.38), c.blade, METAL)
		P(ctx.right, "CrescentEdge" .. k, Vector3.new(0.09, 0.05, 0.75), cf * CFrame.new(0, -(0.42 - k * 0.05) / 2, -0.38), c.glow, NEON)
		cf = cf * CFrame.new(0, 0, -0.72)
	end
	P(ctx.right, "Collar", Vector3.new(0.26, 0.3, 0.26), top, c.trim, METAL)
end
BUILD.axe = function(ctx, w, limb, at)
	local P, c = ctx.piece, ctx.colors
	limb = limb or ctx.right
	at = at or UPRIGHT
	local len = w.p.len or 2.6
	P(limb, "Haft", Vector3.new(0.18, len, 0.18), at * CFrame.new(0, len / 2 - 0.5, 0), c.grip, WOOD)
	local head = at * CFrame.new(0, len - 0.8, 0)
	P(limb, "Bit", Vector3.new(0.1, 0.8, 0.7), head * CFrame.new(0, 0, -0.45), c.blade, METAL)
	P(limb, "BitEdge", Vector3.new(0.11, 0.85, 0.07), head * CFrame.new(0, 0, -0.82), c.glow, NEON)
	if w.p.double then
		P(limb, "Bit2", Vector3.new(0.1, 0.8, 0.7), head * CFrame.new(0, 0, 0.45), c.blade, METAL)
		P(limb, "BitEdge2", Vector3.new(0.11, 0.85, 0.07), head * CFrame.new(0, 0, 0.82), c.glow, NEON)
	end
	P(limb, "Eye", Vector3.new(0.26, 0.3, 0.3), head, c.trim, METAL)
	if w.p.gem then
		P(limb, "Gem", Vector3.new(0.2, 0.2, 0.2), head * CFrame.new(0.14, 0, 0), c.glow, NEON, "ball")
	end
end
BUILD.axes = function(ctx, w)
	BUILD.axe(ctx, w, ctx.right, UPRIGHT)
	BUILD.axe(ctx, w, ctx.left, UPRIGHT)
end
BUILD.hammer = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 3.4
	local big = if w.p.big then 1.35 else 1
	P(ctx.right, "Haft", Vector3.new(0.2, len, 0.2), UPRIGHT * CFrame.new(0, len / 2 - 0.6, 0), c.grip, WOOD)
	local head = UPRIGHT * CFrame.new(0, len - 0.7, 0)
	P(ctx.right, "Head", Vector3.new(0.8 * big, 0.8 * big, 1.5 * big), head, c.blade, METAL)
	for _, z in { -0.62, 0.62 } do
		P(ctx.right, "Band", Vector3.new(0.84 * big, 0.84 * big, 0.1), head * CFrame.new(0, 0, z * big), c.trim, METAL)
	end
	P(ctx.right, "Face", Vector3.new(0.6 * big, 0.6 * big, 0.06), head * CFrame.new(0, 0, -0.77 * big), c.glow, NEON)
	if w.p.gem then
		P(ctx.right, "Gem", Vector3.new(0.3, 0.3, 0.3), head * CFrame.new(0.42 * big, 0, 0), c.glow, NEON, "ball")
	end
end
BUILD.mace = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 2.4
	P(ctx.right, "Haft", Vector3.new(0.18, len, 0.18), UPRIGHT * CFrame.new(0, len / 2 - 0.5, 0), c.grip, WOOD)
	local head = UPRIGHT * CFrame.new(0, len - 0.4, 0)
	P(ctx.right, "Ball", Vector3.new(0.75, 0.75, 0.75), head, c.blade, METAL, "ball")
	local n = if w.p.spikes then 8 else 4
	for k = 0, n - 1 do
		local a = k / n * math.pi * 2
		P(ctx.right, "Spike" .. k, Vector3.new(0.12, 0.34, 0.18), head * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -0.42) * CFrame.Angles(math.rad(-90), 0, 0), c.trim, METAL, "wedge")
	end
	if w.p.spikes then
		P(ctx.right, "Crown", Vector3.new(0.14, 0.36, 0.14), head * CFrame.new(0, 0.45, 0), c.trim, METAL)
	end
end

-- ── magic ──────────────────────────────────────────────────────────────────
BUILD.staff = function(ctx, w, limb)
	local P, c = ctx.piece, ctx.colors
	limb = limb or ctx.right
	local top = shaft(ctx, limb, w.p.len or 5, 1.2)
	P(limb, "Orb", Vector3.new(0.55, 0.55, 0.55), top * CFrame.new(0, 0.5, 0), c.glow, NEON, "ball")
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
			P(limb, "Ring" .. k, Vector3.new(0.06, 0.95 + k * 0.18, 0.95 + k * 0.18), top * CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(k * 50), math.rad(k * 35), 0), c.trim, NEON, "cyl").Transparency = 0.45
		end
	end
end
BUILD.rod = function(ctx, w)
	BUILD.staff(ctx, w)
end
BUILD.wand = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 1.6
	P(ctx.right, "Wand", Vector3.new(0.12, 0.12, len), FORWARD * CFrame.new(0, 0, -len / 2 + 0.3), c.blade, WOOD)
	P(ctx.right, "Band", Vector3.new(0.16, 0.16, 0.12), FORWARD * CFrame.new(0, 0, 0.05), c.trim, METAL)
	P(ctx.right, "Crystal", Vector3.new(0.18, 0.18, 0.4), FORWARD * CFrame.new(0, 0, -len + 0.1), c.glow, NEON)
end
BUILD.orb = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local s = w.p.size or 0.8
	local at = HAND * CFrame.new(0, -0.6, -0.5)
	P(ctx.right, "Orb", Vector3.new(s, s, s), at, c.glow, NEON, "ball").Transparency = 0.15
	P(ctx.right, "Shell", Vector3.new(s * 1.15, s * 1.15, s * 1.15), at, c.blade, Enum.Material.Glass, "ball").Transparency = 0.6
	P(ctx.right, "Halo", Vector3.new(0.05, s * 1.6, s * 1.6), at * CFrame.Angles(0, 0, math.rad(70)), c.trim, NEON, "cyl").Transparency = 0.3
end
BUILD.tome = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local s = w.p.size or 1
	local at = HAND * CFrame.new(0, -0.3, -0.45) * CFrame.Angles(math.rad(-60), 0, 0)
	P(ctx.right, "Cover", Vector3.new(0.9 * s, 1.15 * s, 0.32 * s), at, c.blade, Enum.Material.Leather)
	P(ctx.right, "Pages", Vector3.new(0.82 * s, 1.07 * s, 0.26 * s), at * CFrame.new(0.05, 0, 0), Color3.fromRGB(238, 228, 200))
	P(ctx.right, "Rune", Vector3.new(0.4 * s, 0.4 * s, 0.04), at * CFrame.new(0, 0, -0.17 * s), c.glow, NEON)
	P(ctx.right, "Clasp", Vector3.new(0.1, 0.3 * s, 0.36 * s), at * CFrame.new(0.46 * s, 0, 0), c.trim, METAL)
end
BUILD.censer = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	for k = 0, 3 do
		P(ctx.right, "Chain" .. k, Vector3.new(0.06, 0.22, 0.06), HAND * CFrame.new(0, -0.15 - k * 0.22, -0.1), c.trim, METAL)
	end
	local lamp = HAND * CFrame.new(0, -1.25, -0.1)
	P(ctx.right, "Cage", Vector3.new(0.6, 0.75, 0.6), lamp, c.blade, Enum.Material.Glass).Transparency = 0.35
	P(ctx.right, "Flame", Vector3.new(0.32, 0.42, 0.32), lamp, c.glow, NEON, "ball")
	P(ctx.right, "Top", Vector3.new(0.7, 0.12, 0.7), lamp * CFrame.new(0, 0.42, 0), c.trim, METAL)
	P(ctx.right, "Base", Vector3.new(0.7, 0.12, 0.7), lamp * CFrame.new(0, -0.42, 0), c.trim, METAL)
end

-- ── ranged ─────────────────────────────────────────────────────────────────
BUILD.bow = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local len = w.p.len or 3.6
	local limb = ctx.left
	local grip = HAND * CFrame.new(0, 0.05, -0.15)
	P(limb, "Grip", Vector3.new(0.18, 0.5, 0.2), grip, c.grip, Enum.Material.Leather)
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
	P(limb, "String", Vector3.new(0.03, len * 0.9, 0.03), grip * CFrame.new(0, 0, 0.55), c.glow, NEON)
	if ctx.torso then
		P(ctx.torso, "Quiver", Vector3.new(0.45, 1.6, 0.45), CFrame.new(0.5, 0.25, 0.7) * CFrame.Angles(0, 0, math.rad(-20)), c.grip, Enum.Material.Leather)
	end
end
BUILD.crossbow = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local at = FORWARD * CFrame.new(0, 0.1, -0.3)
	P(ctx.right, "Stock", Vector3.new(0.22, 0.26, 2), at * CFrame.new(0, 0, -0.5), c.grip, WOOD)
	P(ctx.right, "Prod", Vector3.new(2.2, 0.14, 0.16), at * CFrame.new(0, 0.05, -1.3), c.blade, METAL)
	P(ctx.right, "String", Vector3.new(2.1, 0.03, 0.03), at * CFrame.new(0, 0.05, -0.9), c.glow, NEON)
	P(ctx.right, "Bolt", Vector3.new(0.06, 0.06, 1.4), at * CFrame.new(0, 0.18, -1), c.trim, METAL)
	P(ctx.right, "Magazine", Vector3.new(0.3, 0.35, 0.8), at * CFrame.new(0, 0.32, -0.6), c.trim, METAL)
end

-- ── hands ──────────────────────────────────────────────────────────────────
local function fist(ctx, limb, w, claws: boolean)
	local P, c = ctx.piece, ctx.colors
	local big = if w.p.big then 1.2 else 1
	P(limb, "Gauntlet", Vector3.new(1.14 * big, 0.95, 1.14 * big), CFrame.new(0, -0.6, 0), c.blade, METAL)
	P(limb, "Cuff", Vector3.new(1.18 * big, 0.14, 1.18 * big), CFrame.new(0, -0.12, 0), c.trim, METAL)
	P(limb, "Knuckle", Vector3.new(1.18 * big, 0.22, 0.3), CFrame.new(0, -0.95, -0.5 * big), c.glow, NEON)
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
end
BUILD.gauntlets = function(ctx, w)
	fist(ctx, ctx.right, w, false)
	fist(ctx, ctx.left, w, false)
end
BUILD.claws = function(ctx, w)
	fist(ctx, ctx.right, w, true)
	fist(ctx, ctx.left, w, true)
end
BUILD.shield = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	local big = if w.p.big then 1.25 else 1
	local face = CFrame.new(-0.65, -0.5, -0.1)
	P(ctx.left, "Shield", Vector3.new(0.22, 2.4 * big, 1.6 * big), face, c.blade, METAL)
	P(ctx.left, "Rim", Vector3.new(0.26, 2.5 * big, 0.14), face * CFrame.new(0, 0, 0.8 * big), c.trim, METAL)
	P(ctx.left, "Rim2", Vector3.new(0.26, 2.5 * big, 0.14), face * CFrame.new(0, 0, -0.8 * big), c.trim, METAL)
	P(ctx.left, "Boss", Vector3.new(0.3, 0.6, 0.6), face * CFrame.new(-0.1, 0, 0), c.glow, NEON)
	if w.p.gem then
		P(ctx.left, "Crest", Vector3.new(0.28, 1.2 * big, 0.12), face * CFrame.new(-0.08, 0.2, 0), c.trim, NEON)
	end
	-- and something to hit with in the other hand
	P(ctx.right, "Baton", Vector3.new(0.2, 0.2, 1.8), FORWARD * CFrame.new(0, 0, -0.6), c.grip, METAL)
end

-- ── exotic ─────────────────────────────────────────────────────────────────
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
		local at = HAND * CFrame.new(0, -0.1, -0.2)
		P(limb, "Ring", Vector3.new(0.08, s, s), at * CFrame.Angles(0, math.rad(90), 0), c.blade, METAL, "cyl")
		P(limb, "Hole", Vector3.new(0.09, s * 0.62, s * 0.62), at * CFrame.Angles(0, math.rad(90), 0), c.grip, METAL, "cyl")
		P(limb, "Glint", Vector3.new(0.1, s * 1.04, 0.05), at, c.glow, NEON)
	end
end
BUILD.kusarigama = function(ctx, w)
	local P, c = ctx.piece, ctx.colors
	-- the sickle in the right hand, the weight in the left, the chain between
	P(ctx.right, "Handle", Vector3.new(0.18, 0.18, 1.2), FORWARD * CFrame.new(0, 0, -0.3), c.grip, WOOD)
	P(ctx.right, "Sickle", Vector3.new(0.08, 0.9, 0.24), FORWARD * CFrame.new(0, 0.4, -0.85) * CFrame.Angles(math.rad(-30), 0, 0), c.blade, METAL, "wedge")
	P(ctx.right, "SickleEdge", Vector3.new(0.09, 0.85, 0.04), FORWARD * CFrame.new(0, 0.38, -0.97) * CFrame.Angles(math.rad(-30), 0, 0), c.glow, NEON)
	for k = 0, 4 do
		P(ctx.left, "Link" .. k, Vector3.new(0.1, 0.2, 0.1), HAND * CFrame.new(0, 0.2 + k * 0.18, 0.2), c.trim, METAL)
	end
	P(ctx.left, "Weight", Vector3.new(0.35, 0.35, 0.35), HAND * CFrame.new(0, -0.25, -0.1), c.trim, METAL, "ball")
end

WeaponModels.FAMILY_LIST = {}
for id in BUILD do
	table.insert(WeaponModels.FAMILY_LIST, id)
end
table.sort(WeaponModels.FAMILY_LIST)

-- put a weapon in a rig's hands; returns the pieces
function WeaponModels.attach(model: Model, base: string, stars: number?, shiny: boolean?): { BasePart }
	local w = Weapons.byId[base]
	local right = model:FindFirstChild("Right Arm") :: BasePart?
	local left = model:FindFirstChild("Left Arm") :: BasePart?
	if not w or not right or not left then
		return {}
	end
	stars = math.clamp(stars or 1, 1, 3)
	local made: { BasePart } = {}
	local gold = Color3.fromRGB(255, 214, 110)
	local colors = {
		blade = c3(w.c[1]),
		grip = c3(w.c[2]),
		trim = if shiny then gold else c3(w.c[3]),
		glow = c3(w.c[4]),
	}
	local ctx = {
		right = right,
		left = left,
		torso = model:FindFirstChild("Torso"),
		colors = colors,
		edge = (stars or 1) >= 2,
		piece = function(limb, name, size, offset, color, material, kind)
			-- a ★ weapon's glow parts are muted; ★★ and up burn
			local mat = material
			if mat == NEON and stars == 1 and not shiny and not string.find(name, "Orb") and not string.find(name, "Flame") and not string.find(name, "Crystal") then
				mat = METAL
			end
			local p = piece(model, limb, name, size, offset, color, mat, kind)
			table.insert(made, p)
			return p
		end,
	}
	local build = BUILD[w.family] or BUILD.sword
	build(ctx, w)
	-- the masterwork's light, and a shiny's shimmer
	local core = made[#made]
	for _, p in made do
		if p.Material == NEON then
			core = p
			break
		end
	end
	if core and stars == 3 then
		local light = Instance.new("PointLight")
		light.Color = colors.glow
		light.Range = 8
		light.Brightness = 1.6
		light.Parent = core
	end
	if core and shiny then
		local pe = Instance.new("ParticleEmitter")
		pe.Texture = SPARKLE
		pe.Color = ColorSequence.new(gold, colors.glow)
		pe.LightEmission = 1
		pe.Rate = 14
		pe.Lifetime = NumberRange.new(0.5, 1)
		pe.Speed = NumberRange.new(0.5, 1.5)
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
		pe.Parent = core
		local light = Instance.new("PointLight")
		light.Color = gold
		light.Range = 10
		light.Brightness = 2
		light.Parent = core
	end
	return made
end

return WeaponModels
