--[[
	The content pack the game runs. Config.pack picks it:
		"<Id>"       a game made with the blueprint: src/shared/Games/<Id> (Base.build of its spec)
		"City"       the Project Moon City: a fan game, so nothing is sold for Robux
		"Undermere"  the original setting (the store works here)
	If the chosen pack isn't in the build, the first game in Games is used, then the City,
	then Undermere.
]]

local Config = require(script.Parent.Config)

local LEGACY = { City = "City", Undermere = "Content" }

local function find(name: string?): Instance?
	if not name or name == "" then
		return nil
	end
	local games = script.Parent:FindFirstChild("Games")
	local game = games and games:FindFirstChild(name)
	if game then
		return game
	end
	return script.Parent:FindFirstChild(LEGACY[name] or name)
end

local node = find(Config.pack)
if not node then
	local games = script.Parent:FindFirstChild("Games")
	local first = games and games:GetChildren()[1]
	node = first or script.Parent:FindFirstChild("City") or script.Parent:FindFirstChild("Content")
end

local pack = require(node :: any)
-- (v0.13) Config.marriage = false turns a household's marriage off (the household stays)
if Config.marriage == false and type(pack) == "table" and pack.marriage then
	pack.marriage.on = false
	if pack.interactions then
		pack.interactions.hold_wedding = nil
		if pack.interactions.order then
			local at = table.find(pack.interactions.order, "hold_wedding")
			if at then
				table.remove(pack.interactions.order, at)
			end
		end
	end
end
return pack
