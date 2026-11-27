--[[
	CLOTH THAT SWINGS (BitLeveling): SmartBone-style bone physics for capes, robe tails and
	scarves made in Blender with bones (tools/blender: cape_skinned, scarf_skinned).

	Hunter/MeshLibrary lays a skinned cloth mesh over a cape and tags it the way SmartBone does
	(CollectionService tag "SmartBone", attribute "Roots" = its root bones). This finds every one
	and, each frame, runs its bone chains as a little rope of points: each point keeps its speed
	(so the cloth trails behind when its wearer runs or turns), falls under gravity, is blown by a
	gentle wind, springs back toward its resting shape, and stays its bone's length from the one
	above it. The root bones stay pinned to the part. The chain's bones are then turned (their
	Transform) to point along the rope.

	If the game also has SmartBone itself (ReplicatedStorage.SmartBone), this stands aside.
	Cloth further than 140 studs from the camera is left hanging still.

		ClothPhysics.start()                -- watch the tag (call once on the client)
		ClothPhysics.add(meshPart) -> sim   -- (also used by the tests)
		ClothPhysics.step(sim, dt, time)    -- one step of one cloth
]]

local ClothPhysics = {}

ClothPhysics.TAG = "SmartBone"
ClothPhysics.GRAVITY = Vector3.new(0, -60, 0)
ClothPhysics.DAMPING = 0.93 -- of the speed kept each frame
ClothPhysics.STIFFNESS = 0.03 -- the pull back toward the resting shape
ClothPhysics.WIND = 4
ClothPhysics.FAR = 140

-- the turn that takes direction a onto direction b (both unit)
local function between(a: Vector3, b: Vector3): CFrame
	local d = math.clamp(a:Dot(b), -1, 1)
	local axis = a:Cross(b)
	if axis.Magnitude < 1e-6 then
		if d > 0 then
			return CFrame.identity
		end
		local side = if math.abs(a.X) < 0.9 then Vector3.xAxis else Vector3.yAxis
		return CFrame.fromAxisAngle(a:Cross(side).Unit, math.pi)
	end
	return CFrame.fromAxisAngle(axis.Unit, math.acos(d))
end
ClothPhysics.between = between

local function chainsOf(part: BasePart): { { Bone } }
	local chains = {}
	local function down(b: Bone, chain: { Bone })
		table.insert(chain, b)
		local kids = {}
		for _, c in b:GetChildren() do
			if c:IsA("Bone") then
				table.insert(kids, c)
			end
		end
		if #kids == 0 then
			table.insert(chains, chain)
			return
		end
		for i, c in kids do
			down(c, if i == 1 then chain else table.clone(chain))
		end
	end
	for _, b in part:GetChildren() do
		if b:IsA("Bone") then
			down(b, {})
		end
	end
	return chains
end

-- a bone's resting place and turn, relative to the part (walking up through its parents)
local function restOf(part: BasePart, b: Bone): CFrame
	local cf = b.CFrame
	local p = b.Parent
	while p and p ~= part and p:IsA("Bone") do
		cf = p.CFrame * cf
		p = p.Parent
	end
	return cf
end

function ClothPhysics.add(part: BasePart): any
	local sim = { part = part, chains = {} }
	for _, bones in chainsOf(part) do
		local rest, pos, prev = {}, {}, {}
		for i, b in bones do
			rest[i] = restOf(part, b)
			local world = part.CFrame * rest[i].Position
			pos[i] = world
			prev[i] = world
		end
		-- the tip of the chain: one bone-length past the last joint, along the last bone
		local n = #bones
		local dir = if n >= 2 then (rest[n].Position - rest[n - 1].Position) else Vector3.new(0, -0.5, 0)
		local tipRest = rest[n].Position + dir
		table.insert(rest, CFrame.new(tipRest))
		local tipWorld = part.CFrame * tipRest
		table.insert(pos, tipWorld)
		table.insert(prev, tipWorld)
		local lengths = {}
		for i = 2, #rest do
			lengths[i] = (rest[i].Position - rest[i - 1].Position).Magnitude
		end
		table.insert(sim.chains, { bones = bones, rest = rest, pos = pos, prev = prev, lengths = lengths })
	end
	return sim
end

function ClothPhysics.step(sim: any, dt: number, t: number)
	local part = sim.part
	local cf = part.CFrame
	dt = math.clamp(dt, 1 / 240, 1 / 20)
	local wind = Vector3.new(math.sin(t * 1.3) + math.sin(t * 3.1) * 0.4, 0, math.cos(t * 0.9) * 0.6) * ClothPhysics.WIND
	for _, ch in sim.chains do
		local rest, pos, prev, lengths = ch.rest, ch.pos, ch.prev, ch.lengths
		local n = #pos
		-- the root is pinned to the part
		pos[1] = cf * rest[1].Position
		prev[1] = pos[1]
		for i = 2, n do
			local p = pos[i]
			local v = (p - prev[i]) * ClothPhysics.DAMPING
			prev[i] = p
			local np = p + v + (ClothPhysics.GRAVITY + wind) * dt * dt
			-- spring toward where it rests on the part
			local home = cf * rest[i].Position
			np = np:Lerp(home, ClothPhysics.STIFFNESS)
			-- keep the bone's length from the one above
			local d = np - pos[i - 1]
			local len = d.Magnitude
			if len > 1e-6 then
				np = pos[i - 1] + d * (lengths[i] / len)
			end
			-- don't swing through the body: stay behind the part's front face a little
			local loc = cf:PointToObjectSpace(np)
			if loc.Z < rest[i].Position.Z - 0.05 then
				np = cf * Vector3.new(loc.X, loc.Y, rest[i].Position.Z - 0.05)
			end
			pos[i] = np
		end
		-- turn each bone so it points along the rope
		local acc = CFrame.identity -- the turn already given to the bones above (part space)
		for i, b in ch.bones do
			local restDir = acc:VectorToWorldSpace(rest[i + 1].Position - rest[i].Position)
			local simDir = cf:VectorToObjectSpace(pos[i + 1] - pos[i])
			if restDir.Magnitude > 1e-6 and simDir.Magnitude > 1e-6 then
				local turn = between(restDir.Unit, simDir.Unit)
				local boneRot = acc * rest[i].Rotation
				b.Transform = boneRot:Inverse() * turn * boneRot
				acc = turn * acc
			end
		end
	end
end

local sims: { [BasePart]: any } = {}

function ClothPhysics.start()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	if ReplicatedStorage:FindFirstChild("SmartBone") then
		return -- the real SmartBone is in the game: it drives the cloth
	end
	local CollectionService = game:GetService("CollectionService")
	local RunService = game:GetService("RunService")
	local Workspace = game:GetService("Workspace")
	local function add(part: Instance)
		if part:IsA("BasePart") and not sims[part] then
			sims[part] = ClothPhysics.add(part)
		end
	end
	for _, p in CollectionService:GetTagged(ClothPhysics.TAG) do
		add(p)
	end
	CollectionService:GetInstanceAddedSignal(ClothPhysics.TAG):Connect(add)
	CollectionService:GetInstanceRemovedSignal(ClothPhysics.TAG):Connect(function(p)
		sims[p :: BasePart] = nil
	end)
	local t = 0
	RunService.RenderStepped:Connect(function(dt)
		t += dt
		local cam = Workspace.CurrentCamera
		local eye = if cam then cam.CFrame.Position else Vector3.zero
		for part, sim in sims do
			if not part.Parent then
				sims[part] = nil
			elseif (part.Position - eye).Magnitude < ClothPhysics.FAR then
				ClothPhysics.step(sim, dt, t)
			end
		end
	end)
end

return ClothPhysics
