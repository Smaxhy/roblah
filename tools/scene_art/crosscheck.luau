--[[
	Compares the Frames SceneArt.luau builds with what preview/scenes.js draws: for every scene
	and seed in tools/scene_art/shots/crosscheck.json (written by crosscheck.js), lays the
	Roblox tree out at 900x260 the way Roblox does (Scale sizes, AnchorPoint, RelativeYY) and
	checks each element's box, rotation, color, transparency and text against the browser's.
		node tools/scene_art/crosscheck.js && lune run tools/scene_art/crosscheck.luau
]]

local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local Loader = require("../../tests/loader")

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

local data = serde.decode("json", fs.readFile("tools/scene_art/shots/crosscheck.json"))
local W, H = data.W, data.H

local function hex(c): string
	return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

-- Roblox's layout for one GuiObject inside a parent box
local function layout(inst, px, py, pw, ph, out)
	for _, child in inst:GetChildren() do
		if child:IsA("GuiObject") then
			local s, p, ap = child.Size, child.Position, child.AnchorPoint
			local w, h
			if child.SizeConstraint == roblox.Enum.SizeConstraint.RelativeYY then
				w, h = s.X.Scale * ph + s.X.Offset, s.Y.Scale * ph + s.Y.Offset
			else
				w, h = s.X.Scale * pw + s.X.Offset, s.Y.Scale * ph + s.Y.Offset
			end
			local x = px + p.X.Scale * pw + p.X.Offset - ap.X * w
			local y = py + p.Y.Scale * ph + p.Y.Offset - ap.Y * h
			local isText = child:IsA("TextLabel")
			table.insert(out, {
				k = child.ClassName,
				x = x,
				y = y,
				w = w,
				h = h,
				rot = child.Rotation,
				c = if isText then hex(child.TextColor3) elseif child.BackgroundTransparency < 1 then hex(child.BackgroundColor3) else nil,
				a = if isText then 1 - child.TextTransparency else 1 - child.BackgroundTransparency,
				t = if isText then child.Text else nil,
			})
			layout(child, x, y, w, h, out)
		end
	end
	return out
end

local function near(a: number, b: number, tol: number): boolean
	return math.abs(a - b) <= tol
end

local failures, compared = {}, 0
for _, case in data.cases do
	local holder = roblox.Instance.new("Frame")
	holder.Size = roblox.UDim2.fromOffset(W, H)
	local frame = SceneArt.draw(holder, case.id, case.seed)
	local got = layout(frame, 0, 0, W, H, {})
	local want = case.items
	local where = case.id .. " seed " .. case.seed
	if hex(frame.BackgroundColor3) ~= case.bg then
		table.insert(failures, where .. ": background " .. hex(frame.BackgroundColor3) .. " vs " .. case.bg)
	end
	if #got ~= #want then
		table.insert(failures, string.format("%s: %d elements in Roblox, %d in the browser", where, #got, #want))
	end
	for i = 1, math.min(#got, #want) do
		local g, e = got[i], want[i]
		local bad = nil
		if g.k ~= e.k then
			bad = "class " .. g.k .. " vs " .. e.k
		elseif not (near(g.x, e.x, 0.01) and near(g.y, e.y, 0.01) and near(g.w, e.w, 0.01) and near(g.h, e.h, 0.01)) then
			bad = string.format("box %.2f,%.2f %.2fx%.2f vs %.2f,%.2f %.2fx%.2f", g.x, g.y, g.w, g.h, e.x, e.y, e.w, e.h)
		elseif not near(g.rot, e.rot, 0.001) then
			bad = string.format("rotation %.3f vs %.3f", g.rot, e.rot)
		elseif e.a > 0 and g.c ~= e.c then
			bad = "color " .. tostring(g.c) .. " vs " .. tostring(e.c)
		elseif not near(g.a, e.a, 0.0005) then
			bad = string.format("alpha %.4f vs %.4f", g.a, e.a)
		elseif g.t ~= e.t then
			bad = "text " .. tostring(g.t) .. " vs " .. tostring(e.t)
		end
		if bad then
			table.insert(failures, string.format("%s, element %d: %s", where, i, bad))
			break
		end
		compared += 1
	end
end

if #failures > 0 then
	for i, f in failures do
		if i > 30 then
			break
		end
		print(f)
	end
	print(string.format("\n%d of %d cases differ", #failures, #data.cases))
	process.exit(1)
end
print(string.format("crosscheck ok: %d cases, %d elements match the browser exactly", #data.cases, compared))
