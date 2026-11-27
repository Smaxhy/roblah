--[[
	WEAPON EFFECTS (Hunter/WeaponModels on the rig, client/WeaponFx in the city), on @lune/roblox
	instances (real classes, real property names: anything wrong errors here):
		lune run tests/weaponfx_check
	  - every weapon builds on an R6 rig at ★, ★★, ★★★ and Shiny, its parts named "Weapon...",
	    non-colliding and massless, and stamps the rig (WeaponBase, WeaponFamily, WeaponElement,
	    WeaponStars, WeaponShiny, WeaponClass, WeaponGrade, WeaponStyle)
	  - every weapon has a swing Trail between TrailTop and TrailBottom, off until a swing
	  - the element's emitters, the light and the Shiny sparkles come with the stars, on a budget
	    (low rates, small particles, one light), and only Roblox's own particle textures
	  - every MeshRole is one the mesh kit makes, on a part whose box has that role's shape; a
	    socket hides its fallback shape and its cover parts point at it
	  - WeaponFx: equip, swing (every family, with and without aim) and hit (every element, weak
	    and strong) run without an error, leave only anchored or welded non-colliding parts, hand
	    every part to Debris, and turn the trail on for the swing and off after it
	  - a weapon can be taken off (WeaponModels.detach) and put on again
]]
local roblox = require("@lune/roblox")
local process = require("@lune/process")
local Loader = require("./loader")

-- ── a thin proxy over @lune/roblox instances: methods lune doesn't have (Emit) are stubbed
-- and counted; everything else goes to the real instance ──
local REAL = setmetatable({}, { __mode = "k" })
local function unwrap(v)
	return REAL[v] or v
end
local emitted = 0
local STUB_METHODS = {
	Emit = function(_, n)
		emitted += n or 0
	end,
}
local signal = { Connect = function()
	return { Disconnect = function() end, Connected = true }
end }
local function wrap(real)
	local proxy = {}
	REAL[proxy] = real
	return setmetatable(proxy, {
		__index = function(_, k)
			local ok, v = pcall(function()
				return real[k]
			end)
			if not ok then
				if STUB_METHODS[k] then
					return function(_, ...)
						return STUB_METHODS[k](real, ...)
					end
				end
				error(v, 2)
			end
			if type(v) == "function" then
				return function(_, ...)
					local args = table.pack(...)
					for i = 1, args.n do
						args[i] = unwrap(args[i])
					end
					return v(real, table.unpack(args, 1, args.n))
				end
			end
			return v
		end,
		__newindex = function(_, k, v)
			real[k] = unwrap(v)
		end,
	})
end
local ProxyInstance = { new = function(className, parent)
	local r = roblox.Instance.new(className)
	if parent then
		r.Parent = unwrap(parent)
	end
	return wrap(r)
end }

-- the services WeaponFx uses: a tween applies its goals at once (so every goal is checked
-- against the real class), Debris marks what it was handed, task.delay runs later
local queue = {}
local workspace = roblox.Instance.new("Folder")
workspace.Name = "Workspace"
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.globals = {
	Instance = ProxyInstance, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3,
	CFrame = roblox.CFrame, Color3 = roblox.Color3, Enum = roblox.Enum, Font = roblox.Font,
	NumberSequence = roblox.NumberSequence, NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, NumberRange = roblox.NumberRange,
	ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	TweenInfo = { new = function(...)
		return { ... }
	end },
	task = {
		delay = function(_, f, ...)
			table.insert(queue, { f, table.pack(...) })
		end,
		spawn = function(f, ...)
			f(...)
		end,
		defer = function(f, ...)
			f(...)
		end,
		wait = function()
			return 0
		end,
	},
	game = { GetService = function(_, name)
		if name == "TweenService" then
			return { Create = function(_, inst, _info, goals)
				local real = unwrap(inst)
				for k, v in goals do
					real[k] = unwrap(v)
				end
				return { Play = function() end, Cancel = function() end, Completed = signal }
			end }
		elseif name == "Debris" then
			return { AddItem = function(_, inst, _t)
				unwrap(inst):SetAttribute("TestDebris", true)
			end }
		elseif name == "Workspace" then
			return wrap(workspace)
		elseif name == "ReplicatedStorage" then
			return { WaitForChild = function()
				return shared
			end }
		elseif name == "RunService" then
			return { RenderStepped = signal, Heartbeat = signal }
		end
		return {}
	end },
}
local client = Loader.preload(Loader.node("src/client", "Client", nil))
local Weapons = Loader.require(shared.Hunter.Weapons)
local WeaponModels = Loader.require(shared.Hunter.WeaponModels)
local R6Rig = Loader.require(shared.Hunter.R6Rig)
local WeaponFx = Loader.require(client.WeaponFx)

local fails = 0
local function check(ok, msg, detail)
	print((if ok then "  ok    " else "  FAIL  ") .. msg .. (if ok or detail == nil then "" else ": " .. tostring(detail)))
	if not ok then
		fails += 1
	end
end
local function flush()
	while #queue > 0 do
		local q = table.remove(queue, 1)
		q[1](table.unpack(q[2], 1, q[2].n))
	end
end

local TEXTURES = {
	["rbxasset://textures/particles/sparkles_main.dds"] = true,
	["rbxasset://textures/particles/fire_main.dds"] = true,
	["rbxasset://textures/particles/smoke_main.dds"] = true,
}
local ATTRS = { "WeaponBase", "WeaponFamily", "WeaponElement", "WeaponStars", "WeaponShiny", "WeaponClass", "WeaponGrade", "WeaponStyle" }
local VARIANTS = { { 1, false }, { 2, false }, { 3, false }, { 3, true } }

local function weaponParts(rig)
	local out = {}
	for _, d in rig:GetChildren() do
		if d:IsA("BasePart") and d:GetAttribute("WeaponPiece") then
			table.insert(out, d)
		end
	end
	return out
end
local function axisOk(spec, size)
	local s = { X = size.X, Y = size.Y, Z = size.Z }
	if spec.thin then
		for _, a in { "X", "Y", "Z" } do
			if s[a] < s[spec.thin] - 1e-4 then
				return false, "not thinnest along " .. spec.thin
			end
		end
	end
	if spec.long then
		for _, a in { "X", "Y", "Z" } do
			if s[a] > s[spec.long] + 1e-4 then
				return false, "not longest along " .. spec.long
			end
		end
	end
	if spec.square then
		local a, b = string.sub(spec.square, 1, 1), string.sub(spec.square, 2, 2)
		if math.abs(s[a] - s[b]) > 1e-3 then
			return false, spec.square .. " not square"
		end
	end
	if spec.cube and (math.abs(s.X - s.Y) > 1e-3 or math.abs(s.Y - s.Z) > 1e-3) then
		return false, "not a cube"
	end
	return true
end

-- ── the models: every weapon at every rarity ──
local bad = {}
local function fail(where, msg)
	if #bad < 12 then
		table.insert(bad, where .. ": " .. msg)
	end
end
local builds, maxParts, maxRate, roles, sockets = 0, 0, 0, {}, 0
local auraByStars = { 0, 0, 0 }
local auraCount = { 0, 0, 0 }
for _, w in Weapons.list do
	for _, v in VARIANTS do
		local stars, shiny = v[1], v[2]
		local where = w.id .. "@" .. stars .. (if shiny then "s" else "")
		local ok, rig = pcall(R6Rig.build, {}, { weapon = { base = w.id, stars = stars, shiny = shiny } })
		if not ok then
			fail(where, "doesn't build: " .. tostring(rig))
			continue
		end
		rig = unwrap(rig)
		builds += 1
		-- the stamp
		local want = { WeaponBase = w.id, WeaponFamily = w.family, WeaponElement = w.element, WeaponStars = stars, WeaponShiny = shiny, WeaponClass = w.class, WeaponGrade = w.grade, WeaponStyle = Weapons.FAMILIES[w.family].fx }
		for _, key in ATTRS do
			if rig:GetAttribute(key) ~= want[key] then
				fail(where, key .. " is " .. tostring(rig:GetAttribute(key)) .. ", not " .. tostring(want[key]))
			end
		end
		-- the parts
		local parts = weaponParts(rig)
		maxParts = math.max(maxParts, #parts)
		if #parts == 0 then
			fail(where, "has no parts")
		end
		local ids = {}
		for _, p in parts do
			if string.sub(p.Name, 1, 6) ~= "Weapon" or p.CanCollide or not p.Massless or p.CanQuery then
				fail(where, p.Name .. " is misnamed, collides, queries or has mass")
			end
			local role = p:GetAttribute("MeshRole")
			if role ~= nil then
				local spec = WeaponModels.MESH_ROLES[role]
				if not spec then
					fail(where, p.Name .. " asks for an unknown mesh role " .. tostring(role))
				else
					roles[role] = (roles[role] or 0) + 1
					local fine, why = axisOk(spec, p.Size)
					if not fine then
						fail(where, p.Name .. " (" .. role .. ") " .. why)
					end
				end
				local id = p:GetAttribute("MeshId")
				if id then
					sockets += 1
					ids[id] = true
					local sm = p:FindFirstChild("FallbackShape")
					if not (sm and sm:IsA("SpecialMesh") and sm.Scale.Magnitude < 0.01) then
						fail(where, p.Name .. " is a socket without a hidden fallback shape")
					end
				end
			end
		end
		for _, p in parts do
			local cover = p:GetAttribute("MeshCover")
			if cover ~= nil and not ids[cover] then
				fail(where, p.Name .. " covers a socket that isn't there (" .. tostring(cover) .. ")")
			end
		end
		-- the trail(s)
		local trails = WeaponFx.trails(rig)
		if #trails == 0 then
			fail(where, "has no WeaponTrail")
		end
		for _, t in trails do
			local a0, a1 = t.Attachment0, t.Attachment1
			if t.Enabled or not a0 or not a1 or a0.Name ~= "TrailTop" or a1.Name ~= "TrailBottom" or not a0.Parent or not a0.Parent:GetAttribute("WeaponPiece") then
				fail(where, "a trail isn't off between TrailTop and TrailBottom on a weapon part")
			elseif (a0.CFrame.Position - a1.CFrame.Position).Magnitude < 0.15 then
				fail(where, "a trail's attachments are on top of each other")
			end
		end
		-- the aura, the light, the shine
		local rate, lights, shine, auras = 0, 0, false, 0
		for _, d in rig:GetDescendants() do
			if d:IsA("ParticleEmitter") then
				rate += d.Rate
				if not TEXTURES[d.Texture] then
					fail(where, "emitter uses texture " .. tostring(d.Texture))
				end
				for _, kp in d.Size.Keypoints do
					if kp.Value > 1.2 then
						fail(where, d.Name .. " particles are too big")
					end
				end
				if d.Name == "WeaponShine" then
					shine = true
				elseif d.Name == "WeaponAura" or d.Name == "WeaponAura2" then
					auras += 1
				end
			elseif d:IsA("PointLight") then
				lights += 1
				if d.Range > 12 or d.Brightness > 2.5 then
					fail(where, "its light is too strong")
				end
			end
		end
		maxRate = math.max(maxRate, rate)
		if rate > 30 then
			fail(where, string.format("emits %.1f particles a second (budget 30)", rate))
		end
		if lights > 1 then
			fail(where, "has " .. lights .. " lights")
		end
		if shiny ~= shine then
			fail(where, if shiny then "Shiny without sparkles" else "sparkles without Shiny")
		end
		if (stars == 3 or shiny) and lights == 0 then
			fail(where, "a ★★★ or Shiny weapon gives no light")
		end
		local lamp = w.family == "censer" or w.family == "thurible" or w.family == "crystal" or w.family == "orb"
		if stars == 1 and not shiny and lights > 0 and not lamp then
			fail(where, "a ★ weapon gives light")
		end
		if w.element ~= "none" and auras == 0 then
			fail(where, "an elemental weapon throws nothing off")
		end
		if not shiny and w.element ~= "none" then
			auraByStars[stars] += rate
			auraCount[stars] += 1
		end
		-- off and on again
		if stars == 1 and not shiny then
			WeaponModels.detach(rig)
			if #weaponParts(rig) > 0 or rig:GetAttribute("WeaponBase") ~= nil then
				fail(where, "detach leaves the weapon behind")
			end
			WeaponModels.attach(rig, w.id, 2, false)
			local once = #weaponParts(rig)
			WeaponModels.attach(rig, w.id, 2, false)
			if rig:GetAttribute("WeaponStars") ~= 2 or once == 0 or #weaponParts(rig) ~= once or #WeaponFx.trails(rig) == 0 then
				fail(where, "re-attaching doesn't work (or doubles the weapon)")
			end
		end
	end
end
print(string.format("        %d builds (%d weapons x ★/★★/★★★/Shiny), up to %d parts, up to %.1f particles a second", builds, #Weapons.list, maxParts, maxRate))
local roleList = {}
for r, n in roles do
	table.insert(roleList, r .. " " .. n)
end
table.sort(roleList)
print("        mesh roles asked for: " .. table.concat(roleList, ", ") .. string.format(" (%d sockets)", sockets))
check(#bad == 0, "every weapon builds at every rarity, stamped, with a trail, its element's effects, and mesh roles that fit", table.concat(bad, "; "))
local avg = {}
for s = 1, 3 do
	avg[s] = auraByStars[s] / math.max(1, auraCount[s])
end
print(string.format("        elemental particles a second: ★ %.1f  ★★ %.1f  ★★★ %.1f", avg[1], avg[2], avg[3]))
check(avg[1] < avg[2] and avg[2] < avg[3] and avg[1] <= 4, "★ is subtle, ★★★ obvious")
local used = {}
for r in roles do
	used[r] = true
end
local unused = {}
for r in WeaponModels.MESH_ROLES do
	if not used[r] then
		table.insert(unused, r)
	end
end
check(#unused == 0, "every new mesh role is asked for somewhere", table.concat(unused, ", "))
check(maxParts <= 60, "no weapon has more than 60 parts", maxParts)

-- ── WeaponFx ──
local fxFolder = roblox.Instance.new("Folder")
fxFolder.Name = "WeaponFxTest"
WeaponFx.parent = wrap(fxFolder)
local fxBad = {}
local function fxFail(where, msg)
	if #fxBad < 12 then
		table.insert(fxBad, where .. ": " .. msg)
	end
end
local maxFxParts = 0
local function run(where, fn)
	for _, c in fxFolder:GetChildren() do
		c:Destroy()
	end
	local before = emitted
	local ok, err = pcall(fn)
	if not ok then
		fxFail(where, tostring(err))
		return 0, 0
	end
	local n = 0
	for _, c in fxFolder:GetChildren() do
		n += 1
		if not c:GetAttribute("TestDebris") then
			fxFail(where, c.ClassName .. " " .. c.Name .. " is never cleaned up")
		end
		if c:IsA("BasePart") then
			if c.CanCollide or c.CanQuery or c.CanTouch then
				fxFail(where, "an effect part collides or can be hit")
			end
			if not c.Anchored and not c:FindFirstChildOfClass("WeldConstraint") then
				fxFail(where, "an effect part is loose (neither anchored nor welded)")
			end
		end
	end
	flush()
	return n, emitted - before
end
local styles, families = {}, {}
local swingParts, hitParts = 0, 0
local ELEMENTS = Weapons.ELEMENT_LIST
for _, fam in Weapons.FAMILY_ORDER do
	local w
	for _, x in Weapons.list do
		if x.family == fam then
			w = x
			break
		end
	end
	for _, v in { { 1, false }, { 3, true } } do
		local rig = R6Rig.build({}, { weapon = { base = w.id, stars = v[1], shiny = v[2] } })
		local real = unwrap(rig)
		real.Parent = workspace
		local where = w.id .. "@" .. v[1] .. (if v[2] then "s" else "")
		if WeaponFx.familyOf(rig) ~= fam or WeaponFx.elementOf(rig) ~= w.element or WeaponFx.styleOf(rig) ~= Weapons.FAMILIES[fam].fx then
			fxFail(where, "familyOf / elementOf / styleOf read it wrong")
		end
		styles[WeaponFx.styleOf(rig)] = true
		families[fam] = true
		run(where .. " equip", function()
			WeaponFx.equip(rig)
		end)
		local n = run(where .. " swing", function()
			WeaponFx.swing(rig)
			for _, t in WeaponFx.trails(real) do
				if not t.Enabled then
					error("the trail isn't on during the swing")
				end
			end
		end)
		for _, t in WeaponFx.trails(real) do
			if t.Enabled then
				fxFail(where, "the trail stays on after the swing")
			end
		end
		maxFxParts = math.max(maxFxParts, n)
		swingParts = math.max(swingParts, n)
		local n2 = run(where .. " aimed swing", function()
			WeaponFx.swing(rig, { direction = roblox.Vector3.new(1, 0, 0.3), target = roblox.Vector3.new(30, 3, 10), power = 25, reach = 8 })
		end)
		maxFxParts = math.max(maxFxParts, n2)
		real:Destroy()
	end
end
for _, e in ELEMENTS do
	for _, power in { 2, 35 } do
		local n = run("hit " .. e .. " " .. power, function()
			WeaponFx.hit(roblox.Vector3.new(0, 3, 0), e, power)
		end)
		hitParts = math.max(hitParts, n)
		maxFxParts = math.max(maxFxParts, n)
	end
end
run("hit with no element", function()
	WeaponFx.hit(roblox.Vector3.new(0, 3, 0))
end)
run("swing of a bare rig", function()
	WeaponFx.swing(R6Rig.build({}, { weapon = false }))
end)
print(string.format("        %d families, %d swing styles; up to %d parts a swing, %d a hit; %d particles emitted", #Weapons.FAMILY_ORDER, (function()
	local n = 0
	for _ in styles do
		n += 1
	end
	return n
end)(), swingParts, hitParts, emitted))
check(#fxBad == 0, "WeaponFx equips, swings (every family, aimed or not) and hits (every element) cleanly", table.concat(fxBad, "; "))
local missing = {}
for _, s in WeaponFx.STYLES do
	if not styles[s] then
		table.insert(missing, s)
	end
end
check(#missing == 0, "every swing style is some family's", table.concat(missing, ", "))
check(maxFxParts <= 45, "a swing or a hit stays under 45 parts", maxFxParts)
check(emitted > 0, "the bursts emit particles")
check(WeaponFx.colorOf("fire") ~= WeaponFx.colorOf("frost") and WeaponFx.elementOf(R6Rig.build({}, {})) == "none", "element colours differ, and a rig with no weapon reads as none")

if fails > 0 then
	process.exit(1)
end
print("\nEvery weapon's model and effects build on real Roblox instance types.")
