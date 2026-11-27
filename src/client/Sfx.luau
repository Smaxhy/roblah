--[[
	Sound effects (Config.sfx): the mix, the one-shots the app plays by name, and (BitLeveling)
	the layered voice engine that client/UiSounds and client/WorldSfx are built on.

		Sfx.start(Config.sfx)
		Sfx.play("parry")                       -- one-shot by name
		Sfx.play("hit", { pitch = 1.1, volume = 0.8 })
		Sfx.setVolume(0.8)                      -- the player's "Effects volume" slider (0-1)
		Sfx.at("hit", worldPos)                 -- (v0.18) from a place on the 3D stage
		Sfx.layer({ "hit", { "crit", 0.05 } })  -- (v0.18) several, a little apart
		Sfx.duck(0.4, 0.6)                      -- (v0.18) the music steps back for a big moment

	Config.sfx entries are an id (number or "rbxassetid://..."), an engine path
	("rbxasset://sounds/..."), or { id = ..., volume = ..., pitch = ..., gain = ..., lazy = ... }.
	Where each one comes from is written next to it in Config and in docs/SFX.md.

	(BitLeveling) The client's old sound files (rbxasset://sounds/swordslash.wav and the rest of
	the 2009 set) are no longer in the Roblox client's content folder; Roblox uploaded the same
	files as assets back then. Any of those paths given here plays Roblox's upload of it
	(Sfx.LEGACY), so older code that names them is heard again.

	(v0.18) The mix: every effect goes through a compressor (hits land together, nothing spikes)
	and a little low-end EQ, so blows have weight. Fight sounds vary their pitch and volume a
	touch each time, so a long battle never plays the same hit twice.

	(BitLeveling) THE VOICE ENGINE. A sound is built from layers of the few sources we know are
	real (Config.sfx), each pitched, sliced, swept and coloured so one source makes many sounds:

		Sfx.recipe({ layers = {
			{ src = "boom", vol = 0.6, pitch = { 0.5, 0.6 }, len = 1.2, fade = 0.4 },
			{ src = "wind", vol = 0.3, pitch = 0.4, sweep = { to = 2.5, time = 0.8 }, fx = { flange = { 0.4, 0.6, 0.6 } } },
			{ src = "chime", vol = 0.2, pitch = 0.5, delay = 0.1, chance = 0.6 },
		}, far = 260, prio = 2 }, at, { volume = 1, pitch = 1 })

	A layer: src (a Config.sfx name), vol, pitch (a number or a { lo, hi } range), vary (extra
	pitch spread, default 0.03), volVary (default 0.08), delay (+ jitter), len (stop after this
	long, with a fade), attack (fade in), offset (start this far in; a range picks a different
	slice every time), sweep { to, time } (glide the pitch), lfo { to, period } (wobble the pitch
	back and forth: sirens, Gate hums), loop, fx { dist, trem = { hz, depth }, flange = { rate,
	depth, mix }, chorus = {...}, echo = { delay, feedback, wet }, reverb = { decay, wet },
	eq = { low, mid, high }, shift = octave }, chance, rep / gap (the same layer again, a beat
	later), any = { layer, layer } (one of them, at random). Nothing plays the same way twice.

	`at` is nil (in your ears), a Vector3 or CFrame (a point in the world), or a BasePart,
	Attachment or Model (it follows the thing). A sound too far from the camera isn't made.
	At most MAX_VOICES play at once per bus; a more important sound takes the place of the oldest
	less important one, a less important one waits its turn (it's dropped).

	Missing or removed audio stays quiet: every call is guarded, and a Config sound that fails to
	load can have a stand-in (Sfx.standIn) built from the sounds that did.
]]

local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Sfx = {}

local cfg = nil
local group = nil
local templates = {}
local entries = {} -- name -> { id, volume, pitch }
local lastPlayed = {}
local playerVolume = 0.8
local started = false
local missing = {} -- names whose sound failed to load
local defined = {} -- name -> composite cue (UiSounds/WorldSfx register these)
local standIns = {} -- name -> cue played when that name's own sound failed to load
local volumeListeners = {}
local buses: { [string]: any } = {} -- "ui" | "world" -> SoundGroup
local voices = {} -- the sounds the engine is playing: { s, prio, t, bus, loop }
local lastAny = 0

local MIN_GAP = 0.035 -- the same sound can't stack faster than this
Sfx.MAX_VOICES = { ui = 12, world = 32 }

-- (BitLeveling) the client's old content/sounds files, which today's client no longer ships
-- (its rbxManifest.txt lists 11 files there, none of these), mapped to Roblox's own uploads of
-- the same files: creator Roblox (1), each asset's description is its old path, "\sounds\<file>".
Sfx.LEGACY = {
	["swordslash.wav"] = 12222216,
	["swordlunge.wav"] = 12222208,
	["unsheath.wav"] = 12222225,
	["electronicpingshort.wav"] = 12221990,
	["collide.wav"] = 12221984,
	["hit.wav"] = 12222046,
	["swoosh.wav"] = 12222200,
	["glassbreak.wav"] = 12222005,
	["halloweenthunder.wav"] = 12222030,
	["halloweenlightning.wav"] = 12222019,
	["rocket whoosh 01.wav"] = 12222095,
	["rocket shot.wav"] = 12222084,
	["launching rocket.wav"] = 12222065,
	["shoulder fired rocket.wav"] = 12222132,
	["rubber band sling shot.wav"] = 12222103,
	["short spring sound.wav"] = 12222124,
	["victory.wav"] = 12222253,
	["pageturn.wav"] = 12222076,
	["switch.wav"] = 12222170,
	["switch3.wav"] = 12222183,
	["snap.wav"] = 12222140,
	["splat.wav"] = 12222152,
	["kerplunk.wav"] = 12222054,
	["flashbulb.wav"] = 12221996,
	["button.wav"] = 12221967,
	["clickfast.wav"] = 12221976,
	["bass.wav"] = 12221944,
	["paintball.wav"] = 11900833,
}

-- (v0.18) the sounds of a fight: each play is a little different (pitch, level)
local VARIED = {
	coin = 0.06, tails = 0.06, clash = 0.05, clashWin = 0.03, parry = 0.05, evade = 0.06, guard = 0.05, hit = 0.08, slash = 0.08,
	pierce = 0.08, blunt = 0.08, crit = 0.05, stagger = 0.05, tremorBurst = 0.06, burn = 0.06, click = 0.04, confirm = 0.03,
}
local ducker = nil -- (set by Sfx.setDucker: the music's own fader)

local function soundId(raw: any): string?
	local v: any = if type(raw) == "table" then raw.id else raw
	if type(v) == "number" then
		return "rbxassetid://" .. tostring(v)
	end
	if type(v) == "string" and v ~= "" then
		local text: string = v
		if string.match(text, "^%d+$") then
			return "rbxassetid://" .. text
		end
		-- an old engine file that isn't in the client any more: Roblox's upload of it
		local file = string.match(string.lower(text), "^rbxasset://sounds[/\\](.+)$")
		if file and Sfx.LEGACY[file] then
			return "rbxassetid://" .. tostring(Sfx.LEGACY[file])
		end
		return text
	end
	return nil
end
Sfx.soundId = soundId

local function readEntry(name: string, raw: any)
	local id = soundId(raw)
	if not id then
		return
	end
	local t = type(raw) == "table"
	entries[name] = {
		id = id,
		volume = if t and type(raw.volume) == "number" then raw.volume else nil,
		pitch = if t and type(raw.pitch) == "number" then raw.pitch else 1,
		gain = if t and type(raw.gain) == "number" then raw.gain else 1,
		lazy = t and raw.lazy == true,
	}
end

-- a Config.sfx name's entry ({ id, volume, pitch, gain, lazy }), for tests and tools
function Sfx.entry(name: string): any?
	return entries[name]
end
-- every name Config.sfx gave (sorted)
function Sfx.names(): { string }
	local out = {}
	for name in entries do
		table.insert(out, name)
	end
	table.sort(out)
	return out
end

local function newGroup(name: string, withMix: boolean): SoundGroup?
	local ok, g = pcall(function()
		local sg = Instance.new("SoundGroup")
		sg.Name = name
		if withMix then
			local comp = Instance.new("CompressorSoundEffect")
			comp.Threshold = -18
			comp.Ratio = 3
			comp.Attack = 0.004
			comp.Release = 0.12
			comp.GainMakeup = 2.5
			comp.Parent = sg
		end
		sg.Parent = SoundService
		return sg
	end)
	return if ok then g else nil
end

function Sfx.start(config)
	if started or type(config) ~= "table" then
		return
	end
	started = true
	cfg = config
	group = newGroup("LifeSimSfx", true)
	-- (v0.18) the mix
	pcall(function()
		local eq = Instance.new("EqualizerSoundEffect")
		eq.LowGain = 2.5
		eq.MidGain = 0
		eq.HighGain = 1
		eq.Parent = group
	end)
	-- (BitLeveling) the app's named sounds and the short sources get a template (loaded in the
	-- background, the app's own first); long loops and ambiences ("lazy") load when first played
	local first, rest = {}, {}
	local byId = {}
	local names = {}
	for name in config do
		if name ~= "volume" then
			table.insert(names, name)
		end
	end
	table.sort(names)
	for _, name in names do
		readEntry(name, config[name])
		local e = entries[name]
		if e then
			byId[e.id] = byId[e.id] or {}
			table.insert(byId[e.id], name)
			if not e.lazy then
				pcall(function()
					local s = Instance.new("Sound")
					s.Name = name
					s.SoundId = e.id
					s.Volume = 0
					s.SoundGroup = group
					s.Parent = group
					templates[name] = s
					table.insert(if string.find(name, "_", 1, true) then rest else first, s)
				end)
			end
		end
	end
	-- load them in the background so the first parry isn't silent; one that can't load (taken
	-- down, or not in this client) is marked missing, its layers drop out and its stand-in plays
	local function onFetched(contentId: string, status: any)
		local ok, bad = pcall(function()
			return status ~= Enum.AssetFetchStatus.Success
		end)
		if ok and bad then
			for _, n in byId[contentId] or {} do
				missing[n] = true
			end
		end
	end
	local function preload(list: { any })
		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync(list, onFetched)
			end)
		end)
	end
	preload(first)
	-- the sources, a batch every quarter second, so the start isn't one big download
	local function batchFrom(i: number)
		if i > #rest then
			return
		end
		local batch = {}
		for k = i, math.min(i + 23, #rest) do
			table.insert(batch, rest[k])
		end
		preload(batch)
		task.delay(0.25, batchFrom, i + 24)
	end
	task.delay(0.5, batchFrom, 1)
end

-- (BitLeveling) a lazy source is checked the first time it plays: one that fails to load is
-- marked missing like the others
local function watchLoad(s: any, src: string)
	task.delay(8, function()
		pcall(function()
			if s.Parent and not s.IsLoaded and s.TimeLength == 0 then
				missing[src] = true
			end
		end)
	end)
end

function Sfx.started(): boolean
	return started
end

function Sfx.has(name: string): boolean
	return templates[name] ~= nil or defined[name] ~= nil
end

-- the sound id a Config.sfx name (or a raw id/path) stands for
function Sfx.source(name: string): string?
	local e = entries[name]
	if e then
		return e.id
	end
	if cfg == nil or cfg[name] == nil then
		-- a raw id or engine path given directly
		if type(name) == "string" and (string.match(name, "^rbxasset") or string.match(name, "^%d+$")) then
			return soundId(name)
		end
	end
	return nil
end

function Sfx.isMissing(name: string): boolean
	return missing[name] == true
end
function Sfx.markMissing(name: string, gone: boolean?)
	missing[name] = if gone == false then nil else true
end

-- (BitLeveling) a composite cue: Sfx.play(name) calls fn(opts) instead of the one sound
function Sfx.define(name: string, fn: ((any?) -> ())?)
	defined[name] = fn
end
-- a cue for when that name's own sound failed to load (a kit sound that was taken down)
function Sfx.standIn(name: string, fn: ((any?) -> ())?)
	standIns[name] = fn
end

-- when anything last played by name (UiSounds lets an app's own sound lead over its click)
function Sfx.lastAny(): number
	return lastAny
end

function Sfx.play(name: string, opts: { volume: number?, pitch: number? }?)
	if playerVolume <= 0 then
		return
	end
	local now = os.clock()
	if now - (lastPlayed[name] or 0) < MIN_GAP then
		return
	end
	local cue = defined[name] or (if missing[name] or not templates[name] then standIns[name] else nil)
	if cue then
		lastPlayed[name] = now
		lastAny = now
		local ok, err = pcall(cue, opts)
		if not ok then
			warn("[Sfx] " .. name .. ": " .. tostring(err))
		end
		return
	end
	local template = templates[name]
	if not template then
		return
	end
	lastPlayed[name] = now
	lastAny = now
	local entry = cfg[name]
	local e = entries[name]
	local base = (if type(entry) == "table" and entry.volume then entry.volume else (cfg.volume or 0.5))
	pcall(function()
		local s = template:Clone()
		local spread = VARIED[name] or 0
		local wobble = if spread > 0 then 1 + (math.random() * 2 - 1) * spread else 1
		s.Volume = base * (playerVolume / 0.8) * ((opts and opts.volume) or 1) * (if spread > 0 then 0.92 + math.random() * 0.16 else 1)
		s.PlaybackSpeed = ((opts and opts.pitch) or 1) * wobble * (if e then e.pitch else 1)
		s.Parent = (opts and (opts :: any).parent) or group
		pcall(function()
			s:Play()
		end)
		-- clean up when it's done (or after a while, if Ended never fires)
		pcall(function()
			s.Ended:Once(function()
				s:Destroy()
			end)
		end)
		task.delay(12, function()
			if s.Parent then
				s:Destroy()
			end
		end)
	end)
end

function Sfx.setVolume(v: number)
	playerVolume = math.clamp(v, 0, 1)
	-- loops (Gate hums, sirens) follow the slider at once
	for _, vc in voices do
		if vc.loop and vc.base then
			pcall(function()
				vc.s.Volume = vc.base * (playerVolume / 0.8)
			end)
		end
	end
	for _, fn in volumeListeners do
		pcall(fn, playerVolume)
	end
end
function Sfx.getVolume(): number
	return playerVolume
end
-- the player's level as a gain: 1 at the default (0.8)
function Sfx.gain(): number
	return playerVolume / 0.8
end
function Sfx.onVolume(fn: (number) -> ()): { Disconnect: () -> () }
	table.insert(volumeListeners, fn)
	return {
		Disconnect = function()
			local i = table.find(volumeListeners, fn)
			if i then
				table.remove(volumeListeners, i)
			end
		end,
	}
end

-- (v0.18) a sound from a place in the world (the 3D stage): it pans and fades with distance
function Sfx.at(name: string, pos: Vector3, opts: { volume: number?, pitch: number? }?)
	if playerVolume <= 0 then
		return
	end
	local cue = defined[name] or (if missing[name] or not templates[name] then standIns[name] else nil)
	if cue then
		local o = table.clone(opts or {}) :: any
		o.at = pos
		local now = os.clock()
		if now - (lastPlayed[name] or 0) < MIN_GAP then
			return
		end
		lastPlayed[name] = now
		pcall(cue, o)
		return
	end
	if not templates[name] then
		return
	end
	local ok = pcall(function()
		local holder = Instance.new("Part")
		holder.Name = "SfxAt"
		holder.Anchored = true
		holder.CanCollide = false
		holder.CanQuery = false
		holder.CanTouch = false
		holder.Transparency = 1
		holder.Size = Vector3.new(0.2, 0.2, 0.2)
		holder.CFrame = CFrame.new(pos)
		holder.Parent = workspace
		local spot = Instance.new("Attachment")
		spot.Parent = holder
		task.delay(8, function()
			pcall(holder.Destroy, holder)
		end)
		local o = table.clone(opts or {}) :: any
		o.volume = (o.volume or 1) * 1.6 -- (heard from a few studs away, not in your ear)
		o.parent = spot
		Sfx.play(name, o)
		for _, s in spot:GetChildren() do
			if s:IsA("Sound") then
				s.SoundGroup = group
				s.RollOffMode = Enum.RollOffMode.InverseTapered
				s.RollOffMinDistance = 14
				s.RollOffMaxDistance = 160
			end
		end
	end)
	if not ok then
		Sfx.play(name, opts)
	end
end

-- (v0.18) a few sounds, each at its own small delay: { "hit", { "crit", 0.05 }, ... }
function Sfx.layer(list, pos: Vector3?)
	for _, e in list do
		local name, delay = (if type(e) == "table" then e[1] else e), (if type(e) == "table" then e[2] else 0)
		local function go()
			if pos then
				Sfx.at(name, pos)
			else
				Sfx.play(name)
			end
		end
		if delay and delay > 0 then
			task.delay(delay, go)
		else
			go()
		end
	end
end

-- (v0.18) the music steps back for a big moment, then comes back
function Sfx.setDucker(fn)
	ducker = fn
end
function Sfx.duck(amount: number?, seconds: number?)
	if ducker then
		pcall(ducker, amount or 0.4, seconds or 0.6)
	end
end

-- ═════════════════════════════════════════════════════════════════════════════
-- (BitLeveling) the voice engine
-- ═════════════════════════════════════════════════════════════════════════════

-- the buses: "ui" is the app's own group (the v0.18 mix); "world" has its own compressor and a
-- little room, so the 3D city's sounds sit together
function Sfx.bus(name: string?): SoundGroup?
	if name ~= "world" then
		if not group then
			group = newGroup("LifeSimSfx", true)
		end
		return group
	end
	if buses.world == nil then
		buses.world = newGroup("WorldSfx", true) or false
		if buses.world then
			pcall(function()
				local room = Instance.new("ReverbSoundEffect")
				room.DecayTime = 1.1
				room.Density = 0.8
				room.Diffusion = 0.9
				room.DryLevel = 0
				room.WetLevel = -16
				room.Priority = -1
				room.Parent = buses.world
			end)
		end
	end
	return buses.world or nil
end

local function pick(v: any, rng: Random?): any
	if type(v) == "table" and type(v[1]) == "number" then
		local lo, hi = v[1], v[2] or v[1]
		return lo + (if rng then rng:NextNumber() else math.random()) * (hi - lo)
	end
	return v
end
Sfx.pick = pick

-- a recipe's layers made concrete: every range picked, every `any` chosen, every `rep` laid
-- out, chances rolled. (Tests read this to check a recipe resolves to real sources.)
function Sfx.expand(recipe: any, opts: any?): { any }
	local out = {}
	local layers = (recipe and recipe.layers) or recipe or {}
	local pm = (opts and opts.pitch) or 1
	local vm = (opts and opts.volume) or 1
	local function add(l: any, extraDelay: number)
		if l.any then
			local choice = l.any[math.random(1, #l.any)]
			if choice then
				add(choice, extraDelay + (l.delay or 0))
			end
			return
		end
		if l.chance and math.random() > l.chance then
			return
		end
		local reps = l.rep or 1
		for r = 1, reps do
			local vary = l.vary or 0.03
			local volVary = l.volVary or 0.08
			local c = table.clone(l)
			c.rep, c.gap, c.chance, c.any = nil, nil, nil, nil
			c.pitch = (pick(l.pitch or 1) :: number) * (1 + (math.random() * 2 - 1) * vary) * pm
			c.vol = (pick(l.vol or 0.5) :: number) * (1 + (math.random() * 2 - 1) * volVary) * vm * (if r > 1 then (l.repFall or 0.85) ^ (r - 1) else 1)
			c.delay = (pick(l.delay or 0) :: number) + extraDelay + (r - 1) * (pick(l.gap or 0.08) :: number) + (if l.jitter then math.random() * l.jitter else 0)
			c.offset = pick(l.offset or 0)
			c.len = pick(l.len)
			if l.pitchStep and r > 1 then
				c.pitch *= l.pitchStep ^ (r - 1)
			end
			table.insert(out, c)
		end
	end
	for _, l in layers do
		add(l, 0)
	end
	return out
end

local function cameraPos(): Vector3?
	local ok, p = pcall(function()
		return (Workspace :: any).CurrentCamera.CFrame.Position
	end)
	if ok and typeof(p) == "Vector3" then
		return p
	end
	return nil
end

-- where a sound comes from: a point (an attachment made for it), or a thing it follows
local function placeOf(at: any): (Vector3?, Instance?)
	local t = typeof(at)
	if t == "Vector3" then
		return at, nil
	elseif t == "CFrame" then
		return at.Position, nil
	elseif t == "Instance" then
		if at:IsA("Model") then
			local pp = at.PrimaryPart or at:FindFirstChildWhichIsA("BasePart", true)
			if pp then
				return pp.Position, pp
			end
			return nil, nil
		elseif at:IsA("Attachment") then
			local ok, wp = pcall(function()
				return at.WorldPosition
			end)
			return if ok then wp else nil, at
		elseif at:IsA("BasePart") then
			return at.Position, at
		end
	end
	return nil, nil
end
Sfx.placeOf = placeOf

local function spotAt(pos: Vector3, life: number): Instance?
	local ok, spot = pcall(function()
		local a = Instance.new("Attachment")
		a.Name = "SfxSpot"
		a.Position = pos -- (on the Terrain, whose frame is the world's)
		a.Parent = (Workspace :: any).Terrain
		return a
	end)
	if not ok or not spot then
		ok, spot = pcall(function()
			local p = Instance.new("Part")
			p.Name = "SfxSpot"
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.Transparency = 1
			p.Size = Vector3.new(0.2, 0.2, 0.2)
			p.CFrame = CFrame.new(pos)
			p.Parent = Workspace
			return p
		end)
	end
	if ok and spot then
		task.delay(life, function()
			pcall(function()
				spot:Destroy()
			end)
		end)
		return spot
	end
	return nil
end

-- a voice whose Sound is gone (its holder was destroyed: a Gate closed, a monster fell) no
-- longer counts; nor does one that has finished
local function prune()
	for i = #voices, 1, -1 do
		local v = voices[i]
		local alive = pcall(function()
			if v.s.Parent == nil then
				error("gone")
			end
		end)
		if not alive then
			table.remove(voices, i)
		end
	end
end
Sfx.prune = prune

local function busCount(bus: string): number
	local n = 0
	for _, v in voices do
		if v.bus == bus then
			n += 1
		end
	end
	return n
end
function Sfx.activeVoices(bus: string?): number
	if bus then
		return busCount(bus)
	end
	return #voices
end

local function forget(s: any)
	for i = #voices, 1, -1 do
		if voices[i].s == s then
			table.remove(voices, i)
		end
	end
end

local function kill(s: any)
	forget(s)
	pcall(function()
		s:Stop()
	end)
	pcall(function()
		s:Destroy()
	end)
end

-- room for one more on this bus? (a more important sound takes an older, lesser one's place)
local function makeRoom(bus: string, prio: number): boolean
	local cap = Sfx.MAX_VOICES[bus] or 24
	if busCount(bus) < cap then
		return true
	end
	prune()
	if busCount(bus) < cap then
		return true
	end
	local victim, vi = nil, nil
	for i, v in voices do
		if v.bus == bus and not v.loop and v.prio < prio and (victim == nil or v.prio < victim.prio or (v.prio == victim.prio and v.t < victim.t)) then
			victim, vi = v, i
		end
	end
	if victim and vi then
		kill(victim.s)
		return true
	end
	return false
end

local FX = {
	dist = function(v)
		return "DistortionSoundEffect", { Level = v }
	end,
	trem = function(v)
		return "TremoloSoundEffect", { Frequency = v[1] or 5, Depth = v[2] or 0.8, Duty = v[3] or 0.5 }
	end,
	flange = function(v)
		return "FlangeSoundEffect", { Rate = v[1] or 0.5, Depth = v[2] or 0.45, Mix = v[3] or 0.6 }
	end,
	chorus = function(v)
		return "ChorusSoundEffect", { Rate = v[1] or 0.6, Depth = v[2] or 0.3, Mix = v[3] or 0.5 }
	end,
	echo = function(v)
		return "EchoSoundEffect", { Delay = v[1] or 0.18, Feedback = v[2] or 0.35, WetLevel = v[3] or -8, DryLevel = v[4] or 0 }
	end,
	reverb = function(v)
		return "ReverbSoundEffect", { DecayTime = v[1] or 2, WetLevel = v[2] or -4, DryLevel = v[3] or 0, Density = 1, Diffusion = 1 }
	end,
	eq = function(v)
		return "EqualizerSoundEffect", { LowGain = v[1] or 0, MidGain = v[2] or 0, HighGain = v[3] or 0 }
	end,
	shift = function(v)
		return "PitchShiftSoundEffect", { Octave = math.clamp(v, 0.5, 2) }
	end,
}
local FX_ORDER = { "shift", "dist", "trem", "flange", "chorus", "eq", "echo", "reverb" }

local function addFx(s: Instance, fx: any)
	if type(fx) ~= "table" then
		return
	end
	local prio = 10
	for _, key in FX_ORDER do
		local v = fx[key]
		if v ~= nil and FX[key] then
			pcall(function()
				local cls, props = FX[key](v)
				local e = Instance.new(cls)
				for k, pv in props do
					(e :: any)[k] = pv
				end
				(e :: any).Priority = prio
				e.Parent = s
			end)
			prio -= 1
		end
	end
end

-- one layer, made concrete (Sfx.expand), played: returns the Sound if it started
function Sfx.voice(l: any, holder: Instance?, meta: any?): Sound?
	if playerVolume <= 0 then
		return nil
	end
	local src = l.src
	local id = Sfx.source(src)
	if not id or missing[src] then
		return nil
	end
	meta = meta or {}
	local bus = (meta :: any).bus or "world"
	local prio = l.prio or (meta :: any).prio or 1
	if not makeRoom(bus, prio) then
		return nil
	end
	local e = entries[src]
	local s: any = nil
	local ok = pcall(function()
		local t = templates[src]
		s = if t then t:Clone() else Instance.new("Sound")
		if not t then
			s.SoundId = id
		end
		s.Name = ((meta :: any).name or "sfx") .. ":" .. tostring(src)
		if not t and e and e.lazy then
			watchLoad(s, src)
		end
		local pitch = math.clamp((l.pitch or 1) * (if e then e.pitch else 1), 0.05, 10)
		local vol = math.max(0, (l.vol or 0.5)) * (if e then e.gain else 1) * (playerVolume / 0.8)
		s.PlaybackSpeed = pitch
		s.Looped = l.loop == true
		s.Volume = if (l.attack or 0) > 0 then 0 else vol
		if l.offset and l.offset > 0 then
			s.TimePosition = l.offset
		end
		s.SoundGroup = Sfx.bus(bus)
		if holder then
			s.RollOffMode = Enum.RollOffMode.InverseTapered
			s.RollOffMinDistance = (meta :: any).near or 10
			s.RollOffMaxDistance = (meta :: any).far or 180
		end
		addFx(s, l.fx)
		s.Parent = holder or Sfx.bus(bus)
		local entry = { s = s, prio = prio, t = os.clock(), bus = bus, loop = l.loop == true, base = vol / math.max(playerVolume / 0.8, 1e-6) }
		table.insert(voices, entry)
		pcall(function()
			s:Play()
		end)
		-- the shape of it: fade in, glide the pitch, wobble it, stop after a while
		if (l.attack or 0) > 0 then
			pcall(function()
				TweenService:Create(s, TweenInfo.new(l.attack, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Volume = vol }):Play()
			end)
		end
		if l.sweep then
			pcall(function()
				TweenService:Create(s, TweenInfo.new(l.sweep.time or 0.5, (Enum.EasingStyle :: any)[l.sweep.style or "Quad"], Enum.EasingDirection.InOut), { PlaybackSpeed = pitch * (l.sweep.to or 1) }):Play()
			end)
		end
		if l.lfo then
			pcall(function()
				TweenService:Create(s, TweenInfo.new((l.lfo.period or 1) / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { PlaybackSpeed = pitch * (l.lfo.to or 1.1) }):Play()
			end)
		end
		if not l.loop then
			local len = l.len
			local life = if len then len + (l.fade or 0.06) else (l.life or 4) / math.max(pitch, 0.25)
			if len then
				task.delay(len, function()
					pcall(function()
						TweenService:Create(s, TweenInfo.new(l.fade or 0.06, Enum.EasingStyle.Linear), { Volume = 0 }):Play()
					end)
				end)
			end
			pcall(function()
				s.Ended:Once(function()
					kill(s)
				end)
			end)
			task.delay(math.min(life + 0.15, 16), function()
				kill(s)
			end)
		end
	end)
	if not ok then
		if s then
			kill(s)
		end
		return nil
	end
	return s
end

-- a loop's handle: stop it (with a fade), set how strong it is (0-1)
local function handleFor(holder: Instance?, ownsHolder: boolean): any
	local sounds, specs = {}, {}
	local h = { sounds = sounds, specs = specs, alive = true }
	function h.add(s: any, l: any)
		if not h.alive then
			kill(s)
			return
		end
		table.insert(sounds, s)
		table.insert(specs, l)
	end
	function h.set(_, k: number)
		k = math.clamp(k, 0, 1.5)
		h.level = k
		for i, s in sounds do
			local l = specs[i]
			if l and s then
				pcall(function()
					local se = entries[l.src]
					local vol = (l.vol or 0.5) * (if se then se.gain else 1) * (l.setVol and (l.setVol[1] + (l.setVol[2] - l.setVol[1]) * k) or 1) * (playerVolume / 0.8)
					for _, v in voices do
						if v.s == s then
							v.base = vol / (playerVolume / 0.8)
						end
					end
					TweenService:Create(s, TweenInfo.new(0.4), { Volume = vol }):Play()
					if l.setPitch then
						s.PlaybackSpeed = (l.pitch or 1) * (l.setPitch[1] + (l.setPitch[2] - l.setPitch[1]) * k)
					end
				end)
			end
		end
	end
	function h.stop(_, fade: number?)
		if not h.alive then
			return
		end
		h.alive = false
		local f = fade or 0.4
		for _, s in sounds do
			forget(s)
			pcall(function()
				TweenService:Create(s, TweenInfo.new(f, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Volume = 0 }):Play()
			end)
			task.delay(f + 0.05, function()
				kill(s)
			end)
		end
		if ownsHolder and holder then
			task.delay(f + 0.1, function()
				pcall(function()
					holder:Destroy()
				end)
			end)
		end
	end
	return h
end

local recent = {} -- key -> { t, pos } (the same cue, the same place, the same instant: once)

-- a whole recipe: every layer, at a place or in your ears. Returns a handle when it loops.
function Sfx.recipe(recipe: any, at: any?, opts: any?): any?
	if playerVolume <= 0 or type(recipe) ~= "table" then
		return nil
	end
	opts = opts or {}
	local o = opts :: any
	local layers = Sfx.expand(recipe, o)
	if #layers == 0 then
		return nil
	end
	local pos, follow = placeOf(at)
	local far = o.far or recipe.far or 180
	local near = o.near or recipe.near or 10
	-- too far to hear: not made at all
	if pos then
		local cam = cameraPos()
		if cam and (cam - pos).Magnitude > far + 12 and not o.always then
			return nil
		end
	end
	local key = o.key or recipe.key
	if key then
		local now = os.clock()
		local r = recent[key]
		if r and now - r.t < (recipe.gap or 0.03) and (not pos or not r.pos or (r.pos - pos).Magnitude < 4) then
			return nil
		end
		recent[key] = { t = now, pos = pos }
	end
	local loops = false
	local longest = 0.5
	for _, l in layers do
		if l.loop then
			loops = true
		end
		longest = math.max(longest, (l.delay or 0) + (l.len or (l.life or 4) / math.max(l.pitch or 1, 0.25)) + (l.fade or 0.06))
	end
	local holder: Instance? = follow
	local ownsHolder = false
	if pos and not follow then
		holder = spotAt(pos, if loops then 3600 else math.min(longest + 0.6, 17))
		ownsHolder = true
	end
	local meta = { bus = o.bus or recipe.bus or (if holder then "world" else "ui"), prio = o.prio or recipe.prio or 1, near = near, far = far, name = o.name or recipe.name }
	if recipe.duck then
		Sfx.duck(recipe.duck[1], recipe.duck[2])
	end
	local h = if loops then handleFor(holder, ownsHolder) else nil
	for _, l in layers do
		local function go()
			local s = Sfx.voice(l, holder, meta)
			if s and l.loop and h then
				h.add(s, l) -- (a loop that starts late still belongs to the handle)
			end
		end
		if (l.delay or 0) > 0.001 then
			task.delay(l.delay, go)
		else
			go()
		end
	end
	return h
end

-- stop every loop the engine is playing (the opening ends, the player leaves the city)
function Sfx.stopLoops(fade: number?)
	for i = #voices, 1, -1 do
		local v = voices[i]
		if v.loop then
			local s = v.s
			table.remove(voices, i)
			pcall(function()
				TweenService:Create(s, TweenInfo.new(fade or 0.4), { Volume = 0 }):Play()
			end)
			task.delay((fade or 0.4) + 0.05, function()
				kill(s)
			end)
		end
	end
end

return Sfx
