--[[
	The opening and the start menu.
		Intro.play(ctx, gui, intro, onDone, opts)
			The join cinematic over the 3D City. Full version (first join):
				1. Cold open: a street-level shot, a clock ticking to 3:13 AM.
				2. 3:13: the screen jolts red and THE NIGHT IN THE BACKSTREETS slams in.
				3. A montage: diagonal title cards (Wings, Fixers, the Fingers...), each on its
				   own camera shot.
				4. The title drops in letter by letter, a light sweeps across it, then it hands
				   straight over to the mode select.
			opts.short = true: a five-second title sting (every later join).
			Any key, a tap, a gamepad button or Skip ends it.
			intro (from the pack) = { cold = { place, from, to, stamp, line }, cards = { { word,
			line, shot, color } }, title, subtitle, lines (older packs: plain narration) }
		Intro.menu(ctx, parent, opts) -> { frame, first, destroy }
			The mode select: Continue (if a life is going), one card per game mode (locked
			ones show how to open them), then With friends / Guidebook / Archive / Menu.
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Emblem = require(script.Parent.Emblem)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Intro = {}

-- the scene illustration module (client/SceneArt); optional, loaded once
local sceneArt = nil
local function getSceneArt()
	if sceneArt == nil then
		sceneArt = false
		local mod = script.Parent.Parent:FindFirstChild("SceneArt")
		if mod then
			local ok, m = pcall(require, mod)
			if ok and type(m) == "table" and m.draw then
				sceneArt = m
			end
		end
	end
	return sceneArt or nil
end

local DEFAULT = {
	lines = {
		"Every life starts somewhere.",
		"Yours starts here.",
	},
	title = "A LIFE",
	subtitle = "One year at a time.",
}

local NUMERALS = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" }
local RED = Color3.fromRGB(255, 46, 64)
local CYAN = Color3.fromRGB(70, 220, 255)

local function chars(s: string)
	local out = {}
	for _, code in utf8.codes(s) do
		table.insert(out, utf8.char(code))
	end
	return out
end

function Intro.play(ctx, gui: ScreenGui, intro, onDone, opts)
	intro = intro or DEFAULT
	opts = opts or {}
	local short = opts.short == true
	local done = false
	local vw = math.max(320, gui.AbsoluteSize.X)
	local big = math.clamp(vw / 1280, 0.42, 1.12) -- type scale for this screen

	local root = new("Frame", {
		Name = "Intro",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 50,
		Active = true,
		Parent = gui,
	})
	-- a dark vignette top and bottom, so text reads over the City
	for _, flip in { false, true } do
		new("Frame", {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, if flip then 1 else 0),
			Position = UDim2.fromScale(0, if flip then 1 else 0),
			Size = UDim2.fromScale(1, 0.42),
			ZIndex = 51,
			Parent = root,
		}, {
			new("UIGradient", {
				Rotation = if flip then 270 else 90,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 1) }),
			}),
		})
	end
	local pulse = new("Frame", { Name = "Pulse", BackgroundColor3 = RED, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 52, Parent = root })
	-- v0.8: a black screen that never goes still. Scanlines, embers rising, grain, glitches.
	local fx = new("Frame", { Name = "FX", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ClipsDescendants = true, ZIndex = 57, Parent = root })
	for i = 0, 44 do
		new("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.965,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, i / 45),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 57,
			Parent = fx,
		})
	end
	local grain = new("Frame", { Name = "Grain", BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 57, Parent = fx })
	local embers = {}
	for i = 1, 26 do
		local size = math.random(2, 4)
		local e = new("Frame", {
			BackgroundColor3 = if i % 3 == 0 then Color3.fromRGB(255, 190, 120) else RED,
			BackgroundTransparency = 0.25 + math.random() * 0.5,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(math.random(), math.random()),
			Size = UDim2.fromOffset(size, size),
			ZIndex = 57,
			Parent = fx,
		}, { Kit.round() })
		table.insert(embers, { frame = e, speed = 0.02 + math.random() * 0.05, drift = (math.random() - 0.5) * 0.02 })
	end
	local fxClock = 0
	local fxConn = RunService.Heartbeat:Connect(function(dt)
		fxClock += dt
		for _, em in embers do
			local p = em.frame.Position
			local y = p.Y.Scale - em.speed * dt
			local x = p.X.Scale + em.drift * dt
			if y < -0.02 then
				y, x = 1.02, math.random()
			end
			em.frame.Position = UDim2.fromScale(x, y)
		end
		grain.BackgroundTransparency = 0.975 + math.random() * 0.025
	end)
	local layer = new("Frame", { Name = "Layer", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 53, Parent = root })
	local flashFrame = new("Frame", { Name = "Flash", BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 58, Parent = root })
	local top = new("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 0), ZIndex = 56, Parent = root })
	local bottom = new("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, 0), ZIndex = 56, Parent = root })
	local skip = Kit.button({
		name = "SkipIntro",
		text = "Skip",
		style = "ghost",
		size = UDim2.fromOffset(90, 34),
		position = UDim2.new(1, -20, 1, -20),
		anchor = Vector2.new(1, 1),
		textSize = 14,
		zIndex = 60,
	})
	skip.Parent = root

	local function finish()
		if done then
			return
		end
		done = true
		if ctx.actions.cinematic then
			ctx.actions.cinematic(false)
		end
		Kit.tween(root, 0.5, { BackgroundTransparency = 1 })
		for _, d in root:GetDescendants() do
			if d:IsA("TextLabel") or d:IsA("TextButton") then
				Kit.tween(d, 0.35, { TextTransparency = 1 })
			end
			if d:IsA("Frame") then
				Kit.tween(d, 0.5, { BackgroundTransparency = 1 })
			end
		end
		task.delay(0.55, function()
			root:Destroy()
		end)
		-- the mode select comes up underneath while the intro fades
		if onDone then
			task.defer(onDone)
		end
	end
	skip.Activated:Connect(finish)
	local inputConn = UserInputService.InputBegan:Connect(function(input, processed)
		if processed or done then
			return
		end
		local t = input.UserInputType
		if t == Enum.UserInputType.Keyboard or t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.ButtonStart then
			finish()
		end
	end)
	root.Destroying:Connect(function()
		inputConn:Disconnect()
	end)

	-- waits, and says whether the intro is still playing
	local function hold(seconds: number): boolean
		local t0 = os.clock()
		while os.clock() - t0 < seconds do
			if done then
				return false
			end
			task.wait()
		end
		return not done
	end
	local function shot(name: string, cut: boolean?)
		if ctx.actions.shot then
			ctx.actions.shot(name, cut)
		end
	end
	local function flash(color: Color3, from: number?)
		if not Kit.effects then
			return
		end
		flashFrame.BackgroundColor3 = color
		flashFrame.BackgroundTransparency = from or 0.15
		Kit.tween(flashFrame, 0.6, { BackgroundTransparency = 1 })
	end
	local function jolt(amount: number)
		if Kit.effects and ctx.actions.shake then
			ctx.actions.shake(amount)
		end
		Kit.shake(layer, math.floor(10 * big), 0.3)
	end
	local function fadeOut(inst: GuiObject, seconds: number)
		for _, d in inst:GetDescendants() do
			if d:IsA("TextLabel") then
				Kit.tween(d, seconds, { TextTransparency = 1, TextStrokeTransparency = 1 })
			elseif d:IsA("Frame") then
				Kit.tween(d, seconds, { BackgroundTransparency = 1 })
			end
		end
		if inst:IsA("Frame") then
			Kit.tween(inst, seconds, { BackgroundTransparency = 1 })
		end
		task.delay(seconds + 0.05, function()
			inst:Destroy()
		end)
	end

	-- big text that slams in with red and cyan ghosts closing onto it
	local function slam(text: string, color: Color3, size: number, y: number)
		local px = math.floor(size * big)
		local holder = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, y),
			Size = UDim2.new(1, -40, 0, math.floor(px * 1.25)),
			ZIndex = 54,
			Parent = layer,
		})
		local function label(c: Color3, z: number, tr: number, dx: number)
			return new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(dx, 0),
				Size = UDim2.fromScale(1, 1),
				Text = text,
				FontFace = F.display,
				TextScaled = true,
				TextColor3 = c,
				TextTransparency = tr,
				ZIndex = z,
				Parent = holder,
			}, { new("UITextSizeConstraint", { MaxTextSize = px, MinTextSize = 12 }) })
		end
		local red = label(RED, 54, 0.25, math.floor(14 * big))
		local cyan = label(CYAN, 54, 0.25, -math.floor(14 * big))
		label(color, 55, 0, 0)
		local sc = new("UIScale", { Scale = 1.9, Parent = holder })
		Kit.tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
		-- the split jitters a moment (a bad signal) before it settles
		task.spawn(function()
			for _ = 1, 8 do
				if not holder.Parent then
					return
				end
				red.Position = UDim2.fromOffset(math.random(-8, 8) * big, math.random(-3, 3))
				cyan.Position = UDim2.fromOffset(math.random(-8, 8) * big, math.random(-3, 3))
				task.wait(0.04)
			end
			if holder.Parent then
				Kit.tween(red, 0.35, { Position = UDim2.fromOffset(0, 0), TextTransparency = 1 })
				Kit.tween(cyan, 0.35, { Position = UDim2.fromOffset(0, 0), TextTransparency = 1 })
			end
		end)
		return holder
	end

	local function caption(text: string, y: number, size: number?, color: Color3?, font: Font?)
		local l = new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, y),
			Size = UDim2.new(1, -48, 0, math.floor((size or 22) * big * 1.6) + 8),
			Text = text,
			TextWrapped = true,
			FontFace = font or F.serifItalic,
			TextSize = math.max(14, math.floor((size or 22) * big)),
			TextColor3 = color or C.paperHi,
			TextTransparency = 1,
			ZIndex = 55,
			Parent = layer,
		})
		Kit.tween(l, 0.6, { TextTransparency = 0 })
		return l
	end

	-- ── 1-2. cold open: the clock runs out ──
	local function coldOpen(): boolean
		local cold = intro.cold
		if not cold then
			return true
		end
		shot("alley", true)
		local place = new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, math.floor(36 * big) + 12, 0.14, 0),
			Size = UDim2.new(1, -48, 0, 24),
			Text = string.upper(cold.place or ""),
			FontFace = F.mono,
			TextSize = math.max(13, math.floor(18 * big)),
			TextColor3 = C.sub,
			TextXAlignment = Enum.TextXAlignment.Left,
			MaxVisibleGraphemes = 0,
			ZIndex = 55,
			Parent = layer,
		})
		local clock = new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -40, 0, math.floor(120 * big)),
			Text = cold.from or "03:12:55",
			FontFace = F.mono,
			TextSize = math.floor(110 * big),
			TextColor3 = C.paperHi,
			TextTransparency = 1,
			ZIndex = 55,
			Parent = layer,
		})
		Kit.tween(clock, 1.2, { TextTransparency = 0.05 })
		local n = utf8.len(place.Text) or #place.Text
		for i = 1, n do
			place.MaxVisibleGraphemes = i
			if not hold(0.03) then
				return false
			end
		end
		-- the last seconds tick away, each one a heartbeat
		local h, m, sec = string.match(cold.from or "03:12:55", "^(%d+):(%d+):(%d+)$")
		local s = tonumber(sec) or 55
		while s < 60 do
			if not hold(0.62) then
				return false
			end
			s += 1
			if s < 60 then
				clock.Text = string.format("%s:%s:%02d", h or "03", m or "12", s)
				ctx.sound("click")
				pulse.BackgroundTransparency = 0.9
				Kit.tween(pulse, 0.5, { BackgroundTransparency = 1 })
			end
		end
		-- 3:13
		clock.Text = cold.to or "03:13:00"
		clock.TextColor3 = RED
		shot("night", true)
		flash(Color3.new(1, 1, 1), 0.05)
		jolt(6)
		ctx.sound("lose")
		if ctx.music then
			ctx.music("introNight")
		end
		pulse.BackgroundTransparency = 0.55
		Kit.tween(pulse, 1.4, { BackgroundTransparency = 0.88 })
		Kit.tween(clock, 0.35, { TextTransparency = 0.7, Position = UDim2.fromScale(0.5, 0.3) })
		local stamp = slam(string.upper(cold.stamp or "THE NIGHT"), C.paperHi, 92, 0.52)
		local line = if cold.line then caption(cold.line, 0.66, 22, C.crimsonHi) else nil
		if not hold(2.6) then
			return false
		end
		fadeOut(stamp, 0.4)
		fadeOut(place, 0.4)
		if line then
			fadeOut(line, 0.4)
		end
		Kit.tween(clock, 0.4, { TextTransparency = 1 })
		Kit.tween(pulse, 0.6, { BackgroundTransparency = 1 })
		return hold(0.5)
	end

	-- ── 3. the montage ──
	local function montage(): boolean
		local cards = intro.cards
		if not cards or #cards == 0 then
			-- older packs: typed narration lines
			for _, text in intro.lines or {} do
				local l = caption(Format.escape(text), 0.5, 26)
				l.MaxVisibleGraphemes = 0
				local n = utf8.len(text) or #text
				for i = 1, n do
					l.MaxVisibleGraphemes = i
					if not hold(0.026) then
						return false
					end
				end
				if not hold(math.clamp(n * 0.03, 1.2, 2.8)) then
					return false
				end
				fadeOut(l, 0.45)
				if not hold(0.5) then
					return false
				end
			end
			return true
		end
		if ctx.music then
			ctx.music("intro")
		end
		for i, def in cards do
			local color = Theme.rgb(def.color or { 237, 196, 114 })
			if def.shot then
				shot(def.shot, def.cut == true)
			end
			local cardW = math.min(vw * 0.78, 940)
			local artH = math.floor(cardW * 0.3)
			local emblemSize = math.floor(64 * big) + 20
			local band = new("Frame", {
				Name = "Card",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(1.7, 0.47),
				Size = UDim2.fromOffset(cardW, artH + emblemSize + math.floor(70 * big) + 34),
				BackgroundTransparency = 1,
				ZIndex = 53,
				Parent = layer,
			})
			-- the picture: a drawn scene for this part of the City
			local picture = new("Frame", {
				Name = "Scene",
				BackgroundColor3 = Color3.fromRGB(10, 10, 14),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, artH),
				ClipsDescendants = true,
				ZIndex = 53,
				Parent = band,
			}, { Kit.corner(2) })
			Kit.stroke(color, 1, 0.3).Parent = picture
			local art = getSceneArt()
			if art and def.scene then
				pcall(function()
					local drawn = art.draw(picture, def.scene, i * 7, { fade = Color3.new(0, 0, 0) })
					if drawn and Kit.effects and art.animate then
						art.animate(drawn)
					end
				end)
			end
			new("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -10, 0, 8),
				Size = UDim2.fromOffset(120, 18),
				Text = string.format("%02d", i) .. "  /  " .. string.format("%02d", #cards),
				FontFace = F.mono,
				TextSize = math.max(12, math.floor(15 * big)),
				TextColor3 = color,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 56,
				Parent = band,
			})
			-- the mark of the faction, its name, and one line about it
			local mark = if def.emblem == "logo" or not def.emblem then Emblem.logo(emblemSize) else Emblem.make(def.emblem, emblemSize, color)
			mark.Position = UDim2.fromOffset(0, artH + 14)
			mark.ZIndex = 55
			mark.Parent = band
			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(emblemSize + 16, artH + 8),
				Size = UDim2.new(1, -emblemSize - 16, 0, emblemSize + 8),
				Text = string.upper(def.word or ""),
				FontFace = F.display,
				TextScaled = true,
				TextColor3 = color,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 55,
				Parent = band,
			}, { new("UITextSizeConstraint", { MaxTextSize = math.floor(84 * big) + 6, MinTextSize = 18 }) })
			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, artH + emblemSize + 26),
				Size = UDim2.new(1, 0, 0, math.floor(60 * big) + 12),
				Text = def.line or "",
				TextWrapped = true,
				FontFace = F.serifItalic,
				TextSize = math.max(14, math.floor(22 * big)),
				TextColor3 = C.paperHi,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 55,
				Parent = band,
			})
			ctx.sound("click")
			Kit.tween(band, 0.6, { Position = UDim2.fromScale(0.5, 0.47) }, Enum.EasingStyle.Quint)
			if not hold(def.hold or 2.3) then
				return false
			end
			Kit.tween(band, 0.45, { Position = UDim2.fromScale(-0.7, 0.47) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			task.delay(0.5, function()
				band:Destroy()
			end)
			if not hold(0.3) then
				return false
			end
		end
		return true
	end

	-- ── 4. the title ──
	local function title()
		shot("title", true)
		flash(Color3.fromRGB(255, 236, 200), if short then 0.3 else 0.1)
		-- the mark above the title
		local logo = Emblem.logo(math.floor(96 * big) + 24)
		logo.AnchorPoint = Vector2.new(0.5, 1)
		logo.Position = UDim2.new(0.5, 0, 0.44, -math.floor(70 * big))
		logo.ZIndex = 55
		logo.Parent = layer
		Kit.raise(logo, 55)
		local logoScale = new("UIScale", { Scale = 1.6, Parent = logo })
		Kit.tween(logoScale, 0.5, { Scale = 1 }, Enum.EasingStyle.Back)
		local px = math.floor(92 * big)
		local row = new("Frame", {
			Name = "Title",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.44),
			Size = UDim2.new(1, -40, 0, math.floor(px * 1.2)),
			ZIndex = 55,
			Parent = layer,
		}, {
			new("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		local letters = {}
		for i, ch in chars(string.upper(intro.title or "")) do
			local cell = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = i, ZIndex = 55, Parent = row })
			-- an invisible copy sizes the cell; the visible letter drops into it
			new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Text = if ch == " " then "  " else ch, FontFace = F.display, TextSize = px, TextTransparency = 1, ZIndex = 55, Parent = cell })
			local glyph = new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, -math.floor(40 * big)),
				Size = UDim2.fromScale(1, 1),
				Text = ch,
				FontFace = F.display,
				TextSize = px,
				TextColor3 = C.accentHi,
				TextTransparency = 1,
				TextStrokeColor3 = Color3.new(0, 0, 0),
				TextStrokeTransparency = 1,
				ZIndex = 56,
				Parent = cell,
			})
			table.insert(letters, glyph)
		end
		local step = if short then 0.025 else 0.045
		for _, glyph in letters do
			Kit.tween(glyph, 0.32, { Position = UDim2.fromOffset(0, 0), TextTransparency = 0, TextStrokeTransparency = 0.6 }, Enum.EasingStyle.Back)
			if not hold(step) then
				return
			end
		end
		ctx.sound("win")
		jolt(2)
		-- a light sweeps across the letters
		local sweepBox = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = row.AnchorPoint,
			Position = row.Position,
			Size = row.Size,
			ClipsDescendants = true,
			ZIndex = 57,
			Parent = layer,
		})
		local sweep = new("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(-0.3, 0),
			Size = UDim2.fromScale(0.16, 1),
			ZIndex = 57,
			Parent = sweepBox,
		}, {
			new("UIGradient", {
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.55), NumberSequenceKeypoint.new(1, 1) }),
			}),
		})
		Kit.tween(sweep, 0.9, { Position = UDim2.fromScale(1.2, 0) }, Enum.EasingStyle.Sine)
		local sub = caption(intro.subtitle or "", 0.44 + (px * 0.9) / math.max(400, gui.AbsoluteSize.Y), 22, C.sub)
		local fan = nil
		if ctx.info and ctx.info.fanWork then
			fan = caption("A fan game set in Project Moon's City. Not affiliated with Project Moon.", 0.86, 12, C.faint, F.ui)
		end
		if not hold(if short then 1.6 else 2.6) then
			return
		end
		-- the title lifts away into the menu
		local sc = new("UIScale", { Scale = 1, Parent = row })
		Kit.tween(sc, 0.5, { Scale = 0.82 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		Kit.tween(row, 0.5, { Position = UDim2.fromScale(0.5, 0.3) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		fadeOut(sub, 0.4)
		if fan then
			fadeOut(fan, 0.4)
		end
		hold(0.25)
		finish()
	end

	root.Destroying:Connect(function()
		fxConn:Disconnect()
	end)
	task.spawn(function()
		if ctx.actions.cinematic then
			ctx.actions.cinematic(true)
		end
		-- the opening shout, once, as it starts
		if ctx.sfx then
			ctx.sfx("intro")
		end
		if ctx.music then
			ctx.music("intro")
		end
		Kit.tween(top, 1, { Size = UDim2.fromScale(1, 0.1) })
		Kit.tween(bottom, 1, { Size = UDim2.fromScale(1, 0.1) })
		if not short then
			if not hold(0.6) or not coldOpen() or not montage() then
				return
			end
		elseif not hold(0.2) then
			return
		end
		title()
	end)
	return finish
end

-- ── the mode select ─────────────────────────────────────────────────────────

-- One game mode as a card. locked modes show how they open.
local function modeCard(ctx, parent: Instance, mode, index: number, opts, compact: boolean, wide: boolean?)
	local unlocked = (ctx.state.meta and ctx.state.meta.modes and ctx.state.meta.modes[mode.id]) == true or not mode.locked
	local color = Theme.rgb(mode.color or { 207, 163, 73 })
	local card = new("TextButton", {
		Name = "Mode_" .. mode.id,
		AutoButtonColor = false,
		BackgroundColor3 = C.panel,
		BackgroundTransparency = if unlocked then 0.06 else 0.3,
		BorderSizePixel = 0,
		Size = if compact then UDim2.new(1, 0, 0, 96) else UDim2.new(0.5, -5, 0, 150),
		Text = "",
		LayoutOrder = index,
		ClipsDescendants = true,
		ZIndex = 3,
		Parent = parent,
	}, { Kit.corner(2) })
	local stroke = Kit.stroke(if unlocked then color else C.stroke, 1, if unlocked then 0.45 else 0.3)
	stroke.Parent = card
	-- a color edge and a wash of the mode's color
	new("Frame", { BackgroundColor3 = color, BackgroundTransparency = if unlocked then 0 else 0.6, BorderSizePixel = 0, Size = UDim2.new(0, 5, 1, 0), ZIndex = 4, Parent = card })
	new("Frame", {
		BackgroundColor3 = color,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = card,
	}, {
		new("UIGradient", { Rotation = 0, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 1) }) }),
	})
	-- the big numeral, like a chapter number
	new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, if compact then -6 else -10),
		Size = UDim2.fromOffset(if wide then 150 else 120, if compact then 64 elseif wide then 110 else 90),
		Text = NUMERALS[index] or tostring(index),
		FontFace = F.display,
		TextSize = if compact then 58 elseif wide then 100 else 84,
		TextColor3 = color,
		TextTransparency = if unlocked then (if wide then 0.84 else 0.78) else 0.9,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 4,
		Parent = card,
	})
	local body = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(if wide then 22 else 18, if compact then 12 elseif wide then 20 else 16),
		Size = UDim2.new(1, if wide then -40 else -30, 1, if compact then -20 elseif wide then -36 else -28),
		ZIndex = 5,
		Parent = card,
	}, { Kit.list(if compact then 2 elseif wide then 6 else 4) })
	Kit.text({
		Text = string.upper(Format.escape(mode.name)),
		FontFace = F.display,
		TextSize = if compact then 19 elseif wide then 27 else 21,
		TextColor3 = if unlocked then C.text else C.sub,
		LayoutOrder = 1,
		ZIndex = 5,
		Parent = body,
	})
	Kit.text({
		Text = Format.escape(mode.tagline or ""),
		FontFace = F.serifItalic,
		TextSize = if wide then 15 else 13,
		TextColor3 = C.sub,
		LayoutOrder = 2,
		ZIndex = 5,
		Parent = body,
	})
	-- (v0.18) the menu says less: the name, the line under it and where it starts
	local facts = {}
	table.insert(facts, if (mode.startAge or 0) > 0 then "Starts at " .. mode.startAge else "From birth")
	if mode.career then
		table.insert(facts, mode.career)
	end
	if not unlocked then
		Kit.text({
			Text = Format.color("LOCKED  ", C.crimsonHi) .. Format.escape(mode.unlockText or ""),
			FontFace = F.uiMedium,
			TextSize = 11,
			TextColor3 = C.faint,
			LayoutOrder = 3,
			ZIndex = 5,
			Parent = body,
		})
		if mode.lightCost and not compact then
			local glow = (ctx.state.meta and ctx.state.meta.glow) or 0
			local lightName = (ctx.info and ctx.info.meta and ctx.info.meta.glowName) or "Light"
			Kit.button({
				name = "UnlockMode",
				text = string.format("Unlock · %d %s", mode.lightCost, lightName),
				style = if glow >= mode.lightCost then "primary" else "ghost",
				size = UDim2.new(0, 170, 0, 28),
				order = 4,
				textSize = 12,
				zIndex = 6,
				enabled = glow >= mode.lightCost,
				onClick = function()
					if opts.onUnlockMode then
						opts.onUnlockMode(mode.id)
					end
				end,
			}).Parent = body
		end
	else
		Kit.caps({
			Text = table.concat(facts, "  ·  "),
			FontFace = F.displayMed,
			TextSize = if wide then 12 else 11,
			TextColor3 = color,
			LayoutOrder = 3,
			ZIndex = 5,
			Parent = body,
		})
	end
	if wide and unlocked then
		new("TextLabel", {
			Name = "Begin",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 22, 1, -16),
			Size = UDim2.fromOffset(200, 18),
			Text = "BEGIN  \u{203A}",
			FontFace = F.display,
			TextSize = 15,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5,
			Parent = card,
		})
	end
	-- hover: the border lights up and thickens (no scaling: a scale changes the card's size
	-- in the layout, which made the cards reflow and jump under the cursor)
	card.MouseEnter:Connect(function()
		if unlocked then
			Kit.tween(stroke, 0.12, { Transparency = 0, Thickness = 2 })
		end
	end)
	card.MouseLeave:Connect(function()
		Kit.tween(stroke, 0.12, { Transparency = if unlocked then 0.45 else 0.3, Thickness = 1 })
	end)
	card.Activated:Connect(function()
		if unlocked then
			ctx.sound("click")
			task.delay(0.08, function()
				if opts.onMode then
					opts.onMode(mode.id)
				end
			end)
		elseif mode.lightCost and compact and opts.onUnlockMode then
			opts.onUnlockMode(mode.id)
		else
			ctx.toast(mode.unlockText or "This mode is locked.")
		end
	end)
	return card
end

-- The start menu over the City: Continue, the game modes, and the rest.
-- opts = { hasLife, lifeLine, onContinue, onMode(id), onUnlockMode(id), onFriends, onGuide, onLore, onMenu,
--          wide, canvasHeight }
-- (older callers pass onSolo instead of onMode)
-- opts.wide: the holder spans a wide screen, so the menu is two columns: who you are and how
-- hard it is on the left, the ways to begin on the right. canvasHeight (logical px) lets it
-- sit in the middle of the screen instead of hugging the top.
function Intro.menu(ctx, parent: Instance, opts)
	local info = ctx.info or {}
	local width = if parent:IsA("GuiObject") then parent.AbsoluteSize.X else 560
	-- (the caller measures the canvas; a wide one is never compact, however small the window)
	local compact = opts.wide ~= true and width < 470
	local wide = opts.wide == true
	local canvasH = if wide then (opts.canvasHeight or 780) else 0
	-- the mode cards take the height there is, and the whole block sits mid-screen
	-- (v0.18) a hidden mode (Fixer's Road) is never a card, even when the tests can start it
	local shownModes = {}
	for _, m in info.modes or {} do
		if not m.hidden then
			table.insert(shownModes, m)
		end
	end
	local modeRows = math.max(1, math.ceil(#shownModes / 2))
	-- (v0.18) tighter: smaller cards, less air above them
	local cardH = if wide then math.clamp(math.floor((canvasH - 260 - (modeRows - 1) * 10) / modeRows), 120, 156) else 150
	local topPad = if wide then math.clamp(math.floor((canvasH - (520)) / 2) - 10, 14, 110) else 14
	local frame = new("ScrollingFrame", {
		Name = "StartMenu",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.stroke,
		ZIndex = 3,
		Parent = parent,
	}, { Kit.padding(topPad, 8, 14, 8), Kit.list(10) })

	-- where things go: one column, or two side by side
	local colA: Instance, colB: Instance = frame, frame
	if wide then
		local cols = new("Frame", {
			Name = "Columns",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			ZIndex = 3,
			Parent = frame,
		}, { Kit.list(28, Enum.FillDirection.Horizontal) })
		colA = new("Frame", { Name = "Left", BackgroundTransparency = 1, Size = UDim2.new(0.4, -14, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, ZIndex = 3, Parent = cols }, { Kit.list(10) })
		colB = new("Frame", { Name = "Right", BackgroundTransparency = 1, Size = UDim2.new(0.6, -14, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 3, Parent = cols }, { Kit.list(10) })
	end

	-- the header
	local head = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, ZIndex = 3, Parent = colA }, { Kit.list(if wide then 4 else 2) })
	Kit.text({ Text = "THE CITY AWAITS", FontFace = F.type, TextSize = if wide then 16 else 14, TextColor3 = C.crimsonHi, LayoutOrder = 1, ZIndex = 3, Parent = head })
	Kit.text({ Text = string.upper(Format.escape((info.meta and info.meta.title) or "")), FontFace = F.display, TextSize = if compact then 36 elseif wide then 60 else 44, LayoutOrder = 2, ZIndex = 3, Parent = head })
	Kit.text({ Text = Format.escape((info.meta and info.meta.tagline) or ""), FontFace = F.serifItalic, TextSize = if wide then 17 else 14, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = 3, Parent = head })

	local first = nil
	local order = 1
	local function nextOrder()
		order += 1
		return order
	end
	-- with room for it, one plain paragraph on what this is

	-- (v0.18) the store, right on the start screen: what's in it, and the way in
	if ctx.actions and ctx.actions.openStore and info.store ~= false then
		local GOLD = Color3.fromRGB(255, 214, 120)
		local banner = new("Frame", {
			Name = "StartStore",
			BackgroundColor3 = Color3.fromRGB(40, 16, 28),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, if wide then 96 else 84),
			LayoutOrder = nextOrder(),
			ZIndex = 3,
			Parent = colA,
		}, { Kit.corner(8), Kit.stroke(GOLD, 1.5, 0.25) })
		new("UIGradient", { Rotation = 15, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 34, 58)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(44, 16, 32)), ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 10, 18)) }), Parent = banner })
		local okE, Emblem = pcall(function()
			return require(script.Parent.Emblem)
		end)
		if okE and Emblem then
			local ok2, icon = pcall(Emblem.make, "tab.store", if wide then 52 else 44, GOLD)
			if ok2 and icon then
				icon.AnchorPoint = Vector2.new(0, 0.5)
				icon.Position = UDim2.new(0, 14, 0.5, 0)
				icon.ZIndex = 4
				icon.Parent = banner
			end
		end
		local left = if wide then 80 else 70
		Kit.text({ Text = "THE CITY STORE", FontFace = F.display, TextSize = if wide then 24 else 20, TextColor3 = GOLD, AutomaticSize = Enum.AutomaticSize.None, Position = UDim2.fromOffset(left, if wide then 16 else 12), Size = UDim2.new(1, -left - 150, 0, 26), ZIndex = 4, Parent = banner })
		Kit.text({ Text = "Wing VIP, Lunacy with free bonuses, new looks for every life.", FontFace = F.serifItalic, TextSize = if wide then 14 else 12, TextColor3 = C.sub, AutomaticSize = Enum.AutomaticSize.None, Position = UDim2.fromOffset(left, if wide then 46 else 38), Size = UDim2.new(1, -left - 150, 0, 36), ZIndex = 4, Parent = banner })
		Kit.button({ name = "StartStoreOpen", text = "Open the store", style = "primary", size = UDim2.new(0, 136, 0, 40), position = UDim2.new(1, -12, 0.5, 0), anchor = Vector2.new(1, 0.5), textSize = 14, zIndex = 4, parent = banner, onClick = function()
			ctx.actions.openStore()
		end })
		pcall(function()
			require(script.Parent.Spring).hover(banner, { lighten = 0.1 })
		end)
	end

	-- a life already going comes first
	if opts.hasLife then
		local cont = Kit.button({
			name = "Continue",
			text = "Continue" .. (if opts.lifeLine then "  ·  " .. opts.lifeLine else ""),
			style = "primary",
			size = UDim2.new(1, 0, 0, 50),
			order = nextOrder(),
			textSize = 17,
			zIndex = 3,
			onClick = opts.onContinue,
		})
		cont.Parent = colA
		first = cont
	end

	-- HOW HARD: picked here, before any life starts; it can't be changed once you're born
	local diffs = info.difficulties
	if diffs and diffs.list and #diffs.list > 0 then
		local state = ctx.state
		state.difficulty = state.difficulty or (state.meta and state.meta.difficulty) or diffs.default
		Kit.caps({ Text = "How hard is the City?", FontFace = F.display, TextSize = 14, TextColor3 = C.accentHi, LayoutOrder = nextOrder(), ZIndex = 3, Parent = colA })
		local row = new("Frame", {
			Name = "Difficulty",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, if compact or wide then 46 else 40),
			LayoutOrder = nextOrder(),
			ZIndex = 3,
			Parent = colA,
		}, { Kit.list(8, Enum.FillDirection.Horizontal) })
		local desc = Kit.text({ Name = "DifficultyDesc", Text = "", FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 3, Parent = colA })
		local buttons = {}
		local function paint()
			for _, d in diffs.list do
				local b = buttons[d.id]
				local on = d.id == state.difficulty
				local color = if d.color then Theme.rgb(d.color) else C.accent
				b.BackgroundColor3 = if on then color:Lerp(Color3.new(0, 0, 0), 0.45) else C.panelLo
				b.TextColor3 = if on then Color3.new(1, 1, 1) else C.sub
				local stroke = b:FindFirstChildOfClass("UIStroke")
				if stroke then
					stroke.Color = if on then color else C.stroke
				end
				if on then
					desc.Text = d.desc or ""
				end
			end
		end
		for i, d in diffs.list do
			local b = new("TextButton", {
				Name = "Difficulty_" .. d.id,
				AutoButtonColor = false,
				BackgroundColor3 = C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.new(1 / #diffs.list, -6, 1, 0),
				Text = string.upper(d.name),
				FontFace = F.display,
				TextSize = if compact or wide then 12 else 14,
				TextWrapped = true,
				TextColor3 = C.sub,
				LayoutOrder = i,
				ZIndex = 3,
				Parent = row,
			}, { Kit.corner(2), Kit.stroke(C.stroke, 1, 0) })
			buttons[d.id] = b
			b.Activated:Connect(function()
				state.difficulty = d.id
				paint()
			end)
		end
		paint()
	end

	-- the modes
	local modes = shownModes
	if #modes > 0 then
		Kit.caps({ Text = if opts.hasLife then "Or start a new life" else "Choose how you begin", FontFace = F.display, TextSize = if wide then 15 else 14, TextColor3 = C.accentHi, LayoutOrder = nextOrder(), ZIndex = 3, Parent = colB })
		local grid = new("Frame", {
			Name = "Modes",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = nextOrder(),
			ZIndex = 3,
			Parent = colB,
		}, {
			-- a fixed grid: nothing a card does on hover can move its neighbours
			new("UIGridLayout", {
				CellSize = if compact then UDim2.new(1, 0, 0, 96) elseif wide then UDim2.new(0.5, -6, 0, cardH) else UDim2.new(0.5, -5, 0, 150),
				CellPadding = UDim2.fromOffset(10, 10),
				FillDirectionMaxCells = if compact then 1 else 2,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		for i, mode in modes do
			local card = modeCard(ctx, grid, mode, i, opts, compact, wide)
			first = first or card
		end
	else
		local solo = Kit.button({ name = "Solo", text = if opts.hasLife then "Start a new life" else "Begin a life", style = if opts.hasLife then "secondary" else "primary", size = UDim2.new(1, 0, 0, 48), order = nextOrder(), textSize = 17, zIndex = 3, onClick = function()
			if opts.onMode then
				opts.onMode(nil)
			elseif opts.onSolo then
				opts.onSolo()
			end
		end })
		solo.Parent = colB
		first = first or solo
	end

	-- the rest
	local row = new("Frame", { Name = "Rest", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 3, Parent = colA }, {
		new("UIGridLayout", {
			CellSize = UDim2.new(if compact or wide then 0.5 else 0.25, -6, 0, if wide then 46 else 42),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local function small(name: string, text: string, style: string, fn, o: number)
		Kit.button({ name = name, text = text, style = style, order = o, textSize = 14, zIndex = 3, onClick = fn }).Parent = row
	end
	small("Friends", "With friends", "secondary", opts.onFriends, 1)
	small("Guide", "Guidebook", "secondary", opts.onGuide, 2)
	small("Archive", "Archive", "ghost", opts.onLore, 3)
	small("Menu", "Menu", "ghost", opts.onMenu, 4)

	local wallet = {}
	local meta = ctx.state.meta or {}
	if (meta.glow or 0) > 0 or (info.meta and info.meta.glowName) then
		table.insert(wallet, Format.color(tostring(meta.glow or 0), C.accentHi) .. " " .. Format.escape((info.meta and info.meta.glowName) or "Light"))
	end
	if info.lunacy and info.storeOpen and info.meta and info.meta.premiumName then
		table.insert(wallet, Format.color(tostring(meta.lunacy or 0), Color3.fromRGB(240, 92, 120)) .. " " .. Format.escape(info.lunacy))
	end
	table.insert(wallet, tostring(meta.livesPlayed or 0) .. " lives lived")
	Kit.text({ Text = table.concat(wallet, "   ·   "), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 3, Parent = colA })
	if info.fanWork then
		Kit.text({
			Text = "A fan game set in Project Moon's City. Not affiliated with Project Moon.",
			FontFace = F.ui,
			TextSize = 11,
			TextColor3 = C.faint,
			LayoutOrder = nextOrder(),
			ZIndex = 3,
			Parent = colA,
		})
	end
	-- the cards come in one after another
	local sc = new("UIScale", { Scale = 0.94, Parent = frame })
	Kit.tween(sc, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
	return {
		frame = frame,
		first = first,
		destroy = function()
			frame:Destroy()
		end,
	}
end

return Intro
