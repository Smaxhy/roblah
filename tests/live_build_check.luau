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
-- every monster rank builds (their model builder, without moving them)
for rank = 1, 6 do
	local ok, err = pcall(function()
		local def = Npcs.MONSTER[rank]
		assert(def and def.hp > 0, "no def")
		local model, hum = Npcs.monsterModel(rank)
		assert(model.PrimaryPart and hum.MaxHealth == def.hp, "bad monster model")
		assert(#model:GetChildren() > 5, "too few parts")
	end)
	check(ok, "monster rank " .. rank .. " (" .. Npcs.MONSTER[rank].name .. ") builds" .. (if ok then "" else ": " .. tostring(err)))
end
if failures > 0 then
	process.exit(1)
end
print("\nThe live city builds on real Roblox instance types.")
