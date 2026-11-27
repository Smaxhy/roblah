--[[
	Celebrations and alerts:
		Celebrate.banner(ctx, layer, { title, sub, color })   a big stamped moment with sparks
		Celebrate.daily(ctx, layer, daily)                     the login-streak reward
		Celebrate.world(ctx, parent)                           the world-event strip (returns an updater)
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Celebrate = {}

local queue = {}
local showing = false

local function sparks(parent: Instance, color: Color3)
	for i = 1, 14 do
		local a = (i / 14) * math.pi * 2 + math.random() * 0.4
		local dist = 90 + math.random() * 70
		local spark = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(math.random(4, 8), math.random(4, 8)),
			BackgroundColor3 = if i % 3 == 0 then C.crimsonHi else color,
			BorderSizePixel = 0,
			Rotation = math.random(0, 90),
			ZIndex = 9,
			Parent = parent,
		})
		Kit.tween(spark, 0.7, {
			Position = UDim2.new(0.5, math.cos(a) * dist, 0.5, math.sin(a) * dist),
			BackgroundTransparency = 1,
			Rotation = math.random(90, 360),
		})
		task.delay(0.75, function()
			spark:Destroy()
		end)
	end
end

local function showNext(ctx, layer)
	local opts = table.remove(queue, 1)
	if not opts then
		showing = false
		return
	end
	showing = true
	local color = opts.color or C.accentHi
	local holder = new("Frame", {
		Name = "Celebration",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 4),
		Size = UDim2.new(1, -40, 0, 84),
		BackgroundTransparency = 1,
		ZIndex = 8,
		Parent = layer,
	})
	local card = Kit.panel({
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0,
		ZIndex = 8,
		Parent = holder,
	}, nil, color)
	Kit.padding(9, 14, 10, 14).Parent = card
	Kit.list(2, nil, Enum.HorizontalAlignment.Center).Parent = card
	Kit.stripes(card, color, 0.9, 6)
	local title = Kit.caps({
		Text = opts.title or "",
		FontFace = F.display,
		TextSize = 22,
		TextColor3 = color,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 1,
		ZIndex = 9,
		Parent = card,
	})
	local scale = new("UIScale", { Scale = 1.5, Parent = title })
	Kit.tween(scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)
	if opts.sub then
		Kit.text({
			Text = Format.escape(opts.sub),
			FontFace = F.serif,
			TextSize = 13,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = 2,
			ZIndex = 9,
			Parent = card,
		})
	end
	sparks(holder, color)
	ctx.sound("win")
	task.delay(opts.hold or 2.2, function()
		Kit.tween(card, 0.25, { BackgroundTransparency = 1 })
		for _, d in card:GetDescendants() do
			if d:IsA("TextLabel") then
				Kit.tween(d, 0.25, { TextTransparency = 1 })
			end
		end
		task.wait(0.3)
		holder:Destroy()
		showNext(ctx, layer)
	end)
end

-- Big moments queue up so they don't pile on top of each other.
function Celebrate.banner(ctx, layer: Instance, opts)
	table.insert(queue, opts)
	if not showing then
		showNext(ctx, layer)
	end
end

-- The daily streak popup. daily = { streak, day, glow, rewards = {...}, unlocked }
function Celebrate.daily(ctx, layer: Instance, daily)
	local scrim = Kit.scrim(layer, 1)
	Kit.tween(scrim, 0.2, { BackgroundTransparency = 0.35 })
	local card = Kit.panel({
		Name = "Daily",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -24, 0, 0),
		ZIndex = 2,
		Parent = layer,
	}, nil, C.accentHi)
	Kit.padding(18, 16, 18, 16).Parent = card
	Kit.list(10, nil, Enum.HorizontalAlignment.Center).Parent = card
	Kit.caps({ Text = (ctx.info and ctx.info.meta and ctx.info.meta.dailyTitle) or "Daily lantern", FontFace = F.type, TextSize = 14, TextColor3 = C.crimsonHi, TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 1, ZIndex = 2, Parent = card })
	Kit.caps({
		Text = string.format("Day %d of your streak", daily.streak or 1),
		FontFace = F.display,
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 2,
		ZIndex = 2,
		Parent = card,
	})
	local row = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 58),
		LayoutOrder = 3,
		ZIndex = 2,
		Parent = card,
	}, { Kit.list(6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center) })
	local glowName = ((ctx.info and ctx.info.meta and ctx.info.meta.glowName) or "Glow")
	for i, amount in daily.rewards or {} do
		local done = i <= (daily.day or 1)
		local today = i == (daily.day or 1)
		local box = new("Frame", {
			BackgroundColor3 = if today then C.accent elseif done then C.panelHi else C.panelLo,
			BorderSizePixel = 0,
			Size = UDim2.new(1 / 7, -6, 1, 0),
			LayoutOrder = i,
			ZIndex = 2,
			Parent = row,
		}, { Kit.corner(2), Kit.stroke(if today then C.accentHi else C.stroke, 1, 0.2) })
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = string.format('DAY %d\n<font size="16" face="RobotoMono">+%d</font>', i, amount),
			RichText = true,
			FontFace = F.displayMed,
			TextSize = 10,
			TextColor3 = if today then C.ink elseif done then C.text else C.faint,
			ZIndex = 3,
			Parent = box,
		})
	end
	Kit.text({
		Text = string.format("+%d %s today.", daily.glow or 1, glowName)
			.. (if daily.unlocked then "  Unlocked: " .. Format.escape(daily.unlocked) .. "." else "")
			.. "  Come back tomorrow to keep the streak going.",
		FontFace = F.serif,
		TextSize = 14,
		TextColor3 = C.sub,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 4,
		ZIndex = 2,
		Parent = card,
	})
	local close
	local button = Kit.button({
		text = "Collect",
		style = "primary",
		size = UDim2.new(1, 0, 0, 44),
		order = 5,
		zIndex = 2,
		onClick = function()
			close()
		end,
	})
	button.Parent = card
	function close()
		ctx.sound("coin")
		scrim:Destroy()
		card:Destroy()
	end
	ctx.sound("win")
	return close
end

-- The world-event strip. Returns set(world | nil).
function Celebrate.world(ctx, parent: Instance)
	local strip = new("TextButton", {
		Name = "WorldEvent",
		AutoButtonColor = false,
		BackgroundColor3 = C.crimson,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 38),
		Text = "",
		Visible = false,
		ZIndex = 6,
		Parent = parent,
	}, { Kit.corner(2), Kit.padding(0, 12, 0, 12) })
	local stripes = Kit.stripes(strip, Color3.fromRGB(0, 0, 0), 0.78, 6)
	stripes.ZIndex = 6
	local head = Kit.caps({
		Text = "",
		FontFace = F.display,
		TextSize = 14,
		TextColor3 = C.paperHi,
		Size = UDim2.new(1, -64, 1, 0),
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 7,
		Parent = strip,
	})
	local timer = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 60, 1, 0),
		Text = "",
		FontFace = F.mono,
		TextSize = 13,
		TextColor3 = C.paperHi,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 7,
		Parent = strip,
	})
	local current = nil
	local endsAt = 0
	strip.Activated:Connect(function()
		if current and ctx.prompt then
			local buttons = { { label = "OK", style = "ghost" } }
			if current.expedition and ctx.actions.openCrew then
				table.insert(buttons, 1, { label = "Find a crew", style = "danger", onClick = function()
					ctx.actions.openCrew()
				end })
			end
			ctx.prompt({ title = current.name, text = current.text, buttons = buttons })
		end
	end)
	task.spawn(function()
		while strip.Parent do
			task.wait(1)
			if current then
				local left = math.max(0, math.floor(endsAt - os.clock()))
				timer.Text = string.format("%d:%02d", left // 60, left % 60)
			end
		end
	end)
	return function(world)
		if not world or world.ended then
			current = nil
			strip.Visible = false
			return
		end
		current = world
		endsAt = os.clock() + (world.secondsLeft or 0)
		strip.BackgroundColor3 = if world.tone == "danger" then C.crimson elseif world.tone == "strange" then Color3.fromRGB(34, 92, 88) else C.accentLo
		stripes.Visible = world.tone == "danger"
		head.Text = string.upper(world.headline or world.name or "")
		strip.Visible = true
	end
end

return Celebrate
