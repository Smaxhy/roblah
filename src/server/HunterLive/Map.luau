--[[
	THE WALKABLE CITY (server-built, so every player and NPC shares it): a grid of city blocks
	with roads, crossings, street lamps, a plaza with a news screen, a park, a parking lot, an
	industrial yard, a construction site, a subway entrance, a Hunter Association branch and a
	guild tower. Live Gate incidents happen at its SITES (Map.sites); civilians walk its
	sidewalk WAYPOINTS and run to its SHELTERS.

	Everything is plain Parts (no assets to go missing), anchored, and built once.
		local Map = require(script.Map)
		local city = Map.build(parent)        -- the Model, built at Map.ORIGIN
		Map.sites, Map.waypoints, Map.shelters, Map.spawns, Map.screen (the plaza's SurfaceGui label)
]]

local Map = {}

Map.ORIGIN = Vector3.new(0, 0, 0)
Map.BLOCKS = 5
Map.BLOCK = 110
Map.ROAD = 38
Map.SIDEWALK = 7
local EXTENT = Map.BLOCKS * Map.BLOCK + (Map.BLOCKS + 1) * Map.ROAD

Map.sites = {}
Map.waypoints = {}
Map.shelters = {}
Map.spawns = {}
Map.screen = nil :: TextLabel?

local rng = Random.new(20261127)

local ASPHALT = Color3.fromRGB(46, 48, 52)
local CONCRETE = Color3.fromRGB(150, 150, 146)
local CURB = Color3.fromRGB(176, 176, 170)
local GLASS_TINTS = { Color3.fromRGB(70, 96, 130), Color3.fromRGB(56, 70, 92), Color3.fromRGB(88, 110, 136), Color3.fromRGB(42, 52, 70) }
local WALLS = { Color3.fromRGB(196, 190, 178), Color3.fromRGB(150, 146, 140), Color3.fromRGB(120, 118, 122), Color3.fromRGB(176, 160, 140), Color3.fromRGB(96, 100, 108), Color3.fromRGB(214, 210, 200) }
local NEON = { Color3.fromRGB(255, 70, 110), Color3.fromRGB(70, 200, 255), Color3.fromRGB(255, 190, 60), Color3.fromRGB(150, 110, 255), Color3.fromRGB(80, 255, 170) }

local folder: Model
local function part(props: any, parent: Instance?): BasePart
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent or folder
	return p
end
local function deco(props: any, parent: Instance?): BasePart
	props.CanCollide = false
	props.CanQuery = false
	props.CanTouch = false
	props.CastShadow = if props.CastShadow == nil then false else props.CastShadow
	return part(props, parent)
end

-- the centre of block (i, j), 0-based
function Map.blockCenter(i: number, j: number): Vector3
	local start = -EXTENT / 2 + Map.ROAD + Map.BLOCK / 2
	return Map.ORIGIN + Vector3.new(start + i * (Map.BLOCK + Map.ROAD), 0, start + j * (Map.BLOCK + Map.ROAD))
end
-- the centre of the road crossing west/north of block (i, j)
function Map.crossing(i: number, j: number): Vector3
	local start = -EXTENT / 2 + Map.ROAD / 2
	return Map.ORIGIN + Vector3.new(start + i * (Map.BLOCK + Map.ROAD), 0, start + j * (Map.BLOCK + Map.ROAD))
end

local function addSite(name: string, kind: string, pos: Vector3, label: string)
	table.insert(Map.sites, { id = name, kind = kind, pos = pos, label = label })
end

-- ── pieces ────────────────────────────────────────────────────────────────
local function streetLamp(pos: Vector3, facing: number)
	local m = Instance.new("Model")
	m.Name = "StreetLamp"
	deco({ Name = "Pole", Size = Vector3.new(0.5, 16, 0.5), Position = pos + Vector3.new(0, 8.6, 0), Color = Color3.fromRGB(40, 42, 46), Material = Enum.Material.Metal }, m)
	local arm = deco({ Name = "Arm", Size = Vector3.new(0.4, 0.4, 4), CFrame = CFrame.new(pos + Vector3.new(0, 16.4, 0)) * CFrame.Angles(0, facing, 0) * CFrame.new(0, 0, -2), Color = Color3.fromRGB(40, 42, 46), Material = Enum.Material.Metal }, m)
	local head = deco({ Name = "Lamp", Size = Vector3.new(1.4, 0.4, 2), CFrame = arm.CFrame * CFrame.new(0, -0.3, -1.8), Color = Color3.fromRGB(255, 236, 200), Material = Enum.Material.Neon }, m)
	local light = Instance.new("SpotLight")
	light.Face = Enum.NormalId.Bottom
	light.Angle = 110
	light.Range = 34
	light.Brightness = 2.2
	light.Color = Color3.fromRGB(255, 226, 180)
	light.Shadows = false
	light.Parent = head
	m.Parent = folder
end

local function tree(pos: Vector3, scale: number)
	deco({ Name = "Trunk", Shape = Enum.PartType.Cylinder, Size = Vector3.new(6 * scale, 1.1 * scale, 1.1 * scale), CFrame = CFrame.new(pos + Vector3.new(0, 3 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(90, 66, 46), Material = Enum.Material.Wood, CastShadow = true })
	for k = 0, 2 do
		deco({ Name = "Leaves", Shape = Enum.PartType.Ball, Size = Vector3.one * (5.5 - k) * scale, Position = pos + Vector3.new(rng:NextNumber(-1, 1), (6.5 + k * 1.6) * scale, rng:NextNumber(-1, 1)), Color = Color3.fromRGB(60 + k * 10, 120 + k * 12, 60), Material = Enum.Material.Grass, CastShadow = true })
	end
end

local function car(pos: Vector3, yaw: number, color: Color3?)
	local m = Instance.new("Model")
	m.Name = "Car"
	local c = color or Color3.fromHSV(rng:NextNumber(), rng:NextNumber(0.1, 0.6), rng:NextNumber(0.3, 0.9))
	local base = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
	part({ Name = "Body", Size = Vector3.new(6.4, 2.4, 13), CFrame = base * CFrame.new(0, 2, 0), Color = c, Material = Enum.Material.SmoothPlastic }, m)
	deco({ Name = "Cabin", Size = Vector3.new(5.8, 2, 7), CFrame = base * CFrame.new(0, 4.1, 0.6), Color = Color3.fromRGB(40, 50, 64), Material = Enum.Material.Glass, Transparency = 0.2 }, m)
	for _, x in { -2.9, 2.9 } do
		for _, z in { -4, 4 } do
			deco({ Name = "Wheel", Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 2.4, 2.4), CFrame = base * CFrame.new(x, 1.2, z), Color = Color3.fromRGB(20, 20, 22) }, m)
		end
	end
	deco({ Name = "Lights", Size = Vector3.new(5, 0.4, 0.1), CFrame = base * CFrame.new(0, 2.4, -6.55), Color = Color3.fromRGB(255, 250, 230), Material = Enum.Material.Neon }, m)
	deco({ Name = "Tail", Size = Vector3.new(5, 0.4, 0.1), CFrame = base * CFrame.new(0, 2.4, 6.55), Color = Color3.fromRGB(200, 30, 30), Material = Enum.Material.Neon }, m)
	m.Parent = folder
	return m
end
Map.car = car

-- a building on a footprint: walls, window bands, a roof, maybe a vertical neon sign
local function building(center: Vector3, w: number, d: number, h: number, style: string?)
	local m = Instance.new("Model")
	m.Name = "Building"
	local glass = style == "glass"
	local wall = if glass then GLASS_TINTS[rng:NextInteger(1, #GLASS_TINTS)] else WALLS[rng:NextInteger(1, #WALLS)]
	part({ Name = "Mass", Size = Vector3.new(w, h, d), Position = center + Vector3.new(0, h / 2 + 0.6, 0), Color = wall, Material = if glass then Enum.Material.Glass else Enum.Material.Concrete, Reflectance = if glass then 0.15 else 0, CastShadow = true }, m)
	-- window bands on all four faces
	local floors = math.floor(h / 9)
	for f = 1, floors do
		local y = 0.6 + f * 9 - 4
		local lit = rng:NextNumber() < 0.55
		local col = if lit then Color3.fromRGB(255, 226, 160) else Color3.fromRGB(30, 38, 50)
		local mat = if lit then Enum.Material.Neon else Enum.Material.Glass
		deco({ Name = "Band", Size = Vector3.new(w + 0.2, 2.6, 0.2), Position = center + Vector3.new(0, y, d / 2), Color = col, Material = mat, Transparency = if lit then 0.25 else 0 }, m)
		deco({ Name = "Band", Size = Vector3.new(w + 0.2, 2.6, 0.2), Position = center + Vector3.new(0, y, -d / 2), Color = col, Material = mat, Transparency = if lit then 0.25 else 0 }, m)
		deco({ Name = "Band", Size = Vector3.new(0.2, 2.6, d + 0.2), Position = center + Vector3.new(w / 2, y, 0), Color = col, Material = mat, Transparency = if lit then 0.25 else 0 }, m)
		deco({ Name = "Band", Size = Vector3.new(0.2, 2.6, d + 0.2), Position = center + Vector3.new(-w / 2, y, 0), Color = col, Material = mat, Transparency = if lit then 0.25 else 0 }, m)
	end
	deco({ Name = "Roof", Size = Vector3.new(w + 1, 1, d + 1), Position = center + Vector3.new(0, h + 1.1, 0), Color = Color3.fromRGB(70, 70, 74), Material = Enum.Material.Slate }, m)
	if rng:NextNumber() < 0.5 then
		deco({ Name = "Unit", Size = Vector3.new(6, 4, 6), Position = center + Vector3.new(rng:NextNumber(-w / 4, w / 4), h + 3.6, rng:NextNumber(-d / 4, d / 4)), Color = Color3.fromRGB(150, 150, 154), Material = Enum.Material.Metal }, m)
	end
	if not glass and rng:NextNumber() < 0.6 and h > 30 then
		local c = NEON[rng:NextInteger(1, #NEON)]
		local face = if rng:NextNumber() < 0.5 then 1 else -1
		local sign = deco({ Name = "Sign", Size = Vector3.new(2.6, math.min(h * 0.45, 26), 0.6), Position = center + Vector3.new(w / 2 - 3, h * 0.55, face * (d / 2 + 1.3)), Color = c, Material = Enum.Material.Neon }, m)
		local light = Instance.new("PointLight")
		light.Color = c
		light.Range = 16
		light.Brightness = 1.2
		light.Parent = sign
	end
	-- a shop front with a door at street level (a shelter for civilians)
	deco({ Name = "Awning", Size = Vector3.new(math.min(w - 4, 18), 0.4, 4), Position = center + Vector3.new(0, 9, -d / 2 - 2), Color = NEON[rng:NextInteger(1, #NEON)], Material = Enum.Material.Fabric }, m)
	deco({ Name = "Door", Size = Vector3.new(5, 7.5, 0.3), Position = center + Vector3.new(0, 4.4, -d / 2 - 0.1), Color = Color3.fromRGB(60, 80, 96), Material = Enum.Material.Glass, Transparency = 0.3 }, m)
	table.insert(Map.shelters, center + Vector3.new(0, 0, -d / 2 - 3))
	m.Parent = folder
	return m
end

local function signText(parentPart: BasePart, face: Enum.NormalId, text: string, color: Color3, bg: Color3?)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.CanvasSize = Vector2.new(600, 140)
	gui.LightInfluence = 0
	gui.Parent = parentPart
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = bg or Color3.fromRGB(10, 14, 22)
	label.BackgroundTransparency = if bg then 0 else 1
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
	return label
end

-- ── the city ──────────────────────────────────────────────────────────────
function Map.build(parent: Instance): Model
	if folder and folder.Parent then
		return folder
	end
	folder = Instance.new("Model")
	folder.Name = "BitLevelingCity"
	table.clear(Map.sites)
	table.clear(Map.waypoints)
	table.clear(Map.shelters)
	table.clear(Map.spawns)

	-- ground: asphalt everywhere, then the blocks on top as sidewalk slabs
	part({ Name = "Asphalt", Size = Vector3.new(EXTENT + 200, 1, EXTENT + 200), Position = Map.ORIGIN + Vector3.new(0, -0.5, 0), Color = ASPHALT, Material = Enum.Material.Asphalt })
	-- an invisible wall round the edge so nobody walks off the world
	for _, side in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
		local len = EXTENT + 200
		part({ Name = "Edge", Size = if side[1] ~= 0 then Vector3.new(2, 60, len) else Vector3.new(len, 60, 2), Position = Map.ORIGIN + Vector3.new(side[1] * (EXTENT / 2 + 60), 30, side[2] * (EXTENT / 2 + 60)), Transparency = 1, CanQuery = false })
	end
	-- lane markings and crosswalks
	for k = 0, Map.BLOCKS do
		local c = Map.crossing(k, 0)
		for _, axis in { "x", "z" } do
			for s = -EXTENT / 2, EXTENT / 2, 14 do
				local pos = if axis == "x" then Vector3.new(c.X, 0.02, s) else Vector3.new(s, 0.02, Map.crossing(0, k).Z)
				deco({ Name = "Lane", Size = if axis == "x" then Vector3.new(0.6, 0.05, 6) else Vector3.new(6, 0.05, 0.6), Position = pos, Color = Color3.fromRGB(230, 210, 120), Material = Enum.Material.Neon, Transparency = 0.35 })
			end
		end
	end
	for i = 0, Map.BLOCKS do
		for j = 0, Map.BLOCKS do
			local c = Map.crossing(i, j)
			for st = -3, 3 do
				deco({ Name = "Zebra", Size = Vector3.new(2, 0.05, 9), Position = c + Vector3.new(st * 4, 0.03, Map.ROAD / 2 + 6), Color = Color3.fromRGB(235, 235, 230) })
				deco({ Name = "Zebra", Size = Vector3.new(9, 0.05, 2), Position = c + Vector3.new(Map.ROAD / 2 + 6, 0.03, st * 4), Color = Color3.fromRGB(235, 235, 230) })
			end
			if (i + j) % 2 == 0 then
				addSite("crossing_" .. i .. "_" .. j, "street", c + Vector3.new(0, 0, 0), "the crossing at block " .. i .. "-" .. j)
			end
		end
	end

	-- the blocks: what each one is
	local special = {
		["2_2"] = "plaza", ["1_2"] = "association", ["3_2"] = "guild", ["2_1"] = "park", ["2_3"] = "parking",
		["0_0"] = "industrial", ["4_0"] = "construction", ["0_4"] = "station", ["4_4"] = "residential",
	}
	for i = 0, Map.BLOCKS - 1 do
		for j = 0, Map.BLOCKS - 1 do
			local center = Map.blockCenter(i, j)
			local kind = special[i .. "_" .. j] or (if rng:NextNumber() < 0.5 then "commercial" else "residential_tall")
			local slabColor = if kind == "park" then Color3.fromRGB(70, 120, 64) else CONCRETE
			part({ Name = "Block", Size = Vector3.new(Map.BLOCK, 1.2, Map.BLOCK), Position = center + Vector3.new(0, 0, 0), Color = slabColor, Material = if kind == "park" then Enum.Material.Grass else Enum.Material.Concrete })
			-- curbs
			for _, e in { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
				deco({ Name = "Curb", Size = if e[1] ~= 0 then Vector3.new(0.8, 1.4, Map.BLOCK) else Vector3.new(Map.BLOCK, 1.4, 0.8), Position = center + Vector3.new(e[1] * Map.BLOCK / 2, 0.1, e[2] * Map.BLOCK / 2), Color = CURB })
			end
			-- sidewalk waypoints: the four corners and the middle of each side
			local r = Map.BLOCK / 2 - 3
			for _, off in { { -r, -r }, { 0, -r }, { r, -r }, { r, 0 }, { r, r }, { 0, r }, { -r, r }, { -r, 0 } } do
				table.insert(Map.waypoints, center + Vector3.new(off[1], 0.7, off[2]))
			end
			-- lamps at the corners
			for _, off in { { -1, -1 }, { 1, 1 } } do
				streetLamp(center + Vector3.new(off[1] * (Map.BLOCK / 2 - 2), 0.6, off[2] * (Map.BLOCK / 2 - 2)), math.atan2(off[1], off[2]))
			end
			local inner = Map.BLOCK - 2 * Map.SIDEWALK - 6
			if kind == "plaza" then
				deco({ Name = "Paving", Size = Vector3.new(Map.BLOCK - 4, 0.1, Map.BLOCK - 4), Position = center + Vector3.new(0, 0.62, 0), Color = Color3.fromRGB(190, 182, 168), Material = Enum.Material.Pavement })
				part({ Name = "Fountain", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 22, 22), CFrame = CFrame.new(center + Vector3.new(0, 1.6, 22)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(170, 170, 176), Material = Enum.Material.Marble })
				deco({ Name = "Water", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 19, 19), CFrame = CFrame.new(center + Vector3.new(0, 2.5, 22)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(80, 150, 200), Material = Enum.Material.Glass, Transparency = 0.3 })
				-- the news screen: a big billboard the server writes headlines on
				local frame = part({ Name = "ScreenFrame", Size = Vector3.new(44, 26, 2), Position = center + Vector3.new(0, 26, 46), Color = Color3.fromRGB(20, 22, 26), Material = Enum.Material.Metal })
				part({ Name = "ScreenPost", Size = Vector3.new(3, 14, 3), Position = center + Vector3.new(0, 7, 46), Color = Color3.fromRGB(30, 32, 36), Material = Enum.Material.Metal })
				local screen = deco({ Name = "Screen", Size = Vector3.new(42, 24, 0.2), Position = center + Vector3.new(0, 26, 44.9), Color = Color3.fromRGB(10, 14, 22), Material = Enum.Material.Neon })
				local gui = Instance.new("SurfaceGui")
				gui.Face = Enum.NormalId.Front
				gui.CanvasSize = Vector2.new(840, 480)
				gui.LightInfluence = 0
				gui.Parent = screen
				local head = Instance.new("TextLabel")
				head.Size = UDim2.new(1, 0, 0, 90)
				head.BackgroundColor3 = Color3.fromRGB(28, 70, 160)
				head.Text = "HUNTER NEWS · LIVE"
				head.TextColor3 = Color3.new(1, 1, 1)
				head.Font = Enum.Font.GothamBlack
				head.TextScaled = true
				head.Parent = gui
				local body = Instance.new("TextLabel")
				body.Name = "Headlines"
				body.Position = UDim2.fromOffset(20, 100)
				body.Size = UDim2.new(1, -40, 1, -110)
				body.BackgroundTransparency = 1
				body.TextColor3 = Color3.fromRGB(230, 236, 255)
				body.Font = Enum.Font.GothamMedium
				body.TextScaled = true
				body.TextWrapped = true
				body.TextXAlignment = Enum.TextXAlignment.Left
				body.TextYAlignment = Enum.TextYAlignment.Top
				body.Text = "No incidents reported."
				body.Parent = gui
				Map.screen = body
				local _ = frame
				for b = -1, 1, 2 do
					part({ Name = "Bench", Size = Vector3.new(10, 1.6, 3), Position = center + Vector3.new(b * 30, 1.4, -10), Color = Color3.fromRGB(110, 80, 56), Material = Enum.Material.Wood })
				end
				addSite("plaza", "plaza", center + Vector3.new(0, 0.6, -6), "the central plaza")
				table.insert(Map.spawns, center + Vector3.new(-30, 3, -38))
				table.insert(Map.spawns, center + Vector3.new(30, 3, -38))
			elseif kind == "association" then
				local b = building(center + Vector3.new(0, 0, 8), inner, inner * 0.7, 70, "glass")
				local plate = deco({ Name = "AssocSign", Size = Vector3.new(40, 6, 0.4), Position = center + Vector3.new(0, 14, 8 - inner * 0.35 - 0.6), Color = Color3.fromRGB(240, 244, 255), Material = Enum.Material.SmoothPlastic }, b)
				signText(plate, Enum.NormalId.Front, "HUNTER ASSOCIATION", Color3.fromRGB(28, 70, 160), Color3.fromRGB(240, 244, 255))
				signText(plate, Enum.NormalId.Back, "HUNTER ASSOCIATION", Color3.fromRGB(28, 70, 160), Color3.fromRGB(240, 244, 255))
				table.insert(Map.spawns, center + Vector3.new(0, 3, -inner * 0.35 - 6))
			elseif kind == "guild" then
				local b = building(center, inner * 0.7, inner * 0.7, 160, "glass")
				local crown = deco({ Name = "Crown", Size = Vector3.new(inner * 0.72, 6, inner * 0.72), Position = center + Vector3.new(0, 163, 0), Color = Color3.fromRGB(90, 160, 255), Material = Enum.Material.Neon }, b)
				local light = Instance.new("PointLight")
				light.Color = Color3.fromRGB(90, 160, 255)
				light.Range = 40
				light.Parent = crown
				local plate = deco({ Name = "GuildSign", Size = Vector3.new(30, 5, 0.4), Position = center + Vector3.new(0, 12, -inner * 0.35 - 0.6), Color = Color3.fromRGB(16, 20, 30) }, b)
				signText(plate, Enum.NormalId.Front, "GUILD TOWER", Color3.fromRGB(120, 190, 255))
			elseif kind == "park" then
				for _ = 1, 16 do
					tree(center + Vector3.new(rng:NextNumber(-40, 40), 0.6, rng:NextNumber(-40, 40)), rng:NextNumber(0.9, 1.5))
				end
				deco({ Name = "Path", Size = Vector3.new(8, 0.1, Map.BLOCK - 6), Position = center + Vector3.new(0, 0.64, 0), Color = Color3.fromRGB(170, 150, 120), Material = Enum.Material.Ground })
				addSite("park", "park", center + Vector3.new(0, 0.6, 0), "the park")
			elseif kind == "parking" then
				deco({ Name = "Lot", Size = Vector3.new(Map.BLOCK - 6, 0.1, Map.BLOCK - 6), Position = center + Vector3.new(0, 0.62, 0), Color = Color3.fromRGB(56, 58, 62), Material = Enum.Material.Asphalt })
				for row = -2, 2 do
					for col = -3, 3 do
						if rng:NextNumber() < 0.6 then
							car(center + Vector3.new(col * 12, 0.6, row * 18), if row % 2 == 0 then 0 else math.pi)
						end
						deco({ Name = "Line", Size = Vector3.new(0.4, 0.05, 14), Position = center + Vector3.new(col * 12 + 6, 0.68, row * 18), Color = Color3.fromRGB(230, 230, 230) })
					end
				end
				addSite("parking", "parking", center + Vector3.new(0, 0.6, 0), "the parking lot")
			elseif kind == "industrial" then
				for k = -1, 1, 2 do
					local w = building(center + Vector3.new(k * 24, 0, 10), 36, 50, 26)
					w.Name = "Warehouse"
				end
				for _ = 1, 10 do
					local cont = part({ Name = "Container", Size = Vector3.new(8, 8.5, 20), CFrame = CFrame.new(center + Vector3.new(rng:NextNumber(-40, 40), 4.9, rng:NextNumber(-48, -24))) * CFrame.Angles(0, rng:NextInteger(0, 1) * math.pi / 2, 0), Color = NEON[rng:NextInteger(1, #NEON)]:Lerp(Color3.new(0.3, 0.3, 0.3), 0.5), Material = Enum.Material.CorrodedMetal })
					local _ = cont
				end
				addSite("industrial", "industrial", center + Vector3.new(0, 0.6, -36), "the industrial yard")
			elseif kind == "construction" then
				for x = -1, 1 do
					deco({ Name = "Scaffold", Size = Vector3.new(1, 50, 1), Position = center + Vector3.new(x * 20, 25.6, 20), Color = Color3.fromRGB(200, 160, 40), Material = Enum.Material.Metal })
				end
				deco({ Name = "CraneMast", Size = Vector3.new(3, 90, 3), Position = center + Vector3.new(-30, 45.6, 30), Color = Color3.fromRGB(230, 180, 40), Material = Enum.Material.Metal })
				deco({ Name = "CraneJib", Size = Vector3.new(70, 3, 3), Position = center + Vector3.new(0, 90, 30), Color = Color3.fromRGB(230, 180, 40), Material = Enum.Material.Metal })
				part({ Name = "Pit", Size = Vector3.new(60, 1, 40), Position = center + Vector3.new(0, 0.7, -10), Color = Color3.fromRGB(120, 96, 70), Material = Enum.Material.Ground })
				for k = -2, 2 do
					deco({ Name = "Barrier", Size = Vector3.new(10, 3, 0.5), Position = center + Vector3.new(k * 11, 2, -Map.BLOCK / 2 + 4), Color = if k % 2 == 0 then Color3.fromRGB(240, 140, 30) else Color3.fromRGB(240, 240, 240) })
				end
				addSite("construction", "construction", center + Vector3.new(0, 1.2, -10), "the construction site")
			elseif kind == "station" then
				building(center + Vector3.new(0, 0, 18), inner, inner * 0.55, 46)
				local entrance = part({ Name = "SubwayEntrance", Size = Vector3.new(16, 8, 10), Position = center + Vector3.new(0, 4.6, -24), Color = Color3.fromRGB(40, 44, 52), Material = Enum.Material.Metal })
				local plate = deco({ Name = "SubwaySign", Size = Vector3.new(14, 2.6, 0.3), Position = center + Vector3.new(0, 10, -29.2), Color = Color3.fromRGB(30, 120, 70) })
				signText(plate, Enum.NormalId.Front, "SUBWAY", Color3.new(1, 1, 1), Color3.fromRGB(30, 120, 70))
				table.insert(Map.shelters, center + Vector3.new(0, 0.7, -30))
				local _ = entrance
				addSite("station", "station", center + Vector3.new(0, 0.6, -40), "the subway entrance")
			else
				-- ordinary blocks: two to four buildings
				local tall = kind == "residential_tall" or kind == "residential"
				local n = rng:NextInteger(2, 4)
				for b = 1, n do
					local w = inner / 2 - 2
					local dx = if b % 2 == 0 then w / 2 + 2 else -w / 2 - 2
					local dz = if b > 2 then w / 2 + 2 else -w / 2 - 2
					local h = if tall then rng:NextInteger(40, 110) else rng:NextInteger(24, 70)
					building(center + Vector3.new(dx, 0, dz), w, w, h, if rng:NextNumber() < 0.3 then "glass" else nil)
				end
				if kind == "residential" then
					addSite("residential_" .. i .. "_" .. j, "residential", center + Vector3.new(0, 0.6, 0), "an apartment courtyard")
				end
			end
		end
	end
	-- parked cars along some kerbs
	for _ = 1, 24 do
		local i, j = rng:NextInteger(0, Map.BLOCKS - 1), rng:NextInteger(0, Map.BLOCKS - 1)
		local c = Map.blockCenter(i, j)
		car(c + Vector3.new(Map.BLOCK / 2 + 4, 0, rng:NextNumber(-40, 40)), 0)
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "CitySpawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Position = Map.spawns[1] or Map.ORIGIN + Vector3.new(0, 2, 0)
	spawn.Parent = folder
	folder.Parent = parent
	return folder
end

return Map
