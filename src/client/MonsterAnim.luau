--[[
	THE LIVE CITY'S MONSTERS, ANIMATED ON THE CLIENT (BitLeveling).

	The server builds each monster (server/HunterLive/Monsters) with Motor6D joints from its root
	to every limb that moves, and tags the model with a Gait. Here, every frame, each monster near
	the camera gets its joints' Transform set from how fast it is moving and what its gait is:

	  biped     arms and legs swing opposite, a heavier sway when it's big; a swing when it attacks
	  quad      a trot (diagonal pairs), the tail wags
	  crawler   six or eight legs ripple front to back (beetles)
	  spider    eight legs ripple in alternating fours, splayed
	  flyer     wings beat (faster when it moves), the tail trails
	  float     a slow bob and the arms drift (wraiths)
	  serpent   the body segments wave down their length
	  blob      a squash and stretch (slimes)
	  golem     slow, heavy steps with a shoulder roll

	Nothing here touches the server: Transform is local, so it costs no network. Monsters further
	than ~260 studs from the camera are left still.
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local MonsterAnim = {}

local FAR = 260
local tracked: { [Model]: any } = setmetatable({}, { __mode = "k" }) :: any

local function rig(model: Model): any?
	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return nil
	end
	local joints = {}
	for _, d in root:GetChildren() do
		if d:IsA("Motor6D") then
			joints[(string.gsub(d.Name, "Joint$", ""))] = d
		end
	end
	return {
		root = root,
		joints = joints,
		gait = model:GetAttribute("Gait") or "biped",
		phase = math.random() * 10,
		lastAttack = 0,
		size = math.max(0.6, root.Size.Y / 2),
	}
end

local function set(j: Motor6D?, cf: CFrame)
	if j then
		j.Transform = cf
	end
end

local rx, ry, rz = CFrame.Angles, function(a)
	return CFrame.Angles(0, a, 0)
end, function(a)
	return CFrame.Angles(0, 0, a)
end
local function pitch(a)
	return rx(a, 0, 0)
end

local function animate(r: any, dt: number, t: number)
	-- speed from how far the root moved since last frame (works however the server moves it)
	local pos = r.root.CFrame.Position
	local last = r.lastPos or pos
	r.lastPos = pos
	local step = Vector3.new(pos.X - last.X, 0, pos.Z - last.Z).Magnitude
	r.speed = (r.speed or 0) + ((if dt > 0 then step / dt else 0) - (r.speed or 0)) * math.min(1, dt * 8)
	local speed = math.min(r.speed, 40)
	local moving = math.clamp(speed / 12, 0, 1)
	local cadence = (3 + speed * 0.35) / math.sqrt(r.size)
	r.phase += dt * cadence
	local p = r.phase
	local j = r.joints
	local gait = r.gait
	-- an attack (the server sets Attacking on the model for a moment): a big forward swing
	local swing = 0
	local since = t - r.lastAttack
	if since < 0.45 then
		swing = math.sin(since / 0.45 * math.pi)
	end

	if gait == "biped" or gait == "golem" then
		local amp = (if gait == "golem" then 0.35 else 0.7) * moving
		local legs = math.sin(p) * amp
		set(j.LegR, pitch(legs))
		set(j.LegL, pitch(-legs))
		local idle = math.sin(t * 1.6 + r.phase * 0.05) * 0.05
		set(j.ArmR, pitch(-legs * 0.8 - swing * 1.9 + idle))
		set(j.ArmL, pitch(legs * 0.8 + idle))
		if gait == "golem" then
			set(j.ArmR, pitch(-legs * 0.6 - swing * 1.4) * rz(math.sin(p) * 0.08))
			set(j.ArmL, pitch(legs * 0.6) * rz(math.sin(p) * 0.08))
		end
		set(j.Tail, ry(math.sin(t * 2.4) * 0.35))
	elseif gait == "quad" then
		local amp = 0.75 * moving + 0.03
		for k = 1, 4 do
			local diag = if k % 2 == 0 then 0 else math.pi
			set(j["LegR" .. k], pitch(math.sin(p + diag) * amp))
			set(j["LegL" .. k], pitch(math.sin(p + diag + math.pi) * amp))
		end
		set(j.Tail, ry(math.sin(t * (4 + speed * 0.3)) * 0.45) * pitch(-0.25 + swing * 0.4))
	elseif gait == "crawler" or gait == "spider" then
		local amp = (if gait == "spider" then 0.5 else 0.4) * moving + 0.03
		for k = 1, 4 do
			local off = k * 1.3
			set(j["LegR" .. k], rz(math.sin(p * 1.4 + off) * amp) * ry(math.cos(p * 1.4 + off) * amp * 0.6))
			set(j["LegL" .. k], rz(-math.sin(p * 1.4 + off + math.pi) * amp) * ry(math.cos(p * 1.4 + off + math.pi) * amp * 0.6))
		end
		set(j.Tail, ry(math.sin(t * 3) * 0.2))
	elseif gait == "flyer" then
		local beat = math.sin(t * (6 + moving * 5) + r.phase * 0.1)
		set(j.WingR, rz(beat * 0.75))
		set(j.WingL, rz(-beat * 0.75))
		set(j.Tail, ry(math.sin(t * 2.2) * 0.3) * pitch(math.sin(t * 1.7) * 0.15))
		set(j.LegR, pitch(0.5))
		set(j.LegL, pitch(0.5))
	elseif gait == "float" then
		local drift = math.sin(t * 1.3 + r.phase * 0.1)
		set(j.ArmR, pitch(-0.35 + drift * 0.18 - swing * 1.5) * rz(0.12))
		set(j.ArmL, pitch(-0.35 - drift * 0.18) * rz(-0.12))
	elseif gait == "blob" then
		-- the glowing nucleus bobs and turns inside the jelly
		set(j.Nucleus, CFrame.new(math.sin(t * 1.7) * 0.25, math.sin(t * (3 + moving * 4) + r.phase) * 0.3, math.cos(t * 1.3) * 0.25) * ry(t * 1.5))
	elseif gait == "serpent" then
		for k = 1, 8 do
			local seg = j["Seg" .. k]
			if not seg then
				break
			end
			set(seg, ry(math.sin(t * (2.2 + moving * 2.5) - k * 0.75) * (0.18 + k * 0.03)) * pitch(math.sin(t * 1.1 - k * 0.5) * 0.05))
		end
		set(j.ArmR, pitch(math.sin(p) * 0.4 * moving - swing * 1.5))
		set(j.ArmL, pitch(-math.sin(p) * 0.4 * moving))
	end
end

-- the server marks an attack with the Attacking attribute (a tick count); a change starts a swing
local function watchAttacks(model: Model, r: any)
	model:GetAttributeChangedSignal("Attacking"):Connect(function()
		r.lastAttack = os.clock()
	end)
end

function MonsterAnim.start(folderName: string?)
	local folder: Instance? = nil
	local function find()
		local world = Workspace:FindFirstChild(folderName or "BitLevelingLive")
		folder = world and world:FindFirstChild("LiveNPCs")
	end
	RunService.RenderStepped:Connect(function(dt)
		if not folder or not folder.Parent then
			find()
			if not folder then
				return
			end
		end
		local cam = Workspace.CurrentCamera
		local eye = cam and cam.CFrame.Position or Vector3.zero
		local t = os.clock()
		for _, model in (folder :: Instance):GetChildren() do
			if model:IsA("Model") and model:GetAttribute("Gait") then
				local r = tracked[model]
				if r == nil then
					r = rig(model) or false
					tracked[model] = r
					if r then
						watchAttacks(model, r)
					end
				end
				if r and (r.root.CFrame.Position - eye).Magnitude < FAR then
					animate(r, dt, t)
				end
			end
		end
	end)
end

MonsterAnim.animate = animate -- for tests
MonsterAnim.rig = rig

return MonsterAnim
