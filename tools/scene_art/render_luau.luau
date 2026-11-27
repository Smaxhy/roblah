--[[
	Builds every scene with SceneArt.luau (the real Roblox Frames, on @lune/roblox) in a grid
	inside a ScreenGui, and writes it as a gui-snapshot/1 dump for tools/gui_render to draw:
		lune run tools/scene_art/render_luau.luau [small|big] [seed]
		node tools/gui_render/shoot.js --dump tools/scene_art/shots/luau_small.json \
			--png tools/scene_art/shots/luau_small.png --bg none --no-topbar
]]

local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local Loader = require("../../tests/loader")

local mode = process.args[1] or "small"
local seed = tonumber(process.args[2]) or 1

Loader.globals = {
	game = {
		GetService = function(_, name)
			assert(name == "RunService", name)
			return { Heartbeat = { Connect = function() end } }
		end,
	},
	Instance = roblox.Instance,
	UDim = roblox.UDim,
	UDim2 = roblox.UDim2,
	Vector2 = roblox.Vector2,
	Color3 = roblox.Color3,
	ColorSequence = roblox.ColorSequence,
	ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	NumberSequence = roblox.NumberSequence,
	NumberSequenceKeypoint = roblox.NumberSequenceKeypoint,
	Enum = roblox.Enum,
	Font = roblox.Font,
}
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local SceneArt = Loader.require(client.SceneArt)

-- the grid
local bw, bh, cols = 360, 120, 4
if mode == "big" then
	bw, bh, cols = 900, 260, 2
elseif mode == "phone" then
	bw, bh, cols = 340, 110, 4
end
local gap, label = 16, 22
local rows = math.ceil(#SceneArt.scenes / cols)
local W, H = gap + cols * (bw + gap), gap + rows * (bh + label + gap)

local gui = roblox.Instance.new("ScreenGui")
gui.Name = "SceneSheet"
gui.ZIndexBehavior = roblox.Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
local back = roblox.Instance.new("Frame")
back.Size = roblox.UDim2.fromScale(1, 1)
back.BackgroundColor3 = roblox.Color3.fromRGB(5, 6, 8)
back.BorderSizePixel = 0
back.Parent = gui
for i, id in SceneArt.scenes do
	local c, r = (i - 1) % cols, (i - 1) // cols
	local x, y = gap + c * (bw + gap), gap + r * (bh + label + gap)
	local t = roblox.Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = roblox.UDim2.fromOffset(x, y)
	t.Size = roblox.UDim2.fromOffset(bw, label - 4)
	t.Text = string.upper(id) .. "  (Luau, seed " .. seed .. ")"
	t.TextXAlignment = roblox.Enum.TextXAlignment.Left
	t.TextColor3 = roblox.Color3.fromRGB(168, 170, 176)
	t.TextSize = 13
	t.FontFace = roblox.Font.new("rbxasset://fonts/families/Oswald.json", roblox.Enum.FontWeight.Medium)
	t.Parent = back
	local holder = roblox.Instance.new("Frame")
	holder.Name = id
	holder.Position = roblox.UDim2.fromOffset(x, y + label)
	holder.Size = roblox.UDim2.fromOffset(bw, bh)
	holder.BackgroundTransparency = 1
	holder.Parent = back
	SceneArt.draw(holder, id, seed)
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
	Color3 = function(c)
		return { byte(c.R), byte(c.G), byte(c.B) }
	end,
	EnumItem = function(e)
		return e.Name
	end,
	Font = function(f)
		return { family = f.Family, weight = f.Weight.Name, style = f.Style.Name }
	end,
	ColorSequence = function(s)
		local out = {}
		for _, k in s.Keypoints do
			table.insert(out, { num(k.Time), byte(k.Value.R), byte(k.Value.G), byte(k.Value.B) })
		end
		return out
	end,
	NumberSequence = function(s)
		local out = {}
		for _, k in s.Keypoints do
			table.insert(out, { num(k.Time), num(k.Value), num(k.Envelope) })
		end
		return out
	end,
}
local GUI = { "Visible", "Size", "Position", "AnchorPoint", "Rotation", "ZIndex", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "ClipsDescendants", "SizeConstraint" }
local TEXT = { "Text", "FontFace", "TextSize", "TextScaled", "TextWrapped", "TextColor3", "TextTransparency", "TextXAlignment", "TextYAlignment" }
local MODS = {
	UICorner = { "CornerRadius" },
	UIStroke = { "Color", "Thickness", "Transparency", "ApplyStrokeMode" },
	UIGradient = { "Color", "Transparency", "Rotation", "Offset" },
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
local defaults = {}
local count = 0
local function node(real)
	count += 1
	if defaults[real.ClassName] == nil then
		defaults[real.ClassName] = readAll(roblox.Instance.new(real.ClassName))
	end
	local out = { class = real.ClassName, name = real.Name, props = readAll(real) }
	if not MODS[real.ClassName] then
		local kids = {}
		for _, c in real:GetChildren() do
			table.insert(kids, node(c))
		end
		if #kids > 0 then
			out.children = kids
		end
	end
	return out
end
local dump = {
	format = "gui-snapshot/1",
	state = "scene-art-" .. mode,
	note = "Every SceneArt.luau scene, built as Roblox Frames",
	device = "sheet",
	screen = { W, H },
	inset = 0,
	defaults = defaults,
	guis = { node(gui) },
}
local path = "tools/scene_art/shots/luau_" .. mode .. ".json"
fs.writeFile(path, serde.encode("json", dump, false))
print(string.format("wrote %s (%d instances, %dx%d)", path, count, W, H))
