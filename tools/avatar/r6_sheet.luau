--[[
	CONTACT SHEET OF R6 LOOKS (BitLeveling; `-- weapons` draws every weapon instead, `-- presets`
	the outfit presets, face marks, headwear and back items): builds real R6 rigs with Hunter/R6Rig.luau on
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
	Instance = I, NumberRange = roblox.NumberRange, NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, ColorSequence = roblox.ColorSequence, Vector2 = roblox.Vector2, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
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
local process = require("@lune/process")
local Weapons = Loader.require(shared.Hunter.Weapons)
local weaponSheet = table.find(process.args, "weapons") ~= nil
local cells = {
	{ label = "Default", look = Looks.DEFAULT },
	{ label = "Tank (bulwark, ★★★)", look = { skin = "tan", top = "tactical", topColor = "olive", trim = "gold", bottom = "armored", bottomColor = "charcoal", armor = "heavy", armorColor = "slate", hair = 0, hairDye = "jet", shoes = "boots", build = "broad" }, weapon = { base = "bulwark", stars = 3 } },
	{ label = "Mage (sage staff)", look = { skin = "fair", top = "robe", topColor = "shadow", trim = "violet", bottom = "slacks", bottomColor = "black", armor = "cloak", armorColor = "shadow", hair = 376526888, hairDye = "silver", shoes = "dress", extra = "none" }, weapon = { base = "sage_staff", stars = 3 } },
	{ label = "Assassin (Shiny dirks)", look = { skin = "light", top = "hoodie", topColor = "black", trim = "crimson", bottom = "joggers", bottomColor = "black", armor = "harness", armorColor = "brown", hair = 376524487, hairDye = "jet", extra = "mask", shoes = "sneakers", build = "slim" }, weapon = { base = "shadowglass", stars = 2, shiny = true } },
	{ label = "Fighter (ogre greatsword)", look = { skin = "warm", top = "leather", topColor = "brown", trim = "mana", bottom = "cargo", bottomColor = "charcoal", armor = "pauldrons", armorColor = "silver", hair = 7193442167, hairDye = "auburn", shoes = "boots" }, weapon = { base = "ogre_greatsword", stars = 2 } },
	{ label = "Ranger (wyvern longbow)", look = { skin = "bronze", top = "jacket", topColor = "forest", trim = "khaki", bottom = "cargo", bottomColor = "olive", armor = "vest", armorColor = "olive", hair = 9244021842, hairDye = "dark_brown", extra = "headband", shoes = "boots" }, weapon = { base = "wyvern_longbow", stars = 3 } },
	{ label = "Healer (lantern)", look = { skin = "porcelain", top = "coat", topColor = "white", trim = "teal", bottom = "skirt", bottomColor = "navy", armor = "none", hair = 451221329, hairDye = "pink", extra = "earpiece", shoes = "dress", gloves = true }, weapon = { base = "mercy_lantern", stars = 2 } },
	{ label = "Civilian (uniform)", look = { skin = "olive", top = "uniform", topColor = "navy", trim = "red", bottom = "slacks", bottomColor = "charcoal", hair = 9243992729, hairDye = "jet", extra = "glasses", shoes = "dress" } },
}
for k = 1, 8 do
	table.insert(cells, { label = "Random " .. k, look = Looks.random(rand) })
end
local turn = -25
local presetSheet = table.find(process.args, "presets") ~= nil
if presetSheet then
	-- every outfit preset, then the face marks and headwear on a plain look
	cells = {}
	for _, p in Looks.PRESETS do
		table.insert(cells, { label = p.name, look = Looks.applyPreset(Looks.DEFAULT, p.id), rank = 4 })
	end
	for _, h in Looks.HEADWEAR do
		if h.id ~= "none" then
			table.insert(cells, { label = "Head: " .. h.name, look = { skin = "warm", hair = 0, hairDye = "chestnut", top = "guild", topColor = "navy", trim = "gold", armorColor = "slate", headwear = h.id }, face = true })
		end
	end
	for _, b in Looks.BACK do
		if b.id ~= "none" then
			table.insert(cells, { label = "Back: " .. b.name, look = { skin = "honey", hair = 0, hairDye = "jet", top = "tactical", topColor = "black", trim = "mana", backColor = "crimson", back = b.id }, back = true })
		end
	end
end
if weaponSheet then
	cells = {}
	for i, w in Weapons.list do
		local stars = (i % 3) + 1
		table.insert(cells, { label = Weapons.STARS[stars].label .. " " .. w.name, look = { skin = "light", top = "tactical", topColor = "charcoal", trim = "mana", bottom = "cargo", bottomColor = "black", hair = 9243992729, hairDye = "jet", shoes = "boots" }, weapon = { base = w.id, stars = stars, shiny = i % 9 == 0 } })
	end
	turn = -62
end

local cols, cellW, cellH, gap, labelH, titleH = 8, 150, 230, 6, 14, 30
if weaponSheet then
	cols, cellW, cellH = 10, 150, 190
elseif presetSheet then
	cols, cellW, cellH = 10, 150, 200
end
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
label(back, if presetSheet then "BITLEVELING · OUTFIT PRESETS, SCARS AND MARKS, HEADWEAR, BACK ITEMS" elseif weaponSheet then "BITLEVELING · EVERY WEAPON (★ to ★★★, every ninth one Shiny)" else "BITLEVELING · R6 LOOKS (block hair stands in for the hair accessories)", gap, 6, W - 2 * gap, 16, roblox.Color3.fromRGB(170, 150, 255))
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
	local model = R6Rig.build(cell.look, { name = cell.label, weapon = cell.weapon, rank = cell.rank })
	model.Parent = vp
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			total += 1
		end
	end
	local cam = I.new("Camera")
	cam.FieldOfView = 30
	local target = if cell.face then roblox.Vector3.new(0, 4.4, 0) else roblox.Vector3.new(0, 3, 0)
	local dist = if cell.face then 6 else 15
	-- (the sheet renderer draws cameras looking along a world axis reliably; turn the rig instead)
	cam.CFrame = roblox.CFrame.new(target + roblox.Vector3.new(0, 0.6, -dist)) * roblox.CFrame.Angles(0, math.pi, 0)
	local spin = if cell.back then 160 elseif cell.face then -20 else turn
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = roblox.CFrame.Angles(0, math.rad(spin), 0) * d.CFrame
		end
	end
	cam.Parent = vp
	vp.CurrentCamera = cam
end
-- (presets sheet) the faces, flat: the sheet renderer doesn't draw SurfaceGuis on parts, so the
-- face plate's own gui (and its glow) is copied into frames along the bottom
if presetSheet then
	local faces = {}
	for _, m in Looks.MARKS do
		table.insert(faces, { label = m.name, look = { skin = "light", hairDye = "jet", trim = "crimson", marks = m.id, face = "calm" } })
	end
	for _, g in Looks.EYE_GLOW do
		if g.id ~= "none" then
			table.insert(faces, { label = "Glow: " .. g.name, look = { skin = "warm", hairDye = "jet", eyeGlow = g.id, face = "focused" } })
		end
	end
	local fw, fh = 120, 108
	local per = math.floor((W - gap) / (fw + gap))
	local top = H
	H += gap + math.ceil(#faces / per) * (fh + labelH + gap)
	for i, f in faces do
		local c, r = (i - 1) % per, (i - 1) // per
		local x, y = gap + c * (fw + gap), top + gap + r * (fh + labelH + gap)
		label(back, f.label, x, y, fw)
		local holder = I.new("Frame")
		holder.Position = roblox.UDim2.fromOffset(x, y + labelH)
		holder.Size = roblox.UDim2.fromOffset(fw, fh)
		local sk = Looks.color("SKIN", f.look.skin)
		holder.BackgroundColor3 = roblox.Color3.fromRGB(sk[1], sk[2], sk[3])
		holder.BorderSizePixel = 0
		holder.Parent = back
		local model = R6Rig.build(f.look, { name = "Face" })
		local plate = model:FindFirstChild("FacePlate")
		for _, guiName in { "Face", "Glow" } do
			local sg = plate and plate:FindFirstChild(guiName)
			if sg then
				for _, child in sg:GetChildren() do
					child.Parent = holder
				end
			end
		end
	end
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
local outName = if presetSheet then "tools/avatar/shots/presets.json" elseif weaponSheet then "tools/avatar/shots/weapons.json" else "tools/avatar/shots/r6.json"
fs.writeFile(outName, serde.encode("json", { format = "gui-snapshot/1", state = "r6", note = "R6 looks", device = "sheet", screen = { W, H }, inset = 0, defaults = defaults, guis = { node(gui) } }, false))
print(string.format("wrote " .. outName .. " (%d rigs, %.0f parts each, %dx%d)", #cells, total / #cells, W, H))
