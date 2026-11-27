--[[
	The creator (v0.8): one screen, no steps.
		local quick = QuickStart.new(ctx, parent)  -> { frame, refresh(modeId), refreshTalent(), look(), openTab(id) }

	Left (top, on a phone): your character on a lit stage, turning. Random rolls a whole new
	look; the name sits on the stage.
	Right (below): tabs, each a grid you tap: Looks (premade characters), Skin, Hair, Face,
	Outfit, Weapon, Extras, and Sins (lean toward two of the seven; your talent and its rerolls).
	Bottom: your talent, and BE BORN.
	You don't pick your family, District or side of the wall: the City rolls them when you're
	born (BirthReveal). Packs that still let you pick (info.creatorPicks) get a "More" button
	that opens the long creator.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Talent = require(script.Parent.Talent)
local AvatarView = require(script.Parent.AvatarView)
local Emblem = require(script.Parent.Emblem)
local Lobby = require(script.Parent.Lobby)

local Avatar = AvatarView.Avatar

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local QuickStart = {}

local function screenGuiOf(inst: Instance): ScreenGui?
	local p = inst.Parent
	while p and not p:IsA("ScreenGui") do
		p = p.Parent
	end
	return p :: any
end

-- the tabs: premade looks, the cosmetic categories, and the sins
local TABS = {
	{ id = "looks", name = "Looks" },
	{ id = "body", name = "Body", categories = { "body" } }, -- (v0.17)
	{ id = "skin", name = "Skin", categories = { "skin" } },
	{ id = "hair", name = "Hair", categories = { "hair", "hairColor" } },
	{ id = "face", name = "Face", categories = { "eyes", "mark" } },
	{ id = "outfit", name = "Clothes", categories = { "outfit" } },
	{ id = "weapon", name = "Weapon", categories = { "weapon" } }, -- only in packs that still pick one
	{ id = "extras", name = "Extras", categories = { "accessory", "frame" } },
	{ id = "when", name = "When" },
	{ id = "sins", name = "Sins" },
}
-- categories shown as round color swatches
local SWATCH = { skin = true, hairColor = true, eyes = true, frame = true }

local HEADER_H = 52
local FOOTER_H = 74
local WIDE_AT = 640

local function modeOf(ctx, id: string?)
	for _, m in (ctx.info and ctx.info.modes) or {} do
		if m.id == id then
			return m
		end
	end
	return nil
end

local function clear(frame: Instance)
	for _, child in frame:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

-- a tile that pops in a moment after it's made (a little stagger looks alive)
local function popIn(inst: GuiObject, index: number)
	local scale = new("UIScale", { Scale = 0.82, Parent = inst })
	task.delay(math.min(index, 24) * 0.012, function()
		if scale.Parent then
			Kit.tween(scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
		end
	end)
	return scale
end

local function pulse(scale: UIScale?)
	if scale then
		scale.Scale = 0.9
		Kit.tween(scale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
	end
end

function QuickStart.new(ctx, parent: Instance)
	local frame = new("Frame", {
		Name = "QuickStart",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = parent,
	})
	-- the side panels are hidden in the creator, so on a wide screen it spreads out
	local function widen()
		local gui = screenGuiOf(frame)
		local colW = (parent :: any).AbsoluteSize.X
		if gui and colW > 0 then
			local factor = math.clamp((gui.AbsoluteSize.X - 48) / colW, 1, 1.75)
			frame.Size = UDim2.new(factor, 0, 1, 0)
		end
	end
	task.defer(function()
		local gui = screenGuiOf(frame)
		if gui then
			gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(widen)
		end
		widen()
	end)
	local panel: any = Kit.panel({ Size = UDim2.fromScale(1, 1), AutomaticSize = Enum.AutomaticSize.None, ClipsDescendants = true, Parent = frame })

	local function sfx(name: string)
		if ctx.sfx then
			ctx.sfx(name)
		elseif ctx.sound then
			ctx.sound(name)
		end
	end

	-- ── the frame of the screen: header, body, footer ───────────────────────
	local header = new("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, HEADER_H), Parent = panel }, { Kit.padding(10, 14, 0, 14) })
	local body = new("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, HEADER_H),
		Size = UDim2.new(1, 0, 1, -HEADER_H - FOOTER_H),
		Parent = panel,
	}, { Kit.padding(0, 14, 6, 14) })
	local footer = new("Frame", {
		Name = "Footer",
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, FOOTER_H),
		Parent = panel,
	}, { Kit.padding(12, 14, 14, 14) })
	new("Frame", { BackgroundColor3 = C.stroke, BorderSizePixel = 0, Size = UDim2.new(1, 28, 0, 1), Position = UDim2.fromOffset(-14, -12), Parent = footer })

	-- the stage (left / top) and the tabbed chooser (right / below)
	local stage = new("Frame", { Name = "Stage", BackgroundColor3 = C.panelLo, BorderSizePixel = 0, ClipsDescendants = true, Parent = body }, { Kit.corner(2) })
	Kit.stroke(C.stroke, 1, 0.2).Parent = stage
	local chooser = new("Frame", { Name = "Chooser", BackgroundTransparency = 1, Parent = body })
	local tabsBar = new("ScrollingFrame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 38),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		Parent = chooser,
	}, { Kit.list(4, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center) })
	local options = new("ScrollingFrame", {
		Name = "Options",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(1, 0, 1, -44),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = C.stroke,
		Parent = chooser,
	}, { Kit.padding(2, 4, 12, 2), Kit.list(10) })

	local modeId = nil
	local typed = ""
	local eraPick: string? = nil -- nil: the City decides
	local look = nil
	local tab = "looks"
	local talentCard = nil
	local figure = nil
	local figureScale = nil
	local talentChip = nil
	local bornBtn = nil
	local tabButtons = {}
	local wide = false
	local fillOptions -- forward

	local function meta()
		return ctx.state.meta or {}
	end
	local function pack()
		return ctx.info and ctx.info.avatar
	end
	local function cosmetics()
		local p = pack()
		return p and p.cosmetics
	end
	local function recordSet()
		local set = {}
		for _, r in meta().records or {} do
			if r.unlocked then
				set[r.id] = true
			end
		end
		return set
	end
	local function usable(category: string, option): boolean
		return Avatar.usable(category, option, meta().cosmetics, recordSet())
	end
	local function recordName(id: string): string
		for _, r in meta().records or {} do
			if r.id == id then
				return r.name
			end
		end
		return id
	end
	local function ensureLook()
		local p = pack()
		if not look and p then
			look = Avatar.sanitize(p, meta().lastLook or {}, usable)
		end
	end
	local function showFigure(bump: boolean?)
		if figure and look then
			local mode = modeOf(ctx, modeId)
			figure:set({ look = look, age = 24, form = (mode and mode.form) or "human", sanity = 10 })
			if bump then
				pulse(figureScale)
			end
		end
	end
	local function glowName(): string
		return (ctx.info and ctx.info.meta and ctx.info.meta.glowName) or "Light"
	end
	-- a locked piece: unlock it with Light, earn its Record, or find it in the store
	local function tryLocked(category: string, option, after)
		if option.record then
			ctx.toast("Earn the " .. recordName(option.record) .. " record to unlock " .. option.name .. ".")
		elseif option.store then
			ctx.toast(option.name .. " is in the Store.")
		elseif (meta().glow or 0) >= (option.glow or 0) then
			ctx.prompt({
				title = "Unlock " .. option.name .. "?",
				text = string.format("Spend %d %s. It stays unlocked for every life.", option.glow or 0, glowName()),
				buttons = {
					{ label = "Not now", style = "ghost" },
					{ label = "Unlock", style = "primary", onClick = function()
						ctx.actions.unlockCosmetic(category, option.id, function()
							look[category] = option.id
							if after then
								after()
							end
						end)
					end },
				},
			})
		else
			ctx.toast(string.format("%s needs %d %s.", option.name, option.glow or 0, glowName()))
		end
	end

	local function randomLook()
		local cos = cosmetics()
		ensureLook()
		for _, category in (cos and cos.order) or {} do
			local choices = {}
			for _, option in cos[category].options do
				if usable(category, option) and not (category == "weapon" and ctx.info and ctx.info.creatorWeapons == false) then
					table.insert(choices, option.id)
				end
			end
			if #choices > 0 then
				look[category] = choices[math.random(1, #choices)]
			end
		end
	end

	-- ── the stage ───────────────────────────────────────────────────────────
	local function buildStage()
		clear(stage)
		local mode = modeOf(ctx, modeId)
		local glowColor = if mode and mode.color then Theme.rgb(mode.color) else C.accent
		-- a pool of light under the figure, and a soft beam from above
		new("Frame", {
			BackgroundColor3 = glowColor,
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.new(1, 0, 0.6, 0),
			Parent = stage,
		}, {
			new("UIGradient", { Rotation = 270, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1) }) }),
		})
		new("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.93,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(0.5, 0, 1, 0),
			Parent = stage,
		}, {
			new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.8, 1), NumberSequenceKeypoint.new(1, 1) }) }),
		})
		local holder = new("Frame", { Name = "Figure", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -44), Parent = stage })
		figureScale = new("UIScale", { Parent = holder })
		figure = AvatarView.new(ctx, { size = UDim2.fromScale(1, 1), framing = "full", spin = true, chart = true, background = C.panelLo })
		figure.frame.BackgroundTransparency = 1
		figure.frame.Parent = holder
		showFigure()
		Kit.button({
			name = "RandomLook",
			text = "Random",
			style = "ghost",
			size = UDim2.fromOffset(84, 28),
			position = UDim2.new(1, -8, 0, 8),
			anchor = Vector2.new(1, 0),
			textSize = 12,
			onClick = function()
				randomLook()
				sfx("reroll")
				showFigure(true)
				if tab ~= "looks" and tab ~= "sins" then
					fillOptions()
				end
			end,
		}).Parent = stage
		-- the name, written on the stage
		local box: any = new("TextBox", {
			Name = "FirstName",
			BackgroundColor3 = C.panel,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -8),
			Size = UDim2.new(1, -16, 0, 34),
			Text = typed,
			PlaceholderText = "Name (blank for a random one)",
			PlaceholderColor3 = C.faint,
			ClearTextOnFocus = false,
			FontFace = F.display,
			TextSize = 16,
			TextColor3 = C.text,
			Parent = stage,
		}, { Kit.corner(2), Kit.padding(0, 10, 0, 10), Kit.stroke(C.stroke, 1, 0.3) })
		box:GetPropertyChangedSignal("Text"):Connect(function()
			if #box.Text > 20 then
				box.Text = string.sub(box.Text, 1, 20)
			end
			typed = box.Text
		end)
	end

	-- ── the tabs ────────────────────────────────────────────────────────────
	local function visibleTabs()
		local list = {}
		local cos = cosmetics()
		for _, t in TABS do
			local show = false
			if t.id == "looks" then
				show = cos ~= nil and cos.identities ~= nil and #cos.identities > 0
			elseif t.id == "sins" then
				show = (ctx.info and ctx.info.affinities and #ctx.info.affinities > 0) or ctx.state.talent ~= nil
			elseif t.id == "when" then
				-- the age you're born into, unless the mode fixes it (or a lobby's host has)
				local mode = modeOf(ctx, modeId)
				show = ctx.info ~= nil and ctx.info.eras ~= nil and #ctx.info.eras > 1 and not (mode and mode.era) and not ctx.state.together
			elseif t.id == "weapon" and ctx.info and ctx.info.creatorWeapons == false then
				show = false -- weapons are found, bought or issued in a life
			else
				for _, category in t.categories or {} do
					if cos and cos[category] then
						show = true
					end
				end
			end
			if show then
				table.insert(list, t)
			end
		end
		return list
	end

	local function paintTabs()
		for id, b in tabButtons do
			local on = id == tab
			b.button.TextColor3 = if on then C.text else C.faint
			Kit.tween(b.bar, 0.2, { Size = UDim2.new(if on then 1 else 0, 0, 0, 3) }, Enum.EasingStyle.Quart)
		end
	end

	local function buildTabs()
		clear(tabsBar)
		tabButtons = {}
		for i, t in visibleTabs() do
			local b = new("TextButton", {
				Name = "Tab_" .. t.id,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = string.upper(if t.id == "sins" and ctx.info and ctx.info.affinityPick == false then "Talent" else t.name),
				FontFace = F.display,
				TextSize = 14,
				TextColor3 = C.faint,
				LayoutOrder = i,
				Parent = tabsBar,
			}, { Kit.padding(0, 10, 0, 10) })
			local bar = new("Frame", {
				Name = "Underline",
				BackgroundColor3 = if t.id == "sins" then C.crimsonHi else C.accentHi,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, 0),
				Size = UDim2.new(0, 0, 0, 3),
				Parent = b,
			})
			tabButtons[t.id] = { button = b, bar = bar }
			b.Activated:Connect(function()
				if tab ~= t.id then
					tab = t.id
					sfx("tab")
					paintTabs()
					fillOptions()
				end
			end)
		end
		paintTabs()
	end

	-- ── what's in each tab ──────────────────────────────────────────────────
	local function heading(text: string, order: number)
		Kit.caps({ Text = text, FontFace = F.displayMed, TextSize = 12, TextColor3 = C.sub, LayoutOrder = order, Parent = options })
	end

	local function grid(order: number, cell: UDim2)
		return new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, Parent = options }, {
			new("UIGridLayout", { CellSize = cell, CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
	end

	local function fillLooks()
		local cos = cosmetics()
		if not (cos and cos.identities) then
			return
		end
		local g = grid(1, UDim2.fromOffset(if wide then 104 else 96, if wide then 132 else 124))
		for i, ident in cos.identities do
			local card = new("TextButton", {
				Name = "Identity_" .. ident.id,
				AutoButtonColor = false,
				BackgroundColor3 = C.panelLo,
				BorderSizePixel = 0,
				Text = "",
				LayoutOrder = i,
				Parent = g,
			}, { Kit.corner(2) })
			Kit.stroke(C.stroke, 1, 0.3).Parent = card
			local scale = popIn(card, i)
			-- the card shows the whole look; picking it gives you the pieces you have
			local identLook = table.clone(look or {})
			local fullLook = table.clone(look or {})
			local lockedParts = {}
			for category, id in ident.look do
				local option = Avatar.option(pack(), category, id)
				if option then
					fullLook[category] = id
				end
				if option and usable(category, option) then
					identLook[category] = id
				elseif option then
					table.insert(lockedParts, option.name)
				end
			end
			local portrait = AvatarView.new(ctx, { size = UDim2.new(1, -8, 1, -34), position = UDim2.fromOffset(4, 4), framing = "portrait", background = C.panel })
			portrait.frame.Parent = card
			portrait:set({ look = fullLook, age = 24, form = "human", sanity = 10 })
			if #lockedParts > 0 then
				local badge = Emblem.make("misc.lock", 16, C.accentHi)
				badge.AnchorPoint = Vector2.new(1, 0)
				badge.Position = UDim2.new(1, -6, 0, 6)
				badge.ZIndex = 4
				badge.Parent = card
				Kit.raise(badge, 4)
			end
			new("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 4, 1, -4),
				Size = UDim2.new(1, -8, 0, 26),
				Text = string.upper(Format.escape(ident.name)),
				TextWrapped = true,
				FontFace = F.displayMed,
				TextSize = 11,
				TextColor3 = C.text,
				Parent = card,
			})
			card.Activated:Connect(function()
				look = identLook
				sfx("click")
				pulse(scale)
				if #lockedParts > 0 then
					ctx.toast("Not unlocked yet: " .. table.concat(lockedParts, ", ") .. ". Find them in the tabs (Light, Records or the Store).")
				end
				showFigure(true)
			end)
		end
	end

	local function fillCategories(def)
		local cos = cosmetics()
		if not cos then
			return
		end
		local order = 0
		for _, category in def.categories or {} do
			local cat = cos[category]
			if cat then
				order += 1
				heading(cat.name or category, order)
				order += 1
				local swatch = SWATCH[category] == true and cat.options[1] ~= nil and cat.options[1].color ~= nil
				local cell = if swatch then UDim2.fromOffset(40, 40) else UDim2.new(if wide then 1 / 3 else 0.5, -6, 0, 44)
				local g = grid(order, cell)
				for i, option in cat.options do
					if option.uniform then
						continue -- issued by an organisation when you join it
					end
					local ok = usable(category, option)
					local on = look[category] == option.id
					local lockText = if ok then nil elseif option.record then "RECORD" elseif option.store then "STORE" else string.format("%d %s", option.glow or 0, string.upper(glowName()))
					local btn
					if swatch then
						btn = new("TextButton", {
							Name = "LookOption",
							AutoButtonColor = false,
							BackgroundColor3 = Theme.rgb(option.color),
							BorderSizePixel = 0,
							Text = if ok then "" else "LOCK",
							FontFace = F.display,
							TextSize = 9,
							TextColor3 = C.text,
							TextStrokeTransparency = 0.3,
							LayoutOrder = i,
							Parent = g,
						}, { Kit.corner(20) })
					else
						btn = new("TextButton", {
							Name = "LookOption",
							AutoButtonColor = false,
							BackgroundColor3 = if on then C.panelHi else C.panelLo,
							BorderSizePixel = 0,
							Text = string.upper(Format.escape(option.name)) .. (if lockText then "\n" .. Format.color(lockText, C.faint) else ""),
							RichText = true,
							TextWrapped = true,
							FontFace = F.displayMed,
							TextSize = if lockText then 11 else 12,
							TextColor3 = if ok then C.text else C.sub,
							LayoutOrder = i,
							Parent = g,
						}, { Kit.corner(2), Kit.padding(0, 8, 0, 8) })
						if option.color and not swatch then
							new("Frame", { BackgroundColor3 = Theme.rgb(option.color), BorderSizePixel = 0, Size = UDim2.new(0, 3, 1, 0), Position = UDim2.fromOffset(-8, 0), Parent = btn })
						end
					end
					local st = Kit.stroke(if on then C.accentHi else C.stroke, if on then 2 else 1, if on then 0 else 0.35)
					st.Parent = btn
					local scale = popIn(btn, i)
					btn.Activated:Connect(function()
						if ok then
							look[category] = option.id
							sfx("click")
							pulse(scale)
							showFigure(true)
							fillOptions()
						else
							tryLocked(category, option, fillOptions)
						end
					end)
				end
			end
		end
	end

	local function fillSins()
		local affinities = (ctx.info and ctx.info.affinities) or {}
		local st = ctx.state.talent
		local picked = table.clone((st and st.affinities) or {})
		local order = 0
		if ctx.info and ctx.info.affinityPick == false then
			affinities = {}
			order += 1
			Kit.text({
				Text = "You don't pick what you're born with. The City deals every child a talent and two sins; you find out what they're worth by living.",
				FontFace = F.serifItalic,
				TextSize = 13,
				TextColor3 = C.sub,
				LayoutOrder = order,
				Parent = options,
			})
		end
		if #affinities > 0 then
			order += 1
			heading(string.format("Lean toward two sins · their talents %dx as likely", (st and st.affinityWeight) or 3), order)
			order += 1
			local g = grid(order, UDim2.new(if wide then 1 / 2 else 0.5, -4, 0, 58))
			local cards = {}
			local function paint()
				for id, c in cards do
					local on = table.find(picked, id) ~= nil
					c.stroke.Color = if on then c.color else C.stroke
					c.stroke.Thickness = if on then 2 else 1
					c.stroke.Transparency = if on then 0 else 0.4
					c.button.BackgroundColor3 = if on then C.panelHi:Lerp(c.color, 0.22) else C.panelLo
					c.check.Visible = on
				end
			end
			for i, a in affinities do
				local color = Theme.rgb(a.color)
				local b = new("TextButton", {
					Name = "Sin_" .. a.id,
					AutoButtonColor = false,
					BackgroundColor3 = C.panelLo,
					BorderSizePixel = 0,
					Text = "",
					LayoutOrder = i,
					Parent = g,
				}, { Kit.corner(2) })
				local stroke = Kit.stroke(C.stroke, 1, 0.4)
				stroke.Parent = b
				local scale = popIn(b, i)
				new("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.new(0, 4, 1, 0), Parent = b })
				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(14, 6),
					Size = UDim2.new(1, -40, 0, 22),
					Text = string.upper(Format.escape(a.name)),
					FontFace = F.display,
					TextSize = 17,
					TextColor3 = color,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = b,
				})
				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(14, 28),
					Size = UDim2.new(1, -20, 0, 24),
					Text = Format.escape(a.desc or ""),
					TextWrapped = true,
					TextTruncate = Enum.TextTruncate.AtEnd,
					FontFace = F.serif,
					TextSize = 11,
					TextColor3 = C.sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					Parent = b,
				})
				local check = new("TextLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -8, 0, 6),
					Size = UDim2.fromOffset(20, 20),
					Text = "✓",
					FontFace = F.display,
					TextSize = 16,
					TextColor3 = color,
					Visible = false,
					Parent = b,
				})
				cards[a.id] = { button = b, stroke = stroke, color = color, check = check }
				b.Activated:Connect(function()
					local at = table.find(picked, a.id)
					if at then
						table.remove(picked, at)
						sfx("click")
					else
						if #picked >= 2 then
							table.remove(picked, 1)
						end
						table.insert(picked, a.id)
						sfx("resonance")
					end
					pulse(scale)
					paint()
					ctx.actions.setAffinities(table.clone(picked), function()
						if talentCard then
							talentCard.refresh()
						end
					end)
				end)
			end
			paint()
		end
		if ctx.state.talent then
			order += 1
			heading("Your talent", order)
			order += 1
			talentCard = Talent.card(ctx, options, order)
		end
	end

	-- When: the age you're born into. Everything in the life follows it.
	local function fillWhen()
		local eras = (ctx.info and ctx.info.eras) or {}
		Kit.text({
			Text = "The City has a history, and a life only sees the part it's born into. Whatever you pick, the factions, the jobs and the dangers follow it.",
			FontFace = F.serifItalic,
			TextSize = 13,
			TextColor3 = C.sub,
			LayoutOrder = 1,
			Parent = options,
		})
		local list = {}
		if ctx.info and ctx.info.rollEra then
			table.insert(list, { id = nil, name = "Let the City decide", years = "Any age", desc = "Be born whenever the City likes. Most people don't get a say.", has = {} })
		end
		for _, e in eras do
			table.insert(list, e)
		end
		for i, e in list do
			local on = eraPick == e.id
			local b = new("TextButton", {
				Name = "Era_" .. tostring(e.id or "any"),
				AutoButtonColor = false,
				BackgroundColor3 = if on then C.panelHi else C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Text = "",
				LayoutOrder = 1 + i,
				Parent = options,
			}, { Kit.corner(2), Kit.padding(10, 12, 10, 14), Kit.list(4) })
			Kit.stroke(if on then C.accentHi else C.stroke, if on then 2 else 1, if on then 0 else 0.35).Parent = b
			local scale = popIn(b, i)
			Kit.text({
				Text = Format.color(string.upper(Format.escape(e.name)), if on then C.accentHi else C.text) .. "   " .. Format.color(string.upper(Format.escape(e.years or "")), C.faint),
				FontFace = F.display,
				TextSize = 16,
				LayoutOrder = 1,
				Parent = b,
			})
			Kit.text({ Text = Format.escape(e.desc or ""), FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 2, Parent = b })
			if e.has and #e.has > 0 then
				local parts = {}
				for _, h in e.has do
					table.insert(parts, string.upper(Format.escape(h)))
				end
				Kit.text({ Text = table.concat(parts, "   ·   "), FontFace = F.displayMed, TextSize = 11, TextColor3 = if on then C.accentHi else C.faint, LayoutOrder = 3, Parent = b })
			end
			b.Activated:Connect(function()
				eraPick = e.id
				sfx("click")
				pulse(scale)
				fillOptions()
			end)
		end
	end

	function fillOptions()
		clear(options)
		talentCard = nil
		ensureLook()
		if tab == "looks" then
			fillLooks()
		elseif tab == "when" then
			fillWhen()
		elseif tab == "sins" then
			fillSins()
		else
			for _, t in TABS do
				if t.id == tab then
					fillCategories(t)
				end
			end
		end
		options.CanvasPosition = Vector2.new(0, 0)
	end

	-- ── the footer: your talent, and BE BORN ────────────────────────────────
	local function paintTalent()
		if not talentChip then
			return
		end
		local t = ctx.state.talent and ctx.state.talent.talent
		if t then
			local color = if t.color then Theme.rgb(t.color) else C.accentHi
			talentChip.Text = Format.color("TALENT  ", C.faint) .. Format.color(string.upper(Format.escape(t.name)), color) .. "\n" .. Format.color(string.upper(Format.escape(t.tierName or "")), color)
			talentChip.Visible = true
		else
			talentChip.Visible = false
		end
	end

	local function begin()
		local choices = { traits = {}, style = nil, alloc = nil, era = eraPick }
		if not (ctx.info and ctx.info.rollEra) and eraPick == nil then
			for _, e in (ctx.info and ctx.info.eras) or {} do
				if e.default then
					choices.era = e.id
				end
			end
		end
		ensureLook()
		-- packs that still pick a family: the first one you have (the long creator picks properly)
		local origin = nil
		if ctx.info and ctx.info.creatorPicks then
			for _, o in meta().origins or {} do
				if o.unlocked and origin == nil then
					origin = o.id
				end
			end
		end
		sfx("confirm")
		if ctx.state.together then
			ctx.actions.togetherReady(origin, typed, nil, look, choices)
		else
			ctx.actions.newLife(origin, typed, nil, look, choices)
		end
	end

	local function buildFooter()
		clear(footer)
		new("Frame", { BackgroundColor3 = C.stroke, BorderSizePixel = 0, Size = UDim2.new(1, 28, 0, 1), Position = UDim2.fromOffset(-14, -12), Parent = footer })
		talentChip = new("TextButton", {
			Name = "TalentChip",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.5, -8, 1, 0),
			Text = "",
			RichText = true,
			TextWrapped = true,
			FontFace = F.display,
			TextSize = 14,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = footer,
		})
		talentChip.Activated:Connect(function()
			if tab ~= "sins" and tabButtons.sins then
				tab = "sins"
				sfx("tab")
				paintTabs()
				fillOptions()
			end
		end)
		paintTalent()
		bornBtn = Kit.button({
			name = "BeBorn",
			text = if ctx.state.together then "I'm ready" else "Be born",
			style = "primary",
			size = UDim2.new(0.5, -4, 1, 0),
			position = UDim2.new(1, 0, 0, 0),
			anchor = Vector2.new(1, 0),
			textSize = 20,
			onClick = begin,
		})
		bornBtn.Parent = footer
	end

	-- ── the header ──────────────────────────────────────────────────────────
	local function buildHeader()
		clear(header)
		local mode = modeOf(ctx, modeId)
		local color = if mode and mode.color then Theme.rgb(mode.color) else C.accentHi
		-- in a lobby: back to it, and the head says what its host has decided
		local lobby = if ctx.state.together then (ctx.state.crew and ctx.state.crew.lobby) else nil
		Kit.button({
			name = "Back",
			text = if lobby then "‹  Lobby" else "‹  Modes",
			style = "ghost",
			size = UDim2.new(0, 88, 0, 30),
			textSize = 12,
			onClick = function()
				sfx("click")
				if lobby then
					ctx.actions.openLobby()
				else
					ctx.actions.showMenu()
				end
			end,
		}).Parent = header
		local headText = if mode then mode.name else ((ctx.info and ctx.info.meta and ctx.info.meta.title) or "")
		if lobby then
			headText = Lobby.summary(ctx, lobby)
		end
		Kit.text({
			Name = "ModeName",
			Text = string.upper(Format.escape(headText)),
			FontFace = F.display,
			TextSize = 22,
			TextColor3 = color,
			Position = UDim2.fromOffset(100, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			Size = UDim2.new(1, -100 - (if ctx.info and ctx.info.creatorPicks then 96 else 0), 0, 30),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		-- packs where you still pick a family and a build keep the long creator
		if ctx.info and ctx.info.creatorPicks then
			Kit.button({
				name = "QuickLeft",
				text = "More",
				style = "secondary",
				size = UDim2.new(0, 86, 0, 30),
				position = UDim2.new(1, 0, 0, 0),
				anchor = Vector2.new(1, 0),
				textSize = 12,
				onClick = function()
					ctx.actions.showNewLife()
				end,
			}).Parent = header
		end
	end

	-- ── wide or narrow ──────────────────────────────────────────────────────
	local function arrange()
		local w = panel.AbsoluteSize.X
		local nowWide = w >= WIDE_AT
		wide = nowWide
		if nowWide then
			stage.Position = UDim2.fromOffset(0, 0)
			stage.Size = UDim2.new(0.42, -6, 1, 0)
			chooser.Position = UDim2.new(0.42, 10, 0, 0)
			chooser.Size = UDim2.new(0.58, -10, 1, 0)
		else
			stage.Position = UDim2.fromOffset(0, 0)
			stage.Size = UDim2.new(1, 0, 0, 230)
			chooser.Position = UDim2.fromOffset(0, 238)
			chooser.Size = UDim2.new(1, 0, 1, -238)
		end
	end
	panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local before = wide
		arrange()
		if before ~= wide and frame.Visible then
			fillOptions()
		end
	end)

	local function render()
		widen()
		arrange()
		buildHeader()
		-- (the look first: the stage draws it, whichever tab the creator opens on)
		ensureLook()
		buildStage()
		buildTabs()
		if not tabButtons[tab] then
			local first = visibleTabs()[1]
			tab = if first then first.id else "looks"
			paintTabs()
		end
		buildFooter()
		fillOptions()
		-- a small entrance: the stage rises, the chooser fades in
		stage.Position = stage.Position + UDim2.fromOffset(0, 16)
		Kit.tween(stage, 0.35, { Position = stage.Position - UDim2.fromOffset(0, 16) }, Enum.EasingStyle.Quart)
	end

	return {
		frame = frame,
		refresh = function(id: string?)
			modeId = id
			look = nil
			typed = ""
			if not tabButtons[tab] then
				tab = "looks"
			end
			render()
		end,
		refreshTalent = function()
			if talentCard then
				talentCard.refresh()
			end
			paintTalent()
		end,
		openTab = function(id: string)
			tab = id
			paintTabs()
			fillOptions()
		end,
		look = function()
			return look
		end,
	}
end

return QuickStart
