--[[
	ARENA (v0.18): a fight on the real 3D stage (UI/World3D.luau), for the boss battle and the
	duel screens. A set from the cutscenes (UI/Stage.luau), the fighters facing off (your side
	on the left, theirs on the right), a camera that fits them into the part of the screen the
	GUI leaves free, and every blow played with real effects (UI/Fx3D.luau).

	  local arena = Arena.open(ctx, root, { set, time, mood, seed, left = {who}, right = {who}, rect })
	    who = { key, name, appearance? | creature? }   rect = { x0, y0, x1, y1 } (screen fractions)
	  arena:sync(left, right)                    -- someone joined: they step onto the stage
	  arena:strike(fromKey, toKey, { heavy, crit, status, color })   -- a lunge, a slash, a hit
	  arena:clash(aKey, bKey)                    -- two strikes meet in the middle
	  arena:guard(key)  arena:heal(key)  arena:status(key, id)  arena:phase(key, color)
	  arena:down(key)   arena:victory(key)
	  arena:screenPos(key, height?) -> Vector2   -- where to put a number on the GUI
	  arena:close()

	Opening returns nil when the 3D stage isn't available (the "3D effects" setting on Lite);
	the screens then keep their ViewportFrame figures.
]]

local RunService = game:GetService("RunService")

local World3D = require(script.Parent.World3D)
local Fx3D = require(script.Parent.Fx3D)
local Stage = require(script.Parent.Stage)
-- (v0.18) the sounds, from where things happen on the stage (Sfx.at pans them)
local Sfx = nil
do
	local ok, mod = pcall(function()
		return require(script.Parent.Parent:WaitForChild("Sfx", 5))
	end)
	if ok and type(mod) == "table" then
		Sfx = mod
	end
end
local function sfxAt(name: string, pos: Vector3)
	if Sfx and Sfx.at then
		pcall(Sfx.at, name, pos)
	end
end
local function duck(amount: number, seconds: number)
	if Sfx and Sfx.duck then
		pcall(Sfx.duck, amount, seconds)
	end
end
-- each status's own sound (Config.sfx), and what a heavy blow adds
local STATUS_SFX = { burn = "burn", tremor = "tremorBurst", rupture = "pierce", bleed = "slash", sinking = "shatter", poise = "crit", charge = "crit" }

local Arena = {}
Arena.__index = Arena

local FOV = 36

-- a set that suits a boss (bosses carry no scene art of their own)
function Arena.setFor(bossId: string?, enemy): string
	local id = string.lower(bossId or "")
	local function has(s: string): boolean
		return string.find(id, s, 1, true) ~= nil
	end
	-- (blueprint) a game's own places say which bosses fight there (spec.places[].bosses)
	for _, pair in Stage.bossPlaces or {} do
		if has(pair[1]) then
			return pair[2]
		end
	end
	if has("clock") or has("claw") or has("index") or has("messenger") then
		return if has("messenger") then "plaza" else "street"
	elseif has("whale") or has("lake") then
		return "lake"
	elseif has("dock") or has("harbor") or has("pier") then
		return "docks"
	elseif has("aleph") or has("lcorp") or has("breach") then
		return "facility"
	elseif has("workshop") or has("forge") or has("rhino") then
		return "factory"
	elseif has("library") or has("book") then
		return "library"
	elseif has("color") or has("lantern") then
		return "rooftop"
	elseif has("train") or has("rail") then
		return "trainyard"
	elseif has("sweeper") or has("night") or has("hunter") then
		return "alley"
	elseif has("thumb") or has("capo") then
		-- (v0.18) the Thumb collects where the money changes hands
		return ({ "alley", "warehouse", "parking", "docks" })[(#id % 4) + 1]
	elseif has("ring") or has("exhibit") or has("maestro") then
		return "hall"
	elseif enemy and enemy.kind == "creature" then
		return ({ "underpass", "sewer", "construction", "trainyard" })[(#id % 4) + 1]
	end
	-- (v0.18) anyone else is met somewhere of their own, the same place every time
	local pool = { "hall", "warehouse", "factory", "parking", "construction", "market", "bridge", "subway", "plaza" }
	local h = 0
	for i = 1, #id do
		h = (h * 31 + string.byte(id, i)) % 1000003
	end
	return pool[h % #pool + 1]
end

local function wait(seconds: number, self): boolean
	local t = 0
	while t < seconds do
		local dt = task.wait()
		t += if type(dt) == "number" and dt > 0 then dt else 0.03
		if self.closed then
			return false
		end
	end
	return true
end

function Arena.open(ctx, layer: Instance, opts)
	opts = opts or {}
	local setId = opts.set or "hall"
	local w = World3D.open(ctx, layer, { mood = opts.mood or Stage.moodFor(opts.time, setId), fov = FOV })
	if not w then
		return nil
	end
	local self = setmetatable({}, Arena)
	self.ctx = ctx
	self.w = w
	self.actors = {}
	self.order = {}
	self.auras = {}
	self.counts = { left = 0, right = 0 }
	self.closed = false
	local world = Instance.new("Model")
	world.Name = "Arena"
	world.Parent = w.folder
	self.world = world
	local ok, meta = pcall(Stage.buildSet, world, setId, opts.time or "night", nil, opts.seed)
	self.floorY = (ok and type(meta) == "table" and meta.floorY) or 0
	self.rect = opts.rect or { 0.02, 0.2, 0.98, 0.62 }
	self:sync(opts.left or {}, opts.right or {})
	-- the clock: everyone breathes, auras follow, and the camera drifts a little
	local clock = 0
	self.conn = RunService.Heartbeat:Connect(function(dt)
		if self.closed then
			return
		end
		dt = math.min(dt, 1 / 15)
		clock += dt
		for _, a in self.order do
			pcall(a.update, a, dt)
		end
		for key, aura in self.auras do
			local a = self.actors[key]
			if a then
				aura.move(Vector3.new(a.x, a.y + 0.2, a.z))
			end
		end
		if self.camBase then
			local sway = CFrame.new(math.sin(clock * 0.31) * 0.12, math.sin(clock * 0.23) * 0.06, 0) * CFrame.Angles(0, math.sin(clock * 0.17) * 0.006, 0)
			self.w:setCamera(self.camBase * sway, FOV)
		end
	end)
	return self
end

-- adds anyone not on the stage yet, then fits the camera to everyone
function Arena:sync(left, right)
	local added = false
	local function add(who, side: string)
		if type(who) ~= "table" or not who.key or self.actors[who.key] then
			return
		end
		local okA, a = pcall(Stage.newActor, self.ctx, self.world, who)
		if not okA or not a then
			return
		end
		self.counts[side] += 1
		local i = self.counts[side]
		local big = math.max(0, (a.height or 5) - 6)
		local x, z
		if side == "left" then
			x = -2.9 - (i - 1) * 2.0
			z = if i == 1 then 0 elseif i % 2 == 0 then -1.3 else 1.1
		else
			x = 3.0 + big * 0.35 + (i - 1) * 2.2
			z = -big * 0.25 - (i - 1) * 1.1
		end
		a.x, a.y, a.z = x, self.floorY, z
		a.yaw = if side == "left" then Stage.FACE.right else Stage.FACE.left
		a.targetYaw = a.yaw
		a.homeX = x
		a.side = side
		a.key = who.key
		pcall(a.place, a)
		self.actors[who.key] = a
		table.insert(self.order, a)
		added = true
	end
	for _, who in left or {} do
		add(who, "left")
	end
	for _, who in right or {} do
		add(who, "right")
	end
	if added or not self.camBase then
		self:frame(self.rect)
	end
end

-- fits everyone into rect (screen fractions), looking slightly down the set
function Arena:frame(rect)
	self.rect = rect or self.rect
	local minX, maxX, maxH = math.huge, -math.huge, 4.5
	for _, a in self.order do
		minX = math.min(minX, a.x - 1.2)
		maxX = math.max(maxX, a.x + 1.2)
		maxH = math.max(maxH, a.height or 5)
	end
	if minX > maxX then
		minX, maxX = -3, 3
	end
	local center = Vector3.new((minX + maxX) / 2, self.floorY + maxH * 0.5, 0)
	local spanW = maxX - minX
	local cf = self.w:frame(center, math.max(maxH * 1.08, spanW / 2.3), self.rect, Vector3.new(0, -0.16, -1), 0.8)
	self.camBase = cf
	self.w:setCamera(cf, FOV)
	self.w:focus((cf.Position - center).Magnitude, 12)
end

function Arena:actor(key)
	return key and self.actors[key]
end

-- chest height, a touch toward the camera
function Arena:hitPos(a): Vector3
	return Vector3.new(a.x, a.y + (a.height or 5) * 0.6, a.z + 0.9)
end

-- where to put a number over someone, as a fraction of the screen
function Arena:screenPos(key, height: number?): Vector2?
	local a = self.actors[key]
	if not a then
		return nil
	end
	local p, front = self.w:project(Vector3.new(a.x, a.y + (a.height or 5) * (height or 0.85), a.z))
	return if front then p else nil
end

-- the attacker lunges in and swings; a slash crosses the target; the target flashes and reels
-- opts: { heavy, crit, status, color }
function Arena:strike(fromKey, toKey, opts)
	opts = opts or {}
	local a, b = self.actors[fromKey], self.actors[toKey]
	if not b or self.closed then
		return
	end
	local dir = 1
	if a then
		dir = if b.x > a.x then 1 else -1
		local home = a.homeX or a.x
		local reach = math.max(0.8, math.abs(b.x - home) - 2.4)
		a.strikeT = 0
		task.spawn(function()
			local t = 0
			while t < 0.15 and not self.closed do
				local dt = task.wait()
				t += if type(dt) == "number" and dt > 0 then dt else 0.03
				a.x = home + dir * reach * Stage.smooth(math.min(1, t / 0.15))
			end
			if not wait(0.2, self) then
				return
			end
			local t2 = 0
			while t2 < 0.28 and not self.closed do
				local dt = task.wait()
				t2 += if type(dt) == "number" and dt > 0 then dt else 0.03
				a.x = home + dir * reach * (1 - Stage.smooth(math.min(1, t2 / 0.28)))
			end
			a.x = home
		end)
		Fx3D.dust(self.w, Vector3.new(home, a.y, a.z))
	end
	task.delay(if a then 0.13 else 0, function()
		if self.closed then
			return
		end
		local at = self:hitPos(b)
		local from = if a then Vector3.new(b.x - dir * 1.6, a.y + (a.height or 5) * 0.8, a.z + 0.8) else at + Vector3.new(-2.2 * dir, 1.4, 0)
		Fx3D.slash(self.w, from, at, { color = opts.color, heavy = opts.heavy or opts.crit, status = opts.status })
		-- the sound of it, from where it lands: the swing, the hit, and on a heavy one the crack
		sfxAt("slash", from)
		task.delay(0.07, function()
			sfxAt(if opts.heavy or opts.crit then "blunt" else "hit", at)
			if opts.crit then
				sfxAt("crit", at)
				duck(0.5, 0.8)
			elseif opts.heavy then
				sfxAt("stagger", at)
				duck(0.35, 0.6)
			end
			if opts.status and STATUS_SFX[opts.status] then
				task.delay(0.12, function()
					sfxAt(STATUS_SFX[opts.status], at)
				end)
			end
		end)
		Fx3D.flashModel(b.model)
		b.hurtT = 0
		-- knocked back a step, then back to their mark
		local home = b.homeX or b.x
		task.spawn(function()
			local t = 0
			while t < 0.3 and not self.closed do
				local dt = task.wait()
				t += if type(dt) == "number" and dt > 0 then dt else 0.03
				local k = t / 0.3
				b.x = home + dir * 0.7 * math.sin(math.min(1, k) * math.pi)
			end
			b.x = home
		end)
		if opts.status then
			task.delay(0.16, function()
				if not self.closed then
					Fx3D.status(self.w, at, opts.status, { floor = self.floorY })
				end
			end)
		end
	end)
end

-- two strikes meet in the middle and throw each other back
function Arena:clash(aKey, bKey)
	local a, b = self.actors[aKey], self.actors[bKey]
	if not a or not b or self.closed then
		return
	end
	local mid = Vector3.new((a.x + b.x) / 2, self.floorY + math.min(a.height or 5, b.height or 5) * 0.65, (a.z + b.z) / 2 + 0.8)
	a.strikeT, b.strikeT = 0, 0
	Fx3D.anticipate(self.w, mid)
	sfxAt("clash", mid)
	task.delay(0.12, function()
		if not self.closed then
			Fx3D.impact(self.w, mid, { color = Color3.fromRGB(255, 240, 210), scale = 0.9 })
		end
	end)
end

function Arena:guard(key)
	local a = self.actors[key]
	if not a or self.closed then
		return
	end
	a.pose = "guard"
	Fx3D.guard(self.w, Vector3.new(a.x, a.y + (a.height or 5) * 0.55, a.z))
	sfxAt("guard", Vector3.new(a.x, a.y + 3, a.z))
	task.delay(1.1, function()
		if a.pose == "guard" then
			a.pose = "idle"
		end
	end)
end

function Arena:heal(key)
	local a = self.actors[key]
	if a and not self.closed then
		Fx3D.heal(self.w, Vector3.new(a.x, a.y + (a.height or 5) * 0.5, a.z + 0.5), { floor = self.floorY })
		sfxAt("resonance", Vector3.new(a.x, a.y + 3, a.z))
	end
end

function Arena:status(key, id: string?)
	local a = self.actors[key]
	if a and id and not self.closed then
		Fx3D.status(self.w, self:hitPos(a), id, { floor = self.floorY })
	end
end

-- a boss changes phase: a dark burst, and from now on an aura burns around them
function Arena:phase(key, color: Color3?)
	local a = self.actors[key]
	if not a or self.closed then
		return
	end
	color = color or Color3.fromRGB(220, 40, 52)
	Fx3D.phase(self.w, self:hitPos(a), color, { floor = self.floorY })
	sfxAt("stagger", self:hitPos(a))
	task.delay(0.1, function()
		sfxAt("ego", self:hitPos(a))
	end)
	duck(0.6, 1.4)
	if self.auras[key] then
		self.auras[key].stop()
	end
	self.auras[key] = Fx3D.aura(self.w, color :: Color3, "fire")
end

-- someone goes down
function Arena:down(key)
	local a = self.actors[key]
	if not a or self.closed then
		return
	end
	if self.auras[key] then
		self.auras[key].stop()
		self.auras[key] = nil
	end
	Fx3D.ko(self.w, self:hitPos(a))
	sfxAt("crit", self:hitPos(a))
	task.delay(0.15, function()
		sfxAt("defeat", self:hitPos(a))
	end)
	duck(0.7, 1.8)
	task.spawn(function()
		local t = 0
		while t < 0.55 and not self.closed do
			local dt = task.wait()
			t += if type(dt) == "number" and dt > 0 then dt else 0.03
			a.fall = Stage.smooth(math.min(1, t / 0.55))
		end
		a.fall = 1
		if not self.closed then
			Fx3D.dust(self.w, Vector3.new(a.x, a.y, a.z + 1.2))
		end
	end)
end

-- someone drops to one knee (a friendly duel's loser)
function Arena:kneel(key)
	local a = self.actors[key]
	if not a or self.closed then
		return
	end
	Fx3D.impact(self.w, self:hitPos(a), { scale = 0.8 })
	task.spawn(function()
		local t = 0
		while t < 0.45 and not self.closed do
			local dt = task.wait()
			t += if type(dt) == "number" and dt > 0 then dt else 0.03
			a.kneel = Stage.smooth(math.min(1, t / 0.45))
		end
		a.kneel = 1
	end)
end

function Arena:victory(key, color: Color3?)
	local a = self.actors[key]
	if not a or self.closed then
		return
	end
	a.pose = "raise"
	Fx3D.victory(self.w, Vector3.new(a.x, a.y + (a.height or 5) * 0.9, a.z + 0.5), color)
	sfxAt("clashWin", Vector3.new(a.x, a.y + 3, a.z))
end

function Arena:close()
	if self.closed then
		return
	end
	self.closed = true
	if self.conn then
		self.conn:Disconnect()
	end
	for _, aura in self.auras do
		pcall(aura.stop)
	end
	self.auras = {}
	self.w:close()
end

return Arena
