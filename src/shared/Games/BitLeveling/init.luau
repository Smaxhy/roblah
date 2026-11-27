-- A game made with the blueprint: Base.build turns its Spec (and the modules beside it) into a pack.
local Base = require(script.Parent.Parent:WaitForChild("Base"))
return Base.build(require(script:WaitForChild("Spec")), script)
