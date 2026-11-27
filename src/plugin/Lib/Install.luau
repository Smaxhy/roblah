--[[
	INSTALL / UPDATE THE GAME (BitLeveling Studio plugin).

	The plugin carries the whole game as a LifeSimKit folder (its scripts disabled and tagged
	PluginDisabled, so they never run inside Studio's plugin host). Installing puts a copy in ServerScriptService with
	Install enabled, which is all the game needs: on Play, Install moves Shared into
	ReplicatedStorage.LifeSim and starts the server and the client (src/Install.server.luau).

		Install.status(game)                 -> { installed, version, at }
		Install.install(game, bundled, opts) -> { ok, replaced, version }
		Install.withShared(game, bundled, fn) -- run fn(shared, server, client) with the game's
		                                        modules requireable in edit mode (see below)
]]

local Install = {}

local KIT = "LifeSimKit"

function Install.installed(game: any): Instance?
	local sss = game:GetService("ServerScriptService")
	local kit = sss:FindFirstChild(KIT)
	return if kit and kit:FindFirstChild("Shared") and kit:FindFirstChild("Server") then kit else nil
end

function Install.status(game: any): any
	local kit = Install.installed(game)
	return {
		installed = kit ~= nil,
		version = kit and kit:GetAttribute("BitLevelingVersion") or nil,
		at = kit and kit:GetAttribute("InstalledAt") or nil,
	}
end

-- put a fresh copy of the bundled game in ServerScriptService (the old one is replaced)
function Install.install(game: any, bundled: Instance, opts: any?): any
	opts = opts or {}
	local sss = game:GetService("ServerScriptService")
	local old = sss:FindFirstChild(KIT)
	local copy = bundled:Clone()
	copy.Name = KIT
	-- the scripts the plugin build switched off (so they never ran inside Studio's plugin host)
	-- come back on: Install, and the Client template it hands to players
	for _, d in copy:GetDescendants() do
		if d:IsA("Script") and d:GetAttribute("PluginDisabled") then
			d.Disabled = false
			d:SetAttribute("PluginDisabled", nil)
		end
	end
	copy:SetAttribute("BitLevelingVersion", bundled:GetAttribute("BitLevelingVersion") or "dev")
	copy:SetAttribute("InstalledAt", opts.now or os.time())
	if old then
		old:Destroy()
	end
	copy.Parent = sss
	-- the place settings the game expects (the same as games/BitLeveling.project.json)
	local players = game:GetService("Players")
	pcall(function()
		players.CharacterAutoLoads = false
	end)
	-- an edit-mode copy of LifeSim left by a preview would shadow the real one on Play
	local rs = game:GetService("ReplicatedStorage")
	local stale = rs:FindFirstChild("LifeSim")
	if stale and stale:GetAttribute("PluginPreview") then
		stale:Destroy()
	end
	return { ok = true, replaced = old ~= nil, version = copy:GetAttribute("BitLevelingVersion") }
end

-- In edit mode the game's shared modules live in ServerScriptService.LifeSimKit.Shared, but
-- some of them find each other through ReplicatedStorage.LifeSim (where Install puts them on
-- Play). For previews and checks, a fresh copy goes there for the length of fn, then goes.
-- (A fresh copy every time: a ModuleScript is required once per instance, so edits show.)
function Install.withShared(game: any, bundled: Instance?, fn: (Instance, Instance, Instance) -> any): (boolean, any)
	local kit = Install.installed(game) or bundled
	if not kit then
		return false, "The game isn't installed (and the plugin has no copy of it)."
	end
	local rs = game:GetService("ReplicatedStorage")
	local existing = rs:FindFirstChild("LifeSim")
	local temp = nil
	local shared = existing
	if not existing then
		temp = (kit:FindFirstChild("Shared") :: Instance):Clone()
		temp.Name = "LifeSim"
		temp:SetAttribute("PluginPreview", true)
		temp.Archivable = false
		temp.Parent = rs
		shared = temp
	end
	local server = (kit:FindFirstChild("Server") :: Instance):Clone()
	local client = (kit:FindFirstChild("Client") :: Instance):Clone()
	server.Archivable = false
	client.Archivable = false
	local ok, res = pcall(fn, shared :: Instance, server, client)
	server:Destroy()
	client:Destroy()
	if temp then
		temp:Destroy()
	end
	return ok, res
end

return Install
