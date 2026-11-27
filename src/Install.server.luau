--[[
	LifeSim Kit installer.

	Put the whole LifeSimKit folder inside ServerScriptService and press Play.
	On start this script:
	  1. moves Shared -> ReplicatedStorage.LifeSim (engine, content, config)
	  2. gives every player a copy of the Client script (UI)
	  3. starts the Server module (saves + game logic)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local kit = script.Parent

-- Only one copy may run. A second copy (for example, the kit imported into
-- Undermere.rbxlx, which already has it) would otherwise tear down the first.
if ReplicatedStorage:GetAttribute("LifeSimKitRunning") then
	warn(
		"[LifeSim] There are two copies of LifeSimKit. Delete the extra one at "
			.. kit:GetFullName()
			.. ". This copy will not run."
	)
	return
end
ReplicatedStorage:SetAttribute("LifeSimKitRunning", kit:GetFullName())

if not kit:IsDescendantOf(game:GetService("ServerScriptService")) then
	warn(
		"[LifeSim] LifeSimKit should be inside ServerScriptService, but it's in "
			.. (if kit.Parent then kit.Parent:GetFullName() else "nothing")
			.. ". It still runs, but drag it into ServerScriptService so players can't see the server code."
	)
end

local shared = kit:FindFirstChild("Shared")
if shared then
	local existing = ReplicatedStorage:FindFirstChild("LifeSim")
	if existing then
		existing:Destroy()
	end
	shared.Name = "LifeSim"
	shared.Parent = ReplicatedStorage
end

local Config = require(ReplicatedStorage:WaitForChild("LifeSim"):WaitForChild("Config"))

if Config.disableCharacters then
	Players.CharacterAutoLoads = false
	for _, player in Players:GetPlayers() do
		if player.Character then
			player.Character:Destroy()
		end
	end
end

local clientTemplate = kit:WaitForChild("Client")

local function giveClient(player: Player)
	local playerGui = player:WaitForChild("PlayerGui")
	if playerGui:FindFirstChild("LifeSimClient") then
		return
	end
	local client = clientTemplate:Clone()
	client.Name = "LifeSimClient"
	client.Parent = playerGui
end

Players.PlayerAdded:Connect(giveClient)
for _, player in Players:GetPlayers() do
	task.spawn(giveClient, player)
end

require(kit:WaitForChild("Server")).start()
