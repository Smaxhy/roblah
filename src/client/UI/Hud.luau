--[[
	Main life screen, styled as a case file: a FILE card header, the life log
	as a running report, segmented stat bars, and the action bar.
]]

local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local AvatarView = require(script.Parent.AvatarView)
local Celebrate = require(script.Parent.Celebrate)
local Emblem = require(script.Parent.Emblem)
local Tip = require(script.Parent.Tip)
local Layout = require(script.Parent.Layout)
local Feed = require(script.Parent.Feed)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local MAX_LOG_ITEMS = 160
local SEGMENTS = 5 -- the tiers of a stat (a notch on its bar at each)

local Hud = {}
Hud.__index = Hud

-- a stat's level: I to V, then (v0.13) VI at 100 and VII at 120, for a life whose limits broke,
-- and (v0.17) on to XXI at 400
local LEVELS = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI" }
local function levelOf(v: number): string
	return LEVELS[math.clamp(math.floor(v / 20) + 1, 1, #LEVELS)]
end

-- A STAT: its mark, its name, its tier on a tag of its color, the number, and a bar. The bar
-- is one smooth fill over a dark track with a notch at every tier (20, 40, 60, 80), so you
-- can see how far the next perk is.
local function statBar(parent, def, order, key: string?)
	local color = Theme.rgb(def.color)
	local bright = color:Lerp(Color3.new(1, 1, 1), 0.25)
	local frame = new("Frame", { Name = "Stat_" .. tostring(key or order), BackgroundTransparency = 1, LayoutOrder = order, Parent = parent })
	local icon = if key then Emblem.make("stat." .. key, 14, color) else nil
	if icon then
		icon.Position = UDim2.fromOffset(0, 0)
		icon.Parent = frame
	end
	Kit.caps({ Text = def.name, Position = UDim2.fromOffset(if icon then 19 else 0, 0), Size = UDim2.new(1, -86, 0, 14), TextSize = 12, TextColor3 = C.text, TextTruncate = Enum.TextTruncate.AtEnd, Parent = frame })
	-- (v0.17) the level and the number side by side, from the right: numbers like 400/400 and
	-- levels like XVIII never run into each other
	local right = new("Frame", {
		Name = "Right",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, -2),
		Size = UDim2.new(0, 0, 0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = frame,
	}, {
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local level = new("TextLabel", {
		Name = "Level",
		BackgroundColor3 = color,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 26, 0, 15),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "I",
		FontFace = F.display,
		TextSize = 12,
		TextColor3 = bright,
		LayoutOrder = 1,
		Parent = right,
	}, { Kit.corner(3), Kit.padding(0, 3, 0, 3) })
	local value = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 24, 0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "0",
		FontFace = F.mono,
		TextSize = 15,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Right,
		LayoutOrder = 2,
		Parent = right,
	})
	local track = new("Frame", {
		Name = "Track",
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 18),
		Size = UDim2.new(1, 0, 0, 6),
		ClipsDescendants = true,
		Parent = frame,
	}, { Kit.corner(3), Kit.stroke(C.stroke, 1, 0.45) })
	local fill = new("Frame", {
		Name = "Fill",
		BackgroundColor3 = bright,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = track,
	}, {
		Kit.corner(3),
		-- dimmer where it starts, brightest at its leading end
		new("UIGradient", { Color = ColorSequence.new(color:Lerp(Color3.new(0, 0, 0), 0.45), Color3.new(1, 1, 1)) }),
	})
	-- a notch at every tier
	for i = 1, SEGMENTS - 1 do
		new("Frame", {
			Name = "Notch",
			BackgroundColor3 = C.shade,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(i / SEGMENTS, 0, 0, 0),
			Size = UDim2.new(0, 2, 1, 0),
			ZIndex = 2,
			Parent = track,
		})
	end
	return {
		anchor = value,
		-- max: Health's maximum when it isn't 100 ("142/160"); over the maximum the bar is full
		-- and the number turns gold
		set = function(v: number, max: number?, skill: boolean?)
			local top = max or 100
			value.Text = if max and max ~= 100 then string.format("%d<font size=\"11\" color=\"#8a8f99\">/%d</font>", v, max) else tostring(v)
			value.RichText = true
			-- (past 100 a stat is beyond what most lives ever reach: its number turns gold)
			value.TextColor3 = if (max and v > max) or (skill and v > 100) then C.money else C.text
			level.Text = levelOf(v)
			Kit.tween(fill, 0.35, { Size = UDim2.new(math.clamp(v / math.max(1, top), 0, 1), 0, 1, 0) }, Enum.EasingStyle.Quart)
		end,
	}
end

-- floating "+3" / "-2" next to a label when a number changes
local function popup(anchor: GuiObject, delta: number, positive: Color3?, negative: Color3?)
	if delta == 0 or not anchor.Parent then
		return
	end
	local label = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -2, 0, 2),
		Size = UDim2.new(0, 60, 0, 16),
		Text = (if delta > 0 then "+" else "") .. Format.number(delta),
		FontFace = F.display,
		TextSize = 14,
		TextColor3 = if delta > 0 then (positive or C.good) else (negative or C.bad),
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 5,
		Parent = anchor,
	})
	Kit.tween(label, 1.1, { Position = UDim2.new(1, -2, 0, -16), TextTransparency = 1 })
	task.delay(1.15, function()
		label:Destroy()
	end)
end

function Hud.build(ctx, parent)
	local self = setmetatable({}, Hud)
	self.ctx = ctx
	self.info = ctx.info
	self.order = 0
	self.items = {}
	self.busy = false

	local root = new("Frame", {
		Name = "Hud",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = parent,
	})
	self.root = root

	-- ── FILE card ──
	local header = Kit.panel({
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 112),
		AutomaticSize = Enum.AutomaticSize.None,
		Parent = root,
	}, nil, C.accent)
	Kit.padding(10, 14, 10, 14).Parent = header
	-- mugshot: the character as they look right now (gear, injuries, age)
	self.portrait = AvatarView.new(ctx, { size = UDim2.fromOffset(60, 64), framing = "portrait", chart = true })
	self.portrait.frame.Parent = header
	Kit.stroke(C.stroke, 1, 0).Parent = self.portrait.frame
	local TEXT_X = 72
	self.fileLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, TEXT_X, 0, 0),
		Size = UDim2.new(0.4, 0, 0, 14),
		Text = "FILE 0000",
		FontFace = F.type,
		TextSize = 13,
		TextColor3 = C.crimsonHi,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	self.placeLabel = Kit.caps({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.6, 0, 0, 14),
		TextSize = 12,
		TextColor3 = C.faint,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header,
	})
	-- the name shrinks to fit before it's ever cut short: it's the one thing here that's yours
	self.nameLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, TEXT_X, 0, 16),
		Size = UDim2.new(1, -96 - TEXT_X, 0, 32),
		Text = "",
		FontFace = F.display,
		TextSize = 28,
		TextScaled = true,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	}, { new("UITextSizeConstraint", { MaxTextSize = 28, MinTextSize = 16 }) })
	self.subLabel = Kit.caps({
		Position = UDim2.new(0, TEXT_X, 0, 48),
		Size = UDim2.new(1, -96 - TEXT_X, 0, 16),
		TextSize = 13,
		TextColor3 = C.sub,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	self.moneyLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 20),
		Size = UDim2.new(0, 96, 0, 24),
		Text = "",
		FontFace = F.mono,
		TextSize = 20,
		TextColor3 = C.money,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header,
	})
	Kit.caps({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 46),
		Size = UDim2.new(0, 120, 0, 14),
		Text = self.info.meta.currency,
		TextSize = 11,
		TextColor3 = C.faint,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header,
	})
	self.chips = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -24),
		Size = UDim2.new(1, 0, 0, 24),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		ZIndex = 3,
		Parent = header,
	}, { Kit.list(6, Enum.FillDirection.Horizontal) })
	local headerTap = new("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -120, 0, 64),
		Text = "",
		ZIndex = 2,
		Parent = header,
	})
	headerTap.Activated:Connect(function()
		ctx.actions.openDistrict()
	end)
	self.header = header

	-- ── nav: goals, crew, rankings, store, music ──
	local nav = new("Frame", {
		Name = "Nav",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 120),
		Size = UDim2.new(1, 0, 0, 34),
		Parent = root,
	}, { Kit.list(6, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center) })
	self.navButtons = {}
	self.nav = nav
	-- Goals, the archive (lore), the City, your crew, the rankings, and the menu
	-- (sound, display, family name, help, the store where there is one, the mod menu)
	local navItems = {
		{ id = "family", text = "People", action = "openFamily", w = 0.22 },
		{ id = "story", text = "Story", action = "openStory", w = 0.2 },
		{ id = "you", text = "You", action = "openYouPanel", w = 0.16 },
		{ id = "city", text = "City", action = "openCityPanel", w = 0.18 },
		{ id = "menu", text = "More", action = "openMorePanel", w = 0.24 },
	}
	for i, item in navItems do
		local b = Kit.button({
			name = "Nav_" .. item.id,
			text = item.text,
			style = if item.id == "menu" then "paper" else "ghost",
			size = UDim2.new(item.w, -5, 1, 0),
			order = i,
			textSize = 13,
			onClick = function()
				local fn = ctx.actions[item.action]
				if fn then
					fn()
				end
			end,
		})
		b.Parent = nav
		self.navButtons[item.id] = b
	end

	self:buildStoryStrip(ctx, root)

	-- ── companions: linked friends you're living alongside ──
	local companions = Kit.panel({
		Name = "Companions",
		Position = UDim2.new(0, 0, 0, 162),
		Size = UDim2.new(1, 0, 0, 44),
		AutomaticSize = Enum.AutomaticSize.None,
		Visible = false,
		Parent = root,
	})
	Kit.padding(0, 10, 0, 12).Parent = companions
	Kit.caps({
		Text = "With you",
		FontFace = F.display,
		Size = UDim2.new(0, 62, 1, 0),
		TextSize = 12,
		TextColor3 = C.strange,
		Parent = companions,
	})
	self.companionList = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 66, 0, 0),
		Size = UDim2.new(1, -66, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		Parent = companions,
	}, { Kit.list(8, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center) })
	self.companions = companions
	self.companionViews = {}

	-- ── the report (life log) ──
	local logPanel = Kit.panel({
		Name = "Log",
		Position = UDim2.new(0, 0, 0, 162),
		Size = UDim2.new(1, 0, 1, -162 - 214),
		AutomaticSize = Enum.AutomaticSize.None,
		ClipsDescendants = true,
		Parent = root,
	})
	self.logPanel = logPanel
	-- the world-event strip sits over the top of the log while one is on
	local setWorldStrip = Celebrate.world(ctx, root)
	self.worldStrip = root:FindFirstChild("WorldEvent")
	self.setWorld = function(world)
		setWorldStrip(world)
		self:layout()
	end
	local scroll = new("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.strokeHi,
		Parent = logPanel,
	}, {
		Kit.padding(10, 14, 16, 14),
		Kit.list(8),
	})
	self.scroll = scroll

	-- ── stats ──
	-- two columns of bars on a phone; one column in the left panel of a wide screen
	local statCount = #self.info.stats.order
	local statRows = math.ceil(statCount / 2)
	self.statCount = statCount
	self.statsH = statRows * 32 + 50
	local statsPanel = Kit.panel({
		Name = "Stats",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -92),
		Size = UDim2.new(1, 0, 0, self.statsH),
		AutomaticSize = Enum.AutomaticSize.None,
		Parent = root,
	})
	self.statsPanel = statsPanel
	Kit.padding(10, 14, 10, 14).Parent = statsPanel
	local gridLayout = new("UIGridLayout", {
		CellSize = UDim2.new(0.5, -8, 0, 26),
		CellPadding = UDim2.new(0, 16, 0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local grid = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, statRows * 32 - 6),
		Parent = statsPanel,
	}, { gridLayout })
	self.statGrid, self.statGridLayout = grid, gridLayout
	self.statBars = {}
	for i, key in self.info.stats.order do
		self.statBars[key] = statBar(grid, self.info.stats.defs[key], i, key)
	end

	-- sanity: a centered meter with tick marks
	local sanityRow = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, statRows * 32 + 2),
		Size = UDim2.new(1, 0, 0, 28),
		Parent = statsPanel,
	})
	self.sanityRow = sanityRow
	-- hover (or tap) a stat to read what it does
	self:attachStatTips(grid)
	Tip.attach(sanityRow, "Sanity", "Tilts every coin you flip: heads chance is 50% plus your Sanity. At the bottom, you break.")
	self.sanityLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.55, 0, 0, 15),
		Text = "SANITY",
		RichText = true,
		FontFace = F.displayMed,
		TextSize = 12,
		TextColor3 = C.sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sanityRow,
	})
	self.headsLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.45, 0, 0, 15),
		Text = "",
		FontFace = F.mono,
		TextSize = 12,
		TextColor3 = C.faint,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = sanityRow,
	})
	local track = new("Frame", {
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 19),
		Size = UDim2.new(1, 0, 0, 7),
		Parent = sanityRow,
	})
	for i = 1, 9 do
		new("Frame", {
			BackgroundColor3 = if i == 5 then C.strokeHi else C.stroke,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(i / 10, 0, 0.5, 0),
			Size = UDim2.new(0, if i == 5 then 2 else 1, 1, if i == 5 then 6 else 2),
			ZIndex = 2,
			Parent = track,
		})
	end
	self.sanityFill = new("Frame", {
		BackgroundColor3 = C.strange,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		Parent = track,
	})

	self:buildYearStrip(root)

	-- ── action bar ──
	local bar = new("Frame", {
		Name = "Actions",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 84),
		Parent = root,
	})
	local activities, setActivities = Kit.button({
		name = "Activities",
		text = "Activities",
		style = "secondary",
		size = UDim2.new(0.3, -6, 0, 56),
		position = UDim2.new(0, 0, 0.5, 0),
		anchor = Vector2.new(0, 0.5),
		textSize = 17,
		onClick = function()
			ctx.actions.openActivities()
		end,
	})
	activities.Parent = bar
	self.activitiesButton = activities
	self.setActivitiesEnabled = setActivities
	self.actionsBadge = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 5, 0, -6),
		Size = UDim2.new(0, 20, 0, 20),
		BackgroundColor3 = C.crimson,
		Text = "3",
		FontFace = F.display,
		TextSize = 13,
		TextColor3 = C.text,
		ZIndex = 3,
		Parent = activities,
	}, { Kit.corner(2) })

	local menu, setMenu = Kit.button({
		name = "LifeMenu",
		text = "Life",
		style = "secondary",
		size = UDim2.new(0.3, -6, 0, 56),
		position = UDim2.new(1, 0, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		textSize = 17,
		onClick = function()
			ctx.actions.openLife()
		end,
	})
	menu.Parent = bar
	self.lifeButton = menu
	self.setMenuEnabled = setMenu

	local age, setAge = Kit.button({
		name = "AgeUp",
		text = "",
		style = "primary",
		size = UDim2.new(0.4, -4, 0, 66),
		position = UDim2.new(0.5, 0, 0.5, 0),
		anchor = Vector2.new(0.5, 0.5),
		onClick = function()
			ctx.actions.ageUp()
		end,
	})
	age.Parent = bar
	self.ageButton = age
	self.actionBar = bar
	-- (lit from above by Kit.button itself)
	Kit.brackets(age, C.ink, 8, 2, 3)
	-- crimson top edge
	new("Frame", {
		BackgroundColor3 = C.crimson,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 3),
		ZIndex = 2,
		Parent = age,
	})
	self.setAgeEnabled = setAge
	self:buildLeft()
	self.ageLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		RichText = true,
		FontFace = F.display,
		TextSize = 24,
		TextColor3 = C.ink,
		ZIndex = 3,
		Parent = age,
	})
	return self
end

-- ── pieces of the life screen, each built by its own function ───────────────
function Hud:buildStoryStrip(ctx: any, root: any)
	-- ── your story: the current goal, always in sight (tap for the Story tab) ──
	local storyStrip = new("TextButton", {
		Name = "StoryStrip",
		AutoButtonColor = false,
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 120),
		Size = UDim2.new(1, 0, 0, 58),
		Text = "",
		Visible = false,
		ClipsDescendants = true,
		Parent = root,
	}, { Kit.corner(3) })
	Kit.stroke(C.stroke, 1, 0.3).Parent = storyStrip
	self.storyBar = new("Frame", { BackgroundColor3 = C.crimsonHi, BorderSizePixel = 0, Size = UDim2.new(0, 4, 1, 0), Parent = storyStrip })
	-- top line: whose story this is, and its chapters as pips
	self.storyTag = new("TextLabel", {
		Name = "StoryTag",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 7),
		Size = UDim2.new(1, -190, 0, 15),
		Text = "",
		FontFace = F.display,
		TextSize = 13,
		TextColor3 = C.crimsonHi,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = storyStrip,
	})
	self.storyPips = new("Frame", {
		Name = "Chapters",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 9),
		Size = UDim2.new(0, 160, 0, 10),
		Parent = storyStrip,
	}, { Kit.list(4, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center) })
	-- under it: what to do now, and when the next chapter comes
	self.storyLabel = new("TextLabel", {
		Name = "StoryGoal",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 25),
		Size = UDim2.new(1, -130, 0, 28),
		Text = "",
		RichText = true,
		FontFace = F.serif,
		TextSize = 13,
		TextColor3 = C.text,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = storyStrip,
	})
	self.storyNext = new("TextLabel", {
		Name = "StoryNext",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 28),
		Size = UDim2.new(0, 110, 0, 22),
		Text = "",
		RichText = true,
		FontFace = F.displayMed,
		TextSize = 12,
		TextColor3 = C.sub,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = storyStrip,
	})
	storyStrip.Activated:Connect(function()
		if ctx.actions.openStory then
			ctx.actions.openStory()
		end
	end)
	self.storyStrip = storyStrip

end

function Hud:buildYearStrip(root: any)
	-- ── this year: what's left to spend ──
	local yearStrip = new("Frame", {
		Name = "ThisYear",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -86),
		Size = UDim2.new(1, 0, 0, 20),
		Parent = root,
	}, { Kit.list(14, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center) })
	self.yearStrip = yearStrip
	local function counter(name: string, label: string, color: Color3, order: number, tip: string)
		local holder = new("Frame", { Name = name, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order, Parent = yearStrip }, {
			Kit.list(4, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center),
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = label,
			FontFace = F.display,
			TextSize = 12,
			TextColor3 = C.sub,
			LayoutOrder = 0,
			Parent = holder,
		})
		Tip.attach(holder, label, tip)
		return { holder = holder, color = color, pips = {} }
	end
	self.counters = {
		actions = counter("Do", "DO", C.accentHi, 1, "Things you can still do this year. Speed and Intelligence give you more."),
		social = counter("People", "PEOPLE", C.strange, 2, "Time you still have for family and friends this year. Charisma gives you more."),
	}

end

function Hud:attachStatTips(grid: any)
	for _, key in self.info.stats.order do
		local def = self.info.stats.defs[key]
		local row = grid:FindFirstChild("Stat_" .. key)
		if row and def then
			Tip.attach(row, def.name, function()
				-- what it is, then the perks you have from it, then the next one
				local lines = { def.desc }
				local perks = self.life and self.life.perks and self.life.perks[key]
				if perks then
					for _, p in perks.have do
						table.insert(lines, "✓ " .. p.name .. ": " .. p.desc)
					end
					if perks.next then
						table.insert(lines, "At " .. tostring(perks.next.at) .. ": " .. perks.next.name .. ". " .. perks.next.desc)
					end
				end
				local nature = self.life and self.life.nature
				if nature and nature.stat == key then
					table.insert(lines, "Your nature: " .. nature.name .. ". " .. nature.desc)
				end
				return table.concat(lines, "\n")
			end)
		end
	end
end

function Hud:setCounters(life: any)
	-- this year's counters: a pip for each thing you can still do
	local function pips(c, left: number?, total: number?)
		c.holder.Visible = total ~= nil and total > 0
		if not c.holder.Visible then
			return
		end
		for i = 1, math.max(total or 0, #c.pips) do
			local pip = c.pips[i]
			if not pip then
				pip = new("Frame", { Name = "Pip", BorderSizePixel = 0, Size = UDim2.fromOffset(10, 10), LayoutOrder = i, Parent = c.holder }, { Kit.corner(5) })
				c.pips[i] = pip
			end
			pip.Visible = i <= (total or 0)
			pip.BackgroundColor3 = if i <= (left or 0) then c.color else C.stroke
		end
	end
	pips(self.counters.actions, life.actionsLeft, life.actionsPerYear)
	pips(self.counters.social, life.socialLeft, life.socialPerYear)
end

function Hud:setStory(story: any)
	if story and story.name then
		local tone = Theme.tone(story.tone)
		self.storyBar.BackgroundColor3 = tone
		self.storyTag.TextColor3 = tone
		self.storyTag.Text = "YOUR STORY  ·  " .. string.upper(story.name)
		local line = if story.ending then story.ending else (story.goal or story.hook or "")
		self.storyLabel.Text = Format.escape(line)
		-- the chapters: behind you, the next one, still ahead
		for _, child in self.storyPips:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		for i, ch in story.chapters or {} do
			local pip = new("Frame", {
				Name = "Pip",
				BackgroundColor3 = if ch.state == "done" then tone elseif ch.state == "next" then C.text else C.stroke,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(if ch.state == "next" then 12 else 9, 9),
				LayoutOrder = i,
				Parent = self.storyPips,
			}, { Kit.corner(2) })
			Tip.attach(pip, if ch.title then ch.title else "Age " .. tostring(ch.age), if ch.state == "done" then "Behind you." elseif ch.state == "next" then "Comes at " .. tostring(ch.age) .. "." else nil)
		end
		self.storyNext.Text = if story.ending
			then Format.color("ENDED", C.faint)
			elseif story.nextAge then "NEXT  ·  " .. Format.color("AGE " .. tostring(story.nextAge), C.text)
			else ""
	end
end

-- ── WIDE SCREENS: the left panel. Who you are, at full height. ──────────────
-- Built once; shown when the screen has room for three panels (Hud:setWide). The stat bars
-- and the chips move into it, and the small file card above the log goes away.
function Hud:buildLeft()
	local ctx = self.ctx
	local left = Kit.panel({
		Name = "You",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, -Layout.GAP, 0, 0),
		Size = UDim2.new(0, 300, 1, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		Visible = false,
		Parent = self.root,
	}, nil, C.accent)
	Kit.padding(12, 14, 12, 14).Parent = left
	self.left = left
	-- the figure, head to foot, against the height chart
	local stage = new("Frame", {
		Name = "Stage",
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 232),
		ClipsDescendants = true,
		Parent = left,
	})
	Kit.stroke(C.stroke, 1, 0).Parent = stage
	-- light rising from the floor behind them, in the color of their nature
	self.stageGlow = new("Frame", {
		Name = "Glow",
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0.72),
		Parent = stage,
	}, {
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 0.86), NumberSequenceKeypoint.new(1, 0.6) }) }),
	})
	self.figure = AvatarView.new(ctx, { size = UDim2.fromScale(1, 1), framing = "full", chart = true, background = false })
	self.figure.frame.Parent = stage
	self.leftFile = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 6),
		Size = UDim2.new(0.5, 0, 0, 14),
		Text = "FILE 0000",
		FontFace = F.type,
		TextSize = 13,
		TextColor3 = C.crimsonHi,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = stage,
	})
	self.leftDifficulty = Kit.caps({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 6),
		Size = UDim2.new(0.5, 0, 0, 14),
		TextSize = 11,
		TextColor3 = C.faint,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 3,
		Parent = stage,
	})
	local stageTap = new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 4, Parent = stage })
	stageTap.Activated:Connect(function()
		ctx.actions.openLife()
	end)
	self.leftName = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 240),
		Size = UDim2.new(1, 0, 0, 30),
		Text = "",
		FontFace = F.display,
		TextSize = 27,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = left,
	})
	self.leftSub = Kit.caps({ Position = UDim2.fromOffset(0, 272), Size = UDim2.new(1, -110, 0, 16), TextSize = 13, TextColor3 = C.sub, TextTruncate = Enum.TextTruncate.AtEnd, Parent = left })
	self.leftWork = Kit.caps({ Position = UDim2.fromOffset(0, 290), Size = UDim2.new(1, -110, 0, 16), TextSize = 12, TextColor3 = C.accent, TextTruncate = Enum.TextTruncate.AtEnd, Parent = left })
	-- your nature: the stat you lean on
	self.leftNature = new("TextLabel", {
		Name = "Nature",
		BackgroundColor3 = C.accentHi,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 324),
		Size = UDim2.new(0, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "",
		FontFace = F.display,
		TextSize = 13,
		TextColor3 = C.accentHi,
		Visible = false,
		Parent = left,
	}, { Kit.corner(3), Kit.padding(0, 8, 0, 8) })
	Tip.attach(self.leftNature, function()
		return (self.life and self.life.nature and self.life.nature.name) or "Your nature"
	end, function()
		return (self.life and self.life.nature and self.life.nature.desc) or nil
	end)
	self.leftPlace = Kit.caps({ Position = UDim2.fromOffset(0, 308), Size = UDim2.new(1, 0, 0, 14), TextSize = 11, TextColor3 = C.faint, TextTruncate = Enum.TextTruncate.AtEnd, Parent = left })
	self.leftMoney = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 270),
		Size = UDim2.new(0, 110, 0, 22),
		Text = "",
		FontFace = F.mono,
		TextSize = 20,
		TextColor3 = C.money,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = left,
	})
	Kit.caps({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 292),
		Size = UDim2.new(0, 110, 0, 12),
		Text = self.info.meta.currency,
		TextSize = 10,
		TextColor3 = C.faint,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = left,
	})
	-- what's on file: injuries, what you are, what you carry, the state of the City
	self.leftChips = new("Frame", {
		Name = "ChipSlot",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 352),
		Size = UDim2.new(1, 0, 1, -352 - (self.statCount * 32 + 50) - 10),
		ClipsDescendants = true,
		Parent = left,
	})
end

function Hud:show(visible: boolean)
	self.root.Visible = visible
end

-- the crew's age-up ready check (crew.age from the server), or nil
function Hud:setCrewAge(age)
	self.crewAge = age
	self:refreshButtons()
end

function Hud:setBusy(busy: boolean)
	self.busy = busy
	self:refreshButtons()
end

function Hud:refreshButtons()
	local life = self.life
	local pending = life and life.pending ~= nil
	local alive = life and life.alive
	local canAct = alive and not pending and not self.busy
	-- with a card waiting, the button says DECIDE and brings the card back
	self.setAgeEnabled(canAct == true or (alive == true and pending and not self.busy))
	self.setActivitiesEnabled(canAct == true)
	self.setMenuEnabled(not self.busy)
	local crewAge = self.crewAge
	if pending then
		self.ageLabel.Text = "DECIDE"
	elseif life and crewAge and crewAge.youReady then
		-- waiting on the crew: press again to take it back
		self.ageLabel.Text = string.format('READY %d/%d\n<font size="11" face="RobotoMono">WAITING FOR YOUR CREW</font>', crewAge.ready or 0, crewAge.total or 0)
	elseif life and crewAge then
		self.ageLabel.Text = string.format('+1 YEAR\n<font size="11" face="RobotoMono">CREW READY %d/%d</font>', crewAge.ready or 0, crewAge.total or 0)
	elseif life then
		self.ageLabel.Text = '+1 YEAR\n<font size="11" face="RobotoMono">TURN ' .. (life.age + 1) .. "</font>"
	else
		self.ageLabel.Text = "+1 YEAR"
	end
end

function Hud:setLife(life)
	local previous = self.life
	self.life = life
	local info = self.info
	local word = (info.city and info.city.word) or "Ward"
	self.fileLabel.Text = string.format("FILE %04d", life.fileNo or 0)
	-- "District 16 · Backstreets" (a District whose name is just its number isn't said twice)
	local lead = string.format("%s %d", word, life.district.number)
	local parts = { lead }
	local dname = life.district.name or ""
	if dname ~= "" and string.lower(dname) ~= string.lower(lead) then
		table.insert(parts, dname)
	end
	table.insert(parts, life.side.short)
	self.placeLabel.Text = string.upper(table.concat(parts, " · "))
	self.nameLabel.Text = string.upper(life.first .. " " .. life.last)
	local work = if life.career then (life.career.rank .. ", " .. life.career.name) else "No work"
	self.subLabel.Text = string.upper(string.format("Age %d  ·  Year %d  ·  %s", life.age, life.year, work))
	self.moneyLabel.Text = Format.number(life.money)
	self.moneyLabel.TextColor3 = if life.money < 0 then C.bad else C.money
	if self.left then
		self.leftFile.Text = self.fileLabel.Text
		self.leftName.Text = self.nameLabel.Text
		self.leftSub.Text = string.upper(string.format("Age %d  ·  Year %d", life.age, life.year))
		self.leftWork.Text = string.upper(work)
		self.leftPlace.Text = self.placeLabel.Text
		self.leftMoney.Text = self.moneyLabel.Text
		self.leftMoney.TextColor3 = self.moneyLabel.TextColor3
		self.leftDifficulty.Text = if life.difficulty then string.upper(life.difficulty.name) else ""
		if self.leftNature then
			local nature = life.nature
			self.leftNature.Visible = nature ~= nil
			if nature then
				local sdef = info.stats.defs[nature.stat]
				local color = if sdef and sdef.color then Theme.rgb(sdef.color) else C.accentHi
				self.leftNature.Text = string.upper(nature.name)
				self.leftNature.TextColor3 = color
				self.leftNature.BackgroundColor3 = color
				self.stageGlow.BackgroundColor3 = color
			else
				self.stageGlow.BackgroundColor3 = C.accent
			end
		end
		self.figure:set(life.appearance)
	end

	for _, chip in self.chips:GetChildren() do
		if chip:IsA("GuiObject") then
			chip:Destroy()
		end
	end
	-- every chip says what it is when you hover it (or tap it on a phone)
	local order = 0
	local function chip(text: string, color: Color3, title: string, body: string?)
		order += 1
		local c = Kit.chip(text, color, order)
		c.Parent = self.chips
		Tip.attach(c, title, body)
	end
	for _, c in life.conditions or {} do
		local left = if (c.years or 0) > 0 then string.format("%d more year%s.", c.years, if c.years == 1 then "" else "s") else ""
		chip(c.name .. " · " .. c.years .. "y", if c.good then C.good else C.crimsonHi, c.name, ((c.desc or "") .. " " .. left))
	end
	if life.form and life.form.id ~= "human" then
		chip(life.form.name, C.strange, life.form.name, life.form.desc or "What you've become.")
	end
	for _, g in life.gear or {} do
		chip(g.name, C.accent, g.name, ((g.desc or "") .. (if g.effect then "  " .. g.effect else "")))
	end
	for _, w in life.world do
		chip(w.label, C.sub, w.name or "The City", w.label)
	end
	-- (v0.12) what kind of year it is: a hard one, or one with a mood of its own
	if life.crisis then
		chip(life.crisis.name, if life.crisis.color then Theme.rgb(life.crisis.color) else C.crimsonHi, life.crisis.name, (life.crisis.text or "") .. " All year: every fight is harder, and bad luck comes more often.")
	elseif life.mood then
		chip(life.mood.name, if life.mood.color then Theme.rgb(life.mood.color) else C.accentHi, life.mood.name, life.mood.text)
	end
	if order == 0 then
		Kit.chip("No marks on file", C.faint, 1).Parent = self.chips
	end

	local vitalKey = info.stats and info.stats.vital
	for key, bar in self.statBars do
		-- (v0.13) a stat whose limit is past 100 shows it ("104/115"), and its bar fills to it
		local cap = life.caps and life.caps[key]
		local isVital = key == vitalKey or key == "health"
		bar.set(life.stats[key] or 0, if isVital and life.maxHealth then life.maxHealth elseif cap and cap > 100 then cap else nil, not isVital)
	end

	local s = life.sanity
	local range = math.max(1, info.stats.sanity.max - info.stats.sanity.min)
	local w = math.abs(s) / range
	if s >= 0 then
		Kit.tween(self.sanityFill, 0.3, { Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(w, 0, 1, 0) })
		self.sanityFill.BackgroundColor3 = C.strange
	else
		Kit.tween(self.sanityFill, 0.3, { Position = UDim2.new(0.5 - w, 0, 0, 0), Size = UDim2.new(w, 0, 1, 0) })
		self.sanityFill.BackgroundColor3 = C.crimsonHi
	end
	self.sanityLabel.Text = "SANITY  " .. Format.color(Format.signed(s), if s >= 0 then C.strange else C.crimsonHi)
	local heads = math.clamp(50 + s, 5, 95)
	self.headsLabel.Text = "HEADS " .. heads .. "%"

	-- the story strip: "YOUR STORY  Collateral · The loan comes due when you turn sixteen."
	local story = life.story
	self:setStory(story)
	local showStory = story ~= nil and story.name ~= nil
	if self.storyStrip.Visible ~= showStory then
		self.storyStrip.Visible = showStory
		self:layout()
	end

	self.actionsBadge.Text = tostring(life.actionsLeft)
	self.actionsBadge.Visible = life.actionsLeft > 0
	self:setCounters(life)
	self:refreshButtons()
	self.portrait:set(life.appearance)
	self:setCompanions(life.relations or {})
	-- the file card's bracket color (a cosmetic)
	local frameId = life.appearance and life.appearance.look and life.appearance.look.frame
	if frameId ~= self.frameId then
		self.frameId = frameId
		local color = C.accent
		local cos = self.info.avatar and self.info.avatar.cosmetics
		for _, o in (cos and cos.frame and cos.frame.options) or {} do
			if o.id == frameId and o.color then
				color = Color3.fromRGB(o.color[1], o.color[2], o.color[3])
			end
		end
		local brackets = self.header:FindFirstChild("Brackets", true)
		for _, f in (brackets and brackets:GetChildren()) or {} do
			if f:IsA("Frame") then
				f.BackgroundColor3 = color
			end
		end
	end
	local goals = self.navButtons and self.navButtons.goals
	if goals then
		local n = #(life.ambitions or {})
		goals.Text = if n > 0 then "GOALS " .. n else "GOALS"
	end

	-- feedback for the same life (not when a new one starts)
	if previous and previous.id == life.id then
		for key, bar in self.statBars do
			popup(bar.anchor, (life.stats[key] or 0) - (previous.stats[key] or 0))
		end
		popup(self.headsLabel, life.sanity - previous.sanity, C.strange, C.crimsonHi)
		popup(self.moneyLabel, life.money - previous.money, C.money, C.bad)
		local fx = self.ctx.fx
		if fx then
			local vital = (self.info.stats and self.info.stats.vital) or "fortitude"
			local hurt = (previous.stats[vital] or 0) - (life.stats[vital] or 0)
			if hurt >= 5 then
				fx.flash(C.crimson, math.clamp(hurt / 30, 0.15, 0.45))
				Kit.shake(self.root, math.clamp(hurt // 2, 3, 10), 0.25)
			end
			local shaken = previous.sanity - life.sanity
			if shaken >= 4 or (life.sanity <= -25 and shaken > 0) then
				fx.static(math.clamp(shaken / 12, 0.3, 1))
			end
		end
	end
end

-- Stacks the optional strips (companions, world event) above the log.
-- On a wide screen the side panels carry the tabs (and the hub has the activities), so the
-- nav row goes and the year button grows.
function Hud:setWide(wide: boolean, leftW: number?)
	self.wide = wide
	-- three panels: the left one takes the figure, the stats and the chips
	local full = wide and leftW ~= nil
	self.full = full
	if self.left then
		self.left.Visible = full
		self.header.Visible = not full
		local stats, grid = self.statsPanel, self.statGridLayout
		local chipList = self.chips:FindFirstChildOfClass("UIListLayout")
		if full then
			self.left.Size = UDim2.new(0, leftW :: number, 1, 0)
			stats.Parent = self.left
			stats.Position = UDim2.new(0, 0, 1, 0)
			stats.Size = UDim2.new(1, 0, 0, self.statCount * 32 + 50)
			grid.CellSize = UDim2.new(1, 0, 0, 26)
			grid.CellPadding = UDim2.new(0, 0, 0, 6)
			self.statGrid.Size = UDim2.new(1, 0, 0, self.statCount * 32 - 6)
			self.sanityRow.Position = UDim2.new(0, 0, 0, self.statCount * 32 + 2)
			-- the chips wrap instead of scrolling sideways
			self.chips.Parent = self.leftChips
			self.chips.Position = UDim2.fromOffset(0, 0)
			self.chips.Size = UDim2.fromScale(1, 1)
			self.chips.AutomaticCanvasSize = Enum.AutomaticSize.Y
			self.chips.ScrollingDirection = Enum.ScrollingDirection.Y
			if chipList then
				chipList.Wraps = true
			end
		else
			local rows = math.ceil(self.statCount / 2)
			stats.Parent = self.root
			stats.Position = UDim2.new(0, 0, 1, -114)
			stats.Size = UDim2.new(1, 0, 0, self.statsH)
			grid.CellSize = UDim2.new(0.5, -8, 0, 26)
			grid.CellPadding = UDim2.new(0, 16, 0, 6)
			self.statGrid.Size = UDim2.new(1, 0, 0, rows * 32 - 6)
			self.sanityRow.Position = UDim2.new(0, 0, 0, rows * 32 + 2)
			self.chips.Parent = self.header
			self.chips.Position = UDim2.new(0, 0, 1, -24)
			self.chips.Size = UDim2.new(1, 0, 0, 24)
			self.chips.AutomaticCanvasSize = Enum.AutomaticSize.X
			self.chips.ScrollingDirection = Enum.ScrollingDirection.X
			if chipList then
				chipList.Wraps = false
			end
		end
	end
	if self.nav then
		self.nav.Visible = not wide
	end
	if self.activitiesButton then
		self.activitiesButton.Visible = not wide
	end
	local age, life = self.ageButton, self.lifeButton
	if age and life then
		if wide then
			life.AnchorPoint = Vector2.new(0, 0.5)
			life.Position = UDim2.new(0, 0, 0.5, 0)
			life.Size = UDim2.new(0.3, -6, 0, 56)
			age.AnchorPoint = Vector2.new(1, 0.5)
			age.Position = UDim2.new(1, 0, 0.5, 0)
			age.Size = UDim2.new(0.7, -6, 0, 66)
		else
			life.AnchorPoint = Vector2.new(1, 0.5)
			life.Position = UDim2.new(1, 0, 0.5, 0)
			life.Size = UDim2.new(0.3, -6, 0, 56)
			age.AnchorPoint = Vector2.new(0.5, 0.5)
			age.Position = UDim2.new(0.5, 0, 0.5, 0)
			age.Size = UDim2.new(0.4, -4, 0, 66)
		end
	end
	self:layout()
end

function Hud:layout()
	local top = if self.full then 0 elseif self.wide then 120 else 162
	if self.storyStrip and self.storyStrip.Visible then
		self.storyStrip.Position = UDim2.new(0, 0, 0, top)
		top += 64
	end
	if self.companions and self.companions.Visible then
		self.companions.Position = UDim2.new(0, 0, 0, top)
		top += 52
	end
	if self.worldStrip and self.worldStrip.Visible then
		self.worldStrip.Position = UDim2.new(0, 0, 0, top)
		top += 46
	end
	self.logPanel.Position = UDim2.new(0, 0, 0, top)
	-- under the log: the stats (unless they're in the left panel), this year's counters and
	-- the action bar
	self.logPanel.Size = UDim2.new(1, 0, 1, -top - (if self.full then 118 else self.statsH + 122))
	if self.statsPanel and not self.full then
		self.statsPanel.Position = UDim2.new(0, 0, 1, -114)
	end
end

function Hud:setMusicLabel(on: boolean)
	local b = self.navButtons and self.navButtons.music
	if b then
		b.Text = if on then "MUSIC" else "MUTED"
		b.TextColor3 = if on then C.sub else C.faint
	end
end

-- Linked friends (other players) shown in a strip under the file card.
function Hud:setCompanions(relations)
	local friends = {}
	for _, rel in relations do
		if rel.linked and rel.alive then
			table.insert(friends, rel)
		end
	end
	local show = #friends > 0
	self.companions.Visible = show
	self:layout()
	local key = {}
	for _, rel in friends do
		table.insert(key, tostring(rel.userId) .. (if rel.online then "+" else "-") .. rel.name .. Format.number(rel.age))
	end
	local sig = table.concat(key, ";")
	if sig == self.companionSig then
		-- same people: only refresh how they look
		for _, rel in friends do
			local view = self.companionViews[rel.userId or 0]
			if view then
				view:set(rel.appearance)
			end
		end
		return
	end
	self.companionSig = sig
	for _, child in self.companionList:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	self.companionViews = {}
	for i, rel in friends do
		local chip = new("TextButton", {
			Name = "Companion",
			AutoButtonColor = false,
			BackgroundColor3 = C.panelLo,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 0, 34),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "",
			LayoutOrder = i,
			Parent = self.companionList,
		}, {
			Kit.corner(2),
			Kit.stroke(if rel.online then C.strange else C.stroke, 1, 0.4),
			Kit.padding(0, 10, 0, 2),
			Kit.list(6, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center),
		})
		local view = AvatarView.new(self.ctx, { size = UDim2.fromOffset(30, 30), framing = "portrait", order = 1 })
		view.frame.Parent = chip
		view:set(rel.appearance)
		self.companionViews[rel.userId or 0] = view
		local first = string.match(rel.name, "^(%S+)") or rel.name
		new("TextLabel", {
			BackgroundTransparency = 1,
			Text = string.upper(Format.escape(first)) .. "  " .. (if rel.online then Format.color(Format.number(rel.age), C.sub) else Format.color("AWAY", C.faint)),
			RichText = true,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 16),
			FontFace = F.displayMed,
			TextSize = 13,
			TextColor3 = if rel.online then C.text else C.faint,
			LayoutOrder = 2,
			Parent = chip,
		})
		chip.Activated:Connect(function()
			self.ctx.actions.openLife("Friends")
		end)
	end
end

-- ── the report ──────────────────────────────────────────────────────────────

function Hud:clearLog()
	for _, item in self.items do
		item:Destroy()
	end
	self.items = {}
	self.card = nil
	self.yearCards = {}
end

function Hud:nextOrder()
	self.order += 1
	return self.order
end

local function fadeIn(inst: Instance)
	for _, d in inst:GetDescendants() do
		if d:IsA("TextLabel") then
			local target = d.TextTransparency
			d.TextTransparency = 1
			Kit.tween(d, 0.35, { TextTransparency = target })
		end
	end
end

-- an entry with a colored rule down its left edge: the frame's own background,
-- cut to a sliver by a hard-edged gradient, so it always spans the entry's height
local RULE = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.005, 0),
	NumberSequenceKeypoint.new(0.006, 1),
	NumberSequenceKeypoint.new(1, 1),
})
local function ruled(color: Color3)
	return new("Frame", {
		BackgroundColor3 = color,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		new("UIGradient", { Transparency = RULE }),
		Kit.padding(1, 0, 1, 12),
		Kit.list(3),
	})
end

function Hud:entryView(entry)
	local info = self.info
	local kind = entry.kind
	if kind == "year" then
		local frame = new("Frame", {
			BackgroundColor3 = C.panelHi,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 24),
		}, { Kit.padding(0, 10, 0, 10) })
		new("Frame", { BackgroundColor3 = C.crimson, BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, 0), Position = UDim2.new(0, -10, 0, 0), Parent = frame })
		Kit.caps({ Text = entry.text, Size = UDim2.fromScale(0.5, 1), FontFace = F.display, TextSize = 14, TextColor3 = C.accentHi, Parent = frame })
		if entry.year then
			Kit.caps({
				Text = "Year " .. entry.year,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.fromScale(0.5, 1),
				TextSize = 12,
				TextColor3 = C.faint,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = frame,
			})
		end
		return frame
	end

	if kind == "friend" then
		-- news from a linked friend's life
		local frame = ruled(C.strange)
		Kit.text({
			Text = Format.color(string.upper(Format.escape(entry.name or "A friend")), C.strange) .. "   " .. Format.escape(entry.text or ""),
			FontFace = F.uiMedium,
			TextSize = 13,
			TextColor3 = C.sub,
			LayoutOrder = 1,
			Parent = frame,
		})
		return frame
	end

	-- a hard year begins: a red band across the report, the crisis named and what it means
	if kind == "crisis" then
		local color = if entry.color then Theme.rgb(entry.color) else C.crimsonHi
		local frame = new("Frame", { Name = "Crisis", BackgroundColor3 = color:Lerp(Color3.new(0, 0, 0), 0.72), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, { Kit.corner(3), Kit.padding(9, 12, 10, 14), Kit.list(3) })
		Kit.stroke(color, 1, 0.1).Parent = frame
		Kit.edge(frame, color, 4)
		Kit.caps({ Text = "A hard year", FontFace = F.display, TextSize = 12, TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.3), LayoutOrder = 1, Parent = frame })
		Kit.text({ Text = string.upper(Format.escape(entry.title or "")), FontFace = F.display, TextSize = 19, TextColor3 = C.text, LayoutOrder = 2, Parent = frame })
		if entry.text and entry.text ~= "" then
			Kit.text({ Text = Format.escape(entry.text), FontFace = F.serif, TextSize = 13.5, TextColor3 = C.sub, LayoutOrder = 3, Parent = frame })
		end
		Kit.text({ Text = "All year: every fight is harder, and bad luck comes more often. Get through it and it's yours to tell.", FontFace = F.uiMedium, TextSize = 12, TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.2), LayoutOrder = 4, Parent = frame })
		return frame
	end

	-- a Canto or an Intervallo begins: a title line across the report
	if kind == "chapter" or kind == "intervallo" then
		local gold = kind == "intervallo"
		local color = if gold then Color3.fromRGB(226, 190, 112) else C.crimsonHi
		local frame = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, { Kit.list(2), Kit.padding(6, 0, 4, 0) })
		Kit.caps({ Text = string.upper(entry.word or "") .. " " .. tostring(entry.num or ""), FontFace = F.display, TextSize = 12, TextColor3 = color, LayoutOrder = 1, Parent = frame })
		Kit.text({ Text = if gold then Format.escape(entry.title or "") else string.upper(Format.escape(entry.title or "")), FontFace = if gold then F.serifItalic else F.display, TextSize = 19, TextColor3 = C.text, LayoutOrder = 2, Parent = frame })
		new("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), LayoutOrder = 3, Parent = frame })
		if entry.text and entry.text ~= "" then
			Kit.text({ Text = Format.escape(entry.text), FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 4, Parent = frame })
		end
		return frame
	end

	-- the main story: its start, and how it ended
	if kind == "story" or kind == "storyEnd" then
		local tone = Theme.tone(entry.tone)
		local frame = ruled(tone)
		Kit.caps({ Text = if kind == "story" then "Your story" else "Your story ends", FontFace = F.display, TextSize = 12, TextColor3 = tone, LayoutOrder = 1, Parent = frame })
		Kit.text({ Text = string.upper(Format.escape(entry.title or "")), FontFace = F.display, TextSize = 18, TextColor3 = C.text, LayoutOrder = 2, Parent = frame })
		if entry.text and entry.text ~= "" then
			Kit.text({ Text = Format.escape(entry.text), FontFace = F.serif, TextSize = 13.5, TextColor3 = C.sub, LayoutOrder = 3, Parent = frame })
		end
		return frame
	end

	-- something about the City you now know (a faction, the Night...)
	if kind == "learned" then
		local frame = new("Frame", { BackgroundColor3 = C.panelHi, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, { Kit.corner(2), Kit.padding(7, 10, 8, 44), Kit.list(2) })
		Kit.stroke(C.accentLo, 1, 0.3).Parent = frame
		local icon = Emblem.make(entry.emblem or "tab.lore", 24)
		icon.Position = UDim2.fromOffset(-34, 2)
		icon.Parent = new("Folder", { Parent = frame })
		Kit.caps({ Text = "You now know of", FontFace = F.displayMed, TextSize = 11, TextColor3 = C.accentHi, LayoutOrder = 1, Parent = frame })
		Kit.text({ Text = string.upper(Format.escape(entry.title or "")), FontFace = F.display, TextSize = 15, TextColor3 = C.text, LayoutOrder = 2, Parent = frame })
		if entry.text and entry.text ~= "" then
			Kit.text({ Text = Format.escape(entry.text), FontFace = F.serif, TextSize = 12.5, TextColor3 = C.sub, LayoutOrder = 3, Parent = frame })
		end
		return frame
	end

	-- a way of fighting, and who it belongs to
	if kind == "school" then
		local color = if entry.color then Theme.rgb(entry.color) else C.accentHi
		local frame = new("Frame", { BackgroundColor3 = C.panelHi, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, { Kit.corner(2), Kit.padding(7, 10, 8, 14), Kit.list(2) })
		Kit.stroke(color, 1, 0.3).Parent = frame
		Kit.caps({ Text = "You were taught", FontFace = F.displayMed, TextSize = 11, TextColor3 = color, LayoutOrder = 1, Parent = frame })
		Kit.text({
			Text = string.upper(Format.escape(entry.title or "")) .. (if entry.style then "   " .. Format.color(string.upper(Format.escape(entry.style)), color) else ""),
			FontFace = F.display,
			TextSize = 15,
			TextColor3 = C.text,
			LayoutOrder = 2,
			Parent = frame,
		})
		if entry.text and entry.text ~= "" then
			Kit.text({ Text = Format.escape(entry.text), FontFace = F.serif, TextSize = 12.5, TextColor3 = C.sub, LayoutOrder = 3, Parent = frame })
		end
		if entry.org then
			Kit.text({ Text = "It belongs to " .. Format.escape(entry.org) .. ". The rest of it is taught inside.", FontFace = F.ui, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 4, Parent = frame })
		end
		return frame
	end

	-- who you've become (the look back at 18)
	if kind == "recap" then
		local frame = ruled(C.accentHi)
		Kit.caps({ Text = string.upper(Format.escape(entry.title or "")), FontFace = F.display, TextSize = 15, TextColor3 = C.accentHi, LayoutOrder = 1, Parent = frame })
		for i, line in entry.lines or {} do
			Kit.text({ Text = "·  " .. Format.escape(line), FontFace = F.serif, TextSize = 13, TextColor3 = C.text, LayoutOrder = 1 + i, Parent = frame })
		end
		return frame
	end

	-- somebody said something
	if kind == "dialogue" then
		local nameColor = if entry.speaker == "you" then C.good elseif entry.speaker == "foe" then C.crimsonHi else C.accentHi
		local frame = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, { Kit.padding(0, 0, 0, 10) })
		Kit.text({
			Text = Format.color(string.upper(Format.escape(entry.who or "")), nameColor) .. "   <i>" .. Format.escape(entry.text or "") .. "</i>",
			FontFace = F.serif,
			TextSize = 13.5,
			TextColor3 = C.text,
			Parent = frame,
		})
		return frame
	end

	if kind == "event" then
		local frame = ruled(if entry.hazard then C.crimson elseif entry.story then C.crimsonHi else C.accent)
		if entry.story then
			Kit.caps({ Text = "Your story", FontFace = F.display, TextSize = 11, TextColor3 = C.crimsonHi, LayoutOrder = 0, Parent = frame })
		end
		Kit.text({
			Text = Format.escape(entry.title),
			FontFace = F.title,
			TextSize = 15,
			TextColor3 = if entry.hazard then C.crimsonHi else C.text,
			LayoutOrder = 1,
			Parent = frame,
		})
		if entry.text and entry.text ~= "" then
			Kit.text({ Text = Format.escape(entry.text), FontFace = F.serif, TextSize = 13.5, TextColor3 = C.sub, LayoutOrder = 2, Parent = frame })
		end
		if entry.choice then
			Kit.text({
				Text = "&gt; " .. string.upper(Format.escape(entry.choice)),
				FontFace = F.displayMed,
				TextSize = 13,
				TextColor3 = C.accent,
				LayoutOrder = 3,
				Parent = frame,
			})
		end
		return frame
	end

	local color = C.text
	local font = F.serif
	local size = 14.5
	local rule = nil
	local text = entry.text and Format.escape(entry.text) or ""
	if kind == "summary" then
		color = C.faint
		font = F.ui
		size = 12.5
	elseif kind == "world" then
		color = C.strange
		font = F.displayMed
		size = 13
		text = string.upper(text)
		rule = C.strange
	elseif kind == "clash" then
		color = if entry.won then C.good else C.crimsonHi
		font = F.display
		size = 13
		text = string.upper(text)
		rule = color
	elseif kind == "death" then
		color = C.crimsonHi
		font = F.display
		size = 17
		text = string.upper(text)
		rule = C.crimson
	elseif kind == "system" then
		font = F.displayMed
		size = 13.5
		color = if entry.tone == "good" then C.good elseif entry.tone == "bad" then C.crimsonHi elseif entry.tone == "strange" then C.strange else C.accentHi
		text = string.upper(text)
	elseif kind == "rep" then
		-- a faction's regard for you just moved
		color = if (entry.delta or 0) >= 0 then C.good else C.crimsonHi
		font = F.displayMed
		size = 13
		text = string.upper(text)
		rule = color
	end

	local frame = if rule
		then ruled(rule)
		else new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, { Kit.list(3) })
	if text ~= "" then
		Kit.text({ Text = text, FontFace = font, TextSize = size, TextColor3 = color, LayoutOrder = 1, Parent = frame })
	end
	if entry.deltas then
		Kit.text({ Text = Format.deltas(entry.deltas, info), FontFace = F.displayMed, TextSize = 12.5, LayoutOrder = 2, Parent = frame })
	end
	return frame
end

function Hud:addEntry(entry, animate: boolean?)
	-- THE FEED (UI/Feed): a scene, something you did, or a year turning is a card; what followed
	-- from it lands on that card as chips and notes
	local kind = entry.kind
	if kind == "cutscene" then
		return -- played full-screen (UI/Cutscene), not listed
	end
	if Feed.ATTACH[kind] and self.card and self.card.frame.Parent then
		self.card:add(entry)
		return
	end
	local view
	self.yearCards = self.yearCards or {}
	if kind == "event" then
		local thread = entry.thread or (if entry.story then "story" elseif entry.hazard then "danger" else "you")
		self.card = Feed.card(self.info, { title = entry.title, thread = thread, choice = entry.choice, hazard = entry.hazard })
		view = self.card.frame
		table.insert(self.yearCards, self.card)
	elseif kind == "year" then
		-- a new year: last year's cards fold down to their titles and what they gave
		for _, card in self.yearCards do
			if card.frame.Parent then
				card:fold(true)
			end
		end
		self.yearCards = {}
		self.card = Feed.year(self.info, entry)
		view = self.card.frame
	else
		view = self:entryView(entry)
	end
	view.LayoutOrder = self:nextOrder()
	view.Parent = self.scroll
	table.insert(self.items, view)
	while #self.items > MAX_LOG_ITEMS do
		table.remove(self.items, 1):Destroy()
	end
	if animate then
		fadeIn(view)
	end
end

function Hud:scrollToEnd(smooth: boolean?)
	task.defer(function()
		RunService.Heartbeat:Wait()
		local maxY = math.max(0, self.scroll.AbsoluteCanvasSize.Y - self.scroll.AbsoluteWindowSize.Y)
		if smooth then
			Kit.tween(self.scroll, 0.3, { CanvasPosition = Vector2.new(0, maxY) })
		else
			self.scroll.CanvasPosition = Vector2.new(0, maxY)
		end
	end)
end

function Hud:resetLog(entries)
	self:clearLog()
	for _, e in entries do
		self:addEntry(e, false)
	end
	self:scrollToEnd(false)
end

function Hud:appendEntries(entries)
	for _, e in entries do
		self:addEntry(e, true)
	end
	self:scrollToEnd(true)
end

return Hud
