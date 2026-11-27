--[[
	Background music by mood (Config.music). Calm on purpose: a mood holds for at least
	`hold` seconds before the ambient music may change, and big moments (fights, bosses)
	play on their own track over the top while the ambient track pauses, then the ambient
	track picks up where it left off.

		Music.start(config)
		Music.setMood("calm")         -- the ambient mood for where you are (held, not instant)
		Music.moment("battle", 60)    -- a fight: its own track until endMoment() or the time runs out
		Music.endMoment()
		Music.setEnabled(false)       -- the player's mute toggle
		Music.setVolume(0.6)          -- the player's music slider
]]

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Music = {}

local cfg = nil
local group = nil
local ambient = {} -- two Sounds that crossfade between ambient tracks
local current = 1
local momentSound = nil -- fights and bosses play here, over a paused ambient track
local mood = nil -- the ambient mood that's playing
local wanted = nil -- the ambient mood we'd like (applied when the hold runs out)
local lastSwitch = -math.huge
local momentMood = nil
local momentToken = 0
local enabled = true
local lastTrack = {}
local started = false

local playerVolume = 0.6 -- the player's music slider (0-1); 0.6 plays at the configured volume

local function volume(): number
	return if enabled then (cfg.volume or 0.35) * (playerVolume / 0.6) else 0
end

local function fadeTo(sound, target: number, seconds: number)
	local ok = pcall(function()
		TweenService:Create(sound, TweenInfo.new(seconds, Enum.EasingStyle.Sine), { Volume = target }):Play()
	end)
	if not ok then
		sound.Volume = target
	end
end

local function pick(name: string): number?
	local list = cfg.moods and cfg.moods[name]
	if not list or #list == 0 then
		return nil
	end
	if #list == 1 then
		return list[1]
	end
	local id = list[math.random(1, #list)]
	if id == lastTrack[name] then
		id = list[(table.find(list, id) or 1) % #list + 1]
	end
	lastTrack[name] = id
	return id
end

-- start a new ambient track in `name`, crossfading from the old one
local function playAmbient(name: string)
	local id = pick(name)
	if not id then
		return
	end
	mood = name
	lastSwitch = os.clock()
	local old = ambient[current]
	current = if current == 1 then 2 else 1
	local new = ambient[current]
	new.SoundId = "rbxassetid://" .. tostring(id)
	new.Volume = 0
	new.TimePosition = 0
	pcall(function()
		new:Play()
	end)
	if momentMood then
		-- a fight is on: start quietly underneath, it comes up when the fight ends
		pcall(function()
			new:Pause()
		end)
	else
		fadeTo(new, volume(), cfg.fade or 2.5)
	end
	fadeTo(old, 0, cfg.fade or 2.5)
	task.delay((cfg.fade or 2.5) + 0.1, function()
		if ambient[current] ~= old then
			pcall(function()
				old:Stop()
			end)
		end
	end)
end

local function hold(): number
	return cfg.hold or 90
end

-- switch to the wanted mood if the current one has had its time
local function settle()
	if not started or momentMood or not wanted or wanted == mood then
		return
	end
	if os.clock() - lastSwitch >= hold() then
		playAmbient(wanted)
	end
end

function Music.start(config)
	if started or not config or config.enabled == false then
		return
	end
	started = true
	cfg = config
	group = Instance.new("SoundGroup")
	group.Name = "LifeSimMusic"
	group.Parent = SoundService
	for i = 1, 2 do
		local s = Instance.new("Sound")
		s.Name = "Ambient" .. i
		s.Volume = 0
		s.Looped = false
		s.SoundGroup = group
		s.Parent = group
		ambient[i] = s
		-- a track that ends is followed by the wanted mood (or another track of this one)
		pcall(function()
			s.Ended:Connect(function()
				if ambient[current] == s and not momentMood then
					playAmbient(wanted or mood or "semi")
				end
			end)
		end)
	end
	momentSound = Instance.new("Sound")
	momentSound.Name = "Moment"
	momentSound.Volume = 0
	momentSound.Looped = true
	momentSound.SoundGroup = group
	momentSound.Parent = group
	-- check the hold now and then, so a wanted mood isn't stuck behind a long track
	task.spawn(function()
		while started do
			task.wait(10)
			settle()
		end
	end)
end

-- The ambient mood for where the player is. The first one plays at once; after that a
-- mood holds for `hold` seconds (Config.music.hold) before it may change.
function Music.setMood(name: string?)
	if not started or not name then
		return
	end
	wanted = name
	if mood == nil then
		if not momentMood then
			playAmbient(name)
		end
		return
	end
	settle()
end

-- Plays a mood right away, skipping the hold (the intro and the death screen use this).
function Music.cut(name: string?)
	if not started or not name or momentMood then
		return
	end
	wanted = name
	if name ~= mood then
		playAmbient(name)
	end
end

-- A fight or a boss: its own track over the top; the ambient track pauses underneath.
function Music.moment(name: string, seconds: number?)
	if not started or not name then
		return
	end
	local id = pick(name)
	if not id then
		return
	end
	momentToken += 1
	local token = momentToken
	if momentMood ~= name then
		momentMood = name
		momentSound.SoundId = "rbxassetid://" .. tostring(id)
		momentSound.Volume = 0
		momentSound.TimePosition = 0
		pcall(function()
			momentSound:Play()
		end)
	end
	fadeTo(momentSound, volume(), 0.8)
	local amb = ambient[current]
	fadeTo(amb, 0, 0.8)
	task.delay(0.85, function()
		if momentMood and momentToken == token then
			pcall(function()
				amb:Pause()
			end)
		end
	end)
	task.delay((seconds or 60) + 0.05, function()
		if momentToken == token then
			Music.endMoment()
		end
	end)
end

-- Ends a moment: the fight track fades out and the ambient track resumes where it was.
function Music.endMoment()
	if not started or not momentMood then
		return
	end
	momentMood = nil
	momentToken += 1
	fadeTo(momentSound, 0, 1.5)
	task.delay(1.6, function()
		if not momentMood then
			pcall(function()
				momentSound:Stop()
			end)
		end
	end)
	local amb = ambient[current]
	pcall(function()
		amb:Resume()
	end)
	fadeTo(amb, volume(), 2)
	settle()
end

function Music.setEnabled(on: boolean)
	enabled = on
	if not started then
		return
	end
	if momentMood then
		fadeTo(momentSound, volume(), 0.4)
	else
		fadeTo(ambient[current], volume(), 0.4)
	end
end

-- The player's music volume (0-1), from the settings slider.
function Music.setVolume(v: number)
	playerVolume = math.clamp(v, 0, 1)
	if not started then
		return
	end
	if momentMood then
		fadeTo(momentSound, volume(), 0.3)
	elseif ambient[current] then
		fadeTo(ambient[current], volume(), 0.3)
	end
end

function Music.isEnabled(): boolean
	return enabled
end

-- (v0.18) a big moment (a heavy blow, a boss's new phase): the music dips under it, then comes
-- back up over `seconds`
local duckToken = 0
function Music.duck(amount: number, seconds: number)
	local g = group
	if not g then
		return
	end
	duckToken += 1
	local mine = duckToken
	g.Volume = math.clamp(1 - amount, 0.2, 1)
	task.delay(math.max(0.08, seconds * 0.35), function()
		if mine ~= duckToken or not g.Parent then
			return
		end
		pcall(function()
			game:GetService("TweenService"):Create(g, TweenInfo.new(seconds * 0.65, Enum.EasingStyle.Sine), { Volume = 1 }):Play()
		end)
	end)
end

return Music
