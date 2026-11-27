--[[
	THE MESH KIT (BitLeveling): smooth meshes made in Blender (tools/blender) laid over the
	part-built monsters, weapons and gear.

	Everything in the game is built from Parts first (Monsters, WeaponModels, R6Rig), so it
	always works. If the place has the kit, each part with a ROLE (a monster's head, a beast's
	leg, a wing, a blade, a crossguard, a pauldron, a cape...) gets the kit's mesh for that role:
	a MeshPart the part's size, colour and material, welded over it, and the part goes invisible.
	A MeshPart scales its mesh to its Size, so one mesh per role fits every part that plays it.
	A builder can ask for a role with the part's MeshRole attribute. Cloth roles (capes, scarves)
	carry Bones: they're tagged "SmartBone" and swing (client/ClothPhysics, or SmartBone itself).

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
	-- the second set, asked for by a part's MeshRole attribute (weapons and outfits set it)
	"shield_round", "shield_kite", "shield_tower", "shield_buckler", "blade_curved", "blade_wide", "axe_double",
	"spear_leaf", "trident_head", "mace_flanged", "orb_cage", "staff_crescent", "fan_blade",
	"robe_skirt", "robe_sleeve", "hood_cowl", "pauldron_spiked", "helm_winged", "helm_horned", "crown",
	"gauntlet", "boot", "belt_pouch",
	-- cloth with bones: it swings (client/ClothPhysics, SmartBone-compatible)
	"cape_skinned", "scarf_skinned",
	-- the third set: monster families (Hunter/Monsters asks for them with MeshRole)
	"head_elf", "head_dwarf", "beard", "head_insect", "mandible", "antenna", "thorax_insect", "abdomen_insect",
	"pincer", "stinger", "skull", "ribcage", "bone_limb", "tentacle", "shell_dome",
	"wing_feather_r", "wing_feather_l", "wing_insect_r", "wing_insect_l", "fin", "maw", "mane", "hoof_leg",
	"claw_hand", "trunk_bark", "leaf_crown", "root_leg", "flame_core", "crystal_cluster", "head_demon", "head_beast_maned",
}
-- the roles whose meshes carry Bones (cloth): tagged for physics when they're laid on
MeshLibrary.SKINNED = { cape_skinned = true, scarf_skinned = true }
MeshLibrary.PHYSICS_TAG = "SmartBone" -- the tag SmartBone uses, so either it or ours can drive them
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
local roleByName

function MeshLibrary.roleOf(part: BasePart, gait: string?): string?
	if part:IsA("MeshPart") or part.Transparency >= 0.95 then
		return nil
	end
	-- a builder can ask for a mesh by name (WeaponModels and R6Rig set MeshRole on a part)
	local asked = part:GetAttribute("MeshRole")
	if type(asked) == "string" and ROLE_SET[asked] then
		return asked
	end
	return roleByName(part, gait)
end

-- the role a part's name and shape give it (what an older kit, without the asked-for mesh, uses)
function roleByName(part: BasePart, gait: string?): string?
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
		if n == "Cape" or n == "Tatter" or n == "Banner" or n == "VeilBack" or n == "WrapTail" or n == "RobeTail" then
			local t = thinnest(size)
			-- a cape that hangs (thin front to back, taller than thick) swings: the cloth with bones
			if t == "z" and size.Y > size.Z * 4 then
				return "cape_skinned"
			end
			return if t == "x" or t == "z" then "cloth_" .. t else nil
		elseif n == "Scarf" or n == "Sash" then
			return if size.Y > size.X and size.Y > size.Z then "scarf_skinned" else nil
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
		return "cape_skinned"
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

-- a skinned mesh resized: its Bones move with the geometry (a MeshPart scales its mesh to its
-- Size, but not the Bones in it). Each bone keeps its turn; its place relative to the part scales.
function MeshLibrary.fitBones(m: BasePart, fromSize: Vector3, toSize: Vector3)
	local scale = Vector3.new(toSize.X / math.max(fromSize.X, 1e-4), toSize.Y / math.max(fromSize.Y, 1e-4), toSize.Z / math.max(fromSize.Z, 1e-4))
	local function walk(parent: Instance, oldRel: CFrame, newRel: CFrame)
		for _, b in parent:GetChildren() do
			if b:IsA("Bone") then
				local relOld = oldRel * b.CFrame
				local relNew = CFrame.new(relOld.Position * scale) * relOld.Rotation
				b.CFrame = newRel:Inverse() * relNew
				walk(b, relOld, relNew)
			end
		end
	end
	walk(m, CFrame.identity, CFrame.identity)
end

-- cloth: tagged for bone physics, the way SmartBone expects (its tag, and "Roots": the root bones)
function MeshLibrary.tagCloth(m: BasePart)
	local roots = {}
	for _, b in m:GetChildren() do
		if b:IsA("Bone") then
			table.insert(roots, b.Name)
		end
	end
	if #roots == 0 then
		return
	end
	m:SetAttribute("Roots", table.concat(roots, ","))
	pcall(function()
		m:AddTag(MeshLibrary.PHYSICS_TAG)
	end)
end

-- lay the kit over a built model: every part with a role gets its mesh
function MeshLibrary.dress(model: Instance, gait: string?): number
	if not MeshLibrary.ready() then
		return 0
	end
	gait = gait or (model:GetAttribute("Gait") :: string?)
	local done = 0
	-- a socket (a part with MeshId, WeaponModels) is one mesh drawn, until the kit has it, by
	-- the parts that carry MeshCover = its id: dress the sockets first, then hide what they cover
	local parts = {}
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and not p:GetAttribute("Dressed") then
			table.insert(parts, p)
		end
	end
	table.sort(parts, function(a, b)
		return (a:GetAttribute("MeshId") ~= nil) and (b:GetAttribute("MeshId") == nil)
	end)
	local covered: { [string]: boolean } = {}
	for _, p in model:GetDescendants() do
		local id = p:IsA("BasePart") and p:GetAttribute("Dressed") and p:GetAttribute("MeshId")
		if type(id) == "string" then
			covered[id] = true
		end
	end
	for _, p in parts do
		local cover = p:GetAttribute("MeshCover")
		if type(cover) == "string" and covered[cover] then
			p.Transparency = 1
			p:SetAttribute("Dressed", true)
			continue
		end
		local role = MeshLibrary.roleOf(p, gait)
		local t = role and template(role)
		if role and not t and p:GetAttribute("MeshRole") ~= nil then
			-- an older kit without the asked-for mesh: the part's name still finds one
			role = roleByName(p, gait)
			t = role and template(role)
		end
		if t then
			local m = t:Clone()
			local fromSize = m.Size
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
			if MeshLibrary.SKINNED[role] then
				MeshLibrary.fitBones(m, fromSize, p.Size)
				MeshLibrary.tagCloth(m)
			end
			m.Parent = p.Parent
			p.Transparency = 1
			p:SetAttribute("Dressed", true)
			local id = p:GetAttribute("MeshId")
			if type(id) == "string" then
				covered[id] = true
				-- (a socket is drawn tiny by its FallbackShape; its mesh shows it whole)
				m.Transparency = 0
			end
			done += 1
		end
	end
	return done
end

return MeshLibrary
