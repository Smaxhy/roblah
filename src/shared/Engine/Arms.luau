--[[
	Arms: the things a figure holds. Engine/Avatar draws the body; this draws what's in the
	hands, one small model per `kind` (a gear item's look.kind, or a cosmetic weapon's kind).

		Arms.kinds            every kind, in order (the validator checks looks against it)
		Arms.has[kind]        true for each of them
		Arms.low[kind]        true: it hangs from a lowered hand (or is worn), so the arm stays down.
		                      Everything else is HELD: the right forearm comes up and the grip
		                      goes through the fist.
		Arms.draw(kind, c)    adds the parts through c:
			c.held(name, shape, size, t, color, material, opts?)
				a part on the line through the raised fist. `t` is the distance along that line
				from the fist (up the blade is positive). opts = { fwd, side, rx, rz }: pushed
				toward the front / the figure's right, and turned a little more.
			c.add(name, shape, size, pos, color, material, rot?)   a part anywhere (figure space)
			c.hand                 { x, y, z } of the raised fist
			c.color, c.trim        the item's own colors (may be nil)
	Shapes: "box" | "cyl" (upright cylinder: size.x diameter, size.y height) | "ball".
	The figure stands on y = 0, faces -Z; its right hand is at +X. A lowered right hand is at
	(1.5, 2.22, 0), the left at (-1.5, 2.22, 0).
]]

local Arms = {}

local STEEL = { 192, 196, 202 }
local IRON = { 86, 88, 96 }
local DARK = { 40, 38, 42 }
local BRASS = { 204, 162, 72 }
local WOOD = { 110, 84, 56 }
local LEATHER = { 70, 50, 38 }
local RED = { 170, 40, 36 }

local draw = {}
local low = {}
local order = {}

local function kind(id: string, fn, hangs: boolean?)
	draw[id] = fn
	table.insert(order, id)
	if hangs then
		low[id] = true
	end
end

-- ── short blades ────────────────────────────────────────────────────────────
kind("knife", function(c)
	c.held("KnifeHandle", "box", { 0.2, 0.52, 0.26 }, 0, { 88, 60, 40 }, "wood")
	c.held("KnifeBlade", "box", { 0.1, 0.86, 0.3 }, 0.7, c.color or STEEL, "metal")
end)
kind("dagger", function(c)
	c.held("DaggerGrip", "box", { 0.18, 0.46, 0.2 }, 0, DARK, "fabric")
	c.held("DaggerGuard", "box", { 0.5, 0.09, 0.2 }, 0.28, c.trim or BRASS, "metal")
	c.held("DaggerBlade", "box", { 0.1, 0.8, 0.22 }, 0.72, c.color or STEEL, "metal")
	c.held("DaggerTip", "box", { 0.08, 0.26, 0.14 }, 1.22, c.color or STEEL, "metal")
end)
kind("daggers", function(c)
	draw.dagger(c)
	-- the second one, point down, in the other hand
	c.add("OffGrip", "box", { 0.18, 0.44, 0.2 }, { -1.5, 2.2, -0.36 }, DARK, "fabric")
	c.add("OffGuard", "box", { 0.5, 0.09, 0.2 }, { -1.5, 1.94, -0.36 }, c.trim or BRASS, "metal")
	c.add("OffBlade", "box", { 0.1, 0.9, 0.22 }, { -1.5, 1.46, -0.36 }, c.color or STEEL, "metal")
end)
kind("cleaver", function(c)
	c.held("CleaverHandle", "box", { 0.2, 0.54, 0.24 }, 0, WOOD, "wood")
	c.held("CleaverBlade", "box", { 0.09, 1.05, 0.74 }, 0.86, c.color or STEEL, "metal", { fwd = 0.22 })
	c.held("CleaverEdge", "box", { 0.05, 1.05, 0.08 }, 0.86, { 230, 232, 236 }, "metal", { fwd = 0.6 })
end)
kind("sickle", function(c)
	c.held("SickleHandle", "box", { 0.16, 1.0, 0.16 }, 0.2, WOOD, "wood")
	c.held("SickleBlade", "box", { 0.07, 0.3, 0.9 }, 0.86, c.color or STEEL, "metal", { fwd = 0.42 })
	c.held("SickleTip", "box", { 0.07, 0.6, 0.22 }, 0.6, c.color or STEEL, "metal", { fwd = 0.9, rx = 14 })
end)
kind("claws", function(c)
	local h = c.hand
	c.add("ClawBrace", "box", { 0.96, 0.9, 0.5 }, { h[1], h[2], h[3] + 0.02 }, c.trim or IRON, "metal")
	for i = -1, 1 do
		c.add("Claw", "box", { 0.08, 0.16, 1.2 }, { h[1] + 0.26 * i, h[2] + 0.2, h[3] - 0.8 }, c.color or STEEL, "metal", { -8, 0, 0 })
	end
end)

-- ── swords ──────────────────────────────────────────────────────────────────
kind("sword", function(c)
	c.held("SwordGrip", "box", { 0.18, 0.62, 0.18 }, 0, { 50, 36, 30 }, "fabric")
	c.held("SwordGuard", "box", { 0.72, 0.1, 0.24 }, 0.38, c.trim or BRASS, "metal")
	c.held("SwordBlade", "box", { 0.12, 2.6, 0.32 }, 1.74, c.color or STEEL, "metal")
end)
kind("katana", function(c)
	c.held("KatanaGrip", "box", { 0.16, 0.74, 0.16 }, 0, { 30, 26, 30 }, "fabric")
	c.held("KatanaGuard", "cyl", { 0.42, 0.07, 0.42 }, 0.42, c.trim or BRASS, "metal")
	c.held("KatanaBlade", "box", { 0.09, 2.3, 0.22 }, 1.62, c.color or STEEL, "metal")
	c.held("KatanaCurve", "box", { 0.09, 0.8, 0.2 }, 3.1, c.color or STEEL, "metal", { fwd = -0.06, rx = 7 })
end)
kind("greatsword", function(c)
	c.held("GreatswordGrip", "box", { 0.2, 0.84, 0.2 }, 0, { 44, 34, 30 }, "fabric")
	c.held("GreatswordGuard", "box", { 1.04, 0.16, 0.3 }, 0.5, c.trim or { 80, 80, 88 }, "metal")
	c.held("GreatswordBlade", "box", { 0.16, 3.4, 0.74 }, 2.28, c.color or STEEL, "metal")
	c.held("GreatswordFuller", "box", { 0.18, 2.6, 0.16 }, 2.0, { 120, 124, 132 }, "metal")
end)
kind("rapier", function(c)
	c.held("RapierGrip", "box", { 0.14, 0.52, 0.14 }, 0, { 40, 30, 30 }, "fabric")
	c.held("RapierCup", "ball", { 0.5, 0.5, 0.5 }, 0.32, c.trim or BRASS, "metal")
	c.held("RapierBow", "box", { 0.06, 0.6, 0.06 }, 0.02, c.trim or BRASS, "metal", { fwd = 0.26 })
	c.held("RapierBlade", "box", { 0.06, 3.1, 0.09 }, 2.0, c.color or STEEL, "metal")
end)
kind("saber", function(c)
	c.held("SaberGrip", "box", { 0.16, 0.6, 0.16 }, 0, { 44, 34, 30 }, "fabric")
	c.held("SaberBow", "box", { 0.07, 0.62, 0.07 }, 0.04, c.trim or BRASS, "metal", { fwd = 0.28 })
	c.held("SaberGuard", "box", { 0.3, 0.09, 0.5 }, 0.36, c.trim or BRASS, "metal", { fwd = 0.12 })
	c.held("SaberBlade", "box", { 0.09, 1.6, 0.28 }, 1.22, c.color or STEEL, "metal")
	c.held("SaberCurve", "box", { 0.09, 1.3, 0.24 }, 2.6, c.color or STEEL, "metal", { fwd = -0.14, rx = 10 })
end)
kind("machete", function(c)
	c.held("MacheteGrip", "box", { 0.18, 0.56, 0.2 }, 0, LEATHER, "fabric")
	c.held("MacheteBlade", "box", { 0.08, 1.9, 0.4 }, 1.3, c.color or STEEL, "metal", { fwd = 0.06 })
	c.held("MacheteTip", "box", { 0.08, 0.5, 0.28 }, 2.46, c.color or STEEL, "metal", { fwd = 0.12 })
end)
kind("cane", function(c)
	-- a walking cane with a blade inside it: carried upright, tip near the ground
	c.held("CaneShaft", "cyl", { 0.11, 3.0, 0.11 }, -1.36, c.color or { 36, 30, 30 }, "wood")
	c.held("CaneKnob", "ball", { 0.3, 0.3, 0.3 }, 0.3, c.trim or BRASS, "metal")
	c.held("CaneBand", "cyl", { 0.14, 0.1, 0.14 }, 0.08, c.trim or BRASS, "metal")
	c.held("CaneFerrule", "cyl", { 0.13, 0.16, 0.13 }, -2.8, c.trim or BRASS, "metal")
end)
kind("umbrella", function(c)
	c.held("UmbrellaShaft", "cyl", { 0.08, 3.4, 0.08 }, -0.9, DARK, "metal")
	c.held("UmbrellaCanopy", "cyl", { 0.34, 2.1, 0.34 }, -1.2, c.color or { 30, 30, 40 }, "fabric")
	c.held("UmbrellaTip", "cyl", { 0.06, 0.4, 0.06 }, -2.7, STEEL, "metal")
	c.held("UmbrellaHook", "box", { 0.09, 0.09, 0.4 }, 0.5, c.trim or WOOD, "wood", { fwd = -0.16 })
end)
kind("chainblade", function(c)
	-- a Workshop blade with a motor in the hilt and teeth that run
	c.held("RevGrip", "box", { 0.2, 0.6, 0.22 }, 0, DARK, "fabric")
	c.held("RevMotor", "box", { 0.44, 0.56, 0.6 }, 0.56, c.trim or { 150, 60, 40 }, "metal")
	c.held("RevExhaust", "cyl", { 0.14, 0.4, 0.14 }, 0.7, IRON, "metal", { fwd = -0.34 })
	c.held("RevBar", "box", { 0.14, 2.4, 0.42 }, 2.04, c.color or STEEL, "metal")
	for i = 0, 6 do
		c.held("RevTooth", "box", { 0.1, 0.16, 0.14 }, 1.0 + i * 0.34, { 230, 232, 236 }, "metal", { fwd = 0.26 })
	end
end)

-- ── hafted: hammers, axes, clubs ────────────────────────────────────────────
kind("hammer", function(c)
	c.held("HammerHandle", "cyl", { 0.17, 2.5, 0.17 }, 0.62, { 90, 70, 50 }, "wood")
	c.held("HammerHead", "box", { 0.6, 0.54, 1.06 }, 1.86, c.color or { 80, 80, 90 }, "metal")
end)
kind("maul", function(c)
	c.held("MaulHandle", "cyl", { 0.2, 3.2, 0.2 }, 0.8, WOOD, "wood")
	c.held("MaulHead", "box", { 0.96, 0.9, 1.6 }, 2.5, c.color or IRON, "metal")
	c.held("MaulBand", "box", { 1.0, 0.16, 1.64 }, 2.5, c.trim or BRASS, "metal")
	c.held("MaulFace", "box", { 0.8, 0.74, 0.1 }, 2.5, STEEL, "metal", { fwd = 0.82 })
end)
kind("mace", function(c)
	c.held("MaceHandle", "cyl", { 0.15, 2.0, 0.15 }, 0.5, c.trim or IRON, "metal")
	c.held("MaceHead", "ball", { 0.74, 0.74, 0.74 }, 1.66, c.color or STEEL, "metal")
	c.held("MaceFlange", "box", { 0.98, 0.16, 0.16 }, 1.66, c.color or STEEL, "metal")
	c.held("MaceFlange", "box", { 0.16, 0.16, 0.98 }, 1.66, c.color or STEEL, "metal")
	c.held("MaceSpike", "box", { 0.14, 0.4, 0.14 }, 2.16, c.color or STEEL, "metal")
end)
kind("club", function(c)
	c.held("ClubGrip", "cyl", { 0.16, 0.9, 0.16 }, 0.1, LEATHER, "fabric")
	c.held("ClubBody", "cyl", { 0.32, 1.7, 0.32 }, 1.36, c.color or WOOD, "wood")
	for i = 0, 2 do
		c.held("ClubNail", "box", { 0.06, 0.06, 0.5 }, 1.2 + i * 0.4, STEEL, "metal")
		c.held("ClubNail", "box", { 0.5, 0.06, 0.06 }, 1.4 + i * 0.4, STEEL, "metal")
	end
end)
kind("axe", function(c)
	c.held("AxeHandle", "cyl", { 0.17, 2.7, 0.17 }, 0.7, { 96, 70, 46 }, "wood")
	c.held("AxeHead", "box", { 0.14, 0.86, 0.9 }, 1.8, c.color or RED, "metal", { fwd = 0.4 })
	c.held("AxeEdge", "box", { 0.06, 0.96, 0.1 }, 1.8, { 226, 228, 232 }, "metal", { fwd = 0.86 })
end)
kind("pickaxe", function(c)
	c.held("PickHandle", "cyl", { 0.16, 3.0, 0.16 }, 0.7, WOOD, "wood")
	c.held("PickHead", "box", { 0.14, 0.22, 1.9 }, 2.16, c.color or IRON, "metal")
	c.held("PickPoint", "box", { 0.1, 0.4, 0.2 }, 2.0, c.color or IRON, "metal", { fwd = 0.96, rx = 30 })
	c.held("PickPoint", "box", { 0.1, 0.4, 0.2 }, 2.0, c.color or IRON, "metal", { fwd = -0.96, rx = -30 })
end)
kind("shovel", function(c)
	c.held("ShovelShaft", "cyl", { 0.15, 3.6, 0.15 }, 0.6, WOOD, "wood")
	c.held("ShovelBlade", "box", { 0.08, 1.0, 0.74 }, 2.8, c.color or IRON, "metal")
	c.held("ShovelGrip", "box", { 0.54, 0.12, 0.12 }, -1.24, WOOD, "wood")
end)
kind("wrench", function(c)
	c.held("WrenchHandle", "box", { 0.18, 2.0, 0.26 }, 0.7, c.color or STEEL, "metal")
	c.held("WrenchJaw", "box", { 0.2, 0.3, 0.8 }, 1.84, c.color or STEEL, "metal")
	c.held("WrenchJawTop", "box", { 0.2, 0.44, 0.24 }, 2.2, c.color or STEEL, "metal", { fwd = 0.28 })
	c.held("WrenchJawTop", "box", { 0.2, 0.44, 0.24 }, 2.2, c.color or STEEL, "metal", { fwd = -0.28 })
end)
kind("crowbar", function(c)
	c.held("Crowbar", "cyl", { 0.12, 2.8, 0.12 }, 0.7, c.color or { 60, 60, 110 }, "metal")
	c.held("CrowbarHook", "box", { 0.12, 0.12, 0.42 }, 2.1, c.color or { 60, 60, 110 }, "metal", { fwd = 0.2 })
	c.held("CrowbarClaw", "box", { 0.12, 0.3, 0.12 }, 1.98, c.color or { 60, 60, 110 }, "metal", { fwd = 0.4 })
end)
kind("flail", function(c)
	c.held("FlailHandle", "cyl", { 0.15, 1.6, 0.15 }, 0.4, WOOD, "wood")
	c.held("FlailRing", "cyl", { 0.24, 0.1, 0.24 }, 1.24, IRON, "metal")
	for i = 0, 2 do
		c.held("FlailLink", "box", { 0.1, 0.22, 0.1 }, 1.2 - i * 0.2, IRON, "metal", { fwd = 0.3 + i * 0.22 })
	end
	c.held("FlailBall", "ball", { 0.6, 0.6, 0.6 }, 0.5, c.color or STEEL, "metal", { fwd = 0.96 })
	c.held("FlailSpike", "box", { 0.86, 0.1, 0.1 }, 0.5, c.color or STEEL, "metal", { fwd = 0.96 })
	c.held("FlailSpike", "box", { 0.1, 0.86, 0.1 }, 0.5, c.color or STEEL, "metal", { fwd = 0.96 })
end)
kind("baton", function(c)
	c.held("Baton", "cyl", { 0.15, 1.9, 0.15 }, 0.6, c.color or DARK, "metal")
	c.held("BatonGrip", "cyl", { 0.18, 0.5, 0.18 }, 0, LEATHER, "fabric")
	c.held("BatonSide", "cyl", { 0.13, 0.5, 0.13 }, 0.34, c.color or DARK, "metal", { fwd = 0.22, rx = 90 })
	c.held("BatonTip", "cyl", { 0.17, 0.2, 0.17 }, 1.5, c.trim or { 110, 190, 255 }, "neon")
end)
kind("drill", function(c)
	c.held("DrillGrip", "box", { 0.2, 0.6, 0.24 }, 0, DARK, "fabric")
	c.held("DrillMotor", "cyl", { 0.56, 0.8, 0.56 }, 0.6, c.trim or { 170, 120, 40 }, "metal")
	c.held("DrillBit", "cyl", { 0.46, 0.5, 0.46 }, 1.2, c.color or STEEL, "metal")
	c.held("DrillBit", "cyl", { 0.32, 0.5, 0.32 }, 1.66, c.color or STEEL, "metal")
	c.held("DrillBit", "cyl", { 0.18, 0.5, 0.18 }, 2.1, c.color or STEEL, "metal")
	c.held("DrillPoint", "cyl", { 0.08, 0.3, 0.08 }, 2.46, c.color or STEEL, "metal")
end)

-- ── polearms ────────────────────────────────────────────────────────────────
kind("pole", function(c)
	c.held("Pole", "cyl", { 0.17, 5.2, 0.17 }, -0.3, { 128, 98, 64 }, "wood")
	c.held("PoleHook", "box", { 0.12, 0.6, 0.12 }, 2.2, { 150, 150, 156 }, "metal", { fwd = 0.2 })
end)
kind("staff", function(c)
	c.held("Staff", "cyl", { 0.16, 5.2, 0.16 }, -0.3, c.color or WOOD, "wood")
	c.held("StaffCap", "cyl", { 0.24, 0.3, 0.24 }, 2.2, BRASS, "metal")
	c.held("StaffOrb", "ball", { 0.46, 0.46, 0.46 }, 2.56, c.trim or { 140, 190, 255 }, "neon")
end)
kind("spear", function(c)
	c.held("SpearShaft", "cyl", { 0.17, 5.4, 0.17 }, -0.2, WOOD, "wood")
	c.held("SpearHead", "box", { 0.1, 0.96, 0.36 }, 2.96, c.color or STEEL, "metal")
	c.held("SpearTassel", "box", { 0.26, 0.34, 0.26 }, 2.36, c.trim or { 180, 40, 40 }, "fabric")
end)
kind("halberd", function(c)
	c.held("HalberdShaft", "cyl", { 0.17, 5.6, 0.17 }, -0.2, c.trim or DARK, "wood")
	c.held("HalberdAxe", "box", { 0.1, 1.06, 0.86 }, 2.36, c.color or STEEL, "metal", { fwd = 0.44 })
	c.held("HalberdBeak", "box", { 0.1, 0.3, 0.6 }, 2.4, c.color or STEEL, "metal", { fwd = -0.36 })
	c.held("HalberdSpike", "box", { 0.1, 1.0, 0.22 }, 3.12, c.color or STEEL, "metal")
end)
kind("glaive", function(c)
	c.held("GlaiveShaft", "cyl", { 0.17, 5.0, 0.17 }, -0.4, WOOD, "wood")
	c.held("GlaiveCollar", "cyl", { 0.26, 0.2, 0.26 }, 2.1, c.trim or BRASS, "metal")
	c.held("GlaiveBlade", "box", { 0.09, 1.5, 0.46 }, 2.9, c.color or STEEL, "metal", { fwd = 0.08 })
	c.held("GlaiveTip", "box", { 0.09, 0.5, 0.3 }, 3.86, c.color or STEEL, "metal", { fwd = -0.02 })
end)
kind("scythe", function(c)
	c.held("ScytheShaft", "cyl", { 0.16, 5.6, 0.16 }, -0.2, c.trim or DARK, "wood")
	c.held("ScytheHeel", "box", { 0.1, 0.4, 0.7 }, 2.5, c.color or STEEL, "metal", { fwd = 0.34 })
	c.held("ScytheBlade", "box", { 0.07, 0.34, 1.2 }, 2.42, c.color or STEEL, "metal", { fwd = 1.2, rx = 10 })
	c.held("ScytheTip", "box", { 0.07, 0.24, 0.8 }, 2.14, c.color or STEEL, "metal", { fwd = 2.0, rx = 24 })
end)
kind("trident", function(c)
	c.held("TridentShaft", "cyl", { 0.16, 5.0, 0.16 }, -0.4, WOOD, "wood")
	c.held("TridentCross", "box", { 1.0, 0.12, 0.16 }, 2.2, c.color or STEEL, "metal")
	for i = -1, 1 do
		c.held("TridentTine", "box", { 0.1, if i == 0 then 1.1 else 0.84, 0.14 }, if i == 0 then 2.76 else 2.62, c.color or STEEL, "metal", { side = 0.44 * i })
	end
end)
kind("harpoon", function(c)
	c.held("HarpoonShaft", "cyl", { 0.15, 4.6, 0.15 }, 0.3, c.trim or IRON, "metal")
	c.held("HarpoonHead", "box", { 0.1, 0.8, 0.26 }, 2.96, c.color or STEEL, "metal")
	c.held("HarpoonBarb", "box", { 0.1, 0.4, 0.14 }, 2.62, c.color or STEEL, "metal", { fwd = 0.2, rx = -30 })
	c.held("HarpoonBarb", "box", { 0.1, 0.4, 0.14 }, 2.62, c.color or STEEL, "metal", { fwd = -0.2, rx = 30 })
	c.held("HarpoonCoil", "cyl", { 0.5, 0.2, 0.5 }, -0.6, { 190, 170, 130 }, "fabric")
end)
kind("lanternpole", function(c)
	c.held("LanternShaft", "cyl", { 0.15, 5.0, 0.15 }, -0.2, c.color or BRASS, "metal")
	c.held("LanternArm", "box", { 0.1, 0.1, 0.7 }, 2.2, c.color or BRASS, "metal", { fwd = 0.3 })
	c.held("LanternCage", "box", { 0.46, 0.56, 0.46 }, 1.8, IRON, "metal", { fwd = 0.6 })
	c.held("LanternLight", "box", { 0.36, 0.4, 0.36 }, 1.8, c.trim or { 255, 210, 120 }, "neon", { fwd = 0.6 })
end)
kind("brush", function(c)
	-- the Ring paints with something like this
	c.held("BrushHandle", "cyl", { 0.17, 3.8, 0.17 }, 0.3, c.color or { 60, 40, 30 }, "wood")
	c.held("BrushFerrule", "cyl", { 0.3, 0.36, 0.3 }, 2.36, BRASS, "metal")
	c.held("BrushHair", "cyl", { 0.4, 0.7, 0.4 }, 2.86, c.trim or { 190, 40, 90 }, "fabric")
	c.held("BrushTip", "cyl", { 0.22, 0.4, 0.22 }, 3.36, c.trim or { 190, 40, 90 }, "fabric")
end)
kind("key", function(c)
	-- a Dieci key: knowledge with teeth
	c.held("KeyShaft", "cyl", { 0.17, 3.2, 0.17 }, 0.9, c.color or BRASS, "metal")
	c.held("KeyBow", "cyl", { 0.8, 0.16, 0.8 }, -0.86, c.color or BRASS, "metal", { rx = 90 })
	c.held("KeyHole", "cyl", { 0.4, 0.2, 0.4 }, -0.86, DARK, "metal", { rx = 90 })
	c.held("KeyTooth", "box", { 0.14, 0.34, 0.6 }, 2.3, c.color or BRASS, "metal", { fwd = 0.32 })
	c.held("KeyTooth", "box", { 0.14, 0.24, 0.44 }, 1.86, c.color or BRASS, "metal", { fwd = 0.26 })
end)
kind("tuningfork", function(c)
	c.held("ForkHandle", "cyl", { 0.15, 1.6, 0.15 }, 0.2, c.color or STEEL, "metal")
	c.held("ForkYoke", "box", { 0.6, 0.14, 0.14 }, 1.06, c.color or STEEL, "metal")
	for _, s in { -1, 1 } do
		c.held("ForkTine", "box", { 0.12, 1.9, 0.12 }, 2.0, c.color or STEEL, "metal", { side = 0.24 * s })
	end
	c.held("ForkBall", "ball", { 0.26, 0.26, 0.26 }, -0.66, c.trim or BRASS, "metal")
end)
kind("fan", function(c)
	c.held("FanPivot", "ball", { 0.22, 0.22, 0.22 }, 0.1, c.trim or BRASS, "metal")
	for i = -2, 2 do
		c.held("FanRib", "box", { 0.26, 1.5, 0.05 }, 0.9, if i % 2 == 0 then (c.color or { 190, 40, 44 }) else (c.trim or BRASS), "fabric", { side = 0.24 * i, rz = -14 * i })
	end
end)
kind("whip", function(c)
	c.held("WhipHandle", "cyl", { 0.17, 0.8, 0.17 }, 0, LEATHER, "fabric")
	for i = 0, 5 do
		c.held("WhipLash", "box", { 0.09, 0.5, 0.09 }, 0.6 + i * 0.3, c.color or LEATHER, "fabric", { fwd = 0.1 + i * i * 0.07, rx = -12 * i })
	end
end)
kind("syringe", function(c)
	-- a K Corp injector, the size of a forearm
	c.held("SyringePlunger", "cyl", { 0.4, 0.1, 0.4 }, -0.36, STEEL, "metal")
	c.held("SyringeRod", "cyl", { 0.1, 0.5, 0.1 }, -0.1, STEEL, "metal")
	c.held("SyringeBody", "cyl", { 0.36, 1.3, 0.36 }, 0.8, { 214, 232, 226 }, "plastic")
	c.held("SyringeFill", "cyl", { 0.28, 0.9, 0.28 }, 0.9, c.trim or { 110, 255, 150 }, "neon")
	c.held("SyringeNeedle", "cyl", { 0.06, 1.0, 0.06 }, 1.94, STEEL, "metal")
end)

-- ── guns ────────────────────────────────────────────────────────────────────
kind("pistol", function(c)
	local h = c.hand
	c.add("PistolGrip", "box", { 0.22, 0.5, 0.28 }, { h[1], h[2] + 0.02, h[3] - 0.02 }, { 40, 38, 40 }, "metal", { -12, 0, 0 })
	c.add("PistolBarrel", "box", { 0.24, 0.26, 0.9 }, { h[1], h[2] + 0.34, h[3] - 0.5 }, c.color or { 60, 60, 66 }, "metal")
	c.add("PistolSight", "box", { 0.06, 0.08, 0.1 }, { h[1], h[2] + 0.5, h[3] - 0.88 }, c.trim or STEEL, "metal")
end)
kind("pistols", function(c)
	draw.pistol(c)
	c.add("OffPistolGrip", "box", { 0.22, 0.5, 0.28 }, { -1.5, 2.1, -0.3 }, { 40, 38, 40 }, "metal", { 20, 0, 0 })
	c.add("OffPistolBarrel", "box", { 0.24, 0.9, 0.26 }, { -1.5, 1.56, -0.5 }, c.color or { 60, 60, 66 }, "metal", { 14, 0, 0 })
end)
kind("rifle", function(c)
	local h = c.hand
	c.add("RifleStock", "box", { 0.24, 0.44, 0.9 }, { h[1], h[2] + 0.08, h[3] + 0.5 }, c.trim or WOOD, "wood", { 8, 0, 0 })
	c.add("RifleBody", "box", { 0.24, 0.34, 1.3 }, { h[1], h[2] + 0.3, h[3] - 0.5 }, c.color or DARK, "metal")
	c.add("RifleBarrel", "cyl", { 0.13, 1.6, 0.13 }, { h[1], h[2] + 0.36, h[3] - 1.9 }, c.color or DARK, "metal", { 90, 0, 0 })
	c.add("RifleMag", "box", { 0.18, 0.5, 0.26 }, { h[1], h[2] - 0.02, h[3] - 0.56 }, IRON, "metal", { -10, 0, 0 })
	c.add("RifleScope", "cyl", { 0.16, 0.6, 0.16 }, { h[1], h[2] + 0.6, h[3] - 0.5 }, IRON, "metal", { 90, 0, 0 })
end)
kind("shotgun", function(c)
	local h = c.hand
	c.add("ShotgunStock", "box", { 0.26, 0.46, 0.8 }, { h[1], h[2] + 0.06, h[3] + 0.46 }, c.trim or WOOD, "wood", { 10, 0, 0 })
	c.add("ShotgunBody", "box", { 0.28, 0.36, 0.9 }, { h[1], h[2] + 0.28, h[3] - 0.36 }, c.color or IRON, "metal")
	for _, s in { -1, 1 } do
		c.add("ShotgunBarrel", "cyl", { 0.16, 1.3, 0.16 }, { h[1] + 0.08 * s, h[2] + 0.34, h[3] - 1.4 }, c.color or IRON, "metal", { 90, 0, 0 })
	end
	c.add("ShotgunPump", "box", { 0.3, 0.2, 0.5 }, { h[1], h[2] + 0.14, h[3] - 1.2 }, c.trim or WOOD, "wood")
end)
kind("crossbow", function(c)
	local h = c.hand
	c.add("CrossbowStock", "box", { 0.22, 0.3, 1.7 }, { h[1], h[2] + 0.26, h[3] - 0.4 }, c.trim or WOOD, "wood")
	c.add("CrossbowLimb", "box", { 1.7, 0.1, 0.16 }, { h[1], h[2] + 0.3, h[3] - 1.2 }, c.color or IRON, "metal")
	c.add("CrossbowString", "box", { 1.5, 0.03, 0.03 }, { h[1], h[2] + 0.38, h[3] - 0.7 }, { 220, 214, 200 }, "fabric")
	c.add("CrossbowBolt", "cyl", { 0.06, 1.2, 0.06 }, { h[1], h[2] + 0.44, h[3] - 1.0 }, STEEL, "metal", { 90, 0, 0 })
end)

-- ── two things at once ──────────────────────────────────────────────────────
kind("shield", function(c)
	-- a Zwei-style kit: a short mace in the hand, a tower shield on the other arm
	c.held("ShieldMaceHandle", "cyl", { 0.15, 1.5, 0.15 }, 0.36, IRON, "metal")
	c.held("ShieldMaceHead", "box", { 0.5, 0.5, 0.5 }, 1.26, c.trim or STEEL, "metal")
	c.add("Shield", "box", { 0.18, 2.3, 1.5 }, { -2.1, 2.9, -0.16 }, c.color or { 44, 58, 104 }, "metal")
	c.add("ShieldRim", "box", { 0.2, 2.4, 0.14 }, { -2.1, 2.9, -0.92 }, c.trim or STEEL, "metal")
	c.add("ShieldRim", "box", { 0.2, 0.14, 1.5 }, { -2.1, 4.06, -0.16 }, c.trim or STEEL, "metal")
	c.add("ShieldBoss", "ball", { 0.5, 0.5, 0.5 }, { -2.22, 3.0, -0.16 }, c.trim or STEEL, "metal")
end)
kind("nailhammer", function(c)
	-- the Inquisition's pair: the hammer in one hand, the nail in the other
	c.held("NailHammerHandle", "cyl", { 0.16, 1.8, 0.16 }, 0.5, WOOD, "wood")
	c.held("NailHammerHead", "box", { 0.5, 0.5, 1.1 }, 1.5, c.color or IRON, "metal")
	c.add("Nail", "cyl", { 0.14, 1.5, 0.14 }, { -1.5, 1.5, -0.3 }, c.trim or STEEL, "metal")
	c.add("NailHead", "cyl", { 0.36, 0.1, 0.36 }, { -1.5, 2.28, -0.3 }, c.trim or STEEL, "metal")
	c.add("NailPoint", "cyl", { 0.07, 0.3, 0.07 }, { -1.5, 0.64, -0.3 }, c.trim or STEEL, "metal")
end)

-- ── carried and worn (the arm stays down) ───────────────────────────────────
kind("gauntlet", function(c)
	c.add("Gauntlet", "box", { 1.02, 0.6, 1.02 }, { 1.5, 2.25, 0 }, c.color or { 70, 72, 80 }, "metal")
	c.add("GauntletKnuckle", "box", { 1.06, 0.2, 0.3 }, { 1.5, 2.1, -0.4 }, c.trim or STEEL, "metal")
end, true)
kind("gauntlets", function(c)
	for _, s in { -1, 1 } do
		c.add("Gauntlet", "box", { 1.04, 0.9, 1.04 }, { 1.5 * s, 2.4, 0 }, c.color or { 70, 72, 80 }, "metal")
		c.add("GauntletKnuckle", "box", { 1.08, 0.22, 0.32 }, { 1.5 * s, 2.1, -0.42 }, c.trim or STEEL, "metal")
		c.add("GauntletVent", "box", { 0.3, 0.3, 1.08 }, { 1.5 * s, 2.62, 0 }, c.trim or STEEL, "metal")
	end
end, true)
kind("chain", function(c)
	-- the Middle's way: a chain wound round the fist, the rest left to swing
	for _, s in { -1, 1 } do
		c.add("ChainWrap", "box", { 1.0, 0.5, 1.0 }, { 1.5 * s, 2.24, 0 }, c.color or IRON, "metal")
		c.add("ChainWrap", "box", { 1.04, 0.12, 1.04 }, { 1.5 * s, 2.36, 0 }, c.trim or STEEL, "metal")
	end
	for i = 0, 4 do
		c.add("ChainLink", "box", if i % 2 == 0 then { 0.2, 0.3, 0.08 } else { 0.08, 0.3, 0.2 }, { 1.5, 1.86 - i * 0.26, -0.5 }, c.color or IRON, "metal")
	end
	c.add("ChainWeight", "box", { 0.3, 0.3, 0.3 }, { 1.5, 0.5, -0.5 }, c.trim or STEEL, "metal")
end, true)
kind("book", function(c)
	c.add("Book", "box", { 0.74, 0.92, 0.2 }, { 1.5, 1.72, -0.48 }, c.color or { 110, 70, 40 }, "fabric")
	c.add("BookPages", "box", { 0.04, 0.82, 0.16 }, { 1.86, 1.72, -0.48 }, { 232, 224, 204 }, "plastic")
end, true)
kind("lamp", function(c)
	c.add("Lamp", "box", { 0.44, 0.56, 0.44 }, { 1.5, 1.52, -0.25 }, { 70, 66, 60 }, "metal")
	c.add("LampGlass", "box", { 0.46, 0.3, 0.46 }, { 1.5, 1.52, -0.25 }, c.trim or { 255, 210, 120 }, "neon")
	c.add("LampHandle", "box", { 0.06, 0.3, 0.06 }, { 1.5, 1.94, -0.25 }, { 70, 66, 60 }, "metal")
end, true)
kind("censer", function(c)
	c.add("CenserChain", "box", { 0.04, 0.9, 0.04 }, { 1.5, 1.7, -0.25 }, { 150, 150, 156 }, "metal")
	c.add("Censer", "cyl", { 0.46, 0.5, 0.46 }, { 1.5, 1.05, -0.25 }, c.color or BRASS, "metal")
	c.add("CenserGlow", "cyl", { 0.3, 0.12, 0.3 }, { 1.5, 1.36, -0.25 }, c.trim or { 110, 150, 255 }, "neon")
end, true)
kind("bell", function(c)
	draw.censer(c)
end, true)
kind("briefcase", function(c)
	c.add("CaseHandle", "box", { 0.1, 0.24, 0.5 }, { 1.5, 1.96, -0.1 }, DARK, "metal")
	c.add("Case", "box", { 0.34, 0.96, 1.4 }, { 1.5, 1.4, -0.1 }, c.color or { 60, 44, 34 }, "fabric")
	c.add("CaseClasp", "box", { 0.36, 0.14, 0.2 }, { 1.5, 1.8, -0.5 }, c.trim or BRASS, "metal")
	c.add("CaseClasp", "box", { 0.36, 0.14, 0.2 }, { 1.5, 1.8, 0.3 }, c.trim or BRASS, "metal")
end, true)
kind("trunk", function(c)
	-- a Devyat' Courier Trunk: on the back, straps over the shoulders, a lamp that's never off
	c.add("Trunk", "box", { 1.7, 2.2, 0.9 }, { 0, 3.1, 1.0 }, c.color or { 96, 42, 40 }, "metal")
	c.add("TrunkBand", "box", { 1.74, 0.16, 0.94 }, { 0, 3.7, 1.0 }, c.trim or BRASS, "metal")
	c.add("TrunkBand", "box", { 1.74, 0.16, 0.94 }, { 0, 2.5, 1.0 }, c.trim or BRASS, "metal")
	c.add("TrunkLamp", "box", { 0.3, 0.3, 0.1 }, { 0.5, 3.9, 1.48 }, { 255, 120, 90 }, "neon")
	for _, s in { -1, 1 } do
		c.add("TrunkStrap", "box", { 0.26, 2.0, 0.06 }, { 0.6 * s, 3.1, -0.58 }, LEATHER, "fabric")
	end
end, true)

Arms.kinds = order
Arms.has = {}
for _, id in order do
	Arms.has[id] = true
end
Arms.low = low

function Arms.draw(id: string, c)
	local fn = draw[id]
	if fn then
		fn(c)
		return true
	end
	return false
end

return Arms
