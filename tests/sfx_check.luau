--[[
	SOUND EFFECTS, CHECKED ON REAL ROBLOX INSTANCE TYPES (client/Sfx, client/UiSounds, client/WorldSfx).
		lune run tests/sfx_check            (add -- quick to skip running cutscene_check and title_check)
	A fake clock runs every task.delay and tween; Sound:Play is recorded (Lune can't play audio),
	so "a sound played" here means a Sound with that SoundId was made, put in place and started.
	  1. UiSounds: a button made AFTER it started is hooked; pressing it plays a click; a button
	     can pick another sound or opt out (UiSound attribute); hovering ticks
	  2. WorldSfx resolves, to real sounds in its bank, every weapon family (Hunter/Weapons) and
	     event, every element and shape (every SkillFx shape too), every monster family and
	     event (and every live-city monster kind), every Gate and city event, every name the
	     opening and the title call it by, and falls back for names it has never heard of
	  3. all of those play without an error on a stubbed SoundService; at most MAX_VOICES at once;
	     the same move twice in a row is not the same sound twice (variants, pitch)
	  4. every Config.sfx entry and every bank id is a number id or a built-in rbxasset:// path
	     (and the old rbxasset://sounds/*.wav paths map onto Roblox's uploads of those files)
	  5. missing or broken audio stays quiet: unknown names, a Play that errors, no SoundService
	  6. the Effects volume setting reaches the world's mix; loops stop and let go of their place
	  7. tests/cutscene_check and tests/title_check still pass (run as their own processes)
]]

local roblox = require("@lune/roblox")
local process = require("@lune/process")
local fs = require("@lune/fs")
local Loader = require("./loader")
local I = roblox.Instance

local failures = 0
local function check(ok, msg)
	print((if ok then "  ok    " else "  FAIL  ") .. msg)
	if not ok then
		failures += 1
	end
end

-- ── the fake clock ──
local now = 0
local delayed = {}
local function schedule(at, fn, ...)
	table.insert(delayed, { at = at, fn = fn, args = table.pack(...) })
end
local function runFor(seconds)
	local target = now + seconds
	while true do
		table.sort(delayed, function(a, b)
			return a.at < b.at
		end)
		local d = delayed[1]
		if not d or d.at > target then
			break
		end
		table.remove(delayed, 1)
		now = math.max(now, d.at)
		d.fn(table.unpack(d.args, 1, d.args.n))
	end
	now = target
end
local taskStub = {
	delay = function(t, fn, ...)
		schedule(now + (t or 0), fn, ...)
	end,
	spawn = function(fn, ...)
		fn(...)
	end,
	defer = function(fn, ...)
		schedule(now, fn, ...)
	end,
	wait = function(t)
		runFor(t or 0.03)
		return t
	end,
}
local osStub = setmetatable({ clock = function()
	return now
end }, { __index = os })

-- ── what Lune's Roblox types lack: events, Sound:Play ──
local played = {} -- every SoundId started, in order
local playErrors = false
roblox.implementMethod("Sound", "Play", function(self)
	if playErrors then
		error("offline: Play")
	end
	table.insert(played, { id = self.SoundId, name = self.Name, at = self.Parent and self.Parent.ClassName or "?", t = now })
end)
roblox.implementMethod("Sound", "Stop", function() end)
roblox.implementMethod("ParticleEmitter", "Emit", function() end)
local handlers = {}
local function tagOf(inst)
	local tag = inst:GetAttribute("_h")
	if not tag then
		tag = tostring(math.random(1, 1e9))
		inst:SetAttribute("_h", tag)
	end
	return tag
end
local function signalFor(event)
	return function(self)
		local sig = {}
		function sig.Connect(_, fn)
			local tag = tagOf(self)
			handlers[tag] = handlers[tag] or {}
			table.insert(handlers[tag], { event = event, fn = fn })
			return { Disconnect = function() end, Connected = true }
		end
		sig.Once = sig.Connect
		return sig
	end
end
local function fire(inst, event, ...)
	local n = 0
	for _, h in handlers[inst:GetAttribute("_h") or ""] or {} do
		if h.event == event then
			h.fn(...)
			n += 1
		end
	end
	return n
end
for _, cls in { "TextButton", "ImageButton" } do
	for _, ev in { "Activated", "MouseEnter", "MouseLeave", "MouseButton1Click" } do
		roblox.implementProperty(cls, ev, signalFor(ev))
	end
end
roblox.implementProperty("Folder", "DescendantAdded", signalFor("DescendantAdded"))
roblox.implementProperty("ScreenGui", "DescendantAdded", signalFor("DescendantAdded"))
for _, ev in { "Ended", "AncestryChanged", "Loaded" } do
	roblox.implementProperty("Sound", ev, signalFor(ev))
end
for _, cls in { "Part", "MeshPart" } do
	roblox.implementProperty(cls, "Position", function(self)
		return self.CFrame.Position
	end, function(self, v)
		self.CFrame = roblox.CFrame.new(v) * self.CFrame.Rotation
	end)
end
roblox.implementProperty("Attachment", "WorldPosition", function(self)
	local p = self.Parent
	local base = if p and p:IsA("BasePart") then p.CFrame else roblox.CFrame.new()
	return (base * roblox.CFrame.new(self.Position)).Position
end)

-- ── the services ──
local dm = I.new("DataModel")
local workspace = dm:GetService("Workspace")
local cam = I.new("Camera")
cam.CFrame = roblox.CFrame.new(0, 5, 0)
cam.Parent = workspace
workspace.CurrentCamera = cam
local soundService = dm:GetService("SoundService")
local playerGui = I.new("Folder")
playerGui.Name = "PlayerGui"
local player = { Name = "Tester", UserId = 1, WaitForChild = function()
	return playerGui
end }
local shared = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
local rsStub = { WaitForChild = function(_, name)
	return if name == "LifeSim" then shared else nil
end, FindFirstChild = function(_, name)
	return if name == "LifeSim" then shared else nil
end }
local TweenService = { Create = function(_, obj, info, goal)
	return {
		Play = function()
			schedule(now + ((info and info.Time) or 0), function()
				for k, v in goal do
					pcall(function()
						obj[k] = v
					end)
				end
			end)
		end,
		Cancel = function() end,
		Completed = { Connect = function() end },
	}
end }
local services = {
	Players = { LocalPlayer = player }, ReplicatedStorage = rsStub, TweenService = TweenService,
	Workspace = workspace, SoundService = soundService,
	UserInputService = { TouchEnabled = false, MouseEnabled = true, InputBegan = { Connect = function() end } },
	ContentProvider = { PreloadAsync = function() end },
	RunService = { RenderStepped = { Connect = function() end }, Heartbeat = { Connect = function() end }, IsStudio = function()
		return false
	end },
	Debris = { AddItem = function(_, obj, t)
		schedule(now + (t or 10), function()
			pcall(obj.Destroy, obj)
		end)
	end },
}
local seed = 7
local RandomStub = { new = function(s)
	local state = s or seed
	seed += 1
	local function nxt()
		state = (state * 1103515245 + 12345) % 2147483648
		return state / 2147483648
	end
	return {
		NextInteger = function(_, a, b)
			return a + math.floor(nxt() * (b - a + 1))
		end,
		NextNumber = function(_, a, b)
			return (a or 0) + nxt() * ((b or 1) - (a or 0))
		end,
	}
end }
local warnings = {}
Loader.globals = {
	Instance = I, UDim = roblox.UDim, UDim2 = roblox.UDim2, Vector2 = roblox.Vector2, Vector3 = roblox.Vector3, CFrame = roblox.CFrame,
	Color3 = roblox.Color3, Enum = roblox.Enum, NumberRange = roblox.NumberRange, NumberSequence = roblox.NumberSequence,
	NumberSequenceKeypoint = roblox.NumberSequenceKeypoint, ColorSequence = roblox.ColorSequence, ColorSequenceKeypoint = roblox.ColorSequenceKeypoint,
	TweenInfo = { new = function(t)
		return { Time = t }
	end },
	Random = RandomStub, task = taskStub, os = osStub,
	game = { GetService = function(_, name)
		return services[name] or dm:GetService(name)
	end },
	warn = function(...)
		table.insert(warnings, table.concat({ ... }, " "))
	end,
}

local client = Loader.preload(Loader.node("src/client", "Client", nil))
local Config = Loader.require(shared.Config)
local Weapons = Loader.require(shared.Hunter.Weapons)
local Abilities = Loader.require(shared.Hunter.Abilities)
local Monsters = Loader.require(shared.Hunter.Monsters)
local okS, Sfx = pcall(Loader.require, client.Sfx)
check(okS, "client/Sfx loads" .. (if okS then "" else ": " .. tostring(Sfx)))
local okW, WorldSfx = pcall(Loader.require, client.WorldSfx)
check(okW, "client/WorldSfx loads" .. (if okW then "" else ": " .. tostring(WorldSfx)))
local okU, UiSounds = pcall(Loader.require, client.UiSounds)
check(okU, "client/UiSounds loads" .. (if okU then "" else ": " .. tostring(UiSounds)))
if not (okS and okW and okU) then
	process.exit(1)
end
pcall(Sfx.start, Config.sfx)
WorldSfx.start()
local okStart, errStart = pcall(UiSounds.start, playerGui)
check(okStart, "UiSounds starts on PlayerGui" .. (if okStart then "" else ": " .. tostring(errStart)))
runFor(0.5)

-- ── 1. every button clicks, even one made later ──
print("\n1. UI")
local screen = I.new("ScreenGui")
screen.Parent = playerGui
fire(playerGui, "DescendantAdded", screen)
local button = I.new("TextButton")
button.Text = "LATE BUTTON"
button.Parent = screen
fire(playerGui, "DescendantAdded", button) -- (Roblox fires this; Lune doesn't)
check(UiSounds.isHooked(button), "a button made after UiSounds started is hooked")
local before = #played
local pressesBefore = UiSounds.presses
fire(button, "Activated")
runFor(0.4)
check(UiSounds.presses == pressesBefore + 1, "pressing it counts a press")
check(#played > before, string.format("pressing it plays a sound (%d started)", #played - before))
local clicked = false
for _, n in UiSounds.played do
	if n == "click" then
		clicked = true
	end
end
check(clicked, "the press is the click")
local deny = I.new("TextButton")
deny:SetAttribute("UiSound", "deny")
deny.Parent = screen
fire(playerGui, "DescendantAdded", deny)
fire(deny, "Activated")
runFor(0.3)
check(UiSounds.played[#UiSounds.played] == "deny", "a button can pick its own sound (UiSound = \"deny\")")
local quiet = I.new("TextButton")
quiet:SetAttribute("UiSound", "none")
quiet.Parent = screen
fire(playerGui, "DescendantAdded", quiet)
before = #played
fire(quiet, "Activated")
runFor(0.3)
check(#played == before, "UiSound = \"none\" keeps a button silent")
local hovers = UiSounds.hovers
runFor(0.2)
fire(button, "MouseEnter")
runFor(0.2)
check(UiSounds.hovers == hovers + 1, "hovering a button ticks")
local spin = UiSounds.spin(1.2)
runFor(2)
check(spin and spin.ticks and spin.ticks >= 6, string.format("a spin ticks as it slows (%d ticks) and ends", spin and spin.ticks or 0))

-- ── 2. everything resolves to real sounds ──
print("\n2. WorldSfx resolves")
local function realLayers(layers, element, depth)
	if type(layers) ~= "table" or #layers == 0 then
		return false
	end
	for _, l in layers do
		local name = l[1]
		if string.sub(name, 1, 1) == "@" then
			if (depth or 0) > 3 or not realLayers(WorldSfx.magicCue(element or "arcane", string.sub(name, 2)), element, (depth or 0) + 1) then
				return false
			end
		else
			local def = WorldSfx.SOUNDS[name]
			if not def or #def.v == 0 then
				return false, name
			end
		end
	end
	return true
end
local bad = {}
local families = {}
for f in Weapons.FAMILIES do
	table.insert(families, f)
end
table.sort(families)
for _, f in { "plasma_lance", "mystery", "", "BOW" } do
	table.insert(families, f)
end
for _, f in families do
	for _, ev in { "swing", "hit", "equip", "crit", "draw", "shot" } do
		local ok, missing = realLayers(WorldSfx.weaponCue(f, ev))
		if not ok then
			table.insert(bad, "weapon " .. f .. "/" .. ev .. (if missing then " (" .. missing .. ")" else ""))
		end
	end
end
check(#bad == 0, string.format("every weapon family (%d, plus unknown ones) resolves for swing, hit, equip, crit%s", #families - 4, if #bad > 0 then ": " .. table.concat(bad, ", ") else ""))
local cats = {}
for _, f in families do
	cats[WorldSfx.weaponCategory(f)] = true
end
local ncat = 0
for _ in cats do
	ncat += 1
end
check(ncat >= 14, string.format("the families sound like %d kinds of weapon (blades, heavy cleaves, thrusts, blunt, bows, crossbows, thrown, chains, staves, fans, bells, fists, claws, shields)", ncat))
check(WorldSfx.weaponCategory("plasma_lance") == "thrust" and WorldSfx.weaponCategory("mystery", "smash") == "blunt", "an unknown family falls back by a word in its name, then by its swing style")

bad = {}
local elements = { "fire", "frost", "lightning", "wind", "earth", "water", "holy", "void", "venom", "arcane", "healing" }
for e in Abilities.ELEMENTS do
	table.insert(elements, e)
end
table.insert(elements, "plasma") -- (never heard of: arcane)
local shapes = { "charge", "cast", "projectile", "impact", "explosion", "nova", "beam", "buff", "heal", "tick", "wobble" }
for s in Abilities.SHAPES do
	table.insert(shapes, s)
end
for _, e in elements do
	for _, s in shapes do
		local ok, missing = realLayers(WorldSfx.magicCue(e, s), WorldSfx.element(e))
		if not ok then
			table.insert(bad, e .. "/" .. s .. (if missing then " (" .. missing .. ")" else ""))
		end
	end
end
check(#bad == 0, string.format("every element (%d) x shape (%d, every SkillFx shape among them) resolves%s", #elements, #shapes, if #bad > 0 then ": " .. table.concat(bad, ", ", 1, math.min(#bad, 8)) else ""))
-- the eleven elements of the brief each sound like themselves (their own cast)
local distinct = {}
for _, e in { "fire", "frost", "lightning", "wind", "earth", "water", "holy", "void", "venom", "arcane", "healing" } do
	distinct[WorldSfx.magicCue(e, "impact")[1][1]] = true
end
local nd = 0
for _ in distinct do
	nd += 1
end
check(nd >= 10, string.format("the elements' impacts are their own sounds (%d different first layers)", nd))

bad = {}
local mfams = { "goblinoid", "orc", "elf", "dwarf", "giant", "beast", "insect", "spider", "reptile", "undead", "demon", "golem", "elemental", "slime", "flier", "dragon", "plant", "aquatic", "default", "whatever" }
for _, f in mfams do
	for _, ev in { "aggro", "attack", "hurt", "death", "step", "roar", "die" } do
		local ok, missing = realLayers(WorldSfx.monsterCue(f, ev))
		if not ok then
			table.insert(bad, f .. "/" .. ev .. (if missing then " (" .. missing .. ")" else ""))
		end
	end
end
check(#bad == 0, "every monster family x aggro, attack, hurt, death (and step) resolves" .. (if #bad > 0 then ": " .. table.concat(bad, ", ") else ""))
local unplaced = {}
for kind, def in Monsters.DEFS do
	local fam = WorldSfx.monsterFamily(kind, def, def.gait)
	if fam == "default" then
		table.insert(unplaced, kind)
	end
end
check(#unplaced == 0, "every live-city monster kind has a family" .. (if #unplaced > 0 then " (not: " .. table.concat(unplaced, ", ") .. ")" else ""))
check(WorldSfx.monsterFamily("frost_wyrm") == "dragon" and WorldSfx.monsterFamily("tomb_skeleton") == "undead" and WorldSfx.monsterFamily("giant_scorpion") == "spider"
	and WorldSfx.monsterFamily("cave_x", nil, "flyer") == "flier" and WorldSfx.monsterFamily("zzz") == "default", "a new kind is placed by its name, then its gait, then the default")

bad = {}
for _, ev in WorldSfx.GATE_EVENTS do
	local layers = WorldSfx.CUES["gate." .. ev]
	if not realLayers(layers) then
		table.insert(bad, "gate." .. ev)
	end
end
for _, ev in WorldSfx.CITY_EVENTS do
	if not realLayers(WorldSfx.CUES["city." .. ev]) then
		table.insert(bad, "city." .. ev)
	end
end
check(#bad == 0, "every Gate event (hum, open, surge, break, close, red, its drone, enter) and city event (siren, crowd panic, radio...) resolves" .. (if #bad > 0 then ": " .. table.concat(bad, ", ") else ""))

-- every name the opening, the title and the live city call WorldSfx by
local callers = { "src/client/OpeningCutscene.luau", "src/client/UI/TitleMenu.luau", "src/client/HunterLive.luau", "src/client/UiSounds.luau" }
local names, unknown = {}, {}
for _, path in callers do
	local src = fs.readFile(path)
	for name in string.gmatch(src, "WorldSfx%.play%(\"([^\"]+)\"") do
		names[name] = true
	end
	if string.find(path, "HunterLive", 1, true) then -- (its `sound` helper takes WorldSfx names)
		for name in string.gmatch(src, "sound%(\"([^\"]+)\"") do
			names[name] = true
		end
	end
	for ev in string.gmatch(src, "WorldSfx%.gate%(\"([^\"]+)\"") do
		names["gate." .. ev] = true
	end
	for ev in string.gmatch(src, "WorldSfx%.city%(\"([^\"]+)\"") do
		names["city." .. ev] = true
	end
end
local count = 0
for name in names do
	count += 1
	local layers = WorldSfx.CUES[name]
	local ok = (layers and realLayers(layers)) or WorldSfx.SOUNDS[name] ~= nil
	if not ok then
		-- a namespaced name ("weapon.sword.swing", "monster.orc.attack", "magic.fire.impact")
		local a, b, c = string.match(name, "^(%a+)%.([%w_]+)%.?([%w_]*)$")
		ok = (a == "weapon" and realLayers(WorldSfx.weaponCue(b, c)))
			or (a == "monster" and realLayers(WorldSfx.monsterCue(b, c)))
			or (a == "magic" and realLayers(WorldSfx.magicCue(b, c), WorldSfx.element(b)))
			-- (built at run time: "monster." .. family .. ".hurt")
			or (string.match(name, "^(%a+)%.$") ~= nil and table.find({ "weapon", "monster", "magic" }, string.match(name, "^(%a+)%.$")) ~= nil)
	end
	if not ok then
		table.insert(unknown, name)
	end
end
table.sort(unknown)
check(#unknown == 0, string.format("every name the opening, the title and the live city call it by is in the bank (%d names)%s", count, if #unknown > 0 then ": " .. table.concat(unknown, ", ") else ""))

-- ── 3. it all plays, on a stubbed SoundService ──
print("\n3. playing")
local errors = {}
local function try(label, fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		table.insert(errors, label .. ": " .. tostring(err))
	end
end
local spot = roblox.Vector3.new(10, 3, 10)
local part = I.new("Part")
part.Anchored = true
part.CFrame = roblox.CFrame.new(5, 4, 5)
part.Parent = workspace
local startPlayed = #played
for _, f in families do
	for _, ev in { "swing", "hit", "equip", "crit" } do
		try("weapon " .. f, WorldSfx.weapon, f, ev, spot, { power = 300, element = "fire", stars = 3 })
	end
	runFor(0.2)
end
for _, e in elements do
	for _, s in shapes do
		try("magic " .. e .. "/" .. s, WorldSfx.magic, e, s, part, { tier = 5 })
	end
	runFor(0.3)
end
for _, f in mfams do
	for _, ev in { "aggro", "attack", "hurt", "death", "step" } do
		try("monster " .. f, WorldSfx.monster, f, ev, spot, { rank = 4, element = "frost" })
	end
	runFor(0.3)
end
local model = Monsters.build and select(2, pcall(Monsters.build, "orc"))
if model and typeof(model) == "Instance" then
	model.Parent = workspace
	try("monsterOf", WorldSfx.monsterOf, model, "attack")
end
for _, ev in WorldSfx.GATE_EVENTS do
	try("gate " .. ev, WorldSfx.gate, ev, spot, { rank = 3 })
end
for _, ev in WorldSfx.CITY_EVENTS do
	try("city " .. ev, WorldSfx.city, ev, spot)
end
for name in names do
	try("play " .. name, WorldSfx.play, name, spot)
end
for _, n in { "weapon.katana.swing", "magic.frost.nova", "monster.dragon.aggro", "gate.break", "city.radio", "fire.impact", 12222216, "rbxassetid://12222216" } do
	try("play " .. tostring(n), WorldSfx.play, n, nil)
end
runFor(3)
check(#errors == 0, "every call plays without an error" .. (if #errors > 0 then ": " .. table.concat(errors, " | ", 1, math.min(#errors, 5)) else ""))
check(#played - startPlayed > 400, string.format("and they make sounds (%d started)", #played - startPlayed))
check(WorldSfx.activeCount() <= WorldSfx.MAX_VOICES, string.format("never more than %d at once (%d now)", WorldSfx.MAX_VOICES, WorldSfx.activeCount()))
-- a burst of 200: the cap holds, the important ones get through
local peak = 0
for k = 1, 200 do
	WorldSfx.play(if k % 2 == 0 then "blade.hit" else "monster.vocal", roblox.Vector3.new(k % 20, 2, 0), { volume = 1 })
	peak = math.max(peak, WorldSfx.activeCount())
	now += 0.031
end
check(peak <= WorldSfx.MAX_VOICES, string.format("a burst of 200 never goes past the cap (peak %d)", peak))
runFor(6)
-- variety: the same swing ten times isn't ten identical sounds
local ids, speeds = {}, {}
local mark = #played
for _ = 1, 10 do
	WorldSfx.weapon("katana", "swing", spot)
	now += 0.1
end
for i = mark + 1, #played do
	ids[played[i].id] = true
end
local swishes = {}
for _, s in soundService:GetDescendants() do
	local _ = s
end
for _, a in workspace:GetDescendants() do
	if a:IsA("Sound") and a.Name == "blade.swish" then
		table.insert(swishes, a.PlaybackSpeed)
	end
end
local nids = 0
for _ in ids do
	nids += 1
end
for _, sp in swishes do
	speeds[math.floor(sp * 1000)] = true
end
local nsp = 0
for _ in speeds do
	nsp += 1
end
check(nids >= 3 and nsp >= 3, string.format("ten katana swings use %d different recordings at %d different pitches", nids, nsp))
-- positional: a point gets an attachment in the world, a part keeps the sound on itself
local placed, onPart = false, false
mark = #played
WorldSfx.play("blade.hit", roblox.Vector3.new(1, 2, 3))
WorldSfx.play("fist.hit", part)
for i = mark + 1, #played do
	if played[i].at == "Attachment" then
		placed = true
	elseif played[i].at == "Part" then
		onPart = true
	end
end
check(placed and onPart, "a sound at a point sits on an attachment there; one on a part rides on the part")
-- too far to hear: not made at all
mark = #played
WorldSfx.play("blade.hit", roblox.Vector3.new(5000, 0, 0))
check(#played == mark, "a sound far beyond its range is never made")

-- ── 4. every id is real-shaped ──
print("\n4. ids")
local builtIn = {}
for _, f in WorldSfx.BUILT_IN do
	builtIn[f] = true
end
local function shapeOk(v)
	if type(v) == "table" then
		v = v.id
	end
	if type(v) == "number" then
		return v > 0 and v == math.floor(v)
	end
	if type(v) == "string" then
		if string.match(v, "^rbxassetid://%d+$") or string.match(v, "^%d+$") then
			return true
		end
		local file = string.match(v, "^rbxasset://sounds/(.+)$")
		return file ~= nil and (builtIn[file] == true or WorldSfx.LEGACY_ID[string.lower(file)] ~= nil)
	end
	return false
end
bad = {}
for name, entry in Config.sfx do
	if name ~= "volume" and type(entry) ~= "boolean" and not shapeOk(entry) then
		table.insert(bad, name)
	end
end
table.sort(bad)
check(#bad == 0, "every Config.sfx entry is a number id or a built-in rbxasset:// path" .. (if #bad > 0 then " (not: " .. table.concat(bad, ", ") .. ")" else ""))
bad = {}
local nIds = 0
for _, e in WorldSfx.ids() do
	nIds += 1
	local ok = type(e.id) == "number" or (type(e.id) == "string" and builtIn[string.match(e.id, "^rbxasset://sounds/(.+)$") or ""] == true)
	if not ok or type(e.label) ~= "string" or e.label == "" then
		table.insert(bad, e.name)
	end
end
check(#bad == 0, string.format("every one of the bank's %d recordings is a number id (with its Creator Store name) or a built-in file", nIds) .. (if #bad > 0 then " (not: " .. table.concat(bad, ", ") .. ")" else ""))
check(Sfx.soundId("rbxasset://sounds/swordslash.wav") == "rbxassetid://12222216" and WorldSfx.resolveId("rbxasset://sounds/electronicpingshort.wav") == "rbxassetid://12221990",
	"the client's old sound files map onto Roblox's own uploads of them (swordslash.wav -> 12222216)")
mark = #played
WorldSfx.play("rbxasset://sounds/swordslash.wav", spot, { pitch = 2.4 })
check(#played == mark + 1 and played[#played].name == "blade.swish", "SkillFx's old slash path plays the bank's blade swish")

-- ── 5. missing audio stays quiet ──
print("\n5. quiet failures")
check(WorldSfx.play("no.such.sound", spot) == false and WorldSfx.play(nil) == false and WorldSfx.play("", spot) == false, "a name it doesn't know plays nothing (false), no error")
runFor(0.2)
playErrors = true
local failed = WorldSfx.stats.failed
local okBroken, errBroken = pcall(function()
	WorldSfx.weapon("sword", "hit", spot)
	UiSounds.play("click")
	Sfx.play("click")
end)
playErrors = false
check(okBroken and WorldSfx.stats.failed > failed, "a Sound that can't play is let go, with no error" .. (if okBroken then "" else ": " .. tostring(errBroken)))
local okNil = pcall(function()
	WorldSfx.monster("orc", "aggro", I.new("Folder"))
	WorldSfx.gate("open", nil)
end)
check(okNil, "an odd place to play from (a Folder, nothing) plays 2D or not at all, with no error")

-- ── 6. the effects volume, and loops ──
print("\n6. mix and loops")
local worldGroup = soundService:FindFirstChild("BitLevelingWorld")
check(worldGroup ~= nil and worldGroup:IsA("SoundGroup"), "the world has its own SoundGroup under SoundService")
Sfx.setVolume(0.8)
local full = worldGroup and worldGroup.Volume or 0
Sfx.setVolume(0.2)
local low = worldGroup and worldGroup.Volume or 0
Sfx.setVolume(0)
local off = worldGroup and worldGroup.Volume or 1
Sfx.setVolume(0.8)
check(full > 0 and low < full * 0.4 and off == 0, string.format("the Effects volume setting turns the world down (%.2f, %.2f at 0.2, %.2f at 0)", full, low, off))
local activeBefore = WorldSfx.activeCount()
local hum = WorldSfx.gate("hum", part, { rank = 4 })
local siren = WorldSfx.city("siren", part)
check(type(hum) == "table" and type(siren) == "table" and hum.sound and hum.sound.Looped == true, "a Gate's hum and a siren are loops riding on the Gate, with handles")
siren.PlaybackSpeed = 1.19 -- (the live city wobbles it like the old ping)
check(siren.sound.PlaybackSpeed > 1 and siren.sound.PlaybackSpeed < 1.05, "a wobbled siren gets a gentle doppler, not a warble")
local during = WorldSfx.activeCount()
siren:Destroy()
local afterSiren = WorldSfx.activeCount()
hum:stop(0.5)
local humStillFading = hum.sound.Parent ~= nil
runFor(1)
check(afterSiren == during - 1 and humStillFading and hum.sound.Parent == nil and siren.sound.Parent == nil,
	"stopping them lets go of their place (the siren at once, the hum after its fade)")
local hum2 = WorldSfx.gate("hum", part)
part:Destroy()
WorldSfx.play("blade.swish", spot)
check(hum2 and hum2.sound.Parent == nil and WorldSfx.activeCount() <= activeBefore + 1, "a loop whose Gate is destroyed lets go of its place too")
local panic = WorldSfx.city("panic", spot, { duration = 3 })
mark = #played
runFor(4)
check(type(panic) == "table" and #played - mark >= 1, "a crowd running past for a few seconds repeats, then stops by itself")

-- ── 7. the opening and the title still pass ──
if not table.find(process.args, "quick") then
	print("\n7. the opening and the title")
	for _, t in { "tests/cutscene_check", "tests/title_check" } do
		local ok, res = pcall(process.exec, "lune", { "run", t })
		if ok then
			check(res.ok, t .. " passes" .. (if res.ok then "" else ":\n" .. tostring(res.stdout) .. tostring(res.stderr)))
		else
			print("  skip  " .. t .. " (couldn't start lune: " .. tostring(res) .. ")")
		end
	end
end

if failures > 0 then
	print(string.format("\n%d check(s) failed", failures))
	process.exit(1)
end
print("\nEvery button clicks; every weapon, spell, monster, Gate and street sounds like itself, from real sounds.")
