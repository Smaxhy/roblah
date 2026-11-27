--[[
	Opens the BitLeveling client screens (UI/HunterBoard, UI/R6Creator) on @lune/roblox GUI
	instances with sample data: every class and property they set is checked against Roblox's API.
		lune run tests/live_ui_check
]]
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")
local I = roblox.Instance

-- @lune/roblox has real classes and properties but no events: a thin proxy answers events
-- (Activated, MouseEnter...) with a stub signal and passes everything else to the real instance
local signalStub = { Connect = function()
	return { Disconnect = function() end, Connected = true }
end }
local REAL = setmetatable({}, { __mode = "k" })
local function unwrap(v)
	return REAL[v] or v
end
local EVENTS = { Activated = true, MouseEnter = true, MouseLeave = true, MouseButton1Click = true, Changed = true, Triggered = true, Died = true, DescendantAdded = true, Running = true, StateChanged = true }
local function wrap(real)
	local proxy = {}
	REAL[proxy] = real
	return setmetatable(proxy, {
		__index = function(_, k)
			if EVENTS[k] then
				return signalStub
			end
			if k == "GetPropertyChangedSignal" then
				return function()
					return signalStub
				end
			end
			local v = real[k]
			if type(v) == "function" then
				return function(_, ...)
					local args = table.pack(...)
					for i = 1, args.n do
						args[i] = unwrap(args[i])
					end
					return v(real, table.unpack(args, 1, args.n))
				end
			end
			return v
		end,
		__newindex = function(_, k, v)
			real[k] = unwrap(v)
		end,
	})
end
local ProxyInstance = { new = function(className, parent)
	local r = roblox.Instance.new(className)
	if parent then
		r.Parent = unwrap(parent)
	end
	return wrap(r)
end }

local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local hairCache = I.new("Folder")
hairCache.Name = "HunterHairCache"
local signal = { Connect = function()
	return { Disconnect = function() end, Connected = true }
end }
Loader.globals = {
	Instance = ProxyInstance, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font,
	NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
	ColorSequence = roblox.ColorSequence, TweenInfo = { new = function(...)
		return { ... }
	end },
	task = { spawn = function(f, ...)
		f(...)
	end, delay = function() end, wait = function()
		return 0
	end, defer = function(f, ...)
		f(...)
	end },
	game = { GetService = function(_, name)
		if name == "ReplicatedStorage" then
			return { WaitForChild = function(_, child)
				if child == "HunterHairCache" then
					return hairCache
				end
				return shared
			end }
		elseif name == "RunService" then
			return { RenderStepped = signal, Heartbeat = signal }
		elseif name == "TweenService" then
			return { Create = function()
				return { Play = function() end }
			end }
		end
		return {}
	end },
}
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local Board = Loader.require(client.UI.HunterBoard)
local Creator = Loader.require(client.UI.R6Creator)
local R6Rig = Loader.require(shared.Hunter.R6Rig)
local Looks = Loader.require(shared.Hunter.Looks)

local fails = 0
local function check(ok, msg, err)
	print((if ok then "  ok    " else "  FAIL  ") .. msg .. (if ok then "" else ": " .. tostring(err)))
	if not ok then
		fails += 1
	end
end

local gui = ProxyInstance.new("ScreenGui")
local sampleBoard = {
	modeName = "Normal World", gateYear = 10, beforeGates = false, city = "Seoul", country = "Korea", rank = "C", rewritten = false,
	news = { { year = 10, tag = "canon", tone = "strange", text = "The Association confirms Korea's 10th S-rank Hunter." }, { year = 10, tag = "local", tone = "danger", text = "DUNGEON BREAK at Hongdae's main street." } },
	recent = { { n = 1, year = 10, rank = 3, kind = "gate", place = "Hongdae", city = "Seoul", outcome = "break_contained", dead = 4, broke = true, player = { role = "fought", won = true } } },
	history = { { kind = "awakened", age = 17, rank = 3, class = "fighter" }, { kind = "break", age = 24, rank = 3, place = "Hongdae", role = "fought" } },
	counts = { witnessed = 3, survived = 3, raids = 1, red = 0, double = 0, saved = 2 },
}
local okB, eB = pcall(Board.open, gui, function(action)
	if action == "hwBoard" then
		return { ok = true, board = sampleBoard }
	end
	return nil
end, { { id = 1, rank = 3, stage = "escalated", label = "the plaza", headline = "DUNGEON BREAK at the plaza", broke = true } })
check(okB, "the Hunter news board opens and fills", eB)
local okC, eC = pcall(Creator.open, gui, function(action)
	if action == "r6Get" then
		return { ok = true, look = Looks.DEFAULT }
	end
	return { ok = true }
end, R6Rig)
check(okC, "the R6 creator opens, builds its preview and every option tab", eC)
local count = 0
for _, d in unwrap(gui):GetDescendants() do
	if d:IsA("GuiObject") then
		count += 1
	end
end
print(string.format("        %d GUI objects", count))
if fails > 0 then
	process.exit(1)
end
