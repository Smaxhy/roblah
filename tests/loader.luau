--[[
	Minimal Roblox-style module loader for Lune.
	Maps a Rojo source folder to fake Instances so `require(script.Parent.X)`,
	`script:WaitForChild("Y"):GetChildren()` and `child:IsA("ModuleScript")`
	work exactly like they do in Roblox. Follows Rojo naming:
		folder/init.luau -> ModuleScript "folder" (other files become its children)
		folder/          -> Folder
		Name.luau        -> ModuleScript "Name"
		*.server.luau / *.client.luau are skipped (they are Scripts/LocalScripts)
]]

local fs = require("@lune/fs")
local luau = require("@lune/luau")

local Loader = {}

-- Extra globals injected into every loaded module (the UI smoke test fills
-- this with Roblox types and service stubs).
Loader.globals = {
	-- Roblox's profiler marks (the vendored CameraShaker calls them every frame) do nothing here
	debug = setmetatable({ profilebegin = function() end, profileend = function() end }, { __index = debug }),
}

local Node = {}
local nodeMeta = {}

local function childrenOf(node)
	local cached = rawget(node, "_children")
	if cached then
		return cached
	end
	local list = {}
	local dir = rawget(node, "_dir")
	if dir then
		local names = fs.readDir(dir)
		table.sort(names)
		for _, entry in names do
			local path = dir .. "/" .. entry
			if fs.isDir(path) then
				table.insert(list, Loader.node(path, entry, node))
			elseif entry ~= "init.luau" and string.sub(entry, -5) == ".luau" then
				if not string.find(entry, "%.server%.luau$") and not string.find(entry, "%.client%.luau$") then
					table.insert(list, Loader.node(path, string.sub(entry, 1, -6), node))
				end
			end
		end
	end
	rawset(node, "_children", list)
	return list
end

function Node.GetChildren(self)
	return table.clone(childrenOf(self))
end

function Node.FindFirstChild(self, name)
	local dyn = rawget(self, "_dyn")
	if dyn and dyn[name] then
		return dyn[name]
	end
	for _, c in childrenOf(self) do
		if c.Name == name then
			return c
		end
	end
	return nil
end

function Node.WaitForChild(self, name)
	local c = Node.FindFirstChild(self, name)
	if not c then
		error("Infinite yield: " .. self.Name .. " has no child " .. name, 2)
	end
	return c
end

function Node.IsA(self, className)
	return self.ClassName == className
end

function Node.GetFullName(self)
	local parent = rawget(self, "Parent")
	if parent then
		return Node.GetFullName(parent) .. "." .. rawget(self, "Name")
	end
	return rawget(self, "Name")
end

nodeMeta.__index = function(self, key)
	local method = Node[key]
	if method then
		return method
	end
	local child = Node.FindFirstChild(self, key)
	if child then
		return child
	end
	error(tostring(key) .. " is not a valid member of " .. Node.GetFullName(self), 2)
end
nodeMeta.__tostring = function(self)
	return self.Name
end

function Loader.node(path, name, parent)
	local node = { Name = name, Parent = parent, _path = path }
	if fs.isDir(path) then
		node._dir = path
		if fs.isFile(path .. "/init.luau") then
			node.ClassName = "ModuleScript"
			node._source = path .. "/init.luau"
		else
			node.ClassName = "Folder"
		end
	else
		node.ClassName = "ModuleScript"
		node._source = path
	end
	return setmetatable(node, nodeMeta)
end

local cache = {}
local sources = {}

-- Modules to swap out in tests, keyed by source path.
Loader.overrides = {}

function Loader.isNode(v): boolean
	return type(v) == "table" and getmetatable(v) == nodeMeta
end

-- Lets runtime-created instances (e.g. a Remotes folder) live under a file node.
function Loader.attach(node, name: string, child)
	local dyn = rawget(node, "_dyn")
	if not dyn then
		dyn = {}
		rawset(node, "_dyn", dyn)
	end
	dyn[name] = child
end

-- Walks the tree and reads every source up front. Lune's fs calls can't yield
-- from inside metamethods/coroutines, so tests call this on the main thread.
function Loader.preload(node)
	local src = rawget(node, "_source")
	if src and not sources[src] then
		sources[src] = fs.readFile(src)
	end
	for _, child in childrenOf(node) do
		Loader.preload(child)
	end
	return node
end

function Loader.require(node)
	if type(node) ~= "table" or getmetatable(node) ~= nodeMeta then
		error("require expects a ModuleScript", 2)
	end
	if rawget(node, "ClassName") ~= "ModuleScript" then
		error("Attempted to require a non-ModuleScript: " .. Node.GetFullName(node), 2)
	end
	local key = rawget(node, "_source")
	if Loader.overrides[key] ~= nil then
		return Loader.overrides[key]
	end
	if cache[key] ~= nil then
		return cache[key]
	end
	local source = sources[key] or fs.readFile(key)
	local env = { script = node, require = Loader.require }
	for k, v in Loader.globals do
		env[k] = v
	end
	local fn = luau.load(source, {
		debugName = key,
		environment = env,
	})
	local result = fn()
	cache[key] = result
	return result
end

-- The content pack the game runs (Shared > Pack, which reads Config.pack).
-- LIFESIM_PACK=Undermere (or City) picks one for a test run.
function Loader.pack(sharedRoot)
	local process = require("@lune/process")
	local Config = Loader.require(sharedRoot.Config)
	local wanted = process.env.LIFESIM_PACK
	if wanted and wanted ~= "" then
		Config.pack = wanted
	end
	return Loader.require(sharedRoot.Pack)
end

-- (v0.13) a card can start a delve on the spot (a way in found in the world). A headless
-- driver that only answers cards and ages up plays it out here, taking the first open way at
-- every stage, so the life goes on instead of waiting on a run nobody is playing.
function Loader.finishRun(sim, life)
	local guard = 0
	while life.alive and life.run and not life.run.crew and guard < 60 do
		guard += 1
		local v = sim:runView(life)
		local pick = nil
		for _, c in (v and v.stage and v.stage.choices) or {} do
			if c.enabled ~= false then
				pick = c.index
				break
			end
		end
		if not pick or not sim:chooseExpedition(life, pick, nil) then
			life.run = nil
		end
	end
end
-- (v0.16) a turn-based boss battle, fought to its end by a plain-minded fighter: patch up
-- when low, guard a heavy blow aimed at you, otherwise strike with the best odds
function Loader.finishBattle(sim, life)
	local guard = 0
	while life.alive and life.battle and guard < 80 do
		guard += 1
		local v = sim:battleView(life)
		if not v or not v.options then
			break
		end
		local hp, maxHp = 0, 100
		for _, f in v.fighters do
			if f.me then
				hp, maxHp = f.hp, math.max(1, f.maxHp)
			end
		end
		local aimed = v.next.target == "all" or v.next.target == tostring(life.id)
		local action, approach = "guard", nil
		local best, bestOdds = nil, -1
		for _, o in v.options do
			if o.action == "strike" then
				local odds = o.odds or 1
				if odds > bestOdds then
					best, bestOdds = o, odds
				end
			end
		end
		local canRecover = false
		for _, o in v.options do
			if o.action == "recover" and o.enabled ~= false then
				canRecover = true
			end
		end
		if hp < maxHp * 0.3 and canRecover then
			action = "recover"
		elseif aimed and v.next.heavy and bestOdds < 0.5 then
			action = "guard"
		elseif best then
			action, approach = "strike", best.approach
		end
		local rep = sim:battleAct(life, action, approach)
		if not rep and life.battle then
			-- couldn't act (shouldn't happen alone): get out
			sim:battleAct(life, "flee", nil)
		end
	end
	if life.battle then
		life.battle = nil
	end
end
function Loader.ageUp(sim, life)
	Loader.finishRun(sim, life)
	Loader.finishBattle(sim, life)
	return sim:ageUp(life)
end

return Loader
