--[[
	CONTACT SHEET OF R6 LOOKS (BitLeveling; `-- weapons` draws every weapon instead, `-- presets`
	the outfit presets, headwear, back items and face marks, `-- outfits` every top, bottom,
	armour, shoe, glove and accessory, `-- zoom id,id` those presets big, front and back):
	builds real R6 rigs with Hunter/R6Rig.luau on
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
local process = require("@lune/process")
local weaponSheet = table.find(process.args, "weapons") ~= nil
local function viewportOf(vp)
	local parts = {}
	local function emit(d, size, cf, shape)
		table.insert(parts, {
			class = d.ClassName,
			shape = shape,
			size = ENCODE.Vector3(size),
			cframe = ENCODE.CFrame(cf),
			color = ENCODE.Color3(d.Color),
			material = d.Material.Name,
			transparency = num(d.Transparency),
		})
	end
	for _, d in vp:GetDescendants() do
		if d:IsA("BasePart") then
			local size, cf = d.Size, d.CFrame
			local shape = if d:IsA("Part") then d.Shape.Name else "Block"
			-- (weapons sheet) the renderer draws boxes, balls and cylinders: a SpecialMesh scales
			-- its part (a mesh-kit socket is scaled to nothing: its cover parts draw it), and a
			-- WedgePart is drawn as a stair of slices along its slope
			local mesh = if weaponSheet then d:FindFirstChildOfClass("SpecialMesh") else nil
			if mesh then
				local sc = mesh.Scale
				if sc.X * sc.Y * sc.Z < 1e-3 then
					continue
				end
				size = size * sc
				cf = cf * roblox.CFrame.new(mesh.Offset)
			end
			if weaponSheet and d:IsA("WedgePart") then
				local n = math.clamp(math.ceil(size.Z / 0.08), 3, 10)
				for k = 1, n do
					local zc = -size.Z / 2 + (k - 0.5) * size.Z / n
					local h = size.Y * (zc + size.Z / 2) / size.Z
					emit(d, roblox.Vector3.new(size.X, h, size.Z / n), cf * roblox.CFrame.new(0, -size.Y / 2 + h / 2, zc), "Block")
				end
			else
				emit(d, size, cf, shape)
			end
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
local Weapons = Loader.require(shared.Hunter.Weapons)
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
-- the presets family: `-- presets` (every outfit preset by shelf, then headwear, back items and
-- the flat faces), `-- outfits` (every top, bottom, shoe, glove, armour, accessory on one look),
-- `-- zoom id,id,...` (those presets big, front and back). These are drawn by `flow` below.
local outfitSheet = table.find(process.args, "outfits") ~= nil
local zoomAt = table.find(process.args, "zoom")
local presetSheet = table.find(process.args, "presets") ~= nil or outfitSheet or zoomAt ~= nil
local sheetMode = if zoomAt then "zoom" elseif outfitSheet then "outfits" else "presets"
local flowCells = {}
if presetSheet then
	cells = {}
	local function section(title: string)
		table.insert(flowCells, { header = title })
	end
	local function add(c)
		table.insert(flowCells, c)
	end
	local PLAIN = { skin = "warm", hair = 0, hairDye = "chestnut", top = "longsleeve", topColor = "charcoal", trim = "gold", bottom = "slacks", bottomColor = "black", shoes = "boots", armorColor = "slate", backColor = "crimson" }
	local function on(field: string, id: any, extra: any?)
		local l = table.clone(PLAIN)
		l[field] = id
		for k, v in extra or {} do
			l[k] = v
		end
		return l
	end
	if sheetMode == "presets" then
		section(string.format("OUTFIT PRESETS (%d): EVERY CLASS FROM E-RANK TO S-RANK, THE ASSOCIATION, GUILDS, CIVILIANS, ORIGINAL ICONS", #Looks.PRESETS))
		for _, cat in Looks.CATEGORIES do
			local cls = Looks.find("CLASSES", cat.id)
			local tint = if cls then roblox.Color3.fromRGB(cls.color[1], cls.color[2], cls.color[3]) else roblox.Color3.fromRGB(200, 190, 230)
			for _, p in Looks.presetsIn(cat.id) do
				add({ label = string.upper(cat.name) .. (if p.rank then " " .. p.rank else "") .. " · " .. p.name, tint = tint, look = Looks.applyPreset(Looks.DEFAULT, p.id), rank = 4, w = 170, h = 236 })
			end
		end
		section("HEADWEAR")
		for _, h in Looks.HEADWEAR do
			if h.id ~= "none" then
				add({ label = h.name, look = { skin = "warm", hair = 0, hairDye = "chestnut", top = "guild", topColor = "navy", trim = "gold", armorColor = "slate", headwear = h.id }, face = true, w = 116, h = 116 })
			end
		end
		section("ON THE BACK")
		for _, b in Looks.BACK do
			if b.id ~= "none" then
				add({ label = b.name, look = { skin = "honey", hair = 0, hairDye = "jet", top = "tactical", topColor = "black", trim = "mana", backColor = "crimson", back = b.id }, back = true, w = 116, h = 170 })
			end
		end
	elseif sheetMode == "outfits" then
		local colors = { "navy", "crimson", "forest", "shadow", "white", "brown", "slate", "wine" }
		section("TOPS")
		for i, t in Looks.TOPS do
			add({ label = t.name, look = on("top", t.id, { topColor = colors[(i - 1) % #colors + 1] }), w = 128, h = 200 })
		end
		section("BOTTOMS")
		for i, b in Looks.BOTTOMS do
			add({ label = b.name, look = on("bottom", b.id, { bottomColor = colors[(i - 1) % #colors + 1], top = "tee", topColor = "white" }), w = 128, h = 200 })
		end
		section("ARMOR")
		for _, a in Looks.ARMOR do
			add({ label = a.name, look = on("armor", a.id, { armorColor = "silver" }), w = 128, h = 200 })
		end
		section("SHOES AND GLOVES")
		for _, sh in Looks.SHOES do
			add({ label = sh.name, look = on("shoes", sh.id), legs = true, w = 100, h = 110 })
		end
		for _, g in Looks.GLOVES do
			add({ label = g.name, look = on("gloves", g.id, { top = "tee" }), w = 100, h = 150 })
		end
		section("FACE AND NECK")
		for _, e in Looks.EXTRAS do
			add({ label = e.name, look = on("extra", e.id, { top = "tee", topColor = "white" }), face = true, w = 100, h = 100 })
		end
		local okAcc, Accessories = pcall(function()
			return Loader.require(shared.Hunter.Accessories)
		end)
		if okAcc and Accessories and Accessories.list then
			section("ACCESSORIES (class, grade)")
			for _, a in Accessories.list do
				add({ label = a.grade .. " " .. a.name, look = on("top", "tee", { accessories = { a.id }, topColor = "slate" }), w = 100, h = 150, near = true })
			end
		end
	else
		local ids = string.split(process.args[zoomAt + 1] or "", ",")
		for _, id in ids do
			local p = Looks.find("PRESETS", id)
			if p then
				local look = Looks.applyPreset(Looks.DEFAULT, p.id)
				add({ label = p.name .. " (front)", look = look, rank = 4, w = 320, h = 460, near = true })
				add({ label = p.name .. " (back)", look = look, rank = 4, w = 320, h = 460, near = true, back = true })
			end
		end
	end
end
-- (weapons sheet) every weapon, by class and family, its stars cycling ★..★★★, every ninth Shiny.
-- Options after "weapons": fam=<family>[,<family>...] (only those), stars=<1..3> (all at that),
-- shiny (all Shiny), big (larger cells, a closer camera), fx (client/WeaponFx instead: one swing
-- per family and one hit per element, frozen at their first frame; particles and lights aren't drawn)
local weaponOpts = { fams = nil :: { [string]: boolean }?, stars = nil :: number?, shiny = false, big = false, fx = false }
for _, a in process.args do
	local fams = string.match(a, "^fam=(.+)$")
	if fams then
		weaponOpts.fams = {}
		for f in string.gmatch(fams, "[^,]+") do
			(weaponOpts.fams :: any)[f] = true
		end
	end
	local st = string.match(a, "^stars=(%d)$")
	if st then
		weaponOpts.stars = tonumber(st)
	end
	if a == "shiny" then
		weaponOpts.shiny = true
	elseif a == "big" then
		weaponOpts.big = true
	elseif a == "fx" then
		weaponOpts.fx = true
	end
end
local WeaponFx: any = nil
if weaponSheet and weaponOpts.fx then
	-- the client module, offline: tweens don't play and nothing is cleaned up, so each effect
	-- is drawn at its first frame
	local noop = function() end
	local scratch = I.new("Folder")
	Loader.globals.TweenInfo = { new = function(...)
		return { ... }
	end }
	Loader.globals.task = { delay = noop, spawn = noop, defer = noop, wait = function()
		return 0
	end }
	Loader.globals.game = { GetService = function(_, name)
		if name == "TweenService" then
			return { Create = function()
				return { Play = noop, Cancel = noop }
			end }
		elseif name == "Debris" then
			return { AddItem = noop }
		elseif name == "Workspace" then
			return scratch
		elseif name == "ReplicatedStorage" then
			return { WaitForChild = function()
				return shared
			end }
		end
		return {}
	end }
	local client = Loader.preload(Loader.node("src/client", "Client", nil))
	WeaponFx = Loader.require(client.WeaponFx)
end
if weaponSheet then
	cells = {}
	local ordered = {}
	for fi, f in Weapons.FAMILY_ORDER do
		for _, w in Weapons.list do
			if w.family == f and (weaponOpts.fams == nil or (weaponOpts.fams :: any)[f]) then
				table.insert(ordered, { w = w, key = fi * 100 + w.grade })
			end
		end
	end
	table.sort(ordered, function(a, b)
		return a.key < b.key
	end)
	for i, o in ordered do
		local w = o.w
		local stars = weaponOpts.stars or ((i % 3) + 1)
		local shiny = weaponOpts.shiny or i % 9 == 0
		table.insert(cells, { label = (if shiny then "S " else "") .. Weapons.STARS[stars].label .. " " .. w.name, look = { skin = "light", top = "tactical", topColor = "charcoal", trim = "mana", bottom = "cargo", bottomColor = "black", hair = 9243992729, hairDye = "jet", shoes = "boots" }, weapon = { base = w.id, stars = stars, shiny = shiny } })
	end
	if weaponOpts.fx then
		-- one swing per family (its first weapon, ★★★), then one hit per element
		local look = { skin = "light", top = "tactical", topColor = "charcoal", trim = "mana", bottom = "cargo", bottomColor = "black", hair = 9243992729, hairDye = "jet", shoes = "boots" }
		cells = {}
		local seen = {}
		for _, o in ordered do
			if not seen[o.w.family] then
				seen[o.w.family] = true
				local fam = Weapons.FAMILIES[o.w.family]
				table.insert(cells, { label = fam.fx .. " · " .. fam.name .. " (" .. o.w.element .. ")", look = look, weapon = { base = o.w.id, stars = weaponOpts.stars or 3, shiny = weaponOpts.shiny }, fx = "swing" })
			end
		end
		for _, e in Weapons.ELEMENT_LIST do
			local base = "shortsword"
			for _, w in Weapons.list do
				if w.element == e then
					base = w.id
					break
				end
			end
			table.insert(cells, { label = "hit · " .. e, look = look, weapon = { base = base, stars = 1 }, fx = "hit", element = e })
		end
	end
	turn = -62
end

local cols, cellW, cellH, gap, labelH, titleH = 8, 150, 230, 6, 14, 30
if weaponSheet then
	cols, cellW, cellH = 12, 150, 196
	if weaponOpts.big then
		cols, cellW, cellH = 6, 260, 300
	end
elseif presetSheet then
	cols, cellW, cellH = 9, 170, 240
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
label(back, if presetSheet then (if sheetMode == "outfits" then "BITLEVELING · EVERY TOP, BOTTOM, ARMOUR, SHOE, GLOVE, ACCESSORY" elseif sheetMode == "zoom" then "BITLEVELING · PRESETS, CLOSE UP" else "BITLEVELING · OUTFIT PRESETS BY CLASS, HEADWEAR, BACK ITEMS, SCARS AND MARKS") elseif weaponSheet then string.format("BITLEVELING · EVERY WEAPON: %d in %d families, by class (★ to ★★★; S = Shiny)", #cells, #Weapons.FAMILY_ORDER) else "BITLEVELING · R6 LOOKS (block hair stands in for the hair accessories)", gap, 6, W - 2 * gap, 16, roblox.Color3.fromRGB(170, 150, 255))
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
	if weaponSheet then
		-- the weapon's side: the right one, or the left for a shield or a bow
		local fam = Weapons.byId[cell.weapon.base].family
		local leftHanded = fam == "shield" or fam == "buckler" or fam == "towershield" or fam == "bow" or fam == "longbow"
		spin = if leftHanded then -64 else 66
	end
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = roblox.CFrame.Angles(0, math.rad(spin), 0) * d.CFrame
		end
	end
	if cell.fx and WeaponFx then
		-- the effect, drawn into the rig's model (so it's framed with it): long-range ones are
		-- shortened to fit the cell
		local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
		local rcf = root.CFrame
		if cell.fx == "swing" then
			local style = WeaponFx.styleOf(model)
			local far = style == "shot" or style == "throw" or style == "spell"
			WeaponFx.swing(model, { parent = model, reach = if far then 8 elseif style == "lash" or style == "gust" then 7 else nil, target = if far then rcf.Position + rcf.LookVector * 8 else nil, power = 12 })
		else
			WeaponFx.hit(rcf.Position + rcf.LookVector * 3.5, cell.element, 12, { parent = model })
		end
	end
	if weaponSheet then
		-- frame the rig and its weapon: the camera looks along +Z at the middle of their box
		local lo, hi = roblox.Vector3.new(math.huge, math.huge, math.huge), roblox.Vector3.new(-math.huge, -math.huge, -math.huge)
		for _, d in model:GetDescendants() do
			if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and d.Transparency < 0.95 then
				local mesh = d:FindFirstChildOfClass("SpecialMesh")
				if not (mesh and mesh.Scale.X < 0.01) then
					local h = d.Size / 2
					for _, sx in { -1, 1 } do
						for _, sy in { -1, 1 } do
							for _, sz in { -1, 1 } do
								local pt = d.CFrame * roblox.Vector3.new(h.X * sx, h.Y * sy, h.Z * sz)
								lo = lo:Min(pt)
								hi = hi:Max(pt)
							end
						end
					end
				end
			end
		end
		local mid = (lo + hi) / 2
		local half = (hi - lo) / 2
		local tanV = math.tan(math.rad(cam.FieldOfView / 2))
		local fit = math.max(math.max(half.Y, 3.4) * 1.1 / tanV, half.X * 1.1 / (tanV * cellW / cellH))
		cam.CFrame = roblox.CFrame.new(mid.X, mid.Y, lo.Z - fit + half.Z * 0.2) * roblox.CFrame.Angles(0, math.pi, 0)
	end
	cam.Parent = vp
	vp.CurrentCamera = cam
end
-- (the presets family) cells of their own sizes, flowing in rows, with section headers
if presetSheet then
	local x, y, rowH = gap, H, 0
	local maxParts = 0
	for _, cell in flowCells do
		if cell.header then
			if x > gap then
				y += rowH + labelH + gap
			end
			label(back, cell.header, gap, y + 2, W - 2 * gap, 13, roblox.Color3.fromRGB(230, 200, 120))
			y += 20
			x, rowH = gap, 0
			continue
		end
		if x + cell.w > W - gap + 1 then
			x = gap
			y += rowH + labelH + gap
			rowH = 0
		end
		label(back, cell.label, x, y, cell.w, 10, cell.tint)
		local vp = I.new("ViewportFrame")
		vp.Position = roblox.UDim2.fromOffset(x, y + labelH)
		vp.Size = roblox.UDim2.fromOffset(cell.w, cell.h)
		vp.BackgroundColor3 = roblox.Color3.fromRGB(20, 26, 40)
		vp.Ambient = roblox.Color3.fromRGB(150, 150, 165)
		vp.LightColor = roblox.Color3.fromRGB(255, 244, 230)
		vp.Parent = back
		local model = R6Rig.build(cell.look, { name = cell.label, weapon = cell.weapon, rank = cell.rank })
		model.Parent = vp
		local n = 0
		for _, d in model:GetDescendants() do
			if d:IsA("BasePart") then
				n += 1
			end
		end
		total += n
		maxParts = math.max(maxParts, n)
		local cam = I.new("Camera")
		cam.FieldOfView = 30
		local target = if cell.face then roblox.Vector3.new(0, 4.5, 0) elseif cell.legs then roblox.Vector3.new(0, 0.9, 0) else roblox.Vector3.new(0, 2.75, 0)
		local dist = if cell.face then 5.6 elseif cell.legs then 6.5 elseif cell.near then 17 elseif cell.back then 15 else 15.5
		cam.CFrame = roblox.CFrame.new(target + roblox.Vector3.new(0, 0.6, -dist)) * roblox.CFrame.Angles(0, math.pi, 0)
		local spin = if cell.back then 160 elseif cell.face then -20 else turn
		for _, d in model:GetDescendants() do
			if d:IsA("BasePart") then
				d.CFrame = roblox.CFrame.Angles(0, math.rad(spin), 0) * d.CFrame
			end
		end
		cam.Parent = vp
		vp.CurrentCamera = cam
		x += cell.w + gap
		rowH = math.max(rowH, cell.h)
		table.insert(cells, cell)
	end
	H = y + rowH + labelH + gap
	print(string.format("most parts on one rig: %d", maxParts))
end
-- (presets sheet) the faces, flat: the sheet renderer doesn't draw SurfaceGuis on parts, so the
-- face plate's own gui (and its glow) is copied into frames along the bottom
if presetSheet and sheetMode == "presets" then
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
local outName = if presetSheet then "tools/avatar/shots/" .. sheetMode .. ".json" elseif weaponSheet then "tools/avatar/shots/weapons.json" else "tools/avatar/shots/r6.json"
fs.writeFile(outName, serde.encode("json", { format = "gui-snapshot/1", state = "r6", note = "R6 looks", device = "sheet", screen = { W, H }, inset = 0, defaults = defaults, guis = { node(gui) } }, false))
print(string.format("wrote " .. outName .. " (%d rigs, %.0f parts each, %dx%d)", #cells, total / #cells, W, H))
