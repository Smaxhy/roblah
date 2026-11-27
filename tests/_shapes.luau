local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local Creatures = Loader.require(root.Engine.Creatures)
local n, bad = 0, 0
for _, shape in Creatures.shapes do
	for _, pose in { "idle", "strike", "hurt", "down" } do
		local ok, parts, frame = pcall(Creatures.build, { shape = shape, name = "Test " .. shape, pose = pose })
		if not ok then
			bad += 1
			print("FAIL", shape, pose, parts)
		elseif pose == "idle" then
			n += 1
			print(string.format("%-12s parts %3d  height %.1f  angle %s", shape, #parts, frame.height or 0, tostring(frame.angle)))
		end
	end
end
print("shapes:", n, "failures:", bad)
-- the avatar: a feminine build with an augment arm and a coat builds too
local Avatar = Loader.require(root.Engine.Avatar)
Loader.require(root.Config).pack = "City"
local pack = Loader.require(root.Pack)
for _, body in { "masculine", "feminine" } do
	for _, arm in { "aug_piston", "aug_rhino", "aug_grown" } do
		local parts = Avatar.build(pack, { look = { body = body, outfit = "night_coat", hair = "long" }, age = 30, gear = { arm = arm, tool = "workshop_knife", coat = "fixer_coat" } })
		print(body, arm, #parts)
	end
end
