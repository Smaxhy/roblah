--[[
	DUEL VIEW (v0.17): a duel between two players, in turns (Engine/Pvp.luau).

		local dv = DuelView.open(ctx, layer, { onAct = fn(action, approach), onGo = fn(), onClose = fn() })
		dv:set(view)      -- the duel as the server shows it to you (Pvp.view)
		dv:done(view)     -- the end: view.won, view.outcome
		dv:close()

	You on the left, them on the right: both figures, both Health bars (with the mark where a
	friendly duel stops), who has chosen. In the middle, what happened last turn. Below, your
	moves: every way of fighting you have (with its odds against their best, and its damage),
	Guard, Feint, Patch up and Yield. Effects play out every turn (UI/Vfx.luau).
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local AvatarView = require(script.Parent.AvatarView)
local Vfx = require(script.Parent.Vfx)
-- (v0.18) the duel on the real 3D stage, with real effects (the figures stay as the fallback)
local Arena = require(script.Parent.Arena)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local DuelView = {}
DuelView.__index = DuelView

local TONE = { good = C.good, danger = C.crimsonHi, muted = C.faint }

local ACTION_WORD = { strike = "strikes", guard = "guards", feint = "feints", recover = "patches up", yield = "yields" }
local YOUR_WORD = { strike = "strike", guard = "guard", feint = "feint", recover = "patch up", yield = "yield" }

local function pct(x: number?): string
	return if x then tostring(math.floor(x * 100 + 0.5)) .. "%" else "?"
end

local function bar(parent: Instance, z: number, color: Color3, height: number)
	local back = new("Frame", { Name = "Bar", BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, height), ZIndex = z, Parent = parent }, { Kit.corner(3), Kit.stroke(C.stroke, 1, 0.3) })
	local ghost = new("Frame", { Name = "Ghost", BackgroundColor3 = Color3.fromRGB(255, 240, 220), BackgroundTransparency = 0.4, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = z, Parent = back }, { Kit.corner(3) })
	local fill = new("Frame", { Name = "Fill", BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = z + 1, Parent = back }, { Kit.corner(3) })
	return back, fill, ghost
end

function DuelView.open(ctx, layer: Instance, handlers)
	local self = setmetatable({}, DuelView)
	self.ctx = ctx
	self.handlers = handlers or {}
	local Z = 80
	self.Z = Z
	local root = new("Frame", { Name = "DuelView", BackgroundColor3 = Color3.fromRGB(8, 8, 12), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = Z, Active = true, Parent = layer })
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(16, 20, 36), Color3.fromRGB(6, 6, 9)), Parent = root })
	self.root = root
	local wide = layer:IsA("GuiBase2d") and (layer :: any).AbsoluteSize.X >= 700 or false
	self.wide = wide
	local pad = if wide then 28 else 12
	local topInset = 46

	self.kicker = Kit.caps({ Name = "Kicker", Text = "Duel", TextColor3 = C.accentHi, Position = UDim2.fromOffset(pad, pad + topInset), Size = UDim2.new(1, -pad * 2, 0, 16), ZIndex = Z + 2, Parent = root })
	self.title = new("TextLabel", { Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(pad, pad + topInset + 18), Size = UDim2.new(1, -pad * 2, 0, 34), FontFace = F.display, TextSize = if wide then 30 else 22, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left, Text = "", ZIndex = Z + 2, Parent = root })

	-- the two sides
	local stageTop = pad + topInset + 60
	local stageH = if wide then 0.4 else 0.32
	local function sidePanel(name: string, xScale: number, align: Enum.TextXAlignment)
		local panel = new("Frame", { Name = name, BackgroundTransparency = 1, Position = UDim2.new(xScale, if xScale == 0 then pad else 0, 0, stageTop), Size = UDim2.new(0.5, -pad, stageH, 0), ZIndex = Z + 1, Parent = root })
		local figure = new("Frame", { Name = "Figure", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -48), ZIndex = Z + 1, Parent = panel })
		local nameLabel = new("TextLabel", { Name = "Name", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -24), Size = UDim2.new(1, 0, 0, 20), FontFace = F.uiBold, TextSize = if wide then 15 else 14, TextColor3 = C.text, TextXAlignment = align, TextTruncate = Enum.TextTruncate.AtEnd, Text = "", ZIndex = Z + 2, Parent = panel })
		local status = Kit.caps({ Name = "Status", Text = "", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -44), Size = UDim2.new(1, 0, 0, 14), TextSize = 11, TextColor3 = C.sub, TextXAlignment = align, ZIndex = Z + 2, Parent = panel })
		local holder = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -4), Size = UDim2.new(1, 0, 0, 14), ZIndex = Z + 2, Parent = panel })
		local _b, fill, ghost = bar(holder, Z + 2, if xScale == 0 then C.good else C.crimson, 12)
		-- (Health beside the name on a wide screen; on a phone, written on the bar itself)
		local hpText = new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = if wide then UDim2.new(0, if xScale == 0 then -24 else 24, 1, -24) else UDim2.new(0, 0, 1, -4),
			Size = if wide then UDim2.new(1, 0, 0, 20) else UDim2.new(1, 0, 0, 14),
			FontFace = F.mono,
			TextSize = if wide then 13 else 11,
			TextColor3 = if wide then C.sub else C.paperHi,
			TextStrokeTransparency = if wide then 1 else 0.5,
			TextXAlignment = if not wide then Enum.TextXAlignment.Center elseif align == Enum.TextXAlignment.Left then Enum.TextXAlignment.Right else Enum.TextXAlignment.Left,
			Text = "",
			ZIndex = Z + 5,
			Parent = panel,
		})
		return { panel = panel, figure = figure, name = nameLabel, status = status, fill = fill, ghost = ghost, holder = holder, hpText = hpText }
	end
	self.mine = sidePanel("Me", 0, Enum.TextXAlignment.Left)
	self.theirs = sidePanel("Them", 0.5, Enum.TextXAlignment.Right)

	-- what happened last turn, between them
	self.summary = new("TextLabel", { Name = "Summary", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, stageTop + 4), Size = UDim2.new(0.5, 0, 0, 44), FontFace = F.display, TextSize = if wide then 20 else 15, TextWrapped = true, TextColor3 = C.paperHi, Text = "", ZIndex = Z + 3, Parent = root })

	-- the log
	local logBox = new("Frame", { Name = "Log", BackgroundColor3 = C.panelLo, BackgroundTransparency = 0.25, BorderSizePixel = 0, Position = UDim2.new(0, pad, stageH, stageTop + 6), Size = UDim2.new(1, -pad * 2, 0, if wide then 74 else 60), ZIndex = Z + 1, Parent = root }, { Kit.corner(4), Kit.stroke(C.stroke, 1, 0.5), Kit.padding(6) })
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = logBox })
	self.logBox = logBox

	-- your moves
	local movesTop = stageTop + 6 + (if wide then 74 else 60) + 8
	local moves = new("ScrollingFrame", { Name = "Moves", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, pad, stageH, movesTop), Size = UDim2.new(1, -pad * 2, 1 - stageH, -movesTop - pad - 32), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ZIndex = Z + 1, Parent = root })
	new("UIGridLayout", { CellSize = UDim2.new(if wide then 0.24 else 0.48, -4, 0, if wide then 62 else 70), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = moves })
	self.moves = moves
	self.waiting = new("TextLabel", { Name = "Waiting", BackgroundTransparency = 1, Position = UDim2.new(0, pad, 1, -pad - 28), Size = UDim2.new(0.6, -pad, 0, 24), FontFace = F.serifItalic, TextSize = 15, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Left, Text = "", Visible = false, ZIndex = Z + 2, Parent = root })
	self.goHolder = new("Frame", { Name = "Go", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -pad, 1, -pad), Size = UDim2.fromOffset(170, 36), ZIndex = Z + 2, Parent = root })
	self.stageTop, self.stageH = stageTop, stageH
	return self
end

function DuelView:setFigure(side, key: string, appearance)
	if not appearance or side.key == key then
		return
	end
	side.key = key
	for _, c in side.figure:GetChildren() do
		c:Destroy()
	end
	pcall(function()
		local view = AvatarView.new(self.ctx, { size = UDim2.fromScale(1, 1), framing = "full", zIndex = self.Z + 2, background = C.panel })
		view.frame.BackgroundTransparency = 1
		view.frame.Parent = side.figure
		view:set(appearance)
	end)
end

local function setBar(side, s, lastHp: number?)
	local share = math.clamp((s.hp or 0) / math.max(1, s.start or 1), 0, 1)
	if lastHp and s.hp < lastHp then
		side.fill.Size = UDim2.fromScale(share, 1)
		Kit.tween(side.ghost, 0.6, { Size = UDim2.fromScale(share, 1) })
	else
		side.fill.Size = UDim2.fromScale(share, 1)
		side.ghost.Size = UDim2.fromScale(share, 1)
	end
	side.hpText.Text = string.format("%d / %d", math.floor(s.hp or 0), math.floor(s.start or 0))
	-- the mark where a friendly duel stops
	local mark = side.holder:FindFirstChild("FloorMark")
	if (s.floor or 0) > 0 then
		if not mark then
			mark = new("Frame", { Name = "FloorMark", BackgroundColor3 = C.paperHi, BorderSizePixel = 0, Size = UDim2.fromOffset(2, 18), ZIndex = 200, Parent = side.holder })
		end
		(mark :: any).Position = UDim2.new(math.clamp(s.floor / math.max(1, s.start), 0, 1), -1, 0, -3)
	end
end

function DuelView:moveButton(text: string, sub: string, style: string, order: number, enabled: boolean, onClick)
	local btn = Kit.button({ name = "Move_" .. tostring(order), text = "", style = style, size = UDim2.fromScale(1, 1), order = order, enabled = enabled, zIndex = self.Z + 2, onClick = onClick, parent = self.moves })
	btn.Text = ""
	new("TextLabel", { Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 22), FontFace = F.display, TextSize = 16, TextColor3 = if style == "primary" then C.ink else C.text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = string.upper(text), ZIndex = self.Z + 3, Parent = btn })
	new("TextLabel", { Name = "Sub", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 28), Size = UDim2.new(1, -20, 1, -32), FontFace = F.ui, TextSize = 12, TextWrapped = true, TextColor3 = if style == "primary" then C.ink else C.sub, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Text = sub, ZIndex = self.Z + 3, Parent = btn })
	return btn
end

function DuelView:centerOf(gui: GuiObject?, fallback: Vector2): Vector2
	local root = self.root
	if not gui or not root or root.AbsoluteSize.X <= 0 or gui.AbsoluteSize.X <= 0 then
		return fallback
	end
	local c = gui.AbsolutePosition + gui.AbsoluteSize / 2 - root.AbsolutePosition
	return Vector2.new(c.X / root.AbsoluteSize.X, c.Y / root.AbsoluteSize.Y)
end

function DuelView:set(view)
	if not view or not view.me or not view.them then
		return
	end
	local first = self.view == nil
	local lastTurn = self.view and self.view.turn
	local lastMe, lastThem = self.view and self.view.me.hp, self.view and self.view.them.hp
	self.view = view
	local me, them = view.me, view.them
	self.kicker.Text = string.upper((if view.blood then "Blood duel · rough play" else "Duel · first real blood ends it") .. "  ·  Turn " .. tostring(view.turn or 1))
	self.kicker.TextColor3 = if view.blood then C.crimsonHi else C.accentHi
	self.title.Text = (me.name or "You") .. "  vs  " .. (them.name or "them")
	self:setFigure(self.mine, me.key, me.appearance)
	self:setFigure(self.theirs, them.key, them.appearance)
	local okArena, errArena = pcall(self.ensureArena, self, view)
	if not okArena then
		warn("[DuelView] " .. tostring(errArena))
	end
	self.mine.name.Text = (me.full or me.name or "") .. "  (you)"
	self.theirs.name.Text = them.full or them.name or ""
	local function statusOf(s)
		local parts = { if s.chosen then "CHOSEN" else "CHOOSING" }
		if s.steady then
			table.insert(parts, "STEADY")
		end
		table.insert(parts, tostring(s.recovers or 0) .. " PATCH-UPS")
		return table.concat(parts, " · ")
	end
	self.mine.status.Text = statusOf(me)
	self.theirs.status.Text = statusOf(them)
	setBar(self.mine, me, lastMe)
	setBar(self.theirs, them, lastThem)

	-- the log
	for _, c in self.logBox:GetChildren() do
		if c:IsA("TextLabel") then
			c:Destroy()
		end
	end
	local log = view.log or {}
	for i = math.max(1, #log - 3), #log do
		local e = log[i]
		new("TextLabel", { Name = "Line", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.ui, TextSize = 13, TextWrapped = true, TextColor3 = TONE[e.tone or ""] or C.text, TextXAlignment = Enum.TextXAlignment.Left, Text = e.text or "", LayoutOrder = i, ZIndex = self.Z + 2, Parent = self.logBox })
	end

	-- your moves, or who you're waiting on
	for _, c in self.moves:GetChildren() do
		if c:IsA("GuiButton") then
			c:Destroy()
		end
	end
	for _, c in self.goHolder:GetChildren() do
		c:Destroy()
	end
	if view.options and not view.done then
		self.waiting.Visible = false
		for i, o in view.options do
			local style, sub = "secondary", o.desc or ""
			if o.action == "strike" then
				style = "primary"
				sub = "Clash · " .. pct(o.odds) .. " vs their best · ~" .. tostring(o.hit or 0)
			elseif o.action == "yield" then
				style = "danger"
			end
			self:moveButton(o.name or o.action, sub, style, i, o.enabled ~= false, function()
				if self.busy then
					return
				end
				self.busy = true
				if self.handlers.onAct then
					self.handlers.onAct(o.action, o.approach)
				end
				self.busy = false
			end)
		end
	elseif not view.done then
		self.waiting.Visible = true
		self.waiting.Text = if view.canGo then (them.name or "They") .. " hasn't chosen. You can go ahead." else "Waiting for " .. (them.name or "them") .. " (" .. tostring(view.goIn or 0) .. "s)"
		if view.canGo then
			Kit.button({ name = "GoNow", text = "Go now", style = "secondary", size = UDim2.fromScale(1, 1), zIndex = self.Z + 3, parent = self.goHolder, onClick = function()
				if self.handlers.onGo then
					self.handlers.onGo()
				end
			end })
		end
	end

	if first then
		Vfx.banner(self.root, if view.blood then "Blood duel" else "Duel", (me.name or "You") .. " vs " .. (them.name or "them"), if view.blood then C.crimsonHi else C.accentHi)
	elseif lastTurn and view.turn ~= lastTurn and view.last then
		self:turnFx(view.last, view)
	end
end

-- the turn that just happened: both moves, said in the middle, and played as effects
-- (v0.18) THE 3D STAGE: you on the left, them on the right, on a set of their own, framed
-- into the band where the figures were. Without it (the Lite setting) the figures stay.
function DuelView:ensureArena(view)
	if self.arena or self.arenaTried or not self.root then
		return
	end
	if not view.me.appearance or not view.them.appearance then
		return
	end
	self.arenaTried = true
	local size = self.root.AbsoluteSize
	local H = math.max(1, size.Y)
	local top = self.stageTop / H
	local bottom = math.min(0.95, (self.stageTop + self.stageH * H - 48) / H)
	local ok, arena = pcall(Arena.open, self.ctx, self.root, {
		-- (v0.18) somewhere of the two of you's own: the same pair, the same place
		set = (function()
			local pool = if view.blood
				then { "alley", "rooftop", "bridge", "parking", "construction", "trainyard", "docks", "sewer" }
				else { "gym", "office", "warehouse", "plaza", "greenhouse", "noodle", "library", "arcade", "market" }
			-- (in the same order on both screens, so both players see the same place)
			local ka, kb = tostring(view.me.key), tostring(view.them.key)
			if ka > kb then
				ka, kb = kb, ka
			end
			local text = ka .. ":" .. kb
			local h = 0
			for i = 1, #text do
				h = (h * 31 + string.byte(text, i)) % 1000003
			end
			return pool[h % #pool + 1]
		end)(),
		time = "night",
		mood = if view.blood then "boss" else nil,
		seed = tostring(view.me.key) .. ":" .. tostring(view.them.key),
		left = { { key = view.me.key, name = view.me.name, appearance = view.me.appearance } },
		right = { { key = view.them.key, name = view.them.name, appearance = view.them.appearance } },
		rect = { 0.04, top, 0.96, bottom },
	})
	if not ok or not arena then
		if not ok then
			warn("[DuelView] " .. tostring(arena))
		end
		return
	end
	self.arena = arena
	local Z = self.Z
	self.root.BackgroundTransparency = 1
	self.mine.figure.Visible = false
	self.theirs.figure.Visible = false
	new("Frame", { Name = "ScrimTop", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, self.stageTop + 20), ZIndex = Z, Parent = self.root }, {
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.75, 0.55), NumberSequenceKeypoint.new(1, 1) }) }),
	})
	new("Frame", { Name = "ScrimBottom", BackgroundColor3 = Color3.fromRGB(6, 6, 9), BorderSizePixel = 0, Position = UDim2.new(0, 0, self.stageH, self.stageTop - 60), Size = UDim2.new(1, 0, 1 - self.stageH, -(self.stageTop - 60)), ZIndex = Z, Parent = self.root }, {
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0.25), NumberSequenceKeypoint.new(1, 0.06) }) }),
	})
end

-- the turn on the 3D stage
function DuelView:arenaTurn(mine, theirs, view)
	local arena = self.arena
	local root = self.root
	local meKey, themKey = view.me.key, view.them.key
	local clashed = mine and theirs and mine.action == "strike" and theirs.action == "strike"
	if clashed then
		arena:clash(meKey, themKey)
	end
	local function play(e, key, otherKey, color: Color3)
		if not e or arena.closed or not self.root then
			return
		end
		if e.dealt and e.dealt > 0 then
			local heavy = e.dealt >= 50
			arena:strike(key, otherKey, { heavy = heavy, status = e.status, color = if e.status then nil else color })
			task.delay(0.2, function()
				local at = arena:screenPos(otherKey, 0.9)
				if at and self.root then
					Vfx.number(root, at, tostring(e.dealt), color, heavy)
				end
			end)
		end
		if e.action == "guard" then
			arena:guard(key)
		elseif e.action == "recover" and e.healed then
			arena:heal(key)
		end
	end
	local first = if clashed then 0.3 else 0
	task.delay(first, function()
		play(mine, meKey, themKey, C.accentHi)
	end)
	task.delay(first + 0.55, function()
		play(theirs, themKey, meKey, C.crimsonHi)
	end)
end

function DuelView:turnFx(last, view)
	local root = self.root
	if not root then
		return
	end
	local meKey, themKey = view.me.key, view.them.key
	local mine, theirs = nil, nil
	for _, e in last.entries or {} do
		if e.key == meKey then
			mine = e
		elseif e.key == themKey then
			theirs = e
		end
	end
	local meAt = self:centerOf(self.mine.figure, Vector2.new(0.25, 0.35))
	local themAt = self:centerOf(self.theirs.figure, Vector2.new(0.75, 0.35))
	local words = {}
	if mine then
		table.insert(words, "You " .. (YOUR_WORD[mine.action] or mine.action))
	end
	if theirs then
		table.insert(words, (view.them.name or "They") .. " " .. (ACTION_WORD[theirs.action] or theirs.action))
	end
	self.summary.Text = string.upper(table.concat(words, "  ·  "))
	self.summary.TextTransparency = 0
	task.delay(2.2, function()
		if self.summary and self.summary.Parent then
			Kit.tween(self.summary, 0.4, { TextTransparency = 1 })
		end
	end)
	if self.arena then
		self:arenaTurn(mine, theirs, view)
		return
	end
	local function play(e, at: Vector2, color: Color3, otherAt: Vector2)
		if not e then
			return
		end
		if e.dealt and e.dealt > 0 then
			local heavy = e.dealt >= 50
			Vfx.impact(root, otherAt, { status = e.status, heavy = heavy, shake = true, color = if e.status then nil else color })
			Vfx.number(root, otherAt + Vector2.new(0, -0.08), tostring(e.dealt), color, heavy)
		end
		if e.action == "guard" then
			Vfx.guard(root, at)
		elseif e.action == "recover" and e.healed then
			Vfx.heal(root, at)
		elseif e.action == "feint" and e.won then
			Vfx.status(root, otherAt, "poise")
		end
	end
	play(mine, meAt, C.accentHi, themAt)
	task.delay(0.3, function()
		if self.root then
			play(theirs, themAt, C.crimsonHi, meAt)
		end
	end)
end

function DuelView:done(view)
	local Z = self.Z + 10
	if view and view.me then
		self:set(view)
	end
	for _, c in self.moves:GetChildren() do
		if c:IsA("GuiButton") then
			c:Destroy()
		end
	end
	self.waiting.Visible = false
	local won = view and view.won == true
	local word = if view and view.abandoned then "DUEL OVER" elseif won then "VICTORY" else "DEFEAT"
	local color = if won then C.accentHi else C.crimsonHi
	if won then
		Vfx.confetti(self.root, C.accentHi)
	elseif not (view and view.abandoned) then
		Vfx.flash(self.root, C.crimson, if self.arena then 0.3 else 0.5)
	end
	-- (v0.18) on the stage: the loser goes down (or to one knee, in a friendly duel)
	if self.arena and view and view.me and view.them and not view.abandoned then
		local loser = if won then view.them.key else view.me.key
		local winner = if won then view.me.key else view.them.key
		if view.blood then
			self.arena:down(loser)
		else
			self.arena:kneel(loser)
		end
		task.delay(0.6, function()
			if self.arena then
				self.arena:victory(winner, if won then C.accentHi else C.crimsonHi)
			end
		end)
		task.wait(1.4)
		if not self.root then
			return
		end
	end
	local scrim = new("Frame", { Name = "End", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = Z, Parent = self.root })
	new("TextLabel", { Name = "Word", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.new(1, 0, 0, 80), FontFace = F.display, TextSize = 72, TextColor3 = color, Text = word, ZIndex = Z + 1, Parent = scrim })
	local sub = if view and view.outcome == "yield" then "Someone yielded." elseif view and view.outcome == "down" then "To the end." elseif view and view.abandoned then "They left." else "First real blood."
	new("TextLabel", { Name = "Who", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.new(1, 0, 0, 24), FontFace = F.serifItalic, TextSize = 18, TextColor3 = C.text, Text = sub, ZIndex = Z + 1, Parent = scrim })
	local closed = false
	Kit.button({ name = "Continue", text = "Continue", style = "primary", size = UDim2.fromOffset(220, 46), position = UDim2.fromScale(0.5, 0.64), anchor = Vector2.new(0.5, 0.5), zIndex = Z + 2, parent = scrim, onClick = function()
		closed = true
	end })
	local t = 0
	while not closed and t < 8 do
		local dt = task.wait(0.1)
		t += math.max(if type(dt) == "number" then dt else 0, 0.1)
	end
	self:close()
end

function DuelView:close()
	if self.arena then
		local arena = self.arena
		self.arena = nil
		pcall(arena.close, arena)
	end
	if self.root then
		self.root:Destroy()
		self.root = nil
	end
	if self.handlers.onClose then
		self.handlers.onClose()
	end
end

return DuelView
