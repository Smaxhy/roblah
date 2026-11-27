--[[
	BITLEVELING STUDIO (a Roblox Studio plugin). Built by tools/plugin/build_plugin.luau into
	build/BitLevelingStudio.rbxmx: put that file in your Studio Plugins folder (Studio: Plugins
	tab > Plugins Folder) and restart Studio. A "BitLeveling" button appears on the Plugins tab.
	See src/plugin/Lib/App.luau for what the panel does.
]]

if not plugin then
	return
end
local App = require(script.Parent:WaitForChild("Lib"):WaitForChild("App"))
App.start(plugin, script.Parent)
