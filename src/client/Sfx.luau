--[[
	Sound effects (Config.sfx): Roblox Creator Store audio, mostly Limbus Company sounds
	the community uploaded. An empty or removed id just stays quiet.

		Sfx.start(Config.sfx)
		Sfx.play("parry")                       -- one-shot
		Sfx.play("hit", { pitch = 1.1, volume = 0.8 })
		Sfx.setVolume(0.8)                      -- the player's "Effects volume" slider (0-1)
		Sfx.at("hit", worldPos)                 -- (v0.18) from a place on the 3D stage
		Sfx.layer({ "hit", { "crit", 0.05 } })  -- (v0.18) several, a little apart
		Sfx.duck(0.4, 0.6)                      -- (v0.18) the music steps back for a big moment

	Config.sfx entries are an id (number or "rbxassetid://...") or { id = ..., volume = ... }.

	(v0.18) The mix: every effect goes through a compressor (hits land together, nothing spikes)
	and a little low-end EQ, so blows have weight. Fight sounds vary their pitch and volume a
	touch each time, so a long battle never plays the same hit twice.
]]

local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local Sfx = {}

local cfg = nil
local group = nil
local templates = {}
local lastPlayed = {}
local playerVolume = 0.8
local started = false

local MIN_GAP = 0.035 -- the same sound can't stack faster than this

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
		return text
	end
	return nil
end

function Sfx.start(config)
	if started or type(config) ~= "table" then
		return
	end
	started = true
	cfg = config
	group = Instance.new("SoundGroup")
	group.Name = "LifeSimSfx"
	group.Parent = SoundService
	-- (v0.18) the mix
	pcall(function()
		local comp = Instance.new("CompressorSoundEffect")
		comp.Threshold = -18
		comp.Ratio = 3
		comp.Attack = 0.004
		comp.Release = 0.12
		comp.GainMakeup = 2.5
		comp.Parent = group
		local eq = Instance.new("EqualizerSoundEffect")
		eq.LowGain = 2.5
		eq.MidGain = 0
		eq.HighGain = 1
		eq.Parent = group
	end)
	local preload = {}
	for name, v in config do
		local id = soundId(v)
		if id and name ~= "volume" then
			local s = Instance.new("Sound")
			s.Name = name
			s.SoundId = id
			s.Volume = 0
			s.SoundGroup = group
			s.Parent = group
			templates[name] = s
			table.insert(preload, s)
		end
	end
	-- load them in the background so the first parry isn't silent
	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(preload)
		end)
	end)
end

function Sfx.has(name: string): boolean
	return templates[name] ~= nil
end

function Sfx.play(name: string, opts: { volume: number?, pitch: number? }?)
	local template = templates[name]
	if not template or playerVolume <= 0 then
		return
	end
	local now = os.clock()
	if now - (lastPlayed[name] or 0) < MIN_GAP then
		return
	end
	lastPlayed[name] = now
	local entry = cfg[name]
	local base = (if type(entry) == "table" and entry.volume then entry.volume else (cfg.volume or 0.5))
	local s = template:Clone()
	local spread = VARIED[name] or 0
	local wobble = if spread > 0 then 1 + (math.random() * 2 - 1) * spread else 1
	s.Volume = base * (playerVolume / 0.8) * ((opts and opts.volume) or 1) * (if spread > 0 then 0.92 + math.random() * 0.16 else 1)
	s.PlaybackSpeed = ((opts and opts.pitch) or 1) * wobble
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
end

function Sfx.setVolume(v: number)
	playerVolume = math.clamp(v, 0, 1)
end

-- (v0.18) a sound from a place in the world (the 3D stage): it pans and fades with distance
function Sfx.at(name: string, pos: Vector3, opts: { volume: number?, pitch: number? }?)
	if not templates[name] or playerVolume <= 0 then
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

return Sfx
