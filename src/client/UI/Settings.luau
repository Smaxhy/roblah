--[[
	The menu sheet: sound, display, help, your family name, and (for admins) the mod menu.
		Settings.open(ctx, layer)
	Saves through ctx.actions.setSetting(key, value).
]]

local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Sheets = require(script.Parent.Sheets)
local Layout = require(script.Parent.Layout)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Settings = {}

-- A 0-1 slider with - and + buttons (so it works with a gamepad too).
function Settings.slider(parent: Instance, order: number, label: string, value: number, onChange)
	local holder = new("Frame", {
		Name = "Slider_" .. label,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52),
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	})
	local title = Kit.caps({ Text = label, FontFace = F.displayMed, TextSize = 13, TextColor3 = C.sub, Size = UDim2.new(1, -50, 0, 18), ZIndex = 2, Parent = holder })
	local readout = Kit.caps({
		Text = "",
		FontFace = F.mono,
		TextSize = 13,
		TextColor3 = C.accentHi,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(50, 18),
		ZIndex = 2,
		Parent = holder,
	})
	local track = new("TextButton", {
		Name = "Track",
		AutoButtonColor = false,
		Text = "",
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 40, 0, 26),
		Size = UDim2.new(1, -80, 0, 22),
		ZIndex = 2,
		Parent = holder,
	}, { Kit.corner(2), Kit.stroke(C.stroke, 1, 0.3) })
	local fill = new("Frame", { BackgroundColor3 = C.accent, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1), ZIndex = 2, Parent = track }, { Kit.corner(2) })
	local v = math.clamp(value, 0, 1)
	local function show()
		fill.Size = UDim2.fromScale(v, 1)
		readout.Text = math.floor(v * 100 + 0.5) .. "%"
	end
	local function set(nv: number, commit: boolean)
		v = math.clamp(math.floor(nv * 20 + 0.5) / 20, 0, 1)
		show()
		if commit then
			onChange(v)
		end
	end
	local dragging = false
	local function fromX(x: number)
		local abs, pos = track.AbsoluteSize.X, track.AbsolutePosition.X
		if abs > 0 then
			set((x - pos) / abs, false)
		end
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			onChange(v)
		end
	end)
	Kit.button({
		name = "Less",
		text = "-",
		style = "ghost",
		size = UDim2.fromOffset(32, 22),
		position = UDim2.new(0, 0, 0, 26),
		textSize = 16,
		zIndex = 2,
		onClick = function()
			set(v - 0.1, true)
		end,
	}).Parent = holder
	Kit.button({
		name = "More",
		text = "+",
		style = "ghost",
		size = UDim2.fromOffset(32, 22),
		position = UDim2.new(1, -32, 0, 26),
		textSize = 16,
		zIndex = 2,
		onClick = function()
			set(v + 0.1, true)
		end,
	}).Parent = holder
	show()
	return holder, title
end

-- A row of mutually exclusive choices.
function Settings.choice(parent: Instance, order: number, label: string, options, current: string, onPick)
	local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, ZIndex = 2, Parent = parent }, { Kit.list(6) })
	Kit.caps({ Text = label, FontFace = F.displayMed, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 1, ZIndex = 2, Parent = holder })
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 2, ZIndex = 2, Parent = holder }, {
		Kit.list(6, Enum.FillDirection.Horizontal),
	})
	local buttons = {}
	local function paint(sel: string)
		for id, b in buttons do
			b.BackgroundColor3 = if id == sel then C.accent else C.panelLo
			b.TextColor3 = if id == sel then C.ink else C.sub
		end
	end
	for i, opt in options do
		buttons[opt.id] = Kit.button({
			name = "Choice_" .. opt.id,
			text = opt.name,
			style = "ghost",
			size = UDim2.new(1 / #options, -6 + 6 / #options, 1, 0),
			order = i,
			textSize = 13,
			zIndex = 2,
			onClick = function()
				paint(opt.id)
				onPick(opt.id)
			end,
		})
		buttons[opt.id].Parent = row
	end
	paint(current)
	return holder
end

function Settings.open(ctx, layer: Instance)
	local sheet = Sheets.open(layer, "Menu")
	local content = sheet.content
	local settings = (ctx.state.meta and ctx.state.meta.settings) or {}
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end

	Sheets.sectionTitle(content, "Sound", nextOrder())
	Settings.choice(content, nextOrder(), "Music", { { id = "on", name = "On" }, { id = "off", name = "Off" } }, if settings.music == false then "off" else "on", function(id)
		ctx.actions.setSetting("music", id == "on")
	end)
	Settings.slider(content, nextOrder(), "Music volume", settings.musicVolume or 0.6, function(v)
		ctx.actions.setSetting("musicVolume", v)
	end)
	Settings.slider(content, nextOrder(), "Effects volume", settings.sfxVolume or 0.8, function(v)
		ctx.actions.setSetting("sfxVolume", v)
	end)

	Sheets.sectionTitle(content, "Display", nextOrder())
	Settings.choice(content, nextOrder(), "Interface size", {
		{ id = "small", name = "Small" },
		{ id = "auto", name = "Auto" },
		{ id = "big", name = "Big" },
		{ id = "huge", name = "Huge" },
	}, settings.uiScale or "auto", function(id)
		ctx.actions.setSetting("uiScale", id)
	end)
	Settings.choice(content, nextOrder(), "Screen shake and flashes", { { id = "on", name = "On" }, { id = "off", name = "Off" } }, if settings.effects == false then "off" else "on", function(id)
		ctx.actions.setSetting("effects", id == "on")
	end)
	Settings.choice(content, nextOrder(), "3D fight effects", { { id = "full", name = "Full" }, { id = "lite", name = "Lite" }, { id = "flat", name = "Off" } }, settings.vfx or "full", function(id)
		-- (v0.18) Lite: fewer particles and no flashing lights; Off: the flat fight screens
		ctx.actions.setSetting("vfx", id)
	end)
	Settings.choice(content, nextOrder(), "Intro when you join", { { id = "full", name = "Full" }, { id = "short", name = "Short" }, { id = "off", name = "Off" } }, settings.intro or "short", function(id)
		ctx.actions.setSetting("intro", id)
	end)
	Settings.choice(content, nextOrder(), "Cutscenes", { { id = "full", name = "All" }, { id = "fights", name = "Fights only" }, { id = "off", name = "Off" } }, settings.cutscenes or "full", function(id)
		ctx.actions.setSetting("cutscenes", id)
	end)
	Kit.text({
		Text = "Playing on " .. Layout.kind() .. ".",
		FontFace = F.ui,
		TextSize = 11,
		TextColor3 = C.faint,
		LayoutOrder = nextOrder(),
		ZIndex = 2,
		Parent = content,
	})

	Sheets.sectionTitle(content, "More", nextOrder())
	local function link(name: string, text: string, desc: string, fn, accent: Color3?)
		Sheets.row(content, nextOrder(), { title = text, desc = desc, accent = accent, onClick = function()
			sheet.close()
			task.delay(0.25, fn)
		end })
	end
	link("Surnames", "Family name", "Roll for a family name. Rarer names carry a small trait.", function()
		ctx.actions.openSurnames()
	end)
	link("Guide", "Guidebook", "How to play, and what everything does: stats, fights, talents, gear, factions.", function()
		ctx.actions.openGuide()
	end, C.accent)
	link("Tutorial", "Quick tour", "The tour of the screen again.", function()
		ctx.actions.startTutorial()
	end)
	link("Intro", "Watch the intro", "The full opening again.", function()
		ctx.actions.playIntro(true)
	end)
	if ctx.info and (ctx.info.storeOpen or (ctx.info.storeOpen == nil and not ctx.info.fanWork)) then
		link("Store", "Store", "Lunacy, family-name rolls, boosts, passes and looks.", function()
			ctx.actions.openStore()
		end)
	end
	if ctx.state.isAdmin then
		link("Admin", "Mod menu", "Start events, change today's event, edit any player's life, announce.", function()
			ctx.actions.openAdmin()
		end, C.crimson)
	end
	if ctx.info and ctx.info.fanWork then
		Kit.text({
			Text = "A fan game set in Project Moon's City. Not affiliated with or endorsed by Project Moon.",
			FontFace = F.serifItalic,
			TextSize = 11,
			TextColor3 = C.faint,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = content,
		})
	end
	return sheet
end

return Settings
