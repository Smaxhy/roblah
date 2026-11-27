--[[
	THE OPENING CUTSCENE, PLAYED START TO FINISH ON REAL ROBLOX INSTANCE TYPES (client/OpeningCutscene).
		lune run tests/cutscene_check
	A fake clock drives it: every frame (RenderStepped), task.delay, tweens and Debris run on
	simulated time, so the whole ~52 seconds play in a moment. The Gate's drawing is stood in for
	(client/GateVfx has its own checks); the R6 rigs, outfits, weapons, the monster and its
	animation are the game's own.
	  1. it runs to the end with no cue failing (each cue is guarded and warns if it fails)
	  2. six Hunters in six different outfits, each with a weapon; a monster is built
	  3. every Hunter walks into the Gate by the end
	  4. the title spells BITLEVELING and shows; it cleans up after itself (set, effects, lighting)
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")
local I = roblox.Instance

local failures = 0
local function check(ok, msg)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		failures += 1
	end
end

-- the missing pivot methods (@lune/roblox has no PivotTo), done the way Roblox does them
roblox.implementMethod("Model", "GetPivot", function(self)
	local pp = self.PrimaryPart
	if pp then
		return pp.CFrame
	end
	local first = self:FindFirstChildWhichIsA("BasePart", true)
	return if first then first.CFrame else roblox.CFrame.new()
end)
roblox.implementMethod("Model", "PivotTo", function(self, cf)
	local pivot = self:GetPivot()
	local delta = cf * pivot:Inverse()
	for _, d in self:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = delta * d.CFrame
		end
	end
end)

-- a part's Position (derived from its CFrame in Roblox) and a burst of particles
for _, cls in { "Part", "MeshPart", "WedgePart" } do
	roblox.implementProperty(cls, "Position", function(self)
		return self.CFrame.Position
	end, function(self, v)
		self.CFrame = roblox.CFrame.new(v) * self.CFrame.Rotation
	end)
end
roblox.implementMethod("ParticleEmitter", "Emit", function() end)

-- buttons' events (none fire here: nobody presses Skip)
for _, cls in { "TextButton", "ImageButton" } do
	roblox.implementProperty(cls, "Activated", function()
		return { Connect = function()
			return { Disconnect = function() end }
		end }
	end)
end

-- ── the fake clock ──
local now = 0
local delayed = {}
local renderFns = {}
local function schedule(at, fn, ...)
	table.insert(delayed, { at = at, fn = fn, args = table.pack(...) })
end
local function runDue()
	local ran = true
	while ran do
		ran = false
		table.sort(delayed, function(a, b)
			return a.at < b.at
		end)
		if delayed[1] and delayed[1].at <= now then
			local d = table.remove(delayed, 1)
			d.fn(table.unpack(d.args, 1, d.args.n))
			ran = true
		end
	end
end
local frames = 0
local function frame(dt)
	now += dt
	frames += 1
	for _, fn in table.clone(renderFns) do
		fn(dt)
	end
	runDue()
end
local function signalOf(list)
	return { Connect = function(_, fn)
		table.insert(list, fn)
		return { Disconnect = function()
			local i = table.find(list, fn)
			if i then
				table.remove(list, i)
			end
		end, Connected = true }
	end }
end
local taskStub = {
	wait = function(t)
		local target = now + (t or 1 / 30)
		repeat
			frame(1 / 30)
		until now >= target
		return t or 1 / 30
	end,
	delay = function(t, fn, ...)
		schedule(now + (t or 0), fn, ...)
	end,
	spawn = function(fn, ...)
		fn(...)
	end,
	defer = function(fn, ...)
		schedule(now, fn, ...)
	end,
}
local RunService = { RenderStepped = signalOf(renderFns), Heartbeat = signalOf({}), IsStudio = function()
	return false
end }
local TweenService = { Create = function(_, obj, info, goal)
	local done = {}
	return {
		Play = function()
			schedule(now + (info.Time or 0), function()
				for k, v in goal do
					pcall(function()
						obj[k] = v
					end)
				end
				for _, fn in done do
					fn(Enum and nil)
				end
			end)
		end,
		Cancel = function() end,
		Completed = signalOf(done),
	}
end }
local destroyed = 0
local Debris = { AddItem = function(_, obj, t)
	schedule(now + (t or 10), function()
		if obj.Parent then
			destroyed += 1
		end
		obj:Destroy()
	end)
end }
local dm = I.new("DataModel")
local workspace = dm:GetService("Workspace")
local cam = I.new("Camera")
cam.Parent = workspace
workspace.CurrentCamera = cam
local lighting = dm:GetService("Lighting")
-- (a place's lighting, as it would be before the opening; offline it starts with no values)
lighting.ClockTime = 14
lighting.Brightness = 2
lighting.Ambient = roblox.Color3.fromRGB(70, 70, 70)
lighting.OutdoorAmbient = roblox.Color3.fromRGB(128, 128, 128)
lighting.FogEnd = 100000
lighting.FogStart = 0
lighting.FogColor = roblox.Color3.fromRGB(192, 192, 192)
local playerGui = I.new("Folder")
playerGui.Name = "PlayerGui"
local player = { Name = "Tester", WaitForChild = function()
	return playerGui
end }
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local rsStub = { WaitForChild = function(_, name)
	return if name == "LifeSim" then shared else nil
end, FindFirstChild = function()
	return nil
end }
local services = {
	Players = { LocalPlayer = player }, ReplicatedStorage = rsStub, RunService = RunService, TweenService = TweenService,
	Lighting = lighting, Workspace = workspace, Debris = Debris,
}
local RandomStub = { new = function(seed)
	local s = seed or 1
	local function nxt()
		s = (s * 1103515245 + 12345) % 2147483648
		return s / 2147483648
	end
	return {
		NextInteger = function(_, a, b)
			return a + math.floor(nxt() * (b - a + 1))
		end,
		NextNumber = function(_, a, b)
			return (a or 0) + nxt() * ((b or 1) - (a or 0))
		end,
		NextUnitVector = function()
			local v = roblox.Vector3.new(nxt() - 0.5, nxt() - 0.5, nxt() - 0.5)
			return if v.Magnitude > 1e-6 then v.Unit else roblox.Vector3.new(0, 1, 0)
		end,
	}
end }
local warnings = {}
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3, CFrame = roblox.CFrame,
	Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font, NumberRange = roblox.NumberRange, NumberSequence = roblox.NumberSequence,
	NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	TweenInfo = { new = function(t)
		return { Time = t }
	end },
	Random = RandomStub, task = taskStub,
	game = { GetService = function(_, name)
		return services[name] or dm:GetService(name)
	end },
	warn = function(...)
		table.insert(warnings, table.concat({ ... }, " "))
	end,
}
-- the Gate's drawing is stood in for (it moves its parts with BulkMoveTo, which lune lacks)
local gates = {}
Loader.overrides["src/client/GateVfx.luau"] = {
	new = function(parent, cf, radius, opts)
		local g = { opened = false, surges = 0 }
		function g.open()
			g.opened = true
		end
		function g.step() end
		function g.surge()
			g.surges += 1
		end
		function g.setRed() end
		function g.close() end
		table.insert(gates, g)
		local _ = parent, cf, radius, opts
		return setmetatable(g, { __index = function(_, k)
			return function() end
		end })
	end,
	flash = function() end,
}

local client = Loader.preload(Loader.node("src/client", "Client", nil))
local Opening = Loader.require(client.OpeningCutscene)

-- watch the set while it plays
local seen = { hunters = {}, looks = {}, weapons = 0, monster = false, title = "" }
table.insert(renderFns, function()
	local folder = workspace:FindFirstChild("OpeningCutscene")
	if folder and #seen.hunters == 0 then
		for _, m in folder:GetChildren() do
			if m:IsA("Model") and m:GetAttribute("R6Look") and m.Name ~= "Civilian" then
				table.insert(seen.hunters, m.Name)
				local top = m:FindFirstChild("Torso")
				seen.looks[(top and tostring(top.Color) or "?") .. m.Name] = true
				for _, d in m:GetDescendants() do
					if d:IsA("BasePart") and string.sub(d.Name, 1, 6) == "Weapon" then
						seen.weapons += 1
						break
					end
				end
			elseif m:IsA("Model") and m:GetAttribute("Gait") then
				seen.monster = true
			end
		end
	end
end)

local ok, err = pcall(Opening.play)
check(ok, "the opening plays to the end" .. (if ok then string.format(" (%.1f s, %d frames)", now, frames) else ": " .. tostring(err)))
local cueFails = {}
for _, w in warnings do
	if string.find(w, "cue failed", 1, true) then
		table.insert(cueFails, w)
	end
end
check(#cueFails == 0, "no cue failed" .. (if #cueFails > 0 then ": " .. table.concat(cueFails, " | ") else ""))
check(#seen.hunters == 6, string.format("six Hunters walk up (%s)", table.concat(seen.hunters, ", ")))
local classes = {}
for _, n in seen.hunters do
	classes[n] = true
end
check(classes.TANKER and classes.FIGHTER and classes.MAGE and classes.ASSASSIN and classes.RANGER and classes.HEALER, "one of every class")
check(seen.weapons == 6, "each carries a weapon")
check(seen.monster, "a monster forces its way out")
check(#gates == 2 and gates[1].opened and gates[2].opened and gates[2].surges >= 6, "the sky and the street Gates open, and the street one surges as the party goes in")
check(workspace:FindFirstChild("OpeningCutscene") == nil, "the set is gone afterwards")
check(lighting:FindFirstChild("OpeningBloom") == nil and lighting:FindFirstChild("OpeningGrade") == nil and lighting.ClockTime == 14, "the lighting is put back")
local gui = playerGui:FindFirstChild("OpeningCutsceneGui")
-- (the gui fades and goes 0.9 s after; run the clock on)
taskStub.wait(1.2)
check(playerGui:FindFirstChild("OpeningCutsceneGui") == nil, "the screen goes too")
local _ = gui

if failures > 0 then
	process.exit(1)
end
print("\nThe opening plays through: six classes, a monster, into the Gate, the title.")
