--[[
	THE LOBBY (v0.12): starting lives together. A whole screen, not a sheet.

		local lobby = Lobby.show(ctx, parent, opts)   -> { frame, destroy() }
		opts = { wide, canvasHeight, crew, players, hasLife, animate }

	Left (top, on a phone): WHO'S IN. Every seat shows the character its player has made, or
	that they're still choosing; the players on this server can be asked in with one tap.
	Right (below): what the HOST has decided: the age everyone is born into, the District,
	the side of the wall, how hard the City is, how everyone begins. The host gets the
	pickers. Everyone else sees the same settings as a short locked list.
	Bottom, always on screen: MAKE MY CHARACTER, how many are ready, and (the host) START.

	The server checks every setting and who sent it (server/Crews.luau): this screen only asks.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local AvatarView = require(script.Parent.AvatarView)
local Emblem = require(script.Parent.Emblem)
local Tip = require(script.Parent.Tip)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Lobby = {}

local FOOT = 76
local SEAT_H = 66
local ROW_BG = Color3.fromRGB(27, 30, 37)

local function heading(parent: Instance, text: string, order: number, color: Color3?, right: string?)
	local row = new("Frame", { Name = "Heading", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = order, ZIndex = 3, Parent = parent })
	new("Frame", { BackgroundColor3 = color or C.accent, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(3, 14), ZIndex = 3, Parent = row })
	Kit.caps({ Text = text, FontFace = F.display, TextSize = 14, TextColor3 = color or C.accentHi, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -10, 1, 0), ZIndex = 3, Parent = row })
	if right then
		Kit.caps({ Text = right, FontFace = F.displayMed, TextSize = 12, TextColor3 = C.faint, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 1, 0), ZIndex = 3, Parent = row })
	end
	return row
end

-- a small tag: HOST, YOU, READY
local function tag(parent: Instance, text: string, color: Color3, order: number)
	return new("TextLabel", {
		Name = "Tag",
		BackgroundColor3 = color,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = text,
		FontFace = F.display,
		TextSize = 12,
		TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.3),
		LayoutOrder = order,
		ZIndex = 4,
		Parent = parent,
	}, { Kit.corner(3), Kit.padding(0, 7, 0, 7) })
end

local function byId(list, id)
	for _, x in list or {} do
		if x.id == id then
			return x
		end
	end
	return nil
end

-- ── a seat ────────────────────────────────────────────────────────────────
local function seat(ctx, parent: Instance, order: number, m, crew, opts)
	local me = m.userId == opts.userId
	local key = tostring(m.userId)
	local together = crew.together
	local ready = together ~= nil and together.ready ~= nil and together.ready[key] == true
	local made = together and together.made and together.made[key]
	local edge = if m.leader then C.accent elseif ready then C.good else C.strokeHi
	local card = new("Frame", {
		Name = "Seat",
		BackgroundColor3 = ROW_BG,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, SEAT_H),
		LayoutOrder = order,
		ZIndex = 3,
		Parent = parent,
	}, { Kit.corner(5), Kit.depth(nil :: any, true), Kit.stroke(edge, 1, if ready or m.leader then 0.35 else 0.6) })
	card:SetAttribute("UserId", m.userId)
	card:SetAttribute("Ready", ready)
	Kit.edge(card, edge, 3)

	-- the face: the character they made, the life they're living, or nobody yet
	local face = new("Frame", { Name = "Face", BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Position = UDim2.fromOffset(10, 6), Size = UDim2.fromOffset(50, 54), ClipsDescendants = true, ZIndex = 3, Parent = card }, { Kit.corner(4) })
	local look = made and made.look
	local appearance = if look then { look = look, age = 20, form = "human", sanity = 0 } elseif m.character and m.character.appearance then m.character.appearance else nil
	if appearance then
		local view = AvatarView.new(ctx, { size = UDim2.fromScale(1, 1), framing = "portrait", background = false, zIndex = 4 })
		view.frame.Parent = face
		view:set(appearance)
		if not look then
			-- (the life they're living now, not the one they'll start: shown dimmer)
			new("Frame", { BackgroundColor3 = C.panelLo, BackgroundTransparency = 0.45, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = face })
		end
	else
		local icon = Emblem.make("tab.you", 26, C.faint)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.ZIndex = 4
		icon.Parent = face
	end

	local kick = opts.host and not me
	local textW = -72 - (if kick then 118 else 84)
	local nameRow = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(70, 9), Size = UDim2.new(1, textW, 0, 22), ZIndex = 3, Parent = card }, {
		Kit.list(6, Enum.FillDirection.Horizontal, nil, Enum.VerticalAlignment.Center),
	})
	new("TextLabel", {
		Name = "Name",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = Format.escape(m.name or "Someone"),
		FontFace = F.display,
		TextSize = 17,
		TextColor3 = C.text,
		LayoutOrder = 1,
		ZIndex = 3,
		Parent = nameRow,
	})
	if m.leader then
		tag(nameRow, "HOST", C.accentHi, 2)
	end
	if me then
		tag(nameRow, "YOU", C.strange, 3)
	end
	local what
	if made and made.first then
		what = "as " .. Format.color(Format.escape(made.first), C.text)
	elseif ready then
		what = "Character made"
	elseif m.character and m.character.alive then
		what = "Still choosing  ·  living as " .. Format.escape(m.character.first or "")
	else
		what = "Still choosing"
	end
	Kit.text({ Name = "What", Text = what, FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, Position = UDim2.fromOffset(70, 35), Size = UDim2.new(1, textW, 0, 18), AutomaticSize = Enum.AutomaticSize.None, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = card })

	-- ready, or not
	local state = new("TextLabel", {
		Name = "State",
		BackgroundColor3 = if ready then C.good else C.panelLo,
		BackgroundTransparency = if ready then 0.8 else 0.2,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, if kick then -46 else -12, 0.5, 0),
		Size = UDim2.fromOffset(72, 24),
		Text = if ready then "READY" else "NOT YET",
		FontFace = F.display,
		TextSize = 13,
		TextColor3 = if ready then C.good:Lerp(Color3.new(1, 1, 1), 0.25) else C.faint,
		ZIndex = 3,
		Parent = card,
	}, { Kit.corner(4) })
	if not ready then
		Kit.stroke(C.stroke, 1, 0.3).Parent = state
	end
	if kick then
		local b = Kit.button({
			name = "Kick",
			text = "X",
			style = "ghost",
			size = UDim2.fromOffset(28, 28),
			position = UDim2.new(1, -10, 0.5, 0),
			anchor = Vector2.new(1, 0.5),
			textSize = 12,
			zIndex = 4,
			onClick = function()
				ctx.actions.crewCall("crewKick", { userId = m.userId }, opts.refresh)
			end,
		})
		b.Parent = card
		Tip.attach(b, "Take them out of the lobby", nil)
	end
	return card
end

-- the seats nobody has taken yet, as one row
local function openSeat(parent: Instance, order: number, count: number)
	local card = new("Frame", {
		Name = "OpenSeat",
		BackgroundColor3 = C.panelLo,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 44),
		LayoutOrder = order,
		ZIndex = 3,
		Parent = parent,
	}, { Kit.corner(5), Kit.stroke(C.stroke, 1, 0.45) })
	Kit.caps({ Text = if count == 1 then "1 open seat" else tostring(count) .. " open seats", FontFace = F.displayMed, TextSize = 13, TextColor3 = C.faint, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = card })
	return card
end

-- ── the host's pickers ──────────────────────────────────────────────────────
-- options = { { id, title, sub, tip, color, locked } }; `current` is the id that's on (nil = the
-- first option, when that one's id is nil)
local function picker(ctx, parent: Instance, order: number, spec)
	local perRow = math.max(1, spec.perRow or 3)
	local rows = math.ceil(#spec.options / perRow)
	local cellH = spec.cellH or 46
	local grid = new("Frame", {
		Name = "Picker_" .. spec.key,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, rows * cellH + (rows - 1) * 6),
		LayoutOrder = order,
		ZIndex = 3,
		Parent = parent,
	}, {
		-- (a pixel of slack in every cell: a row that adds up to exactly the width can wrap)
		new("UIGridLayout", { CellSize = UDim2.new(1 / perRow, -math.ceil(6 * (perRow - 1) / perRow) - 1, 0, cellH), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	for i, o in spec.options do
		local on = o.id == spec.current
		local usable = spec.enabled ~= false and not o.locked and not o.fixed
		local tint = o.color or C.accent
		local b: any = new("TextButton", {
			Name = "Option",
			AutoButtonColor = false,
			BackgroundColor3 = if on then tint:Lerp(Color3.new(0, 0, 0), 0.72) else ROW_BG,
			BackgroundTransparency = if usable or on then 0 else 0.45,
			BorderSizePixel = 0,
			Text = "",
			LayoutOrder = i,
			ZIndex = 3,
			Parent = grid,
		}, { Kit.corner(5), Kit.stroke(if on then tint:Lerp(Color3.new(1, 1, 1), 0.25) else C.stroke, if on then 2 else 1, if on then 0 else 0.45) })
		b:SetAttribute("Key", spec.key)
		b:SetAttribute("Value", if o.id == nil then "any" else o.id)
		b:SetAttribute("On", on)
		local dim = if usable or on then 0 else 0.45
		new("TextLabel", {
			Name = "Title",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(9, if o.sub then 6 else 0),
			Size = UDim2.new(1, -18, 0, if o.sub then 18 else cellH),
			Text = string.upper(Format.escape(o.title or "")),
			FontFace = F.display,
			TextSize = spec.titleSize or 14,
			TextColor3 = if on then tint:Lerp(Color3.new(1, 1, 1), 0.55) else C.text,
			TextTransparency = dim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 4,
			Parent = b,
		})
		if o.sub then
			new("TextLabel", {
				Name = "Sub",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(9, 24),
				Size = UDim2.new(1, -18, 0, 15),
				Text = string.upper(Format.escape(if o.locked then "Locked" else o.sub)),
				FontFace = F.displayMed,
				TextSize = 11,
				TextColor3 = if o.locked then C.crimsonHi else C.faint,
				TextTransparency = dim * 0.6,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 4,
				Parent = b,
			})
		end
		if on then
			local mark = Emblem.make("misc.check", 12, tint:Lerp(Color3.new(1, 1, 1), 0.4))
			mark.AnchorPoint = Vector2.new(1, 0)
			mark.Position = UDim2.new(1, -6, 0, 6)
			mark.ZIndex = 4
			mark.Parent = b
		end
		if o.tip then
			Tip.attach(b, o.title, o.tip)
		end
		if usable and not on then
			local rest = b.BackgroundColor3
			b.MouseEnter:Connect(function()
				b.BackgroundColor3 = rest:Lerp(Color3.new(1, 1, 1), 0.07)
			end)
			b.MouseLeave:Connect(function()
				b.BackgroundColor3 = rest
			end)
			b.Activated:Connect(function()
				if ctx.sfx then
					ctx.sfx("click")
				end
				spec.onPick(o.id)
			end)
		end
	end
	return grid
end

-- what a setting says when it's the City's to decide
local function eraName(info, id: string?): string
	local e = byId(info.eras, id)
	return if e then e.name else "The City decides"
end
local function districtName(info, id: string?): string
	local d = byId(info.city and info.city.districts, id)
	return if d then d.name else "The City decides"
end
local function sideName(info, id: string?): string
	local s = byId(info.city and info.city.sides, id)
	return if s then (s.name or id) else "Either side"
end
local function difficultyName(info, id: string?): string
	local d = byId(info.difficulties and info.difficulties.list, id)
	return if d then d.name else "As it is"
end
local function modeName(info, id: string?): string
	local m = byId(info.modes, id)
	return if m then m.name else "From birth"
end

-- the settings as one line (the creator's header shows it too)
function Lobby.summary(ctx, lobby): string
	local info = ctx.info or {}
	if not lobby then
		return ""
	end
	local parts = { eraName(info, lobby.era), districtName(info, lobby.district) }
	if lobby.side then
		table.insert(parts, sideName(info, lobby.side))
	end
	return table.concat(parts, "  ·  ")
end

-- ── the screen ──────────────────────────────────────────────────────────────
function Lobby.show(ctx, parent: Instance, opts)
	local info = ctx.info or {}
	local crew = opts.crew
	local lobby = (crew and crew.lobby) or {}
	local wide = opts.wide == true
	local host = crew ~= nil and crew.captain == true
	local userId = opts.userId
	local word = (info.city and info.city.word) or "District"

	local root = new("Frame", { Name = "Lobby", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = parent })
	local body = new("ScrollingFrame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -FOOT - 8),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.accentLo,
		ZIndex = 3,
		Parent = root,
	}, { Kit.padding(if wide then 26 else 12, 8, 16, 8), Kit.list(14) })

	local colA: Instance, colB: Instance = body, body
	if wide then
		local cols = new("Frame", { Name = "Columns", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, ZIndex = 3, Parent = body }, {
			Kit.list(30, Enum.FillDirection.Horizontal),
		})
		colA = new("Frame", { Name = "Left", BackgroundTransparency = 1, Size = UDim2.new(0.4, -15, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, ZIndex = 3, Parent = cols }, { Kit.list(12) })
		colB = new("Frame", { Name = "Right", BackgroundTransparency = 1, Size = UDim2.new(0.6, -15, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 3, Parent = cols }, { Kit.list(12) })
	end
	local orderA, orderB = 0, 100
	local function nextA()
		orderA += 1
		return orderA
	end
	local function nextB()
		orderB += 1
		return orderB
	end

	-- ── the head ──
	local head = new("Frame", { Name = "Head", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextA(), ZIndex = 3, Parent = colA }, { Kit.list(2) })
	Kit.text({ Text = "WITH FRIENDS", FontFace = F.type, TextSize = if wide then 15 else 13, TextColor3 = C.crimsonHi, LayoutOrder = 1, ZIndex = 3, Parent = head })
	Kit.text({ Name = "Title", Text = "LOBBY", FontFace = F.display, TextSize = if wide then 54 else 38, LayoutOrder = 2, ZIndex = 3, Parent = head })
	Kit.text({
		Text = "The host sets the City. Everyone makes a character. Then you all begin in the same place, the same year, already friends.",
		FontFace = F.serifItalic,
		TextSize = if wide then 14 else 13,
		TextColor3 = C.sub,
		LayoutOrder = 3,
		ZIndex = 3,
		Parent = head,
	})

	if not crew then
		Kit.text({ Text = "Opening the lobby...", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, LayoutOrder = nextA(), ZIndex = 3, Parent = colA })
	end

	-- ── who's in ──
	local members = (crew and crew.members) or {}
	local readyCount = 0
	local hostName = "the host"
	for _, m in members do
		if crew.together and crew.together.ready and crew.together.ready[tostring(m.userId)] then
			readyCount += 1
		end
		if m.leader then
			hostName = m.name or hostName
		end
	end
	local seatOpts = { userId = userId, host = host, refresh = opts.refresh }
	if crew then
		heading(colA, "Who's in", nextA(), nil, string.format("%d of %d", #members, crew.max or 4))
		for _, m in members do
			seat(ctx, colA, nextA(), m, crew, seatOpts)
		end
		local free = (crew.max or 4) - #members
		if free > 0 then
			openSeat(colA, nextA(), free)
		end

		-- ── ask someone in ──
		local full = #members >= (crew.max or 4)
		if not full then
			heading(colA, "Ask someone in", nextA(), C.strange)
			local any = false
			for _, p in opts.players or {} do
				any = true
				local row = new("Frame", { Name = "Player", BackgroundColor3 = ROW_BG, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = nextA(), ZIndex = 3, Parent = colA }, { Kit.corner(5), Kit.depth(nil :: any, true) })
				new("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -116, 1, 0),
					Text = Format.escape(p.name or "Someone") .. (if p.inCrew then Format.color("   in another lobby", C.faint) else ""),
					RichText = true,
					FontFace = F.displayMed,
					TextSize = 15,
					TextColor3 = C.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 3,
					Parent = row,
				})
				Kit.button({
					name = "Invite",
					text = "Ask in",
					style = "secondary",
					size = UDim2.fromOffset(92, 28),
					position = UDim2.new(1, -8, 0.5, 0),
					anchor = Vector2.new(1, 0.5),
					textSize = 13,
					zIndex = 4,
					onClick = function()
						ctx.actions.crewCall("crewInvite", { userId = p.userId }, opts.refresh)
					end,
				}).Parent = row
			end
			if not any then
				Kit.text({ Text = "Nobody else is on this server yet.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextA(), ZIndex = 3, Parent = colA })
			end
			Kit.button({
				name = "InviteFriends",
				text = "Invite Roblox friends to this server",
				style = "ghost",
				size = UDim2.new(1, 0, 0, 36),
				order = nextA(),
				textSize = 13,
				zIndex = 3,
				onClick = function()
					ctx.actions.inviteFriends()
				end,
			}).Parent = colA
		end
	end

	-- ── what the host decides ──
	if crew then
		local panel = Kit.panel({ Name = "Settings", LayoutOrder = nextB(), ZIndex = 3, Parent = colB }, nil, C.accent)
		Kit.padding(14, 16, 16, 16).Parent = panel
		Kit.list(10).Parent = panel
		local o = 0
		local function nextO()
			o += 1
			return o
		end
		heading(panel, if host then "You decide" else Format.escape(hostName) .. " decides", nextO(), nil, if host then "You're the host" else "Locked")
		local mode = byId(info.modes, lobby.mode)
		local function set(key: string)
			return function(value)
				ctx.actions.lobbySet(key, if value == nil then "any" else value)
			end
		end
		if host then
			-- WHEN
			if info.eras and #info.eras > 1 then
				heading(panel, "When", nextO(), C.sub)
				local list = {}
				if info.rollEra then
					table.insert(list, { id = nil, title = "The City decides", sub = "Any age", tip = "Everyone is born into the same age. Which one is the City's business.", fixed = mode ~= nil and mode.era ~= nil })
				end
				for _, e in info.eras do
					table.insert(list, { id = e.id, title = e.name, sub = e.years, tip = e.desc, fixed = mode ~= nil and mode.era ~= nil and mode.era ~= e.id })
				end
				picker(ctx, panel, nextO(), { key = "era", options = list, current = lobby.era, perRow = if wide then 3 else 2, onPick = set("era") })
				if mode and mode.era then
					Kit.text({ Text = Format.escape(mode.name) .. " has its own age.", FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.faint, LayoutOrder = nextO(), ZIndex = 3, Parent = panel })
				end
			end
			-- WHERE
			local districts = (info.city and info.city.districts) or {}
			if #districts > 1 then
				heading(panel, "Where", nextO(), C.sub)
				local list = { { id = nil, title = "The City decides", sub = "Any " .. word } }
				for _, d in districts do
					table.insert(list, {
						id = d.id,
						title = if d.number then "D" .. tostring(d.number) else d.name,
						sub = d.corp or (if d.number then d.name else d.trade) or "",
						tip = d.desc,
						color = if d.color then Theme.rgb(d.color) else nil,
					})
				end
				picker(ctx, panel, nextO(), { key = "district", options = list, current = lobby.district, perRow = if wide then 5 else 3, onPick = set("district") })
			end
			local sides = (info.city and info.city.sides) or {}
			if #sides > 1 then
				heading(panel, "Side of the wall", nextO(), C.sub)
				local list = { { id = nil, title = "Either", sub = "Where each family lives" } }
				for _, s in sides do
					table.insert(list, { id = s.id, title = s.short or s.name, sub = nil, tip = s.desc, color = if s.color then Theme.rgb(s.color) else nil })
				end
				for _, item in list do
					item.sub = item.sub or "Everyone"
				end
				picker(ctx, panel, nextO(), { key = "side", options = list, current = lobby.side, perRow = 3, onPick = set("side") })
			end
			-- HOW HARD
			local diffs = (info.difficulties and info.difficulties.list) or {}
			if #diffs > 1 then
				heading(panel, "How hard", nextO(), C.sub)
				local list = {}
				for _, d in diffs do
					table.insert(list, { id = d.id, title = d.name, tip = d.desc, color = if d.color then Theme.rgb(d.color) else nil })
				end
				picker(ctx, panel, nextO(), { key = "difficulty", options = list, current = lobby.difficulty, perRow = if wide then 3 else 1, cellH = 38, onPick = set("difficulty") })
			end
			-- HOW YOU BEGIN
			if info.modes and #info.modes > 1 then
				heading(panel, "How you begin", nextO(), C.sub)
				local unlocked = (ctx.state.meta and ctx.state.meta.modes) or {}
				local list = {}
				for _, m in info.modes do
					if m.hidden then
						continue -- (v0.18) Fixer's Road is off the menus
					end
					table.insert(list, {
						id = m.id,
						title = m.name,
						sub = m.tagline or "",
						tip = m.desc,
						color = if m.color then Theme.rgb(m.color) else nil,
						locked = m.locked == true and unlocked[m.id] ~= true,
					})
				end
				picker(ctx, panel, nextO(), { key = "mode", options = list, current = lobby.mode, perRow = 2, onPick = set("mode") })
			end
			-- AGING
			heading(panel, "Years", nextO(), C.sub)
			picker(ctx, panel, nextO(), {
				key = "syncAge",
				options = {
					{ id = true, title = "Age up together", sub = "The year turns when all are ready" },
					{ id = false, title = "Each on their own", sub = "Everyone turns their own years" },
				},
				current = crew.syncAge ~= false,
				perRow = 2,
				onPick = function(value)
					ctx.actions.lobbySet("syncAge", value == true)
				end,
			})
		else
			-- everyone else: the same settings, as a short locked list
			local rows = {
				{ "When", eraName(info, lobby.era), "misc.year" },
				{ "Where", districtName(info, lobby.district), "tab.city" },
				{ "Side of the wall", sideName(info, lobby.side), "thread.district" },
				{ "How hard", difficultyName(info, lobby.difficulty), "misc.skull" },
				{ "How you begin", modeName(info, lobby.mode), "misc.star" },
				{ "Years", if crew.syncAge ~= false then "You age up together" else "Each on their own", "misc.clock" },
			}
			for _, r in rows do
				local row = new("Frame", { Name = "Setting", BackgroundColor3 = ROW_BG, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 46), LayoutOrder = nextO(), ZIndex = 3, Parent = panel }, { Kit.corner(5), Kit.depth(nil :: any, true) })
				local icon = Emblem.make(r[3], 18, C.accentHi)
				icon.AnchorPoint = Vector2.new(0, 0.5)
				icon.Position = UDim2.new(0, 12, 0.5, 0)
				icon.ZIndex = 4
				icon.Parent = row
				Kit.caps({ Text = r[1], FontFace = F.displayMed, TextSize = 11, TextColor3 = C.faint, Position = UDim2.fromOffset(40, 6), Size = UDim2.new(1, -52, 0, 14), ZIndex = 3, Parent = row })
				new("TextLabel", {
					Name = "Value",
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(40, 20),
					Size = UDim2.new(1, -52, 0, 20),
					Text = string.upper(Format.escape(r[2])),
					FontFace = F.display,
					TextSize = 16,
					TextColor3 = C.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 3,
					Parent = row,
				})
			end
			Kit.text({ Text = "Only the host can change these.", FontFace = F.serifItalic, TextSize = 12, TextColor3 = C.faint, LayoutOrder = nextO(), ZIndex = 3, Parent = panel })
		end
	end

	-- ── the foot: always on screen ──
	local foot = Kit.panel({
		Name = "Foot",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -6),
		Size = UDim2.new(1, -16, 0, FOOT),
		AutomaticSize = Enum.AutomaticSize.None,
		ZIndex = 5,
		Parent = root,
	}, nil, C.accent)
	Kit.padding(12, 12, 12, 12).Parent = foot
	local youReady = crew ~= nil and crew.together ~= nil and crew.together.youReady == true
	local everyone = crew ~= nil and crew.together ~= nil and crew.together.everyone == true
	local third = if wide then 0.3 else 0.5
	local make = Kit.button({
		name = "MakeTogether",
		text = if youReady then "Change my character" else "Make my character",
		style = if youReady then "secondary" else "primary",
		size = UDim2.new(third, -6, 1, 0),
		textSize = if wide then 17 else 14,
		zIndex = 6,
		enabled = crew ~= nil,
		onClick = function()
			ctx.actions.makeTogetherCharacter()
		end,
	})
	make.Parent = foot
	local status = string.format("%d of %d ready", readyCount, math.max(1, #members))
	if opts.hasLife then
		status ..= "\n" .. Format.color("Starting ends the life you're living.", C.crimsonHi)
	end
	if wide then
		Kit.text({
			Name = "Ready",
			Text = status,
			FontFace = F.display,
			TextSize = 15,
			TextColor3 = if everyone then C.good else C.sub,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(0.4, -12, 1, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			ZIndex = 6,
			Parent = foot,
		})
	end
	if host then
		local start = Kit.button({
			name = "StartTogether",
			text = if wide then "Start everyone's lives" else (if everyone then "Start" else status),
			style = if everyone then "primary" else "ghost",
			size = UDim2.new(third, -6, 1, 0),
			position = UDim2.new(1, 0, 0, 0),
			anchor = Vector2.new(1, 0),
			textSize = if wide then 17 else 14,
			zIndex = 6,
			enabled = everyone,
			onClick = function()
				ctx.actions.togetherStart()
			end,
		})
		start.Parent = foot
	else
		new("TextLabel", {
			Name = "Waiting",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(third, -6, 1, 0),
			Text = if everyone then "WAITING FOR " .. string.upper(Format.escape(hostName)) .. " TO START" else (if wide then "THE HOST STARTS WHEN ALL ARE READY" else string.upper(status)),
			RichText = true,
			TextWrapped = true,
			FontFace = F.displayMed,
			TextSize = 13,
			TextColor3 = if everyone then C.accentHi else C.faint,
			ZIndex = 6,
			Parent = foot,
		})
	end

	-- ── the ways out ──
	-- (a wide screen: a row above the settings. A phone: the top right corner, beside the title.)
	local outs
	if wide then
		outs = new("Frame", { Name = "Outs", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 100, ZIndex = 4, Parent = colB }, {
			Kit.list(8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right),
		})
	else
		outs = new("Frame", { Name = "Outs", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 12), Size = UDim2.fromOffset(176, 30), ZIndex = 6, Parent = root }, {
			Kit.list(8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right),
		})
	end
	if crew and #members > 1 then
		Kit.button({
			name = "LeaveLobby",
			text = "Leave",
			style = "ghost",
			size = UDim2.fromOffset(if wide then 96 else 76, 30),
			order = 1,
			textSize = 12,
			zIndex = 6,
			onClick = function()
				ctx.actions.leaveLobby()
			end,
		}).Parent = outs
	end
	Kit.button({
		name = "Back",
		text = "‹  Menu",
		style = "ghost",
		size = UDim2.fromOffset(if wide then 110 else 84, 30),
		order = 2,
		textSize = 12,
		zIndex = 6,
		onClick = function()
			ctx.actions.showMenu()
		end,
	}).Parent = outs

	if opts.animate then
		local sc = new("UIScale", { Scale = 0.96, Parent = body })
		Kit.tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Quart)
	end
	return {
		frame = root,
		destroy = function()
			root:Destroy()
		end,
	}
end

return Lobby
