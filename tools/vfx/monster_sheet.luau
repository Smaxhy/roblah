--[[
	CONTACT SHEETS OF THE BESTIARY (Hunter/Monsters.luau, through server/HunterLive/Monsters):
	one page a rank, every kind framed to fit, labelled with its family, behaviour and gait.
		lune run tools/vfx/monster_sheet.luau [ranks, e.g. EDC] [--pose] [--kit]
		node tools/gui_render/shoot.js --dump tools/vfx/shots/monsters_e.json --png tools/vfx/shots/monsters_e.png --bg none --no-topbar --scale 1
	--pose  runs client/MonsterAnim a moment first, so the limbs show a stride
	--kit   builds the boxes the new head meshes go in (Monsters.MESH_LAYOUT)
	Copies of the pages live in docs/images/bestiary_<rank>.png.
]]
local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local Loader = require("../../tests/loader")
local I = roblox.Instance
local noop = function() end
local sharedRoot = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font,
	ColorSequence = roblox.ColorSequence, NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
	NumberRange = roblox.NumberRange, TweenInfo = { new = function(...) return { ... } end },
	task = { delay = noop, spawn = noop, wait = function() return 0 end },
	game = { GetService = function(_, name)
		if name == "ReplicatedStorage" then
			return { WaitForChild = function() return sharedRoot end, FindFirstChild = function() return nil end }
		elseif name == "TweenService" then
			return { Create = function() return { Play = noop } end }
		elseif name == "RunService" then
			return { RenderStepped = { Connect = noop }, Heartbeat = { Connect = noop } }
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
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local okAnim, MonsterAnim = pcall(Loader.require, client.MonsterAnim)
if not okAnim then
	print("(client/MonsterAnim did not load: " .. tostring(MonsterAnim) .. ")")
end

local ranksWanted, pose = "EDCBAS", false
local only: { [string]: boolean }? = nil
for _, a in process.args do
	if a == "--pose" then
		pose = true
	elseif string.sub(a, 1, 7) == "--only=" then
		-- (a page of just these kinds, for a closer look: tools/vfx/shots/monsters_x.json)
		only = {}
		for id in string.gmatch(string.sub(a, 8), "[^,]+") do
			(only :: any)[id] = true
		end
	elseif a == "--kit" then
		Monsters.MESH_LAYOUT = true
	elseif string.match(a, "^[EDCBASedcbas]+$") then
		ranksWanted = string.upper(a)
	end
end
local LETTERS = { "E", "D", "C", "B", "A", "S" }

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
		if d:IsA("BasePart") and d.Transparency < 1 then
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

-- a model's box, from its visible parts
local function box(model)
	local lo = roblox.Vector3.new(math.huge, math.huge, math.huge)
	local hi = -lo
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and d.Transparency < 0.95 then
			local h = d.Size / 2
			for _, sx in { -1, 1 } do
				for _, sy in { -1, 1 } do
					for _, sz in { -1, 1 } do
						local p = d.CFrame * roblox.Vector3.new(h.X * sx, h.Y * sy, h.Z * sz)
						lo = roblox.Vector3.new(math.min(lo.X, p.X), math.min(lo.Y, p.Y), math.min(lo.Z, p.Z))
						hi = roblox.Vector3.new(math.max(hi.X, p.X), math.max(hi.Y, p.Y), math.max(hi.Z, p.Z))
					end
				end
			end
		end
	end
	return lo, hi
end

local pages = {}
if only then
	local cells = {}
	for _, id in Monsters.ORDER do
		local d = Monsters.DEFS[id]
		if (only :: any)[id] then
			table.insert(cells, { id = id, label = d.name, sub = string.format("%s · %s · %s", (string.gsub(d.family, "_", " ")), d.beh, d.gait) })
		end
	end
	table.insert(pages, { rank = 0, cells = cells, big = true })
end
for r = 1, 6 do
	if not only and string.find(ranksWanted, LETTERS[r], 1, true) then
		local cells = {}
		-- (in the order the bestiary lists them: families together)
		for _, id in Monsters.ORDER do
			local d = Monsters.DEFS[id]
			if d.rank == r then
				table.insert(cells, { id = id, label = d.name, sub = string.format("%s · %s · %s", (string.gsub(d.family, "_", " ")), d.beh, d.gait) })
			end
		end
		table.insert(pages, { rank = r, cells = cells })
	end
end

local function sheet(page)
	local cells = page.cells
	local cols, cellW, cellH, gap, labelH, titleH = 6, 210, 200, 6, 30, 30
	if page.big then
		cols, cellW, cellH = math.min(4, #cells), 420, 400
	end
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
	label(back, if page.rank == 0 then "BITLEVELING · THE BESTIARY · A CLOSER LOOK" else string.format("BITLEVELING · THE BESTIARY · %s-RANK · %d KINDS", LETTERS[page.rank], #cells), gap, 6, W - 2 * gap, 16, roblox.Color3.fromRGB(255, 140, 110))
	for i, cell in cells do
		local c, rr = (i - 1) % cols, (i - 1) // cols
		local x, y = gap + c * (cellW + gap), titleH + gap + rr * (cellH + labelH + gap)
		label(back, cell.label, x, y, cellW, 12, roblox.Color3.fromRGB(230, 232, 238))
		label(back, cell.sub, x, y + 15, cellW, 10)
		local vp = I.new("ViewportFrame")
		vp.Position = roblox.UDim2.fromOffset(x, y + labelH)
		vp.Size = roblox.UDim2.fromOffset(cellW, cellH)
		vp.BackgroundColor3 = roblox.Color3.fromRGB(14, 16, 26)
		vp.Ambient = roblox.Color3.fromRGB(150, 150, 160)
		vp.LightColor = roblox.Color3.fromRGB(255, 250, 240)
		vp.Parent = back
		local model = Monsters.build(cell.id)
		if pose and okAnim and MonsterAnim.applyOffline then
			local rig = MonsterAnim.rig(model)
			if rig then
				for step = 1, 9 do
					MonsterAnim.animate(rig, 1 / 30, step / 30)
				end
				-- (offline, a joint's Transform isn't applied to its parts: this applies it)
				MonsterAnim.applyOffline(model, rig)
			end
		end
		model.Parent = vp
		-- (long bodies turned further, to be seen from the side)
		local g = Monsters.DEFS[cell.id].gait
		local yaw = if g == "slither" or g == "serpent" or g == "centaur" or g == "quad" or g == "spider" or g == "hexapod" or g == "crawler" then -58 else -35
		for _, d in model:GetDescendants() do
			if d:IsA("BasePart") then
				d.CFrame = roblox.CFrame.Angles(0, math.rad(yaw), 0) * d.CFrame
			end
		end
		local lo, hi = box(model)
		local centre = (lo + hi) / 2
		local ext = hi - lo
		local fit = math.max(ext.Y, math.max(ext.X, ext.Z) * 0.85)
		local cam = I.new("Camera")
		cam.FieldOfView = 40
		local dist = fit / 2 / math.tan(math.rad(20)) * 1.1 + math.max(ext.X, ext.Z) / 2
		cam.CFrame = roblox.CFrame.new(centre + roblox.Vector3.new(0, ext.Y * 0.1, -dist)) * roblox.CFrame.Angles(0, math.pi, 0) * roblox.CFrame.Angles(math.rad(-6), 0, 0)
		cam.Parent = vp
		vp.CurrentCamera = cam
	end
	return gui, W, H
end

if not fs.isDir("tools/vfx/shots") then
	fs.writeDir("tools/vfx/shots")
end
for _, page in pages do
	local gui, W, H = sheet(page)
	local name = "tools/vfx/shots/monsters_" .. (if page.rank == 0 then "x" else string.lower(LETTERS[page.rank])) .. ".json"
	fs.writeFile(name, serde.encode("json", { format = "gui-snapshot/1", state = "monsters", note = "Monsters", device = "sheet", screen = { W, H }, inset = 0, defaults = defaults, guis = { node(gui) } }, false))
	print("wrote " .. name)
end
