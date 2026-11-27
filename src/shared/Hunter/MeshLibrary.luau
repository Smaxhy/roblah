--[[
	THE MESH KIT (BitLeveling): smooth meshes made in Blender (tools/blender) laid over the
	part-built monsters, weapons and gear.

	Everything in the game is built from Parts first (Monsters, WeaponModels, R6Rig), so it
	always works. If the place has the kit, each part with a ROLE (a monster's head, a beast's
	leg, a wing, a blade, a crossguard, a pauldron, a cape...) gets the kit's mesh for that role:
	a MeshPart the part's size, colour and material, welded over it, and the part goes invisible.
	A MeshPart scales its mesh to its Size, so one mesh per role fits every part that plays it.

	Where the kit comes from (the first that's there wins):
	  1. ReplicatedStorage.BitLevelingMeshKit: a Model of MeshParts named by role. The Studio
	     plugin's "Register mesh kit" puts it there after you import tools/blender/out/kit.fbx
	     with Studio's 3D Importer (no API key needed), and it saves with the place.
	  2. MeshAssets.kit, an asset id (tools/blender/upload.py uploads the kit with Open Cloud and
	     writes the id): the server loads it with InsertService and puts it in (1).
	  3. Nothing: everything stays parts, as before.

		MeshLibrary.roleOf(part, gait?)    -- the role a part plays, or nil (shared with the
		                                      Blender previews: tools/blender/dump_layout.luau)
		MeshLibrary.dress(model)            -- lay the kit over a built model (no kit: nothing)
		MeshLibrary.ready()                 -- is the kit here?
		MeshLibrary.load()                  -- server: fetch the kit by asset id if it isn't
]]

local MeshLibrary = {}

MeshLibrary.KIT_NAME = "BitLevelingMeshKit"

-- every role the Blender kit makes (tools/blender/kit.py builds one mesh per entry)
MeshLibrary.ROLES = {
	-- creatures
	"head_biped", "head_beast", "head_serpent", "head_golem", "snout", "ear", "horn_x", "horn_y", "horn_z",
	"torso_biped", "torso_golem", "body_quad", "body_flyer", "carapace", "cephalothorax", "abdomen", "slime",
	"arm", "leg", "arm_golem", "leg_golem", "leg_quad", "leg_insect", "sleeve",
	"tail", "wing_r", "wing_l", "segment", "neck", "robe", "hood_open", "crystal_x", "crystal_y", "crystal_z",
	"core_gem", "armor_plate", "club_head", "axe_head", "scythe_blade", "spear_point",
	-- weapons
	"blade", "blade_tip", "guard", "rod_x", "rod_y", "rod_z", "hammer_head", "shield_x", "shield_z",
	-- gear on the R6 rig
	"cloth_x", "cloth_z", "pauldron", "cuirass", "helm",
}
local ROLE_SET = {}
for _, r in MeshLibrary.ROLES do
	ROLE_SET[r] = true
end

local function longest(v: Vector3): string
	if v.X >= v.Y and v.X >= v.Z then
		return "x"
	elseif v.Y >= v.Z then
		return "y"
	end
	return "z"
end
local function thinnest(v: Vector3): string
	if v.X <= v.Y and v.X <= v.Z then
		return "x"
	elseif v.Y <= v.Z then
		return "y"
	end
	return "z"
end

-- the role a part plays. `gait` is the monster's (nil on a rig). Weapon parts are "Weapon<Name>".
function MeshLibrary.roleOf(part: BasePart, gait: string?): string?
	local raw = part.Name
	if part:IsA("MeshPart") or part.Transparency >= 0.95 then
		return nil
	end
	local size = part.Size
	-- a weapon's pieces
	if string.sub(raw, 1, 6) == "Weapon" then
		local n = string.gsub(string.sub(raw, 7), "[%d%-]+$", "")
		if n == "Blade" then
			return "blade"
		elseif n == "Point" then
			return "blade_tip"
		elseif n == "Guard" or n == "Tsuba" then
			return if n == "Guard" then "guard" else nil
		elseif n == "Grip" or n == "Shaft" or n == "Haft" or n == "Handle" or n == "Wand" or n == "Baton" or n == "Limb" then
			return "rod_" .. longest(size)
		elseif n == "Head" then
			return "hammer_head"
		elseif n == "Shield" then
			local t = thinnest(size)
			return if t == "x" or t == "z" then "shield_" .. t else nil
		elseif n == "Bit" then
			return "axe_head"
		elseif n == "Crescent" then
			return "scythe_blade"
		end
		return nil
	end
	local n = string.gsub(raw, "%d+$", "")
	if gait == nil then
		-- the R6 rig's gear
		if n == "Cape" or n == "Tatter" or n == "Banner" or n == "VeilBack" or n == "WrapTail" then
			local t = thinnest(size)
			return if t == "x" or t == "z" then "cloth_" .. t else nil
		elseif n == "Pauldron" then
			return "pauldron"
		elseif n == "Cuirass" then
			return "cuirass"
		elseif n == "Helm" then
			return "helm"
		elseif n == "Horn" or n == "HornTip" then
			return "horn_" .. longest(size)
		elseif n == "Shield" then
			local t = thinnest(size)
			return if t == "x" or t == "z" then "shield_" .. t else nil
		elseif n == "Sheath" or n == "Staff" or n == "BannerPole" or n == "Quiver" then
			return "rod_" .. longest(size)
		elseif n == "Crystal" then
			return "crystal_" .. longest(size)
		end
		return nil
	end
	-- a monster's
	if n == "Head" then
		if gait == "biped" or gait == "float" then
			return "head_biped"
		elseif gait == "golem" then
			return "head_golem"
		elseif gait == "serpent" then
			return if size.Z > size.Y * 1.4 then "head_serpent" else "head_biped"
		end
		return "head_beast"
	elseif n == "Torso" then
		return if gait == "golem" then "torso_golem" else "torso_biped"
	elseif n == "Body" then
		if gait == "quad" then
			return "body_quad"
		elseif gait == "crawler" then
			return "carapace"
		elseif gait == "spider" then
			return "cephalothorax"
		elseif gait == "flyer" then
			return "body_flyer"
		elseif gait == "blob" then
			return "slime"
		end
		return nil
	elseif n == "Snout" then
		return "snout"
	elseif n == "Ear" then
		return "ear"
	elseif n == "Horn" or n == "Tusk" then
		return "horn_" .. longest(size)
	elseif n == "ArmR" or n == "ArmL" then
		if gait == "golem" then
			return "arm_golem"
		elseif gait == "float" then
			return "sleeve"
		end
		return "arm"
	elseif n == "LegR" or n == "LegL" then
		if string.match(raw, "%d$") then
			return if gait == "quad" then "leg_quad" else "leg_insect"
		end
		return if gait == "golem" then "leg_golem" else "leg"
	elseif n == "Tail" then
		return "tail"
	elseif n == "WingR" then
		return "wing_r"
	elseif n == "WingL" then
		return "wing_l"
	elseif n == "Seg" then
		return "segment"
	elseif n == "Neck" then
		return "neck"
	elseif n == "Abdomen" then
		return "abdomen"
	elseif n == "Robe" then
		return "robe"
	elseif n == "Hood" then
		return "hood_open"
	elseif n == "Crystal" or n == "Frost" then
		return "crystal_" .. longest(size)
	elseif n == "Core" then
		return "core_gem"
	elseif n == "Plate" then
		return "armor_plate"
	elseif n == "Cape" then
		return "cloth_z"
	elseif n == "ClubHead" then
		return "club_head"
	elseif n == "Club" or n == "Haft" or n == "Shaft" then
		return "rod_" .. longest(size)
	elseif n == "Blade" then
		return if size.Z > size.Y then "scythe_blade" else "axe_head"
	elseif n == "Point" then
		return "spear_point"
	end
	return nil
end

-- ── the kit ──────────────────────────────────────────────────────────────────
local kitCache: Model? = nil
local templates: { [string]: MeshPart } = {}
local function services()
	local ok, rs = pcall(function()
		return game:GetService("ReplicatedStorage")
	end)
	return if ok then rs else nil
end

local handed: Model? = nil
function MeshLibrary.kit(): Model?
	if handed then
		return handed
	end
	if kitCache and kitCache.Parent then
		return kitCache
	end
	local rs = services()
	local ok, k = pcall(function()
		return rs and rs:FindFirstChild(MeshLibrary.KIT_NAME)
	end)
	kitCache = if ok and k and k:IsA("Model") then k else nil
	return kitCache
end

-- use this kit (the Studio plugin's previews, the tests); nil goes back to the place's own
function MeshLibrary.setKit(kit: Model?)
	handed = kit
	table.clear(templates)
end

function MeshLibrary.ready(): boolean
	return MeshLibrary.kit() ~= nil
end

-- the kit's MeshPart for a role (the importer may nest meshes in Models: search descendants)
local function template(role: string): MeshPart?
	local kit = MeshLibrary.kit()
	if not kit then
		return nil
	end
	local t = templates[role]
	if t and t.Parent then
		return t
	end
	for _, d in kit:GetDescendants() do
		if d:IsA("MeshPart") and d.Name == role then
			templates[role] = d
			return d
		end
	end
	return nil
end

-- server: fetch the kit by asset id (MeshAssets.kit) if the place doesn't have it
function MeshLibrary.load(): boolean
	if MeshLibrary.ready() then
		return true
	end
	local okIds, ids = pcall(function()
		return require(script.Parent:WaitForChild("MeshAssets", 2) :: ModuleScript)
	end)
	local id = okIds and type(ids) == "table" and tonumber(ids.kit) or 0
	if not id or id <= 0 then
		return false
	end
	local ok, asset = pcall(function()
		return game:GetService("InsertService"):LoadAsset(id)
	end)
	if not ok or not asset then
		warn("[BitLeveling] the mesh kit (asset " .. tostring(id) .. ") didn't load; parts are used instead: " .. tostring(asset))
		return false
	end
	local kit = Instance.new("Model")
	kit.Name = MeshLibrary.KIT_NAME
	for _, d in asset:GetDescendants() do
		if d:IsA("MeshPart") and ROLE_SET[d.Name] then
			d.Anchored = true
			d.Parent = kit
		end
	end
	asset:Destroy()
	local rs = services()
	if rs then
		kit.Parent = rs
	end
	kitCache = kit
	return true
end

-- lay the kit over a built model: every part with a role gets its mesh
function MeshLibrary.dress(model: Instance, gait: string?): number
	if not MeshLibrary.ready() then
		return 0
	end
	gait = gait or (model:GetAttribute("Gait") :: string?)
	local done = 0
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and not p:GetAttribute("Dressed") then
			local role = MeshLibrary.roleOf(p, gait)
			local t = role and template(role)
			if t then
				local m = t:Clone()
				m.Name = p.Name .. "Mesh"
				m.Anchored = false
				m.CanCollide = false
				m.CanTouch = false
				m.CanQuery = false
				m.Massless = true
				m.Size = p.Size
				m.CFrame = p.CFrame
				m.Color = p.Color
				m.Material = p.Material
				m.Reflectance = p.Reflectance
				m.Transparency = p.Transparency
				m.CastShadow = p.CastShadow
				local w = Instance.new("WeldConstraint")
				w.Part0 = p
				w.Part1 = m
				w.Parent = m
				m.Parent = p.Parent
				p.Transparency = 1
				p:SetAttribute("Dressed", true)
				done += 1
			end
		end
	end
	return done
end

return MeshLibrary
