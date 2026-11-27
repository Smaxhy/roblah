--[[
	THE LIVE CITY, CLIENT SIDE (BitLeveling). Draws what the server's live world is doing
	(server/HunterLive) and lets the player walk in it as their own R6 character.

	  Gates       a standing portal per incident, sized by rank: blue, swirling, lit; it turns
	              red if the raid seals it, pulses and cracks the street when it breaks, and
	              collapses when it closes. (Canon: ordinary Gates look blue; there is no colour
	              per rank. Only a Red Gate is named for its colour.)
	  Response    police tape and barricades, police cars with light bars and a siren, the
	              Association's van, Hunters walking in.
	  Fights      slashes, hits, kills and the player's own swings.
	  Walk mode   the life's UI steps aside, the camera follows your character, and a small HUD
	              shows your rank, health, the incidents near you, and what you can do:
	              Respond (the incident becomes a card in your life), Help (a frozen bystander),
	              Attack (Hunters only; F or click), Back to my life.
	  Dock        NEWS (the Hunter news board), WALK THE CITY, R6 LOOK (the creator).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Theme = require(script.Parent:WaitForChild("UI"):WaitForChild("Theme"))
local GateVfx = require(script.Parent:WaitForChild("GateVfx"))
local C, F = Theme.colors, Theme.fonts

local HunterLive = {
	walking = false,
	setWalking = nil :: ((boolean) -> ())?,
	call = nil :: any,
	toast = nil :: any,
}
local started = false

local BLUE = Color3.fromRGB(70, 150, 255)
local BLUE_DEEP = Color3.fromRGB(14, 26, 70)
local RED = Color3.fromRGB(255, 50, 50)
local RED_DEEP = Color3.fromRGB(70, 8, 10)
local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local PING = "rbxasset://sounds/electronicpingshort.wav"
local SLASH = "rbxasset://sounds/swordslash.wav"

local function v3(t: any): Vector3
	return Vector3.new(t[1], t[2], t[3])
end

local function make(className: string, props: any, parent: Instance?): any
	local inst = Instance.new(className)
	for k, v in props do
		(inst :: any)[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function fxPart(props: any, parent: Instance): BasePart
	props.Anchored = true
	props.CanCollide = false
	props.CanQuery = false
	props.CanTouch = false
	props.CastShadow = false
	props.TopSurface = Enum.SurfaceType.Smooth
	props.BottomSurface = Enum.SurfaceType.Smooth
	return make("Part", props, parent)
end

function HunterLive.start(opts: any?)
	if started then
		return
	end
	started = true
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local Shared = ReplicatedStorage:WaitForChild("LifeSim")
	local Config = require(Shared:WaitForChild("Config"))
	local Remotes = Shared:WaitForChild("Remotes")
	local Request = Remotes:WaitForChild("Request") :: RemoteFunction
	local Event = Remotes:WaitForChild("HunterLive", 30) :: RemoteEvent?
	if not Event then
		return -- not a BitLeveling server
	end
	local Hunter = Shared:WaitForChild("Hunter")
	local R6Rig = require(Hunter:WaitForChild("R6Rig"))
	local Backdrops = (opts and opts.backdrops) or {}

	local function call(action: string, payload: any?): any
		local ok, res = pcall(function()
			return Request:InvokeServer(action, payload)
		end)
		if not ok or type(res) ~= "table" then
			return nil
		end
		return res
	end
	HunterLive.call = call

	local fxRoot = make("Folder", { Name = "HunterLiveFx" }, Workspace)
	GateVfx.autoStep()
	local tint = Lighting:FindFirstChild("HunterLiveTint") or make("ColorCorrectionEffect", { Name = "HunterLiveTint", Enabled = true }, Lighting)

	-- ── the GUI: a dock on the left, the walk HUD, toasts ──
	local gui = make("ScreenGui", { Name = "HunterLiveGui", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 40, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, playerGui)
	local dock = make("Frame", { Name = "Dock", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(118, 150), BackgroundTransparency = 1 }, gui)
	make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, dock)
	local function dockButton(text: string, order: number, color: Color3, onClick: () -> ()): TextButton
		local b = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 40), LayoutOrder = order, BackgroundColor3 = C.panel, BackgroundTransparency = 0.08,
			AutoButtonColor = true, Text = text, TextColor3 = color, FontFace = F.display, TextSize = 15,
		}, dock)
		make("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
		make("UIStroke", { Color = color, Transparency = 0.45, Thickness = 1.4 }, b)
		b.Activated:Connect(onClick)
		return b
	end

	local toastHolder = make("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 70), Size = UDim2.fromOffset(520, 200), BackgroundTransparency = 1 }, gui)
	make("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center }, toastHolder)
	local function toast(text: string, color: Color3?)
		local t = make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.panel, BackgroundTransparency = 0.1,
			Text = text, TextWrapped = true, TextColor3 = color or C.text, FontFace = F.uiBold, TextSize = 15,
		}, toastHolder)
		make("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, t)
		make("UICorner", { CornerRadius = UDim.new(0, 6) }, t)
		make("UIStroke", { Color = color or C.accent, Transparency = 0.4 }, t)
		task.delay(5, function()
			TweenService:Create(t, TweenInfo.new(0.5), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
			task.wait(0.5)
			t:Destroy()
		end)
	end
	HunterLive.toast = toast

	-- ── gates ──
	local gates: { [number]: any } = {}
	local incidents: { any } = {}

	local function siren(g: any, on: boolean)
		if on and not g.siren then
			local s = make("Sound", { SoundId = PING, Looped = true, Volume = 0.25, RollOffMaxDistance = 260, RollOffMinDistance = 20 }, g.core)
			s:Play()
			g.siren = s
		elseif not on and g.siren then
			g.siren:Destroy()
			g.siren = nil
		end
	end

		return BLUE, BLUE_DEEP
	end

	local function policeCar(parent: Instance, pos: Vector3, yaw: number): { BasePart }
		local base = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
		fxPart({ Size = Vector3.new(6.4, 2.4, 13), CFrame = base * CFrame.new(0, 2, 0), Color = Color3.fromRGB(236, 236, 236) }, parent)
		fxPart({ Size = Vector3.new(6.5, 0.8, 7), CFrame = base * CFrame.new(0, 2.2, 0), Color = Color3.fromRGB(20, 40, 110) }, parent)
		fxPart({ Size = Vector3.new(5.8, 2, 7), CFrame = base * CFrame.new(0, 4.1, 0.6), Color = Color3.fromRGB(30, 40, 50), Material = Enum.Material.Glass, Transparency = 0.2 }, parent)
		local a = fxPart({ Size = Vector3.new(1.6, 0.5, 0.9), CFrame = base * CFrame.new(-1, 5.3, 0.6), Color = RED, Material = Enum.Material.Neon }, parent)
		local b = fxPart({ Size = Vector3.new(1.6, 0.5, 0.9), CFrame = base * CFrame.new(1, 5.3, 0.6), Color = Color3.fromRGB(40, 90, 255), Material = Enum.Material.Neon }, parent)
		make("PointLight", { Color = RED, Range = 18, Brightness = 3 }, a)
		make("PointLight", { Color = Color3.fromRGB(40, 90, 255), Range = 18, Brightness = 3 }, b)
		return { a, b }
	end

	local function cordon(g: any, radius: number)
		if g.cordon then
			return
		end
		local f = make("Folder", { Name = "Cordon" }, g.model)
		g.cordon = f
		local n = 14
		for k = 0, n - 1 do
			local a = k / n * math.pi * 2
			local p = g.pos + Vector3.new(math.cos(a) * radius, 1.6, math.sin(a) * radius)
			fxPart({ Size = Vector3.new(3.6, 2, 0.4), CFrame = CFrame.lookAt(p, g.pos) , Color = if k % 2 == 0 then Color3.fromRGB(240, 130, 30) else Color3.fromRGB(240, 240, 240) }, f)
			local a2 = (k + 0.5) / n * math.pi * 2
			local p2 = g.pos + Vector3.new(math.cos(a2) * radius, 2.4, math.sin(a2) * radius)
			fxPart({ Size = Vector3.new(radius * math.pi * 2 / n, 0.18, 0.05), CFrame = CFrame.lookAt(p2, g.pos) * CFrame.Angles(0, math.rad(90), 0), Color = Color3.fromRGB(250, 220, 40), Material = Enum.Material.Neon, Transparency = 0.15 }, f)
		end
		g.lightbars = {}
		for k, yaw in { 0.6, 2.4 } do
			local p = g.pos + Vector3.new(math.cos(yaw * k) * (radius + 9), 0, math.sin(yaw * k) * (radius + 9))
			for _, l in policeCar(f, p, yaw) do
				table.insert(g.lightbars, l)
			end
		end
	end

	local function van(g: any)
		if g.van then
			return
		end
		local f = make("Folder", { Name = "Van" }, g.model)
		g.van = f
		local base = CFrame.new(g.pos + Vector3.new(-g.size - 14, 0, 8)) * CFrame.Angles(0, math.rad(80), 0)
		local body = fxPart({ Size = Vector3.new(7, 7, 16), CFrame = base * CFrame.new(0, 4, 0), Color = Color3.fromRGB(240, 242, 246) }, f)
		fxPart({ Size = Vector3.new(7.1, 1.2, 16.1), CFrame = base * CFrame.new(0, 3.2, 0), Color = Color3.fromRGB(28, 70, 160) }, f)
		fxPart({ Size = Vector3.new(6.2, 2.4, 0.2), CFrame = base * CFrame.new(0, 5.6, -8.05), Color = Color3.fromRGB(30, 40, 52), Material = Enum.Material.Glass }, f)
		local gui = make("SurfaceGui", { Face = Enum.NormalId.Right, CanvasSize = Vector2.new(500, 200), LightInfluence = 0.3 }, body)
		make("TextLabel", { Size = UDim2.fromScale(1, 0.5), Position = UDim2.fromScale(0, 0.1), BackgroundTransparency = 1, Text = "HUNTER ASSOCIATION", TextColor3 = Color3.fromRGB(28, 70, 160), TextScaled = true, Font = Enum.Font.GothamBlack }, gui)
		make("TextLabel", { Size = UDim2.fromScale(1, 0.25), Position = UDim2.fromScale(0, 0.62), BackgroundTransparency = 1, Text = "GATE MEASUREMENT", TextColor3 = Color3.fromRGB(60, 70, 90), TextScaled = true, Font = Enum.Font.GothamBold }, gui)
		-- the measuring device on a tripod, aimed at the Gate
		local dev = fxPart({ Size = Vector3.new(1.4, 1, 1.8), CFrame = CFrame.lookAt(g.pos + Vector3.new(-g.size - 4, 4, 4), g.core.Position), Color = Color3.fromRGB(40, 44, 52), Material = Enum.Material.Metal }, f)
		fxPart({ Size = Vector3.new(0.2, 3.4, 0.2), CFrame = dev.CFrame * CFrame.new(0, -2.1, 0), Color = Color3.fromRGB(60, 60, 66) }, f)
		local lens = fxPart({ Size = Vector3.new(0.6, 0.6, 0.1), CFrame = dev.CFrame * CFrame.new(0, 0, -0.95), Color = Color3.fromRGB(90, 220, 140), Material = Enum.Material.Neon }, f)
		make("Beam", {
			Attachment0 = make("Attachment", {}, lens), Attachment1 = make("Attachment", {}, g.core),
			Color = ColorSequence.new(Color3.fromRGB(90, 220, 140)), Width0 = 0.15, Width1 = 0.6, Transparency = NumberSequence.new(0.4, 0.9), FaceCamera = true, LightEmission = 1,
		}, lens)
	end

	local function cracks(g: any)
		if g.cracks then
			return
		end
		local f = make("Folder", { Name = "Cracks" }, g.model)
		g.cracks = f
		local rng = Random.new(g.id * 31)
		for _ = 1, 8 + g.rank * 2 do
			local a = rng:NextNumber() * math.pi * 2
			local len = rng:NextNumber(8, 14 + g.rank * 6)
			local mid = g.pos + Vector3.new(math.cos(a) * len / 2, 0.08, math.sin(a) * len / 2)
			fxPart({ Size = Vector3.new(rng:NextNumber(0.4, 1.2), 0.06, len), CFrame = CFrame.lookAt(mid, g.pos + Vector3.new(0, 0.08, 0)), Color = Color3.fromRGB(255, 80, 40), Material = Enum.Material.Neon, Transparency = 0.25 }, f)
		end
	end

	local function buildGate(snap: any): any
		local pos = v3(snap.pos)
		local size = 8 + snap.rank * 3 + (if snap.rank >= 6 then 6 else 0)
		local model = make("Model", { Name = "Gate" .. snap.id }, fxRoot)
		local yaw = (snap.id * 1.7) % (math.pi * 2)
		-- the Gate stands on its edge, its face along the street, its bottom just off the ground
		local center = CFrame.new(pos + Vector3.new(0, size / 2 + 1.5, 0)) * CFrame.Angles(0, yaw, 0)
		local vfx = GateVfx.new(model, center, size / 2, { red = snap.red, rank = snap.rank })
		vfx:open(1.8)
		local core = vfx.core
		local g = { id = snap.id, rank = snap.rank, pos = pos, size = size, model = model, core = core, vfx = vfx, center = center, snap = snap }
		gates[snap.id] = g
		return g
	end

	local function recolor(g: any, snap: any)
		g.vfx:setRed(snap.red == true)
	end

	local function closeGate(g: any)
		gates[g.id] = nil
		siren(g, false)
		g.vfx:close(1.5)
		GateVfx.flash(fxRoot, g.center.Position, if g.snap.red then RED else BLUE, g.size * 1.6, 0.9)
		Debris:AddItem(g.model, 3)
	end

	local function apply(list: any)
		incidents = list or {}
		local seen = {}
		for _, snap in incidents do
			seen[snap.id] = true
			local g = gates[snap.id] or buildGate(snap)
			g.snap = snap
			recolor(g, snap)
			if snap.police then
				cordon(g, 24)
			end
			if snap.assoc then
				van(g)
			end
			if snap.broke or snap.stage == "escalated" then
				cracks(g)
			end
			siren(g, snap.stage == "discovered" or snap.stage == "response" or snap.stage == "escalated")
		end
		for id, g in gates do
			if not seen[id] then
				closeGate(g)
			end
		end
	end

	-- one-off effects the server calls for
	local function flash(at: Vector3, color: Color3, size: number, life: number)
		local p = fxPart({ Shape = Enum.PartType.Ball, Size = Vector3.one * size * 0.3, Position = at, Color = color, Material = Enum.Material.Neon, Transparency = 0.1 }, fxRoot)
		make("PointLight", { Color = color, Range = size * 3, Brightness = 4 }, p)
		TweenService:Create(p, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.one * size, Transparency = 1 }):Play()
		Debris:AddItem(p, life + 0.1)
	end
	local function arc(a: Vector3, b: Vector3, color: Color3, width: number)
		local mid = (a + b) / 2
		local len = (b - a).Magnitude
		if len < 0.1 then
			return
		end
		local p = fxPart({ Size = Vector3.new(width, 0.2, len), CFrame = CFrame.lookAt(mid, b) * CFrame.Angles(0, 0, math.rad(math.random(-60, 60))), Color = color, Material = Enum.Material.Neon, Transparency = 0.05 }, fxRoot)
		TweenService:Create(p, TweenInfo.new(0.25), { Transparency = 1, Size = Vector3.new(width * 2.5, 0.05, len) }):Play()
		Debris:AddItem(p, 0.3)
	end
	local shake = 0
	local function shakeNear(at: Vector3, amount: number, radius: number)
		local ch = player.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp and (hrp.Position - at).Magnitude < radius then
			shake = math.max(shake, amount)
		end
	end
	local function sound(id: string, at: Vector3, volume: number, pitch: number?)
		local p = fxPart({ Size = Vector3.one, Position = at, Transparency = 1 }, fxRoot)
		local s = make("Sound", { SoundId = id, Volume = volume, PlaybackSpeed = pitch or 1, RollOffMaxDistance = 200 }, p)
		s:Play()
		Debris:AddItem(p, 3)
	end

	local function onFx(d: any)
		local kind = d.fx
		if kind == "slash" then
			arc(v3(d.from) + Vector3.new(0, 3, 0), v3(d.to) + Vector3.new(0, 3, 0), Color3.fromRGB(160, 220, 255), 0.5)
			sound(SLASH, v3(d.to), 0.4, 0.9 + math.random() * 0.3)
		elseif kind == "hit" then
			flash(v3(d.to) + Vector3.new(0, 3, 0), Color3.fromRGB(255, 90, 70), 4 + (d.rank or 1), 0.3)
			if d.player == player.UserId then
				shake = math.max(shake, 0.6 + (d.rank or 1) * 0.25)
				TweenService:Create(tint, TweenInfo.new(0.06), { TintColor = Color3.fromRGB(255, 150, 150) }):Play()
				task.delay(0.15, function()
					TweenService:Create(tint, TweenInfo.new(0.4), { TintColor = Color3.new(1, 1, 1) }):Play()
				end)
			end
		elseif kind == "kill" then
			flash(v3(d.at) + Vector3.new(0, 2, 0), BLUE, 8 + (d.rank or 1) * 2, 0.5)
		elseif kind == "swing" then
			local at, dir = v3(d.at), v3(d.dir)
			local col = if d.hit then Color3.fromRGB(190, 230, 255) else Color3.fromRGB(120, 160, 220)
			local right = dir:Cross(Vector3.yAxis)
			arc(at - right * 3 + Vector3.new(0, 2.5, 0), at + right * 3 + Vector3.new(0, 1.5, 0), col, 0.4 + (d.rank or 1) * 0.15)
			if d.player == player.UserId then
				sound(SLASH, at, 0.5, 1 + math.random() * 0.2)
			end
		elseif kind == "enter" then
			flash(v3(d.at) + Vector3.new(0, 3, 0), BLUE, 6, 0.4)
			local g = gates[d.id]
			if g then
				g.vfx:surge(1)
			end
		elseif kind == "gateOpen" then
			local g = gates[d.id]
			if g then
				flash(g.core.Position, BLUE, g.size * 1.5, 0.8)
				g.vfx:surge(1.5)
				shakeNear(g.pos, 0.8, 120)
				sound(PING, g.core.Position, 0.6, 0.5)
			end
		elseif kind == "redGate" then
			local g = gates[d.id]
			if g then
				flash(g.core.Position, RED, g.size * 2, 1)
				shakeNear(g.pos, 1.2, 160)
			end
		elseif kind == "break" then
			local g = gates[d.id]
			if g then
				cracks(g)
				flash(g.core.Position, Color3.fromRGB(255, 110, 60), g.size * 2.4, 1.1)
				g.vfx:surge(2)
				shakeNear(g.pos, 2 + g.rank * 0.4, 220)
			end
		elseif kind == "siren" then
			local g = gates[d.id]
			if g then
				siren(g, d.on == true)
			end
		elseif kind == "cordon" then
			local g = gates[d.id]
			if g then
				cordon(g, d.radius or 24)
			end
		end
	end

	Event.OnClientEvent:Connect(function(d)
		if type(d) ~= "table" then
			return
		end
		if d.incidents then
			apply(d.incidents)
		end
		if d.fx then
			onFx(d)
		end
		if d.walk ~= nil and HunterLive.setWalking then
			HunterLive.setWalking(d.walk == true)
		end
	end)
	task.spawn(function()
		local res = call("hwLive")
		if res then
			apply(res.incidents)
		end
	end)

	-- animate: spin the swirls, flash the light bars, wail the sirens, shake, tint near danger
	local clock = 0
	RunService.RenderStepped:Connect(function(dt)
		clock += dt
		local cam = Workspace.CurrentCamera
		local nearRed, nearBreak = false, false
		local ch = player.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
		for _, g in gates do
			if g.snap.broke and math.random() < dt * 0.8 then
				g.vfx:surge(0.6) -- a broken Gate keeps heaving
			end
			for k, l in g.lightbars or {} do
				l.Transparency = if (math.floor(clock * 6) + k) % 2 == 0 then 0 else 0.85
			end
			if g.siren then
				g.siren.PlaybackSpeed = 0.75 + (math.sin(clock * 3.2) + 1) * 0.22
			end
			if hrp and (hrp.Position - g.pos).Magnitude < 180 then
				if g.snap.red then
					nearRed = true
				end
				if g.snap.broke then
					nearBreak = true
				end
			end
		end
		local target = if nearRed then Color3.fromRGB(255, 170, 170) elseif nearBreak then Color3.fromRGB(255, 220, 200) else Color3.new(1, 1, 1)
		tint.TintColor = tint.TintColor:Lerp(target, math.min(1, dt * 2))
		tint.Saturation = if nearRed then -0.15 else 0
		if shake > 0.02 and cam and HunterLive.walking then
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.CameraOffset = Vector3.new((math.random() - 0.5) * shake, (math.random() - 0.5) * shake, 0)
			end
			shake *= math.exp(-dt * 5)
		elseif ch then
			local hum = ch:FindFirstChildOfClass("Humanoid")
			if hum and hum.CameraOffset.Magnitude > 0 then
				hum.CameraOffset = Vector3.zero
			end
		end
	end)

	-- ── the local R6 character's animations ──
	local function animateCharacter(ch: Model)
		local hum = ch:WaitForChild("Humanoid", 5) :: Humanoid?
		if not hum then
			return
		end
		local animator = hum:FindFirstChildOfClass("Animator") or make("Animator", {}, hum)
		local tracks = {}
		for id, asset in R6Rig.ANIMS do
			local a = make("Animation", { AnimationId = asset })
			local ok, t = pcall(function()
				return animator:LoadAnimation(a)
			end)
			if ok and t then
				t.Looped = id ~= "jump"
				tracks[id] = t
			end
		end
		local current = nil
		local function play(id: string, speed: number?)
			local t = tracks[id]
			if not t then
				return
			end
			if current ~= t then
				if current then
					current:Stop(0.15)
				end
				t:Play(0.15)
				current = t
			end
			if speed then
				t:AdjustSpeed(speed)
			end
		end
		play("idle")
		hum.Running:Connect(function(speed)
			if speed > 0.6 then
				play("walk", math.clamp(speed / 14, 0.6, 2))
			else
				play("idle")
			end
		end)
		hum.StateChanged:Connect(function(_, new)
			if new == Enum.HumanoidStateType.Jumping then
				play("jump")
			elseif new == Enum.HumanoidStateType.Freefall then
				play("fall")
			elseif new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.Running then
				play("idle")
			end
		end)
	end
	player.CharacterAdded:Connect(function(ch)
		if ch:GetAttribute("HunterLive") or ch:WaitForChild("Humanoid", 3) then
			task.spawn(animateCharacter, ch)
			if HunterLive.walking then
				task.defer(function()
					local cam = Workspace.CurrentCamera
					local hum = ch:FindFirstChildOfClass("Humanoid")
					if cam and hum then
						cam.CameraType = Enum.CameraType.Custom
						cam.CameraSubject = hum
					end
				end)
			end
		end
	end)

	-- ── walk mode ──
	local hud = make("Frame", { Name = "WalkHud", Visible = false, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.fromOffset(560, 132), BackgroundColor3 = C.panel, BackgroundTransparency = 0.12 }, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, hud)
	make("UIStroke", { Color = C.accent, Transparency = 0.5 }, hud)
	local rankLabel = make("TextLabel", { Position = UDim2.fromOffset(14, 8), Size = UDim2.new(0.5, 0, 0, 22), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Text = "", TextColor3 = C.accentHi, FontFace = F.display, TextSize = 18 }, hud)
	local hpBack = make("Frame", { Position = UDim2.fromOffset(14, 34), Size = UDim2.new(1, -28, 0, 10), BackgroundColor3 = C.panelLo }, hud)
	make("UICorner", { CornerRadius = UDim.new(1, 0) }, hpBack)
	local hpFill = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(214, 96, 88) }, hpBack)
	make("UICorner", { CornerRadius = UDim.new(1, 0) }, hpFill)
	local nearLabel = make("TextLabel", { Position = UDim2.fromOffset(14, 50), Size = UDim2.new(1, -28, 0, 30), BackgroundTransparency = 1, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Text = "The city is quiet.", TextColor3 = C.sub, FontFace = F.uiMedium, TextSize = 14 }, hud)
	local row = make("Frame", { Position = UDim2.new(0, 14, 1, -46), Size = UDim2.new(1, -28, 0, 38), BackgroundTransparency = 1 }, hud)
	make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8) }, row)
	local function hudButton(text: string, color: Color3, onClick: () -> ()): TextButton
		local b = make("TextButton", { Size = UDim2.fromOffset(124, 38), BackgroundColor3 = color, Text = text, TextColor3 = Color3.new(1, 1, 1), FontFace = F.display, TextSize = 15, AutoButtonColor = true }, row)
		make("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
		b.Activated:Connect(onClick)
		return b
	end
	local nearest: any = nil
	local respondBtn = hudButton("RESPOND", C.crimson, function()
		if nearest then
			local res = call("hwRespond", { id = nearest.id })
			if res and res.ok == false and res.error then
				toast(res.error, C.crimsonHi)
			end
		end
	end)
	local _helpBtn = hudButton("HELP [E]", Color3.fromRGB(60, 130, 90), function()
		local res = call("hwHelp")
		if res then
			toast(res.toast or res.error or "", if res.ok then C.good else C.sub)
		end
	end)
	local attackBtn = hudButton("ATTACK [F]", Color3.fromRGB(40, 90, 200), function()
		Event:FireServer("attack")
	end)
	hudButton("BACK TO LIFE", C.panelHi, function()
		call("hwWalk", { on = false })
	end)

	local hidden: { ScreenGui } = {}
	local savedLighting: any = nil
	function HunterLive.setWalking(on: boolean)
		if on == HunterLive.walking then
			return
		end
		HunterLive.walking = on
		hud.Visible = on
		for _, b in Backdrops do
			b.paused = on
		end
		if on then
			table.clear(hidden)
			for _, g in playerGui:GetChildren() do
				if g:IsA("ScreenGui") and g ~= gui and string.sub(g.Name, 1, 7) == "LifeSim" and g.Enabled then
					g.Enabled = false
					table.insert(hidden, g)
				end
			end
			savedLighting = { ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart }
			Lighting.ClockTime = 17.4
			Lighting.Brightness = 2
			Lighting.FogStart = 200
			Lighting.FogEnd = 1400
			local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
			if atmo then
				savedLighting.density = atmo.Density
				atmo.Density = 0.3
			end
			local cam = Workspace.CurrentCamera
			local ch = player.Character
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if cam then
				cam.CameraType = Enum.CameraType.Custom
				if hum then
					cam.CameraSubject = hum
				end
				cam.FieldOfView = 70
			end
			toast("You're in the city. Gates can open anywhere, at any time.", C.accentHi)
		else
			for _, g in hidden do
				g.Enabled = true
			end
			table.clear(hidden)
			if savedLighting then
				Lighting.ClockTime = savedLighting.ClockTime
				Lighting.Brightness = savedLighting.Brightness
				Lighting.FogEnd = savedLighting.FogEnd
				Lighting.FogStart = savedLighting.FogStart
				local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
				if atmo and savedLighting.density then
					atmo.Density = savedLighting.density
				end
			end
		end
	end

	-- the HUD keeps up with you
	task.spawn(function()
		while true do
			task.wait(0.25)
			if HunterLive.walking then
				local ch = player.Character
				local hum = ch and ch:FindFirstChildOfClass("Humanoid")
				local hrp = ch and ch:FindFirstChild("HumanoidRootPart") :: BasePart?
				if hum and hrp then
					local rank = ch:GetAttribute("Rank") or 0
					rankLabel.Text = if rank > 0 then (({ "E", "D", "C", "B", "A", "S" })[rank] .. "-RANK HUNTER") else "UNAWAKENED CIVILIAN"
					attackBtn.Visible = rank > 0
					hpFill.Size = UDim2.fromScale(math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1), 1)
					local best, bd = nil, 160
					for _, snap in incidents do
						local d = (v3(snap.pos) - hrp.Position).Magnitude
						if d < bd then
							best, bd = snap, d
						end
					end
					nearest = best
					respondBtn.Visible = best ~= nil
					if best then
						local what = if best.broke then "DUNGEON BREAK" elseif best.red then "RED GATE" else "Gate"
						nearLabel.Text = string.format("%s · %s-rank reading · %s · %dm away · %s", what, ({ "E", "D", "C", "B", "A", "S" })[best.rank] or "?", best.label or "", math.floor(bd), best.headline or "")
						nearLabel.TextColor3 = if best.broke or best.red then C.crimsonHi else C.text
					else
						nearLabel.Text = "The city is quiet. Gates can open anywhere."
						nearLabel.TextColor3 = C.sub
					end
				end
			end
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not HunterLive.walking then
			return
		end
		if input.KeyCode == Enum.KeyCode.F or input.UserInputType == Enum.UserInputType.MouseButton1 then
			local ch = player.Character
			if ch and (ch:GetAttribute("Rank") or 0) > 0 then
				Event:FireServer("attack")
			end
		elseif input.KeyCode == Enum.KeyCode.E then
			local res = call("hwHelp")
			if res and (res.toast or res.error) then
				toast(res.toast or res.error, if res.ok then C.good else C.sub)
			end
		end
	end)

	-- ── the dock ──
	local Board = require(script.Parent:WaitForChild("UI"):WaitForChild("HunterBoard"))
	local Creator = require(script.Parent:WaitForChild("UI"):WaitForChild("R6Creator"))
	dockButton("NEWS", 1, C.accentHi, function()
		Board.open(gui, call, incidents)
	end)
	dockButton("WALK THE CITY", 2, Color3.fromRGB(120, 210, 160), function()
		if HunterLive.walking then
			call("hwWalk", { on = false })
		else
			local res = call("hwWalk", { on = true })
			if not res or res.ok == false then
				toast((res and res.error) or "The city isn't open right now.", C.crimsonHi)
			end
		end
	end)
	dockButton("R6 LOOK", 3, Color3.fromRGB(200, 170, 255), function()
		Creator.open(gui, call, R6Rig)
	end)
	-- admins (and anyone testing in Studio) can open a Gate on demand
	task.spawn(function()
		local res = call("adminState")
		if res and res.ok then
			local rank = 3
			dockButton("TEST GATE", 4, C.crimsonHi, function()
				local r = call("hwAdminSpawn", { rank = rank })
				toast((r and (r.toast or r.error)) or "No answer.", if r and r.ok then C.accentHi else C.crimsonHi)
				rank = rank % 6 + 1
			end)
			dockButton("TEST BREAK", 5, C.crimson, function()
				local r = call("hwAdminSpawn", { rank = math.random(1, 4), breaks = true })
				toast((r and (r.toast or r.error)) or "No answer.", if r and r.ok then C.accentHi else C.crimsonHi)
			end)
			dockButton("TEST RED GATE", 6, Color3.fromRGB(200, 40, 40), function()
				local r = call("hwAdminSpawn", { rank = math.random(2, 4), kind = "red" })
				toast((r and (r.toast or r.error)) or "No answer.", if r and r.ok then C.accentHi else C.crimsonHi)
			end)
			dock.Size = UDim2.fromOffset(118, 290)
		end
	end)
	local _ = Config
end

return HunterLive
