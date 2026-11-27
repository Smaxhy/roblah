--[[
	The death scene: the few seconds between the last blow and the end-of-life screen.
		DeathScene.play(ctx, layer, { life = view, cause = string?, name = string? })   -- yields
	The City goes dark, the figure falls, the cause is typed out like the last line of a
	report, and the file is stamped CLOSED. A tap skips to the end. It draws on its own
	full-screen layer and removes itself.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local AvatarView = require(script.Parent.AvatarView)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local DeathScene = {}

function DeathScene.play(ctx, layer: Instance, opts)
	local life = opts.life
	if not life then
		return
	end
	local function sfx(name: string, o: any?)
		if ctx.sfx then
			ctx.sfx(name, o)
		end
	end
	local skip = false
	local root = new("TextButton", {
		Name = "DeathScene",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(40, 4, 6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 60,
		Parent = layer,
	})
	root.Activated:Connect(function()
		skip = true
	end)
	local function pause(t: number)
		local t0 = os.clock()
		while not skip and os.clock() - t0 < t do
			task.wait(0.03)
		end
	end

	-- red, then black
	Kit.tween(root, 0.25, { BackgroundTransparency = 0.15 })
	pause(0.3)
	Kit.tween(root, 0.7, { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0 })

	-- the figure, in a pool of light that shrinks
	local stage = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.4),
		Size = UDim2.fromOffset(240, 280),
		ZIndex = 61,
		Parent = root,
	})
	local pool = new("Frame", {
		Name = "Pool",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 8),
		Size = UDim2.fromOffset(240, 34),
		BackgroundColor3 = Color3.fromRGB(120, 24, 22),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		ZIndex = 61,
		Parent = stage,
	}, { Kit.round() })
	local holder = new("Frame", { Name = "Fallen", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(1, 1), ZIndex = 62, Parent = stage })
	local appearance = life.appearance or { look = life.look, age = life.age, form = life.form }
	pcall(function()
		local view = AvatarView.new(ctx, { size = UDim2.fromScale(1, 1), framing = "full", zIndex = 62, background = C.panel })
		view.frame.BackgroundTransparency = 1
		view.frame.Parent = holder
		view:set(appearance)
	end)
	pause(0.5)
	-- a stagger, then the fall
	Kit.tween(holder, 0.18, { Rotation = -8, Position = UDim2.new(0.5, -8, 1, 0) }, Enum.EasingStyle.Quad)
	pause(0.22)
	sfx("defeat", { volume = 0.7 })
	Kit.tween(holder, 0.55, { Rotation = 84, Position = UDim2.new(0.5, 30, 1, 30) }, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	Kit.tween(pool, 1.4, { Size = UDim2.fromOffset(60, 10), BackgroundTransparency = 0.8 })
	for _, d in holder:GetDescendants() do
		if d:IsA("ViewportFrame") then
			-- the color drains out of them
			Kit.tween(d, 1.2, { ImageColor3 = Color3.fromRGB(120, 120, 128) })
		end
	end
	pause(0.8)

	-- the last line of the report, typed
	local cause = opts.cause or "The City took them."
	local causeLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.66),
		Size = UDim2.new(0.86, 0, 0, 52),
		Text = "",
		FontFace = F.serifItalic,
		TextSize = 22,
		TextColor3 = Color3.fromRGB(226, 120, 108),
		TextWrapped = true,
		ZIndex = 62,
		Parent = root,
	}, { new("UISizeConstraint", { MaxSize = Vector2.new(640, 80) }) })
	for i = 1, #cause do
		if skip then
			break
		end
		causeLabel.Text = string.sub(cause, 1, i)
		if i % 4 == 0 then
			sfx("click", { volume = 0.2, pitch = 1.4 })
		end
		task.wait(0.028)
	end
	causeLabel.Text = cause
	pause(0.35)
	local name = opts.name or ((life.first or "") .. " " .. (life.last or ""))
	local years = if life.bornYear and life.year then string.format("%d – %d", life.bornYear, life.year) else ""
	local line = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.76),
		Size = UDim2.new(0.86, 0, 0, 24),
		Text = string.upper(Format.escape(name)) .. (if years ~= "" then "   ·   " .. years else "") .. "   ·   AGE " .. tostring(life.age or 0),
		FontFace = F.display,
		TextSize = 18,
		TextColor3 = C.text,
		TextTransparency = 1,
		ZIndex = 62,
		Parent = root,
	})
	Kit.tween(line, 0.4, { TextTransparency = 0 })
	pause(0.5)
	-- the file is closed
	local stampHolder = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.4), Size = UDim2.fromOffset(320, 120), ZIndex = 63, Parent = root })
	pcall(function()
		Kit.stamp(stampHolder, "File closed", C.crimsonHi, { Position = UDim2.fromScale(0.5, 0.5), TextSize = 40, Rotation = -8 })
	end)
	sfx("shatter", { volume = 0.6 })
	if not skip and ctx.actions and ctx.actions.shake then
		pcall(ctx.actions.shake, 0.3)
	end
	pause(1.3)
	-- out
	for _, d in root:GetDescendants() do
		if d:IsA("TextLabel") then
			Kit.tween(d, 0.3, { TextTransparency = 1 })
		elseif d:IsA("ViewportFrame") then
			Kit.tween(d, 0.3, { ImageTransparency = 1 })
		elseif d:IsA("Frame") and d.BackgroundTransparency < 1 then
			Kit.tween(d, 0.3, { BackgroundTransparency = 1 })
		end
	end
	task.wait(0.32)
	Kit.tween(root, 0.3, { BackgroundTransparency = 1 })
	task.delay(0.32, function()
		if root.Parent then
			root:Destroy()
		end
	end)
end

return DeathScene
