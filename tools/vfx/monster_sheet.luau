--[[
	CONTACT SHEET OF THE LIVE CITY'S MONSTERS (server/HunterLive/Monsters.luau):
		lune run tools/vfx/monster_sheet.luau
		node tools/gui_render/shoot.js --dump tools/vfx/shots/monsters.json --png tools/vfx/shots/monsters.png --bg none --no-topbar
]]
local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local Loader = require("../../tests/loader")
local I = roblox.Instance
local suffix = ""
local noop = function() end
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font,
	ColorSequence = roblox.ColorSequence, NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
	NumberRange = roblox.NumberRange, TweenInfo = { new = function(...) return { ... } end },
	task = { delay = noop, spawn = noop, wait = function() return 0 end },
	game = { GetService = function(_, name)
		if name == "TweenService" then
			return { Create = function() return { Play = noop } end }
		elseif name == "RunService" then
			return { RenderStepped = { Connect = noop } }
		elseif name == "Workspace" then
			return { BulkMoveTo = function(_, parts, cfs)
				for i, p in parts do
					p.CFrame = cfs[i]
				end
			end }
		end
		return {}
	end },
}
local server = Loader.preload(Loader.node("src/server", "Server", nil))
local Monsters = Loader.require(server.HunterLive.Monsters)
local fakeWorld = { BulkMoveTo = function(_, parts, cfs)
	for i, p in parts do
		p.CFrame = cfs[i]
	end
end }

local function label(parent, text: string, x: number, y: number, w: number, size: number?, color)
	local t = I.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = roblox.UDim2.fromOffset(x, y)
	t.Size = roblox.UDim2.fromOffset(w, (size or 11) + 4)
	t.Text = text
	t.TextXAlignment = roblox.Enum.TextXAlignment.Left
	t.TextTruncate = roblox.Enum.TextTruncate.AtEnd
	t.TextColor3 = color or roblox.Color3.fromRGB(168, 170, 176)
	t.TextSize = size or 11
	t.FontFace = roblox.Font.new("rbxasset://fonts/families/Oswald.json", roblox.Enum.FontWeight.Medium)
	t.Parent = parent
	return t
end

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
local GUI = { "Visible", "Size", "Position", "AnchorPoint", "Rotation", "ZIndex", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "ClipsDescendants", "SizeConstraint" }
local TEXT = { "Text", "FontFace", "TextSize", "TextScaled", "TextWrapped", "TextColor3", "TextTransparency", "TextXAlignment", "TextYAlignment", "TextTruncate" }
local VIEWPORT = { "Ambient", "LightColor", "LightDirection", "ImageColor3", "ImageTransparency" }
local MODS = {
	UICorner = { "CornerRadius" },
	UIStroke = { "Color", "Thickness", "Transparency", "ApplyStrokeMode" },
}
local SCREEN = { "Enabled", "DisplayOrder", "IgnoreGuiInset", "ZIndexBehavior" }
local function propsFor(real)
	if MODS[real.ClassName] then
		return MODS[real.ClassName]
	elseif real:IsA("LayerCollector") then
		return SCREEN
	end
	local list = table.clone(GUI)
	if real:IsA("TextLabel") then
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



local cells = {}
for r = 1, 6 do
	for _, id in Monsters.KINDS[r] do
		table.insert(cells, { id = id, label = ({ "E", "D", "C", "B", "A", "S" })[r] .. "-rank · " .. Monsters.DEFS[id].name })
	end
end
local cols, cellW, cellH, gap, labelH, titleH = 6, 200, 190, 6, 14, 30
local rows = math.ceil(#cells / cols)
local W = gap + cols * (cellW + gap)
local H = titleH + gap + rows * (cellH + labelH + gap)
local gui = I.new("ScreenGui")
gui.IgnoreGuiInset = true
local back = I.new("Frame")
back.Size = roblox.UDim2.fromScale(1, 1)
back.BackgroundColor3 = roblox.Color3.fromRGB(6, 8, 14)
back.BorderSizePixel = 0
back.Parent = gui
label(back, "BITLEVELING · THE MONSTERS OF THE LIVE CITY (four kinds a rank)", gap, 6, W - 2 * gap, 16, roblox.Color3.fromRGB(255, 140, 110))
for i, cell in cells do
	local c, r = (i - 1) % cols, (i - 1) // cols
	local x, y = gap + c * (cellW + gap), titleH + gap + r * (cellH + labelH + gap)
	label(back, cell.label, x, y, cellW)
	local vp = I.new("ViewportFrame")
	vp.Position = roblox.UDim2.fromOffset(x, y + labelH)
	vp.Size = roblox.UDim2.fromOffset(cellW, cellH)
	vp.BackgroundColor3 = roblox.Color3.fromRGB(14, 16, 26)
	vp.Ambient = roblox.Color3.fromRGB(150, 150, 160)
	vp.LightColor = roblox.Color3.fromRGB(255, 250, 240)
	vp.Parent = back
	local model = Monsters.build(cell.id)
	model.Parent = vp
	local s = Monsters.DEFS[cell.id].size
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = roblox.CFrame.Angles(0, math.rad(-35), 0) * d.CFrame
		end
	end
	local cam = I.new("Camera")
	cam.FieldOfView = 40
	local target = roblox.Vector3.new(0, 2.6 * s, 0)
	cam.CFrame = roblox.CFrame.new(target + roblox.Vector3.new(0, 0.5 * s, -11 * s)) * roblox.CFrame.Angles(0, math.pi, 0)
	cam.Parent = vp
	vp.CurrentCamera = cam
end
local defaults = {}
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
if not fs.isDir("tools/vfx/shots") then
	fs.writeDir("tools/vfx/shots")
end
fs.writeFile("tools/vfx/shots/monsters.json", serde.encode("json", { format = "gui-snapshot/1", state = "monsters", note = "Monsters", device = "sheet", screen = { W, H }, inset = 0, defaults = defaults, guis = { node(gui) } }, false))
print("wrote tools/vfx/shots/monsters.json")
