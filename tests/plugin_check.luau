--[[
	THE BITLEVELING STUDIO PLUGIN, CHECKED ON REAL ROBLOX INSTANCE TYPES (src/plugin).
		bash tools/build_plugin.sh && lune run tests/plugin_check
	  1. the built plugin carries the game with every script switched off (nothing runs inside
	     Studio's plugin host) and its code at the top
	  2. Install puts the game in a place's ServerScriptService with those scripts back on, the
	     place settings the game expects, and Update replaces it (one copy, never two)
	  3. the mesh kit registers from an imported model (role names, importer suffixes) and goes
	  4. the preview galleries build every monster, outfit, weapon and Gate, standing on the floor
	  5. validate and a few simulated lives run on the game's own modules
	  6. the panel builds, and its Install button installs
]]

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")
local I = roblox.Instance

local failures = 0
local function check(ok: boolean, msg: string)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		failures += 1
	end
end

if not fs.isFile("build/BitLevelingStudio.rbxmx") then
	print("build the plugin first: bash tools/build_plugin.sh")
	process.exit(1)
end
local pluginRoot = roblox.deserializeModel(fs.readFile("build/BitLevelingStudio.rbxmx"))[1]
local bundled = pluginRoot:FindFirstChild("LifeSimKit")

-- 1. what the plugin carries
local running = {}
for _, d in pluginRoot:GetDescendants() do
	if d:IsA("Script") and not d.Disabled and d.Name ~= "Main" then
		table.insert(running, d:GetFullName())
	end
end
check(pluginRoot:FindFirstChild("Main") ~= nil and pluginRoot:FindFirstChild("Lib") ~= nil, "the plugin has its Main script and Lib")
check(bundled ~= nil and bundled:FindFirstChild("Shared") ~= nil and bundled:FindFirstChild("Server") ~= nil and bundled:FindFirstChild("Client") ~= nil, "the plugin carries the whole game")
check(#running == 0, "no game script runs inside the plugin" .. (if #running > 0 then ": " .. table.concat(running, ", ") else ""))
check(type(bundled and bundled:GetAttribute("BitLevelingVersion")) == "string", "the copy is stamped with its version")

-- the game's modules through the loader, with real instances
local RandomStub = { new = function()
	return {
		NextInteger = function(_, a, b)
			return math.random(a, b)
		end,
		NextNumber = function(_, a, b)
			return (a or 0) + math.random() * ((b or 1) - (a or 0))
		end,
	}
end }
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local server = Loader.preload(Loader.node("src/server", "Server", nil))
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local dm = I.new("DataModel")
local signal = { Connect = function()
	return { Disconnect = function() end, Connected = true }
end }
local svcStubs = {
	RunService = { RenderStepped = signal, Heartbeat = signal, IsStudio = function()
		return true
	end, IsRunning = function()
		return false
	end, IsServer = function()
		return false
	end },
	TweenService = { Create = function()
		return { Play = function() end, Cancel = function() end, Completed = signal }
	end },
	ChangeHistoryService = { TryBeginRecording = function()
		return "rec"
	end, FinishRecording = function() end },
	Selection = { Get = function()
		return {}
	end },
	HttpService = { JSONEncode = function()
		return "{}"
	end },
	LogService = { MessageOut = signal },
	InsertService = {},
}
-- ReplicatedStorage: the real one, except that LifeSim is the loader's copy of the game
local rsReal = dm:GetService("ReplicatedStorage")
local rsStub = setmetatable({}, { __index = function(_, k)
	if k == "WaitForChild" then
		return function(_, name)
			return if name == "LifeSim" then shared else rsReal:WaitForChild(name)
		end
	end
	local v = rsReal[k]
	if type(v) == "function" then
		return function(_, ...)
			return v(rsReal, ...)
		end
	end
	return v
end })
-- Workspace with BulkMoveTo (GateVfx moves its parts in one call; @lune/roblox lacks it)
local wsReal = dm:GetService("Workspace")
local wsStub = setmetatable({ BulkMoveTo = function(_, parts, cfs)
	for i, p in parts do
		p.CFrame = cfs[i]
	end
end }, { __index = function(_, k)
	local v = wsReal[k]
	if type(v) == "function" then
		return function(_, ...)
			return v(wsReal, ...)
		end
	end
	return v
end })
local gameStub = { GetService = function(_, name)
	if svcStubs[name] then
		return svcStubs[name]
	elseif name == "ReplicatedStorage" then
		return rsStub
	elseif name == "Workspace" then
		return wsStub
	end
	return dm:GetService(name)
end }
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font, Random = RandomStub,
	NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, NumberRange = roblox.NumberRange,
	ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	TweenInfo = { new = function(...)
		return { ... }
	end },
	game = gameStub, workspace = wsStub,
	task = { spawn = function(f, ...)
		return f(...)
	end, wait = function() end, delay = function() end },
}
local plug = Loader.preload(Loader.node("src/plugin", "Plugin", nil))
local Install = Loader.require(plug.Lib.Install)
local Kit = Loader.require(plug.Lib.Kit)
local Previews = Loader.require(plug.Lib.Previews)
local Checks = Loader.require(plug.Lib.Checks)
local MeshLibrary = Loader.require(shared.Hunter.MeshLibrary)

-- 2. install / update
check(not Install.status(dm).installed, "a fresh place has no game")
local r1 = Install.install(dm, bundled)
local kit1 = dm:GetService("ServerScriptService"):FindFirstChild("LifeSimKit")
local inst = kit1 and kit1:FindFirstChild("Install")
local cl = kit1 and kit1:FindFirstChild("Client")
check(r1.ok and not r1.replaced and Install.status(dm).installed, "Install puts the game in ServerScriptService")
check(inst ~= nil and not inst.Disabled and inst:GetAttribute("PluginDisabled") == nil, "its installer runs on Play")
check(cl ~= nil and not cl.Disabled, "its client script is on (Install hands it to every player)")
check(dm:GetService("Players").CharacterAutoLoads == false, "the place gets the settings the game expects")
local r2 = Install.install(dm, bundled)
local copies = 0
for _, c in dm:GetService("ServerScriptService"):GetChildren() do
	if c.Name == "LifeSimKit" then
		copies += 1
	end
end
check(r2.replaced and copies == 1, "Update replaces the game (one copy, never two)")

-- 3. the mesh kit
local imported = I.new("Model")
for i, role in MeshLibrary.ROLES do
	local m = I.new("MeshPart")
	m.Name = if i % 3 == 0 then role .. ".001" elseif i % 3 == 1 then role else role .. "_2"
	m.Parent = if i % 2 == 0 then imported else (function()
		local sub = imported:FindFirstChild("Nested") or I.new("Model")
		sub.Name = "Nested"
		sub.Parent = imported
		return sub
	end)()
end
-- the cloth mesh comes with bones (and the importer's welds, which go)
local capeT = imported:FindFirstChild("cape_skinned", true) or imported:FindFirstChild("cape_skinned_2", true) or imported:FindFirstChild("cape_skinned.001", true)
if capeT then
	local b = I.new("Bone")
	b.Name = "root"
	b.Parent = capeT
	I.new("WeldConstraint").Parent = capeT
end
local reg = Kit.register(dm, { imported }, MeshLibrary.ROLES)
local kitCape = dm:GetService("ReplicatedStorage"):FindFirstChild("BitLevelingMeshKit")
kitCape = kitCape and kitCape:FindFirstChild("cape_skinned")
check(capeT == nil or (kitCape ~= nil and kitCape:FindFirstChildOfClass("Bone") ~= nil and kitCape:FindFirstChildOfClass("WeldConstraint") == nil), "a cloth mesh keeps its bones when registered (and loses the importer's welds)")
check(reg.found == #MeshLibrary.ROLES and #reg.missing == 0, string.format("the kit registers from an imported model (%d of %d roles, importer suffixes and nesting)", reg.found, #MeshLibrary.ROLES))
local st = Kit.status(dm, MeshLibrary.ROLES)
check(st.present and dm:GetService("ReplicatedStorage"):FindFirstChild("BitLevelingMeshKit") ~= nil, "the kit is saved in the place (ReplicatedStorage.BitLevelingMeshKit)")
Kit.remove(dm)
check(not Kit.status(dm, MeshLibrary.ROLES).present, "and it can be removed")

-- 4. galleries
local expect = { monsters = 24, outfits = 16, weapons = 65, gates = 7 }
-- (the Gates use Workspace:BulkMoveTo, which @lune/roblox lacks: they're built in a plain folder
-- standing in for the workspace, so GateVfx moves them through the stub above)
local gateWorld = I.new("Folder")
local gateGame = { GetService = function(_, name)
	return if name == "Workspace" then gateWorld else dm:GetService(name)
end }
for what, n in expect do
	local g = if what == "gates" then gateGame else dm
	local ok, res = pcall(Previews.build, g, what, shared, server, client, roblox.Vector3.new(0, 0, 0))
	local into = g:GetService("Workspace"):FindFirstChild("BitLevelingPreview")
	into = into and into:FindFirstChild(what)
	local floorOk = true
	if ok and into and what ~= "gates" then
		for _, m in into:GetChildren() do
			local lowest = math.huge
			for _, d in m:GetDescendants() do
				if d:IsA("BasePart") and d.Transparency < 1 then
					lowest = math.min(lowest, d.CFrame.Position.Y - math.max(d.Size.X, d.Size.Y, d.Size.Z))
				end
			end
			if lowest > 1 or lowest < -8 then
				floorOk = false
			end
		end
	end
	check(ok and res == n and into ~= nil and #into:GetChildren() == n and floorOk, string.format("the %s gallery builds %d, standing on the floor", what, n) .. (if not ok then ": " .. tostring(res) else ""))
end
Previews.clear(dm)
check(dm:GetService("Workspace"):FindFirstChild("BitLevelingPreview") == nil, "Clear previews clears them")

-- 5. checks on the game's own modules
local okV, v = pcall(Checks.validate, shared)
check(okV and #v.errors == 0 and v.events > 200, "Validate runs in Studio and the content is clean" .. (if okV then string.format(" (%d cards)", v.events) else ": " .. tostring(v)))
local okS, sres = pcall(Checks.simulate, shared, 4, nil)
check(okS and sres.lives == 4 and #sres.crashes == 0 and #sres.fates > 0, "Simulate runs lives and every one ends in a fate" .. (if okS then "" else ": " .. tostring(sres)))

-- 6. the panel, on proxies that record what each button does
local handlers = {}
local REAL = setmetatable({}, { __mode = "k" })
local function unwrap(x)
	return REAL[x] or x
end
local EVENTS = { Activated = true, MouseButton1Click = true, FocusLost = true }
local function wrap(real)
	local proxy = {}
	REAL[proxy] = real
	return setmetatable(proxy, {
		__index = function(_, k)
			if EVENTS[k] then
				return { Connect = function(_, fn)
					-- (@lune/roblox hands back a new userdata for the same instance on every
					-- lookup, so the handlers are keyed by a tag on the instance itself)
					local tag = real:GetAttribute("_h")
					if not tag then
						tag = tostring(math.random(1, 1e9))
						real:SetAttribute("_h", tag)
					end
					handlers[tag] = handlers[tag] or {}
					table.insert(handlers[tag], fn)
					return { Disconnect = function() end }
				end }
			end
			local val = real[k]
			if type(val) == "function" then
				return function(_, ...)
					local args = table.pack(...)
					for i = 1, args.n do
						args[i] = unwrap(args[i])
					end
					return val(real, table.unpack(args, 1, args.n))
				end
			end
			return val
		end,
		__newindex = function(_, k, val)
			real[k] = unwrap(val)
		end,
	})
end
local globalsB = table.clone(Loader.globals)
globalsB.Instance = { new = function(className)
	return wrap(I.new(className))
end }
local dm2 = I.new("DataModel")
globalsB.game = { GetService = function(_, name)
	return svcStubs[name] or dm2:GetService(name)
end }
Loader.globals = globalsB
local plug2 = Loader.preload(Loader.node("src/plugin", "Plugin2", nil))
local okApp, App = pcall(Loader.require, plug2.Lib.App)
check(okApp, "the panel's module loads" .. (if okApp then "" else ": " .. tostring(App)))
if okApp then
	local screen = I.new("ScreenGui")
	local okB, ui = pcall(App.build, wrap(screen), nil, bundled)
	check(okB and ui and ui.log, "the panel builds" .. (if okB then "" else ": " .. tostring(ui)))
	local buttons, installBtn = 0, nil
	for _, d in screen:GetDescendants() do
		if d:IsA("TextButton") then
			buttons += 1
			if d.Text == "Install / Update game" then
				installBtn = d
			end
		end
	end
	check(buttons >= 12, string.format("it has its buttons (%d)", buttons))
	local fired = 0
	for _, fn in (installBtn and handlers[installBtn:GetAttribute("_h")]) or {} do
		fn()
		fired += 1
	end
	check(fired > 0 and dm2:GetService("ServerScriptService"):FindFirstChild("LifeSimKit") ~= nil, "pressing Install installs the game")
end

if failures > 0 then
	print(string.format("\n%d check(s) failed.", failures))
	process.exit(1)
end
print("\nThe plugin installs, previews, checks and builds its panel.")
