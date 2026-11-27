--[[
	THE PART LAYOUTS FOR BLENDER (tools/blender/kit.py reads this): every monster, every weapon and
	every outfit preset, built by the game's own builders on real Roblox instance types, as JSON:
	each part's name, role (Hunter/MeshLibrary.roleOf: the same function the game uses), size,
	CFrame (relative to the model's root, or to the right arm for a weapon), colour, material,
	shape and transparency.
		lune run tools/blender/dump_layout.luau        -> tools/blender/out/layout.json
]]

local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local Loader = require("../../tests/loader")
local I = roblox.Instance

Loader.globals = {
	Instance = I, NumberRange = roblox.NumberRange, NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
	ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint, UDim = roblox.UDim, UDim2 = roblox.UDim2,
	Vector2 = roblox.Vector2, Vector3 = roblox.Vector3, CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font,
}
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
-- (Monsters finds the mesh library through ReplicatedStorage.LifeSim)
Loader.globals.game = { GetService = function(_, name)
	if name == "ReplicatedStorage" then
		return { WaitForChild = function()
			return shared
		end, FindFirstChild = function()
			return nil
		end }
	end
	return {}
end }
local server = Loader.preload(Loader.node("src/server", "Server", nil))
local R6Rig = Loader.require(shared.Hunter.R6Rig)
local Looks = Loader.require(shared.Hunter.Looks)
local Weapons = Loader.require(shared.Hunter.Weapons)
local MeshLibrary = Loader.require(shared.Hunter.MeshLibrary)
local Monsters = Loader.require(server.HunterLive.Monsters)
-- (the layouts a place with the kit gets: one box for the head that holds ears, beard, horns or mane)
Monsters.MESH_LAYOUT = true

local function shapeOf(p): string
	if p:IsA("WedgePart") then
		return "Wedge"
	end
	if p:IsA("Part") then
		return tostring(p.Shape.Name)
	end
	return "Block"
end

local function partsOf(model, origin, gait, filter)
	local out = {}
	-- the limbs on joints (Motor6D Part1 -> the joint, in the root's space) and what rides on them
	local joints = {}
	for _, m in model:GetDescendants() do
		if m:IsA("Motor6D") and m.Part1 then
			local j = (origin:Inverse() * m.Part0.CFrame * m.C0).Position
			joints[m.Part1.Name] = { j.X, j.Y, j.Z }
		end
	end
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Name ~= "FacePlate" and (filter == nil or filter(p)) then
			local rel = origin:Inverse() * p.CFrame
			local c = { rel:GetComponents() }
			table.insert(out, {
				name = p.Name,
				role = MeshLibrary.roleOf(p, gait),
				size = { p.Size.X, p.Size.Y, p.Size.Z },
				cf = c,
				color = { math.floor(p.Color.R * 255 + 0.5), math.floor(p.Color.G * 255 + 0.5), math.floor(p.Color.B * 255 + 0.5) },
				material = p.Material.Name,
				shape = shapeOf(p),
				transparency = p.Transparency,
				-- a socket (one kit mesh drawn, without the kit, by its MeshCover parts) and the
				-- outfit detail a kit mesh already has (CoveredBy): the previews hide them as the game does
				meshId = p:GetAttribute("MeshId"),
				meshCover = p:GetAttribute("MeshCover"),
				coveredBy = p:GetAttribute("CoveredBy"),
				joint = joints[p.Name],
				follows = (function()
					local w = p:FindFirstChildOfClass("WeldConstraint")
					local base = w and w.Part0
					return if base and joints[base.Name] then base.Name else nil
				end)(),
			})
		end
	end
	return out
end

local layout = { monsters = {}, weapons = {}, rigs = {}, roles = MeshLibrary.ROLES }
for r = 1, 6 do
	for _, kind in Monsters.KINDS[r] do
		local model = Monsters.build(kind)
		local d = Monsters.DEFS[kind]
		table.insert(layout.monsters, { kind = kind, name = d.name, rank = r, gait = d.gait, parts = partsOf(model, model.PrimaryPart.CFrame, d.gait) })
	end
end
for _, w in Weapons.list do
	local rig = R6Rig.build({}, { weapon = { base = w.id, stars = 1 } })
	local arm = rig:FindFirstChild("Right Arm")
	table.insert(layout.weapons, { base = w.id, name = w.name, family = w.family, grade = w.grade, parts = partsOf(rig, arm.CFrame, nil, function(p)
		return string.sub(p.Name, 1, 6) == "Weapon"
	end) })
end
for _, p in Looks.PRESETS do
	local rig = R6Rig.build(Looks.applyPreset(Looks.DEFAULT, p.id), { rank = 4, weapon = false })
	table.insert(layout.rigs, { preset = p.id, name = p.name, parts = partsOf(rig, rig.PrimaryPart.CFrame, nil, function(part)
		return part.Transparency < 0.99
	end) })
end

if not fs.isDir("tools/blender/out") then
	fs.writeDir("tools/blender/out")
end
fs.writeFile("tools/blender/out/layout.json", serde.encode("json", layout, false))
local roled, total = 0, 0
for _, group in { layout.monsters, layout.weapons, layout.rigs } do
	for _, m in group do
		for _, p in m.parts do
			total += 1
			if p.role then
				roled += 1
			end
		end
	end
end
print(string.format("wrote tools/blender/out/layout.json: %d monsters, %d weapons, %d outfits; %d of %d parts have a mesh role", #layout.monsters, #layout.weapons, #layout.rigs, roled, total))
