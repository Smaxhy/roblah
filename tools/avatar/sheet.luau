--[[
	Contact sheets of the figures Engine/Avatar builds, drawn by the real UI/AvatarView (on
	@lune/roblox instances) and written as gui-snapshot/1 dumps for tools/gui_render:

		lune run tools/avatar/sheet.luau [sheet ...]        (no names: every sheet)
		node tools/gui_render/shoot.js --dump tools/avatar/shots/<sheet>.json \
			--png tools/avatar/shots/<sheet>.png --bg none --no-topbar

	tools/avatar/shoot.sh does both for every sheet. LIFESIM_PACK=Undermere picks the other pack
	(its sheets are written as <sheet>_undermere).

	Sheets: weapons, hair, hairbig, outfits, poses, ages, identities, npcs, extras, mesh.
]]

local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local Loader = require("../../tests/loader")

local I = roblox.Instance

-- ── the modules: src/shared as ReplicatedStorage.LifeSim, src/client for UI/AvatarView ──
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local noop = function() end
local taskStub = { spawn = noop, defer = noop, delay = noop, wait = function()
	return 0
end, cancel = noop }
Loader.globals = {
	game = {
		GetService = function(_, name)
			if name == "ReplicatedStorage" then
				return {
					WaitForChild = function(_, child)
						assert(child == "LifeSim", child)
						return shared
					end,
					FindFirstChild = function(_, child)
						return if child == "LifeSim" then shared else nil
					end,
				}
			elseif name == "TweenService" then
				return { Create = function()
					return { Play = noop, Cancel = noop }
				end }
			elseif name == "RunService" then
				local signal = { Connect = function()
					return { Disconnect = noop, Connected = false }
				end }
				return { Heartbeat = signal, RenderStepped = signal, IsStudio = function()
					return false
				end }
			end
			error("no service " .. tostring(name))
		end,
	},
	Instance = I,
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
	Enum = roblox.Enum,
	Font = roblox.Font,
	TweenInfo = { new = function(...)
		return { ... }
	end },
	task = taskStub,
}
local Engine = Loader.require(shared.Engine)
local pack = Loader.pack(shared)
local Avatar = Engine.Avatar
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local AvatarView = Loader.require(client.UI.AvatarView)
local okCreature, CreatureView = pcall(Loader.require, client.UI.CreatureView)
if not okCreature then
	print("CreatureView didn't load: " .. tostring(CreatureView))
	CreatureView = nil
end

-- what the server sends on hello (src/server/init.luau)
local avatarInfo = { cosmetics = pack.cosmetics, gear = {}, conditions = {}, forms = {} }
for id, g in pack.gear or {} do
	if type(g) == "table" and g.look then
		avatarInfo.gear[id] = { look = g.look, slot = g.slot }
	end
end
for id, c in pack.conditions or {} do
	if c.look then
		avatarInfo.conditions[id] = { look = c.look }
	end
end
for id, f in pack.forms or {} do
	if type(f) == "table" and f.look then
		avatarInfo.forms[id] = { look = f.look }
	end
end
local ctx = { info = { avatar = avatarInfo }, state = {} }

local cosmetics = pack.cosmetics
local function options(category: string)
	return (cosmetics[category] and cosmetics[category].options) or {}
end
local function hashRoll(key: string)
	local h = 5381
	for i = 1, #key do
		h = (h * 33 + string.byte(key, i)) % 2147483647
	end
	if h == 0 then
		h = 1
	end
	return function(n: number): number
		h = (h * 48271) % 2147483647
		return (h % n) + 1
	end
end

-- the plain look every sheet starts from: the first free pick of each category
local base = Avatar.defaultLook(pack)
local function with(changes, from)
	local look = table.clone(from or base)
	for k, v in changes or {} do
		look[k] = v
	end
	return look
end
local function has(category: string, id: string): boolean
	return Avatar.option(pack, category, id) ~= nil
end
local function first(category: string, ids: { string }): string?
	for _, id in ids do
		if has(category, id) then
			return id
		end
	end
	return base[category]
end

-- ── sheets: { title, cellW, cellH, cols, cells = { { label, ap, framing, angle, w, h } } } ──
local SHEETS = {}
local ORDER = {}
local function sheet(name: string, fn)
	SHEETS[name] = fn
	table.insert(ORDER, name)
end

local plainOutfit = first("outfit", { "streetwear", "slate" })

sheet("creatures", function()
	local cells = {}
	for _, foe in pack.foes or {} do
		if foe.kind == "creature" then
			table.insert(cells, { label = foe.id .. " (" .. tostring(foe.shape) .. ")", creature = foe, framing = "full" })
			table.insert(cells, { label = "portrait", creature = foe, framing = "portrait" })
			local strike = table.clone(foe)
			strike.pose = "strike"
			table.insert(cells, { label = "strike", creature = strike, framing = "full" })
			local down = table.clone(foe)
			down.pose = "down"
			table.insert(cells, { label = "down", creature = down, framing = "full" })
		end
	end
	return { title = "Creatures: whole, portrait, strike, down", cols = 8, cellW = 210, cellH = 210, cells = cells }
end)

sheet("weapons", function()
	local cells = {}
	local seen = {}
	local list = {}
	for _, o in options("weapon") do
		if o.kind and not seen[o.kind .. tostring(o.color and o.color[1])] then
			seen[o.kind .. tostring(o.color and o.color[1])] = true
			table.insert(list, { label = o.id .. " (" .. o.kind .. ")", look = with({ weapon = o.id, outfit = plainOutfit }) })
		end
	end
	-- gear kinds that aren't signature weapons (book, lamp, bell ...)
	local gearSeen = {}
	for _, id in (pack.gear and pack.gear.order) or {} do
		local g = pack.gear[id]
		if g and g.look and g.slot == "tool" and not gearSeen[g.look.kind] then
			gearSeen[g.look.kind] = true
			table.insert(list, { label = "gear " .. id .. " (" .. g.look.kind .. ")", look = with({ outfit = plainOutfit, weapon = "none" }), gear = { tool = id } })
		end
	end
	table.insert(list, 1, { label = "empty hands", look = with({ outfit = plainOutfit, weapon = "none" }) })
	for _, item in list do
		for _, angle in { 0, -35, -90, 150 } do
			table.insert(cells, { label = item.label .. "  " .. angle .. "°", ap = { look = item.look, age = 30, form = "human", gear = item.gear }, framing = "full", angle = angle })
		end
		table.insert(cells, { label = "portrait", ap = { look = item.look, age = 30, form = "human", gear = item.gear }, framing = "portrait", angle = -18 })
	end
	return { title = "Weapons: front, three-quarter, side, back, portrait", cellW = 170, cellH = 210, cols = 10, cells = cells }
end)

local function hairCells(size: number, angles)
	local cells = {}
	local colors = { first("hairColor", { "chestnut" }), first("hairColor", { "ink" }), first("hairColor", { "straw" }), first("hairColor", { "rust" }) }
	for i, o in options("hair") do
		local look = with({ hair = o.id, hairColor = colors[(i - 1) % #colors + 1], outfit = plainOutfit })
		for _, angle in angles do
			table.insert(cells, { label = if angle == angles[1] then o.id else tostring(angle) .. "°", ap = { look = look, age = 26, form = "human", sanity = 5 }, framing = "portrait", angle = angle, w = size, h = math.floor(size * 64 / 60) })
		end
	end
	return cells
end
sheet("hair", function()
	-- the sizes the game really shows faces at (Hud 60x64, lists 48x52)
	return { title = "Hair at portrait size (60x64, as in the HUD): -18° and 40°", cellW = 64, cellH = 68, cols = 20, cells = hairCells(60, { -18, 40 }) }
end)
sheet("hairbig", function()
	return { title = "Hair, large: front, three-quarter, side, back", cellW = 150, cellH = 160, cols = 12, cells = hairCells(146, { 0, -35, -90, 180 }) }
end)

sheet("outfits", function()
	local cells = {}
	local hairs = { first("hair", { "crop" }), first("hair", { "bob" }), first("hair", { "long" }), first("hair", { "bun" }) }
	for i, o in options("outfit") do
		local look = with({ outfit = o.id, hair = hairs[(i - 1) % #hairs + 1] })
		local free = not o.record and not o.store and not o.daily and not (o.glow and o.glow > 0)
		table.insert(cells, { label = o.id .. (if free then "" else " *"), ap = { look = look, age = 28, form = "human" }, framing = "full", angle = -24 })
		table.insert(cells, { label = "back", ap = { look = look, age = 28, form = "human" }, framing = "full", angle = 155 })
		table.insert(cells, { label = "portrait", ap = { look = look, age = 28, form = "human" }, framing = "portrait", angle = -18, w = 96, h = 104 })
	end
	return { title = "Outfits (* = locked): three-quarter, back, portrait", cellW = 130, cellH = 190, cols = 12, cells = cells }
end)

sheet("poses", function()
	local cells = {}
	local weapons = { "none" }
	for _, id in { "blade", "knife", "revolver", "spear", "sledge", "greatsword", "katana", "axe", "knuckles", "censer", "pipe" } do
		if has("weapon", id) then
			table.insert(weapons, id)
		end
	end
	for _, w in weapons do
		for _, pose in { "idle", "guard", "strike", "hurt", "down" } do
			local look = with({ weapon = w, outfit = first("outfit", { "fixer_coat", "night_coat", "slate" }) })
			for _, angle in { -18, -60, 60 } do
				table.insert(cells, { label = w .. " " .. pose .. " " .. angle .. "°", ap = { look = look, age = 30, form = "human", pose = pose }, framing = "full", angle = angle })
			end
		end
	end
	return { title = "Poses (idle, guard, strike, hurt, down) at -18°, -60°, 60°", cellW = 150, cellH = 180, cols = 15, cells = cells }
end)

sheet("ages", function()
	local cells = {}
	local looks = {}
	for i, ident in cosmetics.identities or {} do
		if i <= 5 then
			table.insert(looks, with(ident.look))
		end
	end
	for i = 1, 3 do
		table.insert(looks, Avatar.randomLook(pack, hashRoll("ages" .. i)))
	end
	for _, look in looks do
		for _, age in { 1, 3, 6, 10, 14, 17, 30, 52, 66, 80 } do
			table.insert(cells, { label = "age " .. age, ap = { look = look, age = age, form = "human" }, framing = "full", angle = -24 })
			table.insert(cells, { label = "", ap = { look = look, age = age, form = "human" }, framing = "portrait", angle = -18, w = 60, h = 64 })
		end
	end
	return { title = "Ages 1 to 80: full figure and portrait", cellW = 110, cellH = 170, cols = 20, cells = cells }
end)

sheet("identities", function()
	local cells = {}
	for _, ident in cosmetics.identities or {} do
		local look = with(ident.look)
		table.insert(cells, { label = ident.id, ap = { look = look, age = 24, form = "human", sanity = 10 }, framing = "full", angle = -24 })
		table.insert(cells, { label = "", ap = { look = look, age = 24, form = "human", sanity = 10 }, framing = "portrait", angle = -18, w = 96, h = 98 })
		table.insert(cells, { label = "", ap = { look = look, age = 24, form = "human", sanity = 10 }, framing = "portrait", angle = -18, w = 48, h = 52 })
	end
	return { title = "Identities (premade looks): full, creator card (96x98), list face (48x52)", cellW = 130, cellH = 190, cols = 12, cells = cells }
end)

sheet("npcs", function()
	local cells = {}
	-- families: you, then mother, father and two siblings rolled from your look
	for f = 1, 4 do
		local you = Avatar.randomLook(pack, hashRoll("you" .. f))
		table.insert(cells, { label = "you " .. f, ap = { look = you, age = 20, form = "human" }, framing = "full", angle = -24 })
		for k, who in { { "mother", 44 }, { "father", 47 }, { "sibling", 12 }, { "sibling", 5 }, { "child", 2 }, { "grandparent", 74 } } do
			local look = Avatar.randomLook(pack, hashRoll("fam" .. f .. ":" .. k), you, { kind = who[1], age = who[2] })
			table.insert(cells, { label = who[1] .. " " .. who[2], ap = { look = look, age = who[2], form = "human" }, framing = "full", angle = -24 })
		end
	end
	for i = 1, 44 do
		local look = Avatar.randomLook(pack, hashRoll("stranger " .. i))
		table.insert(cells, { label = "stranger " .. i, ap = { look = look, age = 18 + (i * 7) % 50, form = "human" }, framing = if i % 2 == 0 then "portrait" else "full", angle = -20 })
	end
	return { title = "NPCs: four families (you, mother, father, siblings, child, grandparent), then strangers", cellW = 120, cellH = 170, cols = 12, cells = cells }
end)

sheet("extras", function()
	local cells = {}
	for _, category in { "beard", "accessory", "mark", "eyes", "build" } do
		for _, o in options(category) do
			local look = with({ [category] = o.id, outfit = plainOutfit, hair = first("hair", { "crop" }) })
			table.insert(cells, { label = category .. " " .. o.id, ap = { look = look, age = 34, form = "human" }, framing = if category == "build" then "full" else "portrait", angle = -18 })
		end
	end
	for id in pack.conditions or {} do
		local c = pack.conditions[id]
		if c.look then
			table.insert(cells, { label = "condition " .. id, ap = { look = base, age = 34, form = "human", conditions = { id } }, framing = "full", angle = -18 })
		end
	end
	for id in pack.forms or {} do
		table.insert(cells, { label = "form " .. id, ap = { look = base, age = 34, form = id }, framing = "portrait", angle = -18 })
	end
	local coats = {}
	for _, id in (pack.gear and pack.gear.order) or {} do
		local g = pack.gear[id]
		if g and g.look and g.slot ~= "tool" and not coats[g.look.kind] then
			coats[g.look.kind] = true
			table.insert(cells, { label = "gear " .. id, ap = { look = base, age = 34, form = "human", gear = { [g.slot] = id } }, framing = "full", angle = -18 })
		end
	end
	return { title = "Beards, accessories, marks, eyes, builds, conditions, forms, worn gear", cellW = 120, cellH = 150, cols = 12, cells = cells }
end)

-- ── build the GUI tree ──────────────────────────────────────────────────────
local wanted = {}
for _, a in process.args do
	table.insert(wanted, a)
end
if #wanted == 0 then
	wanted = ORDER
end
local suffix = if process.env.LIFESIM_PACK == "Undermere" then "_undermere" else ""

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

local function writeSheet(name: string)
	local def = SHEETS[name]()
	local gap, labelH, titleH = 6, 14, 30
	local cols = def.cols
	local rows = math.ceil(#def.cells / cols)
	local W = gap + cols * (def.cellW + gap)
	local H = titleH + gap + rows * (def.cellH + labelH + gap)

	local gui = I.new("ScreenGui")
	gui.Name = "AvatarSheet"
	gui.ZIndexBehavior = roblox.Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = true
	local back = I.new("Frame")
	back.Size = roblox.UDim2.fromScale(1, 1)
	back.BackgroundColor3 = roblox.Color3.fromRGB(5, 6, 8)
	back.BorderSizePixel = 0
	back.Parent = gui
	label(back, string.upper(def.title) .. "   ·   " .. pack.meta.title, gap, 6, W - 2 * gap, 16, roblox.Color3.fromRGB(237, 196, 114))

	local partCount, figures = 0, 0
	for i, cell in def.cells do
		local c, r = (i - 1) % cols, (i - 1) // cols
		local x, y = gap + c * (def.cellW + gap), titleH + gap + r * (def.cellH + labelH + gap)
		label(back, cell.label or "", x, y, def.cellW)
		local w, h = cell.w or def.cellW, cell.h or def.cellH
		local view
		if cell.creature and CreatureView then
			view = CreatureView.new(ctx, {
				size = roblox.UDim2.fromOffset(w, h),
				position = roblox.UDim2.fromOffset(x + (def.cellW - w) // 2, y + labelH),
				framing = cell.framing,
				still = true,
				angle = cell.angle,
			})
			view.frame.Parent = back
			view:set(cell.creature)
			view:aim()
		else
			view = AvatarView.new(ctx, {
				size = roblox.UDim2.fromOffset(w, h),
				position = roblox.UDim2.fromOffset(x + (def.cellW - w) // 2, y + labelH),
				framing = cell.framing,
				chart = cell.framing == "full",
			})
			view.angle = cell.angle or -18
			view.frame.Parent = back
			view:set(cell.ap)
			view:aim()
		end
		figures += 1
		for _, d in view.model:GetChildren() do
			partCount += 1
		end
	end

	local defaults = {}
	local count = 0
	local function node(real)
		count += 1
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
	local dump = {
		format = "gui-snapshot/1",
		state = "avatar-" .. name,
		note = def.title,
		device = "sheet",
		screen = { W, H },
		inset = 0,
		defaults = defaults,
		guis = { node(gui) },
	}
	local path = "tools/avatar/shots/" .. name .. suffix .. ".json"
	fs.writeFile(path, serde.encode("json", dump, false))
	print(string.format("wrote %s (%d figures, %.1f parts each, %dx%d)", path, figures, partCount / math.max(1, figures), W, H))
end

if not fs.isDir("tools/avatar/shots") then
	fs.writeDir("tools/avatar/shots")
end
for _, name in wanted do
	if SHEETS[name] then
		writeSheet(name)
	else
		print("no sheet named " .. name .. " (there are: " .. table.concat(ORDER, ", ") .. ")")
	end
end
