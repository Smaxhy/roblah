--[[
	PREVIEW GALLERIES IN THE EDITOR (BitLeveling Studio plugin): the game's own builders put
	every monster, outfit preset, weapon or Gate in Workspace.BitLevelingPreview, anchored and
	labelled, so you can walk round them in Studio (with the mesh kit on, if the place has it).

		Previews.build(game, what, shared, server, client, at) -> count
		Previews.clear(game)
	`what` is "monsters", "outfits", "weapons" or "gates".
]]

local Previews = {}

local FOLDER = "BitLevelingPreview"

function Previews.clear(game: any)
	local ws = game:GetService("Workspace")
	local f = ws:FindFirstChild(FOLDER)
	if f then
		f:Destroy()
	end
end

local function folder(game: any, what: string): Instance
	local ws = game:GetService("Workspace")
	local f = ws:FindFirstChild(FOLDER)
	if not f then
		f = Instance.new("Folder")
		f.Name = FOLDER
		f.Parent = ws
	end
	local old = f:FindFirstChild(what)
	if old then
		old:Destroy()
	end
	local sub = Instance.new("Folder")
	sub.Name = what
	sub.Parent = f
	return sub
end

local function anchor(model: Instance)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
		end
	end
end

-- a model's box, from its parts (works on any model, pivot or not)
local function box(model: Instance): (Vector3, Vector3)
	local lo = Vector3.new(math.huge, math.huge, math.huge)
	local hi = -lo
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and d.Transparency < 1 then
			local h = d.Size / 2
			for _, sx in { -1, 1 } do
				for _, sy in { -1, 1 } do
					for _, sz in { -1, 1 } do
						local p = d.CFrame * Vector3.new(h.X * sx, h.Y * sy, h.Z * sz)
						lo = Vector3.new(math.min(lo.X, p.X), math.min(lo.Y, p.Y), math.min(lo.Z, p.Z))
						hi = Vector3.new(math.max(hi.X, p.X), math.max(hi.Y, p.Y), math.max(hi.Z, p.Z))
					end
				end
			end
		end
	end
	if lo.X == math.huge then
		return Vector3.zero, Vector3.zero
	end
	return lo, hi
end

-- stand a model with its feet on `at`, centred on it, turned to face the camera's way back
local function stand(model: Instance, at: Vector3)
	local lo, hi = box(model)
	local centre = Vector3.new((lo.X + hi.X) / 2, lo.Y, (lo.Z + hi.Z) / 2)
	local move = CFrame.new(at) * CFrame.Angles(0, math.pi, 0) * CFrame.new(-centre)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CFrame = move * d.CFrame
		end
	end
end

local function label(model: Model, text: string, color: Color3?)
	local lo, hi = box(model)
	local size = hi - lo
	local holder = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if not holder then
		return
	end
	local bb = Instance.new("BillboardGui")
	bb.Name = "PreviewLabel"
	bb.Size = UDim2.fromOffset(220, 28)
	bb.StudsOffsetWorldSpace = Vector3.new(0, size.Y / 2 + 1.5, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 220
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = color or Color3.fromRGB(235, 235, 245)
	t.TextStrokeTransparency = 0.3
	t.TextScaled = true
	t.Font = Enum.Font.GothamBold
	t.Parent = bb
	bb.Parent = holder
end

local RANK = { "E", "D", "C", "B", "A", "S" }

function Previews.build(game: any, what: string, shared: Instance, server: Instance, client: Instance, at: Vector3?): number
	local origin = at or Vector3.new(0, 0, -40)
	local into = folder(game, what)
	local count = 0
	local function grid(i: number, cols: number, spacing: number): Vector3
		local c, r = (i - 1) % cols, (i - 1) // cols
		return origin + Vector3.new((c - (cols - 1) / 2) * spacing, 0, -r * spacing)
	end
	local hunter = shared:WaitForChild("Hunter")
	if what == "monsters" then
		local Monsters = require(server:WaitForChild("HunterLive"):WaitForChild("Monsters") :: ModuleScript) :: any
		local i = 0
		for r = 1, 6 do
			for _, kind in Monsters.KINDS[r] do
				i += 1
				local model = Monsters.build(kind)
				anchor(model)
				model.Parent = into
				stand(model, grid(i, 6, 24))
				label(model, RANK[r] .. "-rank · " .. Monsters.DEFS[kind].name)
				count += 1
			end
		end
	elseif what == "outfits" then
		-- every preset, a row per shelf (each class E to S, the Association, guilds, civilians, iconic)
		local R6Rig = require(hunter:WaitForChild("R6Rig") :: ModuleScript) :: any
		local Looks = require(hunter:WaitForChild("Looks") :: ModuleScript) :: any
		for row, cat in Looks.CATEGORIES do
			for col, p in Looks.presetsIn(cat.id) do
				local look = Looks.applyPreset(Looks.DEFAULT, p.id)
				look.accessories = p.acc
				local rank = math.max(1, (table.find(RANK, p.rank or "C") or 3))
				local model = R6Rig.build(look, { name = p.name, rank = rank })
				anchor(model)
				model.Parent = into
				stand(model, origin + Vector3.new((col - 4) * 8, 0, -(row - 1) * 11))
				label(model, (if p.rank then p.rank .. " · " else "") .. cat.name .. " · " .. p.name)
				count += 1
			end
		end
	elseif what == "weapons" then
		-- every weapon, a row per family, the families grouped by class; stars cycle, every
		-- ninth one Shiny
		local R6Rig = require(hunter:WaitForChild("R6Rig") :: ModuleScript) :: any
		local Weapons = require(hunter:WaitForChild("Weapons") :: ModuleScript) :: any
		local GRADE = { E = 1, D = 2, C = 3, B = 4, A = 5, S = 6 }
		local i, row = 0, 0
		for _, fam in Weapons.FAMILY_ORDER do
			local inFam = {}
			for _, w in Weapons.list do
				if w.family == fam then
					table.insert(inFam, w)
				end
			end
			table.sort(inFam, function(x, y)
				local gx, gy = GRADE[x.grade] or 0, GRADE[y.grade] or 0
				if gx ~= gy then
					return gx < gy
				end
				return x.name < y.name
			end)
			if #inFam > 0 then
				row += 1
				for col, w in inFam do
					i += 1
					local stars = (i % 3) + 1
					local shiny = i % 9 == 0
					local model = R6Rig.build({ top = "tactical", topColor = "charcoal", bottom = "cargo" }, { name = w.name, weapon = { base = w.id, stars = stars, shiny = shiny } })
					anchor(model)
					model.Parent = into
					stand(model, origin + Vector3.new((col - 3) * 8, 0, -(row - 1) * 9))
					local fname = Weapons.FAMILIES[fam] and Weapons.FAMILIES[fam].name or fam
					label(model, Weapons.STARS[stars].label .. " " .. w.name .. " · " .. tostring(w.grade) .. " " .. fname .. (if w.element and w.element ~= "none" then " · " .. w.element else "") .. (if shiny then " (Shiny)" else ""), if shiny then Color3.fromRGB(255, 214, 110) else nil)
					count += 1
				end
			end
		end
	elseif what == "accessories" then
		-- every accessory on a rig of its class's preset, a row per class (and one for anyone)
		local R6Rig = require(hunter:WaitForChild("R6Rig") :: ModuleScript) :: any
		local Looks = require(hunter:WaitForChild("Looks") :: ModuleScript) :: any
		local Accessories = require(hunter:WaitForChild("Accessories") :: ModuleScript) :: any
		for row, class in Accessories.CLASSES do
			local base = Looks.DEFAULT
			local shelf = Looks.presetsIn(class)
			if shelf[1] then
				base = Looks.applyPreset(Looks.DEFAULT, shelf[1].id)
			end
			for col, a in Accessories.ofClass(class) do
				local look = table.clone(base)
				look.accessories = { a.id }
				local model = R6Rig.build(look, { name = a.name, rank = 3 })
				anchor(model)
				model.Parent = into
				stand(model, origin + Vector3.new((col - 8) * 7, 0, -(row - 1) * 10))
				label(model, a.grade .. " · " .. a.name)
				count += 1
			end
		end
	elseif what == "gates" then
		local GateVfx = require(client:WaitForChild("GateVfx") :: ModuleScript) :: any
		local radii = { 5, 6.5, 8, 10, 12, 15 }
		for r = 1, 7 do
			local red = r == 7
			local rank = if red then 4 else r
			local pos = origin + Vector3.new((r - 4) * 36, radii[rank] + 1, 0)
			local holder = Instance.new("Model")
			holder.Name = if red then "Red Gate" else RANK[rank] .. "-rank Gate"
			holder.Parent = into
			local gate = GateVfx.new(holder, CFrame.new(pos), radii[rank], { rank = rank, red = red })
			gate:open(0.05)
			gate:step(0.1) -- (open: a new Gate starts as a pinpoint)
			gate:step(0.1)
			label(holder, holder.Name .. (if red then " (sealed)" else ""), if red then Color3.fromRGB(255, 120, 120) else nil)
			count += 1
		end
		pcall(function()
			GateVfx.autoStep() -- the swirl turns in the editor while the gallery is up
		end)
	end
	return count
end

return Previews
