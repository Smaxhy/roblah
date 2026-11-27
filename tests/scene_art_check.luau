--[[
	Scene art check: builds every event-card illustration (src/client/SceneArt.luau) on Lune's
	Roblox instances, which reject unknown properties and wrong value types like Roblox does.
	For each scene: two banner sizes (phone 340x110, PC 900x260), several seeds, then
		- no errors, a Frame that fills its parent and clips
		- at most 160 GuiObjects, and only Frames and TextLabels (no images, no viewports)
		- every size and position in Scale (no pixel offsets), gradients within 20 keypoints
		- the same seed draws the same picture; an unknown scene draws "street"
	and SceneArt.animate runs, moves something and puts it all back when stopped.
		lune run tests/scene_art_check
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")

local LIMIT = 160
local SIZES = { { 340, 110 }, { 900, 260 } }
local SEEDS = { 1, 2, 3, 7, 42, 1990, 31337 }

-- ── a minimal client environment ──
local Signal = {}
Signal.__index = Signal
function Signal.new()
	return setmetatable({ fns = {} }, Signal)
end
function Signal:Connect(fn)
	local entry = { fn = fn, live = true }
	table.insert(self.fns, entry)
	return {
		Disconnect = function()
			entry.live = false
		end,
	}
end
function Signal:Fire(...)
	for _, e in self.fns do
		if e.live then
			e.fn(...)
		end
	end
end
function Signal:live(): number
	local n = 0
	for _, e in self.fns do
		if e.live then
			n += 1
		end
	end
	return n
end

local heartbeat = Signal.new()
local services = {
	RunService = { Heartbeat = heartbeat, RenderStepped = Signal.new() },
}
Loader.globals = {
	game = {
		GetService = function(_, name)
			return services[name] or error("SceneArt asked for an unexpected service: " .. tostring(name))
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

local failures = {}
local function fail(msg: string)
	table.insert(failures, msg)
end

local ALLOWED = { Frame = true, TextLabel = true, UICorner = true, UIGradient = true, UIStroke = true }

-- A dump of everything that decides how a scene looks, to compare two draws.
local function dump(inst, out)
	out = out or {}
	for _, d in inst:GetDescendants() do
		local line = d.ClassName .. " " .. d.Name
		if d:IsA("GuiObject") then
			line ..= string.format(" %s %s %s %.3f %s %.3f", tostring(d.Position), tostring(d.Size), tostring(d.AnchorPoint), d.Rotation, tostring(d.BackgroundColor3), d.BackgroundTransparency)
			if d:IsA("TextLabel") then
				line ..= string.format(" %s %s %.3f", d.Text, tostring(d.TextColor3), d.TextTransparency)
			end
		end
		table.insert(out, line)
	end
	return table.concat(out, "\n")
end

local function checkTree(where: string, root)
	local guis = 1
	local texts = 0
	for _, d in root:GetDescendants() do
		if not ALLOWED[d.ClassName] then
			fail(where .. ": unexpected " .. d.ClassName .. " " .. d:GetFullName())
		end
		if d:IsA("GuiObject") then
			guis += 1
			if d:IsA("TextLabel") then
				texts += 1
				if not d.TextScaled then
					fail(where .. ": text not scaled: " .. d.Name)
				end
			end
			local s, p = d.Size, d.Position
			if s.X.Offset ~= 0 or s.Y.Offset ~= 0 or p.X.Offset ~= 0 or p.Y.Offset ~= 0 then
				fail(where .. ": pixel offset on " .. d.Name)
			end
			if s.X.Scale ~= s.X.Scale or s.Y.Scale ~= s.Y.Scale or p.X.Scale ~= p.X.Scale or p.Y.Scale ~= p.Y.Scale then
				fail(where .. ": NaN in " .. d.Name)
			end
			if d.ClipsDescendants and d.Rotation ~= 0 then
				fail(where .. ": a rotated frame cannot clip: " .. d.Name)
			end
		elseif d:IsA("UIGradient") then
			if #d.Color.Keypoints > 20 or #d.Transparency.Keypoints > 20 then
				fail(where .. ": gradient with more than 20 keypoints")
			end
		end
	end
	return guis, texts
end

-- ── every scene, both sizes, several seeds ──
local counts = {}
local seen = {}
for _, id in SceneArt.scenes do
	seen[id] = true
	local most, least, textsMost = 0, math.huge, 0
	for _, size in SIZES do
		for _, seed in SEEDS do
			local holder = roblox.Instance.new("Frame")
			holder.Size = roblox.UDim2.fromOffset(size[1], size[2])
			local where = string.format("%s @%dx%d seed %d", id, size[1], size[2], seed)
			local ok, frame = pcall(SceneArt.draw, holder, id, seed)
			if not ok then
				fail(where .. ": " .. tostring(frame))
				continue
			end
			if frame.Parent ~= holder or not frame:IsA("Frame") then
				fail(where .. ": not a Frame inside the parent")
			end
			if frame.Size ~= roblox.UDim2.new(1, 0, 1, 0) or not frame.ClipsDescendants then
				fail(where .. ": the root must fill its parent and clip")
			end
			if frame:GetAttribute("Scene") ~= id then
				fail(where .. ": drew " .. tostring(frame:GetAttribute("Scene")))
			end
			local guis, texts = checkTree(where, frame)
			if guis > LIMIT then
				fail(string.format("%s: %d GuiObjects (limit %d)", where, guis, LIMIT))
			end
			most = math.max(most, guis)
			least = math.min(least, guis)
			textsMost = math.max(textsMost, texts)
			holder:Destroy()
		end
	end
	-- the same seed draws the same picture; seeds change something somewhere
	local a, b = roblox.Instance.new("Frame"), roblox.Instance.new("Frame")
	local same = dump(SceneArt.draw(a, id, 5)) == dump(SceneArt.draw(b, id, 5))
	if not same then
		fail(id .. ": seed 5 drew two different pictures")
	end
	local differs = false
	local base = dump(SceneArt.draw(roblox.Instance.new("Frame"), id, 1))
	for s = 2, 8 do
		if dump(SceneArt.draw(roblox.Instance.new("Frame"), id, s)) ~= base then
			differs = true
			break
		end
	end
	if not differs then
		fail(id .. ": no seed changes anything")
	end
	table.insert(counts, { id = id, most = most, least = least, texts = textsMost })
end
if #SceneArt.scenes ~= 26 then
	fail("expected 26 scenes, got " .. #SceneArt.scenes)
end

-- the pack's scene list and SceneArt's agree
local fs = require("@lune/fs")
local cityInit = fs.readFile("src/shared/City/init.luau")
local list = string.match(cityInit, "pack%.scenes%s*=%s*(%b{})")
if list then
	for name in string.gmatch(list, '"([%w_]+)"') do
		if not seen[name] then
			fail("pack.scenes has " .. name .. " but SceneArt does not")
		end
		seen[name] = nil
	end
	for name in seen do
		fail("SceneArt has " .. name .. " but pack.scenes does not")
	end
else
	fail("could not find pack.scenes in src/shared/City/init.luau")
end

-- unknown ids and odd seeds still draw
do
	local holder = roblox.Instance.new("Frame")
	local f = SceneArt.draw(holder, "no_such_scene", nil)
	if f:GetAttribute("Scene") ~= "street" then
		fail("an unknown scene should draw street")
	end
	for _, seed in { 0, -12, 3.7, 0 / 0, math.huge, 2 ^ 60 } do
		local ok, err = pcall(SceneArt.draw, holder, "alley", seed)
		if not ok then
			fail("seed " .. tostring(seed) .. ": " .. tostring(err))
		end
	end
	-- a custom fade color reaches the fade
	local fade = roblox.Color3.fromRGB(231, 224, 209)
	local g = SceneArt.draw(holder, "home", 1, { fade = fade })
	local found = false
	for _, d in g:GetDescendants() do
		if d.Name == "Fade" then
			found = true
			if d.BackgroundColor3 ~= fade then
				fail("opts.fade was not applied")
			end
		end
	end
	if not found then
		fail("no Fade frame")
	end
end

-- ── motion ──
do
	local animated = 0
	for _, id in SceneArt.scenes do
		local holder = roblox.Instance.new("Frame")
		local frame = SceneArt.draw(holder, id, 3)
		local before = dump(frame)
		local ok, stop = pcall(SceneArt.animate, frame)
		if not ok then
			fail(id .. ": animate: " .. tostring(stop))
			continue
		end
		local moved = false
		for i = 1, 240 do
			heartbeat:Fire(1 / 60)
			if i % 20 == 0 and not moved then
				moved = dump(frame) ~= before
			end
		end
		stop()
		if dump(frame) ~= before then
			fail(id .. ": stop() did not put things back")
		end
		if moved then
			animated += 1
		end
		if heartbeat:live() ~= 0 then
			fail(id .. ": animate left a connection behind")
		end
		-- a frame that leaves the game stops by itself
		local stop2 = SceneArt.animate(frame)
		frame.Parent = nil
		heartbeat:Fire(1 / 30)
		if heartbeat:live() ~= 0 then
			fail(id .. ": animation kept running after the frame was removed")
		end
		stop2()
	end
	print(string.format("animate: %d of %d scenes move", animated, #SceneArt.scenes))
end

-- ── report ──
print(string.format("%-11s %8s %8s %6s", "scene", "objects", "fewest", "texts"))
for _, c in counts do
	print(string.format("%-11s %8d %8d %6d", c.id, c.most, c.least, c.texts))
end
if #failures > 0 then
	print("\nFAILED:")
	for i, f in failures do
		if i > 60 then
			print(string.format("... and %d more", #failures - 60))
			break
		end
		print("  " .. f)
	end
	process.exit(1)
end
print("\nscene art ok: " .. #SceneArt.scenes .. " scenes, " .. #SIZES .. " sizes, " .. #SEEDS .. " seeds each")
