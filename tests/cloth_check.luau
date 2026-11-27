--[[
	CLOTH THAT SWINGS (client/ClothPhysics) AND SKINNED KIT MESHES (Hunter/MeshLibrary), on real
	Roblox instance types:
		lune run tests/cloth_check
	  1. a cape's bones hang still when its wearer stands still (it settles near its rest shape)
	  2. when the wearer runs forward, the cape trails behind; when they stop, it swings back
	  3. a resized skinned mesh's bones move with it (fitBones)
	  4. a cape on a rig gets the skinned mesh, tagged for physics the way SmartBone expects
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")
local I = roblox.Instance
local CF, V3 = roblox.CFrame, roblox.Vector3

Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = V3, CFrame = CF,
	Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font, NumberRange = roblox.NumberRange,
	NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
	ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
}
local failures = 0
local function check(ok, msg)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		failures += 1
	end
end

local client = Loader.preload(Loader.node("src/client", "Client", nil))
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Cloth = Loader.require(client.ClothPhysics)
local MeshLibrary = Loader.require(shared.Hunter.MeshLibrary)
local R6Rig = Loader.require(shared.Hunter.R6Rig)
local Looks = Loader.require(shared.Hunter.Looks)

-- a cape: a MeshPart with three columns of four bones hanging from its top edge
local function cape(): any
	local m = I.new("MeshPart")
	m.Name = "cape_skinned"
	m.Size = V3.new(2, 3, 0.2)
	m.CFrame = CF.new(0, 5, 0)
	for _, x in { -0.7, 0, 0.7 } do
		local parent = m
		for k = 0, 3 do
			local b = I.new("Bone")
			b.Name = "b" .. k
			b.CFrame = if k == 0 then CF.new(x, 1.5, 0) else CF.new(0, -0.75, 0)
			b.Parent = parent
			parent = b
		end
	end
	return m
end
local function angleOf(cf)
	local _, ang = cf:ToAxisAngle()
	return math.deg(math.abs(ang))
end
local function maxAngle(m)
	local a = 0
	for _, d in m:GetDescendants() do
		if d:IsA("Bone") then
			a = math.max(a, angleOf(d.Transform))
		end
	end
	return a
end

-- 1. standing still
local m = cape()
local sim = Cloth.add(m)
check(#sim.chains == 3, "three bone chains found from the root bones")
local t = 0
for _ = 1, 240 do
	t += 1 / 60
	Cloth.step(sim, 1 / 60, t)
end
local still = maxAngle(m)
check(still < 25, string.format("standing still, the cape hangs near its rest shape (max bone turn %.1f deg)", still))

-- 2. running forward (-Z), then stopping
local tipBefore = sim.chains[2].pos[#sim.chains[2].pos]
for _ = 1, 60 do
	t += 1 / 60
	m.CFrame = m.CFrame * CF.new(0, 0, -0.4)
	Cloth.step(sim, 1 / 60, t)
end
local tip = sim.chains[2].pos[#sim.chains[2].pos]
local tipLocal = m.CFrame:PointToObjectSpace(tip)
check(tipLocal.Z > 0.3, string.format("running forward, the cape trails behind (tip %.2f studs back)", tipLocal.Z))
local running = maxAngle(m)
check(running > still + 5, string.format("its bones turn to follow (max %.1f deg)", running))
for _ = 1, 300 do
	t += 1 / 60
	Cloth.step(sim, 1 / 60, t)
end
check(maxAngle(m) < 25, "stopped, it swings back and settles")
local finite = true
for _, ch in sim.chains do
	for _, p in ch.pos do
		if p.X ~= p.X or math.abs(p.Y) > 1e6 then
			finite = false
		end
	end
end
check(finite and tipBefore ~= nil, "the simulation stays finite")

-- 3. fitBones: a skinned mesh made twice as wide moves its bones with it
local wide = cape()
MeshLibrary.fitBones(wide, V3.new(2, 3, 0.2), V3.new(4, 6, 0.2))
local root = wide:FindFirstChild("b0")
local rootX = nil
for _, b in wide:GetChildren() do
	if b:IsA("Bone") and b.CFrame.Position.X > 1 then
		rootX = b.CFrame.Position.X
	end
end
local child = root and root:FindFirstChild("b1")
check(rootX ~= nil and math.abs(rootX - 1.4) < 1e-3 and child and math.abs(child.CFrame.Position.Y + 1.5) < 1e-3, "a resized skinned mesh's bones scale with it")

-- 4. a cape on a rig gets the skinned mesh, tagged for physics
local kit = I.new("Model")
kit.Name = MeshLibrary.KIT_NAME
for _, role in MeshLibrary.ROLES do
	local tm = if role == "cape_skinned" then cape() else I.new("MeshPart")
	tm.Name = role
	tm.Parent = kit
end
MeshLibrary.setKit(kit)
local rig = R6Rig.build(Looks.applyPreset(Looks.DEFAULT, "striker"), { rank = 3 })
MeshLibrary.setKit(nil)
local capeMesh = nil
for _, d in rig:GetDescendants() do
	if d:IsA("MeshPart") and d:FindFirstChildWhichIsA("Bone") then
		capeMesh = d
	end
end
check(capeMesh ~= nil, "the rig's cape wears the skinned cloth (it has bones)")
local tagged = capeMesh and pcall(function()
	assert(capeMesh:HasTag("SmartBone"))
end)
check(capeMesh ~= nil and capeMesh:GetAttribute("Roots") ~= nil and tagged, "it's tagged for physics the way SmartBone expects (tag, Roots)")

if failures > 0 then
	process.exit(1)
end
print("\nCloth hangs, trails, swings back, and is tagged for physics.")
