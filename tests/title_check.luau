--[[
	THE TITLE SCREEN AND MAIN MENU (client/UI/TitleMenu), CHECKED ON REAL ROBLOX INSTANCE TYPES.
		lune run tests/title_check              (add -- shot to also write tools/ui/shots/title.json
		                                         and menu.json for tools/gui_render/shoot.js)
	  1. the title builds: the 3D scene (a Gate, six Hunters in class gear, drifting mana), the
	     logo, PLAY
	  2. PLAY opens the menu: CONTINUE (with a life), NEW LIFE, CHARACTER, SPINS, WALK THE CITY,
	     NEWS, ENDINGS, MARKET, GUIDE, SETTINGS, and your Hunter on a podium
	  3. NEW LIFE: a card per world (difficulty); the one you pick and the mode (solo, with
	     friends) are what BEGIN starts
	  4. every other button calls what it says (character, life creator, both spins, the city...)
	  5. coming back to the menu (direct) skips the title
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local Loader = require("./loader")
local I = roblox.Instance

local failures = 0
local function check(ok, msg)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		failures += 1
	end
end
roblox.implementMethod("Model", "GetPivot", function(self)
	local pp = self.PrimaryPart
	return if pp then pp.CFrame else roblox.CFrame.new()
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
roblox.implementMethod("WorldModel", "BulkMoveTo", function(_, parts, cfs)
	for i, p in parts do
		p.CFrame = cfs[i]
	end
end)
roblox.implementMethod("ParticleEmitter", "Emit", function() end)

-- buttons' events: recorded, so the test can press them (keyed by a tag on the instance:
-- lune hands back a new userdata for the same instance on every lookup)
local handlers = {}
local function unwrap(x)
	return x
end
for _, cls in { "TextButton", "ImageButton" } do
	for _, ev in { "Activated", "MouseEnter", "MouseLeave", "MouseButton1Click" } do
		roblox.implementProperty(cls, ev, function(self)
			return { Connect = function(_, fn)
				local tag = self:GetAttribute("_h")
				if not tag then
					tag = tostring(math.random(1, 1e9))
					self:SetAttribute("_h", tag)
				end
				handlers[tag] = handlers[tag] or {}
				table.insert(handlers[tag], { event = ev, fn = fn })
				return { Disconnect = function() end }
			end }
		end)
	end
end
local function wrap(x)
	return x
end
local function press(btn)
	local n = 0
	for _, h in handlers[btn:GetAttribute("_h") or ""] or {} do
		if h.event == "Activated" then
			h.fn()
			n += 1
		end
	end
	return n
end
local function findButton(root, text)
	for _, d in root:GetDescendants() do
		if d:IsA("TextButton") and string.find(d.Text, text, 1, true) then
			return d
		end
		if d:IsA("TextButton") then
			for _, l in d:GetDescendants() do
				if l:IsA("TextLabel") and string.find(l.Text, text, 1, true) then
					return d
				end
			end
		end
	end
	return nil
end

local renderFns = {}
local signal = function(list)
	return { Connect = function(_, fn)
		table.insert(list, fn)
		return { Disconnect = function() end }
	end }
end
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
	}
end }
local services = {
	RunService = { RenderStepped = signal(renderFns), Heartbeat = signal({}) },
	TweenService = { Create = function(_, obj, _info, goal)
		return { Play = function()
			for k, v in goal do
				pcall(function()
					unwrap(obj)[k] = unwrap(v)
				end)
			end
		end, Cancel = function() end, Completed = signal({}) }
	end },
	UserInputService = { InputBegan = signal({}) },
}
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3, CFrame = roblox.CFrame,
	Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font, NumberRange = roblox.NumberRange, NumberSequence = roblox.NumberSequence,
	NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	TweenInfo = { new = function(t)
		return { Time = t }
	end },
	Random = RandomStub,
	task = { spawn = function(f, ...)
		f(...)
	end, delay = function(_, f, ...)
		f(...)
	end, wait = function() end },
	game = { GetService = function(_, name)
		return services[name] or { WaitForChild = function()
			return shared
		end }
	end },
}
local R6Rig = Loader.require(shared.Hunter.R6Rig)
local Looks = Loader.require(shared.Hunter.Looks)
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local GateVfx = Loader.require(client.GateVfx)
local TitleMenu = Loader.require(client.UI.TitleMenu)

-- the gui-snapshot writer (the same as tools/avatar/r6_sheet.luau's)
local defaults = {}
-- ── the dump (gui-snapshot/1, as tests/gui_snapshot.luau writes it) ──
local function num(x: number): number
	if x ~= x or x == math.huge or x == -math.huge then
		return 0
	end
	return math.floor(x * 1000 + 0.5) / 1000
end
local function byte(x: number): number
	return math.clamp(math.floor(x * 255 + 0.5), 0, 255)
end
local ENCODE = {
	number = num,
	string = function(v)
		return v
	end,
	boolean = function(v)
		return v
	end,
	UDim2 = function(v)
		return { num(v.X.Scale), num(v.X.Offset), num(v.Y.Scale), num(v.Y.Offset) }
	end,
	UDim = function(v)
		return { num(v.Scale), num(v.Offset) }
	end,
	Vector2 = function(v)
		return { num(v.X), num(v.Y) }
	end,
	Vector3 = function(v)
		return { num(v.X), num(v.Y), num(v.Z) }
	end,
	Color3 = function(c)
		return { byte(c.R), byte(c.G), byte(c.B) }
	end,
	EnumItem = function(e)
		return e.Name
	end,
	Font = function(f)
		return { family = f.Family, weight = f.Weight.Name, style = f.Style.Name }
	end,
	CFrame = function(cf)
		local out = {}
		for _, v in { cf:GetComponents() } do
			table.insert(out, math.floor(v * 100000 + 0.5) / 100000)
		end
		return out
	end,
}
local GUI = { "Visible", "Size", "Position", "AnchorPoint", "AutomaticSize", "Rotation", "ZIndex", "LayoutOrder", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "ClipsDescendants", "SizeConstraint",
	"CanvasSize", "CanvasPosition", "AutomaticCanvasSize", "ScrollingDirection", "ScrollBarThickness" }
local TEXT = { "Text", "FontFace", "TextSize", "TextScaled", "TextWrapped", "TextColor3", "TextTransparency", "TextXAlignment", "TextYAlignment", "TextTruncate", "TextStrokeColor3", "TextStrokeTransparency" }
local VIEWPORT = { "Ambient", "LightColor", "LightDirection", "ImageColor3", "ImageTransparency" }
local MODS = {
	UICorner = { "CornerRadius" },
	UIStroke = { "Color", "Thickness", "Transparency", "ApplyStrokeMode" },
	UIGradient = { "Color", "Transparency", "Rotation", "Offset", "Enabled" },
	UIPadding = { "PaddingTop", "PaddingRight", "PaddingBottom", "PaddingLeft" },
	UIListLayout = { "Padding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder" },
	UIGridLayout = { "CellSize", "CellPadding", "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder" },
}
local SCREEN = { "Enabled", "DisplayOrder", "IgnoreGuiInset", "ZIndexBehavior" }
local function propsFor(real)
	if MODS[real.ClassName] then
		return MODS[real.ClassName]
	elseif real:IsA("LayerCollector") then
		return SCREEN
	end
	local list = table.clone(GUI)
	if real:IsA("TextLabel") or real:IsA("TextButton") or real:IsA("TextBox") then
		for _, k in TEXT do
			table.insert(list, k)
		end
	elseif real:IsA("ViewportFrame") then
		for _, k in VIEWPORT do
			table.insert(list, k)
		end
	end
	return list
end
local function readAll(real)
	local out = {}
	for _, key in propsFor(real) do
		local ok, v = pcall(function()
			return real[key]
		end)
		if ok and v ~= nil then
			local e = ENCODE[typeof(v)]
			if e then
				out[key] = e(v)
			end
		end
	end
	return out
end
local function viewportOf(vp)
	local parts = {}
	for _, d in vp:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(parts, {
				class = d.ClassName,
				shape = if d:IsA("Part") then d.Shape.Name else "Block",
				size = ENCODE.Vector3(d.Size),
				cframe = ENCODE.CFrame(d.CFrame),
				color = ENCODE.Color3(d.Color),
				material = d.Material.Name,
				transparency = num(d.Transparency),
			})
		end
	end
	local cam = vp:FindFirstChildOfClass("Camera")
	return { camera = cam and { cframe = ENCODE.CFrame(cam.CFrame), fov = num(cam.FieldOfView) }, parts = parts }
end


local function node(real)
	if defaults[real.ClassName] == nil then
		defaults[real.ClassName] = readAll(I.new(real.ClassName))
	end
	local out = { class = real.ClassName, name = real.Name, props = readAll(real) }
	if real:IsA("ViewportFrame") then
		out.viewport = viewportOf(real)
	elseif not MODS[real.ClassName] then
		local kids = {}
		for _, child in real:GetChildren() do
			if child:IsA("GuiObject") or MODS[child.ClassName] then
				table.insert(kids, node(child))
			end
		end
		if #kids > 0 then
			out.children = kids
		end
	end
	return out
end

-- ── 1. the title ──
local calls = {}
local function rec(name)
	return function(...)
		table.insert(calls, { name = name, args = { ... } })
	end
end
local function env(hasLife, direct)
	return {
		R6Rig = R6Rig, Looks = Looks, GateVfx = GateVfx, hasLife = hasLife, direct = direct,
		lifeLine = "Han Seo-jin, 27 · C-rank Hunter",
		difficulties = { { id = "normal", name = "Normal World", desc = "The manhwa's pace: Gates are a danger you live alongside." }, { id = "crisis", name = "High-Danger World", desc = "Gates in every street, breaks every season. Lives are shorter." } },
		difficulty = "normal",
		modes = { { id = "life", name = "BitLeveling" } },
		look = Looks.applyPreset(Looks.DEFAULT, "commander"),
		on = {
			continue = rec("continue"), newLife = rec("newLife"), together = rec("together"), character = rec("character"),
			lifeCreator = rec("lifeCreator"), talentSpin = rec("talentSpin"), surnameSpin = rec("surnameSpin"), walk = rec("walk"),
			news = rec("news"), endings = rec("endings"), market = rec("market"), guide = rec("guide"), settings = rec("settings"),
		},
	}
end
local screen = I.new("ScreenGui")
screen.Name = "Title"
local ok, title = pcall(TitleMenu.show, wrap(screen), env(true, false))
check(ok, "the title builds" .. (if ok then "" else ": " .. tostring(title)))
if not ok then
	process.exit(1)
end
for _, fn in renderFns do
	fn(1 / 30)
end
local root = screen:FindFirstChild("BitLevelingTitle")
local sceneVp = root and root:FindFirstChild("Scene")
local world = sceneVp and sceneVp:FindFirstChildOfClass("WorldModel")
local hunters, neon = 0, 0
for _, m in (world and world:GetChildren()) or {} do
	if m:IsA("Model") and m:GetAttribute("R6Look") then
		hunters += 1
	end
end
for _, d in (world and world:GetDescendants()) or {} do
	if d:IsA("BasePart") and d.Material == roblox.Enum.Material.Neon then
		neon += 1
	end
end
check(hunters == 6, string.format("six Hunters stand in front of the Gate (%d)", hunters))
check(neon > 40, "the Gate swirls and mana drifts (neon in the scene)")
local logo = root and root:FindFirstChild("Logo")
local word = ""
for _, l in (logo and logo:GetChildren()) or {} do
	if l:IsA("TextLabel") then
		word ..= l.Text
	end
end
check(word == "BITLEVELING", "the logo spells BITLEVELING")
local play = root and root:FindFirstChild("Play")
check(play ~= nil and play.Text == "PLAY", "a big PLAY button")

local function shotOf(name)
	if not table.find(process.args, "shot") then
		return
	end
	-- (the sheet renderer draws a camera looking along an axis reliably: point them straight)
	for _, vp in screen:GetDescendants() do
		if vp:IsA("ViewportFrame") then
			local cam = vp:FindFirstChildOfClass("Camera")
			if cam and vp.Name == "Scene" then
				cam.CFrame = roblox.CFrame.new(0, 6.5, -24) * roblox.CFrame.Angles(0, math.pi, 0)
			elseif cam then
				cam.CFrame = roblox.CFrame.new(0, 3.3, -18) * roblox.CFrame.Angles(0, math.pi, 0)
			end
		end
	end
	if not fs.isDir("tools/ui/shots") then
		fs.writeDir("tools/ui/shots")
	end
	local W, H = 1600, 900
	screen.IgnoreGuiInset = true
	local doc = { format = "gui-snapshot/1", state = name, note = "BitLeveling " .. name, device = "pc", screen = { W, H }, inset = 0, defaults = defaults, guis = { node(screen) } }
	fs.writeFile("tools/ui/shots/" .. name .. ".json", serde.encode("json", doc, false))
	print("   wrote tools/ui/shots/" .. name .. ".json")
end
shotOf("title")

-- ── 2. PLAY opens the menu ──
check(press(play) == 1, "PLAY is pressable")
for _, fn in renderFns do
	fn(1 / 30)
end
local menu = root:FindFirstChild("Menu")
check(menu ~= nil, "PLAY opens the main menu")
local want = { "CONTINUE", "NEW LIFE", "CHARACTER", "SPINS", "WALK THE CITY", "NEWS", "ENDINGS", "MARKET", "GUIDE", "SETTINGS" }
local missing = {}
for _, w in want do
	if not findButton(menu, w) then
		table.insert(missing, w)
	end
end
check(#missing == 0, "the menu has every entry" .. (if #missing > 0 then " (missing " .. table.concat(missing, ", ") .. ")" else ""))
local podium = menu:FindFirstChild("Podium")
local you = podium and podium:FindFirstChildOfClass("WorldModel")
you = you and you:FindFirstChild("You")
check(you ~= nil, "your Hunter stands on the podium")

-- ── 3. NEW LIFE: worlds and modes ──
press(findButton(menu, "NEW LIFE"))
local page = menu:FindFirstChild("Page")
check(page ~= nil and findButton(page, "Normal World") ~= nil and findButton(page, "High-Danger World") ~= nil, "NEW LIFE shows a card per world")
press(findButton(page, "High-Danger World"))
page = menu:FindFirstChild("Page")
press(findButton(page, "BEGIN"))
local last = calls[#calls]
check(last and last.name == "newLife" and last.args[1] == "crisis", "BEGIN starts a life in the world you picked (High-Danger)")
press(findButton(page, "WITH FRIENDS"))
page = menu:FindFirstChild("Page")
press(findButton(page, "BEGIN"))
last = calls[#calls]
check(last and last.name == "together" and last.args[1] == "crisis", "with friends, BEGIN opens the lobby in that world")
shotOf("menu")

-- ── 4. everything else ──
local function did(name)
	for _, c in calls do
		if c.name == name then
			return true
		end
	end
	return false
end
press(findButton(menu, "CONTINUE"))
press(findButton(menu, "WALK THE CITY"))
for _, w in { "NEWS", "ENDINGS", "MARKET", "GUIDE", "SETTINGS" } do
	press(findButton(menu, w))
end
press(findButton(menu, "CHARACTER"))
press(findButton(menu:FindFirstChild("Page"), "Hunter Look"))
press(findButton(menu:FindFirstChild("Page"), "Life & Class"))
press(findButton(menu, "SPINS"))
press(findButton(menu:FindFirstChild("Page"), "Talent Spin"))
press(findButton(menu:FindFirstChild("Page"), "Family Name Spin"))
local notCalled = {}
for _, n in { "continue", "walk", "news", "endings", "market", "guide", "settings", "character", "lifeCreator", "talentSpin", "surnameSpin" } do
	if not did(n) then
		table.insert(notCalled, n)
	end
end
check(#notCalled == 0, "every button does what it says" .. (if #notCalled > 0 then " (not: " .. table.concat(notCalled, ", ") .. ")" else ""))

-- ── 5. back to the menu: no title ──
title.destroy()
local screen2 = I.new("ScreenGui")
local ok2, t2 = pcall(TitleMenu.show, wrap(screen2), env(false, true))
local root2 = screen2:FindFirstChild("BitLevelingTitle")
check(ok2 and root2 and root2:FindFirstChild("Menu") ~= nil and (root2:FindFirstChild("Menu") :: any):FindFirstChild("Page") ~= nil, "coming back goes straight to the menu (a new life's page open when there's no life)")
check(findButton(root2:FindFirstChild("Menu"), "CONTINUE") == nil, "no CONTINUE without a life")
local _ = t2

if failures > 0 then
	process.exit(1)
end
print("\nThe title opens on PLAY, and the menu does what it says.")
