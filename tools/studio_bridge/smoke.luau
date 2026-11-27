--[[
	A SMOKE TEST RUN INSIDE ROBLOX STUDIO through the bridge:
		python3 tools/studio_bridge/bridge.py run --file tools/studio_bridge/smoke.luau
	In edit mode it checks the installed game: the content validates, every monster and outfit
	builds (with the mesh kit if the place has it), the Gate draws. In Play (server view) it also
	opens a Gate in the live city through the Studio hook. Prints PASS/FAIL lines; errors if any
	FAIL.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local fails = 0
local function check(ok, what, detail)
	print((if ok then "PASS  " else "FAIL  ") .. what .. (if detail then " (" .. tostring(detail) .. ")" else ""))
	if not ok then
		fails += 1
	end
end

local kit = ServerScriptService:FindFirstChild("LifeSimKit")
local shared = ReplicatedStorage:FindFirstChild("LifeSim") or (kit and kit:FindFirstChild("Shared"))
check(shared ~= nil, "the game is installed (ServerScriptService.LifeSimKit or ReplicatedStorage.LifeSim)")
if not shared then
	error("not installed: BitLeveling panel > Install / Update game", 0)
end

-- edit mode: the modules that look in ReplicatedStorage need LifeSim there for a moment
local temp = nil
if not ReplicatedStorage:FindFirstChild("LifeSim") then
	temp = shared:Clone()
	temp.Name = "LifeSim"
	temp.Archivable = false
	temp.Parent = ReplicatedStorage
	shared = temp
end

local ok, err = pcall(function()
	local Engine = require(shared.Engine)
	local pack = require(shared.Pack)
	local issues = Engine.Validate.run(pack)
	check(#issues.errors == 0, "the content validates", #issues.errors .. " errors, " .. #(pack.events or {}) .. " cards")

	local MeshLibrary = require(shared.Hunter.MeshLibrary)
	check(true, "mesh kit " .. (if MeshLibrary.ready() then "present" else "absent (parts)"))

	local R6Rig = require(shared.Hunter.R6Rig)
	local Looks = require(shared.Hunter.Looks)
	local built = 0
	for _, p in Looks.PRESETS do
		local m = R6Rig.build(Looks.applyPreset(Looks.DEFAULT, p.id), {})
		built += 1
		m:Destroy()
	end
	check(built == #Looks.PRESETS, "every outfit preset builds", built)

	local server = (kit and kit:FindFirstChild("Server")) or ServerScriptService:FindFirstChild("Server", true)
	if server then
		local Monsters = require(server:Clone().HunterLive.Monsters)
		local n, meshes = 0, 0
		for _, list in Monsters.KINDS do
			for _, kind in list do
				local m = Monsters.build(kind)
				for _, d in m:GetDescendants() do
					if d:IsA("MeshPart") then
						meshes += 1
					end
				end
				n += 1
				m:Destroy()
			end
		end
		check(n == 24, "every monster builds", n .. " monsters, " .. meshes .. " kit meshes")
	end

	local hook = ServerStorage:FindFirstChild("BitLevelingStudio")
	if RunService:IsRunning() and hook then
		local res = hook:Invoke("spawn", { rank = 2 })
		check(res and res.ok, "the live city opens a Gate on demand", res and (res.toast or res.error))
	end
end)
if temp then
	temp:Destroy()
end
check(ok, "the smoke test ran to its end", err)
print(string.format("%s: %d failure(s)", if fails == 0 then "ALL PASS" else "FAILED", fails))
if fails > 0 then
	error(fails .. " smoke check(s) failed", 0)
end
