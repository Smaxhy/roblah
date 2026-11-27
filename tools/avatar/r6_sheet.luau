--[[
	CONTACT SHEET OF R6 LOOKS (BitLeveling): builds real R6 rigs with Hunter/R6Rig.luau on
	@lune/roblox instances (real classes, real property names: anything wrong errors here) and
	writes a gui-snapshot/1 dump that tools/gui_render draws.
		lune run tools/avatar/r6_sheet.luau
		node tools/gui_render/shoot.js --dump tools/avatar/shots/r6.json --png tools/avatar/shots/r6.png --bg none --no-topbar
	(The face is a SurfaceGui and the hair accessories load in game; the sheet shows block hair.)
]]
local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local Loader = require("../../tests/loader")
local I = roblox.Instance
local suffix = ""

Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font,
}
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local Looks = Loader.require(shared.Hunter.Looks)
local R6Rig = Loader.require(shared.Hunter.R6Rig)

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


local seed = 7
local function rand(a, b)
	seed = (seed * 48271) % 2147483647
	return a + seed % (b - a + 1)
end
local cells = {
	{ label = "Default", look = Looks.DEFAULT },
	{ label = "Tank (plate, shield)", look = { skin = "tan", top = "tactical", topColor = "olive", trim = "gold", bottom = "armored", bottomColor = "charcoal", armor = "heavy", armorColor = "slate", weapon = "shield", hair = 0, hairDye = "jet", shoes = "boots", build = "broad" } },
	{ label = "Mage (robe, staff)", look = { skin = "fair", top = "robe", topColor = "shadow", trim = "violet", bottom = "slacks", bottomColor = "black", armor = "cloak", armorColor = "shadow", weapon = "staff", hair = 376526888, hairDye = "silver", shoes = "dress", extra = "none" } },
	{ label = "Assassin (daggers)", look = { skin = "light", top = "hoodie", topColor = "black", trim = "crimson", bottom = "joggers", bottomColor = "black", armor = "harness", armorColor = "brown", weapon = "dagger", hair = 376524487, hairDye = "jet", extra = "mask", shoes = "sneakers", build = "slim" } },
	{ label = "Fighter (greatsword)", look = { skin = "warm", top = "leather", topColor = "brown", trim = "mana", bottom = "cargo", bottomColor = "charcoal", armor = "pauldrons", armorColor = "silver", weapon = "greatsword", hair = 7193442167, hairDye = "auburn", shoes = "boots" } },
	{ label = "Ranger (bow)", look = { skin = "bronze", top = "jacket", topColor = "forest", trim = "khaki", bottom = "cargo", bottomColor = "olive", armor = "vest", armorColor = "olive", weapon = "bow", hair = 9244021842, hairDye = "dark_brown", extra = "headband", shoes = "boots" } },
	{ label = "Healer (coat)", look = { skin = "porcelain", top = "coat", topColor = "white", trim = "teal", bottom = "skirt", bottomColor = "navy", armor = "none", weapon = "none", hair = 451221329, hairDye = "pink", extra = "earpiece", shoes = "dress", gloves = true } },
	{ label = "Civilian (uniform)", look = { skin = "olive", top = "uniform", topColor = "navy", trim = "red", bottom = "slacks", bottomColor = "charcoal", hair = 9243992729, hairDye = "jet", extra = "glasses", shoes = "dress" } },
}
for k = 1, 8 do
	table.insert(cells, { label = "Random " .. k, look = Looks.random(rand) })
end

local cols, cellW, cellH, gap, labelH, titleH = 8, 150, 230, 6, 14, 30
local rows = math.ceil(#cells / cols)
local W = gap + cols * (cellW + gap)
local H = titleH + gap + rows * (cellH + labelH + gap)
local gui = I.new("ScreenGui")
gui.Name = "R6Sheet"
gui.IgnoreGuiInset = true
local back = I.new("Frame")
back.Size = roblox.UDim2.fromScale(1, 1)
back.BackgroundColor3 = roblox.Color3.fromRGB(8, 10, 16)
back.BorderSizePixel = 0
back.Parent = gui
label(back, "BITLEVELING · R6 LOOKS (block hair stands in for the hair accessories)", gap, 6, W - 2 * gap, 16, roblox.Color3.fromRGB(170, 150, 255))
local total = 0
for i, cell in cells do
	local c, r = (i - 1) % cols, (i - 1) // cols
	local x, y = gap + c * (cellW + gap), titleH + gap + r * (cellH + labelH + gap)
	label(back, cell.label, x, y, cellW)
	local vp = I.new("ViewportFrame")
	vp.Position = roblox.UDim2.fromOffset(x, y + labelH)
	vp.Size = roblox.UDim2.fromOffset(cellW, cellH)
	vp.BackgroundColor3 = roblox.Color3.fromRGB(20, 26, 40)
	vp.Ambient = roblox.Color3.fromRGB(150, 150, 165)
	vp.LightColor = roblox.Color3.fromRGB(255, 244, 230)
	vp.Parent = back
	local model = R6Rig.build(cell.look, { name = cell.label })
	model.Parent = vp
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			total += 1
		end
	end
	local cam = I.new("Camera")
	cam.FieldOfView = 30
	local target = roblox.Vector3.new(0, 3, 0)
	-- (the sheet renderer draws cameras looking along a world axis reliably; turn the rig instead)
	cam.CFrame = roblox.CFrame.new(target + roblox.Vector3.new(0, 0.6, -15)) * roblox.CFrame.Angles(0, math.pi, 0)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = roblox.CFrame.Angles(0, math.rad(-25), 0) * d.CFrame
		end
	end
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
if not fs.isDir("tools/avatar/shots") then
	fs.writeDir("tools/avatar/shots")
end
fs.writeFile("tools/avatar/shots/r6.json", serde.encode("json", { format = "gui-snapshot/1", state = "r6", note = "R6 looks", device = "sheet", screen = { W, H }, inset = 0, defaults = defaults, guis = { node(gui) } }, false))
print(string.format("wrote tools/avatar/shots/r6.json (%d rigs, %.0f parts each, %dx%d)", #cells, total / #cells, W, H))
