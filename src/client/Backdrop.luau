--[[
	Procedural city behind the UI: a crater of tiered buildings around a dark
	lake, lit windows, chimney smoke, floating lanterns, slow camera drift.
	Client-only (nothing replicates). Built far from the origin so it doesn't
	overlap a map you already have. Turn it off with Config.backdrop = false.
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Backdrop = {}

-- Each Ward sits in its own slice of the crater, in this order around the ring.
local WARD_ORDER = { "gatewater", "lampwick", "saltpan", "glasswall", "ropewalk", "pumpside", "foundry", "kelpmarket", "bellhollow", "drownside" }

-- Light for each Ward (a district's `backdrop` in Content overrides these).
local AREAS = {
	gatewater = { tint = { 255, 236, 210 }, fog = { 160, 150, 140 }, clock = 17.6 },
	lampwick = { tint = { 255, 220, 170 }, fog = { 170, 140, 110 }, clock = 19.2 },
	saltpan = { tint = { 240, 244, 250 }, fog = { 200, 204, 210 }, clock = 15.5 },
	glasswall = { tint = { 214, 236, 255 }, fog = { 140, 170, 190 }, clock = 18.4 },
	ropewalk = { tint = { 236, 224, 200 }, fog = { 150, 140, 120 }, clock = 18.0 },
	pumpside = { tint = { 210, 220, 214 }, fog = { 120, 130, 124 }, clock = 18.6 },
	foundry = { tint = { 255, 200, 160 }, fog = { 150, 110, 80 }, clock = 19.0, haze = 3.2 },
	kelpmarket = { tint = { 220, 240, 220 }, fog = { 110, 140, 120 }, clock = 17.2 },
	bellhollow = { tint = { 236, 226, 255 }, fog = { 140, 130, 160 }, clock = 19.6 },
	drownside = { tint = { 190, 230, 226 }, fog = { 70, 110, 112 }, clock = 20.4, haze = 3.0 },
}
-- World events and expeditions regrade the whole scene while they last.
local OVERRIDES = {
	breach_tidewell = { tint = { 255, 150, 140 }, fog = { 150, 60, 54 }, contrast = 0.22, saturation = -0.1 },
	lantern_festival = { tint = { 255, 214, 160 }, fog = { 190, 140, 90 }, brightness = 0.06, clock = 20.5 },
	fog_week = { tint = { 206, 204, 190 }, fog = { 180, 174, 150 }, density = 0.72, haze = 6 },
	great_low_tide = { tint = { 255, 248, 236 }, fog = { 190, 196, 200 }, clock = 14 },
	company_strike = { tint = { 214, 192, 172 }, fog = { 110, 96, 86 }, haze = 3.6, saturation = -0.25 },
	dungeon = { tint = { 150, 220, 214 }, fog = { 30, 60, 64 }, clock = 1.5, density = 0.55 },
	containment = { tint = { 255, 160, 150 }, fog = { 120, 50, 50 }, contrast = 0.25, clock = 22 },
	trip = { tint = { 255, 246, 230 }, fog = { 200, 210, 220 }, clock = 13 },
	mission = { tint = { 222, 212, 236 }, fog = { 110, 100, 130 }, clock = 20 },
}

local ORIGIN = Vector3.new(6000, 0, 6000)
local WATER_LEVEL = 0

local WALLS = { Color3.fromRGB(56, 60, 68), Color3.fromRGB(72, 64, 58), Color3.fromRGB(46, 52, 60), Color3.fromRGB(86, 76, 64), Color3.fromRGB(62, 70, 76), Color3.fromRGB(94, 90, 84) }
local MATERIALS = { Enum.Material.Concrete, Enum.Material.Brick, Enum.Material.Slate, Enum.Material.WoodPlanks, Enum.Material.Cobblestone, Enum.Material.CorrodedMetal }
local WINDOW = Color3.fromRGB(255, 194, 118)
local WINDOW_COOL = Color3.fromRGB(170, 210, 230)
local ROCK = Color3.fromRGB(40, 42, 46)

local built = false

function Backdrop.build()
	if built then
		return
	end
	built = true
	local rng = Random.new(318)
	local folder = Instance.new("Folder")
	folder.Name = "LifeSimBackdrop"

	local function part(className: string, props)
		local p = Instance.new(className) :: BasePart
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		for k, v in props do
			(p :: any)[k] = v
		end
		p.Parent = folder
		return p
	end

	-- ── light & air ──
	Lighting.ClockTime = 18.8
	Lighting.Brightness = 1.4
	Lighting.Ambient = Color3.fromRGB(40, 44, 56)
	Lighting.OutdoorAmbient = Color3.fromRGB(78, 84, 104)
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.6
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = 0.4
	atmosphere.Offset = 0.12
	atmosphere.Color = Color3.fromRGB(150, 156, 172)
	atmosphere.Decay = Color3.fromRGB(88, 96, 122)
	atmosphere.Glare = 0.25
	atmosphere.Haze = 2.2
	atmosphere.Parent = Lighting
	if not Lighting:FindFirstChild("LifeSimBloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "LifeSimBloom"
		bloom.Intensity = 0.7
		bloom.Size = 28
		bloom.Threshold = 0.92
		bloom.Parent = Lighting
	end

	-- ── the Mere ──
	local terrain = Workspace.Terrain
	terrain.WaterColor = Color3.fromRGB(26, 50, 58)
	terrain.WaterTransparency = 0.6
	terrain.WaterReflectance = 0.55
	terrain.WaterWaveSize = 0.12
	terrain.WaterWaveSpeed = 6
	terrain:FillBlock(CFrame.new(ORIGIN + Vector3.new(0, WATER_LEVEL - 8, 0)), Vector3.new(1400, 16, 1400), Enum.Material.Water)
	part("Part", {
		Name = "LakeBed",
		Size = Vector3.new(1400, 4, 1400),
		CFrame = CFrame.new(ORIGIN + Vector3.new(0, WATER_LEVEL - 18, 0)),
		Color = Color3.fromRGB(20, 26, 28),
		Material = Enum.Material.Mud,
	})

	local function facing(pos: Vector3): CFrame
		return CFrame.lookAt(pos, Vector3.new(ORIGIN.X, pos.Y, ORIGIN.Z))
	end

	local function windows(cf: CFrame, size: Vector3, litChance: number, cool: boolean?)
		local cols = math.clamp(math.floor(size.X / 6), 1, 3)
		local floors = math.clamp(math.floor(size.Y / 7), 1, 5)
		local placed = 0
		for f = 1, floors do
			for c = 1, cols do
				if placed < 5 and rng:NextNumber() < litChance then
					placed += 1
					local x = (c - (cols + 1) / 2) * (size.X / (cols + 0.5))
					local y = -size.Y / 2 + f * (size.Y / (floors + 1))
					part("Part", {
						Size = Vector3.new(2, 2.6, 0.3),
						CFrame = cf * CFrame.new(x, y, -size.Z / 2 - 0.12),
						Color = if cool then WINDOW_COOL else WINDOW,
						Material = Enum.Material.Neon,
					})
				end
			end
		end
	end

	-- ── terraces: rings of buildings stepping up the crater wall ──
	local tiers = {
		{ radius = 250, y = 6, count = 30, height = { 14, 30 }, lit = 0.35 },
		{ radius = 310, y = 34, count = 36, height = { 16, 40 }, lit = 0.4 },
		{ radius = 370, y = 64, count = 42, height = { 18, 46 }, lit = 0.42 },
		{ radius = 430, y = 96, count = 46, height = { 20, 52 }, lit = 0.38 },
	}
	for t, tier in tiers do
		-- retaining wall under the tier
		local segments = 28
		for s = 1, segments do
			local a = (s / segments) * math.pi * 2
			local pos = ORIGIN + Vector3.new(math.cos(a) * (tier.radius - 16), tier.y - 18, math.sin(a) * (tier.radius - 16))
			part("Part", {
				Size = Vector3.new(tier.radius * math.pi * 2 / segments + 4, 40, 24),
				CFrame = facing(pos),
				Color = ROCK,
				Material = Enum.Material.Slate,
			})
		end
		for i = 1, tier.count do
			if rng:NextNumber() < 0.9 then
				local a = (i / tier.count) * math.pi * 2 + rng:NextNumber(-0.04, 0.04)
				local size = Vector3.new(rng:NextInteger(12, 24), rng:NextInteger(tier.height[1], tier.height[2]), rng:NextInteger(12, 20))
				local r = tier.radius + rng:NextNumber(-4, 8)
				local pos = ORIGIN + Vector3.new(math.cos(a) * r, tier.y + size.Y / 2, math.sin(a) * r)
				local cf = facing(pos)
				part("Part", {
					Size = size,
					CFrame = cf,
					Color = WALLS[rng:NextInteger(1, #WALLS)],
					Material = MATERIALS[rng:NextInteger(1, #MATERIALS)],
				})
				if rng:NextNumber() < 0.45 then
					-- a pitched roof
					part("WedgePart", {
						Size = Vector3.new(size.X, rng:NextInteger(4, 8), size.Z),
						CFrame = cf * CFrame.new(0, size.Y / 2 + 3, 0) * CFrame.Angles(0, math.pi / 2, 0),
						Color = Color3.fromRGB(52, 40, 36),
						Material = Enum.Material.Slate,
					})
				end
				windows(cf, size, tier.lit, t >= 4 and rng:NextNumber() < 0.3)
			end
		end
	end

	-- ── the Rim: pale houses and glasshouses at the top ──
	for i = 1, 26 do
		local a = (i / 26) * math.pi * 2
		local r = 500 + rng:NextNumber(-6, 6)
		local glass = rng:NextNumber() < 0.35
		local size = if glass then Vector3.new(24, 12, 18) else Vector3.new(rng:NextInteger(18, 28), rng:NextInteger(16, 26), 18)
		local pos = ORIGIN + Vector3.new(math.cos(a) * r, 130 + size.Y / 2, math.sin(a) * r)
		local cf = facing(pos)
		part("Part", {
			Size = size,
			CFrame = cf,
			Color = if glass then Color3.fromRGB(170, 210, 190) else Color3.fromRGB(196, 186, 166),
			Material = if glass then Enum.Material.Glass else Enum.Material.Marble,
			Transparency = if glass then 0.35 else 0,
		})
		if not glass then
			windows(cf, size, 0.55)
		end
	end

	-- ── the Charter walls along the Rim, one lit gatehouse per Ward ──
	local wallSegments = 40
	local wallRadius = 478
	for s = 1, wallSegments do
		local a = (s / wallSegments) * math.pi * 2
		local pos = ORIGIN + Vector3.new(math.cos(a) * wallRadius, 130 + 6, math.sin(a) * wallRadius)
		part("Part", {
			Size = Vector3.new(wallRadius * math.pi * 2 / wallSegments + 1, 12, 3),
			CFrame = facing(pos),
			Color = Color3.fromRGB(88, 84, 80),
			Material = Enum.Material.Cobblestone,
		})
		if s % 4 == 0 then
			local gate = facing(ORIGIN + Vector3.new(math.cos(a) * (wallRadius - 2), 130 + 11, math.sin(a) * (wallRadius - 2)))
			part("Part", {
				Size = Vector3.new(9, 22, 9),
				CFrame = gate,
				Color = Color3.fromRGB(70, 66, 62),
				Material = Enum.Material.Slate,
			})
			local lamp = part("Part", {
				Shape = Enum.PartType.Ball,
				Size = Vector3.new(2.2, 2.2, 2.2),
				CFrame = gate * CFrame.new(0, 12.5, 0),
				Color = Color3.fromRGB(255, 214, 150),
				Material = Enum.Material.Neon,
			})
			if s % 8 == 0 then
				local light = Instance.new("PointLight")
				light.Color = Color3.fromRGB(255, 200, 140)
				light.Range = 18
				light.Brightness = 1.4
				light.Parent = lamp
			end
		end
	end

	-- ── the Silt: stilt-houses and docks at the waterline ──
	for i = 1, 34 do
		local a = rng:NextNumber(0, math.pi * 2)
		local r = rng:NextNumber(150, 215)
		local base = ORIGIN + Vector3.new(math.cos(a) * r, WATER_LEVEL, math.sin(a) * r)
		local size = Vector3.new(rng:NextInteger(7, 11), rng:NextInteger(5, 8), rng:NextInteger(7, 10))
		local cf = facing(base + Vector3.new(0, 6 + size.Y / 2, 0))
		part("Part", {
			Size = size,
			CFrame = cf,
			Color = Color3.fromRGB(rng:NextInteger(70, 96), rng:NextInteger(58, 74), rng:NextInteger(48, 60)),
			Material = Enum.Material.WoodPlanks,
		})
		for _, corner in { Vector3.new(-1, 0, -1), Vector3.new(1, 0, -1), Vector3.new(-1, 0, 1), Vector3.new(1, 0, 1) } do
			part("Part", {
				Size = Vector3.new(0.8, 10, 0.8),
				CFrame = cf * CFrame.new(corner.X * (size.X / 2 - 0.5), -size.Y / 2 - 4, corner.Z * (size.Z / 2 - 0.5)),
				Color = Color3.fromRGB(58, 46, 38),
				Material = Enum.Material.Wood,
			})
		end
		if rng:NextNumber() < 0.6 then
			part("Part", {
				Size = Vector3.new(1.6, 1.8, 0.3),
				CFrame = cf * CFrame.new(0, 0, -size.Z / 2 - 0.12),
				Color = WINDOW,
				Material = Enum.Material.Neon,
			})
		end
	end

	-- ── landmarks ──
	-- drowned cathedral spire breaking the surface
	local spireBase = ORIGIN + Vector3.new(46, WATER_LEVEL, -38)
	part("Part", {
		Size = Vector3.new(10, 34, 10),
		CFrame = CFrame.new(spireBase + Vector3.new(0, 8, 0)),
		Color = Color3.fromRGB(70, 82, 84),
		Material = Enum.Material.Cobblestone,
	})
	part("Part", {
		Size = Vector3.new(9, 9, 9),
		CFrame = CFrame.new(spireBase + Vector3.new(0, 28, 0)) * CFrame.Angles(math.rad(45), 0, math.rad(45)),
		Color = Color3.fromRGB(80, 96, 98),
		Material = Enum.Material.Slate,
	})
	local glow = part("Part", {
		Size = Vector3.new(2, 2, 2),
		CFrame = CFrame.new(spireBase + Vector3.new(0, -2, 0)),
		Color = Color3.fromRGB(90, 200, 190),
		Material = Enum.Material.Neon,
		Transparency = 0.4,
	})
	local underLight = Instance.new("PointLight")
	underLight.Color = Color3.fromRGB(90, 200, 190)
	underLight.Range = 26
	underLight.Brightness = 2
	underLight.Parent = glow

	-- pumphouse with smoking chimneys on the second tier
	local pumpAngle = math.rad(200)
	local pumpPos = ORIGIN + Vector3.new(math.cos(pumpAngle) * 318, 34 + 18, math.sin(pumpAngle) * 318)
	local pumpCf = facing(pumpPos)
	part("Part", {
		Size = Vector3.new(46, 36, 30),
		CFrame = pumpCf,
		Color = Color3.fromRGB(92, 60, 48),
		Material = Enum.Material.Brick,
	})
	windows(pumpCf, Vector3.new(46, 36, 30), 0.7)
	for i = -1, 1 do
		local chimney = part("Part", {
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(30, 6, 6),
			CFrame = pumpCf * CFrame.new(i * 13, 30, 6) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(70, 48, 40),
			Material = Enum.Material.Brick,
		})
		local smoke = Instance.new("Smoke")
		smoke.Color = Color3.fromRGB(120, 120, 128)
		smoke.Opacity = 0.18
		smoke.RiseVelocity = 6
		smoke.Size = 6
		smoke.Parent = chimney
	end

	-- floating lanterns
	local lanterns = {}
	for i = 1, 16 do
		local a = rng:NextNumber(0, math.pi * 2)
		local r = rng:NextNumber(30, 190)
		local pos = ORIGIN + Vector3.new(math.cos(a) * r, WATER_LEVEL + 0.6, math.sin(a) * r)
		local ball = part("Part", {
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(1.4, 1.4, 1.4),
			CFrame = CFrame.new(pos),
			Color = Color3.fromRGB(255, 186, 110),
			Material = Enum.Material.Neon,
		})
		if i <= 8 then
			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(255, 180, 110)
			light.Range = 12
			light.Brightness = 1.6
			light.Parent = ball
		end
		table.insert(lanterns, { part = ball, base = pos, phase = rng:NextNumber(0, math.pi * 2), drift = rng:NextNumber(-0.02, 0.02) })
	end

	-- ── landmarks: each Ward's slice of the crater gets something of its own ──
	local function wardAngle(i: number): number
		return (i - 1) / #WARD_ORDER * math.pi * 2
	end
	local function at(a: number, r: number, y: number): Vector3
		return ORIGIN + Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
	end
	local function neon(pos: Vector3, size: Vector3, color: Color3, shape: Enum.PartType?)
		return part("Part", { Size = size, CFrame = CFrame.new(pos), Color = color, Material = Enum.Material.Neon, Shape = shape or Enum.PartType.Block })
	end
	for i, id in WARD_ORDER do
		local a = wardAngle(i)
		local name = "Landmark_" .. id
		if id == "gatewater" then
			for _, off in { -0.05, 0.05 } do
				part("Part", { Name = name, Size = Vector3.new(14, 64, 14), CFrame = facing(at(a + off, 470, 130 + 32)), Color = Color3.fromRGB(96, 90, 84), Material = Enum.Material.Slate })
			end
			part("Part", { Name = name, Size = Vector3.new(60, 10, 14), CFrame = facing(at(a, 470, 130 + 66)), Color = Color3.fromRGB(110, 102, 94), Material = Enum.Material.Slate })
			neon(at(a, 466, 130 + 58), Vector3.new(6, 6, 6), Color3.fromRGB(255, 220, 150), Enum.PartType.Ball)
		elseif id == "lampwick" then
			part("Part", { Name = name, Size = Vector3.new(6, 80, 6), CFrame = facing(at(a, 370, 64 + 40)), Color = Color3.fromRGB(60, 54, 50), Material = Enum.Material.Metal })
			neon(at(a, 370, 64 + 84), Vector3.new(10, 10, 10), Color3.fromRGB(255, 196, 120), Enum.PartType.Ball)
		elseif id == "saltpan" then
			for k = -1, 1 do
				part("Part", { Name = name, Shape = Enum.PartType.Ball, Size = Vector3.new(34, 34, 34), CFrame = CFrame.new(at(a + k * 0.05, 300, 34 + 4)), Color = Color3.fromRGB(236, 236, 232), Material = Enum.Material.Salt })
			end
		elseif id == "glasswall" then
			for k = -1, 1 do
				local h = 90 + k * 20
				local pos = at(a + k * 0.04, 380, 64 + h / 2)
				part("Part", { Name = name, Size = Vector3.new(16, h, 16), CFrame = facing(pos), Color = Color3.fromRGB(150, 200, 210), Material = Enum.Material.Glass, Transparency = 0.25 })
				neon(pos + Vector3.new(0, h / 2 + 2, 0), Vector3.new(4, 4, 4), Color3.fromRGB(170, 220, 240))
			end
		elseif id == "ropewalk" then
			for k = 0, 2 do
				part("Part", { Name = name, Size = Vector3.new(70, 10, 12), CFrame = facing(at(a + (k - 1) * 0.06, 310, 34 + 5 + k * 3)), Color = Color3.fromRGB(110, 86, 60), Material = Enum.Material.WoodPlanks })
			end
		elseif id == "pumpside" then
			part("Part", { Name = name, Size = Vector3.new(34, 34, 34), CFrame = facing(at(a, 262, 6 + 17)), Color = Color3.fromRGB(80, 84, 88), Material = Enum.Material.CorrodedMetal })
			for k = -1, 1, 2 do
				part("Part", { Name = name, Shape = Enum.PartType.Cylinder, Size = Vector3.new(60, 7, 7), CFrame = CFrame.new(at(a + k * 0.03, 225, 6)) * CFrame.Angles(0, -a, 0), Color = Color3.fromRGB(96, 92, 86), Material = Enum.Material.Metal })
			end
		elseif id == "foundry" then
			for k = -1.5, 1.5 do
				local pos = at(a + k * 0.035, 330, 34 + 40)
				part("Part", { Name = name, Size = Vector3.new(8, 80, 8), CFrame = facing(pos), Color = Color3.fromRGB(70, 50, 44), Material = Enum.Material.Brick })
				neon(pos + Vector3.new(0, 41, 0), Vector3.new(8, 2, 8), Color3.fromRGB(255, 140, 60))
			end
		elseif id == "kelpmarket" then
			local colors = { Color3.fromRGB(160, 54, 44), Color3.fromRGB(60, 120, 84), Color3.fromRGB(196, 156, 60) }
			for k = 1, 6 do
				part("WedgePart", { Name = name, Size = Vector3.new(12, 4, 8), CFrame = facing(at(a + (k - 3.5) * 0.022, 252, 6 + 14)), Color = colors[(k - 1) % 3 + 1], Material = Enum.Material.Fabric })
			end
		elseif id == "bellhollow" then
			part("Part", { Name = name, Size = Vector3.new(12, 64, 12), CFrame = facing(at(a, 370, 64 + 32)), Color = Color3.fromRGB(86, 80, 90), Material = Enum.Material.Slate })
			part("Part", { Name = name, Shape = Enum.PartType.Ball, Size = Vector3.new(9, 9, 9), CFrame = CFrame.new(at(a, 366, 64 + 58)), Color = Color3.fromRGB(214, 168, 72), Material = Enum.Material.Metal })
		elseif id == "drownside" then
			for k = -1, 1 do
				part("Part", { Name = name, Size = Vector3.new(16, 34, 16), CFrame = facing(at(a + k * 0.05, 215, 2)) * CFrame.Angles(math.rad(10 * k), 0, math.rad(12)), Color = Color3.fromRGB(56, 70, 70), Material = Enum.Material.Slate })
			end
			neon(at(a, 205, 1), Vector3.new(30, 1, 30), Color3.fromRGB(80, 200, 190))
		end
	end

	folder.Parent = Workspace

	-- ── light grading (tweened when the area changes) ──
	local grade = Lighting:FindFirstChild("LifeSimGrade") or Instance.new("ColorCorrectionEffect")
	grade.Name = "LifeSimGrade"
	grade.Parent = Lighting
	Backdrop._grade = grade
	Backdrop._atmosphere = atmosphere

	-- ── camera: faces your Ward; high on the Rim in the Charter, low by the water in the Gutters ──
	local camera = Workspace.CurrentCamera
	while not camera do
		task.wait()
		camera = Workspace.CurrentCamera
	end
	local cur = { angle = math.rad(20), eyeY = 46, targetR = 300, targetY = 40 }
	Backdrop._view = { angle = math.rad(20), eyeY = 46, targetR = 300, targetY = 40, orbit = true }
	local clock = 0
	RunService:BindToRenderStep("LifeSimBackdrop", Enum.RenderPriority.Camera.Value + 1, function(dt)
		clock += dt
		local view = Backdrop._view
		if view.orbit then
			view.angle += dt * (view.speed or 0.012)
		end
		local k = math.min(1, dt * 0.8)
		local da = (view.angle - cur.angle + math.pi) % (math.pi * 2) - math.pi
		cur.angle += da * k
		cur.eyeY += (view.eyeY - cur.eyeY) * k
		cur.targetR += (view.targetR - cur.targetR) * k
		cur.targetY += (view.targetY - cur.targetY) * k
		local sway = if view.orbit then 0 else math.sin(clock * 0.05) * 0.12
		local a = cur.angle + sway
		local eye = ORIGIN + Vector3.new(math.cos(a + math.pi) * 70, cur.eyeY, math.sin(a + math.pi) * 70)
		local target = ORIGIN + Vector3.new(math.cos(a) * cur.targetR, cur.targetY, math.sin(a) * cur.targetR)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 55
		camera.CFrame = CFrame.lookAt(eye, target)
		local now = os.clock()
		for _, l in lanterns do
			local bob = math.sin(now * 0.9 + l.phase) * 0.25
			local drift = CFrame.Angles(0, now * l.drift, 0)
			local rel = l.base - ORIGIN
			local pos = ORIGIN + drift:VectorToWorldSpace(rel)
			l.part.CFrame = CFrame.new(pos.X, l.base.Y + bob, pos.Z)
		end
	end)
end

-- The intro: a slow sweep high over the whole city. cinematic(false) hands back to setArea.
function Backdrop.cinematic(on: boolean)
	if not built or not Backdrop._view then
		return
	end
	local view = Backdrop._view
	if on then
		view.orbit = true
		view.speed = 0.07
		view.eyeY = 150
		view.targetR = 520
		view.targetY = 60
	else
		view.speed = nil
	end
end

-- Moves the view to an area and regrades the light.
-- area = { district = id, side = "charter" | "gutters", world = worldEventId?, run = kind?, custom = districtBackdrop? }
function Backdrop.setArea(area)
	if not built or not Backdrop._view then
		return
	end
	-- a pack's own districts map onto the ring by their position in the list
	local index = table.find(WARD_ORDER, area.district or "") or area.index or 1
	index = ((index - 1) % #WARD_ORDER) + 1
	local charter = area.side == "charter"
	local view = Backdrop._view
	view.orbit = false
	view.angle = (index - 1) / #WARD_ORDER * math.pi * 2
	view.eyeY = if charter then 104 else 26
	view.targetR = if charter then 470 else 290
	view.targetY = if charter then 132 else 28

	local base = area.custom or AREAS[area.district or ""] or AREAS.gatewater
	local over = (area.run and OVERRIDES[area.run]) or (area.world and OVERRIDES[area.world]) or {}
	local function color(t)
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	local tint = over.tint or base.tint
	local fog = over.fog or base.fog
	local info = TweenInfo.new(2.5, Enum.EasingStyle.Sine)
	pcall(function()
		TweenService:Create(Lighting, info, { ClockTime = over.clock or base.clock or 18.8 }):Play()
		if Backdrop._grade then
			TweenService:Create(Backdrop._grade, info, {
				TintColor = color(tint),
				Brightness = (over.brightness or 0) + (if charter then 0.04 else -0.03),
				Contrast = over.contrast or 0.06,
				Saturation = (over.saturation or 0) + (if charter then 0.05 else -0.05),
			}):Play()
		end
		if Backdrop._atmosphere then
			TweenService:Create(Backdrop._atmosphere, info, {
				Color = color(fog),
				Density = over.density or base.density or 0.4,
				Haze = (over.haze or base.haze or 2.2) + (if charter then -0.4 else 0.5),
			}):Play()
		end
	end)
end

return Backdrop
