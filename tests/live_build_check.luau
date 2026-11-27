--[[
	Builds the live city (server/HunterLive/Map.luau), civilians, responders and every monster
	rank (server/HunterLive/Npcs.luau) on @lune/roblox instances: every class and property name
	is checked against Roblox's real API, without Studio.
		lune run tests/live_build_check
]]
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")
local I = roblox.Instance

local RandomStub = {}
RandomStub.__index = RandomStub
function RandomStub.new(seed)
	return setmetatable({ s = (seed or 1) % 2147483647 + 1 }, RandomStub)
end
function RandomStub:NextNumber(a, b)
	self.s = (self.s * 48271) % 2147483647
	local r = self.s / 2147483647
	return (a or 0) + r * ((b or 1) - (a or 0))
end
function RandomStub:NextInteger(a, b)
	return a + math.floor(self:NextNumber() * (b - a + 1))
end

local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local players = { GetPlayers = function()
	return {}
end }
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font, Random = RandomStub,
	ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, NumberRange = roblox.NumberRange,
	game = { GetService = function(_, name)
		if name == "ReplicatedStorage" then
			return { WaitForChild = function()
				return shared
			end }
		elseif name == "Players" then
			return players
		end
		return {}
	end },
}
local server = Loader.preload(Loader.node("src/server", "Server", nil))
local Map = Loader.require(server.HunterLive.Map)
local Npcs = Loader.require(server.HunterLive.Npcs)

local failures = 0
local function check(ok, msg)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		failures += 1
	end
end

local root = I.new("Folder")
local okMap, city = pcall(Map.build, root)
check(okMap, "the city builds" .. (if okMap then "" else ": " .. tostring(city)))
if okMap then
	local parts = 0
	for _, d in city:GetDescendants() do
		if d:IsA("BasePart") then
			parts += 1
		end
	end
	print(string.format("        %d parts, %d Gate sites, %d sidewalk waypoints, %d shelters, %d spawns", parts, #Map.sites, #Map.waypoints, #Map.shelters, #Map.spawns))
	check(#Map.sites >= 8, "there are Gate sites in streets, the plaza, the park, the parking lot, the yard, the site, the station")
	check(#Map.waypoints > 50 and #Map.shelters > 10, "civilians have somewhere to walk and somewhere to run")
	check(Map.screen ~= nil, "the plaza has its news screen")
	local kinds = {}
	for _, s in Map.sites do
		kinds[s.kind] = true
	end
	check(kinds.plaza and kinds.street and kinds.park and kinds.parking and kinds.industrial and kinds.station, "Gate sites cover every kind of place the engine knows")
end

local okInit, e1 = pcall(Npcs.init, root)
check(okInit, "the NPC layer starts" .. (if okInit then "" else ": " .. tostring(e1)))
-- (PivotTo isn't in @lune/roblox: a Model's own PivotTo is stood in for, to build here)
local okCiv, e2 = pcall(function()
	local Looks = Loader.require(shared.Hunter.Looks)
	local R6Rig = Loader.require(shared.Hunter.R6Rig)
	for k = 1, 6 do
		local look = Looks.random(function(a, b)
			return math.random(a, b)
		end, { civilian = true })
		local m = R6Rig.build(look, { name = "Citizen", npc = true, civilian = true })
		assert(m:FindFirstChildOfClass("Humanoid").RigType == roblox.Enum.HumanoidRigType.R6, "not R6")
		assert(m:FindFirstChild("Torso"):FindFirstChild("Right Shoulder"), "no shoulder joint")
		local _ = k
	end
end)
check(okCiv, "civilian R6 rigs build" .. (if okCiv then "" else ": " .. tostring(e2)))

-- every option of every field builds (a Hunter rig, with armor and a rank for the aura), and
-- every preset makes a clean look
do
	local Looks = Loader.require(shared.Hunter.Looks)
	local R6Rig = Loader.require(shared.Hunter.R6Rig)
	local built, bad = 0, {}
	for field, listName in Looks.FIELDS do
		if field ~= "hair" then
			for _, o in Looks[listName] do
				local look = table.clone(Looks.DEFAULT)
				look[field] = o.id
				look.armor = if field == "armor" then o.id else "plate"
				local ok, err = pcall(R6Rig.build, look, { name = "Opt", rank = 4 })
				if ok then
					built += 1
				else
					table.insert(bad, field .. "=" .. tostring(o.id) .. ": " .. tostring(err))
				end
			end
		end
	end
	check(#bad == 0, string.format("every look option builds on a real rig (%d built)%s", built, if #bad > 0 then ": " .. table.concat(bad, "; ") else ""))
	local presetsOk = true
	for _, p in Looks.PRESETS do
		local look = Looks.applyPreset(Looks.DEFAULT, p.id)
		for k, v in p.look do
			if look[k] ~= v then
				presetsOk = false
				print("   preset " .. p.id .. " lost " .. k .. "=" .. tostring(v))
			end
		end
		local ok = pcall(R6Rig.build, look, { name = "Preset", rank = 3 })
		presetsOk = presetsOk and ok
	end
	check(presetsOk, string.format("all %d outfit presets are valid looks and build", #Looks.PRESETS))
	local m = R6Rig.build(Looks.applyPreset(Looks.DEFAULT, "mage"), { name = "Glow", rank = 6 })
	local aura = m:FindFirstChild("Torso") and m.Torso:FindFirstChild("AuraAttachment")
	check(aura ~= nil and aura:FindFirstChild("Aura") ~= nil, "an aura is particles on the body")
	local plate = m:FindFirstChild("FacePlate")
	check(plate ~= nil and plate:FindFirstChild("Glow") ~= nil, "glowing eyes are drawn unlit on the face")
	local helm = R6Rig.build(Looks.applyPreset(Looks.DEFAULT, "tank"), { name = "Helm" })
	check(helm:FindFirstChild("Helm") ~= nil and helm:FindFirstChild("BlockHair") == nil, "a helmet covers the hair")
end
-- every monster kind builds, with its joints
local Monsters = Npcs.Monsters
local kinds = 0
for id, def in Monsters.DEFS do
	local ok, err = pcall(function()
		local model, hum = Monsters.build(id)
		assert(model.PrimaryPart and hum.MaxHealth == def.hp, "bad monster model")
		assert(#model:GetChildren() > 4, "too few parts")
		assert(model:GetAttribute("Gait") == def.gait, "no gait")
	end)
	kinds += 1
	check(ok, string.format("%s (%s-rank, %s) builds", def.name, ({ "E", "D", "C", "B", "A", "S" })[def.rank], def.gait) .. (if ok then "" else ": " .. tostring(err)))
end
for r = 1, 6 do
	check(#Monsters.KINDS[r] >= 4, "rank " .. r .. " has four kinds of monster")
end

-- the client animates every gait without error, and something moves (client/MonsterAnim)
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local okA, MonsterAnim = pcall(Loader.require, client.MonsterAnim)
check(okA, "client/MonsterAnim loads" .. (if okA then "" else ": " .. tostring(MonsterAnim)))
if okA then
	local gaits = {}
	for id, def in Monsters.DEFS do
		local ok, err = pcall(function()
			local model = Monsters.build(id)
			local r = MonsterAnim.rig(model)
			assert(r and r.gait == def.gait, "no rig")
			for step = 1, 12 do
				MonsterAnim.animate(r, 1 / 30, step / 30)
			end
			local moved = false
			for _, j in r.joints do
				local okT, tf = pcall(function()
					return j.Transform -- (offline, a Transform never set can't be read: that joint just stays still)
				end)
				if okT and tf ~= roblox.CFrame.new() then
					moved = true
				end
			end
			assert(moved or next(r.joints) == nil, "no joint moved")
		end)
		gaits[def.gait] = gaits[def.gait] or ok
		if not ok then
			check(false, def.name .. " animates: " .. tostring(err))
		end
	end
	local n = 0
	for g, ok in gaits do
		n += 1
		check(ok, "the " .. g .. " gait animates")
	end
end
-- the Blender mesh kit (Hunter/MeshLibrary): with a kit, every part that has a role gets its
-- mesh (a MeshPart its size, welded on, the part hidden) and nothing else changes; without
-- one, nothing does
do
	local MeshLibrary = Loader.require(shared.Hunter.MeshLibrary)
	local R6Rig = Loader.require(shared.Hunter.R6Rig)
	local Looks = Loader.require(shared.Hunter.Looks)
	local Weapons = Loader.require(shared.Hunter.Weapons)
	local kit = I.new("Model")
	kit.Name = MeshLibrary.KIT_NAME
	for _, role in MeshLibrary.ROLES do
		local m = I.new("MeshPart")
		m.Name = role
		m.Parent = kit
	end
	local function meshCount(model)
		local n = 0
		for _, d in model:GetDescendants() do
			if d:IsA("MeshPart") then
				n += 1
			end
		end
		return n
	end
	local bad, dressed = {}, 0
	local function verify(model, gait, label)
		for _, p in model:GetDescendants() do
			if p:IsA("BasePart") and not p:IsA("MeshPart") then
				local mesh = model:FindFirstChild(p.Name .. "Mesh", true)
				if p:GetAttribute("Dressed") then
					dressed += 1
					if p.Transparency ~= 1 then
						table.insert(bad, label .. "/" .. p.Name .. " still shows under its mesh")
					end
				elseif MeshLibrary.roleOf(p, gait) ~= nil then
					table.insert(bad, label .. "/" .. p.Name .. " has a role and no mesh")
				end
				local _ = mesh
			end
		end
		for _, m in model:GetDescendants() do
			if m:IsA("MeshPart") then
				local w = m:FindFirstChildOfClass("WeldConstraint")
				if not w or not w.Part0 or w.Part0.Size ~= m.Size then
					table.insert(bad, label .. "/" .. m.Name .. " isn't welded to a part its size")
				end
			end
		end
	end
	MeshLibrary.setKit(kit)
	local ok, err = pcall(function()
		for id, def in Monsters.DEFS do
			local model = Monsters.build(id)
			verify(model, def.gait, id)
			local before = meshCount(model)
			MeshLibrary.dress(model, def.gait)
			if meshCount(model) ~= before then
				table.insert(bad, id .. " was dressed twice")
			end
		end
		for _, pr in Looks.PRESETS do
			verify(R6Rig.build(Looks.applyPreset(Looks.DEFAULT, pr.id), { rank = 3 }), nil, pr.id)
		end
		for _, w in Weapons.list do
			verify(R6Rig.build({}, { weapon = { base = w.id, stars = 3, shiny = true } }), nil, w.id)
		end
	end)
	MeshLibrary.setKit(nil)
	check(ok and #bad == 0, string.format("with the mesh kit, every part with a role is dressed (%d parts) and nothing else", dressed) .. (if not ok then ": " .. tostring(err) elseif #bad > 0 then ": " .. table.concat(bad, "; ", 1, math.min(#bad, 6)) else ""))
	check(dressed > 400, "the kit reaches monsters, weapons and gear")
	local plain = Monsters.build("dragonkin")
	check(meshCount(plain) == 0, "without a kit, monsters stay parts")
end

if failures > 0 then
	process.exit(1)
end
print("\nThe live city builds on real Roblox instance types.")
