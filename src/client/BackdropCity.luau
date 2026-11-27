--[[
	The City behind the UI (for the City pack). A ring of Districts around a dark centre.
	Each District has a Nest (glass towers around its Wing's headquarters, crowned in the
	Wing's color, inside a wall) and Backstreets (dense, dim blocks with a few warm windows,
	neon signs and steam). An elevated rail rings the whole city with a train of light on it.
	In a Nest the camera looks out over the city from high up; in the Backstreets it sits at
	street level with the towers looming over you.

	Same API as Backdrop:
		BackdropCity.build(districts)  -- districts: info.city.districts (color, backdrop)
		BackdropCity.setArea({ district, index, side, world, run, custom })
		BackdropCity.cinematic(on)
		BackdropCity.shot(name, cut)   -- the intro's camera shots (SHOTS below); cut = no glide
		BackdropCity.shake(amount)     -- a jolt of camera shake that dies away
	Client-only; built far from the origin; Config.backdrop = false turns it off.
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local BackdropCity = {}

local ORIGIN = Vector3.new(-6000, 0, 6000)
local NEST_R = 360 -- where each Nest's towers stand
local STREET_IN, STREET_OUT = 500, 1150 -- the Backstreets band
local RAIL_R, RAIL_Y = 760, 64

local GLASS = { Color3.fromRGB(58, 66, 82), Color3.fromRGB(44, 52, 66), Color3.fromRGB(70, 78, 92), Color3.fromRGB(36, 40, 50) }
local STREET_WALLS = { Color3.fromRGB(46, 42, 44), Color3.fromRGB(58, 50, 46), Color3.fromRGB(40, 44, 48), Color3.fromRGB(66, 58, 52), Color3.fromRGB(52, 50, 56) }
local STREET_MATERIALS = { Enum.Material.Concrete, Enum.Material.Brick, Enum.Material.CorrodedMetal, Enum.Material.Slate }
local WARM = Color3.fromRGB(255, 186, 112)
local COOL = Color3.fromRGB(196, 222, 255)
local SIGNS = { Color3.fromRGB(255, 70, 70), Color3.fromRGB(80, 255, 170), Color3.fromRGB(190, 110, 255), Color3.fromRGB(255, 190, 60), Color3.fromRGB(80, 190, 255) }

-- World events and expeditions regrade the scene while they last.
local OVERRIDES = {
	abnormality_breach = { tint = { 255, 130, 120 }, fog = { 120, 40, 40 }, contrast = 0.24, saturation = -0.1 },
	night_in_backstreets = { tint = { 150, 160, 255 }, fog = { 20, 20, 40 }, clock = 3, density = 0.5, contrast = 0.2 },
	thumb_crackdown = { tint = { 255, 190, 150 }, fog = { 90, 50, 40 }, contrast = 0.18 },
	distortion_sighting = { tint = { 220, 160, 255 }, fog = { 70, 40, 90 }, saturation = 0.1, contrast = 0.2 },
	library_appears = { tint = { 255, 236, 200 }, fog = { 140, 120, 90 }, brightness = 0.05 },
	dungeon = { tint = { 170, 210, 230 }, fog = { 30, 40, 60 }, clock = 2, density = 0.55 },
	containment = { tint = { 255, 150, 140 }, fog = { 110, 40, 40 }, contrast = 0.25 },
	trip = { tint = { 255, 240, 220 }, fog = { 160, 150, 150 }, clock = 7 },
	mission = { tint = { 214, 206, 240 }, fog = { 80, 70, 110 } },
}

-- The intro's shots: where the camera sits, how it drifts, and the light. A shot glides in
-- from the last one unless it's a cut.
local SHOTS = {
	-- 3:12 in the Backstreets: street level, the Nest towers looming over you, cold and dark
	alley = { index = 12, eyeR = 720, eyeY = 9, targetR = NEST_R, targetY = 230, drift = 0.006, tint = { 150, 164, 255 }, fog = { 18, 20, 40 }, clock = 3, density = 0.56, contrast = 0.24, saturation = -0.18, brightness = -0.06 },
	-- 3:13: the Night in the Backstreets
	night = { index = 12, eyeR = 640, eyeY = 7, targetR = 980, targetY = 26, drift = 0.003, tint = { 255, 96, 96 }, fog = { 72, 8, 18 }, clock = 3, density = 0.64, contrast = 0.34, saturation = -0.25, brightness = -0.04 },
	-- a Nest: high among the glass towers, bright and clean
	nest = { index = 3, eyeR = 300, eyeY = 240, targetR = 1100, targetY = 30, drift = 0.014, tint = { 232, 238, 255 }, fog = { 110, 112, 140 }, clock = 0.5, density = 0.3, contrast = 0.1, saturation = 0.04, brightness = 0.04 },
	-- District 12: Lobotomy Corporation, green under the city
	lcorp = { index = 5, eyeR = 540, eyeY = 46, targetR = NEST_R, targetY = 150, drift = 0.009, tint = { 150, 255, 176 }, fog = { 24, 64, 36 }, clock = 1, density = 0.46, contrast = 0.22, saturation = -0.06 },
	-- the Fingers' streets: violet neon
	fingers = { index = 8, eyeR = 860, eyeY = 18, targetR = 480, targetY = 90, drift = -0.008, tint = { 214, 150, 255 }, fog = { 50, 24, 70 }, clock = 2, density = 0.5, contrast = 0.22, saturation = 0.05 },
	-- the whole City from above, turning
	city = { orbit = true, speed = 0.05, eyeR = 60, eyeY = 470, targetR = 1000, targetY = 40, tint = { 255, 220, 188 }, fog = { 92, 64, 80 }, clock = 0.5, density = 0.36, contrast = 0.12 },
	-- the title: far out and low, the whole skyline gold
	title = { index = 1, eyeR = 1320, eyeY = 96, targetR = 0, targetY = 150, drift = 0.012, tint = { 255, 212, 156 }, fog = { 112, 70, 58 }, clock = 0.5, density = 0.4, contrast = 0.15, saturation = 0.04 },
}

local built = false
local count = 10
local train = {}

local function wedgeAngle(i: number): number
	return (i - 1) / count * math.pi * 2
end

local function at(a: number, r: number, y: number): Vector3
	return ORIGIN + Vector3.new(math.cos(a) * r, y, math.sin(a) * r)
end

function BackdropCity.build(districts)
	if built then
		return
	end
	built = true
	districts = districts or {}
	count = math.max(6, #districts)
	local rng = Random.new(1990)
	local folder = Instance.new("Folder")
	folder.Name = "LifeSimBackdrop"

	local function part(props)
		local p = Instance.new("Part")
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
	local function districtColor(i: number): Color3
		local d = districts[i]
		local c = d and d.color
		if c then
			return Color3.fromRGB(c[1], c[2], c[3])
		end
		return Color3.fromHSV((i - 1) / count, 0.55, 1)
	end

	-- ── light & air: a late, hazy night ──
	Lighting.ClockTime = 0.5
	Lighting.Brightness = 1.2
	Lighting.Ambient = Color3.fromRGB(34, 32, 44)
	Lighting.OutdoorAmbient = Color3.fromRGB(70, 64, 92)
	Lighting.EnvironmentDiffuseScale = 0.35
	Lighting.EnvironmentSpecularScale = 0.7
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = 0.36
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(110, 96, 130)
	atmosphere.Decay = Color3.fromRGB(70, 56, 90)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 2.4
	atmosphere.Parent = Lighting
	if not Lighting:FindFirstChild("LifeSimBloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "LifeSimBloom"
		bloom.Intensity = 0.8
		bloom.Size = 30
		bloom.Threshold = 0.9
		bloom.Parent = Lighting
	end

	-- ── the ground and the dark centre ──
	part({ Name = "Ground", Size = Vector3.new(2600, 4, 2600), CFrame = CFrame.new(ORIGIN + Vector3.new(0, -2, 0)), Color = Color3.fromRGB(18, 18, 22), Material = Enum.Material.Asphalt })
	part({ Name = "Centre", Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 420, 420), CFrame = CFrame.new(ORIGIN + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(10, 10, 14), Material = Enum.Material.Slate })
	-- the avenues between Districts
	for i = 1, count do
		local a = wedgeAngle(i) + math.pi / count
		local mid = at(a, 800, 0.4)
		part({ Size = Vector3.new(12, 0.4, 900), CFrame = CFrame.lookAt(mid, at(a, 1600, 0.4)), Color = Color3.fromRGB(30, 30, 36), Material = Enum.Material.Asphalt })
		-- street lights down the avenue
		for k = 0, 6 do
			local pos = at(a, 380 + k * 110, 7)
			part({ Size = Vector3.new(1.4, 1.4, 1.4), Shape = Enum.PartType.Ball, CFrame = CFrame.new(pos), Color = WARM, Material = Enum.Material.Neon })
		end
	end

	-- ── each District: a Nest and its Backstreets ──
	for i = 1, count do
		local a = wedgeAngle(i)
		local color = districtColor(i)
		local half = math.pi / count * 0.82

		-- the Nest: a wall, a headquarters tower and glass towers around it
		local hq = at(a, NEST_R, 0)
		local hqH = 300 + rng:NextNumber() * 90
		local hqW = 46 + rng:NextNumber() * 10
		local tower = part({
			Name = "Headquarters",
			Size = Vector3.new(hqW, hqH, hqW),
			CFrame = CFrame.lookAt(hq + Vector3.new(0, hqH / 2, 0), ORIGIN + Vector3.new(0, hqH / 2, 0)),
			Color = GLASS[1],
			Material = Enum.Material.Glass,
			Transparency = 0.05,
			Reflectance = 0.15,
		})
		-- the Wing's crown and light bands
		part({ Size = Vector3.new(hqW + 2, 5, hqW + 2), CFrame = tower.CFrame * CFrame.new(0, hqH / 2 - 8, 0), Color = color, Material = Enum.Material.Neon })
		for b = 1, 5 do
			part({ Size = Vector3.new(hqW + 0.6, 1.2, hqW + 0.6), CFrame = tower.CFrame * CFrame.new(0, -hqH / 2 + b * hqH / 6, 0), Color = COOL, Material = Enum.Material.Neon, Transparency = 0.35 })
		end
		part({ Size = Vector3.new(3, 50, 3), CFrame = tower.CFrame * CFrame.new(0, hqH / 2 + 25, 0), Color = Color3.fromRGB(60, 60, 70), Material = Enum.Material.Metal })
		part({ Shape = Enum.PartType.Ball, Size = Vector3.new(4, 4, 4), CFrame = tower.CFrame * CFrame.new(0, hqH / 2 + 52, 0), Color = Color3.fromRGB(255, 60, 60), Material = Enum.Material.Neon })
		for t = 1, 8 do
			local ta = a + (rng:NextNumber() - 0.5) * half * 1.4
			local tr = NEST_R + (rng:NextNumber() - 0.5) * 170
			local th = 110 + rng:NextNumber() * 170
			local tw = 22 + rng:NextNumber() * 20
			local pos = at(ta, tr, th / 2)
			if (pos - (hq + Vector3.new(0, th / 2, 0))).Magnitude > hqW + tw then
				local cf = CFrame.lookAt(pos, ORIGIN + Vector3.new(0, th / 2, 0)) * CFrame.Angles(0, rng:NextNumber() * 0.6, 0)
				local glass = part({ Size = Vector3.new(tw, th, tw * (0.8 + rng:NextNumber() * 0.6)), CFrame = cf, Color = GLASS[rng:NextInteger(1, #GLASS)], Material = Enum.Material.Glass, Reflectance = 0.1 })
				for b = 1, rng:NextInteger(2, 4) do
					part({ Size = Vector3.new(tw + 0.4, 0.9, glass.Size.Z + 0.4), CFrame = cf * CFrame.new(0, -th / 2 + b * th / 5, 0), Color = if rng:NextNumber() < 0.25 then color else COOL, Material = Enum.Material.Neon, Transparency = 0.4 })
				end
			end
		end
		-- the Nest wall: an arc of wall segments with a lit gate
		for k = -3, 3 do
			local wa = a + k * half / 3.2
			local pos = at(wa, NEST_R + 120, 9)
			part({ Size = Vector3.new(76, 18, 4), CFrame = CFrame.lookAt(pos, ORIGIN + Vector3.new(0, 9, 0)), Color = Color3.fromRGB(80, 82, 90), Material = Enum.Material.Concrete })
			if k == 0 then
				part({ Size = Vector3.new(18, 6, 4.4), CFrame = CFrame.lookAt(pos + Vector3.new(0, 3, 0), ORIGIN + Vector3.new(0, 12, 0)), Color = color, Material = Enum.Material.Neon })
			end
		end

		-- the Backstreets: dense, dim blocks
		for _ = 1, 70 do
			local ba = a + (rng:NextNumber() - 0.5) * half * 2
			local br = STREET_IN + rng:NextNumber() * (STREET_OUT - STREET_IN)
			local bh = 10 + rng:NextNumber() ^ 2 * 62
			local bw = 12 + rng:NextNumber() * 16
			local bd = 12 + rng:NextNumber() * 16
			local pos = at(ba, br, bh / 2)
			local cf = CFrame.lookAt(pos, ORIGIN + Vector3.new(0, bh / 2, 0)) * CFrame.Angles(0, (rng:NextNumber() - 0.5) * 0.4, 0)
			part({ Size = Vector3.new(bw, bh, bd), CFrame = cf, Color = STREET_WALLS[rng:NextInteger(1, #STREET_WALLS)], Material = STREET_MATERIALS[rng:NextInteger(1, #STREET_MATERIALS)] })
			-- a few warm windows facing the centre
			for _ = 1, rng:NextInteger(0, 3) do
				if rng:NextNumber() < 0.6 then
					local x = (rng:NextNumber() - 0.5) * (bw - 4)
					local y = -bh / 2 + 4 + rng:NextNumber() * math.max(1, bh - 8)
					part({ Size = Vector3.new(2, 2.4, 0.3), CFrame = cf * CFrame.new(x, y, -bd / 2 - 0.12), Color = WARM, Material = Enum.Material.Neon })
				end
			end
			-- now and then a neon sign
			if rng:NextNumber() < 0.16 then
				local sc = SIGNS[rng:NextInteger(1, #SIGNS)]
				part({ Size = Vector3.new(math.min(bw - 2, 8), 2.2, 0.4), CFrame = cf * CFrame.new(0, -bh / 2 + math.min(bh - 3, 10), -bd / 2 - 0.4), Color = sc, Material = Enum.Material.Neon })
			end
			-- rooftop tanks and pipes
			if rng:NextNumber() < 0.25 then
				part({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(5, 5, 5), CFrame = cf * CFrame.new(0, bh / 2 + 2.5, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(70, 62, 58), Material = Enum.Material.CorrodedMetal })
			end
		end
	end

	-- ── the rail: pillars and a ring track, with a train of light on it ──
	local segments = 48
	for k = 1, segments do
		local a0 = (k - 1) / segments * math.pi * 2
		local a1 = k / segments * math.pi * 2
		local p0, p1 = at(a0, RAIL_R, RAIL_Y), at(a1, RAIL_R, RAIL_Y)
		local mid = (p0 + p1) / 2
		part({ Size = Vector3.new(6, 3, (p1 - p0).Magnitude + 0.5), CFrame = CFrame.lookAt(mid, p1), Color = Color3.fromRGB(60, 62, 70), Material = Enum.Material.Metal })
		if k % 2 == 0 then
			part({ Size = Vector3.new(3, RAIL_Y, 3), CFrame = CFrame.new(at(a0, RAIL_R, RAIL_Y / 2)), Color = Color3.fromRGB(48, 48, 54), Material = Enum.Material.Concrete })
		end
	end
	train = {}
	for c = 1, 7 do
		local car = part({
			Name = "TrainCar",
			Size = Vector3.new(5, 4, 15),
			Color = if c == 1 then Color3.fromRGB(255, 240, 200) else Color3.fromRGB(150, 220, 255),
			Material = Enum.Material.Neon,
			CFrame = CFrame.new(at(c * 0.025, RAIL_R, RAIL_Y + 3.5)),
		})
		table.insert(train, car)
	end

	folder.Parent = Workspace

	-- ── light grading (tweened when the area changes) ──
	local grade = Lighting:FindFirstChild("LifeSimGrade") or Instance.new("ColorCorrectionEffect")
	grade.Name = "LifeSimGrade"
	grade.Parent = Lighting
	BackdropCity._grade = grade
	BackdropCity._atmosphere = atmosphere

	-- ── camera ──
	local camera = Workspace.CurrentCamera
	while not camera do
		task.wait()
		camera = Workspace.CurrentCamera
	end
	local cur = { angle = 0, eyeR = 160, eyeY = 220, targetR = 900, targetY = 60 }
	BackdropCity._view = { angle = 0, eyeR = 160, eyeY = 220, targetR = 900, targetY = 60, orbit = true }
	local clock = 0
	local trainAngle = 0
	RunService:BindToRenderStep("LifeSimBackdrop", Enum.RenderPriority.Camera.Value + 1, function(dt)
		-- (BitLeveling) walking the live city: the camera is the player's own
		if BackdropCity.paused then
			return
		end
		clock += dt
		local view = BackdropCity._view
		if view.orbit then
			view.angle += dt * (view.speed or 0.01)
		elseif view.drift then
			view.angle += dt * view.drift
		end
		if view.cut then
			view.cut = nil
			cur.angle, cur.eyeR, cur.eyeY, cur.targetR, cur.targetY = view.angle, view.eyeR, view.eyeY, view.targetR, view.targetY
		end
		local k = math.min(1, dt * (view.glide or 0.8))
		local da = (view.angle - cur.angle + math.pi) % (math.pi * 2) - math.pi
		cur.angle += da * k
		cur.eyeR += (view.eyeR - cur.eyeR) * k
		cur.eyeY += (view.eyeY - cur.eyeY) * k
		cur.targetR += (view.targetR - cur.targetR) * k
		cur.targetY += (view.targetY - cur.targetY) * k
		local sway = if view.orbit then 0 else math.sin(clock * 0.05) * 0.06
		local a = cur.angle + sway
		local eye = at(a - 0.05, cur.eyeR, cur.eyeY)
		local target = at(a, cur.targetR, cur.targetY)
		if (view.shake or 0) > 0.05 then
			local m = view.shake
			eye += Vector3.new((math.random() - 0.5) * m, (math.random() - 0.5) * m, (math.random() - 0.5) * m)
			view.shake = m * math.exp(-dt * 6)
		end
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 58
		camera.CFrame = CFrame.lookAt(eye, target)
		-- the train goes round
		trainAngle += dt * 0.045
		for c, car in train do
			local ca = trainAngle - c * 0.022
			local pos = at(ca, RAIL_R, RAIL_Y + 3.5)
			car.CFrame = CFrame.lookAt(pos, at(ca + 0.01, RAIL_R, RAIL_Y + 3.5))
		end
	end)
end

-- The intro: a slow sweep high over the whole city.
function BackdropCity.cinematic(on: boolean)
	if not built or not BackdropCity._view then
		return
	end
	local view = BackdropCity._view
	if on then
		view.orbit = true
		view.speed = 0.06
		view.eyeR = 60
		view.eyeY = 420
		view.targetR = 1000
		view.targetY = 40
	else
		view.speed = nil
	end
end

local function regrade(spec, seconds: number)
	local function color(t)
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	local info = TweenInfo.new(seconds, Enum.EasingStyle.Sine)
	pcall(function()
		TweenService:Create(Lighting, info, { ClockTime = spec.clock or 0.5 }):Play()
		if BackdropCity._grade then
			TweenService:Create(BackdropCity._grade, info, {
				TintColor = color(spec.tint or { 255, 255, 255 }),
				Brightness = spec.brightness or 0,
				Contrast = spec.contrast or 0.08,
				Saturation = spec.saturation or 0,
			}):Play()
		end
		if BackdropCity._atmosphere then
			TweenService:Create(BackdropCity._atmosphere, info, {
				Color = color(spec.fog or { 90, 64, 80 }),
				Density = spec.density or 0.36,
				Haze = spec.haze or 2.4,
			}):Play()
		end
	end)
end

-- One of the intro's shots (SHOTS). cut = jump there instead of gliding.
function BackdropCity.shot(name: string, cut: boolean?)
	local s = SHOTS[name]
	if not built or not BackdropCity._view or not s then
		return
	end
	local view = BackdropCity._view
	view.orbit = s.orbit == true
	view.speed = s.speed
	view.drift = s.drift
	view.glide = if cut then nil else 0.9
	if s.index then
		view.angle = wedgeAngle(((s.index - 1) % count) + 1)
	end
	view.eyeR, view.eyeY, view.targetR, view.targetY = s.eyeR, s.eyeY, s.targetR, s.targetY
	view.cut = cut == true
	regrade(s, if cut then 0.2 else 1.8)
end

function BackdropCity.shake(amount: number)
	if BackdropCity._view then
		BackdropCity._view.shake = amount
	end
end

-- Moves the view to a District and regrades the light.
-- area = { district, index, side = "charter" (the Nest) | "gutters" (the Backstreets), world, run, custom }
function BackdropCity.setArea(area)
	if not built or not BackdropCity._view then
		return
	end
	local index = ((area.index or 1) - 1) % count + 1
	local nest = area.side == "charter"
	local view = BackdropCity._view
	view.orbit = false
	view.speed = nil
	view.drift = nil
	view.glide = nil
	view.angle = wedgeAngle(index)
	if nest then
		-- high in the Nest, looking out over the city
		view.eyeR, view.eyeY, view.targetR, view.targetY = 280, 190, 1100, 40
	else
		-- down in the Backstreets, the towers looming over you
		view.eyeR, view.eyeY, view.targetR, view.targetY = 640, 14, NEST_R, 170
	end
	local base = area.custom or {}
	local over = (area.run and OVERRIDES[area.run]) or (area.world and OVERRIDES[area.world]) or {}
	local function color(t)
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	local tint = over.tint or base.tint or (if nest then { 236, 236, 255 } else { 255, 214, 200 })
	local fog = over.fog or base.fog or (if nest then { 110, 110, 140 } else { 90, 64, 80 })
	local info = TweenInfo.new(2.5, Enum.EasingStyle.Sine)
	pcall(function()
		TweenService:Create(Lighting, info, { ClockTime = over.clock or base.clock or 0.5 }):Play()
		if BackdropCity._grade then
			TweenService:Create(BackdropCity._grade, info, {
				TintColor = color(tint),
				Brightness = (over.brightness or 0) + (if nest then 0.04 else -0.04),
				Contrast = over.contrast or 0.08,
				Saturation = (over.saturation or 0) + (if nest then 0.02 else -0.08),
			}):Play()
		end
		if BackdropCity._atmosphere then
			TweenService:Create(BackdropCity._atmosphere, info, {
				Color = color(fog),
				Density = over.density or base.density or 0.36,
				Haze = (over.haze or base.haze or 2.4) + (if nest then -0.3 else 0.6),
			}):Play()
		end
	end)
end

return BackdropCity
