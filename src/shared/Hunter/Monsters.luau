--[[
	THE MONSTERS OF THE LIVE CITY (BitLeveling, ORIGINAL designs; goblins, orcs, high orcs and
	ice bears are monster types canon's Gates have, the rest are this game's own).

	(Shared, so the client can build them too: the opening cutscene, the title screen. The live
	city's server builds them through server/HunterLive/Monsters, which forwards here.)

	Four kinds a rank, 24 in all. Each is built from Parts on a Humanoid (HipHeight carries the
	body), with Motor6D joints from the root to every limb that moves, so the client can animate
	them (client/MonsterAnim.luau: legs swing with speed, wings flap, tails and serpents sway,
	slimes squash). Attributes on the model: Gait, Rank, Kind, Incident. If the place has the
	Blender mesh kit (Hunter/MeshLibrary), smooth meshes are laid over the parts.

		local model, hum = Monsters.build(kindId)
		Monsters.KINDS[rank] = { kind ids }
]]

local MeshLibrary = require(script.Parent:WaitForChild("MeshLibrary"))

local Monsters = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

-- id = { name, rank, hp, size, speed, dmg, gait, body colour, accent, eye, extras }
Monsters.DEFS = {
	goblin = { name = "Goblin", rank = 1, hp = 60, size = 0.7, speed = 17, dmg = 8, gait = "biped", c = rgb(96, 130, 70), a = rgb(110, 80, 50), eye = rgb(255, 220, 80), x = { club = true, ears = true } },
	giant_rat = { name = "Giant Rat", rank = 1, hp = 45, size = 0.6, speed = 20, dmg = 6, gait = "quad", c = rgb(90, 80, 74), a = rgb(200, 150, 150), eye = rgb(255, 60, 60), x = { tail = true, ears = true } },
	cave_bat = { name = "Cave Bat", rank = 1, hp = 35, size = 0.7, speed = 22, dmg = 5, gait = "flyer", c = rgb(50, 44, 54), a = rgb(80, 60, 70), eye = rgb(255, 200, 80), x = { wings = true } },
	slime = { name = "Mana Slime", rank = 1, hp = 70, size = 0.9, speed = 10, dmg = 7, gait = "blob", c = rgb(80, 200, 160), a = rgb(140, 255, 210), eye = rgb(20, 40, 30), x = {} },
	hobgoblin = { name = "Hobgoblin", rank = 2, hp = 130, size = 0.95, speed = 16, dmg = 14, gait = "biped", c = rgb(120, 110, 70), a = rgb(90, 90, 96), eye = rgb(255, 170, 60), x = { spear = true, armor = true, ears = true } },
	beetle = { name = "Armoured Beetle", rank = 2, hp = 150, size = 1, speed = 13, dmg = 13, gait = "crawler", c = rgb(60, 66, 90), a = rgb(140, 220, 255), eye = rgb(140, 220, 255), x = { horn = true } },
	spider = { name = "Giant Spider", rank = 2, hp = 120, size = 1, speed = 19, dmg = 15, gait = "spider", c = rgb(40, 36, 40), a = rgb(170, 40, 40), eye = rgb(255, 40, 40), x = {} },
	dire_wolf = { name = "Dire Wolf", rank = 2, hp = 110, size = 1, speed = 24, dmg = 14, gait = "quad", c = rgb(80, 78, 84), a = rgb(200, 200, 210), eye = rgb(255, 220, 120), x = { tail = true, ears = true, snout = true } },
	orc = { name = "Orc", rank = 3, hp = 300, size = 1.35, speed = 15, dmg = 24, gait = "biped", c = rgb(92, 120, 70), a = rgb(120, 110, 100), eye = rgb(255, 80, 60), x = { axe = true, tusks = true } },
	lizardman = { name = "Lizardman", rank = 3, hp = 260, size = 1.2, speed = 18, dmg = 22, gait = "biped", c = rgb(70, 120, 90), a = rgb(200, 190, 120), eye = rgb(255, 230, 60), x = { tail = true, spear = true, snout = true } },
	troll = { name = "Cave Troll", rank = 3, hp = 380, size = 1.6, speed = 12, dmg = 28, gait = "biped", c = rgb(110, 110, 96), a = rgb(80, 70, 60), eye = rgb(255, 150, 60), x = { club = true, hunch = true } },
	naga = { name = "Naga", rank = 3, hp = 280, size = 1.2, speed = 16, dmg = 24, gait = "serpent", c = rgb(60, 130, 120), a = rgb(220, 200, 120), eye = rgb(255, 240, 120), x = { torso = true, spear = true } },
	ice_bear = { name = "Ice Bear", rank = 4, hp = 560, size = 1.6, speed = 18, dmg = 40, gait = "quad", c = rgb(226, 232, 240), a = rgb(170, 210, 240), eye = rgb(120, 200, 255), x = { ears = true, snout = true, frost = true } },
	ogre = { name = "Ogre", rank = 4, hp = 700, size = 2, speed = 13, dmg = 46, gait = "biped", c = rgb(150, 120, 90), a = rgb(90, 70, 50), eye = rgb(255, 120, 60), x = { club = true, hunch = true, tusks = true } },
	wraith = { name = "Wraith", rank = 4, hp = 420, size = 1.5, speed = 20, dmg = 38, gait = "float", c = rgb(60, 60, 90), a = rgb(150, 120, 255), eye = rgb(170, 140, 255), x = { robe = true, scythe = true } },
	iron_golem = { name = "Iron Golem", rank = 4, hp = 820, size = 1.9, speed = 11, dmg = 44, gait = "golem", c = rgb(110, 112, 120), a = rgb(255, 150, 60), eye = rgb(255, 150, 60), x = { rivets = true } },
	warlord = { name = "High Orc Warlord", rank = 5, hp = 1200, size = 2.1, speed = 15, dmg = 70, gait = "biped", c = rgb(80, 100, 60), a = rgb(140, 40, 30), eye = rgb(255, 60, 40), x = { axe = true, armor = true, tusks = true, cape = true } },
	stone_golem = { name = "Stone Golem", rank = 5, hp = 1500, size = 2.5, speed = 10, dmg = 76, gait = "golem", c = rgb(120, 116, 110), a = rgb(255, 170, 60), eye = rgb(255, 170, 60), x = { crystals = true } },
	wyvern = { name = "Wyvern", rank = 5, hp = 1000, size = 2.2, speed = 22, dmg = 68, gait = "flyer", c = rgb(80, 110, 80), a = rgb(200, 190, 130), eye = rgb(255, 230, 80), x = { wings = true, tail = true, snout = true } },
	minotaur = { name = "Minotaur", rank = 5, hp = 1300, size = 2.2, speed = 17, dmg = 74, gait = "biped", c = rgb(110, 76, 56), a = rgb(230, 220, 200), eye = rgb(255, 60, 60), x = { horns = true, axe = true, snout = true } },
	dragonkin = { name = "Dragon-kin", rank = 6, hp = 2800, size = 3, speed = 18, dmg = 120, gait = "quad", c = rgb(46, 34, 66), a = rgb(255, 120, 60), eye = rgb(255, 60, 90), x = { wings = true, tail = true, horns = true, snout = true } },
	colossus = { name = "Colossus", rank = 6, hp = 3600, size = 4, speed = 10, dmg = 140, gait = "golem", c = rgb(150, 140, 120), a = rgb(120, 200, 255), eye = rgb(120, 200, 255), x = { crystals = true, rivets = true } },
	abyss_serpent = { name = "Abyssal Serpent", rank = 6, hp = 2600, size = 3, speed = 19, dmg = 115, gait = "serpent", c = rgb(30, 40, 70), a = rgb(80, 220, 255), eye = rgb(80, 255, 255), x = { horns = true } },
	hollow_king = { name = "Hollow King", rank = 6, hp = 2400, size = 2.6, speed = 16, dmg = 125, gait = "float", c = rgb(30, 26, 40), a = rgb(255, 210, 90), eye = rgb(255, 60, 60), x = { robe = true, crown = true, staff = true } },
}

Monsters.KINDS = { {}, {}, {}, {}, {}, {} }
for id, d in Monsters.DEFS do
	table.insert(Monsters.KINDS[d.rank], id)
end
for _, list in Monsters.KINDS do
	table.sort(list)
end

local function newPart(model: Model, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, shape: Enum.PartType?): BasePart
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.CanCollide = false
	p.CanQuery = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Parent = model
	return p
end

-- a limb on a joint: the joint sits at `joint` (in the root's space), the limb hangs from it
local function limb(model: Model, root: BasePart, name: string, size: Vector3, joint: Vector3, hangOffset: Vector3, color: Color3, material: Enum.Material?, shape: Enum.PartType?): BasePart
	local cf = root.CFrame * CFrame.new(joint) * CFrame.new(hangOffset)
	local p = newPart(model, name, size, cf, color, material, shape)
	local m = Instance.new("Motor6D")
	m.Name = name .. "Joint"
	m.Part0 = root
	m.Part1 = p
	m.C0 = CFrame.new(joint)
	m.C1 = CFrame.new(-hangOffset)
	m.Parent = root
	return p
end

local function weld(root: BasePart, p: BasePart)
	local w = Instance.new("WeldConstraint")
	w.Part0 = root
	w.Part1 = p
	w.Parent = p
end

function Monsters.build(kind: string): (Model, Humanoid)
	local d = Monsters.DEFS[kind] or Monsters.DEFS.goblin
	local s = d.size
	local x = d.x
	local model = Instance.new("Model")
	model.Name = d.name
	local rootH = if d.gait == "crawler" or d.gait == "spider" or d.gait == "blob" or d.gait == "serpent" then 1.2 else 2
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, rootH, 1.4) * s
	root.CFrame = CFrame.new(0, (rootH / 2 + 2) * s, 0)
	root.Transparency = 1
	root.CanCollide = true
	root.Parent = model
	model.PrimaryPart = root
	local R = root.CFrame
	local function body(name: string, size: Vector3, offset: Vector3, color: Color3?, material: Enum.Material?, shape: Enum.PartType?, rot: CFrame?)
		local p = newPart(model, name, size * s, R * CFrame.new(offset * s) * (rot or CFrame.identity), color or d.c, material, shape)
		weld(root, p)
		return p
	end
	local function eyes(y: number, z: number, gap: number, r: number?)
		for _, side in { -1, 1 } do
			body("Eye", Vector3.one * (r or 0.22), Vector3.new(side * gap, y, z), d.eye, Enum.Material.Neon, Enum.PartType.Ball)
		end
	end
	local gait = d.gait
	if gait == "biped" then
		local hunch = if x.hunch then 0.35 else 0
		body("Torso", Vector3.new(2, 2.2, 1.2), Vector3.new(0, 0.1, -hunch), nil, nil, nil, CFrame.Angles(math.rad(-hunch * 40), 0, 0))
		local head = body("Head", Vector3.new(1.3, 1.2, 1.2), Vector3.new(0, 1.9 - hunch, -0.2 - hunch * 1.2))
		local _ = head
		eyes(1.95 - hunch, -0.82 - hunch * 1.2, 0.3)
		if x.snout then
			body("Snout", Vector3.new(0.7, 0.5, 0.6), Vector3.new(0, 1.7 - hunch, -1 - hunch * 1.2), d.c)
		end
		if x.tusks then
			for _, sd in { -1, 1 } do
				body("Tusk", Vector3.new(0.12, 0.4, 0.12), Vector3.new(sd * 0.32, 1.45 - hunch, -0.85 - hunch * 1.2), rgb(240, 232, 210))
			end
		end
		if x.ears then
			for _, sd in { -1, 1 } do
				body("Ear", Vector3.new(0.6, 0.18, 0.3), Vector3.new(sd * 0.85, 2.1 - hunch, -0.2 - hunch), d.c, nil, nil, CFrame.Angles(0, 0, math.rad(sd * 25)))
			end
		end
		if x.horns then
			for _, sd in { -1, 1 } do
				body("Horn", Vector3.new(0.25, 0.9, 0.25), Vector3.new(sd * 0.75, 2.7 - hunch, -0.2), d.a, nil, nil, CFrame.Angles(0, 0, math.rad(-sd * 35)))
			end
		end
		if x.armor then
			body("Plate", Vector3.new(2.15, 1.3, 1.35), Vector3.new(0, 0.4, -hunch), d.a, Enum.Material.Metal)
		end
		if x.cape then
			body("Cape", Vector3.new(2.1, 2.6, 0.12), Vector3.new(0, -0.1, 0.72), d.a, Enum.Material.Fabric)
		end
		local armR = limb(model, root, "ArmR", Vector3.new(0.8, 2.2, 0.8) * s, Vector3.new(1.45, 1, -hunch) * s, Vector3.new(0, -1.1, 0) * s, d.c)
		limb(model, root, "ArmL", Vector3.new(0.8, 2.2, 0.8) * s, Vector3.new(-1.45, 1, -hunch) * s, Vector3.new(0, -1.1, 0) * s, d.c)
		limb(model, root, "LegR", Vector3.new(0.9, 2, 0.9) * s, Vector3.new(0.55, -1, 0) * s, Vector3.new(0, -1, 0) * s, d.a)
		limb(model, root, "LegL", Vector3.new(0.9, 2, 0.9) * s, Vector3.new(-0.55, -1, 0) * s, Vector3.new(0, -1, 0) * s, d.a)
		-- what it carries, in the right hand
		local hand = armR.CFrame * CFrame.new(0, -1.1 * s, -0.2 * s)
		local function held(name, size, off, color, material)
			local p = newPart(model, name, size * s, hand * CFrame.new(off * s), color, material)
			local w = Instance.new("WeldConstraint")
			w.Part0 = armR
			w.Part1 = p
			w.Parent = p
		end
		if x.club then
			held("Club", Vector3.new(0.4, 0.4, 2.2), Vector3.new(0, 0, -1), rgb(100, 72, 48), Enum.Material.Wood)
			held("ClubHead", Vector3.new(0.7, 0.7, 0.9), Vector3.new(0, 0, -2.1), rgb(90, 64, 44), Enum.Material.Wood)
		elseif x.axe then
			held("Haft", Vector3.new(0.25, 0.25, 2.6), Vector3.new(0, 0, -1.2), rgb(80, 60, 40), Enum.Material.Wood)
			held("Blade", Vector3.new(0.12, 1.1, 0.9), Vector3.new(0, 0.4, -2.3), rgb(170, 170, 176), Enum.Material.Metal)
		elseif x.spear then
			held("Shaft", Vector3.new(0.18, 0.18, 4), Vector3.new(0, 0, -1.6), rgb(90, 70, 50), Enum.Material.Wood)
			held("Point", Vector3.new(0.12, 0.4, 0.7), Vector3.new(0, 0, -3.8), rgb(200, 200, 206), Enum.Material.Metal)
		end
		if x.tail then
			limb(model, root, "Tail", Vector3.new(0.4, 0.4, 2) * s, Vector3.new(0, -0.8, 0.6) * s, Vector3.new(0, 0, 1) * s, d.c)
		end
	elseif gait == "quad" or gait == "crawler" or gait == "spider" then
		local long = if gait == "quad" then 4.4 else 3.6
		body("Body", Vector3.new(if gait == "spider" then 2.2 else 2.6, if gait == "quad" then 2 else 1.3, long), Vector3.new(0, 0, 0), nil, if gait == "crawler" then Enum.Material.Metal else nil)
		body("Head", Vector3.new(1.7, if gait == "quad" then 1.5 else 0.9, 1.6), Vector3.new(0, if gait == "quad" then 0.7 else 0.1, -long / 2 - 0.6))
		eyes(if gait == "quad" then 1 else 0.3, -long / 2 - 1.42, 0.45, if gait == "spider" then 0.3 else 0.25)
		if gait == "spider" then
			body("Abdomen", Vector3.new(2.6, 2, 2.6), Vector3.new(0, 0.4, 2.4), d.c, nil, Enum.PartType.Ball)
			body("Mark", Vector3.new(0.9, 0.9, 0.2), Vector3.new(0, 1.3, 2.4), d.a, Enum.Material.Neon)
		end
		if x.snout then
			body("Snout", Vector3.new(0.9, 0.7, 0.9), Vector3.new(0, 0.4, -long / 2 - 1.7), d.c)
		end
		if x.ears then
			for _, sd in { -1, 1 } do
				body("Ear", Vector3.new(0.35, 0.5, 0.25), Vector3.new(sd * 0.55, 1.65, -long / 2 - 0.4), d.c)
			end
		end
		if x.horn then
			body("Horn", Vector3.new(0.3, 1.2, 0.3), Vector3.new(0, 1, -long / 2 - 1.1), d.a, Enum.Material.Neon, nil, CFrame.Angles(math.rad(-40), 0, 0))
		end
		if x.horns then
			for _, sd in { -1, 1 } do
				body("Horn", Vector3.new(0.3, 1.4, 0.3), Vector3.new(sd * 0.6, 1.8, -long / 2 - 0.2), d.a, nil, nil, CFrame.Angles(math.rad(30), 0, math.rad(-sd * 20)))
			end
		end
		if x.frost then
			for k = -1, 1 do
				body("Frost", Vector3.new(0.4, 0.8, 0.4), Vector3.new(k * 0.6, 1.2, k * 0.8), d.a, Enum.Material.Ice)
			end
		end
		local legs = if gait == "spider" then 4 elseif gait == "crawler" then 3 else 2
		local legLen = if gait == "quad" then 2.6 else 1.4
		for k = 1, legs do
			local z = -long / 2 + 0.6 + (k - 1) * (long - 1.2) / math.max(1, legs - 1)
			for _, sd in { -1, 1 } do
				local splay = if gait == "quad" then 0.9 else 1.6
				limb(model, root, "Leg" .. (if sd < 0 then "L" else "R") .. k, Vector3.new(0.55, legLen, 0.55) * s, Vector3.new(sd * splay, -0.4, z) * s, Vector3.new(sd * (if gait == "quad" then 0 else 0.4), -legLen / 2, 0) * s, if gait == "quad" then d.c else rgb(30, 30, 34))
			end
		end
		if x.tail then
			limb(model, root, "Tail", Vector3.new(0.45, 0.45, 2.4) * s, Vector3.new(0, 0.4, long / 2) * s, Vector3.new(0, 0, 1.2) * s, d.c)
		end
		if x.wings then
			limb(model, root, "WingR", Vector3.new(4.5, 0.2, 2.6) * s, Vector3.new(1.2, 1, 0) * s, Vector3.new(2.25, 0, 0) * s, d.a)
			limb(model, root, "WingL", Vector3.new(4.5, 0.2, 2.6) * s, Vector3.new(-1.2, 1, 0) * s, Vector3.new(-2.25, 0, 0) * s, d.a)
		end
	elseif gait == "flyer" then
		body("Body", Vector3.new(1.4, 1.2, 2.4), Vector3.new(0, 1.5, 0))
		body("Head", Vector3.new(1, 0.9, 1), Vector3.new(0, 1.8, -1.5))
		eyes(1.9, -2.02, 0.25)
		if x.snout then
			body("Snout", Vector3.new(0.6, 0.5, 0.9), Vector3.new(0, 1.7, -2.3))
		end
		limb(model, root, "WingR", Vector3.new(4, 0.15, 2) * s, Vector3.new(0.7, 1.7, 0) * s, Vector3.new(2, 0, 0) * s, d.a)
		limb(model, root, "WingL", Vector3.new(4, 0.15, 2) * s, Vector3.new(-0.7, 1.7, 0) * s, Vector3.new(-2, 0, 0) * s, d.a)
		if x.tail then
			limb(model, root, "Tail", Vector3.new(0.35, 0.35, 2.6) * s, Vector3.new(0, 1.4, 1.2) * s, Vector3.new(0, 0, 1.3) * s, d.c)
		end
	elseif gait == "blob" then
		local core = body("Body", Vector3.new(2.4, 2, 2.4), Vector3.new(0, -0.4, 0), d.c, Enum.Material.Glass, Enum.PartType.Ball)
		core.Transparency = 0.25
		limb(model, root, "Nucleus", Vector3.new(0.9, 0.9, 0.9) * s, Vector3.new(0, -0.3, 0) * s, Vector3.zero, d.a, Enum.Material.Neon, Enum.PartType.Ball) -- it bobs inside (client)
		eyes(0.1, -1.1, 0.35, 0.28)
	elseif gait == "serpent" then
		-- a body of segments on joints, rising to a head (or a naga's torso)
		local prev = root
		for k = 1, 5 do
			local seg = limb(model, root, "Seg" .. k, Vector3.new(1.2 - k * 0.12, 1.1 - k * 0.1, 1.6) * s, Vector3.new(0, -0.1, 0.6 + k * 1.4) * s, Vector3.new(0, 0, 0) * s, if k % 2 == 0 then d.c else d.a)
			local _ = prev
			prev = seg
		end
		if x.torso then
			body("Torso", Vector3.new(1.6, 2, 1), Vector3.new(0, 1.3, -0.4), d.c)
			body("Head", Vector3.new(1, 1, 1), Vector3.new(0, 2.8, -0.5), d.c)
			eyes(2.9, -1.02, 0.22)
			limb(model, root, "ArmR", Vector3.new(0.5, 1.8, 0.5) * s, Vector3.new(1.05, 2, -0.4) * s, Vector3.new(0, -0.9, 0) * s, d.c)
			limb(model, root, "ArmL", Vector3.new(0.5, 1.8, 0.5) * s, Vector3.new(-1.05, 2, -0.4) * s, Vector3.new(0, -0.9, 0) * s, d.c)
		else
			body("Neck", Vector3.new(1.2, 2.4, 1.2), Vector3.new(0, 1, -0.4), d.c)
			body("Head", Vector3.new(1.6, 1.1, 2), Vector3.new(0, 2.4, -1), d.c)
			eyes(2.6, -2.02, 0.45, 0.3)
			if x.horns then
				for _, sd in { -1, 1 } do
					body("Horn", Vector3.new(0.25, 1.2, 0.25), Vector3.new(sd * 0.55, 3.2, -0.6), d.a, Enum.Material.Neon, nil, CFrame.Angles(math.rad(40), 0, 0))
				end
			end
		end
	elseif gait == "float" then
		body("Robe", Vector3.new(2, 3.2, 1.6), Vector3.new(0, 0, 0), d.c, Enum.Material.Fabric)
		body("Hem", Vector3.new(2.4, 0.6, 2), Vector3.new(0, -1.7, 0), d.c, Enum.Material.Fabric).Transparency = 0.4
		body("Hood", Vector3.new(1.5, 1.4, 1.5), Vector3.new(0, 2.1, 0), d.c, Enum.Material.Fabric)
		body("Void", Vector3.new(1, 0.9, 0.2), Vector3.new(0, 2, -0.7), rgb(5, 5, 8))
		eyes(2.05, -0.82, 0.22, 0.2)
		if x.crown then
			for k = 0, 4 do
				local a = k / 5 * math.pi * 2
				body("Crown", Vector3.new(0.18, 0.6, 0.18), Vector3.new(math.cos(a) * 0.55, 2.95, math.sin(a) * 0.55), d.a, Enum.Material.Neon)
			end
		end
		local armR = limb(model, root, "ArmR", Vector3.new(0.6, 2.2, 0.6) * s, Vector3.new(1.3, 1, 0) * s, Vector3.new(0, -1.1, 0) * s, d.c, Enum.Material.Fabric)
		limb(model, root, "ArmL", Vector3.new(0.6, 2.2, 0.6) * s, Vector3.new(-1.3, 1, 0) * s, Vector3.new(0, -1.1, 0) * s, d.c, Enum.Material.Fabric)
		if x.scythe or x.staff then
			local p = newPart(model, "Shaft", Vector3.new(0.2, 5, 0.2) * s, armR.CFrame * CFrame.new(0, 0, -0.3 * s), rgb(40, 36, 40), Enum.Material.Wood)
			local w = Instance.new("WeldConstraint")
			w.Part0 = armR
			w.Part1 = p
			w.Parent = p
			local tip = newPart(model, if x.scythe then "Blade" else "Orb", if x.scythe then Vector3.new(0.1, 0.6, 2.4) * s else Vector3.one * 0.8 * s, armR.CFrame * CFrame.new(0, 2.5 * s, if x.scythe then -1.2 * s else -0.3 * s), d.a, Enum.Material.Neon, if x.staff then Enum.PartType.Ball else nil)
			local w2 = Instance.new("WeldConstraint")
			w2.Part0 = armR
			w2.Part1 = tip
			w2.Parent = tip
		end
	elseif gait == "golem" then
		body("Torso", Vector3.new(3, 2.6, 1.8), Vector3.new(0, 0.4, 0), nil, Enum.Material.Slate)
		body("Head", Vector3.new(1.2, 1, 1.1), Vector3.new(0, 2.2, -0.3), nil, Enum.Material.Slate)
		eyes(2.25, -0.88, 0.25)
		body("Core", Vector3.new(0.9, 0.9, 0.3), Vector3.new(0, 0.6, -0.92), d.a, Enum.Material.Neon)
		if x.crystals then
			for k = -1, 1 do
				body("Crystal", Vector3.new(0.5, 1.4, 0.5), Vector3.new(k * 0.9, 2, 0.6), d.a, Enum.Material.Neon, nil, CFrame.Angles(math.rad(-20), 0, math.rad(k * 20)))
			end
		end
		if x.rivets then
			for k = -1, 1, 2 do
				body("Rivet", Vector3.new(0.3, 0.3, 0.3), Vector3.new(k * 1.2, 1.2, -0.92), rgb(70, 70, 76), Enum.Material.Metal, Enum.PartType.Ball)
			end
		end
		limb(model, root, "ArmR", Vector3.new(1.2, 3, 1.2) * s, Vector3.new(2, 1.2, 0) * s, Vector3.new(0, -1.5, 0) * s, d.c, Enum.Material.Slate)
		limb(model, root, "ArmL", Vector3.new(1.2, 3, 1.2) * s, Vector3.new(-2, 1.2, 0) * s, Vector3.new(0, -1.5, 0) * s, d.c, Enum.Material.Slate)
		limb(model, root, "LegR", Vector3.new(1.2, 2, 1.2) * s, Vector3.new(0.8, -1, 0) * s, Vector3.new(0, -1, 0) * s, d.c, Enum.Material.Slate)
		limb(model, root, "LegL", Vector3.new(1.2, 2, 1.2) * s, Vector3.new(-0.8, -1, 0) * s, Vector3.new(0, -1, 0) * s, d.c, Enum.Material.Slate)
	end
	local glow = Instance.new("PointLight")
	glow.Color = d.eye
	glow.Range = 8 * s
	glow.Brightness = 1.4
	glow.Parent = root
	local hum = Instance.new("Humanoid")
	hum.RigType = Enum.HumanoidRigType.R6
	-- how high the root rides above the ground
	hum.HipHeight = if gait == "flyer" or gait == "float" then 3 * s elseif gait == "serpent" then 0.5 * s elseif gait == "blob" then 1 * s elseif rootH == 2 then 2 * s else 1.4 * s
	hum.WalkSpeed = d.speed
	hum.MaxHealth = d.hp
	hum.Health = d.hp
	hum.DisplayName = d.name
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	hum.NameDisplayDistance = 80
	hum.HealthDisplayDistance = 80
	hum.Parent = model
	model:SetAttribute("Gait", gait)
	model:SetAttribute("Kind", kind)
	model:SetAttribute("Rank", d.rank)
	-- smooth Blender meshes over the parts, if the place has the kit (Hunter/MeshLibrary)
	MeshLibrary.dress(model, gait)
	return model, hum
end

return Monsters
