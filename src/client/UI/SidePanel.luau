--[[
	The side panels: the archive (lore), the City (today, the world, this server) and you.
	On a wide screen they sit left and right of the life column and stay open. On a phone
	they become one drawer that slides in over the column.

		local side = SidePanel.build(ctx, gui)    -- gui: its own ScreenGui
		side:open("lore" | "city" | "you")        -- opens the drawer, or flashes the panel
		side:setLife(view)   side:setMeta(meta)   side:setDaily(info)   side:setWorld(world)
		side:setChronicle(list)   side:addChronicle(entry)   side:setSurnames(state)
		side.wide                                 -- true while the panels are docked
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Layout = require(script.Parent.Layout)
local AvatarView = require(script.Parent.AvatarView)
local Sheets = require(script.Parent.Sheets)
local Emblem = require(script.Parent.Emblem)
local Tip = require(script.Parent.Tip)
local DoTab = require(script.Parent.DoTab)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local SidePanel = {}
SidePanel.__index = SidePanel

local function clear(frame: Instance)
	for _, child in frame:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function ago(at: number?): string
	if not at then
		return ""
	end
	local s = math.max(0, os.time() - at)
	if s < 60 then
		return "just now"
	elseif s < 3600 then
		return math.floor(s / 60) .. "m ago"
	end
	return math.floor(s / 3600) .. "h ago"
end

-- a scrolling body that grows with its content
local function scroller(parent: Instance, position: UDim2, size: UDim2)
	return new("ScrollingFrame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = position,
		Size = size,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.stroke,
		ZIndex = 2,
		Parent = parent,
	}, { Kit.padding(2, 12, 16, 12), Kit.list(8) })
end

local function heading(parent: Instance, text: string, order: number, color: Color3?)
	return Kit.caps({
		Text = text,
		FontFace = F.display,
		TextSize = 12,
		TextColor3 = color or C.crimsonHi,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	})
end

local function card(parent: Instance, order: number, accent: Color3?)
	local f = Kit.panel({
		BackgroundColor3 = C.panelLo,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, nil, accent)
	Kit.padding(10, 12, 10, 12).Parent = f
	Kit.list(5).Parent = f
	return f
end

function SidePanel.build(ctx, gui: ScreenGui)
	local self = setmetatable({}, SidePanel)
	self.ctx = ctx
	self.gui = gui
	self.life = nil
	self.meta = nil
	self.daily = nil
	self.world = nil
	self.chronicle = {}
	self.surnames = nil
	self.expanded = {} -- lore categories opened
	self.tab = { left = "you", right = "activities", drawer = "story" }
	self.wide = false
	self.root = new("Frame", {
		Name = "Side",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = gui,
	})
	self.scale = new("UIScale", { Parent = self.root })
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:layout()
	end)
	Layout.changed:Connect(function()
		self:layout()
	end)
	self:layout()
	return self
end

-- ── layout: docked panels or a drawer ─────────────────────────────────────────

function SidePanel:layout()
	local abs = self.gui.AbsoluteSize
	if abs.X <= 0 or abs.Y <= 0 then
		return
	end
	local s = Layout.scaleFor(abs)
	self.scale.Scale = s
	local w, h = abs.X / s, abs.Y / s
	self.root.Size = UDim2.fromOffset(w, h)
	-- a wide screen is filled edge to edge by three panels; a middling one gets the life
	-- column and a hub; a phone gets a drawer
	local panels = Layout.panels(w)
	local sideW = if panels then panels.hub else Layout.hubWidth(w)
	local wide = sideW > 0
	if wide == self.wide and self.built and self.sideW == sideW and self.h == h and (panels ~= nil) == (self.mainWidth ~= nil) then
		return
	end
	self.wide, self.sideW, self.h, self.w = wide, sideW, h, w
	self.built = true
	clear(self.root)
	self.drawer = nil
	self.mainWidth, self.leftWidth = nil, nil
	if panels then
		-- the life column becomes the middle panel; the HUD draws the left one beside it
		self.shift = panels.centerX + panels.center / 2 - w / 2
		self.mainWidth = panels.center
		self.leftWidth = panels.left
		self.left = nil
		self.right = self:makePanel("Right", UDim2.new(0, panels.hubX, 0, Layout.MARGIN), sideW, h - 2 * Layout.MARGIN, { "activities", "family", "story", "you", "city", "more" }, "right", true)
	elseif wide then
		-- everything in one hub on the right: what to do this year, today's City, Light, you, the
		-- archive. The life column steps left (self.shift) so the two sit centered.
		local half = Layout.COLUMN / 2
		self.shift = -(Layout.GAP + sideW) / 2
		self.left = nil
		self.right = self:makePanel("Right", UDim2.new(0.5, self.shift + half + Layout.GAP, 0, 8), sideW, h - 16, { "activities", "family", "story", "you", "city", "more" }, "right", true)
	else
		self.shift = 0
		self.left, self.right = nil, nil
		self:makeDrawer(math.min(420, w - 24), h)
	end
	self:render()
	if self.onWideChanged then
		self.onWideChanged(wide)
	end
end

-- The side panels belong to the life screen: hidden on the menu and in the creator.
function SidePanel:setVisible(on: boolean)
	self.root.Visible = on
end

-- SIX TABS, ONE ROW. Everything else (Light, the Archive, Goals, Crew, Rankings, the Store,
-- the Guidebook, the Menu) is one tap further, under MORE.
local TAB_NAMES = { lore = "Archive", city = "City", you = "You", activities = "Do", light = "Light", story = "Story", family = "People", more = "More" }
local TAB_ICONS = { activities = "tab.do", family = "tab.people", story = "tab.story", you = "tab.you", city = "tab.city", more = "tab.menu" }
local TAB_H, TAB_GAP = 48, 6
-- pages that live under MORE: the tab bar shows MORE lit while one of them is open
local UNDER_MORE = { light = true, lore = true }

-- the hub's shortcuts: each opens its sheet (emblem + a short word)
local HUB = {
	{ id = "goals", text = "Goals", action = "openGoals" },
	{ id = "crew", text = "Crew", action = "openCrew" },
	{ id = "ranks", text = "Ranks", action = "openRankings" },
	{ id = "store", text = "Store", action = "openStore" },
	{ id = "guide", text = "Guide", action = "openGuide" },
	{ id = "menu", text = "Menu", action = "openMenu" },
}

function SidePanel:makePanel(name: string, position: UDim2, width: number, height: number, tabs, slot: string, hub: boolean?)
	local panel = Kit.panel({
		Name = name,
		Position = position,
		Size = UDim2.fromOffset(width, height),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0, -- (solid: as a drawer on a phone it lies over the feed)
		ZIndex = 2,
		Parent = self.root,
	}, nil, C.accent)
	-- tabs: one row, an icon over a word
	local perRow = #tabs
	local barH = TAB_H
	local bar = new("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 0, barH),
		ZIndex = 2,
		Parent = panel,
	}, {
		new("UIGridLayout", {
			CellSize = UDim2.new(1 / perRow, -TAB_GAP, 0, TAB_H),
			CellPadding = UDim2.fromOffset(TAB_GAP, TAB_GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local buttons = {}
	for i, tab in tabs do
		local b: any = new("TextButton", {
			Name = "Tab_" .. tab,
			AutoButtonColor = false,
			BackgroundColor3 = C.panelLo,
			BorderSizePixel = 0,
			Text = "",
			LayoutOrder = i,
			ZIndex = 2,
			Parent = bar,
		}, { Kit.corner(4) })
		local icon = Emblem.make(TAB_ICONS[tab] or "tab.you", 20)
		icon.Name = "Icon"
		icon.AnchorPoint = Vector2.new(0.5, 0)
		icon.Position = UDim2.new(0.5, 0, 0, 6)
		icon.ZIndex = 3
		icon.Parent = b
		Kit.raise(icon, 3)
		new("TextLabel", {
			Name = "Word",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 1, -19),
			Size = UDim2.new(1, 0, 0, 16),
			Text = string.upper(TAB_NAMES[tab] or tab),
			FontFace = F.display,
			TextSize = 12,
			TextColor3 = C.sub,
			ZIndex = 3,
			Parent = b,
		})
		b.Activated:Connect(function()
			if self.ctx.sfx then
				self.ctx.sfx("tab")
			end
			self.tab[slot] = tab
			self:render()
		end)
		buttons[tab] = b
	end
	hub = false
	local hubH = if hub then 132 else 0
	local body = scroller(panel, UDim2.fromOffset(0, barH + 20), UDim2.new(1, 0, 1, -(barH + 22) - hubH))
	if hub then
		local row = new("Frame", {
			Name = "Hub",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 10, 1, -10),
			Size = UDim2.new(1, -20, 0, 114),
			ZIndex = 2,
			Parent = panel,
		}, {
			new("UIGridLayout", {
				CellSize = UDim2.new(1 / 3, -6, 0, 53),
				CellPadding = UDim2.fromOffset(8, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		new("Frame", { BackgroundColor3 = C.stroke, BorderSizePixel = 0, Position = UDim2.new(0, 10, 1, -132), Size = UDim2.new(1, -20, 0, 1), ZIndex = 2, Parent = panel })
		for i, item in HUB do
			local b = new("TextButton", {
				Name = "Hub_" .. item.id,
				AutoButtonColor = false,
				BackgroundColor3 = C.panelHi,
				BorderSizePixel = 0,
				Text = "",
				LayoutOrder = i,
				ZIndex = 2,
				Parent = row,
			}, { Kit.corner(2) })
			local stroke = Kit.stroke(C.stroke, 1, 0.3)
			stroke.Parent = b
			local icon = Emblem.make("tab." .. item.id, 28)
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Position = UDim2.new(0, 12, 0.5, 0)
			icon.ZIndex = 3
			icon.Parent = b
			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(48, 0),
				Size = UDim2.new(1, -52, 1, 0),
				Text = string.upper(item.text),
				FontFace = F.display,
				TextSize = 16,
				TextColor3 = C.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
				Parent = b,
			})
			b.MouseEnter:Connect(function()
				Kit.tween(stroke, 0.1, { Color = C.accentHi, Transparency = 0 })
			end)
			b.MouseLeave:Connect(function()
				Kit.tween(stroke, 0.1, { Color = C.stroke, Transparency = 0.3 })
			end)
			b.Activated:Connect(function()
				if self.ctx.sfx then
					self.ctx.sfx("tab")
				end
				local fn = self.ctx.actions[item.action]
				if fn then
					fn()
				end
			end)
		end
	end
	return { frame = panel, body = body, bar = bar, barH = barH, buttons = buttons, tabs = tabs, slot = slot }
end

function SidePanel:makeDrawer(width: number, height: number)
	local scrim = new("TextButton", {
		Name = "DrawerScrim",
		AutoButtonColor = false,
		BackgroundColor3 = C.shade,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Visible = false,
		ZIndex = 5,
		Parent = self.root,
	})
	local panel = self:makePanel("Drawer", UDim2.fromOffset(-width - 20, 8), width, height - 16, { "family", "story", "you", "city", "more" }, "drawer")
	panel.frame.ZIndex = 6
	Kit.raise(panel.frame, 6)
	local close = Kit.button({
		name = "CloseDrawer",
		text = "X",
		style = "ghost",
		size = UDim2.fromOffset(30, 30),
		position = UDim2.new(1, -10, 0, 10),
		anchor = Vector2.new(1, 0),
		textSize = 13,
		zIndex = 7,
		onClick = function()
			self:closeDrawer()
		end,
	})
	close.Parent = panel.frame
	-- the tab bar leaves room for the close button
	panel.bar.Size = UDim2.new(1, -60, 0, panel.barH)
	scrim.Activated:Connect(function()
		self:closeDrawer()
	end)
	panel.scrim = scrim
	panel.width = width
	self.drawer = panel
end

function SidePanel:closeDrawer()
	local d = self.drawer
	if not d or not d.isOpen then
		return
	end
	d.isOpen = false
	Kit.tween(d.frame, 0.22, { Position = UDim2.fromOffset(-d.width - 20, 8) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	Kit.tween(d.scrim, 0.2, { BackgroundTransparency = 1 })
	task.delay(0.22, function()
		if not d.isOpen then
			d.scrim.Visible = false
		end
	end)
end

-- Opens a tab: slides the drawer in on a phone, or flashes the docked panel on a wide screen.
function SidePanel:open(tab: string)
	if self.wide then
		local panel = self.right or self.left
		if panel then
			self.tab[panel.slot] = tab
			self:render()
			local stroke = panel.frame:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = C.accentHi
				Kit.tween(stroke, 0.8, { Color = C.stroke })
			end
		end
		return
	end
	local d = self.drawer
	if not d then
		return
	end
	self.tab.drawer = tab
	self:render()
	if d.isOpen then
		return
	end
	d.isOpen = true
	d.scrim.Visible = true
	Kit.tween(d.scrim, 0.25, { BackgroundTransparency = 0.45 })
	Kit.tween(d.frame, 0.3, { Position = UDim2.fromOffset(8, 8) }, Enum.EasingStyle.Quint)
end

-- ── data in ─────────────────────────────────────────────────────────────────

function SidePanel:setLife(view)
	self.life = view
	self:render("you", "city", "activities", "story", "family")
end
function SidePanel:setMeta(meta)
	self.meta = meta
	self:render("lore", "you", "light", "story")
end
function SidePanel:setDaily(info)
	self.daily = info
	self:render("city")
end
function SidePanel:setWorld(world)
	self.world = if world and not world.ended then world else nil
	self:render("city")
end
function SidePanel:setHolds(list)
	self.holds = list or {}
	self:render("city")
end
function SidePanel:setChronicle(list)
	self.chronicle = list or {}
	self:render("city")
end
function SidePanel:addChronicle(entry)
	table.insert(self.chronicle, 1, entry)
	while #self.chronicle > 12 do
		table.remove(self.chronicle)
	end
	self:render("city")
end
function SidePanel:setSurnames(state)
	self.surnames = state
	self:render("you")
end

-- ── drawing ─────────────────────────────────────────────────────────────────

-- Re-draws the panels showing any of the given tabs (all of them if none given).
function SidePanel:render(...)
	local only = { ... }
	local function wants(tab: string): boolean
		return #only == 0 or table.find(only, tab) ~= nil
	end
	for _, panel in { self.left, self.right, self.drawer } do
		if panel then
			local tab = if #panel.tabs == 1 then panel.tabs[1] else self.tab[panel.slot]
			-- (a page under MORE lights MORE)
			local lit = if UNDER_MORE[tab] then "more" else tab
			for t, b in panel.buttons do
				local on = t == lit
				b.BackgroundColor3 = if on then C.accent else C.panelLo
				local word = b:FindFirstChild("Word")
				if word then
					word.TextColor3 = if on then C.ink else C.sub
				end
			end
			if wants(tab) then
				clear(panel.body)
				if tab == "lore" then
					self:drawLore(panel.body)
				elseif tab == "city" then
					self:drawCity(panel.body)
				elseif tab == "activities" then
					self:drawActivities(panel.body)
				elseif tab == "light" then
					self:drawLight(panel.body)
				elseif tab == "story" then
					self:drawStory(panel.body)
				elseif tab == "family" then
					self:drawFamily(panel.body)
				elseif tab == "more" then
					self:drawMore(panel.body, panel.slot)
				else
					self:drawYou(panel.body)
				end
				if UNDER_MORE[tab] then
					-- a way back to MORE, above the page
					local back = new("TextButton", {
						Name = "BackToMore",
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 18),
						Text = "‹  MORE",
						FontFace = F.display,
						TextSize = 13,
						TextColor3 = C.accentHi,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = -100,
						ZIndex = 2,
						Parent = panel.body,
					})
					local slot = panel.slot
					back.Activated:Connect(function()
						self.tab[slot] = "more"
						self:render()
					end)
				end
				if panel.frame.ZIndex > 2 then
					Kit.raise(panel.body, panel.frame.ZIndex)
				end
			end
		end
	end
end

-- ── More: the rest of the game, as tiles ─────────────────────────────────────
local MORE = {
	{ id = "goals", name = "Goals", icon = "tab.goals", tip = "What this life is working toward, and what it earns.", action = "openGoals" },
	{ id = "crew", name = "Crew", icon = "tab.crew", tip = "Live alongside friends: start together, run expeditions, duel.", action = "openCrew" },
	{ id = "ranks", name = "Rankings", icon = "tab.ranks", tip = "The best lives on this server, and of all time.", action = "openRankings" },
	{ id = "light", name = "Light", icon = "tab.light", tip = "What you've earned across lives, and what it opens.", tab = "light" },
	{ id = "lore", name = "Archive", icon = "tab.lore", tip = "Everything this life has learned about the City.", tab = "lore" },
	{ id = "store", name = "Store", icon = "tab.store", tip = "Rolls, looks and passes.", action = "openStore" },
	{ id = "guide", name = "Guidebook", icon = "tab.guide", tip = "How everything works, a page at a time.", action = "openGuide" },
	{ id = "menu", name = "Menu", icon = "tab.menu", tip = "Sound, display, family name, help.", action = "openMenu" },
}

function SidePanel:drawMore(body: Instance, slot: string)
	heading(body, "More", 1, C.accentHi)
	local grid = new("Frame", {
		Name = "MoreTiles",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		ZIndex = 2,
		Parent = body,
	}, {
		new("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 58), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	for i, item in MORE do
		if item.id == "store" and not (self.ctx.info and self.ctx.info.storeOpen) then
			continue
		end
		DoTab.tile(grid, i, {
			id = "Hub_" .. item.id,
			name = item.name,
			icon = item.icon,
			tipBody = item.tip,
			onClick = function()
				if self.ctx.sfx then
					self.ctx.sfx("tab")
				end
				if item.tab then
					self.tab[slot] = item.tab
					self:render()
				else
					local fn = self.ctx.actions[item.action]
					if fn then
						fn()
					end
				end
			end,
		})
	end
end

-- ── Activities: the year's actions, right here on a wide screen ─────────────

function SidePanel:drawActivities(body: Instance)
	local ctx = self.ctx
	local life = self.life
	if not (life and life.alive) then
		heading(body, "Activities", 1, C.sub)
		Kit.text({ Text = "Start a life first.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = body })
		return
	end
	if life.pending then
		Kit.text({ Text = "There's a card waiting for your answer. The year goes on once you've decided.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 1, ZIndex = 2, Parent = body })
		local show = Kit.button({
			name = "ShowCard",
			text = "Show the card",
			style = "primary",
			size = UDim2.new(1, 0, 0, 36),
			order = 2,
			zIndex = 2,
			onClick = function()
				if ctx.actions.showDecision then
					ctx.actions.showDecision()
				end
			end,
		})
		show.Parent = body
		return
	end
	Sheets.activitiesContent(ctx, body, ctx.sheetLayer or self.gui, nil)
end

-- ── Light: what you've earned across lives, and what it opens ───────────────

function SidePanel:drawLight(body: Instance)
	local ctx = self.ctx
	local meta = self.meta or {}
	local glowName = (ctx.info and ctx.info.meta and ctx.info.meta.glowName) or "Light"
	local balance = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 1, ZIndex = 2, Parent = body })
	local icon = Emblem.make("cur.light", 32)
	icon.Position = UDim2.fromOffset(0, 6)
	icon.ZIndex = 2
	icon.Parent = balance
	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(42, 0),
		Size = UDim2.new(1, -42, 1, 0),
		Text = string.format("%d  <font size=\"14\">%s</font>", meta.glow or 0, string.upper(glowName)),
		RichText = true,
		FontFace = F.display,
		TextSize = 30,
		TextColor3 = Color3.fromRGB(255, 238, 204),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = balance,
	})
	Kit.text({
		Text = "Earned by finishing lives. Spend it on families for your birth roll, on modes, and on looks (in the creator).",
		FontFace = F.serif,
		TextSize = 12,
		TextColor3 = C.sub,
		LayoutOrder = 2,
		ZIndex = 2,
		Parent = body,
	})
	-- families: unlocking one adds it to the roll at birth
	heading(body, "Families in your birth roll", 3, C.accentHi)
	for i, o in meta.origins or {} do
		local c = card(body, 10 + i, if o.unlocked then nil else C.stroke)
		Kit.caps({ Text = string.upper(Format.escape(o.name)) .. (if o.side then "  ·  " .. string.upper(o.side) else ""), FontFace = F.display, TextSize = 13, TextColor3 = if o.unlocked then C.text else C.sub, LayoutOrder = 1, ZIndex = 2, Parent = c })
		if o.unlocked then
			Kit.caps({ Text = "In your roll", FontFace = F.displayMed, TextSize = 11, TextColor3 = C.good, LayoutOrder = 2, ZIndex = 2, Parent = c })
		else
			local afford = (meta.glow or 0) >= (o.cost or 0)
			local b = Kit.button({
				name = "UnlockOrigin_" .. o.id,
				text = string.format("Unlock · %d %s", o.cost or 0, glowName),
				style = if afford then "primary" else "ghost",
				size = UDim2.new(1, 0, 0, 30),
				order = 2,
				textSize = 12,
				zIndex = 2,
				enabled = afford,
				onClick = function()
					if ctx.actions.unlockOrigin then
						ctx.actions.unlockOrigin(o.id, function()
							self:render("light")
						end)
					end
				end,
			})
			b.Parent = c
		end
	end
	-- modes that unlock with Light
	local modes = (ctx.info and ctx.info.modes) or {}
	local order = 100
	for _, m in modes do
		local cost = m.unlock and m.unlock.light
		if cost then
			if order == 100 then
				heading(body, "Modes", order, C.accentHi)
			end
			order += 1
			local open = meta.modes and meta.modes[m.id]
			local c = card(body, order, nil)
			Kit.caps({ Text = string.upper(Format.escape(m.name)), FontFace = F.display, TextSize = 13, TextColor3 = if m.color then Theme.rgb(m.color) else C.text, LayoutOrder = 1, ZIndex = 2, Parent = c })
			if open then
				Kit.caps({ Text = "Unlocked", FontFace = F.displayMed, TextSize = 11, TextColor3 = C.good, LayoutOrder = 2, ZIndex = 2, Parent = c })
			else
				local afford = (meta.glow or 0) >= cost
				local b = Kit.button({
					name = "UnlockMode_" .. m.id,
					text = string.format("Unlock · %d %s", cost, glowName),
					style = if afford then "primary" else "ghost",
					size = UDim2.new(1, 0, 0, 30),
					order = 2,
					textSize = 12,
					zIndex = 2,
					enabled = afford,
					onClick = function()
						if ctx.actions.unlockMode then
							ctx.actions.unlockMode(m.id, function()
								self:render("light")
							end)
						end
					end,
				})
				b.Parent = c
			end
		end
	end
end

function SidePanel:drawLore(body: Instance)
	local info = self.ctx.info and self.ctx.info.codex
	if not info then
		Kit.text({ Text = "No archive in this game.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, ZIndex = 2, Parent = body })
		return
	end
	local found = (self.meta and self.meta.codex) or {}
	local total, have, secrets, secretsHave = 0, 0, 0, 0
	for _, e in info.entries do
		total += 1
		if found[e.id] then
			have += 1
		end
		if e.secret then
			secrets += 1
			if found[e.id] then
				secretsHave += 1
			end
		end
	end
	Kit.text({
		Text = string.format("<b>%d</b> of %d entries found%s", have, total, if secrets > 0 then string.format("  ·  %s", Format.color(string.format("%d/%d secrets", secretsHave, secrets), C.strange)) else ""),
		FontFace = F.uiMedium,
		TextSize = 12,
		TextColor3 = C.sub,
		LayoutOrder = 0,
		ZIndex = 2,
		Parent = body,
	})
	Kit.text({
		Text = "What you learn stays with you, life after life.",
		FontFace = F.serifItalic,
		TextSize = 12,
		TextColor3 = C.faint,
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = body,
	})
	local order = 1
	for _, cat in info.categories or {} do
		local entries = {}
		local catHave = 0
		for _, e in info.entries do
			if e.category == cat.id then
				table.insert(entries, e)
				if found[e.id] then
					catHave += 1
				end
			end
		end
		if #entries > 0 then
			order += 1
			local open = self.expanded[cat.id]
			if open == nil then
				open = catHave > 0
			end
			local head = Kit.button({
				name = "Cat_" .. cat.id,
				text = string.format("%s %s   %d/%d", if open then "-" else "+", cat.name, catHave, #entries),
				style = "ghost",
				size = UDim2.new(1, 0, 0, 30),
				order = order,
				textSize = 13,
				zIndex = 2,
				onClick = function()
					self.expanded[cat.id] = not open
					self:render("lore")
				end,
			})
			head.TextXAlignment = Enum.TextXAlignment.Left
			Kit.padding(0, 10, 0, 10).Parent = head
			head.Parent = body
			if open then
				for _, e in entries do
					order += 1
					local unlocked = found[e.id] ~= nil
					local label = if unlocked then e.title elseif e.secret then "Secret  ·  not yet found" else "???"
					local b = Kit.button({
						name = "Entry_" .. e.id,
						text = label,
						plain = true,
						style = if unlocked then "secondary" else "ghost",
						size = UDim2.new(1, 0, 0, 30),
						order = order,
						textSize = 12,
						zIndex = 2,
						enabled = unlocked,
						onClick = function()
							if self.ctx.actions.openLore then
								self.ctx.actions.openLore(e.id)
							end
						end,
					})
					b.TextXAlignment = Enum.TextXAlignment.Left
					b.TextColor3 = if unlocked then (if e.secret then C.strange else C.text) else C.faint
					Kit.padding(0, 10, 0, 18).Parent = b
					b.Parent = body
				end
			end
		end
	end
end

function SidePanel:drawCity(body: Instance)
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	-- today's event
	heading(body, "Today in the City", nextOrder())
	local today = card(body, nextOrder(), C.accent)
	if self.daily then
		Kit.text({ Text = Format.escape(self.daily.name), FontFace = F.display, TextSize = 17, TextColor3 = C.accentHi, LayoutOrder = 1, ZIndex = 2, Parent = today })
		Kit.text({ Text = Format.escape(self.daily.desc or ""), FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = today })
		local life = self.life
		local act = nil
		for _, a in (life and life.activities) or {} do
			if a.daily then
				act = a
			end
		end
		local label, enabled = "Go", false
		if not life or not life.alive then
			label = "Start a life first"
		elseif not act then
			label = "Not for you today"
		elseif act.enabled then
			enabled = true
		else
			label = act.reason or "Not now"
		end
		local b = Kit.button({
			name = "DailyGo",
			text = label,
			style = if enabled then "primary" else "ghost",
			size = UDim2.new(1, 0, 0, 34),
			order = 3,
			textSize = 14,
			zIndex = 2,
			enabled = enabled,
			onClick = function()
				if act then
					self.ctx.actions.doActivity(act.id)
					if self.drawer then
						self:closeDrawer()
					end
				end
			end,
		})
		b.Parent = today
		Kit.text({ Text = "Everyone on every server gets the same event today. It changes at midnight (UTC).", FontFace = F.ui, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 4, ZIndex = 2, Parent = today })
	else
		Kit.text({ Text = "A quiet day.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 1, ZIndex = 2, Parent = today })
	end
	-- the world right now
	heading(body, "Right now", nextOrder())
	local now = card(body, nextOrder(), if self.world and self.world.tone == "danger" then C.crimson else nil)
	if self.world then
		Kit.text({ Text = Format.escape(self.world.headline or self.world.name or ""), FontFace = F.display, TextSize = 15, TextColor3 = if self.world.tone == "danger" then C.crimsonHi else C.text, LayoutOrder = 1, ZIndex = 2, Parent = now })
		Kit.text({ Text = Format.escape(self.world.text or ""), FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = now })
	else
		Kit.text({ Text = "Nothing out of the ordinary. For the City, anyway.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 1, ZIndex = 2, Parent = now })
	end
	-- (v0.13) YOUR STREETS: the turf war in your District, block by block
	local turf = self.life and self.life.turf
	if turf and turf.blocks and #turf.blocks > 0 then
		heading(body, string.format("Your streets  ·  %d of %d held", turf.held or 0, #turf.blocks), nextOrder(), C.accentHi)
		local map = new("Frame", { Name = "TurfMap", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
		new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -4, 0, 58), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = map })
		for i, b in turf.blocks do
			local hc = if b.color then Theme.rgb(b.color) else C.sub
			local tile = new("Frame", { BackgroundColor3 = hc:Lerp(C.panelLo, if b.yours then 0.45 else 0.78), BorderSizePixel = 0, LayoutOrder = i, ZIndex = 2, Parent = map }, {
				Kit.corner(4),
				Kit.stroke(hc, if b.yours then 2 else 1, if b.yours then 0 else 0.5),
				Kit.padding(5, 6, 5, 6),
			})
			local bname = b.name or ""
			bname = string.upper(string.sub(bname, 1, 1)) .. string.sub(bname, 2)
			Kit.text({ Text = Format.escape(bname), FontFace = F.uiBold, TextSize = 11, TextColor3 = C.text, Size = UDim2.new(1, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.None, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 3, Parent = tile })
			Kit.caps({ Text = if b.yours then "YOURS" else string.upper(b.holderName or ""), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 12), TextSize = 10, TextColor3 = if b.yours then C.accentHi else hc:Lerp(Color3.new(1, 1, 1), 0.35), ZIndex = 3, Parent = tile })
		end
		Kit.text({
			Text = (if turf.sideName then ("You fight under " .. Format.escape(turf.sideName) .. ". ") else "") .. "Every block you hold pays every year. Take more, walk them, or lose them: DO tab, Turf.",
			FontFace = F.ui,
			TextSize = 11,
			TextColor3 = C.faint,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = body,
		})
	end
	-- THE DISTRICTS: what players on this server have done to them (safety, prosperity, a holder)
	local holds = self.holds or {}
	local here = self.life and self.life.district
	if #holds > 0 or (self.life and self.life.hold) then
		heading(body, "The Districts", nextOrder())
		Kit.text({
			Text = "What people on this server have done to the City. Safer Districts have fewer bad years; richer ones pay better.",
			FontFace = F.serifItalic,
			TextSize = 12,
			TextColor3 = C.faint,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = body,
		})
		local function scale(v: number): string
			local n = math.clamp(math.floor(v + 0.5), -5, 5)
			if n == 0 then
				return "as it was"
			end
			return (if n > 0 then string.rep("+", n) else string.rep("-", -n))
		end
		for _, h in holds do
			local mine = here ~= nil and h.district == here
			local row = card(body, nextOrder(), if mine then C.accentHi else nil)
			Kit.text({
				Text = Format.color(string.upper(Format.escape(h.name or h.district or "")), if mine then C.accentHi else C.text) .. (if mine then "   " .. Format.color("YOU LIVE HERE", C.faint) else ""),
				FontFace = F.display,
				TextSize = 13,
				LayoutOrder = 1,
				ZIndex = 2,
				Parent = row,
			})
			Kit.text({
				Text = Format.color("SAFETY ", C.faint) .. Format.color(scale(h.safety or 0), if (h.safety or 0) >= 0 then C.good else C.crimsonHi)
					.. "     " .. Format.color("PROSPERITY ", C.faint) .. Format.color(scale(h.prosperity or 0), if (h.prosperity or 0) >= 0 then C.money else C.bad),
				FontFace = F.mono,
				TextSize = 11,
				LayoutOrder = 2,
				ZIndex = 2,
				Parent = row,
			})
			if h.holder then
				Kit.text({ Text = "Its streets answer to " .. Format.escape(h.holder) .. ".", FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = 2, Parent = row })
			end
		end
	end
	-- STANDING: how each faction regards you. Bad standing brings them to your door.
	local function standingColor(v: number): Color3
		return if v <= -30 then C.crimsonHi elseif v < 0 then C.bad elseif v >= 30 then C.good elseif v > 0 then C.accentHi else C.sub
	end
	local function standingText(r: any): string
		return string.format("%s  %s%d", string.upper(r.standing or ""), if r.value > 0 then "+" else "", r.value)
	end
	-- a meter from -100 to +100 with a stranger in the middle
	local function standingMeter(parent: Instance, value: number, order: number)
		local color = standingColor(value)
		local track = new("Frame", { BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 5), LayoutOrder = order, ZIndex = 2, Parent = parent })
		new("Frame", { BackgroundColor3 = C.strokeHi, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 2, 1, 4), ZIndex = 3, Parent = track })
		local w = math.clamp(math.abs(value) / 200, 0, 0.5)
		new("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(if value >= 0 then 0.5 else 0.5 - w, 0),
			Size = UDim2.fromScale(w, 1),
			ZIndex = 2,
			Parent = track,
		})
	end
	local function nameRow(row: Instance, emblem: string?, name: string, right: string, rightColor: Color3, size: number)
		local head = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, size + 2), LayoutOrder = 1, ZIndex = 2, Parent = row })
		if emblem then
			local icon = Emblem.make(emblem, size)
			icon.ZIndex = 3
			icon.Parent = head
		end
		new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(if emblem then size + 8 else 0, 0),
			Size = UDim2.new(1, -150 - (if emblem then size + 8 else 0), 1, 0),
			Text = string.upper(Format.escape(name)),
			FontFace = F.display,
			TextSize = 13,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 2,
			Parent = head,
		})
		new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 146, 1, 0),
			Text = right,
			FontFace = F.mono,
			TextSize = 11,
			TextColor3 = rightColor,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 2,
			Parent = head,
		})
	end
	-- standings that "Who you know of" can't show on an entry of its own (the list below
	-- carries the rest, so a faction is never listed twice)
	local rep = self.life and self.life.rep
	local loose = {}
	for _, r in rep or {} do
		if not r.known then
			table.insert(loose, r)
		end
	end
	if #loose > 0 then
		heading(body, "Your standing", nextOrder())
		for _, r in loose do
			local row = card(body, nextOrder())
			nameRow(row, r.emblem, r.name or "", standingText(r), standingColor(r.value), 18)
			standingMeter(row, r.value, 2)
			if r.note then
				Kit.text({ Text = Format.escape(r.note), FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = 2, Parent = row })
			end
		end
	end
	-- who you've heard of, and where you stand with them: the City opens up as a life goes on
	local known = self.life and self.life.known
	if known and (#known.list > 0 or known.hidden > 0) then
		heading(body, "Who you know of", nextOrder())
		Kit.text({
			Text = "Everyone the City has introduced you to, and how they feel about you. Cross one of them and they remember.",
			FontFace = F.serifItalic,
			TextSize = 12,
			TextColor3 = C.faint,
			LayoutOrder = nextOrder(),
			ZIndex = 2,
			Parent = body,
		})
		local groups = known.groups or { { id = "others", name = "" } }
		for _, gr in groups do
			local rows = {}
			for _, k in known.list do
				if (k.group or "others") == gr.id then
					table.insert(rows, k)
				end
			end
			local more = (known.hiddenBy and known.hiddenBy[gr.id]) or 0
			if #rows > 0 or more > 0 then
				if not (gr.id == "others" and #groups == 1) and gr.name and gr.name ~= "" then
					Kit.text({
						Text = string.format("%s  <font color=\"#%s\">%d</font>", string.upper(Format.escape(gr.name)), C.faint:ToHex(), #rows),
						RichText = true,
						FontFace = F.displayMed,
						TextSize = 12,
						TextColor3 = C.accentHi,
						LayoutOrder = nextOrder(),
						ZIndex = 2,
						Parent = body,
					})
				end
				for _, k in rows do
					local row = card(body, nextOrder(), if k.rep and k.rep.value <= -30 then C.crimson else nil)
					nameRow(row, k.emblem, k.name or "", string.upper(k.status or ""), if k.status == "One of them" then C.accentHi else C.faint, 20)
					if k.rep then
						-- where you stand with them
						local line = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 2, ZIndex = 2, Parent = row })
						local who = if k.rep.name and k.rep.name ~= k.name then "STANDING WITH " .. string.upper(Format.escape(k.rep.name)) else "YOUR STANDING"
						new("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -120, 1, 0),
							Text = who,
							FontFace = F.displayMed,
							TextSize = 10,
							TextColor3 = C.faint,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							ZIndex = 2,
							Parent = line,
						})
						new("TextLabel", {
							BackgroundTransparency = 1,
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, 0, 0, 0),
							Size = UDim2.new(0, 120, 1, 0),
							Text = standingText(k.rep),
							FontFace = F.mono,
							TextSize = 11,
							TextColor3 = standingColor(k.rep.value),
							TextXAlignment = Enum.TextXAlignment.Right,
							ZIndex = 2,
							Parent = line,
						})
						standingMeter(row, k.rep.value, 3)
					end
					Kit.text({ Text = Format.escape(k.blurb or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 4, ZIndex = 2, Parent = row })
					if k.rep and k.rep.note then
						Kit.text({ Text = Format.escape(k.rep.note), FontFace = F.serifItalic, TextSize = 12, TextColor3 = standingColor(k.rep.value), LayoutOrder = 5, ZIndex = 2, Parent = row })
					end
				end
				if more > 0 then
					Kit.text({
						Text = if #rows == 0
							then string.format("%d here you haven't heard of yet.", more)
							else string.format("%d more here you haven't heard of yet.", more),
						FontFace = F.serifItalic,
						TextSize = 12,
						TextColor3 = C.faint,
						LayoutOrder = nextOrder(),
						ZIndex = 2,
						Parent = body,
					})
				end
			end
		end
	end
	-- this server's chronicle
	heading(body, "On this server", nextOrder())
	if #self.chronicle == 0 then
		Kit.text({ Text = "Nothing yet. Somebody here is about to make history.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
	end
	for _, entry in self.chronicle do
		local row = card(body, nextOrder())
		Kit.text({ Text = Format.escape(entry.text), FontFace = F.serif, TextSize = 13, TextColor3 = C.text, LayoutOrder = 1, ZIndex = 2, Parent = row })
		Kit.caps({ Text = ago(entry.at), FontFace = F.displayMed, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 2, ZIndex = 2, Parent = row })
	end
	Kit.text({
		Text = "Big things people do here go into the chronicle, and can turn up in each other's lives.",
		FontFace = F.ui,
		TextSize = 11,
		TextColor3 = C.faint,
		LayoutOrder = nextOrder(),
		ZIndex = 2,
		Parent = body,
	})
end

-- ── Story: what this life is about, what's next, and how it has gone so far ──


function SidePanel:drawStory(body: Instance)
	local life = self.life
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	local story = life and life.story
	if not life then
		heading(body, "Your story", nextOrder(), C.sub)
		Kit.text({ Text = "Start a life. The City hands every child a story on the way in.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
		return
	end
	-- (v0.13) the part of life this is
	if life.phase then
		local pc = if life.phase.color then Theme.rgb(life.phase.color) else C.strange
		local pcard = card(body, nextOrder(), pc)
		pcard.Name = "PhaseCard"
		Kit.caps({ Text = "This part of life" .. (if life.phase.nextName then ("  ·  next: " .. life.phase.nextName .. " at " .. tostring(life.phase.nextAt)) else ""), FontFace = F.displayMed, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 1, ZIndex = 2, Parent = pcard })
		Kit.text({ Text = string.upper(Format.escape(life.phase.name or "")), FontFace = F.display, TextSize = 18, TextColor3 = pc, LayoutOrder = 2, ZIndex = 2, Parent = pcard })
		Kit.text({ Text = Format.escape(life.phase.line or ""), FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = 2, Parent = pcard })
	end
	-- (v0.13) open cases, and the episodes this life has seen through
	local openCases = {}
	for _, c in life.cases or {} do
		if not c.solved then
			table.insert(openCases, c)
		end
	end
	if #openCases > 0 then
		heading(body, "Open cases", nextOrder(), C.strange)
		for _, c in openCases do
			local cc = card(body, nextOrder(), C.strange)
			Kit.text({ Text = string.upper(Format.escape(c.name)) .. Format.color(string.format("   %d/%d", math.min(c.clues, c.of), c.of), C.strange), FontFace = F.display, TextSize = 14, LayoutOrder = 1, ZIndex = 2, Parent = cc })
			local track = new("Frame", { BackgroundColor3 = C.panel, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 5), LayoutOrder = 2, ZIndex = 2, Parent = cc }, { Kit.corner(2) })
			new("Frame", { BackgroundColor3 = C.strange, BorderSizePixel = 0, Size = UDim2.new(math.clamp(c.clues / math.max(1, c.of), 0.03, 1), 0, 1, 0), ZIndex = 3, Parent = track }, { Kit.corner(2) })
		end
	end
	if life.episodes and #life.episodes > 0 then
		heading(body, string.format("Episodes  ·  %d seen through", #life.episodes), nextOrder(), C.strange)
		for i = #life.episodes, math.max(1, #life.episodes - 5), -1 do
			local e = life.episodes[i]
			local ec = if e.color then Theme.rgb(e.color) else C.strange
			Kit.text({
				Text = Format.color(string.upper(Format.escape(e.name or "")), ec) .. Format.color("   age " .. tostring(e.age or 0), C.faint) .. "\n" .. Format.escape(e.ending or ""),
				FontFace = F.uiMedium,
				TextSize = 12,
				TextColor3 = C.sub,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = body,
			})
		end
	end
	if story and story.name then
		local tone = Theme.tone(story.tone)
		-- the story: its name, its premise in a line, and what to do now
		local sc = card(body, nextOrder(), tone)
		sc.Name = "StoryCard"
		Kit.caps({ Text = if (story.act or 1) >= 2 then "Your story  ·  a second one" else "Your story", FontFace = F.displayMed, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 1, ZIndex = 2, Parent = sc })
		Kit.text({ Text = string.upper(Format.escape(story.name)), FontFace = F.display, TextSize = 22, TextColor3 = tone, LayoutOrder = 2, ZIndex = 2, Parent = sc })
		Kit.text({ Text = Format.escape(story.hook or ""), FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = 2, Parent = sc })
		local nextCard = card(body, nextOrder(), if story.ending then C.accent else tone)
		nextCard.Name = "StoryGoal"
		Kit.caps({ Text = if story.ending then "How it ended" else "Now", FontFace = F.display, TextSize = 13, TextColor3 = if story.ending then C.accentHi else tone, LayoutOrder = 1, ZIndex = 2, Parent = nextCard })
		Kit.text({ Text = Format.escape(story.ending or story.goal or "Live. The story finds you."), FontFace = F.serif, TextSize = 15, TextColor3 = C.text, LayoutOrder = 2, ZIndex = 2, Parent = nextCard })
		if not story.ending and story.nextAge then
			Kit.caps({ Text = "Next chapter at age " .. tostring(story.nextAge), FontFace = F.displayMed, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = 2, Parent = nextCard })
		end

		-- THE CHAPTERS: behind you, the next one, still ahead
		local chapters = story.chapters or {}
		if #chapters > 0 then
			heading(body, "Chapters", nextOrder(), tone)
			local line = new("Frame", { Name = "Timeline", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, #chapters * 26), LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
			-- the rail the chapters hang on
			new("Frame", { BackgroundColor3 = C.stroke, BorderSizePixel = 0, Position = UDim2.fromOffset(6, 10), Size = UDim2.new(0, 2, 1, -20), ZIndex = 2, Parent = line })
			for i, ch in chapters do
				local y = (i - 1) * 26
				local done, isNext = ch.state == "done", ch.state == "next"
				new("Frame", {
					Name = "Dot",
					BackgroundColor3 = if done then tone elseif isNext then C.text else C.panelLo,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(if isNext then 0 else 2, y + (if isNext then 4 else 6)),
					Size = UDim2.fromOffset(if isNext then 14 else 10, if isNext then 14 else 10),
					Rotation = 45,
					ZIndex = 3,
					Parent = line,
				}, { Kit.stroke(if done then tone elseif isNext then C.text else C.strokeHi, 1, 0) })
				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(26, y),
					Size = UDim2.fromOffset(52, 22),
					Text = "AGE " .. tostring(ch.age),
					FontFace = F.displayMed,
					TextSize = 12,
					TextColor3 = if isNext then C.text else C.faint,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
					Parent = line,
				})
				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(80, y),
					Size = UDim2.new(1, -80, 0, 22),
					Text = if done then Format.escape(ch.title or "") elseif isNext then "NEXT" else "· · ·",
					FontFace = if done then F.title elseif isNext then F.display else F.ui,
					TextSize = if isNext then 13 else 13,
					TextColor3 = if done then C.text elseif isNext then tone else C.faint,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 2,
					Parent = line,
				})
			end
		end
		-- WHO'S IN IT: the faces of this story, with a line each
		local cast = story.cast or {}
		if #cast > 0 then
			heading(body, "Who's in it", nextOrder(), tone)
			for _, person in cast do
				local row = new("Frame", {
					Name = "Cast",
					BackgroundColor3 = C.panel,
					BackgroundTransparency = 0.25,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 52),
					LayoutOrder = nextOrder(),
					ZIndex = 2,
					Parent = body,
				}, { Kit.corner(3) })
				local fig = AvatarView.new(self.ctx, { size = UDim2.fromOffset(44, 46), framing = "portrait", background = C.panelLo, zIndex = 3, still = true })
				fig.frame.Position = UDim2.fromOffset(3, 3)
				fig.frame.Parent = row
				fig:set({ look = person.look, age = 30, form = "human", sanity = 0 })
				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(56, 6),
					Size = UDim2.new(1, -62, 0, 18),
					Text = Format.escape(person.name or ""),
					FontFace = F.display,
					TextSize = 14,
					TextColor3 = C.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 3,
					Parent = row,
				})
				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(56, 25),
					Size = UDim2.new(1, -62, 0, 22),
					Text = Format.escape(person.line or ""),
					FontFace = F.serifItalic,
					TextSize = 12,
					TextColor3 = C.sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 3,
					Parent = row,
				})
			end
		end
	else
		heading(body, "Your story", nextOrder(), C.sub)
		local sc = card(body, nextOrder())
		Kit.text({ Text = "BETWEEN STORIES", FontFace = F.display, TextSize = 16, TextColor3 = C.text, LayoutOrder = 1, ZIndex = 2, Parent = sc })
		Kit.text({ Text = "Nothing has hold of you right now. Stories find people through their work, their District and the age they live in.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = sc })
	end

	-- what you chose, newest first (three, the rest is in the feed)
	local moments = story and story.moments
	if moments and #moments > 0 then
		heading(body, "What you did", nextOrder())
		for i = #moments, math.max(1, #moments - 3), -1 do
			local m = moments[i]
			local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
			new("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(48, 18),
				Text = "AGE " .. tostring(m.age),
				FontFace = F.displayMed,
				TextSize = 11,
				TextColor3 = C.faint,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,
				Parent = row,
			})
			Kit.text({
				Text = "<b>" .. Format.escape(m.title or "") .. "</b>" .. (if m.choice then "  " .. Format.color(Format.escape(m.choice), C.sub) else ""),
				FontFace = F.serif,
				TextSize = 13,
				TextColor3 = C.text,
				Position = UDim2.fromOffset(52, 0),
				Size = UDim2.new(1, -52, 0, 0),
				ZIndex = 2,
				Parent = row,
			})
		end
	end

	-- YOUR GOALS: what this life is working toward, with how far along each is
	local ambitions = life.ambitions or {}
	if #ambitions > 0 then
		heading(body, "Your goals", nextOrder(), C.accentHi)
		for _, a in ambitions do
			local gc = card(body, nextOrder())
			gc.Name = "Goal"
			Kit.text({ Text = Format.escape(a.name or ""), FontFace = F.displayMed, TextSize = 14, TextColor3 = C.text, LayoutOrder = 1, ZIndex = 2, Parent = gc })
			if a.progress then
				local track = new("Frame", { BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 6), LayoutOrder = 2, ZIndex = 2, Parent = gc }, { Kit.corner(3) })
				new("Frame", { BackgroundColor3 = C.accentHi, BorderSizePixel = 0, Size = UDim2.new(math.clamp(a.progress, 0.02, 1), 0, 1, 0), ZIndex = 3, Parent = track }, { Kit.corner(3) })
			end
			if a.desc and a.desc ~= "" then
				Tip.attach(gc, a.name, a.desc)
			end
		end
	end

	-- stories behind you in this life
	local past = story and story.done
	if past and #past > 0 then
		heading(body, "Earlier in this life", nextOrder(), C.sub)
		for _, st in past do
			Kit.text({
				Text = "<b>" .. string.upper(Format.escape(st.name or "")) .. "</b>" .. (if st.ending then "  " .. Format.color(Format.escape(st.ending), C.sub) else ""),
				FontFace = F.serif,
				TextSize = 13,
				TextColor3 = C.text,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = body,
			})
		end
	end

	-- the collection: stories this account has lived
	local stories = self.meta and self.meta.stories
	if stories and (stories.total or 0) > 0 then
		heading(body, string.format("Stories lived  %d / %d", stories.lived or 0, stories.total), nextOrder())
		for i, st in stories.list do
			local endings = #(st.endings or {})
			Kit.text({
				Text = Format.color(string.upper(Format.escape(st.name)), Theme.tone(st.tone))
					.. Format.color(string.format("   %d %s  ·  %d %s", st.lives or 1, if (st.lives or 1) == 1 then "life" else "lives", endings, if endings == 1 then "ending" else "endings"), C.faint),
				FontFace = F.display,
				TextSize = 13,
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = body,
			})
		end
	end
end

-- ── Family: the household you were born into, and the one you make ──────────

local FAMILY_GROUPS = {
	{ title = "Your parents", kinds = { mother = true, father = true } },
	{ title = "Brothers and sisters", kinds = { sibling = true } },
	{ title = "Your children", kinds = { child = true } },
	{ title = "Friends", kinds = { friend = true } },
	{ title = "Teachers and rivals", kinds = { mentor = true, rival = true } },
	{ title = "Your household", kinds = { partner = true } },
	{ title = "People you've met", kinds = { acquaintance = true } },
}

function SidePanel:personRow(body: Instance, order: number, rel)
	local ctx = self.ctx
	local alive = rel.alive
	local row = new("TextButton", {
		Name = "Person_" .. tostring(rel.id),
		AutoButtonColor = false,
		BackgroundColor3 = C.panelLo,
		BackgroundTransparency = if alive then 0 else 0.4,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 64),
		Text = "",
		LayoutOrder = order,
		ZIndex = 2,
		Parent = body,
	}, { Kit.corner(2) })
	local stroke = Kit.stroke(C.stroke, 1, 0.3)
	stroke.Parent = row
	local fig = AvatarView.new(ctx, { size = UDim2.fromOffset(52, 56), framing = "portrait", background = C.panel, zIndex = 3 })
	fig.frame.Position = UDim2.fromOffset(4, 4)
	fig.frame.Parent = row
	fig:set(rel.appearance)
	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(64, 5),
		Size = UDim2.new(1, -72, 0, 18),
		Text = Format.escape(rel.name),
		FontFace = F.display,
		TextSize = 15,
		TextColor3 = if alive then C.text else C.sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = row,
	})
	local kindText = rel.kindName or rel.kind
	if rel.linked and rel.player then
		kindText ..= " (" .. rel.player .. ")"
	elseif rel.role then
		-- someone you've met: who they are to you
		kindText = rel.role
	elseif rel.jobShort then
		kindText ..= ", " .. rel.jobShort
	end
	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(64, 23),
		Size = UDim2.new(1, -72, 0, 16),
		Text = Format.escape(kindText) .. (if alive then "  ·  age " .. tostring(rel.age) elseif rel.fate then "  ·  " .. Format.escape(rel.fate) else "  ·  gone at " .. tostring(rel.age)) .. (if rel.heir and alive then "  ·  heir" else ""),
		FontFace = F.ui,
		TextSize = 12,
		TextColor3 = if rel.linked then C.strange else C.sub,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
		Parent = row,
	})
	-- the bond: a word for it, and a bar
	local bond = rel.bond or 0
	local word = if not alive then "Remembered" elseif bond >= 80 then "Close" elseif bond >= 55 then "Warm" elseif bond >= 30 then "Distant" else "Strained"
	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(64, 42),
		Size = UDim2.fromOffset(84, 14),
		Text = string.upper(word),
		FontFace = F.displayMed,
		TextSize = 11,
		TextColor3 = if not alive then C.faint elseif bond >= 55 then C.good elseif bond >= 30 then C.sub else C.crimsonHi,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = row,
	})
	local track = new("Frame", {
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 150, 0, 49),
		Size = UDim2.new(1, -160, 0, 5),
		ZIndex = 3,
		Parent = row,
	}, { Kit.corner(1) })
	new("Frame", {
		BackgroundColor3 = if not alive then C.faint elseif bond >= 30 then C.good else C.crimsonHi,
		BorderSizePixel = 0,
		Size = UDim2.new(math.clamp(bond / 100, 0, 1), 0, 1, 0),
		ZIndex = 3,
		Parent = track,
	}, { Kit.corner(1) })
	-- what you can do with them this year, right here (the first three; tap the row for all)
	local quick = {}
	for _, act in rel.interactions or {} do
		if #quick < 3 and act.enabled then
			table.insert(quick, act)
		end
	end
	if alive and #quick > 0 then
		row.Size = UDim2.new(1, 0, 0, 96)
		local bar = new("Frame", {
			Name = "Quick",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(6, 64),
			Size = UDim2.new(1, -12, 0, 26),
			ZIndex = 4,
			Parent = row,
		}, { Kit.list(6, Enum.FillDirection.Horizontal) })
		for i, act in quick do
			local b = new("TextButton", {
				Name = "Do_" .. tostring(act.id),
				AutoButtonColor = false,
				BackgroundColor3 = C.panel,
				BorderSizePixel = 0,
				Size = UDim2.new(1 / #quick, -4, 1, 0),
				Text = string.upper(Format.escape(act.name)),
				FontFace = F.displayMed,
				TextSize = 11,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextColor3 = C.accentHi,
				LayoutOrder = i,
				ZIndex = 5,
				Parent = bar,
			}, { Kit.corner(2), Kit.stroke(C.accentLo, 1, 0.3) })
			-- what it gives, in the numbers this life would really get
			local gives = ""
			if act.scene then
				gives = "  A scene: what you choose there decides what it gives."
			else
				local words = {}
				for _, c in DoTab.stakeChips(ctx, act.gains or (act.stakes and act.stakes.win), 5) do
					table.insert(words, c.text)
				end
				if #words > 0 then
					gives = (if act.stakes then "  Win: " else "  Gives ") .. table.concat(words, ", ") .. "."
				end
			end
			Tip.attach(b, act.name, (act.desc or "") .. gives .. (if act.cost and act.cost > 0 then "  Costs " .. tostring(act.cost) .. "." else ""))
			b.Activated:Connect(function()
				if act.clash then
					-- a risk: the person's own sheet has the odds and the ways to go in
					ctx.actions.openPerson(rel)
				else
					ctx.actions.interact(rel.id, act.id)
				end
			end)
		end
	end
	if alive then
		row.MouseEnter:Connect(function()
			Kit.tween(stroke, 0.1, { Color = C.accentHi, Transparency = 0 })
		end)
		row.MouseLeave:Connect(function()
			Kit.tween(stroke, 0.1, { Color = C.stroke, Transparency = 0.3 })
		end)
		row.Activated:Connect(function()
			if self.drawer then
				self:closeDrawer()
			end
			ctx.actions.openPerson(rel)
		end)
	end
	return row
end

function SidePanel:drawFamily(body: Instance)
	local ctx = self.ctx
	local life = self.life
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	if not life then
		heading(body, "Family", nextOrder(), C.sub)
		Kit.text({ Text = "Start a life to see who you were born to.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
		return
	end
	-- TIME FOR PEOPLE: its own three a year, apart from the actions spent on everything else
	if life.socialPerYear then
		local per, left = life.socialPerYear, life.socialLeft or 0
		local strip = new("Frame", { Name = "PeopleTime", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = nextOrder(), ZIndex = 2, Parent = body }, { Kit.list(6, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center) })
		for i = 1, per do
			new("Frame", {
				BackgroundColor3 = if i <= left then C.good else C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(14, 14),
				LayoutOrder = i,
				ZIndex = 2,
				Parent = strip,
			}, { Kit.round(), Kit.stroke(if i <= left then C.good else C.stroke, 1, 0.2) })
		end
		Kit.caps({
			Text = if left > 0 then string.format("%d of %d times with people left this year", left, per) else "No time left for people this year",
			Size = UDim2.new(1, -(per * 20 + 8), 1, 0),
			FontFace = F.display,
			TextSize = 13,
			TextColor3 = if left > 0 then C.text else C.sub,
			LayoutOrder = per + 1,
			ZIndex = 2,
			Parent = strip,
		})
		Kit.text({ Text = "Family and friends have their own time. It doesn't use up your actions.", FontFace = F.ui, TextSize = 11, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
	end
	-- the household: the name, where it lives, what you were born into
	local living, gone = 0, 0
	for _, rel in life.relations or {} do
		if rel.kind == "mother" or rel.kind == "father" or rel.kind == "sibling" or rel.kind == "child" then
			if rel.alive then
				living += 1
			else
				gone += 1
			end
		end
	end
	heading(body, "Household", nextOrder())
	local home = card(body, nextOrder(), C.accent)
	home.Name = "Household"
	Kit.text({ Text = string.upper("The " .. Format.escape(life.last or "") .. " family"), FontFace = F.display, TextSize = 19, TextColor3 = C.accentHi, LayoutOrder = 1, ZIndex = 2, Parent = home })
	Kit.text({ Text = Format.escape(life.zone or ""), FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = home })
	local origin = life.origin
	if origin then
		Kit.text({
			Text = Format.color("BORN TO  ", C.faint) .. "<b>" .. Format.escape(origin.name or "") .. "</b>  " .. Format.escape(origin.desc or ""),
			FontFace = F.serif,
			TextSize = 13,
			TextColor3 = C.text,
			LayoutOrder = 3,
			ZIndex = 2,
			Parent = home,
		})
	end
	-- what the family owns, said plainly
	local household = life.household
	if household and household.owns then
		Kit.text({
			Name = "Owns",
			Text = Format.color("OWNS  ", C.faint) .. Format.escape(household.owns),
			FontFace = F.serif,
			TextSize = 13,
			TextColor3 = C.text,
			LayoutOrder = 3,
			ZIndex = 2,
			Parent = home,
		})
	end
	-- and what each parent does for a living
	local jobs = {}
	for _, rel in life.relations or {} do
		if rel.job and (rel.kind == "mother" or rel.kind == "father") then
			table.insert(jobs, Format.color(string.upper(Format.escape(rel.kindName or rel.kind)) .. "  ", C.faint) .. Format.escape(rel.first) .. " " .. Format.escape(rel.job) .. (if rel.alive then "" else Format.color("  (gone)", C.faint)))
		end
	end
	if #jobs > 0 then
		Kit.text({ Name = "Jobs", Text = table.concat(jobs, "\n"), FontFace = F.serif, TextSize = 13, TextColor3 = C.text, LayoutOrder = 3, ZIndex = 2, Parent = home })
	end
	local status
	if living == 0 and gone == 0 then
		status = "Nobody on the file but you."
	elseif living == 0 then
		status = "You're the last of them."
	elseif (life.age or 0) < 16 then
		status = string.format("%d of you under one roof. They decide where you live, for now.", living + 1)
	else
		status = string.format("%d living%s.", living, if gone > 0 then string.format(", %d gone", gone) else "")
	end
	Kit.text({ Text = status, FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 4, ZIndex = 2, Parent = home })
	-- something to do together, when the year allows it
	local visit = nil
	for _, a in life.activities or {} do
		if a.family then
			visit = a
			break
		end
	end
	if visit then
		local b = Kit.button({
			name = "FamilyVisit",
			text = if visit.enabled then visit.name else (visit.reason or visit.name),
			style = if visit.enabled then "primary" else "ghost",
			size = UDim2.new(1, 0, 0, 34),
			order = 5,
			textSize = 14,
			zIndex = 2,
			enabled = visit.enabled,
			onClick = function()
				ctx.actions.doActivity(visit.id)
				if self.drawer then
					self:closeDrawer()
				end
			end,
		})
		b.Parent = home
	end
	-- the people, by how they're yours
	local shown = {}
	for _, group in FAMILY_GROUPS do
		local first = true
		for _, rel in life.relations or {} do
			if group.kinds[rel.kind] and rel.alive then
				if first then
					first = false
					heading(body, group.title, nextOrder())
				end
				shown[rel.id] = true
				self:personRow(body, nextOrder(), rel)
			end
		end
	end
	-- everyone else who matters
	local firstOther = true
	for _, rel in life.relations or {} do
		if not shown[rel.id] and rel.alive then
			if firstOther then
				firstOther = false
				heading(body, "Close to you", nextOrder())
			end
			shown[rel.id] = true
			self:personRow(body, nextOrder(), rel)
		end
	end
	-- the ones the City took
	local firstGone = true
	for _, rel in life.relations or {} do
		if not rel.alive then
			if firstGone then
				firstGone = false
				heading(body, "Gone", nextOrder(), C.faint)
			end
			self:personRow(body, nextOrder(), rel)
		end
	end
	if #(life.relations or {}) == 0 then
		Kit.text({ Text = "No one, yet. The City is full of strangers.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
	else
		Kit.text({ Text = "Tap someone to spend time with them, ask for help, or make peace.", FontFace = F.ui, TextSize = 11, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
	end
end

function SidePanel:drawYou(body: Instance)
	local life = self.life
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	-- family name
	heading(body, "Family name", nextOrder())
	local fam = card(body, nextOrder())
	local sn = self.surnames
	local current = (sn and sn.current) or (self.meta and self.meta.surname)
	local tierColor = C.text
	local tierName = ""
	for _, t in (sn and sn.tiers) or {} do
		if current and t.id == current.tier then
			tierColor = if t.color then Theme.rgb(t.color) else C.text
			tierName = t.name
		end
	end
	Kit.text({
		Text = if current then (Format.color(Format.escape(current.name), tierColor) .. "  " .. Format.color(string.upper(tierName), C.faint)) else "No family name yet",
		FontFace = F.display,
		TextSize = 18,
		TextColor3 = C.text,
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = fam,
	})
	local rolls = (sn and sn.rolls) or (self.meta and self.meta.rolls) or 0
	local rollBtn = Kit.button({
		name = "OpenSurnames",
		text = string.format("Roll a name  (%d)", rolls),
		style = if rolls > 0 then "primary" else "ghost",
		size = UDim2.new(1, 0, 0, 32),
		order = 2,
		textSize = 13,
		zIndex = 2,
		onClick = function()
			if self.ctx.actions.openSurnames then
				self.ctx.actions.openSurnames()
			end
		end,
	})
	rollBtn.Parent = fam
	if not life then
		Kit.text({ Text = "Start a life to see your build here.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
		return
	end
	-- RENOWN: what the City calls you (Hana's grades for a threat), and what that does for you
	local renown = life.renown
	if renown and (renown.rank > 0 or renown.points > 0 or (life.age or 0) >= 16) then
		heading(body, "Renown", nextOrder())
		local rcolor = if renown.color then Theme.rgb(renown.color) else C.sub
		local rcard = card(body, nextOrder(), if renown.rank > 0 then rcolor else nil)
		Kit.text({
			Text = Format.color(string.upper(Format.escape(renown.name or "")), rcolor) .. "   " .. Format.color(string.format("%d OF %d", renown.rank, renown.of or 0), C.faint),
			FontFace = F.display,
			TextSize = 16,
			LayoutOrder = 1,
			ZIndex = 2,
			Parent = rcard,
		})
		Kit.text({ Text = Format.escape(renown.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = rcard })
		local nxt = renown.next
		if nxt then
			local span = math.max(1, nxt.at - (nxt.from or 0))
			local into = math.clamp(renown.points - (nxt.from or 0), 0, span)
			local track = new("Frame", { BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 6), LayoutOrder = 3, ZIndex = 2, Parent = rcard })
			new("Frame", { BackgroundColor3 = if renown.rank > 0 then rcolor else C.accentHi, BorderSizePixel = 0, Size = UDim2.fromScale(into / span, 1), ZIndex = 3, Parent = track })
		end
		Kit.text({
			Text = if nxt
				then string.format("%d renown. %d more and the City calls you %s.", renown.points, math.max(0, nxt.at - renown.points), Format.escape(nxt.name))
				else string.format("%d renown. Hana has no grade above this one.", renown.points),
			FontFace = F.mono,
			TextSize = 11,
			TextColor3 = C.faint,
			LayoutOrder = 4,
			ZIndex = 2,
			Parent = rcard,
		})
		Kit.text({
			Text = "Beating strong foes, hard jobs, hard years, your Office and deeds (on the DO tab) all add to it.",
			FontFace = F.serifItalic,
			TextSize = 11,
			TextColor3 = C.faint,
			LayoutOrder = 5,
			ZIndex = 2,
			Parent = rcard,
		})
	end
	-- AN OFFICE OF YOUR OWN: its size is its rank, and it pays by the year
	local office = life.office
	if office then
		heading(body, "Your Office", nextOrder())
		local ocard = card(body, nextOrder(), C.money)
		Kit.text({
			Text = Format.color(string.upper("The " .. Format.escape(office.name or "") .. " Office"), C.money) .. "   " .. Format.color(string.format("SIZE %d OF %d", office.size or 1, office.of or 1), C.faint),
			FontFace = F.display,
			TextSize = 16,
			LayoutOrder = 1,
			ZIndex = 2,
			Parent = ocard,
		})
		local rank = tostring(office.rank or "")
		Kit.text({
			Text = Format.escape(string.upper(string.sub(rank, 1, 1)) .. string.sub(rank, 2) .. ". " .. (office.desc or "")),
			FontFace = F.serif,
			TextSize = 12,
			TextColor3 = C.sub,
			LayoutOrder = 2,
			ZIndex = 2,
			Parent = ocard,
		})
		Kit.text({
			Text = string.format("Pays %s Ahn a year.%s", Format.number(office.income or 0), if office.next then " Grow it with deeds: next is " .. Format.escape(office.next) .. "." else " It can't grow any bigger."),
			FontFace = F.mono,
			TextSize = 11,
			TextColor3 = C.faint,
			LayoutOrder = 3,
			ZIndex = 2,
			Parent = ocard,
		})
		-- (v0.18) what's in it, and the way in
		if office.building then
			Kit.text({
				Text = string.format("%s  ·  %d of %d Fixers hired%s", Format.escape(tostring(office.building.name or "")), #(office.crew or {}), office.building.crew or 0, if (office.fightBase or 0) > 0 then string.format("  ·  +%d in fights", office.fightBase) else ""),
				FontFace = F.mono,
				TextSize = 11,
				TextColor3 = C.sub,
				LayoutOrder = 4,
				ZIndex = 2,
				Parent = ocard,
			})
		end
		Kit.button({
			name = "ManageOffice",
			text = if office.named == false then "Name your Office" else "Manage the Office",
			style = "primary",
			size = UDim2.new(1, 0, 0, 36),
			order = 5,
			textSize = 14,
			zIndex = 3,
			parent = ocard,
			onClick = function()
				if self.ctx.actions.openOffice then
					self.ctx.actions.openOffice({ naming = office.named == false })
				end
			end,
		})
	end
	-- A HOME OF YOUR OWN (bought from a letting agent: DO tab, Spend)
	local homeV = life.home
	if homeV then
		heading(body, "Your home", nextOrder())
		local hcard = card(body, nextOrder(), C.good)
		local hname = tostring(homeV.name or "")
		Kit.text({
			Text = Format.color(string.upper(Format.escape(hname)), C.good) .. "   " .. Format.color("SINCE AGE " .. tostring(homeV.since or 0), C.faint),
			FontFace = F.display,
			TextSize = 15,
			LayoutOrder = 1,
			ZIndex = 2,
			Parent = hcard,
		})
		Kit.text({ Text = Format.escape(homeV.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = hcard })
		local bits = {}
		if (homeV.safety or 0) > 0 then
			table.insert(bits, string.format("%d%% less trouble in the streets", math.floor(homeV.safety * 100 + 0.5)))
		end
		if (homeV.hideout or 0) > 0 then
			table.insert(bits, string.format("grudges find you %d%% less", math.floor(homeV.hideout * 100 + 0.5)))
		end
		if (homeV.sanity or 0) ~= 0 then
			table.insert(bits, string.format("%s%d Sanity a year", if homeV.sanity > 0 then "+" else "", homeV.sanity))
		end
		if (homeV.income or 0) > 0 then
			table.insert(bits, string.format("%s rent in a year", Format.number(homeV.income)))
		end
		table.insert(bits, string.format("%s a year to keep", Format.number(homeV.upkeep or 0)))
		Kit.text({ Text = table.concat(bits, "  ·  "), FontFace = F.mono, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 3, ZIndex = 2, Parent = hcard })
		Kit.text({
			Text = string.format("A letting agent would buy it back for %s %s. If you can't pay the upkeep, it's taken back.", Format.number(homeV.sellFor or 0), self.ctx.info.meta.currency),
			FontFace = F.serifItalic,
			TextSize = 11,
			TextColor3 = C.faint,
			LayoutOrder = 4,
			ZIndex = 2,
			Parent = hcard,
		})
	end
	-- the talent you were born with, and your sins
	local talent = life.talent
	if talent then
		heading(body, "Talent", nextOrder())
		local tcolor = if talent.color then Theme.rgb(talent.color) else C.accentHi
		local tcard = card(body, nextOrder(), tcolor)
		Kit.text({
			Text = Format.color(string.upper(Format.escape(talent.name)), tcolor) .. "   " .. Format.color(string.upper(Format.escape(talent.tierName or talent.tier or "")), C.faint),
			FontFace = F.display,
			TextSize = 16,
			LayoutOrder = 1,
			ZIndex = 2,
			Parent = tcard,
		})
		Kit.text({ Text = Format.escape(talent.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = tcard })
		if talent.asleep then
			-- (v0.12) a gift that hasn't woken yet does nothing yet
			Kit.text({
				Text = Format.color("ASLEEP", C.strange) .. "  " .. Format.escape(if talent.wakes then "It wakes " .. talent.wakes .. ". Until then it does nothing at all." else "It hasn't woken yet. Until it does, it does nothing at all."),
				FontFace = F.displayMed,
				TextSize = 11,
				TextColor3 = C.faint,
				LayoutOrder = 4,
				ZIndex = 2,
				Parent = tcard,
			})
		end
		local sins = {}
		for _, a in life.affinities or {} do
			table.insert(sins, Format.color(string.upper(Format.escape(a.name)), Theme.rgb(a.color)))
		end
		if #sins > 0 or talent.resonance then
			Kit.text({
				Text = (if #sins > 0 then Format.color("SINS  ", C.faint) .. table.concat(sins, "  ") else "") .. (if talent.resonance then "   " .. Format.color("RESONANCE", tcolor) else ""),
				FontFace = F.displayMed,
				TextSize = 11,
				LayoutOrder = 3,
				ZIndex = 2,
				Parent = tcard,
			})
		end
	end
	-- (v0.17) how long this body is good for, old blood, and who's teaching you
	if life.lifespan or life.bloodStage or life.trainer then
		heading(body, "Body, blood and training", nextOrder())
		local bc = card(body, nextOrder())
		local lines = {}
		if life.lifespan then
			table.insert(lines, string.format("<b>Lifespan</b>  about %d years (you're %d). K Corp courses and Workshop bodies push it back.", life.lifespan, life.age or 0))
		end
		if life.bloodStage then
			table.insert(lines, "<b>Old blood</b>  " .. Format.escape(life.bloodStage) .. ". The older the blood, the stronger it gets.")
		end
		if type(life.trainer) == "table" then
			local t = life.trainer
			table.insert(lines, string.format("<b>Training</b>  %s, lesson %d of %d%s.", Format.escape(t.name or "?"), t.lessons or 0, t.total or 0, if t.nextUp then ". Next: " .. Format.escape(t.nextUp) else ""))
		end
		Kit.text({ Text = table.concat(lines, "\n"), FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 1, ZIndex = 2, Parent = bc })
	end
	-- the discipline: a way of fighting, and the organisation it belongs to
	local style = life.style
	if not style and self.ctx.info and self.ctx.info.schools then
		heading(body, "Discipline", nextOrder())
		local nc = card(body, nextOrder())
		Kit.text({ Text = "NONE YET", FontFace = F.display, TextSize = 15, TextColor3 = C.sub, LayoutOrder = 1, ZIndex = 2, Parent = nc })
		Kit.text({
			Text = "Nobody in the City invents a way of fighting. Associations, Fingers, Wings and Offices train their own: join one, or find someone who was trained there.",
			FontFace = F.serif,
			TextSize = 12,
			TextColor3 = C.sub,
			LayoutOrder = 2,
			ZIndex = 2,
			Parent = nc,
		})
	end
	if style then
		local school = style.school
		heading(body, if school then "Discipline" else "Fighting style", nextOrder())
		local sc = card(body, nextOrder(), if style.color then Theme.rgb(style.color) else nil)
		local color = if style.color then Theme.rgb(style.color) else C.accentHi
		if school then
			Kit.text({ Text = string.upper(Format.escape(school.name)), FontFace = F.display, TextSize = 17, TextColor3 = C.text, LayoutOrder = 0, ZIndex = 2, Parent = sc })
		end
		Kit.text({ Text = Format.color(string.upper(Format.escape(style.name)), color), FontFace = F.display, TextSize = if school then 14 else 17, LayoutOrder = 1, ZIndex = 2, Parent = sc })
		Kit.text({ Text = Format.escape(style.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = sc })
		local track = new("Frame", { BackgroundColor3 = C.panel, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 8), LayoutOrder = 3, ZIndex = 2, Parent = sc }, { Kit.corner(1) })
		new("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.new(math.clamp((style.mastery or 0) / math.max(1, style.maxMastery or 5), 0, 1), 0, 1, 0),
			ZIndex = 2,
			Parent = track,
		}, { Kit.corner(1) })
		Kit.caps({ Text = string.format("Mastery %d / %d   ·   Potency x%d", style.mastery or 0, style.maxMastery or 5, style.potency or 1), FontFace = F.displayMed, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 4, ZIndex = 2, Parent = sc })
		if school then
			local line
			if school.free then
				line = "Handed down from one person to the next. Nobody can lock it away."
			elseif school.training then
				line = "You're inside " .. (school.org or "the organisation") .. ": it will train you as far as you can go."
			else
				line = string.format("It belongs to %s. Outside it you stop at mastery %d.", school.org or "its organisation", style.cap or 2)
			end
			Kit.text({ Text = Format.escape(line), FontFace = F.ui, TextSize = 11, TextColor3 = if school.training or school.free then C.good else C.accentHi, LayoutOrder = 5, ZIndex = 2, Parent = sc })
		end
	end
	-- books and scrolls: what you hold, what each teaches, and reading it
	if life.books and #life.books > 0 then
		heading(body, "Books and scrolls", nextOrder())
		for _, b in life.books do
			local bc = card(body, nextOrder(), if b.trained then C.accentHi else nil)
			bc.Name = "Book_" .. tostring(b.id)
			Kit.text({ Text = string.upper(Format.escape(b.name)), FontFace = F.display, TextSize = 14, TextColor3 = C.text, LayoutOrder = 1, ZIndex = 2, Parent = bc })
			Kit.text({ Text = Format.escape(b.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = bc })
			if b.teaches then
				Kit.text({
					Text = Format.color("TEACHES  ", C.sub) .. Format.color(string.upper(Format.escape(b.teaches)), C.good) .. (if b.teachesDesc then "  " .. Format.escape(b.teachesDesc) else ""),
					FontFace = F.ui,
					TextSize = 12,
					TextColor3 = C.sub,
					LayoutOrder = 3,
					ZIndex = 2,
					Parent = bc,
				})
			end
			if b.needs then
				Kit.text({
					Text = if b.trained then "Written for " .. Format.escape(b.needs) .. " training, which you have." else "Written for " .. Format.escape(b.needs) .. " training. You can't follow it until you have that: it will keep (and pass to an heir).",
					FontFace = F.ui,
					TextSize = 11,
					TextColor3 = if b.trained then C.good else C.accentHi,
					LayoutOrder = 4,
					ZIndex = 2,
					Parent = bc,
				})
			end
			local read = Kit.button({
				name = "Read_" .. tostring(b.id),
				text = if b.canRead then "Read it  ·  one action" else (b.reason or "Can't be read now"),
				style = if b.canRead then "primary" else "ghost",
				size = UDim2.new(1, 0, 0, 30),
				order = 5,
				textSize = 12,
				zIndex = 2,
				enabled = b.canRead == true,
				onClick = function()
					if b.activity and self.ctx.actions.doActivity then
						self.ctx.actions.doActivity(b.activity)
					end
				end,
			})
			read.Parent = bc
		end
	end
	-- traits
	heading(body, "Traits", nextOrder())
	if #(life.traits or {}) == 0 then
		Kit.text({ Text = "None yet. Lives give you some.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = 2, Parent = body })
	end
	for _, t in life.traits or {} do
		local tc = card(body, nextOrder())
		Kit.text({ Text = string.upper(Format.escape(t.name)), FontFace = F.display, TextSize = 14, TextColor3 = C.text, LayoutOrder = 1, ZIndex = 2, Parent = tc })
		Kit.text({ Text = Format.escape(t.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = tc })
	end
	-- who you are on paper
	if life.appearance then
		heading(body, "On file", nextOrder())
		local fileCard = card(body, nextOrder())
		local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 110), LayoutOrder = 1, ZIndex = 2, Parent = fileCard })
		local fig = AvatarView.new(self.ctx, { size = UDim2.fromOffset(92, 108), framing = "full", background = C.panel, zIndex = 2 })
		fig.frame.Parent = holder
		fig:set(life.appearance)
		Kit.text({
			Text = string.format("<b>%s %s</b>\nAge %d  ·  %s", Format.escape(life.first), Format.escape(life.last), life.age or 0, Format.escape(life.zone or "")),
			FontFace = F.ui,
			TextSize = 12,
			TextColor3 = C.sub,
			Position = UDim2.fromOffset(104, 6),
			Size = UDim2.new(1, -104, 0, 0),
			ZIndex = 2,
			Parent = holder,
		})
	end
end

return SidePanel
