--[[
	THE OPENING (BitLeveling): a raid party walks down a night street into a Gate.

	Played once when a player joins, before the menu (Skip ends it). A set is built far from
	everything else, client-only: a street of lit buildings, lamps, the police cordon with its
	light bars, the Association's van, people at the tape filming, and at the end of the street a
	Gate (client/GateVfx: the standing whirlpool). Five Hunters, built on the real R6 rig, walk
	to it in formation (a Tanker in front, a Fighter, a Mage, an Assassin, a Healer) and step in
	one at a time. The camera cuts between six shots, with letterbox bars and a line of text on
	each, and ends on the title.

		OpeningCutscene.play()   -- yields until it's over or skipped
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local GateVfx = require(script.Parent:WaitForChild("GateVfx"))

local OpeningCutscene = {}

local SET = Vector3.new(0, 0, 3000)
local GATE_Z = 150
local WALK = 5 -- studs a second
local LEAD_START = GATE_Z - WALK * 16.3 -- the leader reaches the Gate at 16.3 s

local LINES = {
	{ 0.6, 4.3, "About ten years ago, the Gates opened." },
	{ 4.8, 8.3, "Doors to somewhere else. Monsters on the other side." },
	{ 8.8, 12.3, "Then people began to wake up with power. The world calls them Hunters." },
	{ 12.8, 15.9, "Most raids are routine." },
	{ 16.4, 20.2, "Some aren't." },
}

local PARTY = {
	{ name = "Tanker", off = Vector3.new(0, 0, 0), look = { skin = "tan", face = "stern", top = "tactical", topColor = "charcoal", trim = "mana", bottom = "armored", bottomColor = "charcoal", shoes = "boots", armor = "heavy", armorColor = "slate", weapon = "shield", hair = 9243992729, hairDye = "jet", build = "broad" } },
	{ name = "Fighter", off = Vector3.new(-4.5, 0, -3), look = { skin = "warm", face = "focused", top = "leather", topColor = "black", trim = "mana", bottom = "cargo", bottomColor = "black", shoes = "boots", armor = "pauldrons", armorColor = "silver", weapon = "greatsword", hair = 376524487, hairDye = "jet" } },
	{ name = "Mage", off = Vector3.new(4.5, 0, -3), look = { skin = "fair", face = "calm", top = "robe", topColor = "navy", trim = "mana", bottom = "slacks", bottomColor = "black", shoes = "dress", armor = "cloak", armorColor = "navy", weapon = "staff", hair = 376526888, hairDye = "silver" } },
	{ name = "Assassin", off = Vector3.new(-2.2, 0, -7), look = { skin = "light", face = "fierce", top = "hoodie", topColor = "black", trim = "crimson", bottom = "joggers", bottomColor = "black", shoes = "sneakers", armor = "harness", armorColor = "brown", weapon = "dagger", hair = 3814474927, hairDye = "jet", extra = "mask", build = "slim" } },
	{ name = "Healer", off = Vector3.new(2.2, 0, -7), look = { skin = "porcelain", face = "soft", top = "coat", topColor = "white", trim = "teal", bottom = "slacks", bottomColor = "navy", shoes = "dress", armor = "none", weapon = "staff", hair = 451221329, hairDye = "chestnut", gloves = true, extra = "earpiece" } },
}

local function part(props: any, parent: Instance): BasePart
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end

local function at(x: number, y: number, z: number): Vector3
	return SET + Vector3.new(x, y, z)
end

local function buildSet(folder: Instance, R6Rig: any, Looks: any)
	local rng = Random.new(4242)
	part({ Size = Vector3.new(260, 1, 420), Position = at(0, -0.5, 110), Color = Color3.fromRGB(34, 36, 40), Material = Enum.Material.Asphalt }, folder)
	for _, side in { -1, 1 } do
		part({ Size = Vector3.new(14, 1.2, 420), Position = at(side * 19, 0, 110), Color = Color3.fromRGB(110, 110, 108), Material = Enum.Material.Concrete }, folder)
		-- buildings down both sides, windows lit
		for k = 0, 9 do
			local h = rng:NextInteger(30, 110)
			local w = rng:NextInteger(18, 26)
			local z = -20 + k * 26
			local c = at(side * (38 + w / 2 - 8), 0, z)
			part({ Size = Vector3.new(w, h, 22), Position = c + Vector3.new(0, h / 2, 0), Color = Color3.fromRGB(rng:NextInteger(40, 70), rng:NextInteger(44, 72), rng:NextInteger(52, 84)), Material = Enum.Material.Concrete }, folder)
			for f = 1, math.floor(h / 8) do
				if rng:NextNumber() < 0.7 then
					part({ Size = Vector3.new(0.3, 2.4, 18), Position = c + Vector3.new(-side * (w / 2 + 0.05), f * 8 - 3, 0), Color = if rng:NextNumber() < 0.75 then Color3.fromRGB(255, 214, 150) else Color3.fromRGB(150, 200, 255), Material = Enum.Material.Neon, Transparency = 0.2 }, folder)
				end
			end
			if rng:NextNumber() < 0.45 then
				local sign = part({ Size = Vector3.new(0.6, rng:NextInteger(10, 20), 2.4), Position = c + Vector3.new(-side * (w / 2 + 1.5), h * 0.45, 0), Color = ({ Color3.fromRGB(255, 70, 110), Color3.fromRGB(70, 200, 255), Color3.fromRGB(255, 190, 60), Color3.fromRGB(150, 110, 255) })[rng:NextInteger(1, 4)], Material = Enum.Material.Neon }, folder)
				local l = Instance.new("PointLight")
				l.Color = sign.Color
				l.Range = 14
				l.Parent = sign
			end
		end
		-- street lamps
		for k = 0, 7 do
			local base = at(side * 13, 0, -10 + k * 26)
			part({ Size = Vector3.new(0.5, 15, 0.5), Position = base + Vector3.new(0, 7.5, 0), Color = Color3.fromRGB(30, 30, 34), Material = Enum.Material.Metal }, folder)
			local head = part({ Size = Vector3.new(1.4, 0.4, 2), Position = base + Vector3.new(-side * 1.6, 15, 0), Color = Color3.fromRGB(255, 232, 190), Material = Enum.Material.Neon }, folder)
			local l = Instance.new("SpotLight")
			l.Face = Enum.NormalId.Bottom
			l.Range = 30
			l.Angle = 110
			l.Brightness = 2.4
			l.Color = Color3.fromRGB(255, 220, 170)
			l.Parent = head
		end
	end
	-- lane markings
	for z = -20, 240, 12 do
		part({ Size = Vector3.new(0.5, 0.05, 6), Position = at(0, 0.02, z), Color = Color3.fromRGB(220, 200, 110), Material = Enum.Material.Neon, Transparency = 0.4 }, folder)
	end
	-- the cordon: barricades, tape, police cars with light bars, the Association's van
	local bars = {}
	for k = -5, 5 do
		part({ Size = Vector3.new(3.4, 2, 0.4), Position = at(k * 3.6, 1.6, 118), Color = if k % 2 == 0 then Color3.fromRGB(240, 130, 30) else Color3.fromRGB(240, 240, 240) }, folder)
	end
	part({ Size = Vector3.new(40, 0.16, 0.05), Position = at(0, 2.5, 117.8), Color = Color3.fromRGB(250, 220, 40), Material = Enum.Material.Neon }, folder)
	for _, x in { -13, 13 } do
		local body = CFrame.new(at(x, 0, 122)) * CFrame.Angles(0, math.rad(if x < 0 then 25 else -25), 0)
		part({ Size = Vector3.new(6.4, 2.4, 13), CFrame = body * CFrame.new(0, 2, 0), Color = Color3.fromRGB(236, 236, 236) }, folder)
		part({ Size = Vector3.new(6.5, 0.8, 7), CFrame = body * CFrame.new(0, 2.2, 0), Color = Color3.fromRGB(20, 40, 110) }, folder)
		part({ Size = Vector3.new(5.8, 2, 7), CFrame = body * CFrame.new(0, 4.1, 0.6), Color = Color3.fromRGB(30, 40, 50), Material = Enum.Material.Glass, Transparency = 0.2 }, folder)
		for j, col in { Color3.fromRGB(255, 40, 40), Color3.fromRGB(40, 90, 255) } do
			local b = part({ Size = Vector3.new(1.6, 0.5, 0.9), CFrame = body * CFrame.new(j * 2 - 3, 5.3, 0.6), Color = col, Material = Enum.Material.Neon }, folder)
			local l = Instance.new("PointLight")
			l.Color = col
			l.Range = 22
			l.Brightness = 3
			l.Parent = b
			table.insert(bars, b)
		end
	end
	local van = CFrame.new(at(-15, 0, 100)) * CFrame.Angles(0, math.rad(90), 0)
	part({ Size = Vector3.new(7, 7, 16), CFrame = van * CFrame.new(0, 4, 0), Color = Color3.fromRGB(240, 242, 246) }, folder)
	part({ Size = Vector3.new(7.1, 1.2, 16.1), CFrame = van * CFrame.new(0, 3.2, 0), Color = Color3.fromRGB(28, 70, 160) }, folder)
	-- people at the tape, phones up
	local crowd = {}
	for k = 1, 8 do
		local look = Looks.random(function(a, b)
			return rng:NextInteger(a, b)
		end, { civilian = true })
		local m = R6Rig.build(look, { name = "Onlooker", npc = true, civilian = true })
		local x = (if k % 2 == 0 then 1 else -1) * (6 + rng:NextNumber() * 9)
		m:PivotTo(CFrame.lookAt(at(x, 3, 108 + rng:NextNumber() * 4), at(0, 3, GATE_Z)))
		for _, d in m:GetDescendants() do
			if d:IsA("BasePart") then
				d.Anchored = true
			end
		end
		local arm = m:FindFirstChild("Right Arm") :: BasePart?
		if arm and k % 3 ~= 0 then
			R6Rig.shell(m, arm, "Phone", Vector3.new(0.5, 0.9, 0.12), CFrame.new(0, -1.1, -0.4), Color3.fromRGB(20, 20, 24), Enum.Material.Glass)
		end
		m.Parent = folder
		table.insert(crowd, m)
	end
	return bars, crowd
end

local function letterbox(gui: ScreenGui): (Frame, Frame)
	local top = Instance.new("Frame")
	top.BackgroundColor3 = Color3.new(0, 0, 0)
	top.BorderSizePixel = 0
	top.Size = UDim2.fromScale(1, 0.11)
	top.Parent = gui
	local bottom = top:Clone()
	bottom.AnchorPoint = Vector2.new(0, 1)
	bottom.Position = UDim2.fromScale(0, 1)
	bottom.Parent = gui
	return top, bottom
end

-- the camera's six shots: f(t, partyZ) -> eye, target, fov
local function shot(t: number, leadZ: number, gateC: Vector3): (Vector3, Vector3, number)
	if t < 4.5 then
		local k = t / 4.5
		return at(0, 70 - 22 * k, -10 + 40 * k), gateC + Vector3.new(0, -4, 0), 55
	elseif t < 8.5 then
		local k = (t - 4.5) / 4
		return at(3 - k * 2, 1.4, leadZ - 11), gateC, 62
	elseif t < 12.5 then
		local k = (t - 8.5) / 4
		return at(-24, 4.5, leadZ + 2 + k * 2), at(0, 4, leadZ + 4), 48
	elseif t < 16 then
		local k = (t - 12.5) / 3.5
		return at(7 - k * 2, 1.5 + k, 124 + k * 4), gateC + Vector3.new(0, 1, 0), 52
	else
		local k = math.clamp((t - 16) / 4.5, 0, 1)
		local ease = k * k * (3 - 2 * k)
		local start = at(0, 6, LEAD_START + WALK * 16 - 16)
		local finish = gateC + Vector3.new(0, 0, -2)
		return start:Lerp(finish, ease * 0.92), gateC, 70 - 34 * ease
	end
end

function OpeningCutscene.play()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local shared = ReplicatedStorage:WaitForChild("LifeSim", 20)
	local hunter = shared and shared:WaitForChild("Hunter", 10)
	if not hunter then
		return
	end
	local R6Rig = require(hunter:WaitForChild("R6Rig"))
	local Looks = require(hunter:WaitForChild("Looks"))
	local hairCache = ReplicatedStorage:FindFirstChild("HunterHairCache")
	local camera = Workspace.CurrentCamera
	while not camera do
		task.wait()
		camera = Workspace.CurrentCamera
	end

	-- night, and a little fog
	local saved = { ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor }
	Lighting.ClockTime = 0.3
	Lighting.Brightness = 1.2
	Lighting.Ambient = Color3.fromRGB(40, 46, 70)
	Lighting.OutdoorAmbient = Color3.fromRGB(50, 56, 84)
	Lighting.FogStart = 120
	Lighting.FogEnd = 700
	Lighting.FogColor = Color3.fromRGB(14, 18, 34)
	local bloom = Instance.new("BloomEffect")
	bloom.Name = "OpeningBloom"
	bloom.Intensity = 1.1
	bloom.Size = 30
	bloom.Threshold = 0.85
	bloom.Parent = Lighting

	local folder = Instance.new("Folder")
	folder.Name = "OpeningCutscene"
	folder.Parent = Workspace
	local bars, _crowd = buildSet(folder, R6Rig, Looks)
	local gateC = at(0, 13, GATE_Z)
	local gate = GateVfx.new(folder, CFrame.new(gateC), 11.5, { rank = 4 })
	gate:open(0.1)

	-- the party: real R6 rigs, walking (the root slides, the walk animation plays)
	local party = {}
	for _, p in PARTY do
		local hair = nil
		if hairCache then
			local h = hairCache:FindFirstChild(tostring(p.look.hair))
			hair = h and h:Clone()
		end
		local m = R6Rig.build(p.look, { name = p.name, hair = hair })
		local root = m:FindFirstChild("HumanoidRootPart") :: BasePart
		root.Anchored = true
		m:PivotTo(CFrame.new(at(p.off.X, 3, LEAD_START + p.off.Z)))
		m.Parent = folder
		local hum = m:FindFirstChildOfClass("Humanoid")
		local animator = hum and hum:FindFirstChildOfClass("Animator")
		if animator then
			local anim = Instance.new("Animation")
			anim.AnimationId = R6Rig.ANIMS.walk
			local ok, track = pcall(function()
				return animator:LoadAnimation(anim)
			end)
			if ok and track then
				track.Looped = true
				track:Play(0)
				track:AdjustSpeed(0.75)
			end
		end
		table.insert(party, { model = m, root = root, off = p.off, inside = false })
	end

	-- the screen: letterbox bars, a line of text, Skip, and a white flash
	local gui = Instance.new("ScreenGui")
	gui.Name = "OpeningCutsceneGui"
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 100
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	local fade = Instance.new("Frame")
	fade.Size = UDim2.fromScale(1, 1)
	fade.BackgroundColor3 = Color3.new(0, 0, 0)
	fade.BorderSizePixel = 0
	fade.ZIndex = 5
	fade.Parent = gui
	letterbox(gui)
	local caption = Instance.new("TextLabel")
	caption.AnchorPoint = Vector2.new(0.5, 1)
	caption.Position = UDim2.new(0.5, 0, 0.87, -10)
	caption.Size = UDim2.new(0.8, 0, 0, 40)
	caption.BackgroundTransparency = 1
	caption.TextColor3 = Color3.fromRGB(230, 236, 255)
	caption.TextStrokeTransparency = 0.5
	caption.Font = Enum.Font.GothamMedium
	caption.TextScaled = true
	caption.Text = ""
	caption.TextTransparency = 1
	caption.ZIndex = 3
	caption.Parent = gui
	local skip = Instance.new("TextButton")
	skip.AnchorPoint = Vector2.new(1, 0)
	skip.Position = UDim2.new(1, -16, 0, 16)
	skip.Size = UDim2.fromOffset(110, 34)
	skip.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	skip.BackgroundTransparency = 0.2
	skip.TextColor3 = Color3.fromRGB(220, 226, 240)
	skip.Font = Enum.Font.GothamBold
	skip.TextSize = 15
	skip.Text = "SKIP  >"
	skip.ZIndex = 6
	skip.Parent = gui
	local corner = Instance.new("UICorner")
	corner.Parent = skip
	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.45)
	title.Size = UDim2.fromScale(0.7, 0.16)
	title.BackgroundTransparency = 1
	title.Text = "BITLEVELING"
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(150, 205, 255)
	title.TextTransparency = 1
	title.ZIndex = 7
	title.Parent = gui
	local sub = title:Clone()
	sub.Position = UDim2.fromScale(0.5, 0.58)
	sub.Size = UDim2.fromScale(0.6, 0.05)
	sub.Font = Enum.Font.GothamMedium
	sub.Text = "Not every Hunter is the hero of the story."
	sub.TextColor3 = Color3.fromRGB(200, 210, 230)
	sub.Parent = gui

	local done = false
	skip.Activated:Connect(function()
		done = true
	end)
	TweenService:Create(fade, TweenInfo.new(1.2), { BackgroundTransparency = 1 }):Play()

	camera.CameraType = Enum.CameraType.Scriptable
	local t = 0
	local flashed = false
	local conn = RunService.RenderStepped:Connect(function(dt)
		t += dt
		local leadZ = LEAD_START + WALK * t
		gate:step(dt)
		-- the party walks; at the Gate, each one steps in with a flash
		for _, m in party do
			if not m.inside then
				local z = leadZ + m.off.Z
				if z >= GATE_Z - 1 then
					m.inside = true
					GateVfx.flash(folder, m.root.Position + Vector3.new(0, 1, 2), Color3.fromRGB(190, 225, 255), 9, 0.5)
					gate:surge(1)
					m.model.Parent = nil
				else
					m.root.CFrame = CFrame.new(at(m.off.X, 3, z))
				end
			end
		end
		for k, b in bars do
			b.Transparency = if (math.floor(t * 6) + k) % 2 == 0 then 0 else 0.85
		end
		local eye, target, fov = shot(t, leadZ, gateC)
		camera.CFrame = CFrame.lookAt(eye, target)
		camera.FieldOfView = fov
		-- the line of text for this moment
		local text = ""
		for _, line in LINES do
			if t >= line[1] and t <= line[2] then
				text = line[3]
			end
		end
		if text ~= caption.Text then
			caption.Text = text
			caption.TextTransparency = 1
			TweenService:Create(caption, TweenInfo.new(0.4), { TextTransparency = if text == "" then 1 else 0 }):Play()
		end
		-- into the Gate: a white flash, then the title over black
		if t >= 20.4 and not flashed then
			flashed = true
			fade.BackgroundColor3 = Color3.new(1, 1, 1)
			fade.BackgroundTransparency = 1
			TweenService:Create(fade, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
			task.delay(0.35, function()
				TweenService:Create(fade, TweenInfo.new(0.6), { BackgroundColor3 = Color3.new(0, 0, 0) }):Play()
				TweenService:Create(title, TweenInfo.new(1), { TextTransparency = 0 }):Play()
				task.delay(0.6, function()
					TweenService:Create(sub, TweenInfo.new(1), { TextTransparency = 0 }):Play()
				end)
			end)
		end
		if t >= 25 then
			done = true
		end
	end)
	while not done do
		task.wait()
	end
	conn:Disconnect()
	-- out: fade the title, put the world back
	TweenService:Create(title, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
	TweenService:Create(sub, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
	fade.BackgroundColor3 = Color3.new(0, 0, 0)
	fade.BackgroundTransparency = 0
	task.wait(0.4)
	folder:Destroy()
	bloom:Destroy()
	for k, v in saved do
		(Lighting :: any)[k] = v
	end
	camera.FieldOfView = 70
	TweenService:Create(fade, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
	task.delay(0.9, function()
		gui:Destroy()
	end)
end

return OpeningCutscene
