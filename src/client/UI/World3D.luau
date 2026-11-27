--[[
	WORLD3D (v0.18): a real 3D stage in the Workspace, behind the GUI.

	Roblox only draws its own effects (ParticleEmitters, Beams, Trails, lights, Bloom, depth of
	field, Highlights) in the Workspace; a ViewportFrame draws none of them. So the moments that
	deserve real effects (boss battles, duels, cutscenes) put their set and their people here,
	at the world's origin (both backdrop cities are 8,500 studs away, lost in the fog), script
	the camera onto it, and the HUD steps aside while it's up. Closing puts everything back: the
	camera (the backdrop takes it again), the light, the HUD.

	  local w = World3D.open(ctx, layer, { mood = "night" })   -- nil when it can't (Lite)
	  w.folder                       -- parent models here (world coordinates; origin = 0,0,0)
	  w:setCamera(cf, fov?)          -- where the camera is (its shake and punch go on top)
	  w:focus(distance)              -- the depth of field's focus
	  w:shake("light"|"medium"|"heavy"|"huge")      (RbxCameraShaker, vendored)
	  w:punch(degrees)               -- a field-of-view punch that springs back
	  w:impactFrame("black"|"white") -- one or two frames of an anime impact frame
	  w:tint(color, seconds)         -- the whole screen pulled toward a colour, briefly
	  w:project(worldPos)            -- where a point is on screen (0-1), and if it's in front
	  w:close()

	Worlds stack: a cutscene opened over a battle hides the battle's stage until it closes.
	Screen shake and flashes follow the player's "Screen shake and flashes" setting.
]]

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local World3D = {}
World3D.__index = World3D

local CameraShaker = nil
do
	local ok, mod = pcall(function()
		return require(script.Parent.Parent:WaitForChild("Vendor", 5):WaitForChild("CameraShaker", 5))
	end)
	if ok and type(mod) == "table" then
		CameraShaker = mod
	end
end

local STEP_NAME = "LifeSimWorld3D"
local STEP_PRIORITY = Enum.RenderPriority.Camera.Value + 10 -- after the backdrop's camera (Camera + 1)
local SHAKE_PRIORITY = Enum.RenderPriority.Camera.Value + 9

-- The light for each kind of scene. clock: Lighting.ClockTime; the rest tune the light and the
-- grade (a ColorCorrectionEffect of our own) and how much the Neon parts bloom.
local MOODS = {
	-- (v0.18) the dark moods stay dark in the sky and lit on the people: at midnight Roblox lights a
	-- figure mostly by Ambient, and the old values left fighters nearly black
	night = { clock = 0.4, brightness = 2.2, ambient = { 112, 116, 146 }, outdoor = { 132, 138, 172 }, exposure = 0.65, tint = { 228, 232, 255 }, contrast = 0.08, saturation = -0.02, bloom = { 0.9, 28, 0.92 }, key = 2.2 },
	dusk = { clock = 17.9, brightness = 2.1, ambient = { 72, 58, 62 }, outdoor = { 124, 100, 100 }, exposure = 0.1, tint = { 255, 232, 220 }, contrast = 0.1, saturation = 0.06, bloom = { 0.8, 26, 0.92 } },
	day = { clock = 13.6, brightness = 2.6, ambient = { 92, 92, 98 }, outdoor = { 128, 128, 136 }, exposure = 0, tint = { 255, 252, 244 }, contrast = 0.06, saturation = 0.05, bloom = { 0.55, 24, 0.95 } },
	inside = { clock = 13, brightness = 1.7, ambient = { 104, 100, 96 }, outdoor = { 118, 114, 108 }, exposure = 0.05, tint = { 255, 244, 228 }, contrast = 0.08, saturation = 0, bloom = { 0.7, 24, 0.93 } },
	facility = { clock = 0.6, brightness = 1.8, ambient = { 118, 136, 128 }, outdoor = { 128, 146, 138 }, exposure = 0.55, tint = { 232, 255, 242 }, contrast = 0.08, saturation = -0.06, bloom = { 1.0, 28, 0.9 }, key = 2 },
	boss = { clock = 0.3, brightness = 1.8, ambient = { 124, 92, 98 }, outdoor = { 150, 112, 118 }, exposure = 0.6, tint = { 255, 222, 218 }, contrast = 0.12, saturation = -0.02, bloom = { 1.1, 30, 0.88 }, key = 2.4 },
	distortion = { clock = 0.1, brightness = 1.6, ambient = { 112, 96, 132 }, outdoor = { 136, 118, 160 }, exposure = 0.6, tint = { 240, 228, 255 }, contrast = 0.12, saturation = -0.14, bloom = { 1.2, 30, 0.86 }, key = 2.2 },
}
World3D.MOODS = MOODS

local SHAKES = {
	-- magnitude, roughness, fade in, fade out (RbxCameraShaker), as the measured hits do
	light = { 0.45, 14, 0, 0.25 },
	medium = { 1.4, 10, 0, 0.6 },
	heavy = { 3.2, 8, 0, 1.1 },
	huge = { 5, 10, 0, 1.6 },
}

local function rgb(t): Color3
	return Color3.fromRGB(t[1], t[2], t[3])
end

local stack = {} -- the open worlds, the newest last
local saved = nil -- the light, the camera and the HUD as they were before the first world
local shaker = nil
local shakeCf = CFrame.new()

local function effectsOn(ctx): boolean
	local meta = ctx and ctx.state and ctx.state.meta
	local s = meta and meta.settings
	return not (s and s.effects == false)
end

-- Can this player have the 3D stage? (the "3D effects" setting, and a camera to point)
function World3D.available(ctx): boolean
	local meta = ctx and ctx.state and ctx.state.meta
	local s = meta and meta.settings
	if s and s.vfx == "flat" then
		-- (v0.18) "3D effects: Off" keeps the flat fight screens of v0.17
		return false
	end
	local ok, cam = pcall(function()
		return workspace.CurrentCamera
	end)
	return ok and cam ~= nil
end

function World3D.current()
	return stack[#stack]
end

-- closes every world opened after `keep` (all of them when keep is nil): a scene that failed
-- halfway never leaves its stage up, or the HUD hidden
function World3D.closeAbove(keep)
	local guard = 0
	while #stack > 0 and stack[#stack] ~= keep and guard < 16 do
		guard += 1
		stack[#stack]:close()
	end
end

-- the HUD and everything else under the cinema layer steps aside (it would cover the stage)
local function hideHud(layer: Instance)
	local gui = if layer:IsA("ScreenGui") then layer else layer:FindFirstAncestorOfClass("ScreenGui")
	local hidden = {}
	if not gui or not gui.Parent then
		return hidden
	end
	local order = (gui :: ScreenGui).DisplayOrder
	for _, other in gui.Parent:GetChildren() do
		if other ~= gui and other:IsA("ScreenGui") and other.Enabled and other.DisplayOrder < order then
			other.Enabled = false
			table.insert(hidden, other)
		end
	end
	return hidden
end

-- the light as it was (each property on its own: one that can't be read is left alone)
local LIGHT_PROPS = { "ClockTime", "Brightness", "Ambient", "OutdoorAmbient", "ExposureCompensation" }
local BLOOM_PROPS = { "Intensity", "Size", "Threshold" }

local function readProps(inst: Instance, props): { [string]: any }
	local out = {}
	for _, k in props do
		local ok, v = pcall(function()
			return (inst :: any)[k]
		end)
		if ok and v ~= nil then
			out[k] = v
		end
	end
	return out
end

local function writeProps(inst: Instance, values)
	for k, v in values do
		pcall(function()
			(inst :: any)[k] = v
		end)
	end
end

local SoundService = game:GetService("SoundService")
-- (v0.18) the room every mood sounds like (SoundService.AmbientReverb, while a stage is up)
local REVERB = { night = "Alley", dusk = "City", day = "City", inside = "Room", facility = "Hangar", boss = "StoneCorridor", distortion = "SewerPipe" }

local function grabLight()
	local bloom = Lighting:FindFirstChild("LifeSimBloom")
	return {
		light = readProps(Lighting, LIGHT_PROPS),
		bloom = bloom,
		bloomProps = if bloom then readProps(bloom, BLOOM_PROPS) else nil,
		reverb = readProps(SoundService, { "AmbientReverb" }),
	}
end

local function putLight(l)
	writeProps(Lighting, l.light)
	if l.reverb then
		writeProps(SoundService, l.reverb)
	end
	if l.bloom and l.bloom.Parent and l.bloomProps then
		writeProps(l.bloom, l.bloomProps)
	end
end

function World3D:applyMood()
	local m = MOODS[self.mood] or MOODS.night
	if self.keyLight then
		pcall(function()
			self.keyLight.Brightness = m.key or 1.4
		end)
	end
	pcall(function()
		Lighting.ClockTime = m.clock
		Lighting.Brightness = m.brightness
		Lighting.Ambient = rgb(m.ambient)
		Lighting.OutdoorAmbient = rgb(m.outdoor)
		Lighting.ExposureCompensation = m.exposure
		local bloom = Lighting:FindFirstChild("LifeSimBloom") or self.bloom
		if bloom then
			local b = bloom :: BloomEffect
			b.Intensity, b.Size, b.Threshold = m.bloom[1], m.bloom[2], m.bloom[3]
		end
		self.grade.TintColor = rgb(m.tint)
		self.grade.Contrast = m.contrast
		self.grade.Saturation = m.saturation
	end)
	pcall(function()
		SoundService.AmbientReverb = (Enum.ReverbType :: any)[REVERB[self.mood] or "Alley"]
	end)
end

function World3D:setMood(mood: string)
	if MOODS[mood] then
		self.mood = mood
		if World3D.current() == self then
			self:applyMood()
		end
	end
end

local function stepAll(dt: number)
	local w = stack[#stack]
	if not w then
		return
	end
	w:_step(dt)
end

local function bindSteps()
	RunService:BindToRenderStep(STEP_NAME, STEP_PRIORITY, stepAll)
	if CameraShaker and not shaker then
		local ok, s = pcall(CameraShaker.new, SHAKE_PRIORITY, function(cf: CFrame)
			shakeCf = cf
		end)
		if ok and s then
			shaker = s
			pcall(function()
				s:Start()
			end)
		end
	end
end

local function unbindSteps()
	pcall(function()
		RunService:UnbindFromRenderStep(STEP_NAME)
	end)
	if shaker then
		pcall(function()
			shaker:Stop()
		end)
		shaker = nil
	end
	shakeCf = CFrame.new()
end

-- opts: { mood = "night", fov = 40 }
function World3D.open(ctx, layer: Instance, opts)
	if not World3D.available(ctx) then
		return nil
	end
	opts = opts or {}
	local self = setmetatable({}, World3D)
	self.ctx = ctx
	self.layer = layer
	self.mood = if MOODS[opts.mood or ""] then opts.mood else "night"
	self.camCF = CFrame.lookAt(Vector3.new(0, 4.4, 16), Vector3.new(0, 2.8, 0))
	self.fov = opts.fov or 40
	self.punchDeg = 0
	self.effectsOn = effectsOn(ctx)
	self.folder = Instance.new("Folder")
	self.folder.Name = "LifeSimWorld3D"
	-- our own grade and impact-frame layers (only while a world is up)
	self.grade = Instance.new("ColorCorrectionEffect")
	self.grade.Name = "LifeSimWorldGrade"
	self.impact = Instance.new("ColorCorrectionEffect")
	self.impact.Name = "LifeSimWorldImpact"
	self.dof = Instance.new("DepthOfFieldEffect")
	self.dof.Name = "LifeSimWorldFocus"
	self.dof.FarIntensity = 0.22
	self.dof.NearIntensity = 0
	self.dof.InFocusRadius = 14
	self.dof.FocusDistance = 18
	if not Lighting:FindFirstChild("LifeSimBloom") then
		self.bloom = Instance.new("BloomEffect")
		self.bloom.Name = "LifeSimWorldBloom"
	end

	-- the first world remembers how things were
	local first = #stack == 0
	if first then
		local cam = workspace.CurrentCamera :: Camera
		saved = {
			light = grabLight(),
			hud = hideHud(layer),
			camera = readProps(cam, { "FieldOfView", "CFrame", "CameraType" }),
		}
	else
		stack[#stack]:_suspend()
	end
	table.insert(stack, self)
	self:_resume()
	if first then
		bindSteps()
	end
	return self
end

function World3D:_resume()
	-- (v0.18) a key light above and in front of where people stand, and a softer fill from the
	-- other side: whatever the hour, the fighters can be seen (Shadows off: no hard black)
	local rig = Instance.new("Part")
	rig.Name = "StageLights"
	rig.Anchored, rig.CanCollide, rig.CanQuery, rig.CanTouch, rig.CastShadow = true, false, false, false, false
	rig.Transparency = 1
	rig.Size = Vector3.new(0.2, 0.2, 0.2)
	rig.CFrame = CFrame.new(0, 13, 14)
	rig.Parent = self.folder
	local key = Instance.new("PointLight")
	key.Name = "Key"
	key.Range = 46
	key.Brightness = 1.6
	key.Color = Color3.fromRGB(255, 244, 228)
	key.Shadows = false
	key.Parent = rig
	local fillPart = rig:Clone()
	fillPart.Name = "StageFill"
	fillPart.CFrame = CFrame.new(0, 9, -12)
	fillPart.Parent = self.folder
	local fill = fillPart:FindFirstChildOfClass("PointLight")
	if fill then
		fill.Name = "Fill"
		fill.Range = 36
		fill.Brightness = 0.7
		fill.Color = Color3.fromRGB(190, 206, 255)
	end
	self.keyLight = key
	self.folder.Parent = workspace
	self.grade.Parent = Lighting
	self.impact.Parent = Lighting
	self.dof.Parent = Lighting
	if self.bloom then
		self.bloom.Parent = Lighting
	end
	self:applyMood()
end

function World3D:_suspend()
	self.folder.Parent = nil
	self.grade.Parent = nil
	self.impact.Parent = nil
	self.dof.Parent = nil
	if self.bloom then
		self.bloom.Parent = nil
	end
end

function World3D:_step(dt: number)
	-- (v0.18) hold the stage's light: the city behind it tweens the clock when its scene changes,
	-- and a scene played at night was being dragged back to the backdrop's midnight
	-- (every frame, before the picture is drawn, and only what changed: a tween elsewhere loses)
	local m = MOODS[self.mood]
	if m then
		pcall(function()
			if math.abs(Lighting.ClockTime - m.clock) > 0.05 then
				Lighting.ClockTime = m.clock
			end
			local amb, out = rgb(m.ambient), rgb(m.outdoor)
			if Lighting.Ambient ~= amb then
				Lighting.Ambient = amb
			end
			if Lighting.OutdoorAmbient ~= out then
				Lighting.OutdoorAmbient = out
			end
			if Lighting.Brightness ~= m.brightness then
				Lighting.Brightness = m.brightness
			end
			if Lighting.ExposureCompensation ~= m.exposure then
				Lighting.ExposureCompensation = m.exposure
			end
		end)
	end
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	-- the punch springs back (critically damped, about a fifth of a second)
	if self.punchDeg ~= 0 then
		self.punchDeg *= math.exp(-dt * 14)
		if math.abs(self.punchDeg) < 0.05 then
			self.punchDeg = 0
		end
	end
	cam.CameraType = Enum.CameraType.Scriptable
	cam.FieldOfView = math.clamp(self.fov - self.punchDeg, 10, 110)
	cam.CFrame = self.camCF * shakeCf
end

-- where the camera is, in world space (no shake), and its lens
function World3D:setCamera(cf: CFrame, fov: number?)
	self.camCF = cf
	if fov then
		self.fov = fov
	end
	if World3D.current() == self then
		self:_step(0)
	end
end

function World3D:focus(distance: number, radius: number?)
	self.dof.FocusDistance = math.max(1, distance)
	if radius then
		self.dof.InFocusRadius = radius
	end
end

function World3D:shake(kind)
	if not self.effectsOn or not shaker then
		return
	end
	local p = if type(kind) == "table" then kind else (SHAKES[kind or "light"] or SHAKES.light)
	pcall(function()
		shaker:ShakeOnce(p[1], p[2], p[3], p[4])
	end)
end

function World3D:punch(degrees: number?)
	if not self.effectsOn then
		return
	end
	self.punchDeg += degrees or 6
end

-- An anime impact frame: the picture snaps to black-on-white (or blown-out white) for a frame
-- or two, then back. Measured values: black = Contrast 2-3, Saturation -1; white = Brightness 1.
function World3D:impactFrame(kind: string?)
	if not self.effectsOn then
		return
	end
	local fx = self.impact
	if kind == "white" then
		fx.Brightness, fx.Contrast, fx.Saturation = 0.8, 0.6, -1
	else
		fx.Brightness, fx.Contrast, fx.Saturation = -0.15, 2.6, -1
	end
	fx.TintColor = Color3.new(1, 1, 1)
	task.delay(0.06, function()
		fx.Brightness, fx.Contrast, fx.Saturation = 0, 0, 0
	end)
end

-- the whole picture leans toward a colour, then lets go
function World3D:tint(color: Color3, seconds: number?)
	if not self.effectsOn then
		return
	end
	local fx = self.impact
	fx.TintColor = color
	local dur = seconds or 0.35
	local t = 0
	local finished = false
	local conn = nil
	local function finish()
		if finished then
			return
		end
		finished = true
		if conn then
			conn:Disconnect()
		end
		fx.TintColor = Color3.new(1, 1, 1)
	end
	conn = RunService.Heartbeat:Connect(function(dt)
		if finished then
			return
		end
		t += dt
		local k = math.clamp(t / dur, 0, 1)
		fx.TintColor = color:Lerp(Color3.new(1, 1, 1), k)
		if k >= 1 then
			finish()
		end
	end)
	task.delay(dur + 0.5, finish)
end

-- where a world point lands on the screen, as a fraction of the cinema layer (which ignores the
-- GUI inset, so it's the whole viewport), worked out from the camera we set; and whether it's
-- in front of the camera at all
function World3D:project(pos: Vector3): (Vector2, boolean)
	local size = Vector2.new(16, 10)
	local ok, abs = pcall(function()
		return (self.layer :: any).AbsoluteSize
	end)
	if ok and typeof(abs) == "Vector2" and abs.X > 2 and abs.Y > 2 then
		size = abs
	end
	local rel = self.camCF:PointToObjectSpace(pos)
	if rel.Z >= -0.01 then
		return Vector2.new(0.5, 0.5), false
	end
	local tanY = math.tan(math.rad(self.fov) / 2)
	local aspect = size.X / size.Y
	local x = (rel.X / -rel.Z) / (tanY * aspect)
	local y = (rel.Y / -rel.Z) / tanY
	return Vector2.new(0.5 + x / 2, 0.5 - y / 2), true
end

-- The camera that fits a group of points (the fighters) into part of the screen: rect is
-- { x0, y0, x1, y1 } as fractions of the screen; the camera looks along `dir` (world) and
-- stands back far enough that `height` studs fill `fill` of the rect's height.
function World3D:frame(center: Vector3, height: number, rect, dir: Vector3?, fill: number?): CFrame
	local size = Vector2.new(16, 10)
	local ok, abs = pcall(function()
		return (self.layer :: any).AbsoluteSize
	end)
	if ok and typeof(abs) == "Vector2" and abs.X > 2 and abs.Y > 2 then
		size = abs
	end
	local aspect = size.X / size.Y
	local tanY = math.tan(math.rad(self.fov) / 2)
	local rh = math.max(0.05, rect[4] - rect[2])
	local rw = math.max(0.05, rect[3] - rect[1])
	-- distance so the height fills the rect, and so a width of 2.2x the height fits across it
	local dist = (height / (fill or 0.62)) / (2 * tanY * rh)
	local wantW = height * 2.3
	dist = math.max(dist, (wantW / 0.9) / (2 * tanY * aspect * rw))
	local look = (dir or Vector3.new(0, -0.12, -1)).Unit
	local base = CFrame.lookAt(center - look * dist, center)
	-- slide the camera so the center lands on the rect's middle, not the screen's
	local cx = (rect[1] + rect[3]) / 2 - 0.5
	local cy = (rect[2] + rect[4]) / 2 - 0.5
	local sx = -cx * 2 * tanY * aspect * dist
	local sy = cy * 2 * tanY * dist
	return base * CFrame.new(sx, sy, 0)
end

function World3D:close()
	if self.closed then
		return
	end
	self.closed = true
	local index = table.find(stack, self)
	if index then
		table.remove(stack, index)
	end
	self.folder:Destroy()
	self.grade:Destroy()
	self.impact:Destroy()
	self.dof:Destroy()
	if self.bloom then
		self.bloom:Destroy()
	end
	local top = stack[#stack]
	if top then
		top:_resume()
		return
	end
	-- the last one: everything back as it was
	unbindSteps()
	if saved then
		putLight(saved.light)
		for _, gui in saved.hud do
			if gui.Parent then
				gui.Enabled = true
			end
		end
		pcall(function()
			local cam = workspace.CurrentCamera :: Camera
			local c = saved.camera
			-- (the lens and the view first, then who drives it)
			writeProps(cam, { FieldOfView = c.FieldOfView, CFrame = c.CFrame })
			writeProps(cam, { CameraType = c.CameraType })
		end)
		saved = nil
	end
end

return World3D
