--[[
	THE TITLE SCREEN AND MAIN MENU (BitLeveling).

	After the opening: a live 3D title (the Gate swirling behind six Hunters in their class
	gear, mana drifting up, the camera turning slowly round them), BITLEVELING, and a pulsing
	PLAY (any key or a tap works too). PLAY opens the main menu over the same scene:

	  CONTINUE        back into the life you're living (when there is one)
	  NEW LIFE        pick the WORLD (each world is a difficulty: the Normal World follows the
	                  manhwa's pace, the High-Danger World puts Gates everywhere) and the GAME
	                  MODE (solo, or together with friends), then BEGIN: the life creator opens
	  CHARACTER       your Hunter's look for the live city (the R6 creator) and your life's
	                  talent and class leanings (the life creator)
	  SPINS           the talent spin (the talent your next life is born with) and the family
	                  name spin
	  WALK THE CITY   straight into the live 3D city
	  more            Hunter News, Endings, the Hunters' Market, the Guide, Settings
	On the right, your Hunter turns on a lit podium. Everything a button does is the app's own
	action (App passes them in), so this screen only decides what to show.

		local title = TitleMenu.show(parent, env)   -> { gui, menu(), destroy() }
	env = { R6Rig, Looks, GateVfx?, look?, rank?, direct? (straight to the menu), hasLife, lifeLine, difficulties = { { id, name,
	        desc } }, difficulty, modes = { { id, name, desc } }, on = { continue, newLife(difficultyId,
	        modeId), together, character, lifeCreator, talentSpin, surnameSpin, walk, news, endings,
	        market, guide, settings } }
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local TitleMenu = {}

-- (sound) client/UiSounds clicks every button by itself; these screens pick which sound each
-- button makes (the UiSound / UiHover attributes) and play the PLAY sting. Silent without it.
local uiSounds: any = nil
local function sfx(name: string, opts: any?)
	if uiSounds == nil then
		local ok, mod = pcall(function()
			return require((script.Parent :: any).Parent:FindFirstChild("UiSounds"))
		end)
		uiSounds = if ok and type(mod) == "table" then mod else false
	end
	if uiSounds then
		pcall(uiSounds.play, name, opts)
	end
end
local function sounds(b: Instance, press: string?, hover: string?)
	pcall(function()
		if press then
			b:SetAttribute("UiSound", press)
		end
		if hover then
			b:SetAttribute("UiHover", hover)
		end
	end)
end

local C = {
	ink = Color3.fromRGB(6, 8, 16),
	panel = Color3.fromRGB(14, 18, 32),
	panelHi = Color3.fromRGB(26, 32, 54),
	mana = Color3.fromRGB(110, 170, 255),
	manaHi = Color3.fromRGB(170, 210, 255),
	gold = Color3.fromRGB(255, 205, 110),
	text = Color3.fromRGB(232, 236, 248),
	sub = Color3.fromRGB(150, 158, 180),
	red = Color3.fromRGB(255, 96, 96),
}
-- the six classes at the top of their craft (their S-rank presets), with their weapons
local PARTY = {
	{ preset = "tank_s", x = 0, z = 0 },
	{ preset = "fighter_s", x = -4.5, z = 1.5 },
	{ preset = "mage_s", x = 4.5, z = 1.5 },
	{ preset = "assassin_s", x = -8.5, z = 4 },
	{ preset = "ranger_s", x = 8.5, z = 4 },
	{ preset = "healer_s", x = 0, z = 3.5 },
}
local WEAPONS = { tank_s = "bulwark", fighter_s = "ogre_greatsword", mage_s = "sage_staff", assassin_s = "shadowglass", ranger_s = "wyvern_longbow", healer_s = "mercy_lantern" }

local function make(className: string, props: any, parent: Instance?): any
	local i = Instance.new(className)
	for k, v in props do
		(i :: any)[k] = v
	end
	if parent then
		i.Parent = parent
	end
	return i
end
local function tween(obj: Instance, t: number, goal: any, style: Enum.EasingStyle?, dir: Enum.EasingDirection?)
	local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), goal)
	tw:Play()
	return tw
end
local function corner(p: Instance, r: number?)
	make("UICorner", { CornerRadius = UDim.new(0, r or 8) }, p)
end
local function stroke(p: Instance, color: Color3, t: number?, thick: number?)
	return make("UIStroke", { Color = color, Transparency = t or 0.4, Thickness = thick or 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p)
end

-- ── the 3D scene behind everything ───────────────────────────────────────────
local function scene(gui: Instance, env: any): any
	local vp = make("ViewportFrame", { Name = "Scene", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, Ambient = Color3.fromRGB(70, 80, 120), LightColor = Color3.fromRGB(170, 200, 255), LightDirection = Vector3.new(0.3, -1, 0.6), ZIndex = 1 }, gui)
	local world = make("WorldModel", {}, vp)
	local cam = make("Camera", { FieldOfView = 46 }, vp)
	vp.CurrentCamera = cam
	local function block(props)
		props.Anchored = true
		props.CanCollide = false
		props.TopSurface = Enum.SurfaceType.Smooth
		props.BottomSurface = Enum.SurfaceType.Smooth
		return make("Part", props, world)
	end
	block({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 60, 60), CFrame = CFrame.new(0, -0.5, 6) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(16, 18, 28), Material = Enum.Material.Slate })
	block({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1.02, 26, 26), CFrame = CFrame.new(0, -0.49, 4) * CFrame.Angles(0, 0, math.rad(90)), Color = Color3.fromRGB(40, 70, 140), Material = Enum.Material.Neon, Transparency = 0.82 })
	for i = 1, 6 do
		local a = i / 6 * math.pi * 2
		block({ Size = Vector3.new(1.2, 10 + (i % 3) * 4, 1.2), CFrame = CFrame.new(math.cos(a) * 24, 4, 14 + math.sin(a) * 10) * CFrame.Angles(0, a, math.rad(4)), Color = Color3.fromRGB(28, 32, 46), Material = Enum.Material.Slate })
	end
	local gate = nil
	if env.GateVfx then
		local ok, g = pcall(env.GateVfx.new, world, CFrame.new(0, 9, 16), 8.5, { rank = 5 })
		if ok and g then
			gate = g
			pcall(function()
				g:open(0.05)
				g:step(0.1)
				g:step(0.1)
			end)
		end
	end
	local rigs = {}
	if env.R6Rig and env.Looks then
		for i, p in PARTY do
			local look = env.Looks.applyPreset(env.Looks.DEFAULT, p.preset)
			local def = env.Looks.find and env.Looks.find("PRESETS", p.preset)
			if def and def.acc then
				look.accessories = def.acc
				look = env.Looks.clean(look)
			end
			local ok, m = pcall(env.R6Rig.build, look, { name = p.preset, weapon = { base = WEAPONS[p.preset] or "none", stars = 1 + (i % 3) }, rank = 3 + (i % 4) })
			if ok and m then
				for _, d in m:GetDescendants() do
					if d:IsA("BasePart") then
						d.Anchored = true
					end
				end
				pcall(function()
					m:PivotTo(CFrame.lookAt(Vector3.new(p.x, 3, p.z), Vector3.new(p.x * 0.6, 3, -20)))
				end)
				m.Parent = world
				table.insert(rigs, m)
			end
		end
	end
	-- mana drifting up through the scene
	local motes = {}
	local rng = Random.new(7)
	for _ = 1, 26 do
		local pos = Vector3.new(rng:NextNumber(-18, 18), rng:NextNumber(0, 16), rng:NextNumber(-6, 20))
		local p = block({ Shape = Enum.PartType.Ball, Size = Vector3.one * rng:NextNumber(0.15, 0.4), CFrame = CFrame.new(pos), Color = C.mana:Lerp(Color3.new(1, 1, 1), rng:NextNumber(0, 0.6)), Material = Enum.Material.Neon, Transparency = 0.2 })
		table.insert(motes, { p = p, pos = pos, speed = rng:NextNumber(0.6, 1.6), phase = rng:NextNumber(0, 6) })
	end
	local t = 0
	local focus = Vector3.new(0, 4.5, 6)
	local radius, height, zoom = 27, 5, 1
	local s = { vp = vp, world = world, cam = cam, gate = gate, rigs = rigs }
	function s.step(dt: number)
		t += dt
		local a = math.rad(200) + math.sin(t * 0.07) * 0.5
		local r = radius * zoom
		cam.CFrame = CFrame.lookAt(focus + Vector3.new(math.sin(a) * r, height + math.sin(t * 0.2) * 0.6, math.cos(a) * r), focus + Vector3.new(0, 1.5, 4))
		for _, m in motes do
			local pos = m.pos + Vector3.new(math.sin(t + m.phase) * 0.01, m.speed * dt, 0)
			if pos.Y > 18 then
				pos = Vector3.new(pos.X, 0, pos.Z)
			end
			m.pos = pos
			m.p.CFrame = CFrame.new(pos)
		end
		if gate then
			pcall(gate.step, gate, dt)
		end
	end
	function s.setZoom(z: number)
		zoom = z
	end
	function s.surge()
		if gate then
			pcall(gate.surge, gate, 1)
		end
	end
	return s
end

-- ── a menu tile: a title, a line under it, a glow on hover ───────────────────
local function tile(parent: Instance, order: number, glyph: string, title: string, line: string, color: Color3, onClick: () -> ()): TextButton
	local b = make("TextButton", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = C.panel, BackgroundTransparency = 0.18, Text = "", AutoButtonColor = false, ZIndex = 12 }, parent)
	corner(b, 10)
	local st = stroke(b, color, 0.6, 1.4)
	make("UIGradient", { Color = ColorSequence.new(C.panelHi, C.panel), Rotation = 0 }, b)
	local g = make("TextLabel", { Position = UDim2.fromOffset(12, 0), Size = UDim2.fromOffset(40, 64), BackgroundTransparency = 1, Text = glyph, TextColor3 = color, Font = Enum.Font.GothamBlack, TextSize = 26, ZIndex = 13 }, b)
	local _ = g
	make("TextLabel", { Position = UDim2.fromOffset(60, 10), Size = UDim2.new(1, -70, 0, 24), BackgroundTransparency = 1, Text = title, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.text, Font = Enum.Font.GothamBlack, TextSize = 19, ZIndex = 13 }, b)
	make("TextLabel", { Position = UDim2.fromOffset(60, 34), Size = UDim2.new(1, -70, 0, 20), BackgroundTransparency = 1, Text = line, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = C.sub, Font = Enum.Font.Gotham, TextSize = 13, ZIndex = 13 }, b)
	b.MouseEnter:Connect(function()
		tween(st, 0.15, { Transparency = 0.05 })
		tween(b, 0.15, { BackgroundTransparency = 0.05 })
	end)
	b.MouseLeave:Connect(function()
		tween(st, 0.2, { Transparency = 0.6 })
		tween(b, 0.2, { BackgroundTransparency = 0.18 })
	end)
	sounds(b, "open", "tile")
	b.Activated:Connect(onClick)
	return b
end

local function chip(parent: Instance, text: string, on: boolean, color: Color3, onClick: () -> ()): TextButton
	local b = make("TextButton", { Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = if on then color else C.panelHi, BackgroundTransparency = if on then 0.15 else 0.3, Text = "  " .. text .. "  ", TextColor3 = if on then C.ink else C.text, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 14 }, parent)
	corner(b, 17)
	sounds(b, "tab")
	b.Activated:Connect(onClick)
	return b
end

function TitleMenu.show(parent: Instance, env: any): any
	local on = env.on or {}
	-- (a frame filling its parent: the app's menu screen, so sheets and modals open over it)
	local gui = make("Frame", { Name = "BitLevelingTitle", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 1 }, parent)
	local sc = scene(gui, env)
	local vignette = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.ink, BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 2 }, gui)
	make("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.45, 0.85), NumberSequenceKeypoint.new(1, 0.15) }), Rotation = 90 }, vignette)

	-- the logo, a letter at a time
	local logo = make("Frame", { Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.3), Size = UDim2.fromScale(0.62, 0.14), BackgroundTransparency = 1, ZIndex = 10 }, gui)
	local word = "BITLEVELING"
	local letters = {}
	for i = 1, #word do
		local l = make("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromScale(1 / #word, 1), Position = UDim2.fromScale((i - 0.5) / #word, 0.5), BackgroundTransparency = 1, Text = string.sub(word, i, i), Font = Enum.Font.GothamBlack, TextScaled = true, TextColor3 = C.manaHi, TextStrokeColor3 = Color3.fromRGB(30, 70, 180), TextStrokeTransparency = 0.25, TextTransparency = 1, ZIndex = 10 }, logo)
		table.insert(letters, l)
		task.delay(0.15 + i * 0.06, function()
			tween(l, 0.4, { TextTransparency = 0 })
		end)
	end
	local tag = make("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.38), Size = UDim2.fromScale(0.6, 0.035), BackgroundTransparency = 1, Text = "A HUNTER'S LIFE UNDER THE GATES", TextColor3 = C.sub, Font = Enum.Font.GothamBold, TextScaled = true, TextTransparency = 1, ZIndex = 10 }, gui)
	tween(tag, 1.2, { TextTransparency = 0.1 })
	local fan = make("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.new(1, -20, 0, 16), BackgroundTransparency = 1, Text = "A non-commercial fan game set in the world of the Solo Leveling manhwa. Not affiliated with its creators.", TextColor3 = C.sub, Font = Enum.Font.Gotham, TextSize = 11, TextTransparency = 0.3, ZIndex = 10 }, gui)
	local _ = fan

	-- PLAY
	local play = make("TextButton", { Name = "Play", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.72), Size = UDim2.fromOffset(280, 72), BackgroundColor3 = C.mana, BackgroundTransparency = 0.05, Text = "PLAY", TextColor3 = C.ink, Font = Enum.Font.GothamBlack, TextSize = 34, ZIndex = 11 }, gui)
	corner(play, 36)
	sounds(play, "none", "tile") -- (its sting plays when the menu opens: PLAY or any key)
	local playStroke = stroke(play, Color3.new(1, 1, 1), 0.2, 3)
	make("UIGradient", { Color = ColorSequence.new(C.manaHi, C.mana), Rotation = 90 }, play)
	local hint = make("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.72, 46), Size = UDim2.fromOffset(300, 18), BackgroundTransparency = 1, Text = "press any key", TextColor3 = C.sub, Font = Enum.Font.GothamMedium, TextSize = 13, ZIndex = 11 }, gui)

	-- the menu (built when PLAY is pressed)
	local menuFrame: Frame? = nil
	local preview: any = nil
	local handle: any = { gui = gui }
	local alive = true
	local t = 0
	local conn = RunService.RenderStepped:Connect(function(dt)
		t += dt
		sc.step(dt)
		-- PLAY breathes
		local pulse = 0.5 + 0.5 * math.sin(t * 3)
		playStroke.Transparency = 0.1 + 0.5 * pulse
		play.Size = UDim2.fromOffset(280 + pulse * 10, 72 + pulse * 3)
		if preview then
			preview.step(dt)
		end
	end)

	-- your Hunter on a podium (the right side of the menu)
	local function podium(host: Instance): any
		local vp = make("ViewportFrame", { Name = "Podium", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -24, 0.54, 0), Size = UDim2.fromScale(0.3, 0.72), BackgroundTransparency = 1, Ambient = Color3.fromRGB(150, 155, 175), LightColor = Color3.fromRGB(255, 244, 230), ZIndex = 12 }, host)
		local world = make("WorldModel", {}, vp)
		local cam = make("Camera", { FieldOfView = 30 }, vp)
		vp.CurrentCamera = cam
		make("Part", { Anchored = true, Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 6, 6), CFrame = CFrame.new(0, -0.2, 0) * CFrame.Angles(0, 0, math.rad(90)), Color = C.mana, Material = Enum.Material.Neon, Transparency = 0.35 }, world)
		local p: any = { rig = nil, angle = math.rad(200) }
		function p.set(look: any)
			if p.rig then
				p.rig:Destroy()
			end
			if not (env.R6Rig and look) then
				return
			end
			local ok, m = pcall(env.R6Rig.build, look, { name = "You", rank = env.rank })
			if ok and m then
				for _, d in m:GetDescendants() do
					if d:IsA("BasePart") then
						d.Anchored = true
					end
				end
				m.Parent = world
				p.rig = m
			end
		end
		function p.step(dt: number)
			p.angle += dt * 0.45
			cam.CFrame = CFrame.lookAt(Vector3.new(math.sin(p.angle) * 18, 4.4, math.cos(p.angle) * 18), Vector3.new(0, 3.2, 0))
		end
		return p
	end

	local function sectionTitle(parent: Instance, order: number, text: string)
		make("TextLabel", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = text, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.mana, Font = Enum.Font.GothamBlack, TextSize = 13, ZIndex = 13 }, parent)
	end

	-- the page area (to the right of the tiles): new life, character, spins
	local page: Frame? = nil
	local function openPage(build: (Frame) -> ())
		if page then
			page:Destroy()
		end
		local host = menuFrame :: Frame
		local f = make("Frame", { Name = "Page", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0.42, 40, 0.56, 0), Size = UDim2.fromScale(0.3, 0.66), BackgroundColor3 = C.panel, BackgroundTransparency = 0.12, ZIndex = 12 }, host)
		corner(f, 12)
		stroke(f, C.mana, 0.5, 1.4)
		make("UIPadding", { PaddingTop = UDim.new(0, 14), PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingBottom = UDim.new(0, 14) }, f)
		make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, f)
		page = f
		build(f)
		f.Position = UDim2.new(0.42, 80, 0.56, 0)
		tween(f, 0.25, { Position = UDim2.new(0.42, 40, 0.56, 0) })
	end
	local function bigButton(parent: Instance, order: number, text: string, color: Color3, onClick: () -> ()): TextButton
		local b = make("TextButton", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = color, Text = text, TextColor3 = C.ink, Font = Enum.Font.GothamBlack, TextSize = 18, ZIndex = 14 }, parent)
		corner(b, 23)
		sounds(b, "begin", "tile")
		b.Activated:Connect(onClick)
		return b
	end
	local function card(parent: Instance, order: number, title: string, desc: string, selected: boolean, color: Color3, onClick: () -> ()): TextButton
		local b = make("TextButton", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = if selected then C.panelHi else C.ink, BackgroundTransparency = 0.1, Text = "", ZIndex = 13 }, parent)
		corner(b, 10)
		stroke(b, color, if selected then 0.05 else 0.7, if selected then 2 else 1)
		make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10) }, b)
		make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, b)
		make("TextLabel", { LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = (if selected then "◆ " else "◇ ") .. title, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = if selected then color else C.text, Font = Enum.Font.GothamBlack, TextSize = 16, ZIndex = 14 }, b)
		make("TextLabel", { LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = desc, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, Font = Enum.Font.Gotham, TextSize = 13, ZIndex = 14 }, b)
		sounds(b, "select")
		b.Activated:Connect(onClick)
		return b
	end

	-- NEW LIFE: the world (difficulty) and the mode, then BEGIN
	local chosenDiff = env.difficulty
	local chosenMode = "solo"
	local function newLifePage()
		openPage(function(f)
			sectionTitle(f, 1, "CHOOSE YOUR WORLD")
			local diffs = env.difficulties or {}
			chosenDiff = chosenDiff or (diffs[1] and diffs[1].id)
			for i, d in diffs do
				local color = if string.find(string.lower(d.id), "crisis") or string.find(string.lower(d.name or ""), "danger") then C.red else C.mana
				card(f, 1 + i, d.name or d.id, d.desc or "", d.id == chosenDiff, color, function()
					chosenDiff = d.id
					newLifePage()
				end)
			end
			sectionTitle(f, 20, "GAME MODE")
			local modeRow = make("Frame", { LayoutOrder = 21, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, ZIndex = 13 }, f)
			make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8) }, modeRow)
			chip(modeRow, "SOLO", chosenMode == "solo", C.mana, function()
				chosenMode = "solo"
				newLifePage()
			end)
			chip(modeRow, "WITH FRIENDS", chosenMode == "together", C.gold, function()
				chosenMode = "together"
				newLifePage()
			end)
			make("TextLabel", { LayoutOrder = 22, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = if chosenMode == "solo" then "Your life, year by year. Awaken, or don't." else "Start lives together with friends on this server: born the same year, ageing up together.", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, Font = Enum.Font.Gotham, TextSize = 13, ZIndex = 13 }, f)
			bigButton(f, 30, "BEGIN  ▶", C.mana, function()
				sc.surge()
				if chosenMode == "together" then
					if on.together then
						on.together(chosenDiff)
					end
				elseif on.newLife then
					on.newLife(chosenDiff, env.modes and env.modes[1] and env.modes[1].id or nil)
				end
			end)
		end)
	end

	local function characterPage()
		openPage(function(f)
			sectionTitle(f, 1, "CHARACTER")
			card(f, 2, "Hunter Look", "Your R6 Hunter in the live city: outfits, robes, armour, capes, scars, glowing eyes, auras, presets for every class.", true, C.mana, function()
				if on.character then
					on.character()
				end
			end)
			card(f, 3, "Life & Class", "The talent you're born with and the classes you lean toward when you awaken: Fighter, Mage, Assassin, Tanker, Ranger, Healer.", false, C.gold, function()
				if on.lifeCreator then
					on.lifeCreator()
				end
			end)
		end)
	end

	local function spinsPage()
		openPage(function(f)
			sectionTitle(f, 1, "SPINS")
			card(f, 2, "Talent Spin", "Roll the talent your next life is born with, from Ordinary to Unreal. The odds are shown before every roll.", true, C.gold, function()
				if on.talentSpin then
					on.talentSpin()
				end
			end)
			card(f, 3, "Family Name Spin", "Spin for a family name. Every finished life earns a roll.", false, C.manaHi, function()
				if on.surnameSpin then
					on.surnameSpin()
				end
			end)
		end)
	end

	function handle.menu()
		if menuFrame then
			return
		end
		sc.surge()
		sc.setZoom(1.12)
		if not env.direct then
			sfx("play") -- (sound) the Gate surges as the menu opens
		end
		tween(play, 0.25, { Position = UDim2.fromScale(0.5, 1.3) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		tween(hint, 0.2, { TextTransparency = 1 })
		tween(logo, 0.45, { Position = UDim2.fromScale(0.215, 0.1), Size = UDim2.fromScale(0.36, 0.08) })
		tween(tag, 0.3, { TextTransparency = 1 })
		local f = make("Frame", { Name = "Menu", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 11 }, gui)
		menuFrame = f
		local col = make("ScrollingFrame", { Name = "Tiles", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(-0.45, 0, 0.56, 0), Size = UDim2.fromScale(0.42, 0.74), BackgroundTransparency = 1, ScrollBarThickness = 4, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, ZIndex = 12 }, f)
		make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, col)
		make("UIPadding", { PaddingLeft = UDim.new(0, 28), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4) }, col)
		tween(col, 0.4, { Position = UDim2.new(0, 0, 0.56, 0) }, Enum.EasingStyle.Quart)
		local order = 0
		local function add(glyph, title, line, color, fn)
			order += 1
			return tile(col, order, glyph, title, line, color, fn)
		end
		if env.hasLife then
			sounds(add("▶", "CONTINUE", env.lifeLine or "Back to your life", C.gold, function()
				if on.continue then
					on.continue()
				end
			end), "confirm")
		end
		add("✦", "NEW LIFE", "Choose your world and mode, then be born", C.mana, newLifePage)
		add("◆", "CHARACTER", "Your Hunter's look, your talent and class", C.manaHi, characterPage)
		add("★", "SPINS", "Talent spin and family name spin", C.gold, spinsPage)
		sounds(add("⚔", "WALK THE CITY", "The live city: Gates open around you in real time", Color3.fromRGB(150, 230, 170), function()
			if on.walk then
				on.walk()
			end
		end), "confirm")
		-- the smaller things, in a row of chips
		order += 1
		local more = make("Frame", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 12 }, col)
		make("UIGridLayout", { CellSize = UDim2.new(0.33, -6, 0, 36), CellPadding = UDim2.fromOffset(6, 6) }, more)
		for _, m in { { "NEWS", on.news }, { "ENDINGS", on.endings }, { "MARKET", on.market }, { "GUIDE", on.guide }, { "SETTINGS", on.settings } } do
			local b = make("TextButton", { BackgroundColor3 = C.panelHi, BackgroundTransparency = 0.2, Text = m[1], TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 13 }, more)
			corner(b, 8)
			b.Activated:Connect(function()
				if m[2] then
					m[2]()
				end
			end)
		end
		-- your Hunter on the right
		preview = podium(f)
		if env.look then
			preview.set(env.look)
		end
		local edit = make("TextButton", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -60, 0.9, 0), Size = UDim2.fromOffset(150, 34), BackgroundColor3 = C.panelHi, BackgroundTransparency = 0.15, Text = "EDIT LOOK", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 13 }, f)
		corner(edit, 17)
		stroke(edit, C.mana, 0.4)
		sounds(edit, "open")
		edit.Activated:Connect(function()
			if on.character then
				on.character()
			end
		end)
		if not env.hasLife then
			newLifePage()
		end
	end
	function handle.setLook(look: any)
		env.look = look
		if preview then
			preview.set(look)
		end
	end
	function handle.hide()
		gui.Visible = false
	end
	function handle.showAgain()
		gui.Visible = true
	end
	function handle.destroy()
		alive = false
		conn:Disconnect()
		gui:Destroy()
	end

	play.Activated:Connect(handle.menu)
	if env.direct then
		for _, l in letters do
			l.TextTransparency = 0
		end
		handle.menu()
	end
	local keyConn
	keyConn = UserInputService.InputBegan:Connect(function(input, processed)
		if not alive or menuFrame then
			keyConn:Disconnect()
			return
		end
		if not processed and (input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.Gamepad1) then
			handle.menu()
		end
	end)
	return handle
end

return TitleMenu
