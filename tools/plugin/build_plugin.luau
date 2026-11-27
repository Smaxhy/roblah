--[[
	BUILD THE BITLEVELING STUDIO PLUGIN: build/BitLevelingStudio.rbxmx
		rojo build games/BitLeveling.kit.project.json -o build/BitLevelingKit.rbxmx
		rojo build games/BitLevelingStudio.project.json -o build/BitLevelingStudioCode.rbxmx
		lune run tools/plugin/build_plugin.luau
	(tools/build_plugin.sh does all three.) The plugin's code, plus a copy of the whole game as
	LifeSimKit with its Install script disabled (a plugin runs every Script inside it; the game's
	installer must only ever run in a game). The panel's Install button copies it into the place
	with Install switched back on. Put the .rbxmx in Studio's Plugins folder.
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local code = roblox.deserializeModel(fs.readFile("build/BitLevelingStudioCode.rbxmx"))[1]
local kit = roblox.deserializeModel(fs.readFile("build/BitLevelingKit.rbxmx"))[1]
kit.Name = "LifeSimKit"
local disabled = 0
for _, d in kit:GetDescendants() do
	if d:IsA("Script") then -- (LocalScripts too: Install hands the Client one to each player)
		if not d.Disabled then
			d.Disabled = true
			d:SetAttribute("PluginDisabled", true) -- Install.install switches exactly these back on
			disabled += 1
		end
	end
end
local version = "dev"
local ok, res = pcall(process.exec, "git", { "rev-parse", "--short", "HEAD" })
if ok and res.ok then
	version = string.gsub(res.stdout, "%s+", "")
end
version = "BitLeveling " .. version .. " (" .. os.date("%Y-%m-%d") .. ")"
kit:SetAttribute("BitLevelingVersion", version)
kit.Parent = code
code.Name = "BitLevelingStudio"
fs.writeFile("build/BitLevelingStudio.rbxmx", roblox.serializeModel({ code }, true))
print(string.format("wrote build/BitLevelingStudio.rbxmx: the plugin, carrying %s (%d script(s) disabled inside it)", version, disabled))
