--[[
	UI smoke test: builds every screen with real engine data on top of Lune's
	Roblox instances, which reject unknown properties and wrong value types
	exactly like Roblox does. Catches typos in property names/enums/fonts
	without opening Studio.
		lune run tests/ui_smoke
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")

local luneTypeof = typeof

-- ── signals ─────────────────────────────────────────────────────────────────
local Signal = {}
Signal.__index = Signal
function Signal.new()
	return setmetatable({ conns = {} }, Signal)
end
function Signal:Connect(fn)
	table.insert(self.conns, fn)
	return { Disconnect = function() end, Connected = true }
end
function Signal:Once(fn)
	return self:Connect(fn)
end
function Signal:Wait()
	return nil
end
function Signal:Fire(...)
	for _, fn in self.conns do
		fn(...)
	end
end

-- ── instance proxies ────────────────────────────────────────────────────────
local realOf = setmetatable({}, { __mode = "k" })
local proxyOf = {}
local signalsOf = {}

local EVENTS = {
	Players = { "PlayerAdded", "PlayerRemoving" },
	GuiButton = { "Activated", "MouseButton1Down", "MouseButton1Up", "MouseButton1Click", "MouseEnter", "MouseLeave", "InputBegan", "InputEnded" },
	TextBox = { "FocusLost", "Focused" },
	GuiObject = { "MouseEnter", "MouseLeave", "InputBegan", "InputEnded" },
	BindableEvent = { "Event" },
	RemoteEvent = { "OnClientEvent", "OnServerEvent" },
	Instance = { "Changed", "ChildAdded", "ChildRemoved", "AncestryChanged", "Destroying" },
}
local EVENT_NAMES = {}
for _, list in EVENTS do
	for _, n in list do
		EVENT_NAMES[n] = true
	end
end
local function eventAllowed(real, name)
	for base, list in EVENTS do
		if real:IsA(base) and table.find(list, name) then
			return true
		end
	end
	return false
end

local wrap
local Methods = {}
function Methods.Destroy(p)
	realOf[p]:Destroy()
end
function Methods.GetChildren(p)
	local out = {}
	for _, c in realOf[p]:GetChildren() do
		table.insert(out, wrap(c))
	end
	return out
end
function Methods.GetDescendants(p)
	local out = {}
	for _, c in realOf[p]:GetDescendants() do
		table.insert(out, wrap(c))
	end
	return out
end
function Methods.FindFirstChild(p, name)
	return wrap(realOf[p]:FindFirstChild(name))
end
function Methods.FindFirstChildOfClass(p, cls)
	return wrap(realOf[p]:FindFirstChildOfClass(cls))
end
function Methods.WaitForChild(p, name)
	local c = realOf[p]:FindFirstChild(name)
	assert(c, "WaitForChild would hang forever: " .. tostring(name))
	return wrap(c)
end
function Methods.FindFirstAncestorOfClass(p, cls)
	local real = realOf[p].Parent
	while real do
		if real:IsA(cls) then
			return wrap(real)
		end
		real = real.Parent
	end
	return nil
end
function Methods.IsA(p, cls)
	return realOf[p]:IsA(cls)
end
function Methods.Clone(p)
	return wrap(realOf[p]:Clone())
end
function Methods.SetAttribute(p, k, v)
	realOf[p]:SetAttribute(k, v)
end
function Methods.GetAttribute(p, k)
	return realOf[p]:GetAttribute(k)
end
function Methods.GetPropertyChangedSignal(p, prop)
	local real = realOf[p]
	if string.sub(prop, 1, 8) ~= "Absolute" then
		local _ = real[prop] -- validates the property exists
	end
	return Signal.new()
end
function Methods.ClearAllChildren(p)
	realOf[p]:ClearAllChildren()
end
function Methods.FillBlock(_, cf, size, material)
	assert(luneTypeof(cf) == "CFrame" and luneTypeof(size) == "Vector3" and luneTypeof(material) == "EnumItem", "bad FillBlock args")
end

-- remote calls are deep-copied like Roblox does, and must be remote-safe
local callbacks = {}
local kicked = {}
local function isArray(t)
	local n = 0
	for _ in t do
		n += 1
	end
	for i = 1, n do
		if t[i] == nil then
			return false
		end
	end
	return true
end
local function marshal(v, path)
	local tv = type(v)
	if tv == "function" or tv == "thread" then
		error("can't send a " .. tv .. " over a remote (at " .. path .. ")")
	end
	if tv ~= "table" then
		return v
	end
	if realOf[v] then
		return v
	end
	local hasString, hasNumber = false, false
	for k in v do
		if type(k) == "string" then
			hasString = true
		elseif type(k) == "number" then
			hasNumber = true
		else
			error("bad key type over remote at " .. path)
		end
	end
	if hasString and hasNumber then
		error("mixed table would lose data over a remote (at " .. path .. ")")
	end
	if hasNumber and not isArray(v) then
		error("sparse array would lose data over a remote (at " .. path .. ")")
	end
	local out = {}
	for k, child in v do
		out[k] = marshal(child, path .. "." .. tostring(k))
	end
	return out
end
local remoteCalls = 0
function Methods.InvokeServer(p, ...)
	local cb = callbacks[p]
	assert(cb, "InvokeServer with no OnServerInvoke set")
	remoteCalls += 1
	local args = marshal({ ... }, "args")
	return marshal(cb(Loader.globals.game:GetService("Players").LocalPlayer, table.unpack(args)), "response")
end
local userIds = {}
function Methods.GetPlayers(_)
	local list = {}
	for _, child in Loader.globals.realPlayers:GetChildren() do
		if child:IsA("Player") then
			table.insert(list, wrap(child))
		end
	end
	return list
end
function Methods.GetPlayerByUserId(_, id)
	for _, child in Loader.globals.realPlayers:GetChildren() do
		if child:IsA("Player") and (userIds[child] or 4242) == id then
			return wrap(child)
		end
	end
	return nil
end
-- server -> client pushes: delivered to the app for the local player, recorded for others
local pushes = {}
function Methods.FireClient(p, player, payload)
	assert(realOf[p]:IsA("RemoteEvent"), "FireClient on a non-RemoteEvent")
	local data = marshal(payload, "push")
	if player == Loader.globals.localPlayer then
		local sig = signalsOf[p] and signalsOf[p].OnClientEvent
		if sig then
			sig:Fire(data)
		end
	else
		table.insert(pushes, { player = player, payload = data })
	end
end
function Methods.Kick(p, msg)
	table.insert(kicked, msg)
end
-- BindableEvent:Fire() fires its .Event signal (Layout uses one to say the size changed)
function Methods.Fire(p, ...)
	assert(realOf[p]:IsA("BindableEvent"), "Fire on a non-BindableEvent")
	local sig = signalsOf[p] and signalsOf[p].Event
	if sig then
		sig:Fire(...)
	end
end

local VIEWPORT = roblox.Vector2.new(420, 760)
local smokeCamera = roblox.Instance.new("Camera")
local meta = {}
meta.__index = function(p, key)
	local real = realOf[p]
	if EVENT_NAMES[key] then
		if not eventAllowed(real, key) then
			error(key .. " is not a valid member of " .. real.ClassName, 2)
		end
		signalsOf[p] = signalsOf[p] or {}
		signalsOf[p][key] = signalsOf[p][key] or Signal.new()
		return signalsOf[p][key]
	end
	local m = Methods[key]
	if m then
		return m
	end
	if type(key) == "string" and string.sub(key, 1, 8) == "Absolute" then
		return VIEWPORT
	end
	-- (v0.18) a camera for the 3D stage, the size of the phone
	if key == "CurrentCamera" and real.ClassName == "Workspace" then
		return wrap(smokeCamera)
	end
	if key == "ViewportSize" and real == smokeCamera then
		return VIEWPORT
	end
	if key == "LocalPlayer" and real.ClassName == "Players" then
		return Loader.globals.localPlayer
	end
	if key == "UserId" and real.ClassName == "Player" then
		return userIds[real] or 4242
	end
	if key == "DisplayName" and real.ClassName == "Player" then
		return real.Name
	end
	local v = real[key]
	if luneTypeof(v) == "Instance" then
		return wrap(v)
	end
	return v
end
meta.__newindex = function(p, key, value)
	local real = realOf[p]
	if key == "OnServerInvoke" then
		assert(real:IsA("RemoteFunction"), "OnServerInvoke on a non-RemoteFunction")
		callbacks[p] = value
		return
	end
	if key == "Parent" and Loader.isNode(value) then
		Loader.attach(value, real.Name, p)
		return
	end
	if type(value) == "table" and realOf[value] then
		value = realOf[value]
	end
	real[key] = value
end
meta.__tostring = function(p)
	return "Proxy<" .. realOf[p].ClassName .. ">"
end

function wrap(real)
	if real == nil then
		return nil
	end
	local p = proxyOf[real]
	if p then
		return p
	end
	p = setmetatable({}, meta)
	realOf[p] = real
	proxyOf[real] = p
	return p
end

local function fireAll(root, eventName: string, limit: number?)
	local fired = 0
	local list = { root }
	for _, d in realOf[root]:GetDescendants() do
		table.insert(list, wrap(d))
	end
	for _, p in list do
		local sig = signalsOf[p] and signalsOf[p][eventName]
		if sig then
			sig:Fire()
			fired += 1
			if limit and fired >= limit then
				break
			end
		end
	end
	return fired
end

-- ── scheduler (task.*) ──────────────────────────────────────────────────────
local queue = {}
local errors = {}
local function resume(co, ...)
	local ok, err = coroutine.resume(co, ...)
	if not ok then
		table.insert(errors, debug.traceback(co, tostring(err)))
	end
end
local task = {}
function task.spawn(fn, ...)
	local co = if type(fn) == "thread" then fn else coroutine.create(fn)
	resume(co, ...)
	return co
end
function task.defer(fn, ...)
	local co = coroutine.create(fn)
	table.insert(queue, { co = co, args = table.pack(...) })
	return co
end
function task.delay(_, fn, ...)
	return task.defer(fn, ...)
end
function task.wait(_)
	if coroutine.isyieldable() then
		table.insert(queue, { co = coroutine.running(), args = table.pack(0) })
		return coroutine.yield()
	end
	return 0
end
local function pump(steps: number)
	for _ = 1, steps do
		local q = queue
		queue = {}
		if #q == 0 then
			return
		end
		for _, item in q do
			if coroutine.status(item.co) == "suspended" then
				resume(item.co, table.unpack(item.args, 1, item.args.n))
			end
		end
	end
	queue = {} -- abandon endless loops (pulsing animations etc.)
end

-- ── services ────────────────────────────────────────────────────────────────
local dm = roblox.Instance.new("DataModel")
local localPlayer = roblox.Instance.new("Player")
localPlayer.Name = "Tester"
localPlayer.Parent = dm:GetService("Players")
local playerGui = roblox.Instance.new("PlayerGui")
playerGui.Parent = localPlayer

local sharedRoot -- assigned below; the ReplicatedStorage stub hands it out

local services = {}
local function service(name: string)
	if services[name] then
		return services[name]
	end
	local s
	if name == "ReplicatedStorage" then
		s = {
			WaitForChild = function(_, child)
				assert(child == "LifeSim", "unexpected ReplicatedStorage child " .. tostring(child))
				return sharedRoot
			end,
			FindFirstChild = function(_, child)
				return if child == "LifeSim" then sharedRoot else nil
			end,
		}
	elseif name == "TextService" then
		s = {
			FilterStringAsync = function(_, text, userId, context)
				assert(type(text) == "string" and type(userId) == "number" and luneTypeof(context) == "EnumItem", "bad FilterStringAsync args")
				return {
					GetNonChatStringForBroadcastAsync = function()
						return if string.find(string.lower(text), "badword") then "#######" else text
					end,
				}
			end,
		}
	elseif name == "TweenService" then
		s = {
			Create = function(_, inst, info, props)
				assert(type(info) == "table" and info.__tweenInfo, "TweenService:Create needs a TweenInfo")
				return {
					Play = function()
						for k, v in props do
							inst[k] = v -- validates tweened property names and types
						end
					end,
					Cancel = function() end,
					Completed = Signal.new(),
				}
			end,
		}
	elseif name == "RunService" then
		s = {
			Heartbeat = Signal.new(),
			RenderStepped = Signal.new(),
			BindToRenderStep = function(_, _name, _prio, fn)
				fn(1 / 60)
				fn(1 / 60)
			end,
			UnbindFromRenderStep = function() end,
			PreSimulation = Signal.new(),
			PostSimulation = Signal.new(),
			IsStudio = function()
				return true
			end,
		}
	elseif name == "Players" then
		s = wrap(dm:GetService("Players"))
	elseif name == "StarterGui" then
		s = { SetCoreGuiEnabled = function() end, SetCore = function() end }
	elseif name == "UserInputService" then
		-- a phone: touch only
		s = {
			TouchEnabled = true,
			KeyboardEnabled = false,
			MouseEnabled = false,
			GamepadEnabled = false,
			InputBegan = Signal.new(),
			InputChanged = Signal.new(),
			InputEnded = Signal.new(),
			LastInputTypeChanged = Signal.new(),
		}
	elseif name == "GuiService" then
		s = { IsTenFootInterface = function()
			return false
		end, SelectedObject = nil, AutoSelectGuiEnabled = true }
	elseif name == "TextChatService" then
		-- no chat channel here: city news falls back to StarterGui:SetCore
		s = { FindFirstChild = function()
			return nil
		end }
	elseif name == "ContextActionService" then
		s = { BindAction = function() end, UnbindAction = function() end }
	elseif name == "SoundService" then
		s = wrap(dm:GetService("SoundService"))
		Methods.PlayLocalSound = function() end
	else
		s = wrap(dm:GetService(name))
	end
	services[name] = s
	return s
end

local RandomStub = {}
RandomStub.__index = RandomStub
function RandomStub.new(seed)
	return setmetatable({ seed = seed }, RandomStub)
end
function RandomStub:NextNumber(a, b)
	a = a or 0
	b = b or 1
	return a + math.random() * (b - a)
end
function RandomStub:NextInteger(a, b)
	return math.random(a, b)
end

Loader.globals = {
	game = { GetService = function(_, name)
		return service(name)
	end },
	workspace = nil,
	Instance = {
		new = function(className, parent)
			local p = wrap(roblox.Instance.new(className))
			if parent then
				p.Parent = parent
			end
			return p
		end,
	},
	UDim = roblox.UDim,
	UDim2 = roblox.UDim2,
	Vector2 = roblox.Vector2,
	Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame,
	Color3 = roblox.Color3,
	ColorSequence = roblox.ColorSequence,
	ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	NumberSequence = roblox.NumberSequence,
	NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
	NumberRange = roblox.NumberRange,
	Enum = roblox.Enum,
	Font = roblox.Font,
	Random = RandomStub,
	TweenInfo = {
		new = function(...)
			return { __tweenInfo = true, args = { ... } }
		end,
	},
	task = task,
	typeof = function(v)
		if type(v) == "table" and realOf[v] then
			return "Instance"
		end
		return luneTypeof(v)
	end,
}
-- Roblox's profiler marks (the vendored CameraShaker calls them every frame) do nothing here
Loader.globals.debug = setmetatable({ profilebegin = function() end, profileend = function() end }, { __index = debug })
Loader.globals.workspace = service("Workspace")
Loader.globals.localPlayer = wrap(localPlayer)
Loader.globals.realPlayers = dm:GetService("Players")
userIds[localPlayer] = 4242

-- a clock that advances like a player clicking at a human pace, so the
-- server's rate limiter doesn't reject the test's rapid-fire requests
local fakeClock = 0
Loader.globals.os = setmetatable({
	clock = function()
		fakeClock += 0.3
		return fakeClock
	end,
}, { __index = os })

-- ProfileStore stand-in: an in-memory profile per key.
local savedProfiles = {}
Loader.overrides["src/server/ProfileStore.luau"] = {
	New = function(storeName, template)
		assert(type(storeName) == "string", "store name")
		return {
			StartSessionAsync = function(_, key, params)
				assert(type(key) == "string" and type(params) == "table" and type(params.Cancel) == "function", "StartSessionAsync args")
				local function copy(t)
					if type(t) ~= "table" then
						return t
					end
					local o = {}
					for k, v in t do
						o[k] = copy(v)
					end
					return o
				end
				local profile = {
					Data = savedProfiles[key] or copy(template),
					OnSessionEnd = Signal.new(),
				}
				savedProfiles[key] = profile.Data
				function profile:AddUserId() end
				function profile:Reconcile()
					for k, v in template do
						if self.Data[k] == nil then
							self.Data[k] = copy(v)
						end
					end
				end
				function profile:EndSession() end
				function profile:Save()
					marshal(self.Data, "profile") -- what a DataStore would reject
				end
				return profile
			end,
		}
	end,
}

-- ── data from the real engine ───────────────────────────────────────────────
sharedRoot = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Engine = Loader.require(sharedRoot.Engine)
local pack = Loader.pack(sharedRoot)
local sim = Engine.new(pack)

-- The UI cases were written against the original pack's ids; on the City pack (LIFESIM_PACK=City)
-- the setup uses City ids, cases that need the original pack's content are skipped, and a
-- City case drives the v0.5 screens and whole lives through the real server and client.
local CITY = pack.fanWork == true
local FIX = if CITY
	then { origin = "backstreets_family", orphan = "street_orphan", district = "d14", oddJob = "odd_jobs", deadOrigin = "fixer_family" }
	else { origin = "ordinary", orphan = "orphan", district = "foundry", oddJob = "wade", deadOrigin = "divers_kid" }
local info = { meta = pack.meta, stats = { order = pack.stats.order, defs = {}, sanity = pack.stats.sanity }, city = sim:cityInfo(), categories = pack.activityCategories }
for _, key in pack.stats.order do
	local s = pack.stats[key]
	info.stats.defs[key] = { name = s.name, short = s.short, color = s.color, desc = s.desc }
end
info.avatar = { cosmetics = pack.cosmetics, gear = pack.gear, conditions = pack.conditions, forms = pack.forms }


local function playUntil(life, predicate, maxYears)
	local brain = { rng = Engine.Rng.seed(99) }
	local lastReport = nil
	local clash = nil
	for _ = 1, maxYears do
		if not life.alive then
			break
		end
		if predicate(life, lastReport) then
			return lastReport, clash
		end
		if life.pending then
			local v = sim:view(life)
			local opts = {}
			for _, c in v.pending.choices do
				if c.enabled then
					table.insert(opts, c.index)
				end
			end
			lastReport = sim:choose(life, Engine.Rng.pick(brain, opts))
		else
			for _, a in sim:view(life).activities do
				if a.enabled and a.id ~= "move_down" and life.actionsLeft > 0 and not life.pending then
					lastReport = sim:doActivity(life, a.id) or lastReport
				end
			end
			if life.pending then
				continue
			end
			lastReport = sim:ageUp(life)
		end
		if lastReport and lastReport.clash then
			clash = lastReport.clash
		end
	end
	return lastReport, clash
end

-- a life that is mid-event, with a clash on record
local life = sim:newLife({ seed = 4242, originId = FIX.origin, district = FIX.district })
local report, clash = playUntil(life, function(l)
	return l.pending ~= nil and l.age >= 14
end, 200)
if not clash then
	-- an activity with a clash in it
	local wadeLife = sim:newLife({ seed = 777, originId = FIX.orphan })
	wadeLife.age = 20
	for _, a in pack.activities do
		if not clash and (a.id == FIX.oddJob or a.clash) then
			local r = sim:doActivity(wadeLife, a.id)
			clash = r and r.clash
		end
	end
	-- or any event with a clash choice, forced
	for _, e in pack.events do
		if not clash and e.choices and wadeLife.alive then
			for i, c in e.choices do
				if c.clash and not clash then
					wadeLife.pending = nil
					local ok = pcall(function()
						sim:forceEvent(wadeLife, e.id)
						if wadeLife.pending then
							local r = sim:choose(wadeLife, i, "steady")
							clash = r and r.clash
						end
					end)
					if not ok then
						wadeLife.pending = nil
					end
				end
			end
		end
	end
end
assert(clash, "could not produce a clash for the test")

local fakeMeta = {
	glow = 3,
	livesPlayed = 4,
	bestAge = 71,
	lanterns = {},
	origins = {},
	records = {},
	cosmetics = { ["mark:ink"] = true },
}
for _, r in pack.records do
	table.insert(fakeMeta.records, { id = r.id, name = r.name, desc = r.desc, unlocked = r.id == "old_bones" })
end
for _, o in pack.origins do
	table.insert(fakeMeta.origins, { id = o.id, name = o.name, desc = o.desc, side = if o.side then pack.sides[o.side].short else nil, cost = o.glowCost or 0, unlocked = (o.glowCost or 0) == 0 })
end

-- a finished life for the death screen
local dead = sim:newLife({ seed = 31337, originId = FIX.deadOrigin })
playUntil(dead, function()
	return false
end, 400)
local lantern = sim:lantern(dead)
table.insert(fakeMeta.lanterns, lantern)
table.insert(fakeMeta.lanterns, { id = "x", name = "Old Lantern", born = 300, died = 344, age = 44, zone = "Silt", career = nil, form = "Human", cause = "Old age", epitaph = "Test.", highlights = {}, score = 3, glow = 1, released = true })

-- ── build every screen ──────────────────────────────────────────────────────
local calls = {}
local ctx = {
	info = info,
	state = { life = sim:view(life), meta = fakeMeta },
	sound = function() end,
	toast = function() end,
	actions = setmetatable({}, {
		__index = function(_, name)
			return function(...)
				table.insert(calls, name)
				local args = { ... }
				if type(args[#args]) == "function" then
					args[#args]()
				end
			end
		end,
	}),
}

local clientRoot = Loader.preload(Loader.node("src/client", "Client", nil))
local serverRoot = Loader.preload(Loader.node("src/server", "Server", nil))
local UI = clientRoot.UI

local function makeColumn(name)
	local gui = Loader.globals.Instance.new("ScreenGui")
	gui.Name = name
	gui.Parent = wrap(playerGui)
	local column = Loader.globals.Instance.new("Frame")
	column.Name = "Column"
	column:SetAttribute("Column", true)
	column.Parent = gui
	return column
end

-- Layout audit: a GuiObject that sits beside a UIListLayout/UIGridLayout gets
-- its Position overridden by the layout. Anything there with a Position,
-- an AnchorPoint, or a full-height size (in a vertical list) was meant to float
-- and will be stacked into the list instead.
local layoutFlags = {}
local function auditLayouts()
	for _, inst in playerGui:GetDescendants() do
		local layout = inst:FindFirstChildOfClass("UIListLayout") or inst:FindFirstChildOfClass("UIGridLayout")
		if layout then
			local vertical = layout.FillDirection == roblox.Enum.FillDirection.Vertical
			for _, child in inst:GetChildren() do
				if child:IsA("GuiObject") and child.Visible then
					local pos, anchor, size = child.Position, child.AnchorPoint, child.Size
					local why = nil
					if pos.X.Scale ~= 0 or pos.X.Offset ~= 0 or pos.Y.Scale ~= 0 or pos.Y.Offset ~= 0 then
						why = "has a Position"
					elseif anchor.X ~= 0 or anchor.Y ~= 0 then
						why = "has an AnchorPoint"
					elseif layout:IsA("UIListLayout") and ((vertical and size.Y.Scale >= 1) or (not vertical and size.X.Scale >= 1)) then
						why = "fills the list's direction"
					end
					if why then
						local key = child:GetFullName() .. " " .. why
						if not layoutFlags[key] then
							layoutFlags[key] = true
							print("      layout: " .. key)
						end
					end
				end
			end
		end
	end
end

local results = {}
local function case(name: string, fn, steps: number?)
	local before = #errors
	local co = coroutine.create(fn)
	resume(co)
	pump(steps or 400)
	auditLayouts()
	if coroutine.status(co) ~= "dead" and #errors == before then
		table.insert(errors, name .. ": did not finish")
	end
	local ok = #errors == before
	table.insert(results, { name = name, ok = ok })
	print(string.format("  %s  %s", if ok then "ok  " else "FAIL", name))
end

print("UI smoke test" .. (if CITY then " (City pack)" else ""))
-- a case that needs the original pack's content (its ids are written into the case)
local function ucase(name: string, fn, steps: number?)
	if CITY then
		print("  skip  " .. name .. "  (original pack only)")
		return
	end
	case(name, fn, steps)
end

case("Theme/Kit/Format load", function()
	Loader.require(UI.Theme)
	Loader.require(UI.Kit)
	local Format = Loader.require(UI.Format)
	assert(Format.number(1234567) == "1,234,567", "number format")
	assert(Format.number(-1200) == "-1,200", "negative format")
	assert(Format.escape("<a & b>") == "&lt;a &amp; b&gt;", "escape")
end)

case("Hud: build, setLife, log, busy", function()
	local Hud = Loader.require(UI.Hud)
	local hud = Hud.build(ctx, makeColumn("Main"))
	hud:show(true)
	hud:setLife(sim:view(life))
	hud:resetLog(life.log)
	hud:appendEntries(report and report.entries or {})
	hud:setBusy(true)
	hud:setBusy(false)
	fireAll(hud.root, "Activated")
	local negative = sim:view(life)
	negative.sanity = -30
	negative.money = -50
	hud:setLife(negative)
end)

case("EventCard: pending event + choose", function()
	local EventCard = Loader.require(UI.EventCard)
	local view = sim:view(life)
	assert(view.pending, "expected a pending event")
	local column = makeColumn("Modal")
	local chosen = nil
	EventCard.show(ctx, column, view.pending, function(i)
		chosen = i
	end)
	fireAll(column.Parent, "Activated", 1)
	fireAll(column, "MouseButton1Down")
	fireAll(column, "MouseLeave")
	-- every hook event should render too
	local bp = sim:newLife({ seed = 5, originId = "ordinary" })
	bp.age = 30
	local hook = pack.hooks.breakingPoint
	for i, id in (if type(hook) == "table" then hook else { hook }) do
		bp.pending = id
		EventCard.show(ctx, makeColumn("Modal2_" .. i), sim:view(bp).pending, function() end)
	end
end)

case("ClashView: play a real clash", function()
	local ClashView = Loader.require(UI.ClashView)
	ClashView.play(ctx, makeColumn("Clash"), clash)
end)

ucase("Sheets: activities + life tabs", function()
	local Sheets = Loader.require(UI.Sheets)
	local column = makeColumn("Sheets")
	ctx.state.life = sim:view(life)
	local a = Sheets.activities(ctx, column)
	fireAll(a.panel, "Activated")
	for _, tab in { "Career", "People", "Ledger" } do
		local s = Sheets.life(ctx, column, tab)
		fireAll(s.panel, "Activated", 12)
	end
	-- with a job
	local worker = sim:newLife({ seed = 8, originId = "company_family", district = "glasswall" })
	worker.age = 20
	worker.stats.justice = 40
	worker.stats.fortitude = 40
	worker.stats.temperance = 50
	assert(sim:joinCareer(worker, "company"))
	assert(worker.career.district == "glasswall", "company job should belong to the Ward")
	worker.actionsLeft = 3
	assert(sim:doActivity(worker, "move_district", "kelpmarket"))
	assert(worker.career == nil, "changing Wards should end a company job")
	assert(worker.district == "kelpmarket" and worker.side == "gutters", "move should land in the Gutters of the new Ward")
	assert(sim:joinCareer(worker, "diver"))
	ctx.state.life = sim:view(worker)
	local s = Sheets.life(ctx, column, "Career")
	fireAll(s.panel, "Activated")
end)

ucase("District sheet, Ward picker, Friends tab, Prompt", function()
	local Sheets = Loader.require(UI.Sheets)
	local Prompt = Loader.require(UI.Prompt)
	local column = makeColumn("Extra")
	ctx.state.life = sim:view(life)
	local d = Sheets.district(ctx, column)
	fireAll(d.panel, "Activated", 3)
	local picked = "unset"
	local picker = Sheets.wardPicker(ctx, column, { includeRandom = true, currentId = "foundry", onPick = function(id)
		picked = id
	end })
	fireAll(picker.panel, "Activated", 4)
	assert(picked ~= "unset", "ward picker never picked")
	local friends = {
		links = { { userId = 7, name = "Pal", online = true, character = { first = "Ossa", last = "Vell", age = 30, alive = true, zone = "the Gutters of Kelpmarket" } }, { userId = 8, name = "Gone", online = false } },
		players = { { userId = 9, name = "Stranger" } },
		invites = { { userId = 10, name = "Asker" } },
		rough = false,
		max = 8,
	}
	local host = Loader.globals.Instance.new("Frame")
	host.Parent = column
	Sheets.friendsContent(ctx, host, nil, function() end)
	Sheets.friendsContent(ctx, host, friends, function() end)
	fireAll(host, "Activated")
	local tabs = Sheets.life(ctx, column, "Friends")
	fireAll(tabs.panel, "Activated", 3)
	Sheets.life(ctx, column, "City")
	Prompt.show(column, { title = "Link lives?", text = "Test", buttons = { { label = "No" }, { label = "Yes", style = "primary" } } })
	fireAll(column, "Activated")
end)

ucase("Gear tab, workshop and approach picker", function()
	local Sheets = Loader.require(UI.Sheets)
	local EventCard = Loader.require(UI.EventCard)
	local Prompt = Loader.require(UI.Prompt)
	local column = makeColumn("GearTest")
	ctx.prompt = function(opts)
		return Prompt.show(column, opts)
	end
	local g = sim:newLife({ seed = 77, originId = "ordinary" })
	g.age = 20
	g.money = 500
	assert(sim:buyGear(g, "dock_knife"), "couldn't buy a knife")
	assert(sim:buyGear(g, "oilskin"), "couldn't buy a coat")
	assert(not sim:buyGear(g, "diving_lamp"), "diving lamp should need the Guild")
	ctx.state.life = sim:view(g)
	assert(#ctx.state.life.gear == 2 and #ctx.state.life.shop > 5, "gear/shop missing from view")
	local tab = Sheets.life(ctx, column, "Gear")
	fireAll(tab.panel, "Activated", 4)
	local shop = Sheets.shop(ctx, column)
	fireAll(shop.panel, "Activated", 6)
	local acts = Sheets.activities(ctx, column)
	fireAll(acts.panel, "Activated")
	-- a clash choice opens the approach picker; picking one returns its id
	local p = sim:newLife({ seed = 78, originId = "ordinary" })
	p.age = 25
	p.money = -50
	p.pending = "core_debt_collector"
	local view = sim:view(p)
	local picked = nil
	local holder = Loader.globals.Instance.new("Frame")
	holder:SetAttribute("Column", true)
	holder.Parent = column.Parent
	EventCard.show(ctx, holder, view.pending, function(i, approach)
		picked = { i, approach }
	end)
	local clashChoice = nil
	for _, d in holder:GetDescendants() do
		if d:IsA("TextButton") and d.Name == "Choice" and d.LayoutOrder == 4 then
			clashChoice = d
		end
	end
	assert(clashChoice, "clash choice button missing")
	signalsOf[clashChoice].Activated:Fire()
	local approachButton = nil
	for _, d in holder:GetDescendants() do
		if d:IsA("TextButton") and d.Name == "Approach" and d.Parent.Parent.Visible then
			approachButton = approachButton or d
		end
	end
	assert(approachButton, "approach picker didn't open")
	signalsOf[approachButton].Activated:Fire()
	assert(picked and picked[1] == 2 and type(picked[2]) == "string", "approach pick didn't come back")
	-- the engine honors it
	local res = sim:choose(p, picked[1], picked[2])
	assert(res and res.clash and res.clash.approach == picked[2], "engine ignored the approach")
end)

case("Screens: loading, new life, death", function()
	local Screens = Loader.require(UI.Screens)
	local column = makeColumn("Screens")
	local loading = Screens.loading(ctx, column)
	loading.setTitle("Undermere")
	loading.setStatus("Testing...")
	loading.stop()
	local nl = Screens.newLife(ctx, column, column)
	nl.refresh()
	fireAll(nl.frame, "Activated", 20)
	local death = Screens.death(ctx, column)
	death.show(lantern, sim:view(dead))
	fireAll(death.frame, "Activated")
end)

ucase("Avatars: portrait, companions, friend news, creator", function()
	local function fire(p, name)
		local sig = signalsOf[p] and signalsOf[p][name]
		if sig then
			sig:Fire()
			return true
		end
		return false
	end
	local Hud = Loader.require(UI.Hud)
	local hud = Hud.build(ctx, makeColumn("AvatarMain"))
	local v = sim:view(life)
	hud:setLife(v)
	local figure = hud.portrait.model
	local count = #figure:GetChildren()
	assert(count >= 10, "portrait should be built from parts, got " .. count)
	for _, part in figure:GetChildren() do
		assert(part:IsA("Part") and part.Anchored and part.Size.X > 0, "bad portrait part")
	end
	assert(hud.portrait.camera.CFrame.Position.Z < 0, "camera should look at the figure's face")
	-- new gear shows on the figure
	local geared = table.clone(v)
	geared.appearance = table.clone(v.appearance)
	geared.appearance.gear = { coat = "oilskin", tool = "hook_pole", charm = "little_bell" }
	hud:setLife(geared)
	assert(#figure:GetChildren() > count, "gear should show on the portrait")
	-- a linked friend appears in the companions strip
	geared.relations = table.clone(geared.relations)
	table.insert(geared.relations, {
		id = 99, kind = "friend", kindName = "Linked friend", name = "Ossa Vell", age = 30, bond = 60, alive = true,
		linked = true, online = true, userId = 42, player = "OssaPlayer",
		appearance = { look = { skin = "deep", hair = "bun" }, age = 30, gear = { coat = "dock_jacket" } },
	})
	hud:setLife(geared)
	assert(hud.companions.Visible, "companions strip should show linked friends")
	local chips = 0
	for _, c in hud.companionList:GetChildren() do
		if c.Name == "Companion" then
			chips += 1
			fire(c, "Activated")
		end
	end
	assert(chips == 1, "one companion chip expected, got " .. chips)
	assert(hud.companionViews[42] and #hud.companionViews[42].model:GetChildren() >= 8, "companion portrait missing")
	hud:appendEntries({ { kind = "friend", name = "Ossa Vell", text = "Ossa was promoted to Diver." } })

	-- the creator: free picks select, locked ones prompt or explain, and the look reaches newLife
	local captured, prompted, toasts = nil, 0, 0
	local cctx = table.clone(ctx)
	cctx.prompt = function()
		prompted += 1
	end
	cctx.toast = function()
		toasts += 1
	end
	cctx.actions = setmetatable({
		newLife = function(origin, name, district, look)
			captured = { origin = origin, look = look }
		end,
	}, { __index = ctx.actions })
	local Screens = Loader.require(UI.Screens)
	local creatorColumn = makeColumn("Creator")
	local nl = Screens.newLife(cctx, creatorColumn, makeColumn("CreatorSheets"))
	nl.refresh()
	nl.frame.Visible = true
	local options = {}
	for _, d in nl.frame:GetDescendants() do
		if d.Name == "LookOption" then
			table.insert(options, d)
		end
	end
	assert(#options >= 30, "creator should list cosmetic options, got " .. #options)
	for _, o in options do
		fire(o, "Activated")
	end
	assert(prompted >= 1, "an affordable Glow cosmetic should ask before unlocking")
	assert(toasts >= 1, "a Record cosmetic should explain how to unlock it")
	local began = false
	for _, d in nl.frame:GetDescendants() do
		if d:IsA("TextButton") and d.Text == "OPEN THE FILE" then
			began = fire(d, "Activated")
		end
	end
	assert(began and captured and type(captured.look) == "table" and captured.look.skin, "newLife should get the chosen look")
	print(string.format("      portrait parts: %d (%d with gear), creator options: %d", count, #figure:GetChildren(), #options))

	-- a person's card: figure plus things to do together
	local Sheets = Loader.require(UI.Sheets)
	-- a fresh adult with a free year (the main test life is waiting on an event)
	local plife = sim:newLife({ seed = 2468, originId = "ordinary" })
	plife.age = 20
	local target = nil
	for _, rel in sim:view(plife).relations do
		if rel.alive and rel.interactions then
			for _, act in rel.interactions do
				if act.enabled then
					target = rel
				end
			end
		end
	end
	assert(target, "expected someone to interact with")
	local before = #calls
	local personSheet = Sheets.person(ctx, makeColumn("Person"), target)
	fireAll(personSheet.panel, "Activated")
	local interacted = false
	for i = before + 1, #calls do
		if calls[i] == "interact" then
			interacted = true
		end
	end
	assert(interacted, "tapping an interaction should call actions.interact")
end)

ucase("Social: rankings, store, crew, goals, celebrations, crew stage card", function()
	local Social = Loader.require(UI.Social)
	local Celebrate = Loader.require(UI.Celebrate)
	local EventCard = Loader.require(UI.EventCard)
	local sctx = table.clone(ctx)
	sctx.prompt = function() end
	local v = sim:view(life)
	v.ambitions = { { id = "a", name = "Earn your keep", desc = "Get a job.", progress = 0.5 } }
	v.score = 321
	sctx.state = { life = v, meta = fakeMeta }
	local sampleBoard = {
		id = "best", name = "Best life", unit = "points", desc = "Test board.",
		entries = {
			{ rank = 1, value = 812, name = "Mira", life = "Ossa Vell", title = "The Gilded", patron = true },
			{ rank = 2, value = 640, name = "You", life = "Brann Ashby", title = "A Quiet Life", you = true },
			{ rank = 3, value = 410, name = "Pell", life = "Una Rook" },
		},
	}
	local sampleStore = {
		{ key = "dye", name = "Dye", desc = "A dye.", price = 25, tier = "Small", kind = "product", owned = false, buyable = true, test = true, grants = { "hairColor:lantern" } },
		{ key = "frame", name = "Red File", desc = "Red brackets.", price = 79, tier = "Medium", kind = "product", owned = false, buyable = true, test = true, grants = { "frame:crimson" } },
		{ key = "big", name = "Big Pack", desc = "Very shiny.", price = 499, tier = "Big", kind = "product", owned = true, buyable = true, grants = { "outfit:gilded", "frame:gold" } },
		{ key = "pass", name = "Patron", desc = "A pass.", price = 299, tier = "Big", kind = "pass", owned = false, buyable = true, grants = { "badge:patron" } },
	}
	local bought = 0
	sctx.actions = setmetatable({
		loadLeaderboard = function(_, after)
			after(sampleBoard)
		end,
		loadStore = function(after)
			after(sampleStore, "Looks only.")
		end,
		buyItem = function(_, after)
			bought += 1
			after(sampleStore)
		end,
		crewCall = function(action, _, after)
			table.insert(calls, action)
			if after then
				after({
					ok = true,
					crew = {
						id = 1, leader = 1, captain = true, max = 4,
						members = {
							{ userId = 1, name = "Me", leader = true, character = { first = "A", last = "B", age = 30, alive = true, appearance = v.appearance } },
							{ userId = 2, name = "Pal", character = { first = "C", last = "D", age = 28, alive = true, appearance = v.appearance }, ready = true },
						},
						proposal = { id = "lost_bell", name = "The Lost Bell", desc = "Test.", secondsLeft = 40, youReady = false },
					},
					players = { { userId = 3, name = "Stranger" } },
					invites = { { userId = 4, name = "Inviter" } },
				})
			end
		end,
	}, { __index = ctx.actions })
	local column = makeColumn("Social")
	local ranks = Social.rankings(sctx, column)
	local rows = 0
	for _, d in ranks.panel:GetDescendants() do
		if d.Name == "Rank" then
			rows += 1
		end
	end
	assert(rows == 3, "rankings should list 3 rows, got " .. rows)
	fireAll(ranks.panel, "Activated")
	local store = Social.store(sctx, column)
	local tryOns, swatches = 0, 0
	for _, d in store.panel:GetDescendants() do
		if d.Name == "TryOn" then
			tryOns += 1
		elseif d.Name == "FrameSwatch" then
			swatches += 1
		end
	end
	assert(tryOns == 2 and swatches == 1, string.format("store try-on: %d figures, %d swatches", tryOns, swatches))
	fireAll(store.panel, "Activated")
	assert(bought >= 1, "store buy button should call buyItem")
	local crew = Social.crew(sctx, column)
	fireAll(crew.panel, "Activated")
	Social.goals(sctx, column)
	Celebrate.banner(sctx, column, { title = "Ambition met", sub = "Get a job." })
	local closeDaily = Celebrate.daily(sctx, column, { streak = 3, day = 3, glow = 2, rewards = { 1, 1, 2, 1, 2, 2, 4 } })
	closeDaily()
	local setWorld = Celebrate.world(sctx, column)
	setWorld({ id = "breach_tidewell", name = "Breach", headline = "BREACH", text = "Sirens.", tone = "danger", secondsLeft = 90, expedition = "tidewell_containment" })
	setWorld({ id = "breach_tidewell", ended = true })
	-- a crewmate's stage card: taps suggest instead of choosing
	local suggested, chose = 0, 0
	local plife = sim:newLife({ seed = 999, originId = "ordinary" })
	plife.age = 25
	plife.money = 200
	plife.pending = nil
	local Expedition = Loader.require(sharedRoot.Engine.Expedition)
	local run = Expedition.start(sim, { plife }, "lost_bell")
	local card = Expedition.view(sim, { plife }, run)
	EventCard.show(sctx, makeColumn("RunModal"), {
		title = card.stage.title, text = card.stage.text, choices = card.stage.choices,
		band = { band = roblox.Color3.fromRGB(34, 92, 88), label = card.name }, step = "Mission  ·  step 1",
		crew = { { appearance = v.appearance }, { appearance = v.appearance } }, readOnly = true, note = "Captain decides.",
	}, function()
		chose += 1
	end, function()
		suggested += 1
	end)
	local modal = column.Parent.Parent:FindFirstChild("RunModal")
	fireAll(modal, "Activated")
	assert(suggested >= 1 and chose == 0, "crewmates should suggest, not choose")
end)

case("Backdrop: build the city", function()
	local Backdrop = Loader.require(clientRoot.Backdrop)
	Backdrop.build()
	for _, side in { "gutters", "charter" } do
		for _, d in { "foundry", "glasswall", "drownside" } do
			Backdrop.setArea({ district = d, side = side, world = "breach_tidewell", run = "dungeon" })
		end
	end
	local folder = service("Workspace"):FindFirstChild("LifeSimBackdrop")
	assert(folder, "backdrop folder missing")
	print("      backdrop parts: " .. #folder:GetDescendants())
	folder.Parent = nil
	-- the City skyline (City pack): ten Districts, Nest and Backstreets views
	local City = Loader.require(clientRoot.BackdropCity)
	local districts = {}
	for i = 1, 10 do
		table.insert(districts, { id = "d" .. i, color = { 40 + i * 20, 120, 200 } })
	end
	City.build(districts)
	for _, side in { "gutters", "charter" } do
		for i = 1, 10, 3 do
			City.setArea({ district = "d" .. i, index = i, side = side, world = "abnormality_breach", run = "dungeon" })
		end
	end
	City.cinematic(true)
	City.cinematic(false)
	local cityFolder = service("Workspace"):FindFirstChild("LifeSimBackdrop")
	assert(cityFolder, "city backdrop folder missing")
	print("      city skyline parts: " .. #cityFolder:GetDescendants())
end)

ucase("Integration: real server + client app, several lives", function()
	-- a test-only linked-friend event, so the friend system can be checked
	-- even before the content pack has its own
	table.insert(pack.events, {
		id = "test_linked_rent",
		title = "Rent for {linked}",
		text = "{linked} is short on rent this year and too proud to say so.",
		weight = 1000,
		cooldown = 1,
		when = { linked = true },
		choices = {
			{ label = "Send {linked} some money", result = { money = -5, log = "You sent {linked} some money.", linked = { money = 5, sanity = 1, log = "{sender} sent you some money." } } },
			{ label = "Can't spare it", result = { log = "You couldn't help this time." } },
		},
	})
	local Server = Loader.require(serverRoot)
	Server.start()
	local App = Loader.require(clientRoot.App)
	App.start()
	local actx = App.ctx
	assert(actx and actx.actions, "App.ctx missing")
	local gui = wrap(playerGui)
	-- (v0.18) this scheduler gives every wait no time and drops whatever is still waiting after a
	-- while, so a scene that plays for seconds on the 3D stage would be cut off halfway, its card
	-- never shown. The scenes have their own tests (fx_check, gui_snapshot); here they're off, as
	-- a player can set them.
	actx.actions.setSetting("cutscenes", "off")

	-- taps the top-most enabled choice on the event card; a clash choice opens
	-- the approach picker, so then it taps the first approach too
	local function clickFirstChoice(): boolean
		local modal = gui:FindFirstChild("LifeSimModal")
		if not modal then
			return false
		end
		local best, bestOrder = nil, math.huge
		for _, d in modal:GetDescendants() do
			if d:IsA("TextButton") and d.Name == "Choice" and d.TextTransparency == 0 then
				local sig = signalsOf[d] and signalsOf[d].Activated
				if sig and d.LayoutOrder < bestOrder then
					best, bestOrder = sig, d.LayoutOrder
				end
			end
		end
		if not best then
			return false
		end
		best:Fire()
		for _, d in modal:GetDescendants() do
			if d:IsA("TextButton") and d.Name == "Approach" then
				local holder = d.Parent and d.Parent.Parent
				if holder and holder.Visible then
					signalsOf[d].Activated:Fire()
					break
				end
			end
		end
		return true
	end

	assert(actx.state.life == nil, "fresh save should have no life")
	actx.actions.newLife("ordinary", "badword", "kelpmarket") -- filtered name falls back to random
	assert(actx.state.life and actx.state.life.alive, "new life did not start")
	assert(actx.state.life.first ~= "Badword", "name filter was bypassed")
	actx.actions.newLife("ordinary", "Ossa") -- abandoning a living life needs confirm (App sends it)
	assert(actx.state.life.first == "Ossa", "named life did not start")

	local deaths, years, choices, activities = 0, 0, 0, 0
	for _ = 1, 3000 do
		-- let clash animations / death transitions finish, like a player would (the death scene
		-- keeps time by the clock, so it can take many steps here)
		local spins = 0
		while (actx.state.busy or actx.state.applying or actx.state.cinema) and spins < 20000 do
			spins += 1
			task.wait()
		end
		local life = actx.state.life
		if not life.alive then
			deaths += 1
			local lantern = actx.state.meta.lanterns[1]
			assert(lantern and lantern.id == life.id, "death did not produce a lantern")
			actx.actions.releaseLantern(lantern.id)
			assert(actx.state.meta.lanterns[1].released, "release did not stick")
			if deaths >= 4 then
				break
			end
			if life.heirs and #life.heirs > 0 then
				actx.actions.continueHeir(life.heirs[1].id)
			else
				actx.actions.newLife("orphan", "")
			end
			assert(actx.state.life.alive, "next life did not start")
		elseif life.pending then
			assert(clickFirstChoice(), "pending event but no choice button on screen")
			choices += 1
		else
			for _, a in life.activities do
				if a.enabled and a.id ~= "move_down" and math.random() < 0.35 then
					actx.actions.doActivity(a.id)
					activities += 1
					break
				end
			end
			if not actx.state.life.pending and actx.state.life.alive then
				actx.actions.ageUp()
				years += 1
			end
		end
		task.wait()
	end
	-- unlock with earned glow, if any is affordable
	for _, o in actx.state.meta.origins do
		if not o.unlocked and actx.state.meta.glow >= o.cost then
			actx.actions.unlockOrigin(o.id)
			break
		end
	end
	print(string.format("      %d years, %d choices, %d activities, %d deaths, %d remote calls, glow %d", years, choices, activities, deaths, remoteCalls, actx.state.meta.glow))
	assert(deaths >= 1, "nobody died in 3000 steps")

	-- ── a second player joins and links lives ──
	local function settle()
		local spins = 0
		while (actx.state.busy or actx.state.applying or actx.state.cinema) and spins < 20000 do
			spins += 1
			task.wait()
		end
		for _ = 1, 3 do
			task.wait()
		end
	end
	local realP2 = roblox.Instance.new("Player")
	realP2.Name = "Pal"
	userIds[realP2] = 777
	realP2.Parent = dm:GetService("Players")
	local p2 = wrap(realP2)
	local playersSvc = service("Players")
	signalsOf[playersSvc].PlayerAdded:Fire(p2)
	local remotesFolder = sharedRoot:FindFirstChild("Remotes")
	local requestFn = remotesFolder:FindFirstChild("Request")
	local function asP2(action, payload)
		return marshal(callbacks[requestFn](p2, action, marshal(payload, "p2 args")), "p2 response")
	end
	local r2 = asP2("newLife", { origin = "ordinary", first = "Mira", district = "pumpside", look = { skin = "deep", hair = "veil", outfit = "clerk", hairColor = "rust" } })
	assert(r2.ok and r2.life.district.id == "pumpside", "player 2 couldn't start a life")
	local look2 = r2.life.appearance.look
	assert(look2.skin == "deep" and look2.hairColor == "rust", "free picks should be kept")
	assert(look2.hair ~= "veil" and look2.outfit ~= "clerk", "locked picks must be refused by the server")
	local u = asP2("unlockCosmetic", { category = "outfit", id = "clerk" })
	assert(not u.ok, "unlocking without Glow should fail")
	local bogus = asP2("unlockCosmetic", { category = "order", id = "skin" })
	assert(not bogus.ok, "bogus cosmetic category should fail")

	actx.actions.newLife("ordinary", "Ossa")
	settle()
	assert(actx.state.life.alive, "player 1 has no life")

	-- P2 invites P1; P1's app shows a prompt and taps Link
	local inv = asP2("linkRequest", { userId = 4242 })
	assert(inv.ok, "link request failed: " .. tostring(inv.error))
	settle()
	local tapped = false
	local modal = gui:FindFirstChild("LifeSimModal")
	for _, d in modal:GetDescendants() do
		if d:IsA("TextButton") and string.upper(d.Text) == "LINK" then
			signalsOf[d].Activated:Fire()
			tapped = true
		end
	end
	assert(tapped, "invite prompt never appeared")
	settle()
	local f2 = asP2("friends")
	assert(f2.ok and #f2.friends.links == 1 and f2.friends.links[1].userId == 4242, "players did not get linked")
	assert(f2.friends.links[1].character and f2.friends.links[1].character.appearance, "friends list should carry the friend's look")

	-- P1 sees P2's face in the companions strip, drawn from P2's real look
	local seen = nil
	for _, rel in actx.state.life.relations do
		if rel.linked and rel.userId == 777 then
			seen = rel
		end
	end
	assert(seen and seen.appearance and seen.appearance.look.skin == "deep", "linked friend's look didn't reach player 1")
	assert(actx.hud.companions.Visible, "companions strip should be showing player 2")

	-- P2 grows up and takes a job: P1 hears about it in their log
	local life2 = r2.life
	for _ = 1, 80 do
		if life2.age >= 17 or not life2.alive then
			break
		end
		local res
		if life2.pending then
			local pick = 1
			for _, c in life2.pending.choices do
				if c.enabled then
					pick = c.index
					break
				end
			end
			res = asP2("choose", { index = pick })
		else
			res = asP2("ageUp")
		end
		if not res.ok and not life2.pending then
			-- a world event or a friend handed P2 a scene in the meantime
			local st = asP2("friends").life
			if st and st.pending then
				life2 = st
				continue
			end
		end
		assert(res.ok, "player 2 couldn't play: " .. tostring(res.error))
		life2 = res.life
	end
	assert(life2.alive and life2.age >= 17, "player 2 didn't grow up")
	while life2.pending do
		local pick = 1
		for _, c in life2.pending.choices do
			if c.enabled then
				pick = c.index
				break
			end
		end
		life2 = asP2("choose", { index = pick }).life
	end
	local jobId = nil
	for _, c in life2.careers do
		if c.enabled then
			jobId = c.id
			break
		end
	end
	assert(jobId, "player 2 has no job they can take")
	local job = asP2("joinCareer", { id = jobId })
	assert(job.ok, "player 2 couldn't take a job: " .. tostring(job.error))
	settle()
	for _ = 1, 5 do
		task.wait()
	end
	local heardNews = false
	for _, d in gui:GetDescendants() do
		if d:IsA("TextLabel") and string.find(d.Text, "started work at", 1, true) then
			heardNews = true
		end
	end
	assert(heardNews, "player 1 never heard that player 2 started work")

	-- play P1 until the linked event fires and its effect reaches P2
	local delivered = false
	local ups, cards, why = 0, 0, ""
	-- (the linked card is one of many: 60 turns was sometimes too few for it to come up)
	for _ = 1, 150 do
		settle()
		local life = actx.state.life
		if not life.alive then
			why = "player 1 died at " .. tostring(life.age)
			break
		end
		if life.pending then
			cards += 1
			clickFirstChoice()
		else
			ups += 1
			actx.actions.ageUp()
		end
		for _ = 1, 5 do
			task.wait()
		end
		for _, push in pushes do
			for _, e in push.payload.entries or {} do
				if e.text and string.find(e.text, "sent you some money", 1, true) then
					delivered = true
				end
			end
		end
		if delivered then
			break
		end
	end
	assert(delivered, string.format("a linked effect never reached the other player (%d age-ups, %d cards, player 1 at %s; %s)", ups, cards, tostring(actx.state.life.age), why))

	-- a together activity: P1 trains with P2, and P2's life feels it
	for _ = 1, 80 do
		settle()
		local l = actx.state.life
		if not l.alive then
			break
		end
		if l.pending then
			clickFirstChoice()
		elseif l.actionsLeft <= 0 or l.age < 10 then
			actx.actions.ageUp()
		else
			local open = false
			for _, a in l.activities do
				if a.id == "train_together" and a.enabled then
					open = true
				end
			end
			if open then
				break
			end
			actx.actions.ageUp()
		end
	end
	local pushesBefore = #pushes
	actx.actions.doActivity("train_together")
	settle()
	for _ = 1, 5 do
		task.wait()
	end
	local trained = false
	for i = pushesBefore + 1, #pushes do
		for _, e in pushes[i].payload.entries or {} do
			if e.text and string.find(e.text, "spar on the docks", 1, true) then
				trained = true
			end
		end
	end
	assert(trained or not actx.state.life.alive, "training together never reached the other player")

	-- ── expeditions, crews, rankings, the store, world events ──
	local function freeYear()
		-- get P1 to an adult year with actions left and nothing pending
		for _ = 1, 120 do
			settle()
			local l = actx.state.life
			if not l.alive then
				actx.actions.newLife("ordinary", "")
				settle()
			elseif l.pending then
				clickFirstChoice()
			elseif l.run or (actx.state.crew and actx.state.crew.run) then
				break
			elseif l.age < 18 or l.actionsLeft < 2 then
				actx.actions.ageUp()
			else
				break
			end
			for _ = 1, 3 do
				task.wait()
			end
		end
	end
	local function playOpenRun(maxSteps)
		-- click through whatever stage card is open until the run ends
		for _ = 1, maxSteps do
			settle()
			for _ = 1, 3 do
				task.wait()
			end
			local l = actx.state.life
			local soloRun = l.alive and l.run
			local crewRun = actx.state.crew and actx.state.crew.run
			if not soloRun and not crewRun then
				return true
			end
			if l.pending then
				clickFirstChoice()
			elseif not clickFirstChoice() then
				actx.actions.openRun()
			end
		end
		return false
	end

	-- a solo trip on the Undertow Line, played through the stage cards
	freeYear()
	asP2("debugWorldEvent", { id = "great_low_tide" })
	settle()
	freeYear()
	local why = "not listed"
	for _, ex in actx.state.life.expeditions or {} do
		if ex.id == "lost_bell" then
			why = if ex.enabled then "ok" else tostring(ex.reason)
		end
	end
	assert(why == "ok", "lost_bell should be open to player 1: " .. why)
	actx.actions.expeditionStart("lost_bell")
	settle()
	assert(actx.state.life.run or not actx.state.life.alive, "solo expedition didn't start")
	assert(playOpenRun(30), "solo expedition never finished")
	assert(actx.state.life.run == nil, "solo run should be over")

	-- a world event reaches everyone: banner, music, and the opening scene in your life
	asP2("debugWorldEvent", { id = "breach_tidewell" })
	settle()
	assert(actx.state.world and actx.state.world.id == "breach_tidewell", "breach banner never reached player 1")

	-- P2 starts a crew and invites P1; P1 taps Join on the prompt
	freeYear()
	local made = asP2("crewInvite", { userId = 4242 })
	assert(made.ok, "crew invite failed: " .. tostring(made.error))
	settle()
	local joined = false
	for _, d in gui:FindFirstChild("LifeSimModal"):GetDescendants() do
		if d:IsA("TextButton") and string.upper(d.Text) == "JOIN" then
			signalsOf[d].Activated:Fire()
			joined = true
		end
	end
	assert(joined, "crew invite prompt never appeared")
	settle()
	assert(actx.state.crew and #actx.state.crew.members == 2, "player 1 didn't join the crew")
	assert(not actx.state.crew.captain, "player 2 should be captain")

	-- aging up together: everyone in the crew readies up, then the year turns for all
	local function p2Free()
		for _ = 1, 20 do
			local st = asP2("friends").life
			if not st or not st.pending then
				return
			end
			local pick = 1
			for _, c in st.pending.choices do
				if c.enabled then
					pick = c.index
					break
				end
			end
			asP2("choose", { index = pick })
		end
	end
	for _ = 1, 20 do
		if not actx.state.life.pending then
			break
		end
		clickFirstChoice()
		settle()
	end
	p2Free()
	local ageBefore = actx.state.life.age
	actx.actions.ageUp()
	settle()
	assert(actx.state.crew and actx.state.crew.age and actx.state.crew.age.youReady, "player 1 should be waiting on the crew")
	assert(actx.state.life.age == ageBefore, "the year shouldn't turn until everyone is ready")
	assert(string.find(actx.hud.ageLabel.Text, "READY", 1, true), "the Age Up button should say you're ready")
	local p2Age = asP2("ageUp")
	assert(p2Age.ok and not p2Age.waiting, "the last one to ready up should turn the year: " .. tostring(p2Age.error))
	for _ = 1, 10 do
		settle()
	end
	assert(actx.state.life.age == ageBefore + 1 or not actx.state.life.alive, "player 1's year should turn once the crew is ready (age " .. tostring(actx.state.life.age) .. ")")
	assert(not (actx.state.crew and actx.state.crew.age), "the ready check should clear after the year turns")
	local off = asP2("crewSyncAge", { on = false })
	assert(off.ok and off.crew.syncAge == false, "the captain should be able to turn aging together off")
	settle()

	-- the captain proposes the containment job (open during the breach); P1 must say ready
	freeYear()
	local function p2Clear()
		for _ = 1, 20 do
			local st = asP2("friends").life
			if not st or not st.pending then
				return
			end
			local pick = 1
			for _, c in st.pending.choices do
				if c.enabled then
					pick = c.index
					break
				end
			end
			asP2("choose", { index = pick })
		end
	end
	p2Clear()
	local proposed = asP2("crewPropose", { id = "tidewell_containment" })
	assert(proposed.ok, "proposal failed: " .. tostring(proposed.error))
	settle()
	local readied = false
	for _, d in gui:FindFirstChild("LifeSimModal"):GetDescendants() do
		if d:IsA("TextButton") and string.upper(d.Text) == "READY" then
			signalsOf[d].Activated:Fire()
			readied = true
		end
	end
	assert(readied, "ready check never appeared for player 1")
	settle()
	assert(actx.state.crew.run, "the crew run didn't start after everyone was ready")
	assert(actx.state.life.onCrewRun, "player 1's life should be on the crew run")
	-- (v0.16) everyone picks: the run waits for both, and moves on the crew's pick
	local sugg = asP2("crewState")
	local stageChoices = sugg.crew.run.stage.choices
	actx.actions.crewCall("crewSuggest", { index = stageChoices[1].index })
	local steps, waited = 0, 0
	while asP2("crewState").crew and asP2("crewState").crew.run and steps < 20 do
		steps += 1
		local cs = asP2("crewState").crew.run.stage.choices
		local pick = 1
		for _, c in cs do
			if c.enabled then
				pick = c.index
				break
			end
		end
		local r = asP2("crewChoose", { index = pick, approach = "careful" })
		assert(r.ok, "the captain's pick failed: " .. tostring(r.error))
		settle()
		local mid = asP2("crewState").crew
		if mid and mid.run then
			assert(mid.votes and mid.votes.voted == 1 and mid.votes.total == 2, "the run should wait for player 1's pick")
			waited += 1
			actx.actions.crewCall("crewChoose", { index = pick, approach = "careful" })
			settle()
		end
	end
	assert(waited > 0, "the run never waited for the crew")
	settle()
	assert(not (actx.state.crew and actx.state.crew.run), "crew run should have ended")
	assert(not actx.state.life.onCrewRun, "player 1 should be back from the crew run")

	-- the store: a Studio test purchase unlocks a look, which a new life can then use
	local catalog = asP2("store")
	assert(catalog.ok and #catalog.store > 5, "store catalog missing")
	local bought = asP2("storeTestBuy", { key = "outfit_midnight" })
	assert(bought.ok, "test purchase failed: " .. tostring(bought.error))
	local again = asP2("store")
	local owns = false
	for _, item in again.store do
		if item.key == "outfit_midnight" then
			owns = item.owned
		end
	end
	assert(owns, "store should show the outfit as owned")

	-- rankings: P1's finished lives are on the board
	local lb = asP2("leaderboard", { board = "best" })
	assert(lb.ok and #lb.board.entries >= 1, "leaderboard is empty")
	local p1OnBoard = false
	for _, e in lb.board.entries do
		if e.name == "Tester" or e.name == "Ossa" or (e.life and #e.life > 0) then
			p1OnBoard = true
		end
	end
	assert(p1OnBoard, "player 1's life should be on the leaderboard")
	print(string.format("      expeditions: solo trip done, crew of 2 ran %d stages, breach reached everyone; leaderboard rows: %d", steps, #lb.board.entries))

	-- duels (v0.17, in turns): P2 challenges P1, P1 taps Fight, both get the duel screen, and
	-- both choose every turn (P1 by pressing a move on the real DuelView) until it ends
	freeYear()
	p2Clear()
	local duelNote = "skipped (player 1 too young)"
	if actx.state.life.alive and actx.state.life.age >= 14 and not actx.state.life.pending then
		local before = #pushes
		local ch = asP2("duelChallenge", { userId = 4242 })
		assert(ch.ok, "duel challenge failed: " .. tostring(ch.error))
		settle()
		local fought = false
		for _, d in gui:FindFirstChild("LifeSimModal"):GetDescendants() do
			if d:IsA("TextButton") and string.upper(d.Text) == "FIGHT" then
				signalsOf[d].Activated:Fire()
				fought = true
			end
		end
		assert(fought, "the duel prompt never appeared for player 1")
		for _ = 1, 10 do
			settle()
		end
		local seen = nil
		for i = before + 1, #pushes do
			local pl = pushes[i].payload
			if type(pl.duel) == "table" and pl.duel.me then
				seen = pl.duel
			end
		end
		assert(seen and seen.options and #seen.options >= 4, "player 2 never saw the duel")
		local function duelScreen()
			for _, d in gui:GetDescendants() do
				if d.Name == "DuelView" then
					return d
				end
			end
			return nil
		end
		assert(duelScreen() and actx.duelOpen and actx.duelOpen(), "player 1's duel screen never opened")
		local turns, done = 0, nil
		while turns < 60 and not done do
			turns += 1
			-- player 1: the first move on the screen (a strike)
			local screen = duelScreen()
			assert(screen, "the duel screen closed mid-duel")
			local move = nil
			for _, d in screen:GetDescendants() do
				if d:IsA("TextButton") and d.Name == "Move_1" then
					move = d
				end
			end
			assert(move, "player 1 has no moves on the duel screen")
			signalsOf[move].Activated:Fire()
			settle()
			-- player 2: a strike with its first way of fighting
			local opt = seen.options[1]
			local r = asP2("duelAct", { action = opt.action, approach = opt.approach })
			if r.duelDone then
				done = r.duelDone
			elseif type(r.duel) == "table" and r.duel.me then
				seen = r.duel
			else
				assert(r.ok, "player 2's move failed: " .. tostring(r.error))
			end
			settle()
		end
		assert(done and done.done, "the duel never ended")
		-- player 1's screen shows the end; Continue closes it
		local screen = duelScreen()
		if screen then
			for _, d in screen:GetDescendants() do
				if d:IsA("TextButton") and d.Name == "Continue" then
					signalsOf[d].Activated:Fire()
				end
			end
			settle()
		end
		assert(not (actx.duelOpen and actx.duelOpen()), "the duel screen should close after Continue")
		local again = asP2("duelChallenge", { userId = 4242 })
		assert(not again.ok, "the same pair shouldn't duel twice in one year")
		duelNote = string.format("%d turns, %s won", turns, if done.won then "player 2" else "player 1")
	end
	print("      duel: " .. duelNote)

	-- rough play needs both players
	asP2("setRough", { on = true })
	actx.actions.setRough(true)
	settle()

	-- P2's character dies (they start over); P1 hears about it
	local before = #actx.state.life.relations
	asP2("newLife", { origin = "orphan", confirm = true })
	settle()
	local heard = false
	for _, rel in actx.state.life.relations do
		if rel.linked and not rel.alive then
			heard = true
		end
	end
	assert(heard or #actx.state.life.relations >= before, "linked friend's death wasn't reported")

	-- there is no unlinking (v0.12): the client has no such action, and the server refuses it
	assert(actx.actions.unlink == nil, "the client still has an unlink action")
	local before3 = #asP2("friends").friends.links
	assert(before3 >= 1, "the two players should be linked by now")
	local refused = asP2("unlink", { userId = 4242 })
	assert(type(refused) == "table" and refused.ok == false, "the server should refuse to unlink")
	settle()
	local f3 = asP2("friends")
	assert(#f3.friends.links == before3, "a refused unlink still removed the link")
	print(string.format("      friends: linked, effect delivered, %d pushes to player 2", #pushes))
	assert(#kicked == 0, "player was kicked: " .. tostring(kicked[1]))
end, 600000)

-- ── the City pack: v0.5 screens and whole lives through the real server and client ──
if CITY then
	case("City: intro, start menu, creator with eras, panels, names, menu, mod menu, lives", function()
		local Server = Loader.require(serverRoot)
		Server.start()
		local App = Loader.require(clientRoot.App)
		App.start()
		local actx = App.ctx
		assert(actx and actx.actions, "App.ctx missing")
		local gui = wrap(playerGui)
		local function frames(n: number)
			for _ = 1, n do
				task.wait()
			end
		end
		local function settle()
			local spins = 0
			while (actx.state.busy or actx.state.applying) and spins < 800 do
				spins += 1
				task.wait()
			end
			frames(3)
		end
		local function find(name: string)
			for _, d in gui:GetDescendants() do
				if d.Name == name then
					return d
				end
			end
			return nil
		end
		local function press(name: string): boolean
			for _, d in gui:GetDescendants() do
				if d:IsA("TextButton") and d.Name == name then
					local sig = signalsOf[d] and signalsOf[d].Activated
					if sig then
						sig:Fire()
						return true
					end
				end
			end
			return false
		end
		local function clickFirstChoice(): boolean
			local modal = gui:FindFirstChild("LifeSimModal")
			if not modal then
				return false
			end
			local best, bestOrder = nil, math.huge
			for _, d in modal:GetDescendants() do
				if d:IsA("TextButton") and d.Name == "Choice" and d.TextTransparency == 0 then
					local sig = signalsOf[d] and signalsOf[d].Activated
					if sig and d.LayoutOrder < bestOrder then
						best, bestOrder = sig, d.LayoutOrder
					end
				end
			end
			if not best then
				return false
			end
			best:Fire()
			for _, d in modal:GetDescendants() do
				if d:IsA("TextButton") and d.Name == "Approach" then
					local holder = d.Parent and d.Parent.Parent
					if holder and holder.Visible then
						signalsOf[d].Activated:Fire()
						break
					end
				end
			end
			return true
		end

		-- first join: the intro plays, then the start menu
		frames(10)
		assert(find("Intro"), "the intro should play on first join")
		assert(press("SkipIntro"), "no skip button on the intro")
		frames(60)
		assert(actx.state.meta.flags and actx.state.meta.flags.seenIntro, "seenIntro was not saved")
		assert(find("StartMenu"), "the start menu should follow the intro")

		-- the mode select: a card per mode, Kindred locked until earned
		assert(find("Mode_city") and find("Mode_agent") and find("Mode_kindred"), "mode cards missing from the start menu")
		assert(not find("Mode_fixer"), "v0.18: Fixer's Road (start at 18) is off the start menu")
		assert(not (actx.state.meta.modes or {}).kindred, "Kindred should start locked")
		-- the creator (v0.8): one screen. The character on a stage, tabs of looks, sins, BE BORN.
		assert(press("Mode_city"), "the City mode card isn't a button")
		frames(20)
		assert(find("QuickStart") and find("QuickStart").Visible, "the creator should open")
		assert(find("Stage") and find("FirstName"), "the creator should show the character and a name box")
		assert(find("Tab_looks") and find("Tab_outfit") and find("Tab_when") and find("Tab_sins"), "creator tabs missing")
		assert(not find("Tab_weapon"), "v0.9: weapons are found in a life, not picked in the creator")
		assert(not find("Build_tremor") and not find("Origin_backstreets_family"), "builds and origins are rolled now, not picked")
		assert(find("Identity_backstreets_kid") and not find("Identity_office_fixer") and not find("Identity_kindred"), "v0.9: quick looks are civilian (no faction costumes)")
		assert(press("Identity_backstreets_kid"), "an identity card isn't a button")
		frames(5)
		-- clothes: nothing an organisation issues is on offer
		assert(press("Tab_outfit"), "no Clothes tab in the creator")
		frames(5)
		for _, d in find("QuickStart"):GetDescendants() do
			if d:IsA("TextButton") and d.Name == "LookOption" then
				local t = string.upper(d.Text)
				assert(not string.find(t, "(ZWEI)", 1, true) and not string.find(t, "(THUMB)", 1, true) and not string.find(t, "L CORP AGENT", 1, true), "a uniform is on offer in the creator: " .. d.Text)
			end
		end
		assert(press("RandomLook"), "no Random button on the stage")
		frames(5)
		-- When: the age to be born into (or let the City decide)
		assert(press("Tab_when"), "no When tab")
		frames(10)
		assert(find("Era_any") and find("Era_wings") and find("Era_twilight") and find("Era_library") and find("Era_after"), "the four ages (and 'let the City decide') should be on the When tab")
		assert(press("Era_after"), "an age card isn't a button")
		frames(5)
		assert(press("Era_any"), "'Let the City decide' isn't a button")
		frames(5)
		-- the Talent tab: nobody picks their sins any more; the talent and its rerolls are here
		assert(press("Tab_sins"), "no Talent tab")
		frames(10)
		assert(not find("Sin_wrath"), "v0.9: sins are dealt at birth, not picked")
		settle()
		frames(10)
		local t0 = actx.state.talent
		assert(t0.talent and t0.talent.id, "no pending talent")
		assert(t0.talent.affinityName ~= nil, "talents should show their sin")
		assert(find("Talent") and find("TalentName"), "the talent card is missing on the Sins tab")
		assert(find("TalentChip"), "the footer should show the talent")
		assert((t0.free or 0) > 0, "new players should have free rerolls")
		assert(t0.odds and #t0.odds >= 5, "talent odds missing")
		local oddsSum = 0
		for _, o in t0.odds do
			oddsSum += o.percent
		end
		assert(math.abs(oddsSum - 100) < 0.01, "talent odds should add up to 100% (got " .. oddsSum .. ")")
		assert(press("Reroll"), "no Reroll on the talent card")
		settle()
		frames(40)
		assert(actx.state.talent.free == t0.free - 1, "a free reroll should be used")
		assert(find("BeBorn"), "no Be born button")
		-- the guidebook
		local guide = nil
		actx.actions.loadGuide(function(g)
			guide = g
		end)
		settle()
		assert(guide and guide.sections and #guide.sections >= 8, "the guidebook should have its sections")
		local secs = {}
		for _, sec in guide.sections do
			secs[sec.id] = #sec.entries
		end
		assert((secs.talents or 0) >= 20 and (secs.gear or 0) >= 20 and (secs.careers or 0) >= 20 and (secs.start or 0) >= 6, "guidebook pages look empty")
		actx.actions.openGuide("fights")
		frames(10)
		assert(find("Search"), "the guidebook has no search box")

		-- a life born in the age of the Wings: family, District and side are rolled, the talent
		-- is the one shown; picked traits and styles are ignored (styles are found in play)
		local pendingTalent = actx.state.talent.talent.id
		task.spawn(function()
			actx.actions.newLife("backstreets_family", "Yuri", "d12", nil, { traits = { "steady_mind", "cold_reader" }, style = "rupture", alloc = { mind = 5, health = 5 }, era = "wings" })
		end)
		local sawReveal, sawCanto = false, false
		for _ = 1, 4000 do
			if find("BirthReveal") then
				sawReveal = true
			end
			if find("CantoCard") then
				sawCanto = true
			end
			if actx.state.life and actx.state.life.alive and not actx.state.cinema and not actx.state.busy and not actx.state.applying and not find("BirthReveal") then
				break
			end
			task.wait()
		end
		assert(sawReveal, "the birth reveal should play")
		assert(sawCanto, "Canto I should play after the reveal")
		settle()
		local life = actx.state.life
		assert(life and life.alive, "life did not start")
		assert(life.talent and life.talent.id == pendingTalent, "the life should be born with the talent shown in the creator")
		assert(actx.state.talent and actx.state.talent.talent, "a fresh talent should be rolled for the next life")
		assert(life.year >= 939 and life.year <= 945, "a life born in the Age of L Corp should start near 942 (got " .. tostring(life.year) .. ")")
		assert(life.origin and life.origin.name, "the life should know the family it was born into")
		assert(life.style == nil or life.style.id == nil, "a new life shouldn't have a fighting style yet")
		local have = {}
		for _, t in life.traits or {} do
			have[t.name] = true
		end
		assert(not have["Steady Mind"], "picked traits should be ignored (no builds in the creator)")
		assert(life.chapter and life.chapter.word == "Canto", "the life should be in Canto I")

		-- the quick tour runs once after the first life starts
		frames(150)
		if find("TutorialCard") then
			assert(press("NextStep"), "no Next on the tour")
			frames(5)
			assert(press("SkipTutorial"), "no Skip on the tour")
			frames(10)
		end
		assert(actx.state.meta.flags.tutorialDone, "tutorialDone was not saved")

		-- the full join cinematic (cold open, montage, title) runs to the end by itself and
		-- hands over to the mode select, with Continue on top for the life being lived
		actx.actions.playIntro(true)
		frames(5)
		assert(find("Intro"), "the full intro should play again from the menu")
		local sawCard = false
		for _ = 1, 3000 do
			if not find("Intro") then
				break
			end
			if find("Card") then
				sawCard = true
			end
			task.wait()
		end
		assert(not find("Intro"), "the full intro should end on its own")
		assert(sawCard, "the montage cards should show")
		frames(10)
		assert(find("StartMenu"), "the mode select should follow the intro")
		assert(press("Continue"), "the mode select should offer Continue for a living life")
		frames(10)

		-- side panels, the menu and settings
		actx.actions.openLorePanel()
		frames(5)
		actx.actions.openCityPanel()
		frames(5)
		assert(find("Side"), "side panel missing")
		actx.actions.openMenu()
		frames(5)
		actx.actions.setSetting("musicVolume", 0.3)
		actx.actions.setSetting("uiScale", "big")
		settle()
		assert(actx.state.meta.settings and actx.state.meta.settings.musicVolume == 0.3, "music volume did not save")
		assert(actx.state.meta.settings.uiScale == "big", "UI size did not save")

		-- family names: a roll (new players have some), and the sheet
		local rolled = nil
		actx.actions.loadSurnames(function() end)
		actx.actions.surnameRoll(function(res)
			rolled = res
		end)
		settle()
		assert(rolled and rolled.ok, "surname roll failed: " .. tostring(rolled and rolled.error))
		actx.actions.openSurnames()
		frames(5)

		-- the lore archive
		local codex = nil
		actx.actions.loadCodex(function(c)
			codex = c
		end)
		settle()
		assert(codex ~= nil, "the archive did not load")

		-- the mod menu (Studio counts as an admin, like the whitelisted id)
		assert(actx.state.isAdmin, "Studio should count as an admin")
		actx.actions.openAdmin()
		frames(5)
		local res = nil
		local function admin(payload)
			res = nil
			actx.actions.adminCall(payload, function(r)
				res = r
			end)
			settle()
			assert(res and res.ok, "admin " .. payload.op .. " failed: " .. tostring(res and res.error))
		end
		local uid = Loader.globals.localPlayer.UserId
		admin({ op = "__state" })
		admin({ op = "world", id = "night_in_backstreets" })
		admin({ op = "world", id = "night_in_backstreets", on = false })
		admin({ op = "daily", id = pack.daily.order[1] })
		admin({ op = "stat", target = uid, stat = "strength", value = 70 })
		admin({ op = "rolls", target = uid, amount = 3 })
		-- forcing an event waits until the open decision is made
		local guard = 0
		while actx.state.life.pending and guard < 20 do
			guard += 1
			clickFirstChoice()
			settle()
		end
		admin({ op = "event", target = uid, id = "core_debt_collector" })
		settle()
		assert(actx.state.life.pending, "the forced event should be on screen")

		-- the store (open in the City: Config.store.sellInFanPacks); Studio test purchases
		assert(actx.info.storeOpen, "the store should be open")
		local storeList = nil
		actx.actions.loadStore(function(list)
			storeList = list
		end)
		settle()
		assert(storeList and #storeList > 0, "the store catalog didn't load")
		local function buy(key: string)
			local item = nil
			for _, it in storeList do
				if it.key == key then
					item = it
				end
			end
			assert(item, "no store item " .. key)
			actx.actions.buyItem(item, function(updated)
				storeList = updated or storeList
			end)
			settle()
		end
		-- Lunacy: bought with Robux (a test purchase in Studio), then spent in game
		local lunacyBefore = actx.state.meta.lunacy or 0
		buy("lunacy_700")
		assert((actx.state.meta.lunacy or 0) == lunacyBefore + 700, "700 Lunacy should arrive")
		local function spend(key: string)
			buy(key) -- opens the confirm prompt
			frames(5)
			assert(press("PromptButton2"), "no Spend button on the confirm prompt")
			settle()
			frames(5)
		end
		local rollsBefore = actx.state.meta.rolls or 0
		local lunacyMid = actx.state.meta.lunacy
		spend("rolls_3")
		assert((actx.state.meta.rolls or 0) == rollsBefore + 3, "3 family-name rolls should arrive")
		assert(actx.state.meta.lunacy == lunacyMid - 40, "3 rolls should cost 40 Lunacy")
		spend("premium_1")
		assert((actx.state.meta.premiumRolls or 0) >= 1, "a Rare-or-better roll should arrive")
		-- a Rare-or-better talent reroll, paid in Lunacy
		local before = actx.state.meta.lunacy
		local rerolled = nil
		actx.actions.talentReroll(true, true, function(st, rolled)
			rerolled = rolled
		end)
		settle()
		assert(rerolled and rerolled.rank >= 3, "a Rare-or-better reroll landed " .. tostring(rerolled and rerolled.tier))
		assert(actx.state.meta.lunacy == before - actx.state.talent.premiumCost, "the Rare+ reroll should cost Lunacy")
		if actx.state.surnames and actx.state.surnames.pending then
			actx.actions.surnameKeep(false, function() end)
			settle()
		end
		local premium = nil
		actx.actions.surnameRoll(function(res)
			premium = res
		end, true)
		settle()
		assert(premium and premium.ok and premium.rolled, "premium roll failed: " .. tostring(premium and premium.error))
		assert(premium.rolled.tier == "rare" or premium.rolled.tier == "epic" or premium.rolled.tier == "legendary", "a Rare-or-better roll landed " .. tostring(premium.rolled.tier))
		if actx.state.surnames and actx.state.surnames.pending then
			actx.actions.surnameKeep(true, function() end)
			settle()
		end
		-- a boost works on the life being lived
		admin({ op = "stat", target = uid, stat = "health", value = 20 })
		spend("boost_heal")
		assert(actx.state.life.stats.health >= 55, "Second Wind should heal (health " .. tostring(actx.state.life.stats.health) .. ")")
		-- a pass: three traits in the next life
		buy("pass_trait")
		assert(actx.state.meta.perks and actx.state.meta.perks.extraTrait, "the Extra Trait pass didn't stick")
		-- the Bloodline pass opens the Kindred mode
		buy("pass_bloodline")
		assert(actx.state.meta.modes and actx.state.meta.modes.kindred, "the Bloodline pass should unlock Kindred")
		task.spawn(function()
			actx.actions.newLife("backstreets_family", "Mira", nil, nil, { era = "twilight" })
		end)
		for _ = 1, 4000 do
			if actx.state.life and actx.state.life.first == "Mira" and not actx.state.cinema and not actx.state.busy and not actx.state.applying then
				break
			end
			task.wait()
		end
		settle()
		local perkLine = actx.state.life.perkTrait ~= nil
		assert(perkLine, "the Extra Trait pass should give a random trait at birth")
		-- the mod menu can make someone a Bloodfiend
		while actx.state.life.pending do
			clickFirstChoice()
			settle()
		end
		admin({ op = "form", target = uid, id = "bloodfiend" })
		settle()
		assert(actx.state.life.form and actx.state.life.form.id == "bloodfiend", "admin form op didn't turn the life")

		-- now live: events, fights (statuses) and quick checks through the real UI
		local deaths, years, choices, activities, battles = 0, 0, 0, 0, 0
		-- (v0.18) a card can start a boss battle; this loop plays cards, not battles, so it leaves
		-- one the way a player can (the last move is Get out), then presses Continue. Before, the
		-- loop spun on a life stuck in its battle until it ran out of turns.
		local function leaveBattle(): boolean
			local l = actx.state.life
			if not (l and l.alive and (l.battle or actx.state.battleOpen)) then
				return false
			end
			battles += 1
			for _ = 1, 30 do
				local last, lastN = nil, 0
				for _, d in gui:GetDescendants() do
					if d:IsA("TextButton") then
						local n = tonumber(string.match(d.Name, "^Move_(%d+)$"))
						if n and n > lastN and signalsOf[d] then
							last, lastN = d, n
						end
					end
				end
				if last then
					signalsOf[last].Activated:Fire()
					settle()
				end
				for _, d in gui:GetDescendants() do
					if d:IsA("TextButton") and d.Name == "Continue" and signalsOf[d] then
						signalsOf[d].Activated:Fire()
						settle()
						break
					end
				end
				local now = actx.state.life
				if not (now and now.alive and (now.battle or actx.state.battleOpen)) then
					break
				end
			end
			return true
		end
		for _ = 1, 2500 do
			settle()
			leaveBattle()
			local l = actx.state.life
			if not l.alive then
				deaths += 1
				local lantern = actx.state.meta.lanterns[1]
				assert(lantern and lantern.id == l.id, "death did not produce a book")
				actx.actions.releaseLantern(lantern.id)
				if deaths >= 2 then
					break
				end
				if l.heirs and #l.heirs > 0 then
					actx.actions.continueHeir(l.heirs[1].id)
				else
					actx.actions.newLife("street_orphan", "", nil, nil, { era = "after", style = "tremor", traits = { "rat_smart" } })
				end
				settle()
				assert(actx.state.life.alive, "the next life did not start")
			elseif l.pending then
				assert(clickFirstChoice(), "pending event but no choice on screen")
				choices += 1
			elseif l.run then
				-- (v0.18) an expedition a random activity started: its stages are cards too. Before,
				-- this loop never played them, and the life sat in its expedition, unable to age.
				if not clickFirstChoice() then
					actx.actions.openRun()
					settle()
					clickFirstChoice()
				end
				choices += 1
			else
				for _, a in l.activities do
					if a.enabled and math.random() < 0.4 then
						actx.actions.doActivity(a.id)
						activities += 1
						break
					end
				end
				settle()
				if not actx.state.life.pending and actx.state.life.alive then
					actx.actions.ageUp()
					years += 1
				end
			end
		end
		print(string.format("      City: %d years, %d choices, %d activities, %d deaths, %d boss battles left, %d remote calls", years, choices, activities, deaths, battles, remoteCalls))
		assert(deaths >= 1, "nobody died")
	end, 900000)
end

local failed = 0
for _, r in results do
	if not r.ok then
		failed += 1
	end
end
if #errors > 0 then
	print("\nERRORS:")
	for _, e in errors do
		print(e)
		print("----")
	end
end
print(string.format("\n%d/%d cases passed, %d UI callbacks fired into actions", #results - failed, #results, #calls))
if failed > 0 then
	process.exit(1)
end
