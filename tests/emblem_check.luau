--[[
	Emblem check: builds every emblem (src/client/UI/Emblem.luau) at three sizes, the logo, and
	an unknown id, out of Lune's Roblox instances, which reject unknown properties and wrong
	value types the way Roblox does. Fails on any error, a missing id, an emblem over 25
	GuiObjects, a part outside its square, or a broken cut.
		lune run tests/emblem_check
		lune run tests/emblem_check --dump out.json   also writes every emblem as a GUI dump for
		                                              tools/gui_render (node tools/emblems/luau_shot.js)
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local Loader = require("./loader")

-- Kit (which Emblem builds with) asks for TweenService when it loads; nothing here tweens
local game = {
	GetService = function(_, name)
		assert(name == "TweenService", "Emblem shouldn't need the " .. tostring(name) .. " service")
		return {}
	end,
}
Loader.globals = {
	game = game,
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
	TweenInfo = { new = function(...)
		return { ... }
	end },
	typeof = roblox.typeof or typeof,
}

local uiRoot = Loader.preload(Loader.node("src/client/UI", "UI", nil))
local Emblem = Loader.require(uiRoot.Emblem)

local failures = {}
local function fail(msg: string)
	table.insert(failures, msg)
end

-- the ids the lead asked for
local REQUIRED = {
	"stat.fortitude", "stat.prudence", "stat.temperance", "stat.justice", "stat.sanity",
	"stat.health", "stat.strength", "stat.speed", "stat.intelligence", "stat.charisma", "stat.luck", "stat.mind",
	"cur.ahn", "cur.light", "cur.lunacy",
	"approach.steady", "approach.reckless", "approach.careful",
	"style.tremor", "style.rupture", "style.bleed", "style.burn", "style.sinking", "style.poise", "style.charge",
	"sin.wrath", "sin.lust", "sin.sloth", "sin.gluttony", "sin.gloom", "sin.pride", "sin.envy",
	"faction.thumb", "faction.middle", "faction.index", "faction.ring", "faction.fingers", "faction.fixers",
	"faction.hana", "faction.wings", "faction.lcorp", "faction.bloodfiend", "faction.limbus", "faction.library",
	"faction.syndicate", "faction.night",
	"tab.activities", "tab.light", "tab.you", "tab.city", "tab.crew", "tab.goals", "tab.lore", "tab.ranks",
	"tab.store", "tab.menu", "tab.guide", "tab.friends",
	"misc.clock", "misc.coin_heads", "misc.coin_tails", "misc.skull", "misc.check", "misc.cross", "misc.lock",
	"misc.star", "misc.year", "misc.fight",
	-- v0.11: what a card is part of, the new tabs, and a foe's temper
	"thread.story", "thread.work", "thread.people", "thread.district", "thread.age", "thread.brink", "thread.grudge", "thread.danger",
	"thread.past", "thread.life", "thread.city", "thread.self", "tab.story", "tab.people", "tab.do", "tab.work",
	"temper.brute", "temper.quick", "temper.cunning",
	-- v0.12: more of "Who you know of" (Wings and Associations wear badges: "wing:K", "assoc:2")
	"faction.pinky", "faction.kurokumo", "faction.rats", "faction.blade", "faction.head", "faction.outskirts",
}

assert(type(Emblem.ids) == "table", "Emblem.ids is missing")
local have = {}
for _, id in Emblem.ids do
	if have[id] then
		fail("duplicate id " .. id)
	end
	have[id] = true
end
for _, id in REQUIRED do
	if not have[id] then
		fail("missing id " .. id)
	end
end
if #Emblem.ids ~= #REQUIRED then
	fail(string.format("%d ids, expected %d", #Emblem.ids, #REQUIRED))
end

-- one built emblem: its root, its parts, and where they sit
local function inspect(label: string, frame, S: number)
	if typeof(frame) ~= "Instance" or not frame:IsA("Frame") then
		fail(label .. ": didn't return a Frame")
		return
	end
	if frame.Size ~= roblox.UDim2.fromOffset(S, S) then
		fail(label .. ": root size " .. tostring(frame.Size))
	end
	if frame.BackgroundTransparency ~= 1 then
		fail(label .. ": root background isn't transparent")
	end
	local guiObjects = 1
	local parts = 0
	for _, d in frame:GetDescendants() do
		if d:IsA("GuiObject") then
			guiObjects += 1
		end
		local cls = d.ClassName
		if cls ~= "Frame" and cls ~= "TextLabel" and cls ~= "UICorner" and cls ~= "UIStroke" and cls ~= "UIGradient" then
			fail(label .. ": uses a " .. cls)
		end
		if cls == "Frame" then
			parts += 1
			if d.Parent ~= frame then
				fail(label .. ": a nested part")
			end
			-- its bounding box, turned with it, with any outline, must stay in (about) the square
			-- parts are placed in Scale (offsets are whole pixels in Roblox; the geometry isn't)
			if d.Size.X.Offset ~= 0 or d.Size.Y.Offset ~= 0 or d.Position.X.Offset ~= 0 or d.Position.Y.Offset ~= 0 then
				fail(label .. ": part " .. d.Name .. " uses offsets, which Roblox rounds to whole pixels")
			end
			local w, h = d.Size.X.Scale * S, d.Size.Y.Scale * S
			if w < 0 or h < 0 then
				fail(label .. ": part " .. d.Name .. " has a bad size " .. tostring(d.Size))
			end
			local stroke = d:FindFirstChildOfClass("UIStroke")
			local st = if stroke then stroke.Thickness else 0
			local a = math.rad(d.Rotation)
			local hx = (math.abs(w * math.cos(a)) + math.abs(h * math.sin(a))) / 2 + st
			local hy = (math.abs(w * math.sin(a)) + math.abs(h * math.cos(a))) / 2 + st
			local cx, cy = d.Position.X.Scale * S, d.Position.Y.Scale * S
			local x0, x1, y0, y1 = cx - hx, cx + hx, cy - hy, cy + hy
			-- a half cut square to the screen hides the far half (an arc's ring can hang outside)
			local grad = (stroke or d):FindFirstChildOfClass("UIGradient")
			if grad and grad.Transparency.Keypoints[1].Value == 1 then
				local dir = (d.Rotation + grad.Rotation) % 360
				if dir == 0 then
					x0 = cx - st
				elseif dir == 90 then
					y0 = cy - st
				elseif dir == 180 then
					x1 = cx + st
				elseif dir == 270 then
					y1 = cy + st
				end
			end
			local margin = 1 + S * 0.04
			if x0 < -margin or y0 < -margin or x1 > S + margin or y1 > S + margin then
				fail(string.format("%s: part %s spills out of the square (%.1f..%.1f, %.1f..%.1f)", label, d.Name, x0, x1, y0, y1))
			end
			if d.BackgroundTransparency >= 1 and not stroke then
				fail(label .. ": part " .. d.Name .. " draws nothing")
			end
		elseif cls == "UIGradient" then
			local p = d.Parent
			if not (p and (p:IsA("Frame") or p:IsA("UIStroke"))) then
				fail(label .. ": a cut on a " .. (if p then p.ClassName else "nothing"))
			end
			local keys = d.Transparency.Keypoints
			if #keys < 2 or #keys > 20 or keys[1].Time ~= 0 or keys[#keys].Time ~= 1 then
				fail(label .. ": a malformed cut")
			end
		end
	end
	if parts == 0 then
		fail(label .. ": empty")
	end
	if guiObjects > 25 then
		fail(string.format("%s: %d GuiObjects (25 at most)", label, guiObjects))
	end
	return guiObjects
end

local SIZES = { 16, 20, 64 }
local most, mostId = 0, ""
for _, id in Emblem.ids do
	for _, S in SIZES do
		local label = id .. " @" .. S
		local ok, frame = pcall(Emblem.make, id, S)
		if not ok then
			fail(label .. ": " .. tostring(frame))
		else
			local n = inspect(label, frame, S)
			if n and n > most then
				most, mostId = n, id
			end
			if ok and frame:GetAttribute("EmblemId") ~= id then
				fail(label .. ": EmblemId attribute")
			end
		end
	end
	local ok, c = pcall(Emblem.color, id)
	if not ok or typeof(c) ~= "Color3" then
		fail(id .. ": Emblem.color")
	end
end

-- tints: a flat single color, and a dark ink for paper
do
	local grey = roblox.Color3.fromRGB(110, 114, 122)
	local ok, frame = pcall(Emblem.make, "tab.store", 20, grey, grey)
	if not ok then
		fail("tinted tab.store: " .. tostring(frame))
	else
		for _, d in frame:GetDescendants() do
			local col = if d:IsA("UIStroke") then d.Color elseif d:IsA("Frame") and d.BackgroundTransparency < 1 then d.BackgroundColor3 else nil
			if col and col ~= grey then
				fail("tinted tab.store: a part isn't the tint")
			end
		end
	end
	local ink = roblox.Color3.fromRGB(28, 26, 23)
	ok, frame = pcall(Emblem.make, "stat.prudence", 20, nil, ink)
	if not ok then
		fail("paper stat.prudence: " .. tostring(frame))
	else
		local line = frame:FindFirstChild("L01")
		if not line or line.BackgroundColor3 ~= ink then
			fail("paper stat.prudence: the linework isn't the ink")
		end
	end
end

-- the logo and an unknown id
for _, S in { 20, 40, 128 } do
	local ok, frame = pcall(Emblem.logo, S)
	if not ok then
		fail("logo @" .. S .. ": " .. tostring(frame))
	else
		inspect("logo @" .. S, frame, S)
	end
end
do
	local ok, frame = pcall(Emblem.make, "no.such.emblem", 20)
	if not ok then
		fail("unknown id: " .. tostring(frame))
	else
		inspect("unknown id", frame, 20)
	end
end

-- ── --dump: every emblem as a GUI dump for tools/gui_render ─────────────────
local dumpPath = nil
for i, a in process.args do
	if a == "--dump" then
		dumpPath = process.args[i + 1]
	end
end

if dumpPath then
	local function num(x: number)
		return math.floor(x * 1e6 + 0.5) / 1e6
	end
	local function byte(x: number)
		return math.clamp(math.floor(x * 255 + 0.5), 0, 255)
	end
	local function encode(v)
		local t = typeof(v)
		if t == "UDim2" then
			return { num(v.X.Scale), num(v.X.Offset), num(v.Y.Scale), num(v.Y.Offset) }
		elseif t == "UDim" then
			return { num(v.Scale), num(v.Offset) }
		elseif t == "Vector2" then
			return { num(v.X), num(v.Y) }
		elseif t == "Color3" then
			return { byte(v.R), byte(v.G), byte(v.B) }
		elseif t == "EnumItem" then
			return v.Name
		elseif t == "NumberSequence" then
			local out = {}
			for _, k in v.Keypoints do
				table.insert(out, { num(k.Time), num(k.Value), num(k.Envelope) })
			end
			return out
		elseif t == "Font" then
			return { family = v.Family, weight = v.Weight.Name, style = v.Style.Name }
		elseif t == "number" then
			return num(v)
		end
		return v
	end
	local PROPS = {
		Frame = { "Size", "Position", "AnchorPoint", "Rotation", "ZIndex", "BackgroundColor3", "BackgroundTransparency", "BorderSizePixel", "Visible" },
		TextLabel = { "Size", "Position", "AnchorPoint", "ZIndex", "BackgroundTransparency", "BorderSizePixel", "Visible", "Text", "FontFace", "TextSize", "TextColor3", "TextXAlignment", "TextYAlignment" },
		UIStroke = { "Color", "Thickness", "Transparency", "ApplyStrokeMode", "LineJoinMode" },
		UICorner = { "CornerRadius" },
		UIGradient = { "Rotation", "Transparency" },
	}
	local function node(inst)
		local out = { class = inst.ClassName, name = inst.Name, props = {} }
		for _, k in PROPS[inst.ClassName] or {} do
			out.props[k] = encode((inst :: any)[k])
		end
		local kids = {}
		for _, c in inst:GetChildren() do
			table.insert(kids, node(c))
		end
		if #kids > 0 then
			out.children = kids
		end
		return out
	end

	-- a sheet: every emblem at 20 and 64 px with its id, then the logo
	local COLS, CELL_W, CELL_H = 6, 230, 84
	local screen = roblox.Instance.new("ScreenGui")
	screen.Name = "Emblems"
	local bg = roblox.Instance.new("Frame")
	bg.Name = "Panel"
	bg.BackgroundColor3 = roblox.Color3.fromRGB(14, 16, 20)
	bg.BorderSizePixel = 0
	bg.Size = roblox.UDim2.fromScale(1, 1)
	bg.Parent = screen
	local list = table.clone(Emblem.ids)
	table.insert(list, "no.such.emblem")
	local parts = {}
	for n, id in list do
		local col, row = (n - 1) % COLS, (n - 1) // COLS
		local x, y = 16 + col * CELL_W, 16 + row * CELL_H
		local big = Emblem.make(id, 64)
		big.Position = roblox.UDim2.fromOffset(x, y)
		big.Parent = bg
		local small = Emblem.make(id, 20)
		small.Position = roblox.UDim2.fromOffset(x + 74, y + 22)
		small.Parent = bg
		local label = roblox.Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = roblox.UDim2.fromOffset(x + 102, y + 22)
		label.Size = roblox.UDim2.fromOffset(CELL_W - 106, 20)
		label.Text = id
		label.FontFace = roblox.Font.fromEnum(roblox.Enum.Font.RobotoMono)
		label.TextSize = 11
		label.TextColor3 = roblox.Color3.fromRGB(168, 170, 176)
		label.TextXAlignment = roblox.Enum.TextXAlignment.Left
		label.Parent = bg
		parts[id] = { ["64"] = node(big), ["20"] = node(small) }
	end
	local rows = (#list + COLS - 1) // COLS
	local logoY = 16 + rows * CELL_H + 8
	local lx = 16
	for _, S in { 128, 64, 40, 20 } do
		local logo = Emblem.logo(S)
		logo.Position = roblox.UDim2.fromOffset(lx, logoY + (128 - S))
		logo.Parent = bg
		parts["logo@" .. S] = node(logo)
		lx += S + 24
	end
	local W, H = 16 * 2 + COLS * CELL_W, logoY + 128 + 16
	local guiNode = node(screen)
	guiNode.props = { Enabled = true, IgnoreGuiInset = true, ZIndexBehavior = "Sibling", DisplayOrder = 0 }
	local dump = {
		format = 1,
		device = "emblems",
		state = "emblems",
		note = "Every emblem built by src/client/UI/Emblem.luau (tests/emblem_check.luau --dump).",
		screen = { W, H },
		inset = 0,
		index = 1,
		time = 0,
		defaults = {},
		guis = { guiNode },
		emblems = parts, -- each emblem's own tree at 64 and 20 px, for tools/emblems/parity.js
	}
	fs.writeFile(dumpPath, serde.encode("json", dump))
	print("wrote " .. dumpPath)
end

if #failures > 0 then
	for _, f in failures do
		print("FAIL " .. f)
	end
	print(string.format("%d emblem checks failed", #failures))
	process.exit(1)
end
print(string.format("emblem check: %d emblems at %d sizes, the logo and the fallback built clean (busiest: %s, %d GuiObjects)", #Emblem.ids, #SIZES, mostId, most))
