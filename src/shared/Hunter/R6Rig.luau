--[[
	R6 RIG: builds a real R6 character (Humanoid, the six classic parts, Motor6D joints,
	the standard attachments) from a look (Hunter/Looks.luau), entirely out of Parts: the
	clothes and the Hunter gear are shells welded to each limb, the face is drawn on a plate
	in front of the head, and the hair is a Roblox hair accessory (or block hair if it can't
	load). Runs on the server (players' characters, NPCs) and on the client (the creator's
	preview, in a ViewportFrame's WorldModel).

		local model = R6Rig.build(look, { name = "Ari", hair = accessoryOrNil, npc = true })
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
local function dressTop(model: Model, parts: any, look: any)
	local top = Looks.find("TOPS", look.top) or Looks.TOPS[1]
	local pad = (Looks.find("BUILD", look.build) or Looks.BUILD[2]).pad
	local col = colorOf(look, "topColor", { 52, 54, 60 })
	local trim = colorOf(look, "trim", { 70, 150, 255 })
	local skin = c3(Looks.color("SKIN", look.skin))
	local torso: BasePart = parts.Torso
	torso.Color = col
	-- sleeves: long ones are the arms' colour; short ones are shells on the shoulder
	for _, side in { "Left", "Right" } do
		local arm: BasePart = parts[side .. " Arm"]
		if top.sleeves == "long" then
			arm.Color = col
			shell(model, arm, "Cuff", Vector3.new(1.06, 0.18, 1.06), CFrame.new(0, -0.62, 0), if top.stripes then trim else shade(col, 0.8))
			if top.stripes then
				shell(model, arm, "Stripe", Vector3.new(0.06, 1.9, 1.02), CFrame.new(if side == "Left" then -0.52 else 0.52, 0, 0), trim)
			end
		else
			arm.Color = skin
			if top.sleeves == "short" then
				shell(model, arm, "Sleeve", Vector3.new(1.06, 0.7, 1.06), CFrame.new(0, 0.66, 0), col)
			end
		end
	end
	if top.open then
		-- a jacket worn open: the shirt shows down the front
		shell(model, torso, "Shirt", Vector3.new(0.7, 1.9, 0.04), CFrame.new(0, 0, -0.5 - pad), shade(trim, 1))
		shell(model, torso, "LapelL", Vector3.new(0.12, 1.9, 0.06), CFrame.new(-0.4, 0, -0.52 - pad), shade(col, 0.75))
		shell(model, torso, "LapelR", Vector3.new(0.12, 1.9, 0.06), CFrame.new(0.4, 0, -0.52 - pad), shade(col, 0.75))
		shell(model, torso, "Body", Vector3.new(2 + pad * 2, 2 + pad, 1 + pad * 2), CFrame.new(0, 0.02, 0), col)
	end
	if top.collar then
		shell(model, torso, "Collar", Vector3.new(1.5, 0.26, 1.16 + pad), CFrame.new(0, 1.02, 0.02), shade(col, 0.85))
	end
	if top.hood then
		shell(model, torso, "Hood", Vector3.new(1.4, 0.5, 0.5), CFrame.new(0, 0.95, 0.5 + pad), shade(col, 0.88))
	end
	if top.pocket then
		shell(model, torso, "Pocket", Vector3.new(1.2, 0.45, 0.05), CFrame.new(0, -0.62, -0.52 - pad), shade(col, 0.82))
	end
	if top.pockets then
		for _, x in { -0.5, 0.5 } do
			shell(model, torso, "ChestPocket", Vector3.new(0.5, 0.42, 0.06), CFrame.new(x, 0.38, -0.53 - pad), shade(col, 0.8))
		end
	end
	if top.zips then
		shell(model, torso, "Zip", Vector3.new(0.05, 1.8, 0.05), CFrame.new(0.32, 0, -0.55 - pad), Color3.fromRGB(190, 190, 196), Enum.Material.Metal)
	end
	if top.tie then
		shell(model, torso, "Tie", Vector3.new(0.18, 1.2, 0.05), CFrame.new(0, 0.3, -0.53 - pad), trim)
	end
	if top.belt then
		shell(model, torso, "Belt", Vector3.new(2.08 + pad * 2, 0.2, 1.08 + pad * 2), CFrame.new(0, -0.6, 0), shade(col, 0.6))
	end
	if top.tails then
		shell(model, torso, "Tails", Vector3.new(2.04 + pad * 2, 1.6, 0.12), CFrame.new(0, -1.7, 0.5 + pad), col)
		shell(model, torso, "TailL", Vector3.new(0.12, 1.6, 1.02 + pad * 2), CFrame.new(-1.0 - pad, -1.7, 0), col)
		shell(model, torso, "TailR", Vector3.new(0.12, 1.6, 1.02 + pad * 2), CFrame.new(1.0 + pad, -1.7, 0), col)
	end
	if top.id == "tank" then
		shell(model, torso, "Strap", Vector3.new(2.02, 0.12, 1.04), CFrame.new(0, 0.94, 0), shade(col, 0.8))
	end
	if top.highNeck then
		shell(model, torso, "HighNeck", Vector3.new(1.3, 0.42, 1.0 + pad), CFrame.new(0, 1.12, 0), shade(col, 0.92), Enum.Material.Fabric)
	end
	if top.emblem then
		shell(model, torso, "Emblem", Vector3.new(0.42, 0.42, 0.04), CFrame.new(-0.5, 0.45, -0.53 - pad) * CFrame.Angles(0, 0, math.rad(45)), trim, Enum.Material.Neon)
		shell(model, torso, "EmblemCore", Vector3.new(0.22, 0.22, 0.05), CFrame.new(-0.5, 0.45, -0.54 - pad) * CFrame.Angles(0, 0, math.rad(45)), shade(col, 0.6))
	end
	if top.badge then
		shell(model, torso, "Badge", Vector3.new(0.22, 0.28, 0.05), CFrame.new(-0.62, 0.42, -0.56 - pad), Color3.fromRGB(214, 180, 90), Enum.Material.Metal)
		shell(model, torso, "BadgeStar", Vector3.new(0.1, 0.1, 0.06), CFrame.new(-0.62, 0.44, -0.58 - pad) * CFrame.Angles(0, 0, math.rad(45)), Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
	end
	if top.wrap then
		shell(model, torso, "WrapL", Vector3.new(0.34, 2.2, 0.05), CFrame.new(-0.16, 0.1, -0.52 - pad) * CFrame.Angles(0, 0, math.rad(-26)), shade(col, 0.86), Enum.Material.Fabric)
		shell(model, torso, "WrapR", Vector3.new(0.34, 2.2, 0.05), CFrame.new(0.16, 0.1, -0.53 - pad) * CFrame.Angles(0, 0, math.rad(26)), shade(col, 0.92), Enum.Material.Fabric)
	end
	if top.waistcoat then
		-- the shirt is the trim colour; the waistcoat is buttoned over it
		torso.Color = trim
		for _, side in { "Left", "Right" } do
			(parts[side .. " Arm"] :: BasePart).Color = trim
		end
		for _, x in { -0.55, 0.55 } do
			shell(model, torso, "Waistcoat", Vector3.new(0.9, 1.7, 0.06), CFrame.new(x, -0.12, -0.52 - pad), col, Enum.Material.Fabric)
		end
		shell(model, torso, "WaistcoatBack", Vector3.new(2.04 + pad * 2, 1.7, 0.06), CFrame.new(0, -0.12, 0.52 + pad), col, Enum.Material.Fabric)
		for k = 0, 2 do
			shell(model, torso, "Button", Vector3.new(0.08, 0.08, 0.04), CFrame.new(0.14, -0.35 - k * 0.3, -0.56 - pad), Color3.fromRGB(200, 180, 120), Enum.Material.Metal)
		end
	end
	if top.apron then
		shell(model, torso, "Apron", Vector3.new(1.7, 2.3, 0.05), CFrame.new(0, -0.4, -0.54 - pad), trim, Enum.Material.Fabric)
		shell(model, torso, "ApronTie", Vector3.new(2.08 + pad * 2, 0.12, 1.08 + pad * 2), CFrame.new(0, -0.35, 0), shade(trim, 0.85), Enum.Material.Fabric)
	end
	if top.cross then
		shell(model, torso, "CrossV", Vector3.new(0.12, 0.42, 0.05), CFrame.new(0.55, 0.45, -0.56 - pad), trim, Enum.Material.Neon)
		shell(model, torso, "CrossH", Vector3.new(0.42, 0.12, 0.05), CFrame.new(0.55, 0.45, -0.56 - pad), trim, Enum.Material.Neon)
	end
end

local function dressBottom(model: Model, parts: any, look: any)
	local b = Looks.find("BOTTOMS", look.bottom) or Looks.BOTTOMS[1]
	local col = colorOf(look, "bottomColor", { 24, 24, 28 })
	local skin = c3(Looks.color("SKIN", look.skin))
	local shoe = Looks.find("SHOES", look.shoes) or Looks.SHOES[1]
	for _, side in { "Left", "Right" } do
		local leg: BasePart = parts[side .. " Leg"]
		if b.short or b.skirt then
			leg.Color = skin
			if b.short then
				shell(model, leg, "Short", Vector3.new(1.04, 0.9, 1.04), CFrame.new(0, 0.56, 0), col)
			end
		else
			leg.Color = col
		end
		if b.rips then
			shell(model, leg, "Rip", Vector3.new(0.44, 0.2, 0.04), CFrame.new(0.05, 0.05, -0.51), skin)
			shell(model, leg, "Rip2", Vector3.new(0.28, 0.12, 0.04), CFrame.new(-0.12, -0.42, -0.51), skin)
		end
		if b.wide then
			shell(model, leg, "Wide", Vector3.new(1.24, 1.7, 1.24), CFrame.new(0, -0.1, 0), col, Enum.Material.Fabric)
		end
		if b.pockets and not b.skirt then
			shell(model, leg, "CargoPocket", Vector3.new(0.06, 0.5, 0.5), CFrame.new(if side == "Left" then -0.52 else 0.52, 0.1, 0), shade(col, 0.82))
		end
		if b.cuffs then
			shell(model, leg, "Cuff", Vector3.new(1.04, 0.16, 1.04), CFrame.new(0, -0.62, 0), shade(col, 0.75))
		end
		if b.plates then
			shell(model, leg, "Greave", Vector3.new(0.86, 0.9, 0.12), CFrame.new(0, -0.25, -0.55), Color3.fromRGB(150, 154, 162), Enum.Material.Metal)
			shell(model, leg, "Knee", Vector3.new(0.7, 0.36, 0.16), CFrame.new(0, 0.3, -0.56), Color3.fromRGB(170, 174, 182), Enum.Material.Metal)
		end
		-- shoes
		local h = if shoe.tall then 0.7 elseif shoe.low then 0.16 else 0.36
		local sc = if shoe.id == "sneakers" then Color3.fromRGB(230, 230, 226)
			elseif shoe.id == "sandals" then Color3.fromRGB(120, 86, 56)
			elseif shoe.metal then Color3.fromRGB(150, 154, 162)
			elseif shoe.wood then Color3.fromRGB(150, 110, 70)
			elseif shoe.trimSole then Color3.fromRGB(40, 42, 50)
			else Color3.fromRGB(28, 26, 26)
		local mat = if shoe.id == "dress" then Enum.Material.Glass elseif shoe.metal then Enum.Material.Metal elseif shoe.wood then Enum.Material.Wood else Enum.Material.SmoothPlastic
		shell(model, leg, "Shoe", Vector3.new(1.04, h, 1.16), CFrame.new(0, -1 + h / 2 - 0.01, -0.06), sc, mat)
		if shoe.id == "sneakers" or shoe.trimSole then
			shell(model, leg, "Sole", Vector3.new(1.06, 0.1, 1.18), CFrame.new(0, -0.96, -0.06), if shoe.trimSole then colorOf(look, "trim", { 70, 150, 255 }) else Color3.fromRGB(250, 250, 250), if shoe.trimSole then Enum.Material.Neon else nil)
		end
		if shoe.metal then
			shell(model, leg, "ToeCap", Vector3.new(0.9, 0.24, 0.2), CFrame.new(0, -0.86, -0.62), shade(sc, 1.2), Enum.Material.Metal)
		end
		if shoe.wood then
			shell(model, leg, "Strap", Vector3.new(0.5, 0.08, 0.5), CFrame.new(0, -0.82, -0.2), Color3.fromRGB(160, 30, 36))
		end
	end
	if b.skirt then
		local torso: BasePart = parts.Torso
		shell(model, torso, "Skirt", Vector3.new(2.2, 1.0, 1.2), CFrame.new(0, -1.35, 0), col)
		if b.pockets then
			for _, x in { -1.12, 1.12 } do
				shell(model, torso, "SkirtPouch", Vector3.new(0.14, 0.45, 0.5), CFrame.new(x, -1.3, 0), shade(col, 0.8))
			end
			shell(model, torso, "SkirtBelt", Vector3.new(2.24, 0.16, 1.24), CFrame.new(0, -0.9, 0), shade(col, 0.6))
		end
	end
	if look.gloves then
		for _, side in { "Left", "Right" } do
			shell(model, parts[side .. " Arm"], "Glove", Vector3.new(1.05, 0.5, 1.05), CFrame.new(0, -0.76, 0), Color3.fromRGB(30, 28, 30))
		end
	end
end

local function armorOn(model: Model, parts: any, look: any)
	local a = look.armor or "none"
	if a == "none" then
		return
	end
	local col = colorOf(look, "armorColor", { 88, 96, 108 })
	local trim = colorOf(look, "trim", { 70, 150, 255 })
	local pad = (Looks.find("BUILD", look.build) or Looks.BUILD[2]).pad
	local torso: BasePart = parts.Torso
	local metal = Enum.Material.Metal
	if a == "vest" then
		shell(model, torso, "Vest", Vector3.new(2.06 + pad * 2, 1.7, 1.12 + pad * 2), CFrame.new(0, 0.1, 0), col, Enum.Material.Fabric)
		for i = -1, 1 do
			shell(model, torso, "Pouch" .. i, Vector3.new(0.4, 0.34, 0.12), CFrame.new(i * 0.55, -0.45, -0.62 - pad), shade(col, 0.8), Enum.Material.Fabric)
		end
		shell(model, torso, "Patch", Vector3.new(0.5, 0.26, 0.04), CFrame.new(-0.5, 0.5, -0.63 - pad), trim, Enum.Material.Neon)
	elseif a == "plate" or a == "heavy" then
		shell(model, torso, "Cuirass", Vector3.new(2.1 + pad * 2, 1.8, 1.16 + pad * 2), CFrame.new(0, 0.08, 0), col, metal)
		shell(model, torso, "Ridge", Vector3.new(0.16, 1.7, 0.08), CFrame.new(0, 0.08, -0.62 - pad), shade(col, 1.25), metal)
		for _, side in { "Left", "Right" } do
			local arm: BasePart = parts[side .. " Arm"]
			local o = if side == "Left" then -1 else 1
			shell(model, arm, "Pauldron", Vector3.new(1.3, 0.5, 1.3), CFrame.new(0.06 * o, 0.92, 0) * CFrame.Angles(0, 0, math.rad(-12 * o)), col, metal)
			if a == "heavy" then
				shell(model, arm, "Vambrace", Vector3.new(1.12, 0.9, 1.12), CFrame.new(0, -0.4, 0), shade(col, 0.9), metal)
				shell(model, parts[side .. " Leg"], "Tasset", Vector3.new(1.1, 0.7, 1.14), CFrame.new(0, 0.55, 0), col, metal)
			end
		end
		shell(model, torso, "Gem", Vector3.new(0.24, 0.24, 0.06), CFrame.new(0, 0.5, -0.66 - pad), trim, Enum.Material.Neon)
	elseif a == "pauldrons" then
		for _, side in { "Left", "Right" } do
			local o = if side == "Left" then -1 else 1
			shell(model, parts[side .. " Arm"], "Pauldron", Vector3.new(1.28, 0.46, 1.28), CFrame.new(0.06 * o, 0.92, 0) * CFrame.Angles(0, 0, math.rad(-14 * o)), col, metal)
			shell(model, parts[side .. " Arm"], "PauldronTrim", Vector3.new(1.3, 0.08, 1.3), CFrame.new(0.06 * o, 0.7, 0) * CFrame.Angles(0, 0, math.rad(-14 * o)), trim, Enum.Material.Neon)
		end
	elseif a == "harness" then
		shell(model, torso, "StrapA", Vector3.new(0.22, 2.4, 1.1 + pad * 2), CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(38)), col, Enum.Material.Leather)
		shell(model, torso, "StrapB", Vector3.new(0.22, 2.4, 1.1 + pad * 2), CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(-38)), col, Enum.Material.Leather)
		shell(model, torso, "Buckle", Vector3.new(0.3, 0.3, 0.08), CFrame.new(0, 0, -0.6 - pad), Color3.fromRGB(200, 170, 90), metal)
	elseif a == "cloak" then
		shell(model, torso, "Mantle", Vector3.new(2.3 + pad * 2, 0.4, 1.3 + pad * 2), CFrame.new(0, 0.9, 0), col, Enum.Material.Fabric)
		shell(model, torso, "Cape", Vector3.new(2.1 + pad * 2, 2.8, 0.1), CFrame.new(0, -0.4, 0.62 + pad), col, Enum.Material.Fabric)
		shell(model, torso, "Clasp", Vector3.new(0.26, 0.26, 0.08), CFrame.new(0.6, 0.85, -0.62 - pad), trim, Enum.Material.Neon)
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

local function extraOn(model: Model, parts: any, look: any)
	local e = look.extra or "none"
	local head: BasePart = parts.Head
	local H = HEAD / 2
	local dark = Color3.fromRGB(22, 22, 26)
	local trim = colorOf(look, "trim", { 70, 150, 255 })
	if e == "glasses" or e == "shades" then
		for _, s in { -1, 1 } do
			shell(model, head, "Lens", Vector3.new(0.34, 0.24, 0.04), CFrame.new(s * 0.24, 0.06, -H - 0.06), if e == "shades" then dark else Color3.fromRGB(200, 220, 240), Enum.Material.Glass).Transparency = if e == "shades" then 0 else 0.6
		end
		shell(model, head, "Bridge", Vector3.new(1.3, 0.05, 0.05), CFrame.new(0, 0.1, -H - 0.06), dark)
	elseif e == "mask" then
		shell(model, head, "Mask", Vector3.new(HEAD * 0.86, 0.5, 0.08), CFrame.new(0, -0.3, -H - 0.04), Color3.fromRGB(30, 30, 34), Enum.Material.Fabric)
	elseif e == "headband" then
		shell(model, head, "Band", Vector3.new(HEAD + 0.06, 0.16, HEAD + 0.06), CFrame.new(0, 0.3, 0), trim)
	elseif e == "earpiece" then
		shell(model, head, "Earpiece", Vector3.new(0.12, 0.26, 0.2), CFrame.new(H + 0.04, 0, 0.05), dark)
		shell(model, head, "EarLight", Vector3.new(0.04, 0.06, 0.06), CFrame.new(H + 0.11, 0.06, 0.05), trim, Enum.Material.Neon)
	elseif e == "scarf" then
		shell(model, parts.Torso, "Scarf", Vector3.new(1.5, 0.36, 1.3), CFrame.new(0, 1.05, 0), trim, Enum.Material.Fabric)
		shell(model, parts.Torso, "ScarfTail", Vector3.new(0.34, 0.9, 0.1), CFrame.new(0.4, 0.5, -0.62), trim, Enum.Material.Fabric)
	elseif e == "cap" then
		shell(model, head, "Cap", Vector3.new(HEAD + 0.12, 0.4, HEAD + 0.12), CFrame.new(0, H - 0.02, 0), dark)
		shell(model, head, "Brim", Vector3.new(HEAD * 0.9, 0.08, 0.6), CFrame.new(0, H - 0.18, -H - 0.2), dark)
	elseif e == "beanie" then
		shell(model, head, "Beanie", Vector3.new(HEAD + 0.12, 0.6, HEAD + 0.12), CFrame.new(0, H - 0.1, 0), trim, Enum.Material.Fabric)
	elseif e == "eyepatch" then
		shell(model, head, "Patch", Vector3.new(0.34, 0.3, 0.05), CFrame.new(0.24, 0.06, -H - 0.05), dark)
		shell(model, head, "PatchStrap", Vector3.new(HEAD + 0.06, 0.05, HEAD + 0.06), CFrame.new(0, 0.18, 0) * CFrame.Angles(0, 0, math.rad(-14)), dark)
	elseif e == "bandage" then
		shell(model, head, "Bandage", Vector3.new(0.3, 0.2, 0.04), CFrame.new(-0.3, -0.16, -H - 0.04), Color3.fromRGB(244, 236, 220))
	elseif e == "choker" then
		shell(model, parts.Torso, "Choker", Vector3.new(1.0, 0.14, 0.9), CFrame.new(0, 1.04, 0), dark)
		shell(model, parts.Torso, "ChokerGem", Vector3.new(0.12, 0.12, 0.06), CFrame.new(0, 1.0, -0.47), trim, Enum.Material.Neon)
	elseif e == "earrings" then
		for _, s in { -1, 1 } do
			shell(model, head, "Earring", Vector3.new(0.12, 0.12, 0.12), CFrame.new(s * (H + 0.03), -0.22, 0.02), Color3.fromRGB(230, 190, 90), Enum.Material.Metal, Enum.PartType.Ball)
		end
	elseif e == "monocle" then
		shell(model, head, "Monocle", Vector3.new(0.32, 0.32, 0.03), CFrame.new(0.24, 0.06, -H - 0.06), Color3.fromRGB(210, 230, 250), Enum.Material.Glass).Transparency = 0.55
		shell(model, head, "MonocleRim", Vector3.new(0.36, 0.05, 0.04), CFrame.new(0.24, 0.23, -H - 0.06), Color3.fromRGB(214, 180, 90), Enum.Material.Metal)
		shell(model, head, "MonocleChain", Vector3.new(0.03, 0.5, 0.03), CFrame.new(0.4, -0.18, -H - 0.04) * CFrame.Angles(0, 0, math.rad(15)), Color3.fromRGB(214, 180, 90), Enum.Material.Metal)
	elseif e == "half_mask" then
		shell(model, head, "HalfMask", Vector3.new(HEAD * 0.92, 0.48, 0.1), CFrame.new(0, -0.3, -H - 0.05), Color3.fromRGB(40, 40, 46), Enum.Material.Metal)
		shell(model, head, "MaskLine", Vector3.new(HEAD * 0.7, 0.04, 0.11), CFrame.new(0, -0.24, -H - 0.06), trim, Enum.Material.Neon)
	elseif e == "medical" then
		shell(model, head, "Medical", Vector3.new(HEAD * 0.8, 0.42, 0.06), CFrame.new(0, -0.3, -H - 0.03), Color3.fromRGB(236, 240, 244), Enum.Material.Fabric)
		for _, s in { -1, 1 } do
			shell(model, head, "MaskLoop", Vector3.new(0.04, 0.04, HEAD * 0.6), CFrame.new(s * (H + 0.01), -0.12, -0.25), Color3.fromRGB(236, 240, 244))
		end
	elseif e == "nose_band" then
		shell(model, head, "NoseBand", Vector3.new(0.36, 0.1, 0.04), CFrame.new(0, -0.04, -H - 0.05), Color3.fromRGB(244, 236, 220))
	end
end

-- ── headwear ───────────────────────────────────────────────────────────────
local function headwearOn(model: Model, parts: any, look: any)
	local hw = look.headwear or "none"
	if hw == "none" then
		return
	end
	local head: BasePart = parts.Head
	local H = HEAD / 2
	local trim = colorOf(look, "trim", { 70, 150, 255 })
	local armor = colorOf(look, "armorColor", { 88, 96, 108 })
	local cloth = colorOf(look, "topColor", { 52, 54, 60 })
	local dark = Color3.fromRGB(26, 26, 30)
	local metal, fabric = Enum.Material.Metal, Enum.Material.Fabric
	-- a cap of top, back and sides around the head that leaves the face open
	local function dome(name: string, color: Color3, material: Enum.Material, grow: number)
		local g = grow
		shell(model, head, name .. "Top", Vector3.new(HEAD + g, 0.2, HEAD + g), CFrame.new(0, H + 0.04, 0.02), color, material)
		shell(model, head, name .. "Back", Vector3.new(HEAD + g, HEAD + 0.1, 0.16), CFrame.new(0, 0.02, H + 0.04), color, material)
		for _, x in { -1, 1 } do
			shell(model, head, name .. "Side", Vector3.new(0.14, HEAD + 0.1, HEAD + g * 0.5), CFrame.new(x * (H + 0.04), 0.02, 0.04), color, material)
		end
	end
	if hw == "hood" then
		dome("Hood", shade(cloth, 0.9), fabric, 0.24)
		shell(model, head, "HoodLip", Vector3.new(HEAD + 0.24, 0.22, 0.2), CFrame.new(0, H - 0.06, -H - 0.04), shade(cloth, 0.8), fabric)
	elseif hw == "raid_helmet" then
		dome("Helmet", armor, metal, 0.18)
		shell(model, head, "Visor", Vector3.new(HEAD * 0.94, 0.34, 0.06), CFrame.new(0, 0.16, -H - 0.08), trim:Lerp(Color3.new(0.1, 0.1, 0.12), 0.5), Enum.Material.Glass).Transparency = 0.35
		shell(model, head, "VisorStrip", Vector3.new(HEAD * 0.94, 0.04, 0.07), CFrame.new(0, 0.34, -H - 0.08), trim, Enum.Material.Neon)
	elseif hw == "knight_helm" then
		shell(model, head, "Helm", Vector3.new(HEAD + 0.16, HEAD + 0.16, HEAD + 0.16), CFrame.new(0, 0.02, 0), armor, metal)
		shell(model, head, "Slit", Vector3.new(HEAD * 0.72, 0.08, 0.04), CFrame.new(0, 0.1, -H - 0.1), dark)
		for k = -2, 2 do
			shell(model, head, "Breath", Vector3.new(0.05, 0.16, 0.04), CFrame.new(k * 0.12, -0.3, -H - 0.1), dark)
		end
		shell(model, head, "Crest", Vector3.new(0.12, 0.26, HEAD + 0.1), CFrame.new(0, H + 0.2, 0), trim, Enum.Material.Neon)
	elseif hw == "horned_helm" then
		dome("Helm", armor, metal, 0.18)
		shell(model, head, "NoseGuard", Vector3.new(0.12, 0.5, 0.06), CFrame.new(0, 0.1, -H - 0.07), armor, metal)
		for _, x in { -1, 1 } do
			shell(model, head, "Horn", Vector3.new(0.22, 0.6, 0.22), CFrame.new(x * (H + 0.18), H, 0) * CFrame.Angles(0, 0, math.rad(-40 * x)), Color3.fromRGB(232, 222, 200))
			shell(model, head, "HornTip", Vector3.new(0.14, 0.45, 0.14), CFrame.new(x * (H + 0.42), H + 0.38, 0) * CFrame.Angles(0, 0, math.rad(-12 * x)), Color3.fromRGB(240, 234, 216))
		end
	elseif hw == "assassin_wrap" then
		dome("Wrap", shade(cloth, 0.7), fabric, 0.14)
		shell(model, head, "WrapFace", Vector3.new(HEAD * 0.92, 0.52, 0.08), CFrame.new(0, -0.3, -H - 0.04), shade(cloth, 0.7), fabric)
		shell(model, head, "WrapTail", Vector3.new(0.3, 1.2, 0.06), CFrame.new(0.2, -0.6, H + 0.12) * CFrame.Angles(math.rad(10), 0, math.rad(8)), shade(cloth, 0.7), fabric)
	elseif hw == "hardhat" then
		shell(model, head, "HardHat", Vector3.new(HEAD + 0.2, 0.46, HEAD + 0.2), CFrame.new(0, H + 0.06, 0), Color3.fromRGB(240, 180, 40))
		shell(model, head, "HardBrim", Vector3.new(HEAD + 0.46, 0.08, HEAD + 0.46), CFrame.new(0, H - 0.15, 0), Color3.fromRGB(230, 170, 30))
		shell(model, head, "Lamp", Vector3.new(0.24, 0.18, 0.1), CFrame.new(0, H + 0.04, -H - 0.12), Color3.fromRGB(255, 250, 220), Enum.Material.Neon)
	elseif hw == "mage_hat" then
		local hat = shade(cloth, 0.85)
		local up = CFrame.Angles(0, 0, math.rad(90))
		shell(model, head, "HatBrim", Vector3.new(0.08, 2.5, 2.5), CFrame.new(0, H - 0.05, 0) * up, hat, fabric, Enum.PartType.Cylinder)
		shell(model, head, "HatBand", Vector3.new(0.18, 1.32, 1.32), CFrame.new(0, H + 0.06, 0) * up, trim, Enum.Material.Neon, Enum.PartType.Cylinder)
		shell(model, head, "HatCone1", Vector3.new(0.5, 1.26, 1.26), CFrame.new(0, H + 0.3, 0) * up, hat, fabric, Enum.PartType.Cylinder)
		shell(model, head, "HatCone2", Vector3.new(0.5, 0.86, 0.86), CFrame.new(0, H + 0.75, 0.1) * CFrame.Angles(math.rad(-10), 0, 0) * up, hat, fabric, Enum.PartType.Cylinder)
		shell(model, head, "HatCone3", Vector3.new(0.5, 0.48, 0.48), CFrame.new(0, H + 1.15, 0.28) * CFrame.Angles(math.rad(-25), 0, 0) * up, hat, fabric, Enum.PartType.Cylinder)
	elseif hw == "circlet" then
		shell(model, head, "Circlet", Vector3.new(HEAD + 0.06, 0.08, HEAD + 0.06), CFrame.new(0, 0.34, 0), Color3.fromRGB(220, 186, 96), metal)
		shell(model, head, "CircletGem", Vector3.new(0.14, 0.14, 0.05), CFrame.new(0, 0.34, -H - 0.05) * CFrame.Angles(0, 0, math.rad(45)), trim, Enum.Material.Neon)
	elseif hw == "healer_veil" then
		local veil = Color3.fromRGB(244, 244, 248)
		shell(model, head, "VeilTop", Vector3.new(HEAD + 0.14, 0.12, HEAD + 0.14), CFrame.new(0, H + 0.03, 0), veil, fabric)
		shell(model, head, "VeilBack", Vector3.new(HEAD + 0.2, 1.5, 0.08), CFrame.new(0, -0.22, H + 0.07), veil, fabric).Transparency = 0.12
		shell(model, head, "VeilBand", Vector3.new(HEAD + 0.08, 0.1, HEAD + 0.08), CFrame.new(0, 0.38, 0), trim)
	elseif hw == "bandana" then
		shell(model, head, "Bandana", Vector3.new(HEAD + 0.06, 0.22, HEAD + 0.06), CFrame.new(0, 0.3, 0), trim, fabric)
		for _, x in { -1, 1 } do
			shell(model, head, "BandanaTail", Vector3.new(0.18, 0.42, 0.05), CFrame.new(x * 0.12, 0.08, H + 0.08) * CFrame.Angles(0, 0, math.rad(18 * x)), trim, fabric)
		end
	elseif hw == "goggles" then
		shell(model, head, "GoggleStrap", Vector3.new(HEAD + 0.06, 0.1, HEAD + 0.06), CFrame.new(0, 0.42, 0), dark)
		for _, x in { -1, 1 } do
			shell(model, head, "Goggle", Vector3.new(0.36, 0.26, 0.12), CFrame.new(x * 0.24, 0.44, -H - 0.07), trim, Enum.Material.Glass).Transparency = 0.2
		end
	elseif hw == "headphones" then
		shell(model, head, "PhoneBand", Vector3.new(HEAD + 0.24, 0.12, 0.22), CFrame.new(0, H + 0.07, 0), dark)
		for _, x in { -1, 1 } do
			shell(model, head, "EarCup", Vector3.new(0.2, 0.48, 0.48), CFrame.new(x * (H + 0.09), 0, 0), dark)
			shell(model, head, "EarRing", Vector3.new(0.21, 0.3, 0.3), CFrame.new(x * (H + 0.1), 0, 0), trim, Enum.Material.Neon)
		end
	elseif hw == "hairpin" then
		shell(model, head, "Hairpin", Vector3.new(0.12, 0.36, 0.12), CFrame.new(0.46, 0.42, -0.2) * CFrame.Angles(0, 0, math.rad(-30)), trim, Enum.Material.Neon)
	end
end

-- ── on the back ────────────────────────────────────────────────────────────
local function backOn(model: Model, parts: any, look: any, civilian: boolean?)
	local b = look.back or "none"
	if b == "none" or (civilian and (b == "sheath" or b == "shield" or b == "staff" or b == "quiver" or b == "mana_wings" or b == "banner")) then
		return
	end
	local torso: BasePart = parts.Torso
	local pad = (Looks.find("BUILD", look.build) or Looks.BUILD[2]).pad
	local col = colorOf(look, "backColor", { 52, 54, 60 })
	local trim = colorOf(look, "trim", { 70, 150, 255 })
	local Z = 0.5 + pad
	local fabric, leather, metal, wood = Enum.Material.Fabric, Enum.Material.Leather, Enum.Material.Metal, Enum.Material.Wood
	if b == "cape" then
		shell(model, torso, "Cape", Vector3.new(2.0 + pad * 2, 2.9, 0.1), CFrame.new(0, -0.45, Z + 0.1) * CFrame.Angles(math.rad(6), 0, 0), col, fabric)
		for _, x in { -0.75, 0.75 } do
			shell(model, torso, "CapeClasp", Vector3.new(0.2, 0.2, 0.06), CFrame.new(x, 0.9, -Z - 0.03), trim, Enum.Material.Neon)
		end
	elseif b == "long_cape" then
		shell(model, torso, "Mantle", Vector3.new(2.4 + pad * 2, 0.3, 1.3 + pad * 2), CFrame.new(0, 0.95, 0), col, fabric)
		shell(model, torso, "Cape", Vector3.new(2.3 + pad * 2, 4.6, 0.1), CFrame.new(0, -1.25, Z + 0.14) * CFrame.Angles(math.rad(7), 0, 0), col, fabric)
		shell(model, torso, "CapeHem", Vector3.new(2.3 + pad * 2, 0.14, 0.12), CFrame.new(0, -3.5, Z + 0.42) * CFrame.Angles(math.rad(7), 0, 0), trim, Enum.Material.Neon)
	elseif b == "tattered" then
		shell(model, torso, "Cape", Vector3.new(2.0 + pad * 2, 2.4, 0.08), CFrame.new(0, -0.25, Z + 0.1) * CFrame.Angles(math.rad(6), 0, 0), col, fabric)
		for k, len in { 0.9, 0.5, 1.1, 0.6, 0.8 } do
			shell(model, torso, "Tatter", Vector3.new(0.36, len, 0.07), CFrame.new(-0.84 + (k - 1) * 0.42, -1.45 - len / 2, Z + 0.22) * CFrame.Angles(math.rad(6), 0, math.rad((k % 2) * 6 - 3)), shade(col, 0.9), fabric)
		end
	elseif b == "quiver" then
		local q = CFrame.new(0.42, 0.15, Z + 0.28) * CFrame.Angles(0, 0, math.rad(-25))
		shell(model, torso, "Quiver", Vector3.new(0.46, 1.8, 0.46), q, col, leather)
		for k = -1, 2 do
			shell(model, torso, "Arrow", Vector3.new(0.05, 0.55, 0.05), q * CFrame.new(k * 0.08, 1.15, 0), Color3.fromRGB(150, 110, 70), wood)
			shell(model, torso, "Fletch", Vector3.new(0.1, 0.18, 0.02), q * CFrame.new(k * 0.08, 1.4, 0), trim, Enum.Material.Neon)
		end
		shell(model, torso, "QuiverStrap", Vector3.new(0.16, 2.5, 0.05), CFrame.new(0, 0, -Z - 0.02) * CFrame.Angles(0, 0, math.rad(-38)), shade(col, 0.7), leather)
	elseif b == "pack" then
		shell(model, torso, "Pack", Vector3.new(1.5, 1.5, 0.6), CFrame.new(0, 0, Z + 0.32), col, fabric)
		shell(model, torso, "PackFlap", Vector3.new(1.52, 0.5, 0.62), CFrame.new(0, 0.56, Z + 0.33), shade(col, 0.82), fabric)
		shell(model, torso, "PackLight", Vector3.new(0.3, 0.08, 0.04), CFrame.new(0, 0.3, Z + 0.64), trim, Enum.Material.Neon)
		for _, x in { -0.5, 0.5 } do
			shell(model, torso, "PackStrap", Vector3.new(0.2, 1.9, 0.05), CFrame.new(x, 0, -Z - 0.02), shade(col, 0.7), fabric)
		end
	elseif b == "sheath" then
		local sh = CFrame.new(0, 0, Z + 0.12) * CFrame.Angles(0, 0, math.rad(35))
		shell(model, torso, "Sheath", Vector3.new(0.3, 3.0, 0.2), sh, col, leather)
		shell(model, torso, "SheathTip", Vector3.new(0.34, 0.24, 0.24), sh * CFrame.new(0, -1.5, 0), Color3.fromRGB(200, 170, 90), metal)
		shell(model, torso, "Guard", Vector3.new(0.7, 0.12, 0.26), sh * CFrame.new(0, 1.56, 0), Color3.fromRGB(200, 170, 90), metal)
		shell(model, torso, "Hilt", Vector3.new(0.18, 0.8, 0.18), sh * CFrame.new(0, 2.02, 0), Color3.fromRGB(30, 28, 30), leather)
		shell(model, torso, "Pommel", Vector3.new(0.2, 0.2, 0.2), sh * CFrame.new(0, 2.46, 0), trim, Enum.Material.Neon, Enum.PartType.Ball)
	elseif b == "shield" then
		shell(model, torso, "Shield", Vector3.new(1.7, 2.1, 0.18), CFrame.new(0, 0, Z + 0.18), col, metal)
		shell(model, torso, "ShieldRim", Vector3.new(1.8, 2.2, 0.12), CFrame.new(0, 0, Z + 0.12), shade(col, 0.7), metal)
		shell(model, torso, "ShieldBoss", Vector3.new(0.5, 0.5, 0.12), CFrame.new(0, 0.1, Z + 0.3) * CFrame.Angles(0, 0, math.rad(45)), trim, Enum.Material.Neon)
	elseif b == "staff" then
		local st = CFrame.new(0, 0.3, Z + 0.12) * CFrame.Angles(0, 0, math.rad(-28))
		shell(model, torso, "Staff", Vector3.new(0.16, 5, 0.16), st, Color3.fromRGB(110, 76, 46), wood)
		shell(model, torso, "StaffOrb", Vector3.new(0.5, 0.5, 0.5), st * CFrame.new(0, 2.7, 0), trim, Enum.Material.Neon, Enum.PartType.Ball)
		shell(model, torso, "StaffClaw", Vector3.new(0.3, 0.3, 0.3), st * CFrame.new(0, 2.4, 0), Color3.fromRGB(200, 170, 90), metal)
	elseif b == "scrolls" then
		local sc = CFrame.new(0.2, 0.15, Z + 0.28) * CFrame.Angles(0, 0, math.rad(-60))
		shell(model, torso, "ScrollCase", Vector3.new(1.7, 0.5, 0.5), sc, col, leather, Enum.PartType.Cylinder)
		for _, x in { -0.9, 0.9 } do
			shell(model, torso, "ScrollCap", Vector3.new(0.14, 0.56, 0.56), sc * CFrame.new(x, 0, 0), trim, metal, Enum.PartType.Cylinder)
		end
	elseif b == "crystal_crate" then
		shell(model, torso, "Crate", Vector3.new(1.6, 1.3, 0.9), CFrame.new(0, -0.1, Z + 0.48), Color3.fromRGB(122, 90, 58), wood)
		for k, x in { -0.45, 0, 0.42 } do
			shell(model, torso, "Crystal", Vector3.new(0.28, 0.6, 0.28), CFrame.new(x, 0.7, Z + 0.48) * CFrame.Angles(0, math.rad(30 * k), math.rad(12 * (k - 2))), Color3.fromRGB(120, 200, 255), Enum.Material.Neon)
		end
		for _, x in { -0.5, 0.5 } do
			shell(model, torso, "CrateStrap", Vector3.new(0.2, 1.9, 0.05), CFrame.new(x, 0, -Z - 0.02), Color3.fromRGB(70, 50, 34), leather)
		end
	elseif b == "banner" then
		shell(model, torso, "BannerPole", Vector3.new(0.1, 5.6, 0.1), CFrame.new(0.6, 1.4, Z + 0.12), Color3.fromRGB(120, 90, 60), wood)
		shell(model, torso, "Banner", Vector3.new(1.4, 1.8, 0.05), CFrame.new(-0.12, 3.2, Z + 0.12), col, fabric)
		shell(model, torso, "BannerMark", Vector3.new(0.5, 0.5, 0.06), CFrame.new(-0.12, 3.25, Z + 0.12) * CFrame.Angles(0, 0, math.rad(45)), trim, Enum.Material.Neon)
		shell(model, torso, "BannerTop", Vector3.new(0.2, 0.2, 0.2), CFrame.new(0.6, 4.25, Z + 0.12), Color3.fromRGB(214, 180, 90), metal, Enum.PartType.Ball)
	elseif b == "mana_wings" then
		for _, x in { -1, 1 } do
			local upper = shell(model, torso, "WingUpper", Vector3.new(2.4, 1.5, 0.06), CFrame.new(x * 1.45, 0.7, Z + 0.3) * CFrame.Angles(0, math.rad(-18 * x), math.rad(24 * x)), trim, Enum.Material.Neon)
			upper.Transparency = 0.35
			local lower = shell(model, torso, "WingLower", Vector3.new(1.8, 0.9, 0.06), CFrame.new(x * 1.15, -0.15, Z + 0.3) * CFrame.Angles(0, math.rad(-18 * x), math.rad(-14 * x)), trim, Enum.Material.Neon)
			lower.Transparency = 0.45
		end
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
	dressTop(model, parts, look)
	dressBottom(model, parts, look)
	if not opts.civilian then
		armorOn(model, parts, look)
		if opts.weapon ~= false then
			weaponOn(model, parts, look, opts.weapon)
		end
	end
	extraOn(model, parts, look)
	headwearOn(model, parts, look)
	backOn(model, parts, look, opts.civilian)
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
