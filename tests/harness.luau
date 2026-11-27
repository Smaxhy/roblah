--[[
	Harness for tests/gui_snapshot: runs the real client UI (src/client) against the real
	server (src/server) inside Lune, on @lune/roblox instances (real property names and value
	types), at a chosen screen size, on a virtual clock.

	It is ui_smoke's harness (tests/ui_smoke.luau, which is not touched) with the changes that
	matter for taking pictures:
	  - Time is virtual. task.wait / task.delay / os.clock follow a 60 fps clock that only
	    moves while the driver waits (Harness.run), so a cinematic can be stopped at exactly
	    5.3 seconds and two runs give the same pictures.
	  - Tweens really animate on that clock (ui_smoke applies their end values at once), with
	    Roblox's easing styles.
	  - Absolute* properties are worked out from the Size/Position chain and the screen size
	    (ui_smoke answers 420x760 for everything). Layouts and AutomaticSize are not run here;
	    the renderer does those. AbsoluteCanvasSize is huge, so "scroll to the end" lands at
	    the end once the renderer clamps it.
	  - Signal:Wait() yields until the signal fires (the fight screen waits for Continue).
	  - GetPropertyChangedSignal / Changed fire when a property is set (typing in a TextBox).
	  - UserInputService, the camera's ViewportSize and the topbar inset say PC or phone, so
	    UI/Layout.luau picks the device the way it does in game.
	  - The 3D backdrop modules are stubbed (the City behind the UI isn't GUI).
	  - Each ViewportFrame made by UI/AvatarView remembers its appearance (the look table)
	    in Harness.avatarOf, for the dump.

	Harness.boot(device) -> h (see the h.* functions at the bottom). Run from the repo root.
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")

local luneTypeof = typeof

local Harness = {}

-- ── signals ─────────────────────────────────────────────────────────────────
local Signal = {}
Signal.__index = Signal
function Signal.new()
	return setmetatable({ conns = {}, waiting = {} }, Signal)
end
function Signal:Connect(fn)
	local conn
	conn = {
		Connected = true,
		Disconnect = function()
			conn.Connected = false
			local at = table.find(self.conns, conn)
			if at then
				table.remove(self.conns, at)
			end
		end,
		fn = fn,
	}
	table.insert(self.conns, conn)
	return conn
end
function Signal:Once(fn)
	local conn
	conn = self:Connect(function(...)
		conn.Disconnect()
		fn(...)
	end)
	return conn
end
Harness.Signal = Signal

-- ── the clock and the task scheduler ────────────────────────────────────────
local FRAME = 1 / 60
local now = 0 -- virtual seconds since boot
local frameNo = 0
local seq = 0
local sleepers = {}
local deferredQ = {}
local errors = {}
local cancelled = setmetatable({}, { __mode = "k" })

local function resume(co, ...)
	if cancelled[co] or coroutine.status(co) ~= "suspended" then
		return
	end
	local ok, err = coroutine.resume(co, ...)
	if not ok then
		table.insert(errors, debug.traceback(co, tostring(err)))
	end
end

function Signal:Fire(...)
	for _, conn in table.clone(self.conns) do
		if conn.Connected then
			local co = coroutine.create(conn.fn)
			resume(co, ...)
		end
	end
	local waiting = self.waiting
	self.waiting = {}
	for _, co in waiting do
		resume(co, ...)
	end
end
function Signal:Wait()
	if not coroutine.isyieldable() then
		return nil
	end
	table.insert(self.waiting, coroutine.running())
	return coroutine.yield()
end

local task = {}
local function threadOf(fn)
	return if type(fn) == "thread" then fn else coroutine.create(fn)
end
function task.spawn(fn, ...)
	local co = threadOf(fn)
	resume(co, ...)
	return co
end
function task.defer(fn, ...)
	local co = threadOf(fn)
	table.insert(deferredQ, { co = co, args = table.pack(...) })
	return co
end
function task.delay(t, fn, ...)
	local co = threadOf(fn)
	seq += 1
	table.insert(sleepers, { co = co, wake = now + math.max(0, tonumber(t) or 0), minFrame = frameNo + 1, seq = seq, args = table.pack(...) })
	return co
end
function task.wait(t)
	if not coroutine.isyieldable() then
		return 0
	end
	seq += 1
	table.insert(sleepers, { co = coroutine.running(), wake = now + math.max(0, tonumber(t) or 0), minFrame = frameNo + 1, seq = seq, start = now, isWait = true })
	return coroutine.yield()
end
function task.cancel(co)
	cancelled[co] = true
end
function task.synchronize() end
function task.desynchronize() end

local function flushDeferred()
	for _ = 1, 200 do
		if #deferredQ == 0 then
			return
		end
		local q = deferredQ
		deferredQ = {}
		for _, item in q do
			resume(item.co, table.unpack(item.args, 1, item.args.n))
		end
	end
	deferredQ = {} -- a defer chain that never ends
end

-- ── tweens on the virtual clock ─────────────────────────────────────────────
local tweens = {}

local function easeIn(style: string, t: number): number
	if style == "Linear" then
		return t
	elseif style == "Sine" then
		return 1 - math.cos(t * math.pi / 2)
	elseif style == "Quad" then
		return t ^ 2
	elseif style == "Cubic" then
		return t ^ 3
	elseif style == "Quart" then
		return t ^ 4
	elseif style == "Quint" then
		return t ^ 5
	elseif style == "Exponential" then
		return if t <= 0 then 0 else 2 ^ (10 * t - 10)
	elseif style == "Circular" then
		return 1 - math.sqrt(math.max(0, 1 - t * t))
	elseif style == "Back" then
		local s = 1.70158
		return t * t * ((s + 1) * t - s)
	elseif style == "Elastic" then
		if t <= 0 or t >= 1 then
			return t
		end
		return -(2 ^ (10 * t - 10)) * math.sin((t * 10 - 10.75) * (2 * math.pi) / 3)
	elseif style == "Bounce" then
		local u = 1 - t
		local v
		if u < 1 / 2.75 then
			v = 7.5625 * u * u
		elseif u < 2 / 2.75 then
			u -= 1.5 / 2.75
			v = 7.5625 * u * u + 0.75
		elseif u < 2.5 / 2.75 then
			u -= 2.25 / 2.75
			v = 7.5625 * u * u + 0.9375
		else
			u -= 2.625 / 2.75
			v = 7.5625 * u * u + 0.984375
		end
		return 1 - v
	end
	return t
end

local function ease(style: string, direction: string, t: number): number
	t = math.clamp(t, 0, 1)
	if direction == "In" then
		return easeIn(style, t)
	elseif direction == "InOut" then
		return if t < 0.5 then easeIn(style, t * 2) / 2 else 1 - easeIn(style, (1 - t) * 2) / 2
	end
	return 1 - easeIn(style, 1 - t)
end

local function lerp(a, b, k: number)
	local ta = luneTypeof(a)
	if ta ~= luneTypeof(b) then
		return if k >= 1 then b else a
	end
	if ta == "number" then
		return a + (b - a) * k
	elseif ta == "UDim2" then
		return roblox.UDim2.new(a.X.Scale + (b.X.Scale - a.X.Scale) * k, a.X.Offset + (b.X.Offset - a.X.Offset) * k, a.Y.Scale + (b.Y.Scale - a.Y.Scale) * k, a.Y.Offset + (b.Y.Offset - a.Y.Offset) * k)
	elseif ta == "UDim" then
		return roblox.UDim.new(a.Scale + (b.Scale - a.Scale) * k, a.Offset + (b.Offset - a.Offset) * k)
	elseif ta == "Color3" then
		return roblox.Color3.new(a.R + (b.R - a.R) * k, a.G + (b.G - a.G) * k, a.B + (b.B - a.B) * k)
	elseif ta == "Vector2" then
		return roblox.Vector2.new(a.X + (b.X - a.X) * k, a.Y + (b.Y - a.Y) * k)
	elseif ta == "Vector3" then
		return roblox.Vector3.new(a.X + (b.X - a.X) * k, a.Y + (b.Y - a.Y) * k, a.Z + (b.Z - a.Z) * k)
	elseif ta == "CFrame" then
		local ok, v = pcall(function()
			return a:Lerp(b, k)
		end)
		return if ok then v elseif k >= 1 then b else a
	end
	return if k >= 1 then b else a
end

-- ── instance proxies ────────────────────────────────────────────────────────
-- (all strong: a proxy that got collected would lose the signals connected to it)
local realOf = {}
local proxyOf = {}
local signalsOf = {}
local propSignals = {}
local vpCamera = {} -- ViewportFrame (real) -> Camera (real)
local avatarOf = {} -- ViewportFrame (real) -> { framing, appearance, ... }

local EVENTS = {
	Players = { "PlayerAdded", "PlayerRemoving" },
	GuiButton = { "Activated", "MouseButton1Down", "MouseButton1Up", "MouseButton1Click", "MouseButton2Click", "MouseEnter", "MouseLeave", "InputBegan", "InputEnded", "InputChanged", "SelectionGained", "SelectionLost" },
	TextBox = { "FocusLost", "Focused", "ReturnPressedFromOnScreenKeyboard" },
	GuiObject = { "MouseEnter", "MouseLeave", "MouseMoved", "InputBegan", "InputEnded", "InputChanged", "SelectionGained", "SelectionLost" },
	BindableEvent = { "Event" },
	RemoteEvent = { "OnClientEvent", "OnServerEvent" },
	Sound = { "Ended", "Loaded", "Played", "Stopped" },
	Player = { "CharacterAdded", "CharacterRemoving", "Chatted" },
	Instance = { "Changed", "ChildAdded", "ChildRemoved", "AncestryChanged", "DescendantAdded", "DescendantRemoving", "Destroying", "AttributeChanged" },
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
local function unwrap(v)
	if type(v) == "table" and realOf[v] then
		return realOf[v]
	end
	return v
end

local device = nil -- set by Harness.boot
local localPlayer, realPlayers -- assigned in boot
local userIds = {}
local callbacks = {}
local pushes = {}
local kicked = {}
local remoteCalls = 0
local workspaceCamera = nil

-- remote calls are deep-copied like Roblox does, and must be remote-safe
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
Harness.marshal = marshal

-- ── Absolute* without a layout engine: the Size/Position/UIPadding/UIScale chain ──
local function readOr(real, key, default)
	local ok, v = pcall(function()
		return real[key]
	end)
	if ok and v ~= nil then
		return v
	end
	return default
end

local function guiParentOf(real)
	local p = real.Parent
	while p and not (p:IsA("GuiObject") or p:IsA("LayerCollector")) do
		if p:IsA("Folder") then
			p = p.Parent
		else
			return nil
		end
	end
	return p
end

local function screenRect(gui)
	local ignore = readOr(gui, "IgnoreGuiInset", false)
	local inset = if ignore then 0 else device.inset
	return 0, inset, device.width, device.height - inset
end

local function uiScaleOf(real): number
	local s = real:FindFirstChildOfClass("UIScale")
	return if s then readOr(s, "Scale", 1) else 1
end

-- x, y, w, h (absolute pixels) and the scale everything inside is drawn at
local function absRect(real, depth: number?)
	depth = (depth or 0) + 1
	if depth > 64 then
		return 0, 0, 0, 0, 1
	end
	if real:IsA("LayerCollector") then
		local x, y, w, h = screenRect(real)
		return x, y, w, h, 1
	end
	if not real:IsA("GuiObject") then
		return 0, 0, 0, 0, 1
	end
	local parent = guiParentOf(real)
	local size = real.Size
	if not parent then
		return 0, 0, size.X.Offset, size.Y.Offset, 1
	end
	local px, py, pw, ph, ps = absRect(parent, depth)
	if parent:IsA("GuiObject") then
		local pad = parent:FindFirstChildOfClass("UIPadding")
		if pad then
			local l = pad.PaddingLeft.Scale * pw + pad.PaddingLeft.Offset * ps
			local r = pad.PaddingRight.Scale * pw + pad.PaddingRight.Offset * ps
			local t = pad.PaddingTop.Scale * ph + pad.PaddingTop.Offset * ps
			local b = pad.PaddingBottom.Scale * ph + pad.PaddingBottom.Offset * ps
			px, py, pw, ph = px + l, py + t, pw - l - r, ph - t - b
		end
	end
	local own = uiScaleOf(real)
	local bw = size.X.Scale * pw + size.X.Offset * ps
	local bh = size.Y.Scale * ph + size.Y.Offset * ps
	local pos, anchor = real.Position, real.AnchorPoint
	local ax = px + pos.X.Scale * pw + pos.X.Offset * ps
	local ay = py + pos.Y.Scale * ph + pos.Y.Offset * ps
	local w, h = bw * own, bh * own
	return ax - anchor.X * w, ay - anchor.Y * h, w, h, ps * own
end

local function absolute(real, key: string)
	local x, y, w, h = absRect(real)
	if key == "AbsoluteSize" or key == "AbsoluteWindowSize" then
		return roblox.Vector2.new(w, h)
	elseif key == "AbsolutePosition" then
		return roblox.Vector2.new(x, y)
	elseif key == "AbsoluteCanvasSize" then
		-- big on purpose: code that scrolls to the end sets CanvasPosition past the end, and
		-- the renderer clamps it to the real end once it knows how tall the content is
		return roblox.Vector2.new(math.max(w, 100000), 100000)
	elseif key == "AbsoluteRotation" then
		local r = 0
		local p = real
		while p and p:IsA("GuiObject") do
			r += p.Rotation
			p = guiParentOf(p)
		end
		return r
	elseif key == "AbsoluteContentSize" then
		return roblox.Vector2.new(0, 0)
	end
	return roblox.Vector2.new(w, h)
end

-- ── methods on proxies ──────────────────────────────────────────────────────
local Methods = {}
function Methods.Destroy(p)
	local real = realOf[p]
	local list = { p }
	for _, d in real:GetDescendants() do
		local dp = proxyOf[d]
		if dp then
			table.insert(list, dp)
		end
	end
	for _, item in list do
		local sig = signalsOf[item] and signalsOf[item].Destroying
		if sig then
			sig:Fire()
		end
	end
	real:Destroy()
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
function Methods.FindFirstChild(p, name, recursive)
	return wrap(realOf[p]:FindFirstChild(name, recursive == true))
end
function Methods.FindFirstChildOfClass(p, cls)
	return wrap(realOf[p]:FindFirstChildOfClass(cls))
end
function Methods.FindFirstChildWhichIsA(p, cls, recursive)
	return wrap(realOf[p]:FindFirstChildWhichIsA(cls, recursive == true))
end
function Methods.FindFirstAncestor(p, name)
	local a = realOf[p].Parent
	while a and a.Name ~= name do
		a = a.Parent
	end
	return wrap(a)
end
function Methods.FindFirstAncestorOfClass(p, cls)
	local a = realOf[p].Parent
	while a and a.ClassName ~= cls do
		a = a.Parent
	end
	return wrap(a)
end
function Methods.FindFirstAncestorWhichIsA(p, cls)
	local a = realOf[p].Parent
	while a and not a:IsA(cls) do
		a = a.Parent
	end
	return wrap(a)
end
function Methods.IsDescendantOf(p, other)
	local target = unwrap(other)
	local a = realOf[p].Parent
	while a do
		if a == target then
			return true
		end
		a = a.Parent
	end
	return false
end
function Methods.WaitForChild(p, name)
	local c = realOf[p]:FindFirstChild(name)
	assert(c, "WaitForChild would hang forever: " .. tostring(name))
	return wrap(c)
end
function Methods.IsA(p, cls)
	return realOf[p]:IsA(cls)
end
function Methods.Clone(p)
	return wrap(realOf[p]:Clone())
end
function Methods.SetAttribute(p, k, v)
	realOf[p]:SetAttribute(k, v)
	local sig = signalsOf[p] and signalsOf[p].AttributeChanged
	if sig then
		sig:Fire(k)
	end
end
function Methods.GetAttribute(p, k)
	return realOf[p]:GetAttribute(k)
end
function Methods.GetAttributes(p)
	return realOf[p]:GetAttributes()
end
function Methods.GetFullName(p)
	return realOf[p]:GetFullName()
end
function Methods.GetPropertyChangedSignal(p, prop)
	local real = realOf[p]
	if string.sub(prop, 1, 8) ~= "Absolute" then
		local _ = readOr(real, prop, nil) -- (a typo in the name would fail here in ui_smoke)
	end
	propSignals[p] = propSignals[p] or {}
	propSignals[p][prop] = propSignals[p][prop] or Signal.new()
	return propSignals[p][prop]
end
function Methods.ClearAllChildren(p)
	realOf[p]:ClearAllChildren()
end
function Methods.FillBlock(_, cf, size, material)
	assert(luneTypeof(cf) == "CFrame" and luneTypeof(size) == "Vector3" and luneTypeof(material) == "EnumItem", "bad FillBlock args")
end
function Methods.InvokeServer(p, ...)
	local cb = callbacks[p]
	assert(cb, "InvokeServer with no OnServerInvoke set")
	remoteCalls += 1
	-- a round trip takes a moment, and the server's rate limit counts on os.clock
	now += 0.13
	local args = marshal({ ... }, "args")
	return marshal(cb(localPlayer, table.unpack(args)), "response")
end
function Methods.GetPlayers(_)
	local list = {}
	for _, child in realPlayers:GetChildren() do
		if child:IsA("Player") then
			table.insert(list, wrap(child))
		end
	end
	return list
end
function Methods.GetPlayerByUserId(_, id)
	for _, child in realPlayers:GetChildren() do
		if child:IsA("Player") and (userIds[child] or 4242) == id then
			return wrap(child)
		end
	end
	return nil
end
-- server -> client pushes: delivered to the app for the local player, recorded for others
function Methods.FireClient(p, player, payload)
	assert(realOf[p]:IsA("RemoteEvent"), "FireClient on a non-RemoteEvent")
	local data = marshal(payload, "push")
	if player == localPlayer then
		local sig = signalsOf[p] and signalsOf[p].OnClientEvent
		if sig then
			sig:Fire(data)
		end
	else
		table.insert(pushes, { player = player, payload = data })
	end
end
function Methods.FireAllClients(p, payload)
	for _, child in realPlayers:GetChildren() do
		if child:IsA("Player") then
			Methods.FireClient(p, wrap(child), payload)
		end
	end
end
function Methods.Kick(_, msg)
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
function Methods.Play(p)
	local _ = realOf[p]
end
function Methods.Stop(p)
	local _ = realOf[p]
end
function Methods.Pause(p)
	local _ = realOf[p]
end
function Methods.Resume(p)
	local _ = realOf[p]
end
function Methods.CaptureFocus() end
function Methods.ReleaseFocus() end
function Methods.IsFocused()
	return false
end

local function fireChanged(p, key)
	local ps = propSignals[p]
	if ps and ps[key] then
		ps[key]:Fire()
	end
	local changed = signalsOf[p] and signalsOf[p].Changed
	if changed then
		changed:Fire(key)
	end
end

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
		return absolute(real, key)
	end
	local cls = real.ClassName
	if key == "LocalPlayer" and cls == "Players" then
		return localPlayer
	end
	if cls == "Player" then
		if key == "UserId" then
			return userIds[real] or 4242
		elseif key == "DisplayName" then
			return real.Name
		end
	end
	if key == "CurrentCamera" then
		if cls == "Workspace" then
			return wrap(workspaceCamera)
		elseif real:IsA("ViewportFrame") then
			return wrap(vpCamera[real])
		end
	end
	if key == "ViewportSize" and real == workspaceCamera then
		return roblox.Vector2.new(device.width, device.height)
	end
	if key == "TextBounds" and real:IsA("GuiObject") then
		local text = tostring(readOr(real, "Text", ""))
		local size = readOr(real, "TextSize", 14)
		local lines = select(2, string.gsub(text, "\n", "\n")) + 1
		return roblox.Vector2.new(math.min(#text, 400) * size * 0.5, size * lines)
	end
	if key == "TextFits" then
		return true
	end
	local v = real[key]
	if type(v) == "function" then
		-- a method this harness doesn't special-case: call it on the real instance
		return function(_self, ...)
			local args = table.pack(...)
			for i = 1, args.n do
				args[i] = unwrap(args[i])
			end
			local out = table.pack(v(real, table.unpack(args, 1, args.n)))
			for i = 1, out.n do
				if luneTypeof(out[i]) == "Instance" then
					out[i] = wrap(out[i])
				end
			end
			return table.unpack(out, 1, out.n)
		end
	end
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
	value = unwrap(value)
	if key == "CurrentCamera" then
		if real.ClassName == "Workspace" then
			workspaceCamera = value
			return
		elseif real:IsA("ViewportFrame") then
			vpCamera[real] = value
			pcall(function()
				real.CurrentCamera = value
			end)
			return
		end
	end
	real[key] = value
	fireChanged(p, key)
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

-- TweenService on the virtual clock
local function startTween(tw)
	local real = realOf[tw.inst]
	if not real then
		return
	end
	-- a newer tween on the same property takes it over
	for _, other in tweens do
		if other ~= tw and other.inst == tw.inst then
			for k in tw.props do
				other.props[k] = nil
			end
		end
	end
	tw.from = {}
	for k in tw.props do
		tw.from[k] = readOr(real, k, nil)
	end
	tw.start = now + tw.delay
	tw.state = "Playing"
	if not table.find(tweens, tw) then
		table.insert(tweens, tw)
	end
end

local function updateTweens()
	local live = {}
	for _, tw in tweens do
		if tw.state ~= "Playing" then
			continue
		end
		if now < tw.start then
			table.insert(live, tw)
			continue
		end
		local t = if tw.time <= 0 then 1 else (now - tw.start) / tw.time
		local done = t >= 1
		local k = if tw.reversing then 1 - ease(tw.style, tw.direction, t) else ease(tw.style, tw.direction, t)
		local ok = pcall(function()
			for key, target in tw.props do
				local from = tw.from[key]
				if from ~= nil then
					tw.inst[key] = lerp(from, target, k)
				else
					tw.inst[key] = target
				end
			end
		end)
		if not ok then
			tw.state = "Cancelled"
			continue
		end
		if done then
			if tw.reverses and not tw.reversing then
				tw.reversing = true
				tw.start = now
				table.insert(live, tw)
			elseif tw.repeats ~= 0 then
				tw.repeats -= 1
				tw.reversing = false
				tw.start = now
				table.insert(live, tw)
			else
				tw.state = "Completed"
				tw.Completed:Fire(roblox.Enum.PlaybackState.Completed)
			end
		else
			table.insert(live, tw)
		end
	end
	tweens = live
end

local function tweenService()
	return {
		Create = function(_, inst, info, props)
			assert(type(info) == "table" and info.__tweenInfo, "TweenService:Create needs a TweenInfo")
			assert(type(inst) == "table" and realOf[inst], "TweenService:Create needs an Instance")
			local real = realOf[inst]
			for k, v in props do
				-- validates tweened property names and types, like Roblox does on Create
				local current = real[k]
				assert(luneTypeof(current) == luneTypeof(v) or current == nil, "can't tween " .. tostring(k) .. " from " .. luneTypeof(current) .. " to " .. luneTypeof(v))
			end
			local a = info.args
			local tw = {
				inst = inst,
				props = table.clone(props),
				time = tonumber(a[1]) or 1,
				style = if a[2] then a[2].Name else "Quad",
				direction = if a[3] then a[3].Name else "Out",
				repeats = tonumber(a[4]) or 0,
				reverses = a[5] == true,
				delay = tonumber(a[6]) or 0,
				state = "Begin",
				Completed = Signal.new(),
			}
			function tw.Play()
				startTween(tw)
			end
			function tw.Cancel()
				tw.state = "Cancelled"
			end
			function tw.Pause()
				tw.state = "Paused"
			end
			function tw.Destroy()
				tw.state = "Cancelled"
			end
			return setmetatable(tw, {
				__index = function(_, k)
					if k == "PlaybackState" then
						return roblox.Enum.PlaybackState[tw.state]
					end
					return nil
				end,
			})
		end,
		GetValue = function(_, alpha, style, direction)
			return ease(style.Name, direction.Name, alpha)
		end,
	}
end

-- ── one frame of the world ──────────────────────────────────────────────────
local runService = nil
local function step()
	frameNo += 1
	now += FRAME
	updateTweens()
	if runService then
		for _, fn in runService.bound do
			local ok, err = pcall(fn, FRAME)
			if not ok then
				table.insert(errors, "RenderStep: " .. tostring(err))
			end
		end
		runService.RenderStepped:Fire(FRAME)
		runService.Stepped:Fire(now, FRAME)
		runService.Heartbeat:Fire(FRAME)
	end
	local due, keep = {}, {}
	for _, s in sleepers do
		if s.minFrame <= frameNo and s.wake <= now + 1e-9 then
			table.insert(due, s)
		else
			table.insert(keep, s)
		end
	end
	sleepers = keep
	table.sort(due, function(a, b)
		if a.wake ~= b.wake then
			return a.wake < b.wake
		end
		return a.seq < b.seq
	end)
	for _, s in due do
		if s.isWait then
			resume(s.co, now - s.start)
		else
			resume(s.co, table.unpack(s.args, 1, s.args.n))
		end
		flushDeferred()
	end
	flushDeferred()
end

-- ── boot ────────────────────────────────────────────────────────────────────
--[[
	device = { name, width, height, inset (topbar, px), touch, keyboard, mouse, gamepad }
	Returns h, the handle the driver uses (h.* below).
]]
function Harness.boot(dev, opts)
	opts = opts or {}
	device = dev
	math.randomseed(opts.seed or 1)
	local fs = require("@lune/fs")
	assert(fs.isDir("src/client") and fs.isDir("src/server") and fs.isDir("src/shared"), "run this from the repo root (src/client, src/server and src/shared must be here)")

	local dm = roblox.Instance.new("DataModel")
	local realLocal = roblox.Instance.new("Player")
	realLocal.Name = "Tester"
	realLocal.Parent = dm:GetService("Players")
	local playerGui = roblox.Instance.new("PlayerGui")
	playerGui.Parent = realLocal
	realPlayers = dm:GetService("Players")
	localPlayer = wrap(realLocal)
	userIds[realLocal] = 4242
	local realWorkspace = dm:GetService("Workspace")
	workspaceCamera = roblox.Instance.new("Camera")
	workspaceCamera.Name = "Camera"
	workspaceCamera.Parent = realWorkspace

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
							return text
						end,
					}
				end,
				GetTextSize = function(_, text, size)
					return roblox.Vector2.new(#tostring(text) * size * 0.5, size)
				end,
			}
		elseif name == "TweenService" then
			s = tweenService()
		elseif name == "RunService" then
			s = {
				Heartbeat = Signal.new(),
				RenderStepped = Signal.new(),
				Stepped = Signal.new(),
				PreRender = Signal.new(),
				PreSimulation = Signal.new(),
				PostSimulation = Signal.new(),
				bound = {},
				IsStudio = function()
					return true
				end,
				IsClient = function()
					return true
				end,
				IsServer = function()
					return true
				end,
			}
			-- the camera loops of the (stubbed) 3D backdrop would run here every frame
			s.BindToRenderStep = function(_, bindName, _prio, fn)
				s.bound[bindName] = fn
			end
			s.UnbindFromRenderStep = function(_, bindName)
				s.bound[bindName] = nil
			end
			runService = s
		elseif name == "Players" then
			s = wrap(realPlayers)
		elseif name == "StarterGui" then
			s = { SetCoreGuiEnabled = function() end, SetCore = function() end, GetCoreGuiEnabled = function()
				return true
			end }
		elseif name == "UserInputService" then
			s = {
				TouchEnabled = dev.touch == true,
				KeyboardEnabled = dev.keyboard == true,
				MouseEnabled = dev.mouse == true,
				GamepadEnabled = dev.gamepad == true,
				VREnabled = false,
				InputBegan = Signal.new(),
				InputChanged = Signal.new(),
				InputEnded = Signal.new(),
				LastInputTypeChanged = Signal.new(),
				TextBoxFocused = Signal.new(),
				TextBoxFocusReleased = Signal.new(),
				GetLastInputType = function()
					return if dev.touch then roblox.Enum.UserInputType.Touch else roblox.Enum.UserInputType.MouseButton1
				end,
				GetMouseLocation = function()
					return roblox.Vector2.new(-1000, -1000)
				end,
			}
		elseif name == "GuiService" then
			s = {
				IsTenFootInterface = function()
					return dev.console == true
				end,
				GetGuiInset = function()
					return roblox.Vector2.new(0, dev.inset), roblox.Vector2.new(0, 0)
				end,
				SelectedObject = nil,
				AutoSelectGuiEnabled = true,
				TopbarInset = { Height = dev.inset, Width = dev.width, Min = roblox.Vector2.new(0, 0), Max = roblox.Vector2.new(dev.width, dev.inset) },
			}
		elseif name == "TextChatService" then
			-- no chat channel here: city news falls back to StarterGui:SetCore
			s = { FindFirstChild = function()
				return nil
			end }
		elseif name == "ContextActionService" then
			s = { BindAction = function() end, UnbindAction = function() end, BindActionAtPriority = function() end }
		elseif name == "SoundService" then
			s = wrap(dm:GetService("SoundService"))
			Methods.PlayLocalSound = function() end
		elseif name == "MarketplaceService" then
			s = {
				PromptGamePassPurchase = function() end,
				PromptProductPurchase = function() end,
				UserOwnsGamePassAsync = function()
					return false
				end,
				GetProductInfo = function()
					return {}
				end,
				PromptGamePassPurchaseFinished = Signal.new(),
				PromptProductPurchaseFinished = Signal.new(),
			}
			local real = dm:GetService("MarketplaceService")
			setmetatable(s, { __index = function(_, k)
				return wrap(real)[k]
			end, __newindex = function(_, k, v)
				if k == "ProcessReceipt" then
					return
				end
				wrap(real)[k] = v
			end })
		elseif name == "SocialService" then
			s = {
				CanSendGameInviteAsync = function()
					return false
				end,
				PromptGameInvite = function() end,
			}
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

	-- a fixed date, so today's City event and the daily streak are the same every run
	local BASE_TIME = opts.baseTime or 1795000000
	local fakeOs = setmetatable({
		clock = function()
			return now
		end,
		time = function(t)
			if t ~= nil then
				return os.time(t)
			end
			return BASE_TIME + math.floor(now)
		end,
	}, { __index = os })

	Loader.globals = {
		game = { GetService = function(_, name)
			return service(name)
		end, CreatorType = roblox.Enum.CreatorType.User, CreatorId = 0, PlaceId = 0, JobId = "gui-snapshot" },
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
		Rect = roblox.Rect,
		Enum = roblox.Enum,
		Font = roblox.Font,
		Random = RandomStub,
		TweenInfo = {
			new = function(...)
				return { __tweenInfo = true, args = { ... } }
			end,
		},
		task = task,
		wait = task.wait,
		delay = task.delay,
		spawn = task.defer,
		tick = function()
			return BASE_TIME + now
		end,
		time = function()
			return now
		end,
		os = fakeOs,
		-- the game's own warnings (a screen that failed to build says so here) go into errors;
		-- its prints are kept quiet unless opts.verbose
		warn = function(...)
			local parts = {}
			for i = 1, select("#", ...) do
				table.insert(parts, tostring((select(i, ...))))
			end
			table.insert(errors, "warning: " .. table.concat(parts, " "))
		end,
		print = if opts.verbose then print else function() end,
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

	-- ProfileStore stand-in: an in-memory profile per key
	local savedProfiles = {}
	Loader.overrides["src/server/ProfileStore.luau"] = {
		New = function(storeName, template)
			assert(type(storeName) == "string", "store name")
			return {
				StartSessionAsync = function(_, key, params)
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
					function profile:Save() end
					function profile:IsActive()
						return true
					end
					return profile
				end,
			}
		end,
	}
	-- the 3D backdrop isn't GUI: any call into it does nothing
	local noop = setmetatable({}, { __index = function()
		return function() end
	end })
	Loader.overrides["src/client/Backdrop.luau"] = noop
	Loader.overrides["src/client/BackdropCity.luau"] = noop

	-- every source is read up front (Lune's fs calls can't run inside the scheduler's coroutines)
	sharedRoot = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
	local clientRoot = Loader.preload(Loader.node("src/client", "Client", nil))
	local serverRoot = Loader.preload(Loader.node("src/server", "Server", nil))

	local Config = Loader.require(sharedRoot.Config)
	-- no random world events: the same pictures every run
	-- (v0.18) the screenshots still make their grown-up lives on Fixer's Road (hidden from players)
	Config.devModes = true
	if type(Config.worldEvents) == "table" then
		Config.worldEvents.enabled = false
	end
	for k, v in opts.config or {} do
		Config[k] = v
	end
	local pack = Loader.pack(sharedRoot)

	-- ViewportFrames from AvatarView remember the look they show
	local okAv, AvatarView = pcall(Loader.require, clientRoot.UI.AvatarView)
	if okAv and type(AvatarView) == "table" and AvatarView.new and AvatarView.set then
		local origNew, origSet = AvatarView.new, AvatarView.set
		AvatarView.new = function(ctx, o)
			local view = origNew(ctx, o)
			local vp = view and view.viewport and realOf[view.viewport]
			if vp then
				avatarOf[vp] = { framing = view.framing, spin = (o and o.spin) == true, chart = (o and o.chart) == true }
			end
			return view
		end
		AvatarView.set = function(self, appearance)
			origSet(self, appearance)
			local vp = self.viewport and realOf[self.viewport]
			local rec = vp and avatarOf[vp]
			if rec and appearance then
				local ok, copy = pcall(marshal, appearance, "appearance")
				rec.appearance = if ok then copy else nil
				rec.framing = self.framing
			end
		end
	end

	local h = {
		device = dev,
		Loader = Loader,
		roblox = roblox,
		pack = pack,
		Config = Config,
		sharedRoot = sharedRoot,
		clientRoot = clientRoot,
		serverRoot = serverRoot,
		realPlayerGui = playerGui,
		gui = wrap(playerGui),
		wrap = wrap,
		realOf = realOf,
		signalsOf = signalsOf,
		avatarOf = avatarOf,
		vpCamera = vpCamera,
		errors = errors,
		pushes = pushes,
		kicked = kicked,
		callbacks = callbacks,
		service = service,
		userIds = userIds,
		dm = dm,
	}
	function h.now()
		return now
	end
	function h.remoteCalls()
		return remoteCalls
	end
	function h.require(node)
		return Loader.require(node)
	end
	-- a second player on the server (crews, links, duels)
	function h.addPlayer(name: string, userId: number)
		local real = roblox.Instance.new("Player")
		real.Name = name
		userIds[real] = userId
		real.Parent = realPlayers
		local p = wrap(real)
		local players = service("Players")
		local sig = signalsOf[players] and signalsOf[players].PlayerAdded
		if sig then
			sig:Fire(p)
		end
		local remotes = sharedRoot:FindFirstChild("Remotes")
		local requestFn = remotes and remotes:FindFirstChild("Request")
		return function(action: string, payload: any?)
			assert(requestFn and callbacks[requestFn], "the server isn't listening yet")
			return marshal(callbacks[requestFn](p, action, marshal(payload, "player args")), "player response")
		end, p
	end
	return h
end

--[[
	Runs `driver(h)` as the main coroutine and turns the clock until it finishes. The driver
	lets time pass with task.wait (h.wait in gui_snapshot). `onFrame()` runs on the main
	thread after every frame (file writes go there: Lune's fs can't run in these coroutines).
	maxSeconds stops a driver that never ends.
]]
function Harness.run(driver, h, onFrame, maxSeconds: number?)
	local co = coroutine.create(driver)
	resume(co, h)
	local limit = now + (maxSeconds or 1800)
	while coroutine.status(co) ~= "dead" do
		if now > limit then
			table.insert(errors, "the driver ran past " .. tostring(maxSeconds or 1800) .. " virtual seconds; stopped")
			break
		end
		step()
		if onFrame then
			onFrame()
		end
	end
	if onFrame then
		onFrame()
	end
end

Harness.step = step
Harness.task = task
Harness.FRAME = FRAME
Harness.process = process

return Harness
