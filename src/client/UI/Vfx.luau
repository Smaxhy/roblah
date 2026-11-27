--[[
	VFX (v0.17): sparks, slashes, shockwaves, status effects, damage numbers, flashes and banners,
	drawn as GUI over whatever is on screen. (A ViewportFrame can't draw particles, so the
	effects over a 3D figure are Frames and tweens too.) Every effect cleans up after itself,
	and does nothing when effects are turned off in Settings (Kit.effects == false).

		Vfx.impact(layer, at, opts)      a hit: slash, burst, ring, flash. at = Vector2 (0..1 of
		                                 the layer); opts = { color, heavy, status, angle, big }
		Vfx.slash(layer, at, color, angle, length)
		Vfx.burst(layer, at, color, n, reach)
		Vfx.ring(layer, at, color, size, thickness)
		Vfx.flash(layer, color, strength)
		Vfx.number(layer, at, text, color, big)
		Vfx.status(layer, at, id)        burn embers, bleed drops, tremor rings, rupture cracks,
		                                 sinking drops, poise glints, charge bolts
		Vfx.heal(layer, at)              green crosses, rising
		Vfx.guard(layer, at, color)      a shield that flares
		Vfx.banner(layer, text, sub, color)   phase changes, a duel's turn, a victory
		Vfx.confetti(layer, color)       gold, falling
		Vfx.speedLines(layer, color)     a heavy moment's streaks
		Vfx.colorOf(statusId)            the color each status burns in
]]

local TweenService = game:GetService("TweenService")

local Kit = require(script.Parent.Kit)
local Theme = require(script.Parent.Theme)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Vfx = {}

local Z = 300

-- the colors of the City's statuses (Limbus: Burn, Bleed, Tremor, Rupture, Sinking, Poise, Charge)
local STATUS = {
	burn = Color3.fromRGB(255, 132, 40),
	bleed = Color3.fromRGB(220, 40, 52),
	tremor = Color3.fromRGB(232, 190, 80),
	rupture = Color3.fromRGB(80, 220, 190),
	sinking = Color3.fromRGB(60, 90, 220),
	poise = Color3.fromRGB(230, 240, 255),
	charge = Color3.fromRGB(90, 180, 255),
}
function Vfx.colorOf(id: string?): Color3
	return (id and STATUS[id]) or C.accentHi
end

local function on(): boolean
	return Kit.effects ~= false
end

local function tween(inst: Instance, time: number, props, style: Enum.EasingStyle?, dir: Enum.EasingDirection?)
	local t = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function later(time: number, inst: Instance)
	task.delay(time, function()
		if inst and inst.Parent then
			inst:Destroy()
		end
	end)
end

-- (v0.18) An effect never goes INTO a panel that arranges its children (a UIListLayout or a
-- UIGridLayout would line its pieces up in a column, which is what confetti on the fight card
-- did): it goes on the nearest ancestor that doesn't, in a box laid exactly over the panel.
local function arranged(inst: Instance): boolean
	for _, c in inst:GetChildren() do
		if c:IsA("UIGridStyleLayout") then
			return true
		end
	end
	return false
end

local function overlay(layer: Instance, life: number): Instance
	-- (v0.18) a layer that's gone (a fight screen that just closed under a late effect) draws
	-- nothing: the effect goes to a frame that's never shown, not into something destroyed
	if layer == nil or layer.Parent == nil then
		local void = new("Frame", { Name = "VfxVoid", BackgroundTransparency = 1 })
		later(life, void)
		return void
	end
	if not arranged(layer) then
		return layer
	end
	local host = layer.Parent
	while host and host:IsA("GuiObject") and arranged(host) do
		host = host.Parent
	end
	if not host or not (host:IsA("GuiObject") or host:IsA("LayerCollector")) or not layer:IsA("GuiObject") then
		return layer
	end
	local lp, ls = (layer :: GuiObject).AbsolutePosition, (layer :: GuiObject).AbsoluteSize
	local hp = (host :: any).AbsolutePosition :: Vector2
	local box = new("Frame", {
		Name = "VfxCanvas",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(lp.X - hp.X, lp.Y - hp.Y),
		Size = UDim2.fromOffset(ls.X, ls.Y),
		ZIndex = 500,
		Parent = host,
	})
	later(life, box)
	return box
end

-- a weightless point on the layer, at a share of its size, that effects are drawn around
local function anchor(layer: Instance, at: Vector2?, life: number): Frame
	local a = new("Frame", {
		Name = "Vfx",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale((at and at.X) or 0.5, (at and at.Y) or 0.5),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = Z,
		Parent = overlay(layer, life),
	})
	later(life, a)
	return a
end

local function dot(parent: Instance, size: number, color: Color3, round: boolean?, z: number?): Frame
	local f = new("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(size, size),
		ZIndex = z or Z,
		Parent = parent,
	})
	if round then
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = f })
	end
	return f
end

-- ── the pieces ──────────────────────────────────────────────────────────────

function Vfx.slash(layer: Instance, at: Vector2?, color: Color3?, angle: number?, length: number?)
	if not on() then
		return
	end
	local a = anchor(layer, at, 0.6)
	local col = color or C.paperHi
	local len = length or 220
	local rot = angle or (-30 + math.random(-20, 20))
	for i, spec in { { 14, col, 0.05 }, { 5, Color3.new(1, 1, 1), 0 } } do
		local bar = new("Frame", {
			BackgroundColor3 = spec[2],
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Rotation = rot,
			Size = UDim2.fromOffset(len * 0.15, spec[1]),
			BackgroundTransparency = spec[3],
			ZIndex = Z + i,
			Parent = a,
		})
		new("UIGradient", {
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.45, 0), NumberSequenceKeypoint.new(0.55, 0), NumberSequenceKeypoint.new(1, 1) }),
			Parent = bar,
		})
		tween(bar, 0.12, { Size = UDim2.fromOffset(len, spec[1]) }, Enum.EasingStyle.Quart)
		task.delay(0.1, function()
			if bar.Parent then
				tween(bar, 0.3, { Size = UDim2.fromOffset(len * 1.15, 1), BackgroundTransparency = 1 })
			end
		end)
	end
end

function Vfx.burst(layer: Instance, at: Vector2?, color: Color3?, n: number?, reach: number?)
	if not on() then
		return
	end
	local a = anchor(layer, at, 0.8)
	local col = color or C.accentHi
	for _ = 1, n or 12 do
		local size = math.random(3, 8)
		local d = dot(a, size, if math.random() < 0.3 then Color3.new(1, 1, 1) else col)
		local ang = math.random() * math.pi * 2
		local dist = (reach or 90) * (0.5 + math.random() * 0.7)
		tween(d, 0.45 + math.random() * 0.2, {
			Position = UDim2.fromOffset(math.cos(ang) * dist, math.sin(ang) * dist),
			Rotation = math.random(-180, 180),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(1, 1),
		}, Enum.EasingStyle.Quart)
	end
end

function Vfx.ring(layer: Instance, at: Vector2?, color: Color3?, size: number?, thickness: number?)
	if not on() then
		return
	end
	local a = anchor(layer, at, 0.7)
	local r = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = Z, Parent = a })
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = r })
	local stroke = new("UIStroke", { Color = color or C.paperHi, Thickness = thickness or 4, Transparency = 0, Parent = r })
	local s = size or 180
	tween(r, 0.5, { Size = UDim2.fromOffset(s, s) }, Enum.EasingStyle.Quart)
	tween(stroke, 0.5, { Transparency = 1, Thickness = 1 })
end

function Vfx.flash(layer: Instance, color: Color3?, strength: number?)
	if not on() then
		return
	end
	local f = new("Frame", {
		Name = "VfxFlash",
		BackgroundColor3 = color or Color3.new(1, 1, 1),
		BackgroundTransparency = 1 - (strength or 0.35),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Z - 5,
		Parent = overlay(layer, 0.4),
	})
	tween(f, 0.3, { BackgroundTransparency = 1 })
	later(0.35, f)
end

function Vfx.number(layer: Instance, at: Vector2?, text: string, color: Color3?, big: boolean?)
	if not on() then
		return
	end
	local a = anchor(layer, at, 1.2)
	local label = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(math.random(-16, 16), 0),
		Size = UDim2.fromOffset(240, 60),
		FontFace = F.display,
		TextSize = if big then 54 else 34,
		TextColor3 = color or C.paperHi,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.2,
		Text = text,
		ZIndex = Z + 6,
		Parent = a,
	})
	local scale = new("UIScale", { Scale = 1.8, Parent = label })
	tween(scale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
	tween(label, 1.0, { Position = UDim2.fromOffset(math.random(-30, 30), -70) }, Enum.EasingStyle.Quad)
	task.delay(0.6, function()
		if label.Parent then
			tween(label, 0.4, { TextTransparency = 1, TextStrokeTransparency = 1 })
		end
	end)
end

function Vfx.speedLines(layer: Instance, color: Color3?)
	if not on() then
		return
	end
	local a = anchor(layer, Vector2.new(0.5, 0.5), 0.6)
	for _ = 1, 14 do
		local ang = math.random() * 360
		local line = new("Frame", {
			BackgroundColor3 = color or Color3.new(1, 1, 1),
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Rotation = ang,
			Position = UDim2.fromOffset(math.cos(math.rad(ang)) * 260, math.sin(math.rad(ang)) * 260),
			Size = UDim2.fromOffset(40, 2),
			ZIndex = Z - 2,
			Parent = a,
		})
		tween(line, 0.4, { Size = UDim2.fromOffset(260, 1), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart)
	end
end

-- ── the City's statuses ─────────────────────────────────────────────────────

local function embers(a: Frame, col: Color3)
	for _ = 1, 14 do
		local e = dot(a, math.random(3, 6), if math.random() < 0.4 then Color3.fromRGB(255, 230, 120) else col, true)
		e.Position = UDim2.fromOffset(math.random(-40, 40), math.random(-10, 20))
		tween(e, 0.8 + math.random() * 0.5, { Position = UDim2.fromOffset(math.random(-60, 60), math.random(-120, -60)), BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1) }, Enum.EasingStyle.Sine)
	end
end

local function drops(a: Frame, col: Color3, slow: boolean)
	for _ = 1, 10 do
		local d = new("Frame", { BackgroundColor3 = col, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(math.random(-40, 40), math.random(-30, 0)), Size = UDim2.fromOffset(4, 9), ZIndex = Z, Parent = a })
		new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = d })
		tween(d, if slow then 1.3 else 0.7, { Position = UDim2.fromOffset(math.random(-50, 50), math.random(70, 130)), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	end
end

local function cracks(a: Frame, col: Color3)
	for i = 1, 6 do
		local ang = i * 60 + math.random(-15, 15)
		local line = new("Frame", { BackgroundColor3 = col, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Rotation = ang, Size = UDim2.fromOffset(4, 3), ZIndex = Z + 1, Parent = a })
		tween(line, 0.12, { Size = UDim2.fromOffset(math.random(50, 90), 3) }, Enum.EasingStyle.Quart)
		task.delay(0.35, function()
			if line.Parent then
				tween(line, 0.3, { BackgroundTransparency = 1 })
			end
		end)
	end
end

local function glints(a: Frame, col: Color3)
	for _ = 1, 5 do
		local g = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(math.random(-70, 70), math.random(-70, 50)), Size = UDim2.fromOffset(1, 1), ZIndex = Z + 2, Parent = a })
		for _, r in { 0, 90 } do
			local bar = new("Frame", { BackgroundColor3 = col, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Rotation = r + 45, Size = UDim2.fromOffset(2, 2), ZIndex = Z + 2, Parent = g })
			tween(bar, 0.18, { Size = UDim2.fromOffset(26, 3) }, Enum.EasingStyle.Back)
			task.delay(0.3, function()
				if bar.Parent then
					tween(bar, 0.25, { Size = UDim2.fromOffset(1, 1), BackgroundTransparency = 1 })
				end
			end)
		end
	end
end

local function bolts(a: Frame, col: Color3)
	for i = 1, 4 do
		local x, y = math.random(-60, 60), -70
		local base = math.random(-25, 25)
		for _ = 1, 3 do
			local len = math.random(28, 40)
			local ang = 90 + base + math.random(-50, 50)
			local seg = new("Frame", { BackgroundColor3 = if i % 2 == 0 then Color3.new(1, 1, 1) else col, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Rotation = ang, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(len, 3), ZIndex = Z + 2, Parent = a })
			x += math.cos(math.rad(ang)) * len
			y += math.sin(math.rad(ang)) * len
			task.delay(0.08 * i, function()
				if seg.Parent then
					tween(seg, 0.25, { BackgroundTransparency = 1 })
				end
			end)
		end
	end
end

function Vfx.status(layer: Instance, at: Vector2?, id: string?)
	if not on() or not id or not STATUS[id] then
		return
	end
	local col = STATUS[id]
	local a = anchor(layer, at, 1.6)
	if id == "burn" then
		embers(a, col)
	elseif id == "bleed" then
		drops(a, col, false)
	elseif id == "tremor" then
		for i = 0, 2 do
			task.delay(i * 0.12, function()
				if a.Parent then
					Vfx.ring(layer, at, col, 120 + i * 50, 5)
				end
			end)
		end
	elseif id == "rupture" then
		cracks(a, col)
	elseif id == "sinking" then
		drops(a, col, true)
		Vfx.flash(layer, Color3.fromRGB(10, 20, 60), 0.25)
	elseif id == "poise" then
		glints(a, col)
	elseif id == "charge" then
		bolts(a, col)
	end
end

-- ── what a turn looks like ───────────────────────────────────────────────────

function Vfx.impact(layer: Instance, at: Vector2?, opts: any?)
	if not on() then
		return
	end
	opts = opts or {}
	local col = opts.color or (opts.status and STATUS[opts.status]) or C.paperHi
	Vfx.slash(layer, at, col, opts.angle, if opts.heavy then 320 else 220)
	if opts.heavy then
		task.delay(0.06, function()
			Vfx.slash(layer, at, Color3.new(1, 1, 1), (opts.angle or -30) + 70, 260)
		end)
		Vfx.speedLines(layer, col)
	end
	Vfx.burst(layer, at, col, if opts.heavy then 22 else 12, if opts.heavy then 140 else 90)
	Vfx.ring(layer, at, col, if opts.heavy then 260 else 170)
	Vfx.flash(layer, col, if opts.heavy then 0.35 else 0.15)
	if opts.status then
		Vfx.status(layer, at, opts.status)
	end
	if opts.shake and layer:IsA("GuiObject") then
		Kit.shake(layer :: any, if opts.heavy then 12 else 6, if opts.heavy then 0.4 else 0.22)
	end
end

function Vfx.heal(layer: Instance, at: Vector2?)
	if not on() then
		return
	end
	local a = anchor(layer, at, 1.4)
	local col = Color3.fromRGB(120, 230, 140)
	for _ = 1, 7 do
		local g = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(math.random(-50, 50), math.random(-10, 30)), Size = UDim2.fromOffset(14, 14), ZIndex = Z + 2, Parent = a })
		local bars = {}
		for _, s in { { 14, 4 }, { 4, 14 } } do
			table.insert(bars, new("Frame", { BackgroundColor3 = col, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(s[1], s[2]), ZIndex = Z + 2, Parent = g }))
		end
		tween(g, 1.1, { Position = UDim2.fromOffset(math.random(-60, 60), math.random(-110, -60)) }, Enum.EasingStyle.Sine)
		for _, b in bars do
			task.delay(0.6, function()
				if b.Parent then
					tween(b, 0.5, { BackgroundTransparency = 1 })
				end
			end)
		end
	end
	Vfx.ring(layer, at, col, 140, 3)
end

function Vfx.guard(layer: Instance, at: Vector2?, color: Color3?)
	if not on() then
		return
	end
	local a = anchor(layer, at, 0.9)
	local col = color or Color3.fromRGB(150, 200, 255)
	local shield = new("Frame", { BackgroundColor3 = col, BackgroundTransparency = 0.75, AnchorPoint = Vector2.new(0.5, 0.5), Rotation = 45, Size = UDim2.fromOffset(40, 40), ZIndex = Z + 1, Parent = a })
	new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = shield })
	local stroke = new("UIStroke", { Color = col, Thickness = 4, Parent = shield })
	tween(shield, 0.25, { Size = UDim2.fromOffset(120, 120) }, Enum.EasingStyle.Back)
	task.delay(0.35, function()
		if shield.Parent then
			tween(shield, 0.4, { BackgroundTransparency = 1, Size = UDim2.fromOffset(140, 140) })
			tween(stroke, 0.4, { Transparency = 1 })
		end
	end)
end

function Vfx.banner(layer: Instance, text: string, sub: string?, color: Color3?)
	if not on() then
		return
	end
	local col = color or C.crimsonHi
	local band = new("Frame", {
		Name = "VfxBanner",
		BackgroundColor3 = Color3.fromRGB(6, 5, 8),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.42),
		Size = UDim2.new(1, 0, 0, 0),
		ZIndex = Z + 10,
		Parent = overlay(layer, 4),
	})
	for _, y in { 0, 1 } do
		new("Frame", { BackgroundColor3 = col, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, y), Position = UDim2.fromScale(0.5, y), Size = UDim2.new(1, 0, 0, 3), ZIndex = Z + 11, Parent = band })
	end
	local title = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, -80, 0.45, 0),
		Size = UDim2.new(1, -40, 0, 50),
		FontFace = F.display,
		TextSize = 44,
		TextColor3 = col,
		TextTransparency = 1,
		Text = string.upper(text),
		ZIndex = Z + 12,
		Parent = band,
	})
	local subLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 80, 0.72, 0),
		Size = UDim2.new(1, -60, 0, 22),
		FontFace = F.serifItalic,
		TextSize = 16,
		TextWrapped = true,
		TextColor3 = C.text,
		TextTransparency = 1,
		Text = sub or "",
		ZIndex = Z + 12,
		Parent = band,
	})
	tween(band, 0.25, { Size = UDim2.new(1, 0, 0, if sub then 120 else 90) }, Enum.EasingStyle.Quart)
	tween(title, 0.35, { Position = UDim2.new(0.5, 0, 0.4, 0), TextTransparency = 0 }, Enum.EasingStyle.Quart)
	tween(subLabel, 0.45, { Position = UDim2.new(0.5, 0, 0.66, 0), TextTransparency = 0 }, Enum.EasingStyle.Quart)
	task.delay(1.6, function()
		if band.Parent then
			tween(title, 0.3, { Position = UDim2.new(0.5, 80, 0.4, 0), TextTransparency = 1 })
			tween(subLabel, 0.3, { TextTransparency = 1 })
			tween(band, 0.35, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 })
		end
	end)
	later(2.1, band)
end

function Vfx.confetti(layer: Instance, color: Color3?)
	if not on() then
		return
	end
	local col = color or Color3.fromRGB(255, 214, 120)
	local sky = overlay(layer, 3.2)
	for _ = 1, 40 do
		local piece = new("Frame", {
			BackgroundColor3 = if math.random() < 0.3 then Color3.new(1, 1, 1) else col,
			BorderSizePixel = 0,
			Position = UDim2.new(math.random(), 0, 0, -10),
			Size = UDim2.fromOffset(math.random(4, 9), math.random(6, 12)),
			Rotation = math.random(0, 360),
			ZIndex = Z + 3,
			Parent = sky,
		})
		tween(piece, 1.6 + math.random() * 1.2, { Position = UDim2.new(math.random(), 0, 1, 20), Rotation = math.random(-720, 720) }, Enum.EasingStyle.Sine)
		later(3, piece)
	end
end

return Vfx
