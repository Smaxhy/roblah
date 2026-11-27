-- Validate a pack: LIFESIM_PACK=<Id> lune run tests/_validate   (default: Config.pack)
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(root.Engine)
local pack = Loader.pack(root)
local issues = Engine.Validate.run(pack)
for i, e in issues.errors do
	if i <= 40 then print("ERR " .. e) end
end
print("errors", #issues.errors, "warnings", #issues.warnings)
for i, w in issues.warnings do
	if i <= 12 then print("WARN " .. w) end
end
for _, m in pack.mergeIssues or {} do print("MERGE " .. m) end
