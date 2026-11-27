--[[
	R6 RIG: builds a real R6 character (Humanoid, the six classic parts, Motor6D joints,
	the standard attachments) from a look (Hunter/Looks.luau), entirely out of Parts: the
	clothes and the Hunter gear are shells welded to each limb, the face is drawn on a plate
	in front of the head, and the hair is a Roblox hair accessory (or block hair if it can't
	load). Runs on the server (players' characters, NPCs) and on the client (the creator's
	preview, in a ViewportFrame's WorldModel).

		local model = R6Rig.build(look, { name = "Ari", hair = accessoryOrNil, npc = true })
		    -- more opts: civilian (no armour, weapon, aura or combat gear), rank (the Rank aura),
		    -- weapon ({ base, stars, shiny } or false), accessories ({ id } drawn on top of the
		    -- look's own: a life's equipped charm, Hunter/Accessories.luau)
		R6Rig.pose(model, CFrame.new(...))     -- move the whole rig (keeps the joints)
		R6Rig.wearHair(model, accessory, dye)  -- put a hair accessory on
		R6Rig.ANIMS                            -- the R6 animation ids (idle, walk, run, jump, fall)

	The rig stands with its feet on y = 0, faces -Z, before it's moved.
]]

local Looks = require(script.Parent:WaitForChild("Looks"))
local WeaponModels = require(script.Parent:WaitForChild("WeaponModels"))
local MeshLibrary = require(script.Parent:WaitForChild("MeshLibrary"))

local R6Rig = {}

-- Roblox's own R6 animations (public, by Roblox)
R6Rig.ANIMS = {
	idle = "rbxassetid://180435571",
	idle2 = "rbxassetid://180435792",
	walk = "rbxassetid://180426354",
	run = "rbxassetid://180426354",
	jump = "rbxassetid://125750702",
	fall = "rbxassetid://180436148",
	climb = "rbxassetid://180436334",
	sit = "rbxassetid://178130996",
	tool = "rbxassetid://182393478",
}

local HEAD = 1.25

local function c3(rgb: { number }?, fallback: { number }?): Color3
	local c = rgb or fallback or { 200, 200, 200 }
	return Color3.fromRGB(c[1], c[2], c[3])
end
local function shade(c: Color3, f: number): Color3
	return Color3.new(math.clamp(c.R * f, 0, 1), math.clamp(c.G * f, 0, 1), math.clamp(c.B * f, 0, 1))
end

local function newPart(props: any): BasePart
	local p = Instance.new("Part")
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = true
	for k, v in props do
		(p :: any)[k] = v
	end
	return p
end

local function attach(part: Instance, name: string, pos: Vector3)
	local a = Instance.new("Attachment")
	a.Name = name
	a.Position = pos
	a.Parent = part
	return a
end

local function motor(name: string, p0: BasePart, p1: BasePart, c0: CFrame, c1: CFrame, parent: Instance)
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = p0
	m.Part1 = p1
	m.C0 = c0
	m.C1 = c1
	m.MaxVelocity = 0.1
	m.Parent = parent
	return m
end

-- a shell welded to a limb: `offset` is from the limb's centre, in the limb's space
local function shell(model: Model, limb: BasePart, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material?, shape: Enum.PartType?)
	local p = newPart({
		Name = name,
		Size = size,
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		CFrame = limb.CFrame * offset,
	})
	if shape then
		p.Shape = shape
	end
	local w = Instance.new("WeldConstraint")
	w.Part0 = limb
	w.Part1 = p
	w.Parent = p
	p.Parent = model
	return p
end
R6Rig.shell = shell

local function colorOf(look: any, field: string, fallback: { number }): Color3
	return c3(Looks.color("PALETTE", look[field]), fallback)
end

-- ── the face, drawn on a plate in front of the head ────────────────────────
local MOUTHS = {
	calm = { w = 0.22, h = 0.035, y = 0.74 },
	focused = { w = 0.16, h = 0.03, y = 0.74 },
	smile = { w = 0.26, h = 0.05, y = 0.72, curve = 1 },
	grin = { w = 0.32, h = 0.09, y = 0.7, open = true },
	stern = { w = 0.24, h = 0.04, y = 0.75, curve = -1 },
	tired = { w = 0.18, h = 0.03, y = 0.76, curve = -1 },
	fierce = { w = 0.28, h = 0.06, y = 0.72, open = true, curve = -1 },
	soft = { w = 0.16, h = 0.04, y = 0.73, curve = 1 },
}
local BROWS = {
	straight = { t = 0.035, tilt = 0 },
	arched = { t = 0.035, tilt = -10, lift = 0.02 },
	thick = { t = 0.06, tilt = 0 },
	thin = { t = 0.02, tilt = 0 },
	angled = { t = 0.04, tilt = 16 },
}
-- scars, freckles, paint (on the face's own gui), and the mana glow (an unlit gui of its own)
local function drawMarks(gui: SurfaceGui, frame: (any) -> Frame, round: (Frame, number?) -> (), look: any, skin: Color3, squint: boolean)
	local mark = look.marks or "none"
	local scar = shade(skin, 0.7):Lerp(Color3.fromRGB(150, 80, 80), 0.25)
	local function line(x, y, w, h, rot, color, t)
		local f = frame({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(w, h), Rotation = rot, BackgroundColor3 = color, BackgroundTransparency = t or 0 })
		round(f, 0.5)
		return f
	end
	local function dot(x, y, r, color, t)
		local f = frame({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, y), Size = UDim2.fromScale(r, r * 1.1), BackgroundColor3 = color, BackgroundTransparency = t or 0 })
		round(f, 1)
		return f
	end
	if mark == "scar_eye" then
		line(0.69, 0.47, 0.026, 0.4, 8, scar)
		for k = -1, 1 do
			line(0.69 + k * 0.006, 0.47 + k * 0.11, 0.07, 0.014, 8, scar, 0.25)
		end
	elseif mark == "scar_cheek" then
		line(0.27, 0.63, 0.03, 0.17, 35, scar)
	elseif mark == "scar_nose" then
		line(0.5, 0.57, 0.42, 0.026, -8, scar)
	elseif mark == "scar_cross" then
		line(0.71, 0.64, 0.03, 0.2, 45, scar)
		line(0.71, 0.64, 0.03, 0.2, -45, scar)
	elseif mark == "scar_lip" then
		line(0.57, 0.76, 0.024, 0.13, 10, scar)
	elseif mark == "claw" then
		for k = 0, 2 do
			line(0.24 + k * 0.06, 0.6, 0.02, 0.24, 18, scar)
		end
	elseif mark == "burn" then
		local burn = skin:Lerp(Color3.fromRGB(170, 86, 76), 0.45)
		dot(0.24, 0.42, 0.2, burn, 0.25)
		dot(0.2, 0.55, 0.14, burn, 0.3)
		dot(0.3, 0.33, 0.12, burn, 0.35)
	elseif mark == "freckles" then
		for _, xy in { { 0.38, 0.57 }, { 0.42, 0.61 }, { 0.34, 0.62 }, { 0.62, 0.57 }, { 0.58, 0.61 }, { 0.66, 0.62 }, { 0.47, 0.58 }, { 0.53, 0.58 } } do
			dot(xy[1], xy[2], 0.018, shade(skin, 0.7))
		end
	elseif mark == "beauty" then
		dot(0.64, 0.69, 0.025, Color3.fromRGB(50, 30, 26))
	elseif mark == "blush" then
		for _, x in { 0.25, 0.75 } do
			local b = frame({ AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(x, 0.62), Size = UDim2.fromScale(0.16, 0.07), BackgroundColor3 = Color3.fromRGB(240, 120, 130), BackgroundTransparency = 0.55 })
			round(b, 1)
		end
	elseif mark == "dark_circles" then
		for _, x in { 0.31, 0.69 } do
			line(x, 0.565, 0.16, 0.035, 0, shade(skin, 0.74), 0.3)
		end
	elseif mark == "war_paint" then
		local paint = c3(Looks.color("PALETTE", look.trim), { 160, 28, 36 })
		for _, x in { 0.31, 0.69 } do
			line(x - 0.03, 0.62, 0.035, 0.13, 0, paint)
			line(x + 0.03, 0.62, 0.035, 0.13, 0, paint)
		end
	elseif mark == "tear" then
		dot(0.31, 0.6, 0.035, Color3.fromRGB(40, 60, 120))
	end

	-- the glow: eyes that shine with mana, and veins of it
	local glow = Looks.color("EYE_GLOW", look.eyeGlow)
	local veins = mark == "mana_veins"
	if not glow and not veins then
		return
	end
	local gc = c3(glow or { 90, 180, 255 })
	local plate = gui.Parent
	local g = Instance.new("SurfaceGui")
	g.Name = "Glow"
	g.Face = Enum.NormalId.Front
	g.CanvasSize = gui.CanvasSize
	g.LightInfluence = 0
	g.Brightness = 2.5
	g.AlwaysOnTop = false
	g.Parent = plate
	local function gframe(x, y, w, h, t, rot)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(x, y)
		f.Size = UDim2.fromScale(w, h)
		f.Rotation = rot or 0
		f.BackgroundColor3 = gc
		f.BackgroundTransparency = t
		f.Parent = g
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = f
		return f
	end
	if glow then
		for _, side in { -1, 1 } do
			local x = 0.5 + side * 0.19
			gframe(x - side * 0.01, 0.49, 0.085, if squint then 0.06 else 0.09, 0.05)
			gframe(x, 0.48, 0.2, if squint then 0.1 else 0.16, 0.72)
		end
	end
	if veins then
		for _, side in { -1, 1 } do
			local x = 0.5 + side * 0.19
			gframe(x + side * 0.05, 0.6, 0.016, 0.14, 0.15, side * -20)
			gframe(x + side * 0.1, 0.57, 0.014, 0.1, 0.2, side * -50)
			gframe(x - side * 0.02, 0.62, 0.012, 0.09, 0.25, side * 15)
		end
	end
	local light = Instance.new("PointLight")
	light.Color = gc
	light.Range = 4
	light.Brightness = 0.8
	light.Parent = plate
end

local function drawFace(head: BasePart, look: any, model: Model)
	local plate = newPart({
		Name = "FacePlate",
		Size = Vector3.new(HEAD * 0.98, HEAD * 0.9, 0.05),
		Transparency = 1,
		CFrame = head.CFrame * CFrame.new(0, -0.02, -HEAD / 2 - 0.03),
	})
	local w = Instance.new("WeldConstraint")
	w.Part0 = head
	w.Part1 = plate
	w.Parent = plate
	plate.Parent = model
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Face"
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(200, 180)
	gui.LightInfluence = 1
	gui.Parent = plate
	local function frame(props)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		for k, v in props do
			(f :: any)[k] = v
		end
		f.Parent = gui
		return f
	end
	local function round(f, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(r or 1, 0)
		c.Parent = f
	end
	local eye = c3(Looks.color("EYES", look.eyes), { 70, 44, 28 })
	local skin = c3(Looks.color("SKIN", look.skin), { 234, 196, 160 })
	local face = look.face or "calm"
	local squint = face == "focused" or face == "fierce" or face == "tired"
	for _, side in { -1, 1 } do
		local x = 0.5 + side * 0.19
		local white = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x, 0.48),
			Size = UDim2.fromScale(0.15, if squint then 0.1 else 0.15),
			BackgroundColor3 = Color3.fromRGB(246, 244, 240),
		})
		round(white, 0.5)
		local iris = Instance.new("Frame")
		iris.BorderSizePixel = 0
		iris.AnchorPoint = Vector2.new(0.5, 0.5)
		iris.Position = UDim2.fromScale(0.5 - side * 0.06, 0.55)
		iris.Size = UDim2.fromScale(0.62, if squint then 0.95 else 0.78)
		iris.BackgroundColor3 = eye
		iris.Parent = white
		round(iris, 1)
		local pupil = Instance.new("Frame")
		pupil.BorderSizePixel = 0
		pupil.AnchorPoint = Vector2.new(0.5, 0.5)
		pupil.Position = UDim2.fromScale(0.5, 0.5)
		pupil.Size = UDim2.fromScale(0.45, 0.45)
		pupil.BackgroundColor3 = Color3.fromRGB(12, 10, 10)
		pupil.Parent = iris
		round(pupil, 1)
		local shine = Instance.new("Frame")
		shine.BorderSizePixel = 0
		shine.Position = UDim2.fromScale(0.18, 0.15)
		shine.Size = UDim2.fromScale(0.3, 0.3)
		shine.BackgroundColor3 = Color3.new(1, 1, 1)
		shine.Parent = iris
		round(shine, 1)
		if face == "tired" then
			frame({ AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(x, 0.45), Size = UDim2.fromScale(0.17, 0.05), BackgroundColor3 = shade(skin, 0.85) })
		end
		local b = BROWS[look.brows or "straight"]
		if b then
			local hair = Looks.color("HAIR_DYES", look.hairDye) or { 40, 30, 24 }
			local brow = frame({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(x, 0.34 - (b.lift or 0)),
				Size = UDim2.fromScale(0.19, b.t),
				BackgroundColor3 = c3(hair),
				Rotation = (b.tilt + (if face == "fierce" or face == "stern" then 12 else 0)) * side,
			})
			round(brow, 0.5)
		end
	end
	local m = MOUTHS[face] or MOUTHS.calm
	local mouth = frame({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, m.y),
		Size = UDim2.fromScale(m.w, m.h),
		BackgroundColor3 = if m.open then Color3.fromRGB(90, 30, 30) else Color3.fromRGB(70, 36, 34),
	})
	round(mouth, 0.5)
	if m.open then
		local teeth = Instance.new("Frame")
		teeth.BorderSizePixel = 0
		teeth.Size = UDim2.fromScale(1, 0.35)
		teeth.BackgroundColor3 = Color3.fromRGB(244, 240, 232)
		teeth.Parent = mouth
	end
	if m.curve then
		for _, side in { -1, 1 } do
			frame({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5 + side * m.w / 2, m.y - m.curve * 0.025),
				Size = UDim2.fromScale(0.05, 0.03),
				Rotation = side * m.curve * -35,
				BackgroundColor3 = mouth.BackgroundColor3,
			})
		end
	end
	drawMarks(gui, frame, round, look, skin, squint)
	return plate
end

-- ── block hair, for "no accessory" styles and when a mesh can't load ──────
local function blockHair(model: Model, head: BasePart, style: string, color: Color3)
	if style == "none" then
		return
	end
	local H = HEAD / 2
	local function hp(name, size, offset, shapeType)
		return shell(model, head, "Hair" .. name, size, offset, color, Enum.Material.SmoothPlastic, shapeType)
	end
	-- every style has a cap
	hp("Cap", Vector3.new(HEAD + 0.1, 0.32, HEAD + 0.1), CFrame.new(0, H - 0.06, 0.02))
	hp("Back", Vector3.new(HEAD + 0.1, 0.7, 0.18), CFrame.new(0, H - 0.4, H + 0.02))
	if style == "messy" or style == "spiky" then
		for i = -2, 2 do
			hp("Spike" .. i, Vector3.new(0.26, 0.34, 0.26), CFrame.new(i * 0.24, H + 0.12, (i % 2) * 0.16 - 0.08) * CFrame.Angles(math.rad(i * 6), 0, math.rad(-i * 12)))
		end
	elseif style == "long" or style == "bob" then
		local len = if style == "long" then 1.6 else 0.8
		hp("SideL", Vector3.new(0.18, len, HEAD * 0.9), CFrame.new(-H - 0.04, H - len / 2, 0.05))
		hp("SideR", Vector3.new(0.18, len, HEAD * 0.9), CFrame.new(H + 0.04, H - len / 2, 0.05))
		hp("Fall", Vector3.new(HEAD + 0.1, len, 0.2), CFrame.new(0, H - len / 2, H + 0.06))
		hp("Fringe", Vector3.new(HEAD + 0.08, 0.2, 0.14), CFrame.new(0, H - 0.18, -H - 0.02))
	elseif style == "ponytail" then
		hp("Tie", Vector3.new(0.3, 0.3, 0.3), CFrame.new(0, H - 0.1, H + 0.12), Enum.PartType.Ball)
		hp("Tail", Vector3.new(0.28, 1.2, 0.28), CFrame.new(0, H - 0.75, H + 0.24))
	elseif style == "bun" then
		hp("Bun", Vector3.new(0.6, 0.6, 0.6), CFrame.new(0, H + 0.2, H * 0.4), Enum.PartType.Ball)
	elseif style == "braid" then
		for i = 0, 3 do
			hp("Braid" .. i, Vector3.new(0.3, 0.3, 0.3), CFrame.new(0, H - 0.5 - i * 0.3, H + 0.16), Enum.PartType.Ball)
		end
	elseif style == "twintails" then
		for _, s in { -1, 1 } do
			hp("Twin" .. s, Vector3.new(0.3, 1.1, 0.3), CFrame.new(s * (H + 0.18), H - 0.7, 0.1))
		end
	elseif style == "curls" then
		for i = 0, 6 do
			local a = i / 7 * math.pi * 2
			hp("Curl" .. i, Vector3.new(0.42, 0.42, 0.42), CFrame.new(math.cos(a) * 0.5, H + 0.02, math.sin(a) * 0.5), Enum.PartType.Ball)
		end
	elseif style == "sidecut" or style == "slick" then
		hp("Swoop", Vector3.new(HEAD * 0.7, 0.2, HEAD + 0.12), CFrame.new(if style == "sidecut" then 0.2 else 0, H + 0.08, 0) * CFrame.Angles(0, 0, math.rad(-6)))
	elseif style == "crop" then
		hp("Fringe", Vector3.new(HEAD + 0.06, 0.16, 0.12), CFrame.new(0, H - 0.12, -H - 0.02))
	end
end
R6Rig.blockHair = blockHair

-- ── clothes and gear ───────────────────────────────────────────────────────
--[[ Every piece is a shell welded to a limb (offsets in the limb's own space: X right, Y up,
	-Z forward). A few names mean something to other code:
		Cape, RobeTail, Scarf, Sash   long cloth that may swing (cloth physics)
		Cape, Pauldron, Cuirass, Helm, Horn, Shield, Sheath, Staff, Quiver, Crystal ...
		                              the Blender mesh kit's roles by name (Hunter/MeshLibrary)
	and two attributes:
		MeshRole = "<role>"           ask the kit for that mesh on this part (its box fits it)
		CoveredBy = "<part name>"     a part that only stands in for detail the named part's
		                              mesh already has (the kit can hide it once that's dressed) ]]
local V = Vector3.new
local at = CFrame.new
local function rot(x: number, y: number, z: number): CFrame
	return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end
local FAB, LEA, MET, NEON, GLASS, WOOD, SMOOTH = Enum.Material.Fabric, Enum.Material.Leather, Enum.Material.Metal, Enum.Material.Neon, Enum.Material.Glass, Enum.Material.Wood, Enum.Material.SmoothPlastic
local BALL, CYL = Enum.PartType.Ball, Enum.PartType.Cylinder
local GOLD = Color3.fromRGB(214, 180, 90)
local STEEL = Color3.fromRGB(150, 156, 166)
local DARK = Color3.fromRGB(26, 26, 30)
local LEATHER = Color3.fromRGB(86, 58, 38)
local WHITE = Color3.fromRGB(238, 238, 234)
local ROPE = Color3.fromRGB(196, 170, 120)
local BONE = Color3.fromRGB(226, 216, 192)
local FUR_LIGHT = Color3.fromRGB(214, 204, 186)
local FUR_DARK = Color3.fromRGB(70, 56, 46)
local SKIN_SIDES = { "Left", "Right" }

local function role(p: BasePart, r: string): BasePart
	p:SetAttribute("MeshRole", r)
	return p
end
local function covered(p: BasePart, by: string): BasePart
	p:SetAttribute("CoveredBy", by)
	return p
end
local function luma(c: Color3): number
	return c.R * 0.3 + c.G * 0.59 + c.B * 0.11
end
-- a shell-maker for one limb
local function on(ctx: any, limb: BasePart): (string, Vector3, CFrame, Color3, Enum.Material?, Enum.PartType?) -> BasePart
	return function(name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, shape: Enum.PartType?): BasePart
		return shell(ctx.model, limb, name, size, cf, color, material or FAB, shape)
	end
end
local function sideOf(side: string): number
	return if side == "Left" then -1 else 1
end

-- a robe's skirt from the waist, `len` long (the kit's robe_skirt bell goes over the core; as
-- parts: the core, a wider flare above a heavy hem band, a front panel or slit, runes)
local function robeSkirt(ctx: any, len: number, color: Color3, hem: Color3, opts: any)
	local T = on(ctx, ctx.parts.Torso)
	local pad = ctx.pad
	local grow = opts.grow or 0
	local w, d = 2.12 + pad * 2 + grow, 1.14 + pad * 2 + grow
	local top = -0.9
	local bottom = top - len
	role(T(opts.name or "RobeSkirt", V(w, len, d), at(0, top - len / 2, 0), color), "robe_skirt")
	-- (the flare: a wider fall of cloth over the lower half, the hem wider still)
	local fh = math.min(len * 0.5, 0.95)
	covered(T("RobeFlare", V(w + 0.26, fh, d + 0.26), at(0, bottom + fh / 2 + 0.06, 0), shade(color, 0.95)), opts.name or "RobeSkirt")
	T("RobeHem", V(w + 0.4, 0.16, d + 0.4), at(0, bottom + 0.06, 0), hem, opts.hemMat)
	local fz = -(d + 0.26) / 2 - 0.02
	if opts.panel then
		T("RobePanel", V(0.56, len - 0.2, 0.04), at(0, top - len / 2 - 0.04, fz) * rot(2, 0, 0), opts.panel)
	end
	if opts.slit then
		T("RobeSlit", V(0.42, len * 0.7, 0.03), at(0, bottom + len * 0.35 + 0.1, fz), opts.slit)
	end
	if opts.runes then
		for k = -1, 1 do
			T("Rune", V(0.12, 0.12, 0.04), at(k * 0.5, bottom + 0.42, fz - 0.03) * rot(0, 0, 45), hem, NEON)
		end
	end
	ctx.robe = math.max(ctx.robe, len)
end

-- ── the top ──
local function dressTop(ctx: any)
	local top = ctx.top
	local parts, pad = ctx.parts, ctx.pad
	local col, trim, skin = ctx.col, ctx.trim, ctx.skin
	local torso: BasePart = parts.Torso
	local T = on(ctx, torso)
	local FZ, BZ = -(0.5 + pad), 0.5 + pad -- the front and the back of the clothes
	local cloth = if top.leather then LEA else FAB
	local fur = if luma(col) > 0.55 then FUR_DARK else FUR_LIGHT
	local shirt = if top.shirt == "white" then WHITE elseif top.shirt == "black" then DARK elseif top.shirt == "col" then shade(col, 0.5) else trim
	local mail = top.sleeves == "mail"
	-- the torso: the cloth itself (under a vest or surcoat, the shirt or the mail)
	torso.Color = if top.vest then trim elseif top.surcoat then STEEL elseif top.waistcoat then trim else col
	if mail then
		torso.Material = MET
	end
	if top.bulk or top.open or top.vest then
		T("Body", V(2.02 + pad * 2, 2.04, 1.02 + pad * 2), at(0, 0.02, 0), if top.vest then trim else col, cloth)
	end

	-- the sleeves (and what's worn on the arms)
	local sleeveCol = if top.sleeveTrim or top.vest then trim elseif mail then STEEL else col
	local cuffCol = if top.cuffs == "trim" or top.cuffs == "rune" then trim
		elseif top.cuffs == "white" then WHITE
		elseif top.cuffs == "fur" then fur
		else shade(sleeveCol, 0.76)
	for _, side in SKIN_SIDES do
		local arm: BasePart = parts[side .. " Arm"]
		local o = sideOf(side)
		local A = on(ctx, arm)
		local s = top.sleeves
		if s == "none" then
			arm.Color = skin
		elseif s == "short" then
			arm.Color = skin
			A("Sleeve", V(1.07, 0.74, 1.07), at(0, 0.64, 0), col, cloth)
			if top.cuffs then
				A("SleeveCuff", V(1.09, 0.1, 1.09), at(0, 0.3, 0), cuffCol)
			end
		elseif s == "rolled" then
			arm.Color = skin
			A("Sleeve", V(1.06, 1.02, 1.06), at(0, 0.5, 0), sleeveCol, cloth)
			A("Roll", V(1.12, 0.2, 1.12), at(0, -0.02, 0), shade(sleeveCol, 0.88), cloth)
		elseif s == "bell" then
			arm.Color = sleeveCol
			role(A("BellSleeve", V(1.4, 1.0, 1.4), at(0, -0.46, 0), col), "robe_sleeve")
			A("BellTrim", V(1.44, 0.1, 1.44), at(0, -0.92, 0), trim, if top.runes then NEON else nil)
			ctx.sleeved[side] = true
		elseif s == "layered" then
			arm.Color = col
			role(A("BellSleeve", V(1.34, 1.16, 1.34), at(0, -0.54, 0), shade(col, 0.68)), "robe_sleeve")
			role(A("OuterSleeve", V(1.58, 0.92, 1.58), at(0, -0.22, 0), col), "robe_sleeve")
			A("OuterTrim", V(1.62, 0.1, 1.62), at(0, -0.64, 0), trim, if top.runes then NEON else nil)
			ctx.sleeved[side] = true
		elseif s == "wide" then
			arm.Color = col
			role(A("WideSleeve", V(1.32, 1.3, 1.32), at(0, -0.2, 0), col), "robe_sleeve")
			A("WideCuff", V(1.36, 0.18, 1.36), at(0, -0.78, 0), cuffCol)
			ctx.sleeved[side] = true
		else -- long, mail, puffy
			arm.Color = sleeveCol
			if mail then
				arm.Material = MET
			end
			if top.cuffs == "fur" then
				A("FurCuff", V(1.2, 0.3, 1.2), at(0, -0.5, 0), fur)
			else
				A("Cuff", V(1.08, 0.14, 1.08), at(0, -0.62, 0), cuffCol, if top.cuffs == "rune" then NEON else nil)
			end
			if s == "puffy" then
				for k, y in { 0.52, -0.08 } do
					A("Puff" .. k, V(1.18, 0.42, 1.18), at(0, y, 0), shade(col, 1 - k * 0.04), cloth)
				end
			end
			ctx.sleeved[side] = true
		end
		if top.bracers then
			A("Bracer", V(1.13, 0.6, 1.13), at(0, -0.46, 0), LEATHER, LEA)
		end
		if top.wraps then
			for k = 0, 1 do
				A("ArmWrap", V(1.08, 0.08, 1.08), at(0, -0.28 - k * 0.26, 0) * rot(0, 0, if k % 2 == 0 then 7 else -7), shade(trim, 0.85))
			end
		end
		if top.stripes then
			A("Stripe", V(0.06, 1.86, 1.03), at(o * 0.52, 0.02, 0), trim)
		end
		if top.colorblock then
			A("Block", V(1.07, 0.62, 1.07), at(0, 0.68, 0), trim, cloth)
		end
		if top.epaulettes then
			A("Epaulette", V(1.16, 0.14, 0.9), at(o * 0.02, 1.03, 0), GOLD, MET)
		end
		if top.armband and side == "Left" then
			A("Armband", V(1.09, 0.28, 1.09), at(0, 0.36, 0), trim)
			A("ArmbandStripe", V(1.1, 0.06, 1.1), at(0, 0.36, 0), WHITE, NEON)
		end
		if top.mantle == true or top.mantle == "short" then
			A("MantleShoulder", V(1.2, 0.48, 1.2), at(o * 0.04, 0.8, 0) * rot(0, 0, -8 * o), shade(col, 0.88))
		elseif top.mantle == "plate" then
			A("Pauldron", V(1.24, 0.42, 1.24), at(o * 0.06, 0.9, 0) * rot(0, 0, -12 * o), ctx.armorCol, MET)
			A("PauldronTrim", V(1.26, 0.07, 1.26), at(o * 0.06, 0.7, 0) * rot(0, 0, -12 * o), trim, NEON)
		end
		if top.cloak then
			A("CloakShoulder", V(1.18, 0.52, 1.18), at(o * 0.03, 0.78, 0), shade(col, 0.82))
		end
		if top.lamellar then
			A("Sode", V(1.2, 0.4, 1.18), at(o * 0.07, 0.84, 0) * rot(0, 0, -10 * o), col)
			A("Sode", V(1.24, 0.4, 1.22), at(o * 0.1, 0.46, 0) * rot(0, 0, -10 * o), shade(col, 0.86))
		end
	end

	-- the front
	if top.open then
		T("Shirt", V(0.62, 1.98, 0.04), at(0, 0, FZ - 0.015), shirt)
		for _, o in { -1, 1 } do
			T("Lapel", V(0.2, 1.08, 0.06), at(o * 0.4, 0.44, FZ - 0.03) * rot(0, 0, o * -14), shade(col, 0.72), cloth)
		end
	end
	if top.vest then
		for _, o in { -1, 1 } do
			T("VestFront", V(0.76, 1.9, 0.07), at(o * 0.64, -0.02, FZ - 0.03), col, LEA)
		end
		T("VestBack", V(2.06 + pad * 2, 1.9, 0.07), at(0, -0.02, BZ + 0.03), col, LEA)
	end
	if top.waistcoat then
		for _, side in SKIN_SIDES do
			(parts[side .. " Arm"] :: BasePart).Color = trim
		end
		for _, x in { -0.55, 0.55 } do
			T("Waistcoat", V(0.9, 1.7, 0.06), at(x, -0.12, FZ - 0.02), col)
		end
		T("WaistcoatBack", V(2.04 + pad * 2, 1.7, 0.06), at(0, -0.12, BZ + 0.02), col)
		for k = 0, 2 do
			T("Button", V(0.08, 0.08, 0.04), at(0.14, -0.35 - k * 0.3, FZ - 0.06), GOLD, MET)
		end
	end
	if top.wrap then
		T("WrapUnder", V(0.5, 0.7, 0.03), at(0, 0.62, FZ - 0.008), if top.cuffs == "white" then WHITE else shade(col, 0.82))
		T("WrapEdge", V(0.16, 2.0, 0.05), at(-0.12, 0.08, FZ - 0.03) * rot(0, 0, -30), shade(col, 0.84))
		T("WrapEdge", V(0.16, 1.2, 0.05), at(0.28, 0.48, FZ - 0.02) * rot(0, 0, 30), shade(col, 0.9))
	end
	if top.surcoat then
		-- a tabard over mail: front and back panels to the knees, the emblem on the chest
		T("Tabard", V(1.5, 1.96, 0.05), at(0, -0.02, FZ - 0.03), col)
		T("RobeTail", V(1.5, 1.4, 0.05), at(0, -1.68, FZ - 0.07) * rot(4, 0, 0), col)
		T("TabardBack", V(1.5, 1.96, 0.05), at(0, -0.02, BZ + 0.03), col)
		T("RobeTail", V(1.5, 1.4, 0.05), at(0, -1.68, BZ + 0.07) * rot(-4, 0, 0), col)
		T("TabardHem", V(1.56, 0.1, 0.07), at(0, -2.33, FZ - 0.12) * rot(4, 0, 0), trim)
		if top.surcoat == "cross" then
			T("CrossV", V(0.22, 1.0, 0.04), at(0, 0.2, FZ - 0.06), trim)
			T("CrossH", V(0.7, 0.22, 0.04), at(0, 0.38, FZ - 0.06), trim)
		else
			T("Emblem", V(0.66, 0.66, 0.04), at(0, 0.25, FZ - 0.06) * rot(0, 0, 45), trim)
			T("EmblemCore", V(0.3, 0.3, 0.05), at(0, 0.25, FZ - 0.07) * rot(0, 0, 45), shade(col, 0.6))
		end
	end
	if top.lamellar then
		-- rows of lacquered plates, laced in the trim, and plates hanging over the hips
		for k, y in { 0.62, 0.1, -0.42 } do
			T("Lamella", V(2.08 + pad * 2, 0.46, 1.08 + pad * 2), at(0, y, 0), shade(col, 1 - (k % 2) * 0.12))
		end
		for _, y in { 0.36, -0.16 } do
			T("Lace", V(2.1 + pad * 2, 0.06, 1.1 + pad * 2), at(0, y, 0), trim)
		end
		for _, x in { -0.52, 0.52 } do
			T("Kusazuri", V(0.98, 0.82, 0.1), at(x, -1.32, FZ - 0.06) * rot(5, 0, 0), shade(col, 0.92))
		end
		T("Kusazuri", V(2.08, 0.82, 0.1), at(0, -1.32, BZ + 0.06) * rot(-5, 0, 0), shade(col, 0.92))
		T("KusazuriLace", V(2.16 + pad * 2, 0.08, 1.16 + pad * 2), at(0, -0.98, 0), trim)
	end
	if top.bands then
		for k, y in { 0.58, 0.0, -0.58 } do
			T("PuffBand", V(2.14 + pad * 2, 0.46, 1.14 + pad * 2), at(0, y, 0), shade(col, 1 - (k % 2) * 0.05), cloth)
		end
	end
	if top.quilt then
		for _, y in { 0.5, 0.05, -0.4 } do
			T("Quilt", V(2.06 + pad * 2, 0.05, 1.06 + pad * 2), at(0, y, 0), shade(col, 0.72))
		end
		T("QuiltSeam", V(0.05, 1.8, 0.03), at(0, -0.05, FZ - 0.03), shade(col, 0.72))
	end
	if top.colorblock then
		T("Block", V(2.04 + pad * 2, 0.66, 1.04 + pad * 2), at(0, 0.62, 0), trim)
		T("BlockLine", V(2.06 + pad * 2, 0.08, 1.06 + pad * 2), at(0, 0.26, 0), WHITE)
	end
	if top.print then
		T("Print", V(1.0, 0.9, 0.03), at(0, 0.18, FZ - 0.01), trim)
		T("PrintRing", V(0.03, 0.66, 0.66), at(0, 0.18, FZ - 0.03) * rot(0, 90, 0), DARK, nil, CYL)
		T("PrintCore", V(0.03, 0.4, 0.4), at(0, 0.18, FZ - 0.045) * rot(0, 90, 0), shade(trim, 1.25), NEON, CYL)
	end
	if top.letter then
		T("Letter", V(0.42, 0.5, 0.04), at(-0.5, 0.38, FZ - 0.02), trim)
		T("LetterCore", V(0.22, 0.3, 0.05), at(-0.5, 0.38, FZ - 0.03), col)
	end
	if top.crest then
		T("Crest", V(0.34, 0.4, 0.05), at(-0.56, 0.42, FZ - 0.04), trim)
		T("CrestStar", V(0.14, 0.14, 0.06), at(-0.56, 0.44, FZ - 0.06) * rot(0, 0, 45), GOLD, MET)
	end
	if top.emblem == true then
		T("Emblem", V(0.42, 0.42, 0.04), at(-0.5, 0.45, FZ - 0.03) * rot(0, 0, 45), trim, NEON)
		T("EmblemCore", V(0.22, 0.22, 0.05), at(-0.5, 0.45, FZ - 0.04) * rot(0, 0, 45), shade(col, 0.6))
	elseif top.emblem == "big" then
		T("Emblem", V(0.8, 0.8, 0.04), at(0, 0.25, FZ - 0.03) * rot(0, 0, 45), trim)
		T("EmblemCore", V(0.36, 0.36, 0.05), at(0, 0.25, FZ - 0.04) * rot(0, 0, 45), shade(col, 0.6))
	elseif top.emblem == "circle" then
		T("Emblem", V(0.04, 0.7, 0.7), at(0, 0.35, FZ - 0.03) * rot(0, 90, 0), trim, NEON, CYL)
		T("EmblemCore", V(0.05, 0.5, 0.5), at(0, 0.35, FZ - 0.04) * rot(0, 90, 0), shade(col, 0.7), nil, CYL)
	elseif top.emblem == "cross" then
		T("CrossV", V(0.14, 0.5, 0.04), at(0.5, 0.42, FZ - 0.04), trim, NEON)
		T("CrossH", V(0.5, 0.14, 0.04), at(0.5, 0.42, FZ - 0.04), trim, NEON)
	elseif top.emblem == "sun" then
		T("Sun", V(0.04, 0.42, 0.42), at(0, 0.5, FZ - 0.05) * rot(0, 90, 0), GOLD, MET, CYL)
		T("SunRays", V(0.8, 0.08, 0.04), at(0, 0.5, FZ - 0.04), GOLD, MET)
		T("SunRays", V(0.08, 0.8, 0.04), at(0, 0.5, FZ - 0.04), GOLD, MET)
	end
	if top.badge then
		T("Badge", V(0.22, 0.28, 0.05), at(-0.62, 0.42, FZ - 0.06), GOLD, MET)
		T("BadgeStar", V(0.1, 0.1, 0.06), at(-0.62, 0.44, FZ - 0.08) * rot(0, 0, 45), Color3.fromRGB(255, 240, 200), NEON)
	end
	if top.cross then
		T("CrossV", V(0.12, 0.42, 0.05), at(0.55, 0.45, FZ - 0.06), trim, NEON)
		T("CrossH", V(0.42, 0.12, 0.05), at(0.55, 0.45, FZ - 0.06), trim, NEON)
	end
	if top.buttons then
		local bc = if luma(col) > 0.6 then DARK elseif top.buttons == "double" then GOLD else shade(trim, 1)
		if top.buttons == "double" then
			for k = 0, 1 do
				for _, x in { -0.3, 0.3 } do
					T("Button", V(0.1, 0.1, 0.05), at(x, 0.45 - k * 0.55, FZ - 0.03), bc, MET)
				end
			end
		elseif top.buttons == "edge" then
			for k = 0, 3 do
				T("Button", V(0.08, 0.08, 0.05), at(0.38, 0.6 - k * 0.42, FZ - 0.05), bc)
			end
		else
			for k = 0, 2 do
				T("Button", V(0.08, 0.08, 0.05), at(0, 0.55 - k * 0.5, FZ - 0.03), bc)
			end
		end
	end
	if top.pocket then
		T("Pocket", V(1.2, 0.45, 0.05), at(0, -0.62, FZ - 0.02), shade(col, 0.82))
	end
	if top.pockets then
		for _, x in { -0.5, 0.5 } do
			T("ChestPocket", V(0.5, 0.42, 0.06), at(x, 0.36, FZ - 0.03), shade(col, 0.8))
		end
	end
	if top.zips then
		T("Zip", V(0.05, 1.8, 0.05), at(if top.open then 0.32 else 0, 0, FZ - 0.03), Color3.fromRGB(190, 190, 196), MET)
	end
	if top.strings then
		for _, x in { -0.18, 0.18 } do
			T("String", V(0.05, 0.56, 0.04), at(x, 0.62, FZ - 0.02), WHITE)
		end
	end
	if top.tie then
		T("Tie", V(0.18, 1.2, 0.05), at(0, 0.3, FZ - 0.03), if top.open or top.waistcoat then trim else shade(trim, 0.9))
		T("TieKnot", V(0.22, 0.16, 0.06), at(0, 0.88, FZ - 0.04), shade(trim, 0.8))
	end
	if top.apron then
		T("Apron", V(1.7, 2.3, 0.05), at(0, -0.4, FZ - 0.04), trim)
		T("ApronTie", V(2.08 + pad * 2, 0.12, 1.08 + pad * 2), at(0, -0.35, 0), shade(trim, 0.85))
		T("ApronPocket", V(0.8, 0.36, 0.06), at(0, -0.65, FZ - 0.07), shade(trim, 0.88))
	end
	if top.stole then
		local len = if top.robe or top.tails then 2.5 else 1.9
		for _, o in { -1, 1 } do
			T("Sash", V(0.24, len, 0.05), at(o * 0.3, 1.0 - len / 2, FZ - 0.05) * rot(2, 0, 0), trim)
		end
	end
	if top.tabard then
		T("TabardPanel", V(0.62, 2.0, 0.04), at(0, 0, FZ - 0.02), trim)
	end
	if top.kesa then
		T("Kesa", V(0.56, 2.7, 1.16 + pad * 2), at(0.05, 0.05, 0) * rot(0, 0, 34), shade(trim, 0.95))
		T("KesaRing", V(0.04, 0.26, 0.26), at(-0.42, 0.52, FZ - 0.09) * rot(0, 90, 0), GOLD, MET, CYL)
	end
	if top.straps then
		T("StrapA", V(0.2, 2.4, 1.12 + pad * 2), at(0, 0, 0) * rot(0, 0, 38), shade(col, 0.6), LEA)
		T("StrapB", V(0.2, 2.4, 1.12 + pad * 2), at(0, 0, 0) * rot(0, 0, -38), shade(col, 0.6), LEA)
		T("StrapRing", V(0.24, 0.24, 0.06), at(0, 0, FZ - 0.08) * rot(0, 0, 45), trim, NEON)
	end
	if top.laces then
		T("LaceGap", V(0.16, 1.1, 0.03), at(0, 0.45, FZ - 0.06), shade(trim, 0.85))
		for k = 0, 2 do
			T("Lace", V(0.36, 0.05, 0.04), at(0, 0.78 - k * 0.3, FZ - 0.08), ROPE)
		end
	end
	if top.highNeck then
		T("HighNeck", V(1.3, 0.42, 1.0 + pad), at(0, 1.12, 0), shade(col, 0.92))
	end

	-- the collar (the front stays low: the face is never covered)
	local c = top.collar
	if c == true then
		T("Collar", V(1.46, 0.24, 1.12 + pad), at(0, 1.02, 0.02), shade(col, 0.82), cloth)
	elseif c == "mandarin" then
		T("Collar", V(1.34, 0.28, 1.08 + pad), at(0, 1.1, 0.02), shade(col, 0.84), cloth)
	elseif c == "rib" then
		T("Collar", V(1.4, 0.2, 1.1 + pad), at(0, 1.02, 0.02), shade(col, 0.8))
		T("CollarStripe", V(1.42, 0.05, 1.12 + pad), at(0, 1.02, 0.02), trim)
	elseif c == "high" or c == "flare" then
		-- a stand-up collar round the back of the head, open at the front
		local big = c == "flare"
		local h = if big then 1.1 else 0.72
		local w = if big then 2.0 else 1.6
		local tilt = if big then -16 else -8
		T("CollarBack", V(w, h, 0.1), at(0, 0.92 + h / 2, 0.72) * rot(tilt, 0, 0), shade(col, 0.82), cloth)
		if big or top.runes == true then
			T("CollarEdge", V(w + 0.04, 0.07, 0.13), at(0, 0.92 + h - 0.04, 0.72 + math.sin(math.rad(-tilt)) * h / 2) * rot(tilt, 0, 0), trim, if top.runes then NEON else nil)
		end
		for _, o in { -1, 1 } do
			T("CollarSide", V(0.1, h * 0.82, 0.86), at(o * (if big then 0.92 else 0.78), 0.92 + h * 0.4, 0.26) * rot(0, o * (if big then 18 else 6), o * (if big then -14 else -5)), shade(col, 0.78), cloth)
		end
	elseif c == "fur" then
		T("FurCollar", V(1.96, 0.44, 1.26 + pad), at(0, 1.0, 0.06), fur)
		for k, p in { { -0.66, 1.1, 0.24, 0.66 }, { 0.66, 1.1, 0.24, 0.66 } } do
			T("FurPuff" .. k, V(p[4], p[4], p[4]), at(p[1], p[2], p[3]), fur, FAB, BALL)
		end
		for _, o in { -1, 1 } do
			T("FurLapel", V(0.32, 1.25, 0.16), at(o * 0.44, 0.34, FZ - 0.08), fur)
		end
	elseif c == "sailor" then
		T("SailorBack", V(1.72, 0.92, 0.05), at(0, 0.56, BZ + 0.02), trim)
		T("SailorStripe", V(1.6, 0.05, 0.06), at(0, 0.2, BZ + 0.03), WHITE)
		for _, o in { -1, 1 } do
			T("SailorFront", V(0.24, 1.02, 0.05), at(o * 0.32, 0.5, FZ - 0.02) * rot(0, 0, o * -26), trim)
		end
		T("Neckerchief", V(0.34, 0.34, 0.06), at(0, 0.02, FZ - 0.04) * rot(0, 0, 45), Color3.fromRGB(190, 40, 50))
		T("Sash", V(0.16, 0.5, 0.05), at(0, -0.3, FZ - 0.05), Color3.fromRGB(190, 40, 50))
	elseif c == "hanbok" then
		-- the white collar band (dongjeong) and the ribbon tie (goreum), in the trim
		T("HanbokCollar", V(0.2, 1.2, 0.05), at(-0.1, 0.5, FZ - 0.02) * rot(0, 0, -36), WHITE)
		T("HanbokCollar", V(0.2, 0.7, 0.05), at(0.38, 0.76, FZ - 0.015) * rot(0, 0, 32), shade(WHITE, 0.94))
		T("GoreumKnot", V(0.26, 0.2, 0.07), at(0.26, 0.12, FZ - 0.05), trim)
		T("Sash", V(0.14, 1.3, 0.04), at(0.2, -0.62, FZ - 0.05) * rot(0, 0, 4), trim)
		T("Sash", V(0.14, 1.0, 0.04), at(0.36, -0.48, FZ - 0.045) * rot(0, 0, -7), shade(trim, 0.9))
	end
	if top.hood then
		T("HoodDown", V(1.4, 0.74, 0.44), at(0, 0.72, BZ + 0.2) * rot(-8, 0, 0), shade(col, 0.88), cloth)
		T("HoodRim", V(1.5, 0.2, 0.5), at(0, 1.08, BZ + 0.12), shade(col, 0.76), cloth)
	end

	-- the belt
	local b = top.belt
	local by = -0.66
	if b == "sash" then
		T("SashBand", V(2.1 + pad * 2, 0.34, 1.1 + pad * 2), at(0, -0.64, 0), trim)
		T("SashKnot", V(0.34, 0.28, 0.1), at(0.55, -0.64, FZ - 0.06), shade(trim, 0.85))
		T("Sash", V(0.26, 1.05, 0.06), at(0.6, -1.25, FZ - 0.1) * rot(4, 0, -5), shade(trim, 0.92))
	elseif b == "rope" then
		T("RopeBelt", V(2.1 + pad * 2, 0.12, 1.1 + pad * 2), at(0, by, 0), ROPE)
		T("RopeKnot", V(0.22, 0.22, 0.22), at(-0.42, by, FZ - 0.08), ROPE, FAB, BALL)
		T("Sash", V(0.08, 0.85, 0.08), at(-0.42, by - 0.5, FZ - 0.08) * rot(0, 0, 5), ROPE)
	elseif b then
		T("Belt", V(2.08 + pad * 2, 0.2, 1.08 + pad * 2), at(0, by, 0), shade(LEATHER, 0.7), LEA)
		T("Buckle", V(0.28, 0.24, 0.06), at(0, by, FZ - 0.07), GOLD, MET)
		if b == "pouches" then
			for _, o in { -1, 1 } do
				role(T("BeltPouch", V(0.4, 0.38, 0.22), at(o * 0.72, by - 0.16, FZ - 0.13), LEATHER, LEA), "belt_pouch")
			end
		end
	end

	-- below the waist: coat tails, a robe, a waist cloth, a cloak
	if top.tails then
		local len = if top.tails == "ankle" then 2.7 elseif top.tails == "tatter" then 2.3 else 1.6
		local y = -0.95 - len / 2
		if top.tails == "tatter" then
			for k, l in { 2.2, 2.6, 1.8 } do
				T("RobeTail", V(0.72, l, 0.08), at(-0.7 + (k - 1) * 0.7, -0.95 - l / 2, BZ + 0.06) * rot(-4, 0, (k % 2) * 4 - 2), shade(col, 1 - (k % 2) * 0.08))
			end
		else
			T("RobeTail", V(2.06 + pad * 2, len, 0.1), at(0, y, BZ + 0.04) * rot(-4, 0, 0), col, cloth)
		end
		for _, o in { -1, 1 } do
			T("CoatSide", V(0.1, len, 1.06 + pad * 2), at(o * (1.03 + pad), y, 0.02) * rot(0, 0, o * 3), shade(col, 0.95), cloth)
			T("CoatFront", V(0.52, len, 0.1), at(o * (0.79 + pad), y, FZ - 0.03) * rot(3, 0, 0), col, cloth)
			if top.cuffs == "rune" then
				T("CoatEdge", V(0.08, len, 0.12), at(o * (0.55 + pad), y, FZ - 0.05) * rot(3, 0, 0), trim, if top.runes then NEON else nil)
			end
		end
	end
	if top.robe then
		-- (over a robe skirt in the bottoms, a long robe stops at the calf: the layers show)
		local under = ctx.bottom.robe ~= nil or ctx.bottom.skirt == "long"
		local len = if top.robe == "knee" then 1.25 elseif under then 1.42 else 1.98
		robeSkirt(ctx, len, col, trim, {
			slit = if top.robe == "split" then ctx.bottomCol else nil,
			panel = if top.tabard then trim elseif top.stole then nil else nil,
			runes = top.runes == true,
			grow = 0.04,
		})
	end
	if top.waistCloth or top.sidePanel then
		T("RobeTail", V(0.72, 1.2, 0.06), at(0, -1.36, FZ - 0.08) * rot(4, 0, 0), shade(col, 0.84))
		T("WaistClothHem", V(0.76, 0.08, 0.08), at(0, -1.92, FZ - 0.12) * rot(4, 0, 0), trim)
	end
	if top.cloak then
		role(T("Cape", V(2.16 + pad * 2, 3.5, 0.1), at(0, -0.72, BZ + 0.12) * rot(-4, 0, 0), shade(col, 0.82)), "cape_skinned")
		for _, o in { -1, 1 } do
			T("CloakFront", V(0.44, 1.95, 0.08), at(o * (0.8 + pad), 0.04, FZ - 0.06), shade(col, 0.82))
		end
		T("CloakClasp", V(0.2, 0.2, 0.06), at(0.52, 0.86, FZ - 0.11) * rot(0, 0, 45), GOLD, MET)
	end
	if top.mantle == true or top.mantle == "short" then
		T("Mantle", V(2.36 + pad * 2, 0.56, 1.36 + pad * 2), at(0, 0.8, 0.02), shade(col, 0.88), cloth)
		T("MantleTrim", V(2.4 + pad * 2, 0.08, 1.4 + pad * 2), at(0, 0.54, 0.02), trim, if top.runes then NEON else nil)
	end
	if top.runes == true then
		for k = 0, 0 do
			for _, o in { -1, 1 } do
				T("Rune", V(0.11, 0.11, 0.04), at(o * 0.44, 0.5 - k * 0.6, FZ - 0.06) * rot(0, 0, 45), trim, NEON)
			end
		end
	elseif top.runes == "small" then
		for _, o in { -1, 1 } do
			T("Rune", V(0.12, 0.12, 0.04), at(o * 0.56, 0.62, FZ - 0.05) * rot(0, 0, 45), trim, NEON)
		end
	elseif top.runes == "column" then
		T("RuneLine", V(0.05, 1.7, 0.04), at(0, -0.05, FZ - 0.05), shade(trim, 1.3), NEON)
		for k = 0, 2 do
			T("Rune", V(0.16, 0.16, 0.04), at(0, 0.55 - k * 0.55, FZ - 0.06) * rot(0, 0, 45), shade(trim, 1.3), NEON)
		end
	end
end

-- ── the bottoms, the shoes ──
local function dressBottom(ctx: any)
	local b = ctx.bottom
	local col = ctx.bottomCol
	local skin = ctx.skin
	local parts = ctx.parts
	local T = on(ctx, parts.Torso)
	local mat = if b.leather then LEA else FAB
	for _, side in SKIN_SIDES do
		local leg: BasePart = parts[side .. " Leg"]
		local o = sideOf(side)
		local L = on(ctx, leg)
		if b.short or b.skirt == "pleat" then
			leg.Color = skin
			if b.short then
				L("Short", V(1.05, 0.9, 1.05), at(0, 0.56, 0), col)
				L("ShortHem", V(1.07, 0.1, 1.07), at(0, 0.14, 0), shade(col, 0.8))
			else
				-- (knee socks under a pleated skirt)
				L("Sock", V(1.03, 0.7, 1.03), at(0, -0.58, 0), Color3.fromRGB(30, 30, 36))
			end
		else
			leg.Color = col
			leg.Material = mat
		end
		if b.seams then
			L("Seam", V(0.04, 1.9, 0.04), at(o * 0.51, 0.02, 0), shade(col, 1.25))
		end
		if b.crease then
			L("Crease", V(0.04, 1.8, 0.02), at(0, 0.02, -0.51), shade(col, 0.8))
		end
		if b.rips then
			L("Rip", V(0.44, 0.2, 0.04), at(0.05, 0.05, -0.51), skin)
			L("Rip2", V(0.28, 0.12, 0.04), at(-0.12, -0.42, -0.51), skin)
		end
		if b.wide then
			L("Wide", V(1.26, 1.72, 1.26), at(0, -0.1, 0), col)
		end
		if b.ties then
			L("AnkleTie", V(1.12, 0.16, 1.12), at(0, -0.8, 0), WHITE)
		end
		if b.hakama then
			L("Hakama", V(1.32, 1.86, 1.32), at(o * 0.04, -0.06, 0) * rot(0, 0, o * 2), col)
			L("Pleat", V(0.05, 1.7, 0.05), at(0.2, -0.1, -0.67), shade(col, 0.75))
		end
		if b.pockets and not b.skirt then
			L("CargoPocket", V(0.06, 0.5, 0.5), at(o * 0.52, 0.1, 0), shade(col, 0.82))
		end
		if b.kneepads then
			L("Kneepad", V(0.78, 0.4, 0.16), at(0, -0.05, -0.56), DARK)
		end
		if b.holster and side == "Right" then
			L("Holster", V(0.12, 0.6, 0.5), at(0.55, 0.3, 0), DARK, LEA)
			L("HolsterStrap", V(1.06, 0.1, 1.06), at(0, 0.1, 0), DARK, LEA)
		end
		if b.laces then
			L("LaceSeam", V(0.06, 1.6, 0.08), at(o * 0.52, 0.1, 0), shade(col, 0.6), LEA)
			for k = 0, 1 do
				L("Lace", V(0.08, 0.05, 0.3), at(o * 0.53, 0.5 - k * 0.6, 0), ROPE)
			end
		end
		if b.straps then
			for _, y in { 0.55, 0.15 } do
				L("ThighStrap", V(1.06, 0.1, 1.06), at(0, y, 0), LEATHER, LEA)
			end
			L("ThighPouch", V(0.12, 0.34, 0.36), at(o * 0.56, 0.35, 0), LEATHER, LEA)
		end
		if b.wraps then
			for k = 0, 3 do
				L("LegWrap", V(1.06, 0.09, 1.06), at(0, 0.3 - k * 0.3, 0) * rot(0, 0, if k % 2 == 0 then 8 else -8), shade(col, 1.35))
			end
		end
		if b.stripes then
			L("Stripe", V(0.06, 1.9, 0.5), at(o * 0.52, 0, 0), ctx.trim)
		end
		if b.cuffs then
			L("Cuff", V(1.04, 0.16, 1.04), at(0, -0.62, 0), shade(col, 0.75))
		end
		if b.plates then
			L("Greave", V(0.86, 0.9, 0.12), at(0, -0.25, -0.55), STEEL, MET)
			L("Knee", V(0.7, 0.36, 0.16), at(0, 0.3, -0.56), shade(STEEL, 1.12), MET)
			if b.cuisses then
				L("Cuisse", V(1.1, 0.62, 1.1), at(0, 0.6, 0), shade(STEEL, 0.92), MET)
			end
		end
	end
	-- skirts and robes hang from the torso (a robe the top already has is the outer layer)
	if b.skirt == "pleat" and ctx.robe == 0 then
		T("Skirt", V(2.2, 1.0, 1.2), at(0, -1.35, 0), col)
		for k = -2, 2 do
			T("SkirtPleat", V(0.05, 0.92, 0.05), at(k * 0.36, -1.38, -0.62), shade(col, 0.78))
		end
		if b.pockets then
			for _, x in { -1.12, 1.12 } do
				T("SkirtPouch", V(0.14, 0.45, 0.5), at(x, -1.3, 0), shade(col, 0.8))
			end
			T("SkirtBelt", V(2.24, 0.16, 1.24), at(0, -0.9, 0), shade(col, 0.6))
		end
	elseif b.skirt == "long" then
		robeSkirt(ctx, 1.75, col, shade(col, 0.82), { name = "LongSkirt", grow = -0.06 })
	elseif b.robe then
		local outer = ctx.robe > 0
		local len = if b.robe == "floor" then 2.02 elseif b.robe == "split" then 1.55 else 1.86
		robeSkirt(ctx, len, col, shade(col, 0.75), {
			name = if outer then "UnderRobe" else "RobeSkirt",
			grow = if outer then -0.1 else 0,
			slit = if b.robe == "split" then shade(col, 0.5) else nil,
		})
	end
	if b.tassets then
		for k, x in { -0.55, 0.55 } do
			T("Tasset", V(0.96, 0.9, 0.1), at(x, -1.38, -(0.62 + ctx.pad)) * rot(6, 0, 0), STEEL, MET)
			T("TassetRivet" .. k, V(0.1, 0.1, 0.05), at(x, -1.06, -(0.69 + ctx.pad)), GOLD, MET)
		end
		T("Tasset", V(2.06, 0.9, 0.1), at(0, -1.38, 0.62 + ctx.pad) * rot(-6, 0, 0), STEEL, MET)
		for _, o in { -1, 1 } do
			T("Tasset", V(0.1, 0.9, 1.1), at(o * (1.1 + ctx.pad), -1.38, 0) * rot(0, 0, o * 6), shade(STEEL, 0.9), MET)
		end
		T("TassetBelt", V(2.2 + ctx.pad * 2, 0.16, 1.24 + ctx.pad * 2), at(0, -0.92, 0), LEATHER, LEA)
	end
	if b.mail then
		T("MailSkirt", V(2.18 + ctx.pad * 2, 1.15, 1.18 + ctx.pad * 2), at(0, -1.5, 0), STEEL, MET)
		T("MailHem", V(2.2 + ctx.pad * 2, 0.08, 1.2 + ctx.pad * 2), at(0, -2.05, 0), shade(STEEL, 0.8), MET)
	end
	if b.hakama then
		T("HakamaBand", V(2.12 + ctx.pad * 2, 0.24, 1.12 + ctx.pad * 2), at(0, -0.9, 0), shade(col, 0.85))
	end
end

local function shoesOn(ctx: any)
	local shoe = Looks.find("SHOES", ctx.look.shoes) or Looks.SHOES[1]
	local trim = ctx.trim
	for _, side in SKIN_SIDES do
		local L = on(ctx, ctx.parts[side .. " Leg"])
		local id = shoe.id
		local sc = if id == "sneakers" or id == "hightops" then Color3.fromRGB(230, 230, 226)
			elseif id == "sandals" then Color3.fromRGB(120, 86, 56)
			elseif shoe.metal then STEEL
			elseif shoe.wood then Color3.fromRGB(150, 110, 70)
			elseif shoe.trimSole then Color3.fromRGB(40, 42, 50)
			elseif shoe.loafer or shoe.knee then Color3.fromRGB(54, 36, 26)
			elseif shoe.tabi then Color3.fromRGB(34, 34, 40)
			elseif shoe.curled then shade(ctx.col, 0.7)
			else Color3.fromRGB(28, 26, 26)
		local mat = if id == "dress" or id == "loafers" then GLASS elseif shoe.metal then MET elseif shoe.wood then WOOD elseif shoe.knee then LEA else nil
		if shoe.knee then
			-- a tall boot to the knee (the kit's boot: foot forward at the bottom)
			role(L("Boot", V(1.08, 1.08, 1.2), at(0, -0.47, -0.06), sc, mat), "boot")
			if shoe.metal then
				covered(L("BootKnee", V(0.7, 0.34, 0.16), at(0, 0.02, -0.62), shade(STEEL, 1.15), MET), "Boot")
			else
				L("BootCuff", V(1.14, 0.16, 1.16), at(0, 0.1, 0), shade(sc, 0.8), mat)
			end
		else
			local h = if shoe.tall then 0.7 elseif shoe.high then 0.56 elseif shoe.low then 0.16 elseif shoe.tabi then 0.5 else 0.36
			local s = L(if shoe.tall then "Boot" else "Shoe", V(1.04, h, 1.16), at(0, -1 + h / 2 - 0.01, -0.06), sc, mat)
			if shoe.tall then
				role(s, "boot")
			end
		end
		if id == "sneakers" or id == "hightops" or shoe.trimSole then
			L("Sole", V(1.06, 0.1, 1.18), at(0, -0.96, -0.06), if shoe.trimSole then trim else Color3.fromRGB(250, 250, 250), if shoe.trimSole then NEON else nil)
		end
		if id == "hightops" then
			L("Ankle", V(1.06, 0.16, 1.06), at(0, -0.6, 0.02), trim)
		end
		if shoe.metal and not shoe.knee then
			covered(L("ToeCap", V(0.9, 0.24, 0.2), at(0, -0.86, -0.62), shade(sc, 1.2), MET), "Boot")
		end
		if shoe.wood then
			L("Strap", V(0.5, 0.08, 0.5), at(0, -0.82, -0.2), Color3.fromRGB(160, 30, 36))
		end
		if shoe.tabi then
			L("TabiWrap", V(1.07, 0.08, 1.07), at(0, -0.62, 0) * rot(0, 0, 8), Color3.fromRGB(70, 70, 80))
		end
		if shoe.curled then
			L("CurlToe", V(0.4, 0.22, 0.4), at(0, -0.82, -0.66) * rot(28, 0, 0), trim)
		end
		if shoe.loafer then
			L("LoaferBand", V(0.7, 0.06, 0.1), at(0, -0.84, -0.6), GOLD, MET)
		end
	end
end

-- ── gloves, and bare hands below a sleeve ──
local GLOVE_COLORS = {
	gloves = { 30, 28, 30 }, leather = { 92, 60, 38 }, fingerless = { 34, 32, 36 }, work = { 186, 160, 110 },
	silk = { 242, 242, 238 }, medical = { 200, 222, 240 }, wraps = { 232, 224, 204 }, long = { 26, 24, 30 },
	mage = { 40, 34, 60 }, claws = { 36, 34, 40 },
}
local function glovesOn(ctx: any)
	local g = ctx.look.gloves or "none"
	for _, side in SKIN_SIDES do
		local arm: BasePart = ctx.parts[side .. " Arm"]
		local A = on(ctx, arm)
		local o = sideOf(side)
		local gc = GLOVE_COLORS[g]
		local color = if gc then Color3.fromRGB(gc[1], gc[2], gc[3]) else DARK
		local covers = true
		if g == "none" then
			covers = false
		elseif g == "gloves" or g == "medical" then
			A("Glove", V(1.05, 0.44, 1.05), at(0, -0.79, 0), color, if g == "gloves" then LEA else nil)
		elseif g == "leather" or g == "work" then
			A("Glove", V(1.05, 0.42, 1.05), at(0, -0.8, 0), color, LEA)
			A("GloveCuff", V(1.14, 0.2, 1.14), at(0, -0.56, 0), shade(color, 0.8), LEA)
		elseif g == "silk" then
			A("Glove", V(1.05, 0.56, 1.05), at(0, -0.73, 0), color)
		elseif g == "fingerless" then
			covers = false
			if ctx.sleeved[side] then
				A("Hand", V(1.03, 0.3, 1.03), at(0, -0.86, 0), ctx.skin)
			end
			A("Glove", V(1.05, 0.28, 1.05), at(0, -0.78, 0), color, LEA)
		elseif g == "wraps" then
			A("Glove", V(1.05, 0.46, 1.05), at(0, -0.78, 0), color)
			A("WrapBand", V(1.07, 0.07, 1.07), at(0, -0.66, 0) * rot(0, 0, 10), shade(color, 0.85))
		elseif g == "long" or g == "mage" then
			A("Glove", V(1.05, if g == "long" then 1.1 else 0.5, 1.05), at(0, if g == "long" then -0.46 else -0.76, 0), color, LEA)
			A("GloveCuff", V(1.08, 0.08, 1.08), at(0, if g == "long" then 0.06 else -0.5, 0), ctx.trim, if g == "mage" then NEON else nil)
			if g == "mage" then
				A("GloveRune", V(0.04, 0.2, 0.2), at(o * 0.53, -0.8, 0) * rot(45, 0, 0), ctx.trim, NEON)
			end
		elseif g == "bracers" then
			covers = false
			A("Bracer", V(1.14, 0.62, 1.14), at(0, -0.42, 0), LEATHER, LEA)
			A("BracerLace", V(0.04, 0.5, 0.2), at(o * 0.58, -0.42, 0), ROPE)
		elseif g == "gauntlets" or g == "claws" then
			local mc = if g == "claws" then color else ctx.armorCol
			role(A("Gauntlet", V(1.14, 0.78, 1.14), at(0, -0.62, 0), mc, MET), "gauntlet")
			if g == "claws" then
				for _, k in { -1, 1 } do
					A("Claw", V(0.07, 0.56, 0.08), at(k * 0.22, -1.18, -0.36) * rot(-18, 0, 0), STEEL, MET)
				end
			else
				covered(A("GauntletCuff", V(1.26, 0.14, 1.26), at(0, -0.24, 0), shade(mc, 1.15), MET), "Gauntlet")
				A("Knuckles", V(1.0, 0.16, 0.2), at(0, -0.88, -0.52), shade(mc, 0.8), MET)
			end
		end
		ctx.gloved[side] = covers
		-- a sleeve that reaches the wrist leaves the hand to draw
		if not covers and ctx.sleeved[side] and g ~= "fingerless" then
			A("Hand", V(1.03, 0.3, 1.03), at(0, -0.86, 0), ctx.skin)
		end
	end
end

-- ── armour over the clothes ──
local function armorOn(ctx: any)
	local a = ctx.look.armor or "none"
	if a == "none" then
		return
	end
	local parts, pad = ctx.parts, ctx.pad
	local col, trim = ctx.armorCol, ctx.trim
	local torso: BasePart = parts.Torso
	local T = on(ctx, torso)
	local FZ, BZ = -(0.5 + pad), 0.5 + pad
	local function arms(f: (A: any, o: number, side: string) -> ())
		for _, side in SKIN_SIDES do
			f(on(ctx, parts[side .. " Arm"]), sideOf(side), side)
		end
	end
	local function legs(f: (L: any, o: number) -> ())
		for _, side in SKIN_SIDES do
			f(on(ctx, parts[side .. " Leg"]), sideOf(side))
		end
	end
	-- (chest pieces and pendants sit on top of anything worn over the chest)
	if a ~= "pauldrons" and a ~= "single_pauldron" and a ~= "mage_bracers" and a ~= "archer_guard" and a ~= "cloak" and a ~= "harness" then
		ctx.chestZ = FZ - 0.14
	end
	local function cuirass(color: Color3, name: string?)
		T(name or "Cuirass", V(2.12 + pad * 2, 1.82, 1.18 + pad * 2), at(0, 0.08, 0), color, MET)
	end
	local function pauldron(A: any, o: number, color: Color3, big: number?)
		local s = big or 1
		A("Pauldron", V(1.3 * s, 0.5 * s, 1.3 * s), at(0.07 * o, 0.9, 0) * rot(0, 0, -13 * o), color, MET)
	end
	if a == "vest" then
		T("Vest", V(2.06 + pad * 2, 1.7, 1.12 + pad * 2), at(0, 0.1, 0), col)
		for i = -1, 1 do
			T("Pouch" .. i, V(0.4, 0.34, 0.12), at(i * 0.55, -0.45, FZ - 0.12), shade(col, 0.8))
		end
		T("Patch", V(0.5, 0.26, 0.04), at(-0.5, 0.5, FZ - 0.13), trim, NEON)
		T("VestCollar", V(1.6, 0.2, 1.2 + pad * 2), at(0, 0.98, 0), shade(col, 0.8))
	elseif a == "plate" or a == "heavy" then
		cuirass(col)
		T("Ridge", V(0.16, 1.7, 0.08), at(0, 0.08, FZ - 0.12), shade(col, 1.25), MET)
		arms(function(A, o)
			pauldron(A, o, col)
			if a == "heavy" then
				A("Vambrace", V(1.12, 0.9, 1.12), at(0, -0.4, 0), shade(col, 0.9), MET)
			end
		end)
		if a == "heavy" then
			legs(function(L)
				L("Tasset", V(1.1, 0.7, 1.14), at(0, 0.55, 0), col, MET)
			end)
		end
		T("Gem", V(0.24, 0.24, 0.06), at(0, 0.5, FZ - 0.16), trim, NEON)
	elseif a == "pauldrons" then
		arms(function(A, o)
			A("Pauldron", V(1.28, 0.46, 1.28), at(0.06 * o, 0.92, 0) * rot(0, 0, -14 * o), col, MET)
			A("PauldronTrim", V(1.3, 0.08, 1.3), at(0.06 * o, 0.7, 0) * rot(0, 0, -14 * o), trim, NEON)
		end)
		T("PauldronStrap", V(1.7, 0.12, 1.16 + pad * 2), at(0, 0.88, 0), LEATHER, LEA)
	elseif a == "single_pauldron" then
		arms(function(A, o, side)
			if side == "Left" then
				A("Pauldron", V(1.42, 0.56, 1.42), at(-0.1, 0.92, 0) * rot(0, 0, 16), col, MET)
				A("PauldronLame", V(1.36, 0.36, 1.36), at(-0.14, 0.58, 0) * rot(0, 0, 16), shade(col, 0.88), MET)
				A("PauldronTrim", V(1.44, 0.07, 1.44), at(-0.1, 0.66, 0) * rot(0, 0, 16), trim, NEON)
			end
		end)
		T("PauldronStrap", V(0.22, 2.5, 1.14 + pad * 2), at(0, 0, 0) * rot(0, 0, 40), LEATHER, LEA)
	elseif a == "harness" then
		T("StrapA", V(0.22, 2.4, 1.1 + pad * 2), at(0, 0, 0) * rot(0, 0, 38), col, LEA)
		T("StrapB", V(0.22, 2.4, 1.1 + pad * 2), at(0, 0, 0) * rot(0, 0, -38), col, LEA)
		T("Buckle", V(0.3, 0.3, 0.08), at(0, 0, FZ - 0.1), GOLD, MET)
		T("HarnessBelt", V(2.1 + pad * 2, 0.16, 1.1 + pad * 2), at(0, -0.8, 0), col, LEA)
	elseif a == "cloak" then
		T("Mantle", V(2.3 + pad * 2, 0.4, 1.3 + pad * 2), at(0, 0.9, 0), col)
		role(T("Cape", V(2.1 + pad * 2, 2.8, 0.1), at(0, -0.4, BZ + 0.12), col), "cape_skinned")
		T("Clasp", V(0.26, 0.26, 0.08), at(0.6, 0.85, FZ - 0.12), trim, NEON)
	elseif a == "breastplate" then
		T("Cuirass", V(1.9, 1.5, 0.3), at(0, 0.22, FZ - 0.08), col, MET)
		T("Ridge", V(0.12, 1.4, 0.08), at(0, 0.22, FZ - 0.24), shade(col, 1.25), MET)
		T("PlateStrap", V(2.08 + pad * 2, 0.14, 1.08 + pad * 2), at(0, -0.4, 0), LEATHER, LEA)
		T("PlateTrim", V(1.92, 0.08, 0.32), at(0, -0.5, FZ - 0.08), trim)
	elseif a == "chainmail" then
		T("MailShirt", V(2.08 + pad * 2, 2.0, 1.08 + pad * 2), at(0, 0, 0), STEEL, MET)
		T("MailSkirt", V(2.16 + pad * 2, 0.7, 1.16 + pad * 2), at(0, -1.3, 0), shade(STEEL, 0.94), MET)
		T("MailBelt", V(2.12 + pad * 2, 0.18, 1.12 + pad * 2), at(0, -0.8, 0), LEATHER, LEA)
		arms(function(A)
			A("MailSleeve", V(1.08, 1.0, 1.08), at(0, 0.48, 0), STEEL, MET)
		end)
		T("Coif", V(1.5, 0.3, 1.2 + pad * 2), at(0, 1.02, 0.02), shade(STEEL, 0.9), MET)
	elseif a == "leather_armor" or a == "shadow_leather" then
		local dark = a == "shadow_leather"
		T("Cuirass", V(2.1 + pad * 2, 1.7, 1.14 + pad * 2), at(0, 0.12, 0), col, LEA)
		if not dark then
			T("LeatherBand", V(2.12 + pad * 2, 0.08, 1.16 + pad * 2), at(0, 0.2, 0), shade(col, 0.7), LEA)
		end
		arms(function(A, o, side)
			if side == "Left" or dark then
				A("Pauldron", V(1.2, 0.4, 1.2), at(0.05 * o, 0.92, 0) * rot(0, 0, -12 * o), shade(col, 0.9), LEA)
			end
			if dark then
				A("Bracer", V(1.12, 0.6, 1.12), at(0, -0.45, 0), col, LEA)
			end
		end)
		if dark then
			T("StrapA", V(0.16, 2.4, 1.18 + pad * 2), at(0, 0, 0) * rot(0, 0, 36), shade(col, 0.6), LEA)
			T("Rune", V(0.14, 0.14, 0.05), at(-0.42, 0.42, FZ - 0.12) * rot(0, 0, 45), trim, NEON)
		end
	elseif a == "archer_guard" then
		T("ChestGuard", V(0.95, 0.95, 0.14), at(-0.5, 0.45, FZ - 0.07), col, LEA)
		T("GuardStrap", V(0.18, 2.5, 1.14 + pad * 2), at(0, 0, 0) * rot(0, 0, -38), shade(col, 0.7), LEA)
		arms(function(A, o, side)
			if side == "Left" then
				A("ArmGuard", V(1.14, 0.8, 1.14), at(0, -0.38, 0), col, LEA)
				A("ArmGuardTrim", V(1.16, 0.06, 1.16), at(0, -0.02, 0), trim)
			end
		end)
	elseif a == "mage_bracers" then
		arms(function(A, o)
			A("Bracer", V(1.14, 0.7, 1.14), at(0, -0.42, 0), col, MET)
			A("BracerRune", V(1.16, 0.06, 1.16), at(0, -0.6, 0), trim, NEON)
			A("BracerGem", V(0.06, 0.18, 0.18), at(o * 0.58, -0.42, 0) * rot(45, 0, 0), trim, NEON)
		end)
	elseif a == "brigandine" then
		T("Brigandine", V(2.1 + pad * 2, 1.76, 1.14 + pad * 2), at(0, 0.1, 0), col)
		for r = 0, 1 do
			for _, k in { -1, 1 } do
				T("Rivet", V(0.09, 0.09, 0.04), at(k * 0.5, 0.45 - r * 0.6, FZ - 0.09), GOLD, MET)
			end
		end
		T("BrigandineCollar", V(1.5, 0.24, 1.2 + pad * 2), at(0, 0.98, 0), shade(col, 0.8))
		for _, x in { -0.5, 0.5 } do
			T("Tasset", V(0.9, 0.6, 0.1), at(x, -1.2, FZ - 0.08) * rot(5, 0, 0), shade(col, 0.9))
		end
		arms(function(A, o)
			pauldron(A, o, STEEL, 0.92)
		end)
	elseif a == "scale" or a == "dragon_scale" then
		local dragon = a == "dragon_scale"
		cuirass(col)
		for k, y in { 0.56, 0.04, -0.48 } do
			T("ScaleRow", V(2.16 + pad * 2, 0.44, 1.22 + pad * 2), at(0, y, 0) * rot(-4, 0, 0), shade(col, 0.82 + (k % 2) * 0.14), MET)
		end
		arms(function(A, o)
			pauldron(A, o, shade(col, 0.9), if dragon then 1.08 else 0.96)
			if dragon then
				A("Horn", V(0.18, 0.62, 0.18), at(0.36 * o, 1.3, 0.12) * rot(-20, 0, -30 * o), BONE)
			end
		end)
		if dragon then
			T("Gem", V(0.3, 0.3, 0.06), at(0, 0.5, FZ - 0.16) * rot(0, 0, 45), trim, NEON)
			T("Gorget", V(1.5, 0.3, 1.24 + pad * 2), at(0, 1.02, 0), shade(col, 0.75), MET)
		end
	elseif a == "full_plate" or a == "holy_plate" then
		local holy = a == "holy_plate"
		local edge = if holy then GOLD else shade(col, 1.25)
		cuirass(col)
		T("Ridge", V(0.14, 1.7, 0.08), at(0, 0.08, FZ - 0.12), edge, MET)
		T("Gorget", V(1.5, 0.32, 1.24 + pad * 2), at(0, 1.02, 0), shade(col, 0.85), MET)
		for k, y in { -1.0, -1.28 } do
			T("Fauld" .. k, V(2.16 + pad * 2 + k * 0.06, 0.3, 1.22 + pad * 2 + k * 0.06), at(0, y, 0), shade(col, 0.95 - k * 0.05), MET)
		end
		arms(function(A, o)
			pauldron(A, o, col, 1.06)
			A("Vambrace", V(1.12, 0.8, 1.12), at(0, -0.36, 0), shade(col, 0.92), MET)
			if holy then
				A("PauldronTrim", V(1.4, 0.06, 1.4), at(0.07 * o, 0.68, 0) * rot(0, 0, -13 * o), GOLD, MET)
			end
		end)
		if holy then
			T("Sun", V(0.06, 0.6, 0.6), at(0, 0.35, FZ - 0.14) * rot(0, 90, 0), GOLD, MET, CYL)
			T("SunCore", V(0.07, 0.32, 0.32), at(0, 0.35, FZ - 0.16) * rot(0, 90, 0), trim, NEON, CYL)
		else
			T("Gem", V(0.24, 0.24, 0.06), at(0, 0.5, FZ - 0.16) * rot(0, 0, 45), trim, NEON)
		end
	elseif a == "spiked" then
		cuirass(col)
		T("Ridge", V(0.16, 1.7, 0.08), at(0, 0.08, FZ - 0.12), shade(col, 0.7), MET)
		arms(function(A, o)
			local p = A("Pauldron", V(1.34, 0.56, 1.34), at(0.08 * o, 0.92, 0) * rot(0, 0, -14 * o), col, MET)
			role(p, "pauldron_spiked")
			for _, k in { -1, 1 } do
				covered(A("Spike", V(0.16, 0.56, 0.16), at(0.2 * o, 1.3, k * 0.3) * rot(0, 0, -30 * o), STEEL, MET), "Pauldron")
			end
		end)
		T("Gem", V(0.26, 0.26, 0.06), at(0, 0.5, FZ - 0.16) * rot(0, 0, 45), trim, NEON)
	elseif a == "bone" then
		for k = 0, 3 do
			T("Rib", V(1.7 - math.abs(k - 1.5) * 0.12, 0.12, 0.1), at(0, 0.6 - k * 0.32, FZ - 0.07), BONE)
		end
		T("Sternum", V(0.16, 1.2, 0.12), at(0, 0.15, FZ - 0.1), shade(BONE, 0.9))
		T("BoneStrap", V(0.18, 2.4, 1.12 + pad * 2), at(0, 0, 0) * rot(0, 0, 38), LEATHER, LEA)
		arms(function(A, o)
			A("Skull", V(0.8, 0.8, 0.8), at(0.12 * o, 1.05, 0), BONE, nil, BALL)
			A("Horn", V(0.16, 0.5, 0.16), at(0.4 * o, 1.42, 0) * rot(0, 0, -40 * o), shade(BONE, 0.85))
		end)
	end
end

-- the weapon a rig carries: a real weapon (opts.weapon = { base, stars, shiny }, from a life's
-- equipped gear) or the look's own pick (a workshop weapon, ★)
local function weaponOn(model: Model, _parts: any, look: any, item: any?)
	if type(item) == "table" and item.base then
		WeaponModels.attach(model, item.base, item.stars, item.shiny)
		return
	end
	local kind = look.weapon or "none"
	if kind ~= "none" then
		WeaponModels.attach(model, kind, 1, false)
	end
end

-- ── on the face and round the neck ──
local function extraOn(ctx: any)
	local e = ctx.look.extra or "none"
	local parts = ctx.parts
	local head: BasePart = parts.Head
	local H = HEAD / 2
	local dark = Color3.fromRGB(22, 22, 26)
	local trim = ctx.trim
	local K = on(ctx, head)
	local T = on(ctx, parts.Torso)
	local FZ = -(0.5 + ctx.pad)
	if e == "glasses" or e == "shades" then
		for _, s in { -1, 1 } do
			K("Lens", V(0.34, 0.24, 0.04), at(s * 0.24, 0.0, -H - 0.06), if e == "shades" then dark else Color3.fromRGB(200, 220, 240), GLASS).Transparency = if e == "shades" then 0 else 0.6
		end
		K("Bridge", V(1.3, 0.05, 0.05), at(0, 0.14, -H - 0.06), dark, SMOOTH)
	elseif e == "round_glasses" then
		for _, s in { -1, 1 } do
			K("Lens", V(0.03, 0.3, 0.3), at(s * 0.24, 0.0, -H - 0.06) * rot(0, 90, 0), Color3.fromRGB(210, 225, 240), GLASS, CYL).Transparency = 0.6
			K("LensRim", V(0.02, 0.34, 0.34), at(s * 0.24, 0.0, -H - 0.05) * rot(0, 90, 0), GOLD, MET, CYL)
		end
		K("Bridge", V(1.3, 0.04, 0.04), at(0, 0.17, -H - 0.06), GOLD, MET)
	elseif e == "visor" then
		K("Visor", V(HEAD * 0.96, 0.26, 0.06), at(0, 0.02, -H - 0.08), trim:Lerp(Color3.new(0.1, 0.1, 0.12), 0.4), GLASS).Transparency = 0.45
		for _, s in { -1, 1 } do
			K("VisorMount", V(0.12, 0.2, 0.3), at(s * (H + 0.04), 0.02, -0.4), dark)
		end
	elseif e == "mask" then
		K("Mask", V(HEAD * 0.86, 0.5, 0.08), at(0, -0.3, -H - 0.04), Color3.fromRGB(30, 30, 34))
	elseif e == "headband" then
		K("Band", V(HEAD + 0.06, 0.16, HEAD + 0.06), at(0, 0.32, 0), trim)
		K("BandTail", V(0.14, 0.5, 0.04), at(0.12, 0.1, H + 0.06) * rot(0, 0, 14), trim)
	elseif e == "earpiece" then
		K("Earpiece", V(0.12, 0.26, 0.2), at(H + 0.04, 0, 0.05), dark, SMOOTH)
		K("EarLight", V(0.04, 0.06, 0.06), at(H + 0.11, 0.06, 0.05), trim, NEON)
	elseif e == "headset" then
		K("HeadsetBand", V(HEAD + 0.12, 0.08, 0.14), at(0, H + 0.02, 0), dark, SMOOTH)
		K("Earpiece", V(0.14, 0.4, 0.4), at(H + 0.06, 0, 0), dark, SMOOTH)
		K("MicBoom", V(0.04, 0.04, 0.6), at(H + 0.02, -0.3, -0.36) * rot(0, -12, 0), dark, SMOOTH)
	elseif e == "scarf" then
		T("Scarf", V(1.5, 0.36, 1.3), at(0, 1.05, 0), trim)
		role(T("Scarf", V(0.34, 0.9, 0.1), at(0.4, 0.5, FZ - 0.12), trim), "scarf_skinned")
	elseif e == "gaiter" then
		T("Gaiter", V(1.34, 0.36, 1.16), at(0, 1.1, 0), shade(trim, 0.6))
	elseif e == "cap" then
		K("Cap", V(HEAD + 0.12, 0.4, HEAD + 0.12), at(0, H - 0.02, 0), dark)
		K("Brim", V(HEAD * 0.9, 0.08, 0.6), at(0, H - 0.18, -H - 0.2), dark)
	elseif e == "beanie" then
		K("Beanie", V(HEAD + 0.12, 0.6, HEAD + 0.12), at(0, H - 0.1, 0), trim)
		K("BeanieFold", V(HEAD + 0.16, 0.18, HEAD + 0.16), at(0, H - 0.34, 0), shade(trim, 0.85))
	elseif e == "eyepatch" then
		K("Patch", V(0.34, 0.3, 0.05), at(0.24, 0.0, -H - 0.05), dark)
		K("PatchStrap", V(HEAD + 0.06, 0.05, HEAD + 0.06), at(0, 0.14, 0) * rot(0, 0, -14), dark)
	elseif e == "bandage" then
		K("Bandage", V(0.3, 0.2, 0.04), at(-0.3, -0.16, -H - 0.04), Color3.fromRGB(244, 236, 220))
	elseif e == "choker" then
		T("Choker", V(1.0, 0.14, 0.9), at(0, 1.04, 0), dark)
		T("ChokerGem", V(0.12, 0.12, 0.06), at(0, 1.0, -0.47), trim, NEON)
	elseif e == "earrings" then
		for _, s in { -1, 1 } do
			K("Earring", V(0.12, 0.12, 0.12), at(s * (H + 0.03), -0.22, 0.02), GOLD, MET, BALL)
		end
	elseif e == "crystal_earring" then
		K("EarCrystal", V(0.1, 0.3, 0.1), at(H + 0.04, -0.3, 0.02) * rot(0, 45, 0), trim, NEON)
		K("EarHook", V(0.06, 0.08, 0.06), at(H + 0.04, -0.12, 0.02), GOLD, MET)
	elseif e == "ear_cuffs" then
		for k = 0, 1 do
			K("EarCuff", V(0.06, 0.1, 0.14), at(H + 0.03, 0.04 - k * 0.18, 0.04), Color3.fromRGB(210, 212, 220), MET)
		end
	elseif e == "monocle" then
		K("Monocle", V(0.32, 0.32, 0.03), at(0.24, 0.0, -H - 0.06), Color3.fromRGB(210, 230, 250), GLASS).Transparency = 0.55
		K("MonocleRim", V(0.36, 0.05, 0.04), at(0.24, 0.17, -H - 0.06), GOLD, MET)
		K("MonocleChain", V(0.03, 0.5, 0.03), at(0.42, -0.26, -H - 0.04) * rot(0, 0, 15), GOLD, MET)
	elseif e == "half_mask" then
		K("HalfMask", V(HEAD * 0.92, 0.48, 0.1), at(0, -0.3, -H - 0.05), Color3.fromRGB(40, 40, 46), MET)
		K("MaskLine", V(HEAD * 0.7, 0.04, 0.11), at(0, -0.24, -H - 0.06), trim, NEON)
	elseif e == "demon_mask" then
		K("DemonMask", V(HEAD * 0.92, 0.5, 0.1), at(0, -0.3, -H - 0.05), Color3.fromRGB(120, 24, 30))
		for _, s in { -1, 1 } do
			K("Fang", V(0.08, 0.18, 0.04), at(s * 0.16, -0.46, -H - 0.11), BONE)
		end
		K("MaskLine", V(HEAD * 0.6, 0.04, 0.11), at(0, -0.2, -H - 0.06), trim, NEON)
	elseif e == "face_veil" then
		K("Veil", V(HEAD * 0.9, 0.5, 0.04), at(0, -0.32, -H - 0.06), trim:Lerp(WHITE, 0.4)).Transparency = 0.3
		K("VeilBand", V(HEAD + 0.06, 0.05, HEAD + 0.06), at(0, -0.08, 0), GOLD, MET)
	elseif e == "respirator" then
		K("Respirator", V(0.7, 0.42, 0.18), at(0, -0.32, -H - 0.07), Color3.fromRGB(40, 42, 46))
		for _, s in { -1, 1 } do
			K("Filter", V(0.2, 0.26, 0.26), at(s * 0.4, -0.38, -H - 0.1) * rot(0, s * 30, 0), Color3.fromRGB(70, 74, 80), nil, CYL)
		end
	elseif e == "medical" then
		K("Medical", V(HEAD * 0.8, 0.42, 0.06), at(0, -0.3, -H - 0.03), Color3.fromRGB(236, 240, 244))
		for _, s in { -1, 1 } do
			K("MaskLoop", V(0.04, 0.04, HEAD * 0.6), at(s * (H + 0.01), -0.12, -0.25), Color3.fromRGB(236, 240, 244))
		end
	elseif e == "nose_band" then
		K("NoseBand", V(0.36, 0.1, 0.04), at(0, -0.12, -H - 0.05), Color3.fromRGB(244, 236, 220))
	elseif e == "necklace" then
		T("Chain", V(1.3, 0.05, 1.06), at(0, 0.98, 0) * rot(-10, 0, 0), GOLD, MET)
		T("Pendant", V(0.2, 0.2, 0.06), at(0, 0.55, FZ - 0.09) * rot(0, 0, 45), trim, NEON)
		T("PendantRim", V(0.26, 0.26, 0.05), at(0, 0.55, FZ - 0.07) * rot(0, 0, 45), GOLD, MET)
	elseif e == "bead_necklace" then
		T("Chain", V(1.3, 0.05, 1.06), at(0, 0.98, 0) * rot(-10, 0, 0), Color3.fromRGB(80, 50, 30))
		for k = -2, 2 do
			T("Bead", V(0.16, 0.16, 0.16), at(k * 0.16, 0.66 + math.abs(k) * 0.12, FZ - 0.08), Color3.fromRGB(110, 70, 40), WOOD, BALL)
		end
	elseif e == "dog_tags" then
		T("Chain", V(1.3, 0.04, 1.06), at(0, 0.98, 0) * rot(-10, 0, 0), STEEL, MET)
		T("Tag", V(0.18, 0.26, 0.03), at(-0.04, 0.48, FZ - 0.06) * rot(0, 0, 8), STEEL, MET)
		T("Tag", V(0.18, 0.26, 0.03), at(0.08, 0.44, FZ - 0.08) * rot(0, 0, -6), shade(STEEL, 1.1), MET)
	elseif e == "lanyard" then
		for _, o in { -1, 1 } do
			T("Lanyard", V(0.08, 0.9, 0.03), at(o * 0.2, 0.62, FZ - 0.05) * rot(0, 0, o * 14), trim)
		end
		T("IdCard", V(0.34, 0.44, 0.03), at(0, 0.0, FZ - 0.07), WHITE)
		T("IdStripe", V(0.34, 0.1, 0.035), at(0, 0.14, FZ - 0.075), trim)
	end
end

-- ── headwear ───────────────────────────────────────────────────────────────
local function headwearOn(ctx: any)
	local look = ctx.look
	local hw = look.headwear or "none"
	if hw == "none" then
		return
	end
	local head: BasePart = ctx.parts.Head
	local H = HEAD / 2
	local trim = ctx.trim
	local armor = ctx.armorCol
	local cloth = ctx.col
	local dark = Color3.fromRGB(26, 26, 30)
	local K = on(ctx, head)
	local function hat(name, size, cf, color, material, shape)
		return K(name, size, cf, color, material or FAB, shape)
	end
	local up = rot(0, 0, 90) -- (a cylinder stood on its end)
	-- a cap of top, back and sides around the head that leaves the face open
	local function dome(name: string, color: Color3, material: Enum.Material, grow: number)
		local g = grow
		K(name .. "Top", V(HEAD + g, 0.2, HEAD + g), at(0, H + 0.04, 0.02), color, material)
		K(name .. "Back", V(HEAD + g, HEAD + 0.1, 0.16), at(0, 0.02, H + 0.04), color, material)
		for _, x in { -1, 1 } do
			K(name .. "Side", V(0.14, HEAD + 0.1, HEAD + g * 0.5), at(x * (H + 0.04), 0.02, 0.04), color, material)
		end
	end
	-- an open-face shell: the back three quarters of the head and the top (the face stays out
	-- in front of it; the kit's open helms and hoods fit this box)
	local function openShell(name: string, color: Color3, material: Enum.Material, grow: number, depth: number?): BasePart
		local d = depth or 0.8
		return K(name, V(HEAD + grow, HEAD + grow * 0.8, HEAD * d), at(0, grow * 0.3, H - HEAD * d / 2 + 0.1), color, material)
	end
	if hw == "hood" or hw == "cowl" then
		local deep = hw == "cowl"
		local hc = shade(cloth, if deep then 0.7 else 0.9)
		role(openShell("Hood", hc, FAB, if deep then 0.4 else 0.3, if deep then 0.9 else 0.8), "hood_cowl")
		local z = if deep then -H + 0.1 else -H + 0.2
		K("HoodLip", V(HEAD + 0.42, 0.2, 0.26), at(0, H + 0.08, z), shade(hc, 0.85), FAB)
		for _, x in { -1, 1 } do
			K("HoodLip", V(0.2, HEAD + 0.1, 0.26), at(x * (H + 0.12), -0.02, z), shade(hc, 0.85), FAB)
		end
		if deep then
			K("CowlShade", V(HEAD + 0.2, 0.14, 0.06), at(0, H - 0.02, -H - 0.02), shade(hc, 0.4), FAB)
			on(ctx, ctx.parts.Torso)("CowlDrape", V(2.0 + ctx.pad * 2, 0.5, 1.4 + ctx.pad * 2), at(0, 0.86, 0.04), hc, FAB)
		end
	elseif hw == "raid_helmet" then
		dome("Helmet", armor, MET, 0.18)
		K("Visor", V(HEAD * 0.94, 0.34, 0.06), at(0, 0.36, -H - 0.08), trim:Lerp(Color3.new(0.1, 0.1, 0.12), 0.5), GLASS).Transparency = 0.35
		K("VisorStrip", V(HEAD * 0.94, 0.04, 0.07), at(0, 0.52, -H - 0.08), trim, NEON)
		K("HelmetBrim", V(HEAD + 0.26, 0.1, 0.3), at(0, H - 0.02, -H + 0.04), shade(armor, 0.85), MET)
	elseif hw == "knight_helm" then
		K("Helm", V(HEAD + 0.16, HEAD + 0.16, HEAD + 0.16), at(0, 0.02, 0), armor, MET)
		K("Slit", V(HEAD * 0.72, 0.08, 0.04), at(0, 0.1, -H - 0.1), dark)
		K("VisorRidge", V(0.12, HEAD * 0.8, 0.06), at(0, -0.05, -H - 0.1), shade(armor, 1.2), MET)
		for k = -2, 2 do
			K("Breath", V(0.05, 0.16, 0.04), at(k * 0.12, -0.3, -H - 0.1), dark)
		end
		K("Crest", V(0.12, 0.26, HEAD + 0.1), at(0, H + 0.2, 0), trim, NEON)
	elseif hw == "horned_helm" or hw == "winged_helm" or hw == "half_helm" or hw == "spiked_helm" or hw == "kabuto" then
		local shellPart = openShell(if hw == "half_helm" or hw == "kabuto" or hw == "spiked_helm" then "HelmShell" else "Helm", armor, MET, 0.22)
		local by = shellPart.Name
		K("BrowBand", V(HEAD + 0.26, 0.18, 0.22), at(0, 0.46, -H + 0.1), shade(armor, 1.15), MET)
		if hw == "horned_helm" then
			role(shellPart, "helm_horned")
			K("NoseGuard", V(0.12, 0.5, 0.06), at(0, 0.24, -H - 0.04), armor, MET)
			for _, x in { -1, 1 } do
				covered(K("Horn", V(0.22, 0.6, 0.22), at(x * (H + 0.18), H, 0) * rot(0, 0, -40 * x), Color3.fromRGB(232, 222, 200)), by)
				covered(K("HornTip", V(0.14, 0.45, 0.14), at(x * (H + 0.42), H + 0.38, 0) * rot(0, 0, -12 * x), Color3.fromRGB(240, 234, 216)), by)
			end
		elseif hw == "winged_helm" then
			role(shellPart, "helm_winged")
			for _, x in { -1, 1 } do
				for k = 0, 1 do
					covered(K("Wing", V(0.08, 0.7 - k * 0.14, 0.3), at(x * (H + 0.16), 0.34 + k * 0.12, 0.14 + k * 0.26) * rot(-34 - k * 22, 0, -x * (24 + k * 8)), if k == 0 then WHITE else shade(WHITE, 0.88), MET), by)
				end
			end
		elseif hw == "half_helm" then
			for _, x in { -1, 1 } do
				K("CheekGuard", V(0.14, 0.62, 0.5), at(x * (H + 0.08), -0.18, -0.22), armor, MET)
			end
			K("HelmRim", V(HEAD + 0.3, 0.08, HEAD + 0.1), at(0, 0.36, 0.1), shade(armor, 0.8), MET)
		elseif hw == "spiked_helm" then
			for k = -2, 2 do
				K("Spike", V(0.12, 0.42, 0.12), at(0, H + 0.36, k * 0.24 + 0.1) * rot(k * 8, 0, 0), STEEL, MET)
			end
			K("NoseGuard", V(0.12, 0.44, 0.06), at(0, 0.26, -H - 0.04), armor, MET)
		elseif hw == "kabuto" then
			-- the neck guard flaring out, the turnbacks and a crescent crest
			K("Shikoro", V(HEAD + 0.6, 0.5, 0.1), at(0, -0.12, H + 0.22) * rot(-30, 0, 0), shade(armor, 0.9), MET)
			for _, x in { -1, 1 } do
				K("Shikoro", V(0.1, 0.5, HEAD * 0.9), at(x * (H + 0.24), -0.12, 0.12) * rot(0, 0, x * 24), shade(armor, 0.85), MET)
				K("Fukigaeshi", V(0.12, 0.3, 0.3), at(x * (H + 0.18), 0.32, -0.42), trim, MET)
				K("Crest", V(0.06, 0.62, 0.06), at(x * 0.2, H + 0.24, -H + 0.04) * rot(0, 0, x * -26), GOLD, MET)
			end
			K("HelmRim", V(HEAD + 0.36, 0.08, HEAD + 0.2), at(0, 0.38, 0.06), trim, MET)
		end
	elseif hw == "assassin_wrap" then
		dome("Wrap", shade(cloth, 0.7), FAB, 0.14)
		K("WrapFace", V(HEAD * 0.92, 0.52, 0.08), at(0, -0.3, -H - 0.04), shade(cloth, 0.7), FAB)
		role(K("WrapTail", V(0.3, 1.2, 0.06), at(0.2, -0.6, H + 0.12) * rot(10, 0, 8), shade(cloth, 0.7), FAB), "scarf_skinned")
	elseif hw == "hardhat" then
		K("HardHat", V(HEAD + 0.2, 0.46, HEAD + 0.2), at(0, H + 0.06, 0), Color3.fromRGB(240, 180, 40))
		K("HardBrim", V(HEAD + 0.46, 0.08, HEAD + 0.46), at(0, H - 0.15, 0), Color3.fromRGB(230, 170, 30))
		K("Lamp", V(0.24, 0.18, 0.1), at(0, H + 0.04, -H - 0.12), Color3.fromRGB(255, 250, 220), NEON)
	elseif hw == "mage_hat" then
		local m = shade(cloth, 0.85)
		hat("HatBrim", V(0.08, 2.5, 2.5), at(0, H - 0.05, 0) * up, m, FAB, CYL)
		hat("HatBand", V(0.18, 1.32, 1.32), at(0, H + 0.06, 0) * up, trim, NEON, CYL)
		hat("HatCone1", V(0.5, 1.26, 1.26), at(0, H + 0.3, 0) * up, m, FAB, CYL)
		hat("HatCone2", V(0.5, 0.86, 0.86), at(0, H + 0.75, 0.1) * rot(-10, 0, 0) * up, m, FAB, CYL)
		hat("HatCone3", V(0.5, 0.48, 0.48), at(0, H + 1.15, 0.28) * rot(-25, 0, 0) * up, m, FAB, CYL)
	elseif hw == "sedge_hat" then
		local straw = Color3.fromRGB(200, 170, 110)
		hat("HatBrim", V(0.08, 2.7, 2.7), at(0, H + 0.02, 0) * up, straw, FAB, CYL)
		hat("HatCone1", V(0.24, 1.9, 1.9), at(0, H + 0.14, 0) * up, shade(straw, 0.95), FAB, CYL)
		hat("HatCone2", V(0.24, 1.2, 1.2), at(0, H + 0.34, 0) * up, shade(straw, 0.9), FAB, CYL)
		hat("HatCone3", V(0.2, 0.5, 0.5), at(0, H + 0.52, 0) * up, shade(straw, 0.85), FAB, CYL)
		for _, x in { -1, 1 } do
			K("HatString", V(0.03, 0.9, 0.03), at(x * (H + 0.02), -0.2, -0.1), dark)
		end
	elseif hw == "gat" then
		local black = Color3.fromRGB(20, 20, 24)
		hat("GatBrim", V(0.04, 2.5, 2.5), at(0, H + 0.04, 0) * up, black, FAB, CYL).Transparency = 0.25
		hat("GatCrown", V(0.62, 0.86, 0.86), at(0, H + 0.36, 0) * up, black, FAB, CYL).Transparency = 0.15
		hat("GatBand", V(0.1, 0.88, 0.88), at(0, H + 0.1, 0) * up, shade(black, 1.6), FAB, CYL)
		for _, x in { -1, 1 } do
			K("GatString", V(0.05, 1.0, 0.05), at(x * (H + 0.02), -0.2, -0.05), Color3.fromRGB(140, 90, 60))
		end
	elseif hw == "bucket_hat" then
		hat("BucketCrown", V(HEAD + 0.14, 0.44, HEAD + 0.14), at(0, H + 0.04, 0), trim)
		hat("BucketBrim", V(0.08, HEAD + 0.9, HEAD + 0.9), at(0, H - 0.2, 0) * up, shade(trim, 0.85), FAB, CYL)
	elseif hw == "beret" then
		hat("Beret", V(0.26, HEAD + 0.42, HEAD + 0.42), at(-0.1, H + 0.02, 0.05) * rot(0, 0, -8) * up, trim, FAB, CYL)
		hat("BeretNub", V(0.12, 0.12, 0.12), at(-0.06, H + 0.18, 0.05), shade(trim, 0.8), FAB, BALL)
	elseif hw == "fur_hat" then
		hat("FurCrown", V(HEAD + 0.14, 0.42, HEAD + 0.14), at(0, H + 0.08, 0), trim)
		hat("FurBand", V(HEAD + 0.3, 0.3, HEAD + 0.3), at(0, H - 0.16, 0.02), FUR_LIGHT)
		for _, x in { -1, 1 } do
			hat("EarFlap", V(0.18, 0.62, 0.6), at(x * (H + 0.1), -0.08, 0.1), FUR_LIGHT)
		end
	elseif hw == "officer_cap" then
		hat("CapCrown", V(0.36, 1.58, 1.58), at(0, H + 0.12, 0.04) * up, cloth, FAB, CYL)
		hat("CapBand", V(0.16, 1.4, 1.4), at(0, H - 0.08, 0.02) * up, shade(cloth, 0.6), FAB, CYL)
		K("CapVisor", V(1.0, 0.06, 0.46), at(0, H - 0.16, -H - 0.08) * rot(14, 0, 0), dark, GLASS)
		K("CapBadge", V(0.2, 0.2, 0.05), at(0, H + 0.05, -0.74) * rot(0, 0, 45), GOLD, MET)
		K("CapCord", V(0.9, 0.05, 0.05), at(0, H - 0.08, -0.7), GOLD, MET)
	elseif hw == "feather_cap" then
		hat("CapCrown", V(HEAD + 0.12, 0.38, HEAD + 0.12), at(0, H + 0.04, 0), shade(cloth, 0.8))
		hat("CapBrim", V(HEAD + 0.1, 0.06, 0.4), at(0, H - 0.14, -H - 0.14) * rot(10, 0, 0), shade(cloth, 0.7))
		K("Feather", V(0.06, 1.0, 0.26), at(0.52, H + 0.36, 0.3) * rot(-30, 0, -20), trim)
		K("FeatherQuill", V(0.04, 0.6, 0.04), at(0.48, H + 0.2, 0.2) * rot(-30, 0, -20), WHITE)
	elseif hw == "circlet" then
		K("Circlet", V(HEAD + 0.06, 0.08, HEAD + 0.06), at(0, 0.36, 0), Color3.fromRGB(220, 186, 96), MET)
		K("CircletGem", V(0.14, 0.14, 0.05), at(0, 0.36, -H - 0.05) * rot(0, 0, 45), trim, NEON)
	elseif hw == "tiara" then
		K("Tiara", V(HEAD + 0.06, 0.08, HEAD + 0.06), at(0, 0.42, 0), Color3.fromRGB(214, 220, 232), MET)
		K("TiaraPeak", V(0.26, 0.26, 0.05), at(0, 0.56, -H - 0.04) * rot(0, 0, 45), Color3.fromRGB(214, 220, 232), MET)
		K("TiaraGem", V(0.12, 0.12, 0.06), at(0, 0.56, -H - 0.06) * rot(0, 0, 45), trim, NEON)
		for _, x in { -1, 1 } do
			K("TiaraPeak", V(0.14, 0.14, 0.05), at(x * 0.3, 0.5, -H - 0.04) * rot(0, 0, 45), Color3.fromRGB(214, 220, 232), MET)
		end
	elseif hw == "crown" then
		local crown = role(K("Crown", V(HEAD + 0.12, 0.32, HEAD + 0.12), at(0, H + 0.04, 0), GOLD, MET), "crown")
		local _ = crown
		for k = 0, 3 do
			local a = math.rad(k * 90)
			covered(K("CrownPoint", V(0.2, 0.36, 0.2), at(math.sin(a) * 0.6, H + 0.36, -math.cos(a) * 0.6) * rot(0, -k * 90, 45), GOLD, MET), "Crown")
		end
		K("CrownGem", V(0.16, 0.16, 0.06), at(0, H + 0.04, -H - 0.1) * rot(0, 0, 45), trim, NEON)
	elseif hw == "spectral_crown" then
		for k = 0, 6 do
			local a = math.rad(k * 360 / 7)
			K("Shard", V(0.12, 0.5, 0.12), at(math.sin(a) * 0.72, H + 0.46, -math.cos(a) * 0.72) * rot(0, k * 360 / 7, math.sin(a) * 10), trim, NEON).Transparency = 0.15
		end
	elseif hw == "halo" then
		for k = 0, 7 do
			local a = math.rad(k * 45)
			K("Halo", V(0.46, 0.07, 0.1), at(math.cos(a) * 0.58, H + 0.5, math.sin(a) * 0.58) * rot(0, -k * 45 + 90, 0), trim:Lerp(WHITE, 0.4), NEON)
		end
	elseif hw == "horns" then
		for _, x in { -1, 1 } do
			K("Horn", V(0.24, 0.6, 0.24), at(x * 0.42, H + 0.16, -0.05) * rot(-10, 0, -22 * x), Color3.fromRGB(40, 36, 40))
			K("HornTip", V(0.14, 0.42, 0.14), at(x * 0.56, H + 0.6, 0.05) * rot(-25, 0, -8 * x), shade(trim, 0.8))
		end
	elseif hw == "festival_mask" then
		K("FestivalMask", V(0.12, 0.78, 0.66), at(H + 0.1, 0.12, 0.12) * rot(0, 0, -6), WHITE)
		K("MaskPaint", V(0.13, 0.08, 0.4), at(H + 0.11, 0.24, 0.12), Color3.fromRGB(200, 40, 50))
		K("MaskPaint", V(0.13, 0.3, 0.06), at(H + 0.11, -0.06, 0.12), Color3.fromRGB(200, 40, 50))
		K("MaskStrap", V(HEAD + 0.08, 0.06, HEAD + 0.08), at(0, 0.34, 0) * rot(0, 0, -6), dark)
	elseif hw == "ribbon" then
		for _, x in { -1, 1 } do
			K("RibbonLoop", V(0.42, 0.3, 0.08), at(x * 0.24, H - 0.04, H + 0.1) * rot(0, 0, x * -16), trim)
			K("Sash", V(0.12, 0.6, 0.05), at(x * 0.12, H - 0.4, H + 0.12) * rot(0, 0, x * 10), trim)
		end
		K("RibbonKnot", V(0.16, 0.18, 0.1), at(0, H - 0.04, H + 0.12), shade(trim, 0.8))
	elseif hw == "healer_veil" then
		local veil = Color3.fromRGB(244, 244, 248)
		K("VeilTop", V(HEAD + 0.14, 0.12, HEAD + 0.14), at(0, H + 0.03, 0), veil, FAB)
		K("VeilBack", V(HEAD + 0.2, 1.5, 0.08), at(0, -0.22, H + 0.07), veil, FAB).Transparency = 0.12
		K("VeilBand", V(HEAD + 0.08, 0.1, HEAD + 0.08), at(0, 0.4, 0), trim)
	elseif hw == "bandana" then
		K("Bandana", V(HEAD + 0.06, 0.22, HEAD + 0.06), at(0, 0.34, 0), trim, FAB)
		for _, x in { -1, 1 } do
			K("BandanaTail", V(0.18, 0.42, 0.05), at(x * 0.12, 0.08, H + 0.08) * rot(0, 0, 18 * x), trim, FAB)
		end
	elseif hw == "goggles" then
		K("GoggleStrap", V(HEAD + 0.06, 0.1, HEAD + 0.06), at(0, 0.44, 0), dark)
		for _, x in { -1, 1 } do
			K("Goggle", V(0.36, 0.26, 0.12), at(x * 0.24, 0.46, -H - 0.07), trim, GLASS).Transparency = 0.2
		end
	elseif hw == "headphones" then
		K("PhoneBand", V(HEAD + 0.24, 0.12, 0.22), at(0, H + 0.07, 0), dark)
		for _, x in { -1, 1 } do
			K("EarCup", V(0.2, 0.48, 0.48), at(x * (H + 0.09), 0, 0), dark)
			K("EarRing", V(0.21, 0.3, 0.3), at(x * (H + 0.1), 0, 0), trim, NEON)
		end
	elseif hw == "hairpin" then
		K("Hairpin", V(0.12, 0.36, 0.12), at(0.46, 0.42, -0.2) * rot(0, 0, -30), trim, NEON)
		K("HairpinBead", V(0.14, 0.14, 0.14), at(0.56, 0.58, -0.2), GOLD, MET, BALL)
	end
end

-- ── on the back ────────────────────────────────────────────────────────────
local function backOn(ctx: any)
	local look = ctx.look
	local b = look.back or "none"
	local def = Looks.find("BACK", b)
	if b == "none" or not def or (ctx.civilian and def.combat) then
		return
	end
	local parts, pad = ctx.parts, ctx.pad
	local torso: BasePart = parts.Torso
	local T = on(ctx, torso)
	local col = ctx.backCol
	local trim = ctx.trim
	local Z = 0.5 + pad
	local FZ = -Z
	local fabric, leather, metal, wood = FAB, LEA, MET, WOOD
	local GRIP = Color3.fromRGB(30, 28, 30)
	local function straps(color: Color3)
		for _, x in { -0.5, 0.5 } do
			T("PackStrap", V(0.2, 1.9, 0.05), at(x, 0, FZ - 0.03), color, fabric)
		end
	end
	if b == "cape" then
		role(T("Cape", V(2.0 + pad * 2, 2.9, 0.1), at(0, -0.45, Z + 0.1) * rot(-6, 0, 0), col, fabric), "cape_skinned")
		T("CapeHem", V(2.0 + pad * 2, 0.1, 0.12), at(0, -1.86, Z + 0.25) * rot(-6, 0, 0), trim, fabric)
		for _, x in { -0.75, 0.75 } do
			T("CapeClasp", V(0.2, 0.2, 0.06), at(x, 0.9, FZ - 0.04), trim, NEON)
		end
	elseif b == "long_cape" then
		T("Mantle", V(2.4 + pad * 2, 0.3, 1.3 + pad * 2), at(0, 0.95, 0), col, fabric)
		role(T("Cape", V(2.3 + pad * 2, 4.6, 0.1), at(0, -1.25, Z + 0.14) * rot(-7, 0, 0), col, fabric), "cape_skinned")
		T("CapeHem", V(2.3 + pad * 2, 0.14, 0.12), at(0, -3.5, Z + 0.42) * rot(-7, 0, 0), trim, NEON)
		for _, x in { -0.8, 0.8 } do
			T("CapeClasp", V(0.24, 0.24, 0.06), at(x, 0.88, FZ - 0.06) * rot(0, 0, 45), GOLD, MET)
		end
	elseif b == "half_cape" then
		role(T("Cape", V(1.3, 2.5, 0.1), at(-0.45, -0.3, Z + 0.1) * rot(-6, 0, 4), col, fabric), "cape_skinned")
		on(ctx, parts["Left Arm"])("CapeShoulder", V(1.22, 0.5, 1.22), at(0, 0.8, 0), col, fabric)
		T("CapeHem", V(1.3, 0.1, 0.12), at(-0.53, -1.54, Z + 0.24) * rot(-6, 0, 4), trim, fabric)
		T("CapeCord", V(1.4, 0.06, 0.06), at(0, 0.7, FZ - 0.05) * rot(0, 0, 18), GOLD, MET)
	elseif b == "tattered" then
		role(T("Cape", V(2.0 + pad * 2, 2.4, 0.08), at(0, -0.25, Z + 0.1) * rot(-6, 0, 0), col, fabric), "cape_skinned")
		for k, len in { 0.9, 0.5, 1.1, 0.6, 0.8 } do
			T("Tatter", V(0.36, len, 0.07), at(-0.84 + (k - 1) * 0.42, -1.45 - len / 2, Z + 0.22) * rot(-6, 0, (k % 2) * 6 - 3), shade(col, 0.9), fabric)
		end
	elseif b == "hooded_cloak" then
		T("Mantle", V(2.4 + pad * 2, 0.5, 1.36 + pad * 2), at(0, 0.84, 0.02), col, fabric)
		role(T("Cape", V(2.3 + pad * 2, 3.9, 0.1), at(0, -0.95, Z + 0.14) * rot(-5, 0, 0), col, fabric), "cape_skinned")
		T("HoodDown", V(1.4, 0.78, 0.46), at(0, 0.74, Z + 0.3) * rot(-10, 0, 0), shade(col, 0.88), fabric)
		T("CloakClasp", V(0.22, 0.22, 0.06), at(0, 0.88, FZ - 0.16) * rot(0, 0, 45), GOLD, MET)
	elseif b == "fur_cape" then
		role(T("Cape", V(2.2 + pad * 2, 3.4, 0.1), at(0, -0.8, Z + 0.14) * rot(-5, 0, 0), col, fabric), "cape_skinned")
		T("FurMantle", V(2.5 + pad * 2, 0.5, 1.5 + pad * 2), at(0, 0.92, 0.04), FUR_LIGHT, fabric)
		for k, x in { -0.9, 0, 0.9 } do
			T("FurPuff" .. k, V(0.66, 0.66, 0.66), at(x, 1.05, Z + 0.1), FUR_LIGHT, fabric, BALL)
		end
	elseif b == "long_scarf" then
		T("Scarf", V(1.5, 0.38, 1.32), at(0, 1.06, 0), col, fabric)
		for k, x in { -0.25, 0.2 } do
			role(T("Scarf", V(0.36, 2.2 + k * 0.3, 0.08), at(x, -0.1 - k * 0.15, Z + 0.16) * rot(-8, 0, (k - 1.5) * 8), shade(col, 1 - k * 0.06), fabric), "scarf_skinned")
		end
		T("ScarfStripe", V(1.52, 0.06, 1.34), at(0, 1.06, 0), trim, fabric)
	elseif b == "quiver" then
		local q = at(0.42, 0.15, Z + 0.28) * rot(0, 0, -25)
		T("Quiver", V(0.46, 1.8, 0.46), q, col, leather)
		for k = -1, 1 do
			T("Arrow", V(0.05, 0.55, 0.05), q * at(k * 0.1, 1.15, 0), Color3.fromRGB(150, 110, 70), wood)
			T("Fletch", V(0.12, 0.2, 0.02), q * at(k * 0.1, 1.4, 0), trim, NEON)
		end
		T("QuiverStrap", V(0.16, 2.5, 0.05), at(0, 0, FZ - 0.04) * rot(0, 0, -38), shade(col, 0.7), leather)
	elseif b == "bow" then
		local bw = at(0, 0.1, Z + 0.16) * rot(0, 0, 30)
		for _, s in { -1, 1 } do
			T("BowLimb", V(0.14, 1.6, 0.12), bw * at(0.12, s * 0.8, 0) * rot(0, 0, s * 10), Color3.fromRGB(110, 76, 46), wood)
		end
		T("BowGrip", V(0.2, 0.36, 0.16), bw * at(0.04, 0, 0), GRIP, leather)
		T("BowString", V(0.03, 3.1, 0.03), bw * at(-0.12, 0, 0), WHITE)
		T("QuiverStrap", V(0.12, 2.5, 0.05), at(0, 0, FZ - 0.04) * rot(0, 0, 38), LEATHER, leather)
	elseif b == "spear" then
		local sp = at(0, 0.4, Z + 0.14) * rot(0, 0, -30)
		T("Staff", V(0.12, 5.4, 0.12), sp, Color3.fromRGB(110, 76, 46), wood)
		T("SpearHead", V(0.26, 0.6, 0.06), sp * at(0, 2.95, 0), STEEL, metal)
		T("SpearTassel", V(0.14, 0.3, 0.14), sp * at(0, 2.55, 0), trim, fabric)
	elseif b == "pack" then
		T("Pack", V(1.5, 1.5, 0.6), at(0, 0, Z + 0.32), col, fabric)
		T("PackFlap", V(1.52, 0.5, 0.62), at(0, 0.56, Z + 0.33), shade(col, 0.82), fabric)
		T("PackLight", V(0.3, 0.08, 0.04), at(0, 0.3, Z + 0.64), trim, NEON)
		straps(shade(col, 0.7))
	elseif b == "school_bag" then
		T("Pack", V(1.3, 1.4, 0.5), at(0, -0.05, Z + 0.27), col, fabric)
		T("PackPocket", V(1.0, 0.6, 0.14), at(0, -0.35, Z + 0.56), shade(col, 0.85), fabric)
		T("PackZip", V(1.0, 0.05, 0.05), at(0, -0.06, Z + 0.63), trim, metal)
		straps(shade(col, 0.7))
	elseif b == "medic_pack" then
		T("Pack", V(1.5, 1.5, 0.6), at(0, 0, Z + 0.32), col, fabric)
		T("PackCrossV", V(0.22, 0.7, 0.04), at(0, 0.05, Z + 0.64), Color3.fromRGB(200, 40, 50))
		T("PackCrossH", V(0.7, 0.22, 0.04), at(0, 0.05, Z + 0.64), Color3.fromRGB(200, 40, 50))
		straps(shade(col, 0.7))
	elseif b == "guitar_case" then
		local g = at(0.1, 0.1, Z + 0.3) * rot(0, 0, -18)
		T("CaseBody", V(1.3, 1.6, 0.4), g * at(0, -0.6, 0), col, leather)
		T("CaseNeck", V(0.5, 1.6, 0.34), g * at(0, 0.95, 0), col, leather)
		T("CaseHandle", V(0.3, 0.1, 0.1), g * at(0.62, -0.4, 0), DARK)
		T("QuiverStrap", V(0.16, 2.5, 0.05), at(0, 0, FZ - 0.04) * rot(0, 0, -38), DARK, leather)
	elseif b == "sheath" then
		local sh = at(0, 0, Z + 0.12) * rot(0, 0, 35)
		T("Sheath", V(0.3, 3.0, 0.2), sh, col, leather)
		T("SheathTip", V(0.34, 0.24, 0.24), sh * at(0, -1.5, 0), GOLD, metal)
		T("Guard", V(0.7, 0.12, 0.26), sh * at(0, 1.56, 0), GOLD, metal)
		T("Hilt", V(0.18, 0.8, 0.18), sh * at(0, 2.02, 0), GRIP, leather)
		T("Pommel", V(0.2, 0.2, 0.2), sh * at(0, 2.46, 0), trim, NEON, BALL)
	elseif b == "twin_sheaths" then
		for _, s in { -1, 1 } do
			local sh = at(0, -0.1, Z + 0.12 + (s + 1) * 0.06) * rot(0, 0, 32 * s)
			T("Sheath", V(0.22, 2.2, 0.16), sh, col, leather)
			T("Guard", V(0.44, 0.1, 0.2), sh * at(0, 1.15, 0), GOLD, metal)
			T("Hilt", V(0.14, 0.6, 0.14), sh * at(0, 1.5, 0), GRIP, leather)
		end
		T("SheathBelt", V(0.16, 2.5, 1.16 + pad * 2), at(0, 0, 0) * rot(0, 0, -40), shade(col, 0.6), leather)
	elseif b == "greatsword" then
		local gs = at(0, 0.3, Z + 0.16) * rot(0, 0, 32)
		T("GreatBlade", V(0.6, 3.6, 0.1), gs * at(0, -0.4, 0), STEEL, metal)
		T("GreatFuller", V(0.12, 3.0, 0.11), gs * at(0, -0.2, 0), shade(STEEL, 0.75), metal)
		T("Guard", V(1.2, 0.18, 0.24), gs * at(0, 1.44, 0), shade(col, 0.9), metal)
		T("Hilt", V(0.2, 0.9, 0.2), gs * at(0, 1.98, 0), GRIP, leather)
		T("Pommel", V(0.26, 0.26, 0.26), gs * at(0, 2.48, 0), trim, NEON, BALL)
		T("QuiverStrap", V(0.16, 2.5, 0.05), at(0, 0, FZ - 0.04) * rot(0, 0, -38), LEATHER, leather)
	elseif b == "shield" then
		T("Shield", V(1.7, 2.1, 0.18), at(0, 0, Z + 0.18), col, metal)
		T("ShieldRim", V(1.8, 2.2, 0.12), at(0, 0, Z + 0.12), shade(col, 0.7), metal)
		T("ShieldBoss", V(0.5, 0.5, 0.12), at(0, 0.1, Z + 0.3) * rot(0, 0, 45), trim, NEON)
	elseif b == "round_shield" then
		T("Shield", V(0.18, 2.0, 2.0), at(0, 0, Z + 0.2) * rot(0, 90, 0), col, wood, CYL)
		T("ShieldRim", V(0.12, 2.12, 2.12), at(0, 0, Z + 0.16) * rot(0, 90, 0), STEEL, metal, CYL)
		T("ShieldBoss", V(0.2, 0.56, 0.56), at(0, 0, Z + 0.32) * rot(0, 90, 0), shade(STEEL, 1.15), metal, CYL)
		T("ShieldBand", V(1.9, 0.18, 0.04), at(0, 0, Z + 0.3), trim)
	elseif b == "tower_shield" then
		T("Shield", V(2.1, 3.3, 0.2), at(0, -0.35, Z + 0.2), col, metal)
		T("ShieldRim", V(2.22, 3.42, 0.12), at(0, -0.35, Z + 0.14), shade(col, 0.7), metal)
		T("ShieldBand", V(0.3, 3.2, 0.06), at(0, -0.35, Z + 0.32), trim, metal)
		T("ShieldBand", V(2.0, 0.3, 0.06), at(0, 0.25, Z + 0.32), trim, metal)
		T("ShieldBoss", V(0.5, 0.5, 0.1), at(0, 0.25, Z + 0.37) * rot(0, 0, 45), shade(trim, 1.2), NEON)
	elseif b == "staff" then
		local st = at(0, 0.3, Z + 0.12) * rot(0, 0, -28)
		T("Staff", V(0.16, 5, 0.16), st, Color3.fromRGB(110, 76, 46), wood)
		T("StaffOrb", V(0.5, 0.5, 0.5), st * at(0, 2.7, 0), trim, NEON, BALL)
		T("StaffClaw", V(0.3, 0.3, 0.3), st * at(0, 2.4, 0), GOLD, metal)
	elseif b == "scrolls" then
		local sc = at(0.2, 0.15, Z + 0.28) * rot(0, 0, -60)
		T("ScrollCase", V(1.7, 0.5, 0.5), sc, col, leather, CYL)
		for _, x in { -0.9, 0.9 } do
			T("ScrollCap", V(0.14, 0.56, 0.56), sc * at(x, 0, 0), trim, metal, CYL)
		end
		T("QuiverStrap", V(0.12, 2.5, 0.05), at(0, 0, FZ - 0.04) * rot(0, 0, 38), shade(col, 0.7), leather)
	elseif b == "grimoire" then
		T("Grimoire", V(0.9, 1.1, 0.34), at(-0.62, -1.1, Z + 0.08) * rot(0, 0, 8), col, leather)
		T("GrimoirePages", V(0.82, 1.0, 0.36), at(-0.58, -1.1, Z + 0.06) * rot(0, 0, 8), Color3.fromRGB(230, 220, 190))
		T("GrimoireSigil", V(0.3, 0.3, 0.05), at(-0.62, -1.08, Z + 0.26) * rot(0, 0, 53), trim, NEON)
		T("GrimoireChain", V(0.06, 0.6, 0.06), at(-0.66, -0.36, Z + 0.06), STEEL, metal)
		T("GrimoireBelt", V(2.12 + pad * 2, 0.14, 1.12 + pad * 2), at(0, -0.72, 0), shade(LEATHER, 0.7), leather)
	elseif b == "lantern" then
		local pole = at(0.3, 0.6, Z + 0.14) * rot(0, 0, -20)
		T("LanternPole", V(0.1, 3.0, 0.1), pole, Color3.fromRGB(110, 76, 46), wood)
		T("LanternHook", V(0.5, 0.08, 0.08), pole * at(-0.2, 1.48, 0), GOLD, metal)
		T("Lantern", V(0.44, 0.56, 0.44), pole * at(-0.44, 1.12, 0), GOLD, metal)
		T("LanternLight", V(0.32, 0.32, 0.32), pole * at(-0.44, 1.1, 0), trim:Lerp(WHITE, 0.5), NEON, BALL)
	elseif b == "crystal_crate" then
		T("Crate", V(1.6, 1.3, 0.9), at(0, -0.1, Z + 0.48), Color3.fromRGB(122, 90, 58), wood)
		for k, x in { -0.45, 0, 0.42 } do
			T("Crystal", V(0.28, 0.6, 0.28), at(x, 0.7, Z + 0.48) * rot(0, 30 * k, 12 * (k - 2)), Color3.fromRGB(120, 200, 255), NEON)
		end
		straps(Color3.fromRGB(70, 50, 34))
	elseif b == "banner" then
		T("BannerPole", V(0.1, 5.6, 0.1), at(0.6, 1.4, Z + 0.12), Color3.fromRGB(120, 90, 60), wood)
		T("Banner", V(1.4, 1.8, 0.05), at(-0.12, 3.2, Z + 0.12), col, fabric)
		T("BannerMark", V(0.5, 0.5, 0.06), at(-0.12, 3.25, Z + 0.12) * rot(0, 0, 45), trim, NEON)
		T("BannerTop", V(0.2, 0.2, 0.2), at(0.6, 4.25, Z + 0.12), GOLD, metal, BALL)
	elseif b == "mana_wings" or b == "shadow_wings" then
		local shadow = b == "shadow_wings"
		local wc = if shadow then shade(col, 0.6) else trim
		for _, x in { -1, 1 } do
			local upper = T("WingUpper", V(2.4, 1.5, 0.06), at(x * 1.45, 0.7, Z + 0.3) * rot(0, -18 * x, 24 * x), wc, if shadow then fabric else NEON)
			upper.Transparency = if shadow then 0.1 else 0.35
			local lower = T("WingLower", V(1.8, 0.9, 0.06), at(x * 1.15, -0.15, Z + 0.3) * rot(0, -18 * x, -14 * x), wc, if shadow then fabric else NEON)
			lower.Transparency = if shadow then 0.15 else 0.45
			if shadow then
				T("WingEdge", V(2.4, 0.08, 0.08), at(x * 1.5, 1.44, Z + 0.32) * rot(0, -18 * x, 24 * x), trim, NEON)
			end
		end
	elseif b == "rune_ring" then
		local n = 8
		for k = 0, n - 1 do
			local a = math.rad(k * 360 / n)
			T("RuneRing", V(1.2, 0.08, 0.06), at(math.cos(a) * 1.5, 0.3 + math.sin(a) * 1.5, Z + 0.7) * rot(0, 0, k * 360 / n + 90), trim, NEON)
		end
		T("RuneMark", V(0.9, 0.9, 0.04), at(0, 0.3, Z + 0.72) * rot(0, 0, 45), trim, NEON).Transparency = 0.6
	end
end

-- ── accessories (Hunter/Accessories.luau): one per body slot, a few parts each. Hands, wrists,
-- shoulders and hips on the right; earrings on the left ear ──
local Accessories = Looks.Accessories
local function accessoryOn(ctx: any, a: any)
	local parts, pad = ctx.parts, ctx.pad
	local c = c3(a.color)
	local glow = if a.glow then c3(a.glow) else nil
	local gem = glow or shade(c, 1.2)
	local gemMat = if glow then NEON else MET
	local T = on(ctx, parts.Torso)
	local R = on(ctx, parts["Right Arm"])
	local K = on(ctx, parts.Head)
	local H = HEAD / 2
	local FZ, BZ = -(0.5 + pad), 0.5 + pad
	local cz = ctx.chestZ or (FZ - 0.05)
	local k, s = a.kind, a.slot
	if s == "hand" then
		R("Ring", V(0.34, 0.08, 0.06), at(0.12, -0.9, -0.53), c, MET)
		R("RingGem", V(0.12, 0.12, 0.06), at(0.12, -0.9, -0.57) * rot(0, 0, 45), gem, gemMat)
	elseif s == "ear" then
		local x = -(H + 0.04)
		if k == "stud" then
			K("EarStud", V(0.12, 0.12, 0.12), at(x, -0.2, 0.04), c, MET, BALL)
		elseif k == "hoop" then
			K("EarHoop", V(0.03, 0.3, 0.3), at(x, -0.32, 0.04), c, MET, CYL)
			if glow then
				K("EarGem", V(0.08, 0.08, 0.08), at(x - 0.02, -0.46, 0.04), glow, NEON, BALL)
			end
		elseif k == "feather" then
			K("EarFeather", V(0.04, 0.44, 0.14), at(x, -0.4, 0.1) * rot(14, 0, 6), c)
		else
			K("EarHook", V(0.05, 0.1, 0.05), at(x, -0.18, 0.04), GOLD, MET)
			K("EarDrop", V(0.09, 0.26, 0.09), at(x, -0.36, 0.04) * rot(0, 45, 0), gem, gemMat)
		end
	elseif s == "neck" then
		if k == "chain" then
			T("NeckChain", V(1.34, 0.1, 1.1), at(0, 0.94, 0.04) * rot(-14, 0, 0), c, MET)
			T("Pendant", V(0.2, 0.2, 0.06), at(0, 0.56, cz - 0.04) * rot(0, 0, 45), c, MET)
			return
		end
		T("Cord", V(1.22, 0.05, 1.12 + pad), at(0, 0.82, 0.04) * rot(-22, 0, 0), if k == "talisman" or k == "fang" or k == "token" then Color3.fromRGB(60, 40, 30) else c, if k == "amulet" or k == "holy" or k == "key" or k == "coin" then MET else FAB)
		local y = 0.42
		if k == "amulet" then
			T("Pendant", V(0.3, 0.3, 0.05), at(0, y, cz - 0.04) * rot(0, 0, 45), c, MET)
			T("PendantGem", V(0.18, 0.18, 0.06), at(0, y, cz - 0.07) * rot(0, 0, 45), gem, gemMat)
		elseif k == "fang" then
			T("Fang", V(0.1, 0.34, 0.06), at(0, y - 0.02, cz - 0.04) * rot(0, 0, 10), c)
			if glow then
				T("FangGlow", V(0.04, 0.2, 0.07), at(0, y, cz - 0.06) * rot(0, 0, 10), glow, NEON)
			end
		elseif k == "talisman" then
			T("Talisman", V(0.24, 0.4, 0.03), at(0, y - 0.04, cz - 0.04), Color3.fromRGB(236, 226, 196))
			T("TalismanMark", V(0.06, 0.3, 0.035), at(0, y - 0.04, cz - 0.05), if glow then glow else c, if glow then NEON else nil)
		elseif k == "holy" or k == "coin" or k == "token" then
			T("Pendant", V(0.04, 0.34, 0.34), at(0, y, cz - 0.04) * rot(0, 90, 0), c, if k == "token" then WOOD else MET, CYL)
			if k == "holy" then
				T("PendantGem", V(0.05, 0.16, 0.16), at(0, y, cz - 0.07) * rot(0, 90, 0), gem, gemMat, CYL)
			end
		elseif k == "key" then
			T("KeyBow", V(0.04, 0.2, 0.2), at(0, y + 0.08, cz - 0.04) * rot(0, 90, 0), c, MET, CYL)
			T("KeyShaft", V(0.05, 0.36, 0.04), at(0, y - 0.16, cz - 0.04), c, MET)
			T("KeyGlow", V(0.05, 0.1, 0.1), at(0, y + 0.08, cz - 0.07) * rot(0, 90, 0), gem, gemMat, CYL)
		end
	elseif s == "chest" then
		local x, y = 0.52, 0.5
		if k == "badge" then
			T("Badge", V(0.26, 0.32, 0.05), at(x, y, cz - 0.03), c, MET)
			T("BadgeStar", V(0.1, 0.1, 0.06), at(x, y + 0.02, cz - 0.05) * rot(0, 0, 45), gem, gemMat)
		elseif k == "ribbon" then
			T("RibbonKnot", V(0.14, 0.14, 0.06), at(x, y + 0.06, cz - 0.04), c)
			for _, o in { -1, 1 } do
				T("RibbonTail", V(0.1, 0.34, 0.04), at(x + o * 0.08, y - 0.12, cz - 0.03) * rot(0, 0, o * -18), c)
			end
		elseif k == "leaf" then
			T("Leaf", V(0.18, 0.36, 0.04), at(x, y, cz - 0.04) * rot(0, 0, 35), c, if glow then NEON else nil)
			T("LeafStem", V(0.03, 0.16, 0.04), at(x + 0.1, y - 0.18, cz - 0.03) * rot(0, 0, 35), STEEL, MET)
		elseif k == "sun" then
			T("Sun", V(0.04, 0.34, 0.34), at(x, y, cz - 0.04) * rot(0, 90, 0), c, MET, CYL)
			T("SunRays", V(0.56, 0.06, 0.04), at(x, y, cz - 0.03), c, MET)
			T("SunRays", V(0.06, 0.56, 0.04), at(x, y, cz - 0.03), c, MET)
			T("SunCore", V(0.05, 0.18, 0.18), at(x, y, cz - 0.07) * rot(0, 90, 0), gem, gemMat, CYL)
		elseif k == "medal" then
			T("MedalRibbon", V(0.16, 0.3, 0.04), at(x, y + 0.1, cz - 0.03), Color3.fromRGB(190, 40, 50))
			T("Medal", V(0.04, 0.24, 0.24), at(x, y - 0.14, cz - 0.04) * rot(0, 90, 0), c, MET, CYL)
		else -- brooch
			T("Brooch", V(0.28, 0.28, 0.05), at(x, y, cz - 0.03) * rot(0, 0, 45), c, MET)
			T("BroochGem", V(0.16, 0.16, 0.06), at(x, y, cz - 0.06) * rot(0, 0, 45), gem, gemMat)
		end
	elseif s == "shoulder" then
		if k == "spaulder" then
			R("Pauldron", V(1.34, 0.48, 1.34), at(0.08, 0.9, 0) * rot(0, 0, -13), c, MET)
			R("PauldronTrim", V(1.36, 0.07, 1.36), at(0.08, 0.68, 0) * rot(0, 0, -13), gem, gemMat)
		elseif k == "mantle" then
			R("MantleShoulder", V(1.24, 0.5, 1.24), at(0.04, 0.82, 0) * rot(0, 0, -8), c)
			role(T("Cape", V(1.2, 2.3, 0.08), at(0.5, -0.15, BZ + 0.14) * rot(-5, 0, -3), c), "cape_skinned")
			T("CapeHem", V(1.2, 0.08, 0.1), at(0.56, -1.3, BZ + 0.24) * rot(-5, 0, -3), gem, gemMat)
		elseif k == "stole" then
			T("StoleBand", V(1.56, 0.22, 1.24 + pad), at(0, 1.0, 0.02), c)
			for _, o in { -1, 1 } do
				T("Sash", V(0.22, 1.3, 0.05), at(o * 0.42, 0.32, cz - 0.02), c)
			end
			if glow then
				T("StoleTrim", V(0.6, 0.06, 0.05), at(0, -0.3, cz - 0.03), glow, NEON)
			end
		elseif k == "fur" then
			T("FurStole", V(2.3 + pad * 2, 0.4, 1.34 + pad * 2), at(0, 0.96, 0.02), c)
			T("FurPuff", V(0.7, 0.7, 0.7), at(0.95, 1.0, 0.1), c, FAB, BALL)
		else -- veil
			local v = R("Veil", V(1.26, 0.7, 1.26), at(0.04, 0.72, 0), c)
			v.Transparency = 0.35
			local d = T("VeilDrape", V(1.0, 1.5, 0.05), at(0.55, 0.1, BZ + 0.08), c)
			d.Transparency = 0.4
			if glow then
				R("VeilTrim", V(1.28, 0.05, 1.28), at(0.04, 0.38, 0), glow, NEON)
			end
		end
	elseif s == "wrist" then
		if k == "bracer" then
			R("Bracer", V(1.15, 0.5, 1.15), at(0, -0.42, 0), c, if c.R > c.B * 1.4 and luma(c) < 0.45 then LEA else MET)
			R("BracerGem", V(0.06, 0.18, 0.18), at(0.6, -0.42, 0) * rot(45, 0, 0), gem, gemMat)
		elseif k == "beads" then
			R("BeadCord", V(1.08, 0.05, 1.08), at(0, -0.6, 0), Color3.fromRGB(60, 40, 30))
			for i = -1, 1 do
				R("Bead", V(0.14, 0.14, 0.14), at(0.24 * i, -0.6, -0.55), if i == 0 then gem else c, if i == 0 then gemMat else WOOD, BALL)
			end
		elseif k == "wrap" then
			for i = 0, 1 do
				R("WristWrap", V(1.08, 0.08, 1.08), at(0, -0.5 - i * 0.14, 0) * rot(0, 0, if i == 0 then 8 else -8), c)
			end
		else -- bracelet
			for i = 0, 1 do
				R("Bracelet", V(1.09, 0.07, 1.09), at(0, -0.5 - i * 0.13, 0), if i == 0 then c else gem, if i == 0 then MET else gemMat)
			end
		end
	elseif s == "waist" then
		local y = -0.86
		local hip = 1.06 + pad
		if k == "belt" then
			T("HipBelt", V(2.24 + pad * 2, 0.16, 1.24 + pad * 2), at(0, y, 0), c, if c.R > c.B * 1.4 and luma(c) < 0.45 then LEA else MET)
			T("HipBuckle", V(0.28, 0.22, 0.06), at(0, y, -(0.62 + pad) - 0.04), shade(c, 1.2), MET)
			if glow then
				T("BuckleGem", V(0.1, 0.1, 0.06), at(0, y, -(0.62 + pad) - 0.07) * rot(0, 0, 45), glow, NEON)
			end
		elseif k == "pouch" then
			role(T("BeltPouch", V(0.4, 0.4, 0.24), at(hip + 0.1, y - 0.12, 0) * rot(0, -90, 0), c, LEA), "belt_pouch")
		elseif k == "charm" or k == "tassel" then
			T("CharmCord", V(0.04, 0.4, 0.04), at(0.72, y - 0.18, FZ - 0.08), Color3.fromRGB(60, 40, 30))
			if k == "tassel" then
				T("Sash", V(0.14, 0.5, 0.14), at(0.72, y - 0.62, FZ - 0.08), c)
				T("TasselKnot", V(0.16, 0.16, 0.16), at(0.72, y - 0.38, FZ - 0.08), shade(c, 0.8), FAB, BALL)
			else
				T("Charm", V(0.05, 0.3, 0.3), at(0.72, y - 0.5, FZ - 0.08) * rot(0, 90, 0), c, MET, CYL)
				if glow then
					T("CharmGlow", V(0.06, 0.14, 0.14), at(0.72, y - 0.5, FZ - 0.11) * rot(0, 90, 0), glow, NEON, CYL)
				end
			end
		elseif k == "book" then
			T("HipBook", V(0.16, 0.52, 0.42), at(hip + 0.08, y - 0.3, 0.06), c, LEA)
			T("HipBookChain", V(0.04, 0.3, 0.04), at(hip + 0.06, y + 0.04, 0.06), STEEL, MET)
			T("HipBookSigil", V(0.04, 0.18, 0.18), at(hip + 0.17, y - 0.3, 0.06) * rot(45, 0, 0), gem, gemMat)
		elseif k == "quiver" then
			local q = at(hip + 0.06, y - 0.34, 0.3) * rot(0, 0, -16)
			T("Quiver", V(0.3, 0.96, 0.3), q, c, LEA)
			for i = 0, 1 do
				T("Fletch", V(0.04, 0.2, 0.1), q * at(-0.05 + i * 0.1, 0.56, 0), gem, if glow then NEON else FAB)
			end
		elseif k == "knives" then
			T("KnifeBelt", V(2.22 + pad * 2, 0.12, 1.22 + pad * 2), at(0, y, 0), shade(LEATHER, 0.7), LEA)
			for i = 0, 2 do
				T("Knife", V(0.06, 0.36, 0.06), at(-0.32 - i * 0.2, y - 0.04, -(0.61 + pad) - 0.03) * rot(0, 0, 10), c, MET)
			end
		elseif k == "vial" then
			for i = 0, 1 do
				local v = T("Vial", V(0.12, 0.28, 0.12), at(0.56 + i * 0.2, y - 0.2, FZ - 0.08), gem, gemMat)
				v.Transparency = 0.15
			end
		elseif k == "censer" then
			T("CenserChain", V(0.04, 0.46, 0.04), at(hip + 0.06, y - 0.26, -0.1), GOLD, MET)
			T("Censer", V(0.32, 0.32, 0.32), at(hip + 0.06, y - 0.6, -0.1), c, MET, BALL)
			if glow then
				T("CenserGlow", V(0.18, 0.08, 0.18), at(hip + 0.06, y - 0.46, -0.1), glow, NEON)
			end
		else -- sash
			T("HipSash", V(2.2 + pad * 2, 0.26, 1.2 + pad * 2), at(0, y + 0.02, 0), c)
			T("Sash", V(0.24, 0.95, 0.06), at(-0.7, y - 0.55, FZ - 0.08) * rot(4, 0, 4), shade(c, 0.9))
			if glow then
				T("SashGlow", V(0.26, 0.05, 0.07), at(-0.7, y - 0.98, FZ - 0.1), glow, NEON)
			end
		end
	elseif s == "head" then
		K("Circlet", V(HEAD + 0.08, 0.07, HEAD + 0.08), at(0, 0.46, 0), c, MET)
		K("CircletGem", V(0.13, 0.13, 0.05), at(0, 0.46, -H - 0.06) * rot(0, 0, 45), gem, gemMat)
	elseif s == "float" then
		-- (floating: welded where they hover)
		if k == "orbs" then
			for _, o in { -1, 1 } do
				T("Orb", V(0.36, 0.36, 0.36), at(o * 1.95, 1.2 + (o + 1) * 0.15, 0.3), gem, gemMat, BALL)
			end
		elseif k == "orb" then
			T("Orb", V(0.46, 0.46, 0.46), at(1.95, 1.6, 0.3), gem, gemMat, BALL)
			local halo = T("OrbHalo", V(0.04, 0.7, 0.7), at(1.95, 1.6, 0.3) * rot(0, 30, 0), c, if glow then NEON else MET, CYL)
			halo.Transparency = 0.6
		elseif k == "rune" then
			for i = 0, 1 do
				local r = T("RuneHalo", V(1.0, 1.0, 0.04), at(0, 2.05, 0.95) * rot(0, 0, i * 45), gem, gemMat)
				r.Transparency = 0.55
			end
			T("RuneCore", V(0.04, 0.4, 0.4), at(0, 2.05, 0.92) * rot(0, 90, 0), c, MET, CYL)
		elseif k == "blades" then
			for _, o in { -1, 1 } do
				T("FloatBlade", V(0.14, 1.0, 0.04), at(o * 1.35, 0.7, 0.95) * rot(0, 0, o * -22), c, MET)
				T("FloatBladeEdge", V(0.04, 0.9, 0.05), at(o * 1.42, 0.72, 0.95) * rot(0, 0, o * -22), gem, gemMat)
			end
		elseif k == "feather" then
			T("SpiritFeather", V(0.08, 0.8, 0.26), at(1.95, 1.7, 0.2) * rot(10, 0, -25), gem, gemMat)
			T("SpiritQuill", V(0.04, 0.4, 0.04), at(1.85, 1.3, 0.2) * rot(10, 0, -25), c)
		else -- crystal
			T("FloatCrystal", V(0.26, 0.62, 0.26), at(1.95, 1.65, 0.25) * rot(0, 45, 10), gem, gemMat)
			T("FloatShard", V(0.12, 0.3, 0.12), at(2.2, 1.25, 0.1) * rot(0, 20, -20), gem, gemMat)
		end
	end
end
local function accessoriesOn(ctx: any, extra: { string }?)
	local seen = {}
	-- what the life wears (its charm, passed in) comes first, then the look's own picks; one per slot
	local list: { string } = table.clone(extra or {})
	for _, id in ctx.look.accessories or {} do
		table.insert(list, id)
	end
	local worn = {}
	for _, id in list do
		local a = Accessories.find(id)
		if a and not seen[a.slot] then
			seen[a.slot] = true
			accessoryOn(ctx, a)
			table.insert(worn, a.id)
		end
	end
	if #worn > 0 then
		ctx.model:SetAttribute("Accessories", table.concat(worn, ","))
	end
end

-- ── the aura: mana coming off the body (particles and a light, both cheap) ──
local function auraOn(model: Model, parts: any, look: any, rank: number?)
	local a = look.aura or "none"
	if a == "none" then
		return
	end
	local rgb = if a == "rank" then Looks.RANK_COLORS[math.clamp(rank or 0, 0, 6)] else Looks.color("AURA", a)
	local color = c3(rgb or { 90, 170, 255 })
	local torso: BasePart = parts.Torso
	local att = Instance.new("Attachment")
	att.Name = "AuraAttachment"
	att.Position = Vector3.new(0, -0.6, 0)
	att.Parent = torso
	local p = Instance.new("ParticleEmitter")
	p.Name = "Aura"
	p.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	p.Color = ColorSequence.new(color, color:Lerp(Color3.new(1, 1, 1), 0.4))
	p.LightEmission = 1
	p.LightInfluence = 0
	p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
	p.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
	p.Lifetime = NumberRange.new(0.8, 1.6)
	p.Rate = 10 + 4 * (rank or 0)
	p.Speed = NumberRange.new(1.5, 3.5)
	p.SpreadAngle = Vector2.new(25, 25)
	p.Acceleration = Vector3.new(0, 2, 0)
	p.EmissionDirection = Enum.NormalId.Top
	p.Parent = att
	local light = Instance.new("PointLight")
	light.Name = "AuraLight"
	light.Color = color
	light.Range = 8
	light.Brightness = 0.7
	light.Parent = torso
	model:SetAttribute("Aura", a)
end

-- ── hair accessories ───────────────────────────────────────────────────────
-- put an accessory on by its attachment (works on any rig, server or client)
function R6Rig.wearHair(model: Model, accessory: Instance, dye: string?)
	local handle = accessory:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then
		accessory:Destroy()
		return false
	end
	local fit: Attachment? = nil
	for _, a in handle:GetChildren() do
		if a:IsA("Attachment") then
			local target = model:FindFirstChild(a.Name, true)
			if target and target:IsA("Attachment") and target.Parent ~= handle then
				fit = a
				local part = target.Parent :: BasePart
				handle.CFrame = target.WorldCFrame * a.CFrame:Inverse()
				handle.Anchored = false
				handle.CanCollide = false
				handle.Massless = true
				local weld = Instance.new("Weld")
				weld.Name = "AccessoryWeld"
				weld.Part0 = handle
				weld.Part1 = part
				weld.C0 = a.CFrame
				weld.C1 = target.CFrame
				weld.Parent = handle
				break
			end
		end
	end
	if not fit then
		accessory:Destroy()
		return false
	end
	local color = Looks.color("HAIR_DYES", dye)
	if color then
		local c = c3(color)
		for _, d in handle:GetDescendants() do
			if d:IsA("SurfaceAppearance") then
				d:Destroy()
			elseif d:IsA("SpecialMesh") then
				d.TextureId = ""
				d.VertexColor = Vector3.new(1, 1, 1)
			end
		end
		if handle:IsA("MeshPart") then
			handle.TextureID = ""
		end
		handle.Color = c
	end
	accessory.Parent = model
	return true
end

-- ── the rig ────────────────────────────────────────────────────────────────
function R6Rig.build(rawLook: any, opts: any?): Model
	opts = opts or {}
	local look = Looks.clean(rawLook)
	local skin = c3(Looks.color("SKIN", look.skin))
	local model = Instance.new("Model")
	model.Name = opts.name or "Hunter"

	local root = newPart({
		Name = "HumanoidRootPart",
		Size = Vector3.new(2, 2, 1),
		Transparency = 1,
		CFrame = CFrame.new(0, 3, 0),
		Massless = false,
		CanCollide = false,
	})
	local torsoPart = newPart({ Name = "Torso", Size = Vector3.new(2, 2, 1), Color = skin, CFrame = CFrame.new(0, 3, 0), Massless = false, CanCollide = true })
	local head = newPart({ Name = "Head", Size = Vector3.new(HEAD, HEAD, HEAD), Color = skin, CFrame = CFrame.new(0, 4 + HEAD / 2, 0), Massless = false, CanCollide = true })
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Head
	mesh.Scale = Vector3.new(1, 1, 1)
	mesh.Parent = head
	local la = newPart({ Name = "Left Arm", Size = Vector3.new(1, 2, 1), Color = skin, CFrame = CFrame.new(-1.5, 3, 0), Massless = false })
	local ra = newPart({ Name = "Right Arm", Size = Vector3.new(1, 2, 1), Color = skin, CFrame = CFrame.new(1.5, 3, 0), Massless = false })
	local ll = newPart({ Name = "Left Leg", Size = Vector3.new(1, 2, 1), Color = skin, CFrame = CFrame.new(-0.5, 1, 0), Massless = false })
	local rl = newPart({ Name = "Right Leg", Size = Vector3.new(1, 2, 1), Color = skin, CFrame = CFrame.new(0.5, 1, 0), Massless = false })
	for _, p in { root, torsoPart, head, la, ra, ll, rl } do
		p.Parent = model
	end
	model.PrimaryPart = root

	-- the classic R6 joints
	local R = CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, -1), Vector3.new(0, 1, 0), Vector3.new(1, 0, 0)) -- (0,0,1, 0,1,0, -1,0,0)
	local L = CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0)) -- (0,0,-1, 0,1,0, 1,0,0)
	local N = CFrame.fromMatrix(Vector3.zero, Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 1, 0)) -- (-1,0,0, 0,0,1, 0,1,0)
	motor("RootJoint", root, torsoPart, N, N, root)
	motor("Neck", torsoPart, head, CFrame.new(0, 1, 0) * N, CFrame.new(0, -HEAD / 2, 0) * N, torsoPart)
	motor("Right Shoulder", torsoPart, ra, CFrame.new(1, 0.5, 0) * R, CFrame.new(-0.5, 0.5, 0) * R, torsoPart)
	motor("Left Shoulder", torsoPart, la, CFrame.new(-1, 0.5, 0) * L, CFrame.new(0.5, 0.5, 0) * L, torsoPart)
	motor("Right Hip", torsoPart, rl, CFrame.new(1, -1, 0) * R, CFrame.new(0.5, 1, 0) * R, torsoPart)
	motor("Left Hip", torsoPart, ll, CFrame.new(-1, -1, 0) * L, CFrame.new(-0.5, 1, 0) * L, torsoPart)

	-- the standard attachments (accessories find their place by these names)
	attach(head, "HairAttachment", Vector3.new(0, HEAD / 2 - 0.05, 0))
	attach(head, "HatAttachment", Vector3.new(0, HEAD / 2 - 0.05, 0))
	attach(head, "FaceFrontAttachment", Vector3.new(0, 0, -HEAD / 2))
	attach(head, "FaceCenterAttachment", Vector3.new(0, 0, 0))
	attach(torsoPart, "NeckAttachment", Vector3.new(0, 1, 0))
	attach(torsoPart, "BodyFrontAttachment", Vector3.new(0, 0, -0.5))
	attach(torsoPart, "BodyBackAttachment", Vector3.new(0, 0, 0.5))
	attach(torsoPart, "LeftCollarAttachment", Vector3.new(-1, 1, 0))
	attach(torsoPart, "RightCollarAttachment", Vector3.new(1, 1, 0))
	attach(torsoPart, "WaistFrontAttachment", Vector3.new(0, -1, -0.5))
	attach(torsoPart, "WaistCenterAttachment", Vector3.new(0, -1, 0))
	attach(torsoPart, "WaistBackAttachment", Vector3.new(0, -1, 0.5))
	attach(la, "LeftShoulderAttachment", Vector3.new(0, 1, 0))
	attach(ra, "RightShoulderAttachment", Vector3.new(0, 1, 0))
	attach(la, "LeftGripAttachment", Vector3.new(0, -1, 0))
	attach(ra, "RightGripAttachment", Vector3.new(0, -1, 0))
	attach(ll, "LeftFootAttachment", Vector3.new(0, -1, 0))
	attach(rl, "RightFootAttachment", Vector3.new(0, -1, 0))
	attach(root, "RootAttachment", Vector3.new(0, 0, 0))

	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R6
	humanoid.DisplayDistanceType = if opts.npc then Enum.HumanoidDisplayDistanceType.None else Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
	humanoid.Parent = model
	local animator = Instance.new("Animator")
	animator.Parent = humanoid
	local colors = Instance.new("BodyColors")
	colors.HeadColor3 = skin
	colors.TorsoColor3 = skin
	colors.LeftArmColor3 = skin
	colors.RightArmColor3 = skin
	colors.LeftLegColor3 = skin
	colors.RightLegColor3 = skin
	colors.Parent = model

	local parts = { Torso = torsoPart, Head = head, ["Left Arm"] = la, ["Right Arm"] = ra, ["Left Leg"] = ll, ["Right Leg"] = rl }
	drawFace(head, look, model)
	-- (everything the clothes and gear share)
	local ctx = {
		model = model, parts = parts, look = look, skin = skin, civilian = opts.civilian == true,
		pad = (Looks.find("BUILD", look.build) or Looks.BUILD[2]).pad,
		col = colorOf(look, "topColor", { 52, 54, 60 }), trim = colorOf(look, "trim", { 70, 150, 255 }),
		bottomCol = colorOf(look, "bottomColor", { 24, 24, 28 }), armorCol = colorOf(look, "armorColor", { 88, 96, 108 }),
		backCol = colorOf(look, "backColor", { 52, 54, 60 }),
		top = Looks.find("TOPS", look.top) or Looks.TOPS[1], bottom = Looks.find("BOTTOMS", look.bottom) or Looks.BOTTOMS[1],
		sleeved = {}, gloved = {}, robe = 0,
	}
	dressTop(ctx)
	dressBottom(ctx)
	shoesOn(ctx)
	glovesOn(ctx)
	if not opts.civilian then
		armorOn(ctx)
		if opts.weapon ~= false then
			weaponOn(model, parts, look, opts.weapon)
		end
	end
	extraOn(ctx)
	local hwDef = Looks.find("HEADWEAR", look.headwear)
	if not (opts.civilian and hwDef and hwDef.combat) then
		headwearOn(ctx)
	end
	backOn(ctx)
	accessoriesOn(ctx, opts.accessories)
	if not opts.civilian then
		auraOn(model, parts, look, opts.rank)
	end
	-- the body colours follow what the clothes made of the limbs
	colors.TorsoColor3 = torsoPart.Color
	colors.LeftArmColor3 = la.Color
	colors.RightArmColor3 = ra.Color
	colors.LeftLegColor3 = ll.Color
	colors.RightLegColor3 = rl.Color

	-- hair: an accessory if we have one, block hair if not (or if it won't fit)
	local hairDef = Looks.find("HAIR", look.hair) or Looks.HAIR[1]
	local hw = Looks.find("HEADWEAR", look.headwear)
	local worn = false
	if hw and hw.hidesHair then
		worn = true -- (under the helmet or hood)
	elseif opts.hair and hairDef.id ~= 0 then
		worn = R6Rig.wearHair(model, opts.hair, look.hairDye)
	end
	if not worn then
		local dye = Looks.color("HAIR_DYES", look.hairDye) or { 30, 24, 20 }
		blockHair(model, head, hairDef.fallback or "crop", c3(dye))
	end
	model:SetAttribute("R6Look", true)
	-- the Blender mesh kit over the gear and the weapon, if the place has it (Hunter/MeshLibrary)
	MeshLibrary.dress(model)
	return model
end

-- move a built rig (before it's simulated): keeps every weld
function R6Rig.pose(model: Model, cf: CFrame)
	model:PivotTo(cf)
end

return R6Rig
