--[[
	THE MESH KIT IN THE PLACE (BitLeveling Studio plugin).

	tools/blender makes kit.fbx: one mesh per role (Hunter/MeshLibrary). Two ways to get it in:
	  - Studio's 3D Importer (Home > Import 3D): import tools/blender/out/kit.fbx, select what it
	    made, and press "Register selected as mesh kit". Studio uploads the meshes to your account
	    as part of importing; this copies the MeshParts it made into
	    ReplicatedStorage.BitLevelingMeshKit, which saves with the place.
	  - An asset id (tools/blender/upload.py writes it into Hunter/MeshAssets): "Load kit by id".

		Kit.status(game, roles)                 -> { present, found, missing = {..} }
		Kit.register(game, roots, roles)        -> { found, missing }
		Kit.loadAsset(game, id, roles, insert)  -> { found, missing }
		Kit.remove(game)
]]

local Kit = {}

local NAME = "BitLevelingMeshKit"

local function roleSet(roles: { string }): { [string]: boolean }
	local s = {}
	for _, r in roles do
		s[r] = true
	end
	return s
end

-- the importer can append a suffix or nest meshes in models; match by the leading role name
local function roleOf(name: string, set: { [string]: boolean }): string?
	if set[name] then
		return name
	end
	local base = string.match(name, "^([%w_]-)[%.%s%-]%d+$") or string.match(name, "^([%w_]+)_%d+$")
	if base and set[base] then
		return base
	end
	return nil
end

function Kit.status(game: any, roles: { string }): any
	local rs = game:GetService("ReplicatedStorage")
	local kit = rs:FindFirstChild(NAME)
	local have = {}
	if kit then
		for _, d in kit:GetDescendants() do
			if d:IsA("MeshPart") then
				have[d.Name] = true
			end
		end
	end
	local missing, found = {}, 0
	for _, r in roles do
		if have[r] then
			found += 1
		else
			table.insert(missing, r)
		end
	end
	return { present = kit ~= nil, found = found, missing = missing }
end

local function store(game: any, meshes: { [string]: MeshPart }, roles: { string }): any
	local rs = game:GetService("ReplicatedStorage")
	local old = rs:FindFirstChild(NAME)
	if old then
		old:Destroy()
	end
	local kit = Instance.new("Model")
	kit.Name = NAME
	local i = 0
	for role, m in meshes do
		local c = m:Clone()
		for _, child in c:GetChildren() do
			if not child:IsA("SurfaceAppearance") then
				child:Destroy() -- (welds and scripts from wherever it was imported to)
			end
		end
		c.Name = role
		c.Anchored = true
		c.CanCollide = false
		c.Transparency = 0
		c.CFrame = CFrame.new((i % 10) * 3, 0, (i // 10) * 3)
		c.Parent = kit
		i += 1
	end
	kit.Parent = rs
	local st = Kit.status(game, roles)
	return { found = st.found, missing = st.missing }
end

function Kit.register(game: any, roots: { Instance }, roles: { string }): any
	local set = roleSet(roles)
	local meshes: { [string]: MeshPart } = {}
	for _, root in roots do
		local list = root:GetDescendants()
		table.insert(list, root)
		for _, d in list do
			if d:IsA("MeshPart") then
				local r = roleOf(d.Name, set)
				if r and not meshes[r] then
					meshes[r] = d
				end
			end
		end
	end
	return store(game, meshes, roles)
end

function Kit.loadAsset(game: any, id: number, roles: { string }, insert: any?): any
	local svc = insert or game:GetService("InsertService")
	local model = svc:LoadAsset(id)
	local res = Kit.register(game, { model }, roles)
	model:Destroy()
	return res
end

function Kit.remove(game: any)
	local rs = game:GetService("ReplicatedStorage")
	local kit = rs:FindFirstChild(NAME)
	if kit then
		kit:Destroy()
	end
end

return Kit
