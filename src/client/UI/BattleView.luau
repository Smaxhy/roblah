--[[
	BATTLE VIEW (v0.16): the full-screen turn-based fight against a big boss (Engine/Battle.luau).

		local bv = BattleView.open(ctx, layer, { onAct = fn(action, approach), onGo = fn(), onClose = fn() })
		bv:set(view)      -- the fight as the server sees it (Battle.view)
		bv:done(done)     -- the end: { outcome = "won" | "lost" | "fled", boss }
		bv:close()

	Shows the boss (figure, Health with phase marks, the move it's about to make and who it's
	aimed at), every fighter (Health, chosen, guarding, down), your moves for this turn (each
	way of fighting with its odds and damage, Guard, Patch up, Get out), and a log of the turns.
	With friends, it says who the turn is waiting on, and lets you go ahead after a while.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local AvatarView = require(script.Parent.AvatarView)
local Vfx = require(script.Parent.Vfx)
-- (v0.18) the fight on the real 3D stage, with real effects (the figure box stays as the fallback)
local Arena = require(script.Parent.Arena)
local Stage = require(script.Parent.Stage)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local CreatureView = nil
do
	local ok, mod = pcall(function()
		return require(script.Parent:FindFirstChild("CreatureView"))
	end)
	if ok then
		CreatureView = mod
	end
end

local BattleView = {}
BattleView.__index = BattleView

local TONE = {
	good = C.good,
	danger = C.crimsonHi,
	muted = C.faint,
	voice = C.accentHi,
}

local function pct(x: number?): string
	if not x then
		return ""
	end
	return tostring(math.floor(x * 100 + 0.5)) .. "%"
end

local function bar(parent: Instance, z: number, color: Color3, height: number)
	local back = new("Frame", { Name = "Bar", BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, height), ZIndex = z, Parent = parent }, { Kit.corner(3), Kit.stroke(C.stroke, 1, 0.3) })
	local fill = new("Frame", { Name = "Fill", BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = z + 1, Parent = back }, { Kit.corner(3) })
	local ghost = new("Frame", { Name = "Ghost", BackgroundColor3 = Color3.fromRGB(255, 240, 220), BackgroundTransparency = 0.4, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = z, Parent = back }, { Kit.corner(3) })
	return back, fill, ghost
end

function BattleView.open(ctx, layer: Instance, handlers)
	local self = setmetatable({}, BattleView)
	self.ctx = ctx
	self.handlers = handlers or {}
	self.lastTurn = nil
	self.lastHp = nil
	local Z = 80

	local root = new("Frame", {
		Name = "BattleView",
		BackgroundColor3 = Color3.fromRGB(8, 7, 10),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Z,
		Active = true,
		Parent = layer,
	})
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(40, 14, 16), Color3.fromRGB(6, 6, 9)), Parent = root })
	self.root = root

	local wide = layer:IsA("GuiBase2d") and (layer :: any).AbsoluteSize.X >= 700 or false
	self.wide = wide
	local pad = if wide then 28 else 12

	-- ── top: the boss's name, Health and phase ──
	-- (clear of the Roblox buttons in the top corner)
	local topInset = 46
	local top = new("Frame", { Name = "Top", BackgroundTransparency = 1, Position = UDim2.fromOffset(pad, pad + topInset), Size = UDim2.new(1, -pad * 2, 0, 92), ZIndex = Z + 1, Parent = root })
	self.kicker = Kit.caps({ Name = "Kicker", Text = "Boss battle", TextColor3 = C.crimsonHi, Size = UDim2.new(1, 0, 0, 16), ZIndex = Z + 2, Parent = top })
	self.bossName = new("TextLabel", { Name = "BossName", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 34), FontFace = F.display, TextSize = if wide then 32 else 24, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left, Text = "", ZIndex = Z + 2, Parent = top })
	self.bossTitle = Kit.caps({ Name = "BossTitle", Text = "", Position = UDim2.fromOffset(0, 50), TextColor3 = C.sub, ZIndex = Z + 2, Parent = top })
	local hpHolder = new("Frame", { Name = "Hp", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 70), Size = UDim2.new(1, 0, 0, 18), ZIndex = Z + 2, Parent = top })
	local _hpBack, hpFill, hpGhost = bar(hpHolder, Z + 2, C.crimson, 14)
	self.hpFill, self.hpGhost, self.hpHolder = hpFill, hpGhost, hpHolder
	self.hpText = new("TextLabel", { Name = "HpText", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 52), Size = UDim2.fromOffset(200, 16), FontFace = F.mono, TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Right, Text = "", ZIndex = Z + 3, Parent = top })
	self.marks = {}

	-- ── the boss's figure ──
	local stageH = if wide then 0.42 else 0.3
	local figureBox = new("Frame", { Name = "Figure", BackgroundTransparency = 1, Position = UDim2.new(0, pad, 0, pad + topInset + 100), Size = UDim2.new(if wide then 0.34 else 0.45, 0, stageH, 0), ZIndex = Z + 1, Parent = root })
	self.figureBox = figureBox

	-- ── the move it's about to make ──
	local tele = new("Frame", { Name = "Telegraph", BackgroundColor3 = C.panel, BackgroundTransparency = 0.1, BorderSizePixel = 0, Position = UDim2.new(if wide then 0.36 else 0.47, pad, 0, pad + topInset + 104), Size = UDim2.new(if wide then 0.3 else 0.53, -pad * 2, 0, if wide then 128 else 116), ZIndex = Z + 1, Parent = root }, { Kit.corner(4), Kit.stroke(C.crimson, 1, 0.3), Kit.padding(10) })
	self.teleKicker = Kit.caps({ Name = "TeleKicker", Text = "Next", TextColor3 = C.crimsonHi, ZIndex = Z + 2, Parent = tele })
	self.teleName = new("TextLabel", { Name = "TeleName", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 24), FontFace = F.display, TextSize = 20, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left, Text = "", ZIndex = Z + 2, Parent = tele })
	self.teleText = new("TextLabel", { Name = "TeleText", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 0, 34), FontFace = F.serifItalic, TextSize = 13, TextWrapped = true, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Text = "", ZIndex = Z + 2, Parent = tele })
	self.teleTarget = new("TextLabel", { Name = "TeleTarget", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 20), FontFace = F.uiBold, TextSize = 14, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Left, RichText = true, Text = "", ZIndex = Z + 2, Parent = tele })
	self.tele = tele

	-- ── the log ──
	local logBox = new("Frame", { Name = "Log", BackgroundColor3 = C.panelLo, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = Z + 1, Parent = root }, { Kit.corner(4), Kit.stroke(C.stroke, 1, 0.5), Kit.padding(8) })
	if wide then
		logBox.Position = UDim2.new(0.68, 0, 0, pad + topInset + 104)
		logBox.Size = UDim2.new(0.32, -pad, stageH, -4)
	else
		logBox.Position = UDim2.new(0.47, pad, 0, pad + topInset + 104 + 124)
		logBox.Size = UDim2.new(0.53, -pad * 2, stageH, -128)
	end
	new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = logBox })
	self.logBox = logBox

	-- ── the fighters ──
	local fightersY = pad + topInset + 104 + (if wide then 0 else 0)
	local fightersRow = new("Frame", { Name = "Fighters", BackgroundTransparency = 1, Position = UDim2.new(0, pad, stageH, fightersY + 6), Size = UDim2.new(1, -pad * 2, 0, 64), ZIndex = Z + 1, Parent = root })
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = fightersRow })
	self.fightersRow = fightersRow

	-- ── your moves ──
	local moves = new("Frame", { Name = "Moves", BackgroundTransparency = 1, Position = UDim2.new(0, pad, stageH, fightersY + 78), Size = UDim2.new(1, -pad * 2, 1 - stageH, -(fightersY + 78) - pad), ZIndex = Z + 1, Parent = root })
	local grid = new("UIGridLayout", { CellSize = UDim2.new(if wide then 0.24 else 0.48, 0, 0, if wide then 64 else 58), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = moves })
	self.grid = grid
	self.moves = moves
	self.waiting = new("TextLabel", { Name = "Waiting", BackgroundTransparency = 1, Position = UDim2.new(0, pad, 1, -pad - 30), Size = UDim2.new(1, -pad * 2, 0, 24), FontFace = F.serifItalic, TextSize = 15, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Left, Text = "", Visible = false, ZIndex = Z + 2, Parent = root })
	self.Z = Z
	self.pad, self.topInset, self.stageH = pad, topInset, stageH
	return self
end

-- (v0.18) THE 3D STAGE: once the boss and the crew are known, the fight moves onto the real 3D
-- stage (UI/Arena.luau): your crew on the left, the boss on the right, framed into the part of
-- the screen the panels leave free. Without it (the Lite setting) the figure box stays.
function BattleView:arenaRect()
	local size = self.root.AbsoluteSize
	local H = math.max(1, size.Y)
	local top = (self.pad + self.topInset + 96) / H
	local bottom = math.min(0.95, self.stageH + (self.pad + self.topInset + 100) / H)
	if self.wide then
		return { 0.01, top, 0.66, bottom }
	end
	return { 0.0, top, 0.47, bottom }
end

function BattleView:ensureArena(view)
	local boss = view.boss or {}
	local left = {}
	for _, f in view.fighters or {} do
		if f.appearance then
			table.insert(left, { key = f.key, name = f.name, appearance = f.appearance, me = f.me })
		end
	end
	table.sort(left, function(a, b)
		return (if a.me then 1 else 0) > (if b.me then 1 else 0)
	end)
	if self.arena then
		self.arena:sync(left, {})
		return
	end
	if self.arenaTried or not self.root then
		return
	end
	self.arenaTried = true
	local bossWho = Stage.foeWho(boss.enemy, boss.name)
	if bossWho then
		bossWho.key = "boss"
	end
	local ok, arena = pcall(Arena.open, self.ctx, self.root, {
		set = Arena.setFor(boss.id, boss.enemy),
		time = "night",
		mood = "boss",
		seed = boss.id,
		left = left,
		right = { bossWho },
		rect = self:arenaRect(),
	})
	if not ok or not arena then
		if not ok then
			warn("[BattleView] " .. tostring(arena))
		end
		return
	end
	self.arena = arena
	-- the panels float over the stage now: no backdrop, a dark fade at the top and the bottom
	local Z = self.Z
	self.root.BackgroundTransparency = 1
	self.figureBox.Visible = false
	local topH = self.pad + self.topInset + 100
	new("Frame", { Name = "ScrimTop", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, topH + 40), ZIndex = Z, Parent = self.root }, {
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.7, 0.55), NumberSequenceKeypoint.new(1, 1) }) }),
	})
	new("Frame", { Name = "ScrimBottom", BackgroundColor3 = Color3.fromRGB(6, 6, 9), BorderSizePixel = 0, Position = UDim2.new(0, 0, self.stageH, topH - 40), Size = UDim2.new(1, 0, 1 - self.stageH, -(topH - 40)), ZIndex = Z, Parent = self.root }, {
		new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.22, 0.25), NumberSequenceKeypoint.new(1, 0.06) }) }),
	})
	if self.wide then
		-- the "next move" panel joins the log on the right, so the middle is the stage's
		local y = self.pad + self.topInset + 104
		self.tele.Position = UDim2.new(0.68, 0, 0, y)
		self.tele.Size = UDim2.new(0.32, -self.pad, 0, 128)
		self.logBox.Position = UDim2.new(0.68, 0, 0, y + 136)
		self.logBox.Size = UDim2.new(0.32, -self.pad, self.stageH, -140)
	end
end

-- a fraction-of-the-screen point over someone on the stage (nil when there's no stage)
function BattleView:arenaAt(key, height: number?): Vector2?
	return self.arena and self.arena:screenPos(key, height)
end

function BattleView:setFigure(enemy)
	if self.figureKey == (enemy and (enemy.id or enemy.name)) then
		return
	end
	self.figureKey = enemy and (enemy.id or enemy.name)
	for _, c in self.figureBox:GetChildren() do
		c:Destroy()
	end
	local Z = self.Z + 2
	if enemy and enemy.kind == "creature" and CreatureView then
		pcall(function()
			local view = CreatureView.new(self.ctx, { size = UDim2.fromScale(1, 1), framing = "full", zIndex = Z, background = false })
			view.frame.Parent = self.figureBox
			view:set(enemy)
		end)
	elseif enemy and enemy.look then
		pcall(function()
			local view = AvatarView.new(self.ctx, { size = UDim2.fromScale(1, 1), framing = "full", zIndex = Z, background = C.panel })
			view.frame.BackgroundTransparency = 1
			view.frame.Parent = self.figureBox
			view:set({ look = enemy.look, age = 30, form = "human" })
		end)
	end
end

function BattleView:fighterCard(f, order: number)
	local Z = self.Z + 2
	local color = if f.down then C.faint elseif f.targeted then C.crimsonHi else C.stroke
	local card = new("Frame", { Name = "Fighter_" .. tostring(f.key), BackgroundColor3 = C.panel, BorderSizePixel = 0, Size = UDim2.fromOffset(if self.wide then 210 else 160, 60), LayoutOrder = order, ZIndex = Z, Parent = self.fightersRow }, { Kit.corner(4), Kit.stroke(color, if f.targeted then 2 else 1, 0.1), Kit.padding(7) })
	new("TextLabel", { Name = "Name", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), FontFace = F.uiBold, TextSize = 14, TextColor3 = if f.me then C.accentHi else C.text, TextXAlignment = Enum.TextXAlignment.Left, Text = (f.name or "?") .. (if f.me then "  (you)" else ""), ZIndex = Z + 1, Parent = card })
	local status = if f.down then "DOWN" elseif f.fled then "OUT" elseif f.acted then "CHOSEN" else "CHOOSING"
	if f.steady and not f.down and not f.fled then
		status ..= " · STEADY"
	end
	if f.targeted and not f.down and not f.fled then
		status ..= " · TARGETED"
	end
	Kit.caps({ Name = "Status", Text = status, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 14), TextSize = 11, TextColor3 = if f.targeted then C.crimsonHi else C.sub, ZIndex = Z + 1, Parent = card })
	local holder = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, -46, 0, 10), ZIndex = Z + 1, Parent = card })
	local _b, fill = bar(holder, Z + 1, if f.down then C.faint else C.good, 8)
	fill.Size = UDim2.fromScale(math.clamp((f.hp or 0) / math.max(1, f.maxHp or 100), 0, 1), 1)
	new("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 32), Size = UDim2.fromOffset(44, 16), FontFace = F.mono, TextSize = 12, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Right, Text = tostring(math.floor(f.hp or 0)), ZIndex = Z + 1, Parent = card })
	return card
end

function BattleView:moveButton(text: string, sub: string, style: string, order: number, enabled: boolean, onClick)
	local btn = Kit.button({ name = "Move_" .. tostring(order), text = "", style = style, size = UDim2.fromScale(1, 1), order = order, enabled = enabled, zIndex = self.Z + 2, onClick = onClick, parent = self.moves })
	btn.Text = ""
	new("TextLabel", { Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -20, 0, 22), FontFace = F.display, TextSize = 17, TextColor3 = if style == "primary" then C.ink else C.text, TextXAlignment = Enum.TextXAlignment.Left, Text = string.upper(text), ZIndex = self.Z + 3, Parent = btn })
	new("TextLabel", { Name = "Sub", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 30), Size = UDim2.new(1, -20, 0, 24), FontFace = F.ui, TextSize = 12, TextWrapped = true, TextColor3 = if style == "primary" then C.ink else C.sub, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Text = sub, ZIndex = self.Z + 3, Parent = btn })
	return btn
end

function BattleView:set(view)
	if not view or not view.boss then
		return
	end
	self.view = view
	local boss = view.boss
	self.kicker.Text = string.upper((if view.withFriends then "Boss battle · with your crew" else "Boss battle") .. "  ·  Turn " .. tostring(view.turn or 1) .. (if (boss.phases or 1) > 1 then "  ·  Phase " .. tostring(boss.phase or 1) .. " of " .. tostring(boss.phases) else ""))
	self.bossName.Text = boss.name or ""
	self.bossTitle.Text = string.upper(boss.title or "")
	local share = math.clamp((boss.hp or 0) / math.max(1, boss.maxHp or 1), 0, 1)
	local turnChanged = self.lastTurn ~= nil and view.turn ~= self.lastTurn
	if self.lastHp and boss.hp < self.lastHp then
		-- a hit lands: the bar drops, its ghost follows, the screen jolts
		self.hpFill.Size = UDim2.fromScale(share, 1)
		Kit.tween(self.hpGhost, 0.6, { Size = UDim2.fromScale(share, 1) })
		if not self.arena then
			Kit.shake(self.root, 6, 0.25) -- (on the 3D stage, the camera shakes instead)
		end
	else
		self.hpFill.Size = UDim2.fromScale(share, 1)
		self.hpGhost.Size = UDim2.fromScale(share, 1)
	end
	self.lastHp = boss.hp
	self.lastTurn = view.turn
	self.hpText.Text = tostring(math.floor(boss.hp or 0)) .. " / " .. tostring(math.floor(boss.maxHp or 0))
	for _, m in self.marks do
		m:Destroy()
	end
	self.marks = {}
	for _, at in boss.phaseMarks or {} do
		table.insert(self.marks, new("Frame", { Name = "PhaseMark", BackgroundColor3 = C.paperHi, BorderSizePixel = 0, Position = UDim2.new(at, -1, 0, -3), Size = UDim2.fromOffset(2, 20), ZIndex = self.Z + 5, Parent = self.hpHolder }))
	end
	self:setFigure(boss.enemy)
	local okArena, errArena = pcall(self.ensureArena, self, view)
	if not okArena then
		warn("[BattleView] " .. tostring(errArena))
	end

	-- the move it's about to make
	local nx = view.next or {}
	self.teleKicker.Text = string.upper(if nx.heavy then "Next · heavy" else "Next")
	self.teleName.Text = nx.name or ""
	self.teleText.Text = (boss.name or "It") .. " " .. (nx.text or "") .. "."
	local mine = false
	for _, f in view.fighters or {} do
		if f.me and f.targeted then
			mine = true
		end
	end
	if nx.target == "all" then
		self.teleTarget.Text = "Aimed at <b>everyone</b>  ·  " .. tostring(nx.power or 0) .. " power"
	elseif mine then
		self.teleTarget.Text = "Aimed at <b><font color=\"#e2564c\">you</font></b>  ·  " .. tostring(nx.power or 0) .. " power"
	else
		self.teleTarget.Text = "Aimed at <b>" .. tostring(nx.targetName or "someone") .. "</b>  ·  " .. tostring(nx.power or 0) .. " power"
	end

	-- the fighters
	for _, c in self.fightersRow:GetChildren() do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	for i, f in view.fighters or {} do
		self:fighterCard(f, i)
	end

	-- the log
	for _, c in self.logBox:GetChildren() do
		if c:IsA("TextLabel") then
			c:Destroy()
		end
	end
	local log = view.log or {}
	local from = math.max(1, #log - 8)
	for i = from, #log do
		local e = log[i]
		new("TextLabel", { Name = "Line", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, FontFace = if e.tone == "voice" then F.serifItalic else F.ui, TextSize = 13, TextWrapped = true, TextColor3 = TONE[e.tone or ""] or C.text, TextXAlignment = Enum.TextXAlignment.Left, Text = e.text or "", LayoutOrder = i, ZIndex = self.Z + 2, Parent = self.logBox })
	end

	-- your moves
	for _, c in self.moves:GetChildren() do
		if c:IsA("GuiButton") then
			c:Destroy()
		end
	end
	local options = view.options
	if options then
		self.waiting.Visible = false
		for i, o in options do
			local enabled = o.enabled ~= false
			local style, sub = "secondary", o.desc or ""
			if o.action == "strike" then
				style = "primary"
				if o.free then
					sub = "Lands unopposed · ~" .. tostring(o.hit or 0) .. " damage"
				else
					sub = "Clash · " .. pct(o.odds) .. " to win · ~" .. tostring(o.hit or 0) .. " damage"
				end
			elseif o.action == "recover" then
				sub = (o.desc or "Heal") .. " · " .. tostring(o.left or 0) .. " left"
			elseif o.action == "flee" then
				style = "danger"
			end
			self:moveButton(o.name or o.action, sub, style, i, enabled, function()
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
	else
		local waitingOn = view.waitingOn or {}
		self.waiting.Visible = true
		if #waitingOn > 0 then
			self.waiting.Text = "Waiting for " .. table.concat(waitingOn, ", ") .. (if view.canGo then "." else " (" .. tostring(view.goIn or 0) .. "s)")
			if view.canGo then
				self:moveButton("Go now", "Whoever hasn't chosen guards this turn.", "secondary", 1, true, function()
					if self.handlers.onGo then
						self.handlers.onGo()
					end
				end)
			end
		else
			self.waiting.Text = "..."
		end
	end
	if turnChanged and view.last then
		self:flashTurn(view.last)
		self:turnFx(view.last, view)
	end
	if not self.opened then
		self.opened = true
		Vfx.banner(self.root, boss.name or "Boss battle", boss.title, C.crimsonHi)
	end
end

-- (v0.17) where a GUI object sits on the battle screen, as a share of it (for effects)
function BattleView:centerOf(gui: GuiObject?, fallback: Vector2): Vector2
	local root = self.root
	if not gui or not root or root.AbsoluteSize.X <= 0 or gui.AbsoluteSize.X <= 0 then
		return fallback
	end
	local c = gui.AbsolutePosition + gui.AbsoluteSize / 2 - root.AbsolutePosition
	return Vector2.new(c.X / root.AbsoluteSize.X, c.Y / root.AbsoluteSize.Y)
end

-- (v0.17) the turn that just happened, as effects: every blow on the boss, the boss's move on
-- whoever it hit, a heal, a guard, a new phase
function BattleView:turnFx(last, view)
	local root = self.root
	if not root then
		return
	end
	local bossAt = self:centerOf(self.figureBox, Vector2.new(0.2, 0.4))
	local myKey = nil
	for _, f in view.fighters or {} do
		if f.me then
			myKey = f.key
		end
	end
	local myCard = myKey and self.fightersRow:FindFirstChild("Fighter_" .. tostring(myKey))
	local meAt = self:centerOf(myCard :: any, Vector2.new(0.15, 0.62))
	if self.arena then
		self:arenaTurn(last, view, myKey)
		return
	end
	local delay = 0
	for _, e in last.entries or {} do
		task.delay(delay, function()
			if not self.root then
				return
			end
			if e.dealt and e.dealt > 0 then
				local heavy = e.dealt >= 60
				Vfx.impact(root, bossAt, { status = e.status, heavy = heavy, shake = true, angle = math.random(-60, 20) })
				Vfx.number(root, bossAt + Vector2.new(0.03, -0.06), tostring(e.dealt), if e.won then C.accentHi else C.paperHi, heavy)
			elseif e.action == "strike" and e.won == false then
				Vfx.ring(root, bossAt, C.crimsonHi, 140)
			end
			if e.healed and e.key == myKey then
				Vfx.heal(root, meAt)
			end
			if e.action == "guard" and e.key == myKey then
				Vfx.guard(root, meAt)
			end
			if e.taken and e.taken > 0 and e.key == myKey then
				Vfx.impact(root, meAt, { color = C.crimsonHi, heavy = last.heavy or e.taken >= 60 })
				Vfx.flash(root, C.crimson, if last.heavy then 0.45 else 0.25)
				Kit.shake(root, if last.heavy then 14 else 8, 0.3)
				Vfx.number(root, meAt + Vector2.new(0, -0.08), "-" .. tostring(e.taken), C.crimsonHi, last.heavy)
			end
		end)
		delay += 0.25
	end
	if last.phase then
		task.delay(delay + 0.2, function()
			if self.root then
				Vfx.banner(self.root, "Phase " .. tostring(last.phase), (view.log and view.log[#view.log] and view.log[#view.log].text) or nil, C.crimsonHi)
				Vfx.speedLines(self.root, C.crimsonHi)
			end
		end)
	end
end

-- (v0.18) the turn on the 3D stage: every fighter's blow on the boss (a lunge, a slash, the
-- hit, its status), the boss's move on whoever it hit, guards, patch-ups, a new phase
function BattleView:arenaTurn(last, view, myKey)
	local arena = self.arena
	local root = self.root
	local delay = 0
	for _, e in last.entries or {} do
		task.delay(delay, function()
			if not self.root or arena.closed then
				return
			end
			if e.dealt and e.dealt > 0 then
				local heavy = e.dealt >= 60
				arena:strike(e.key, "boss", { heavy = heavy, crit = e.dealt >= 120, status = e.status, color = if e.status then nil else Color3.fromRGB(255, 226, 170) })
				task.delay(0.2, function()
					local at = self:arenaAt("boss", 0.9)
					if at and self.root then
						Vfx.number(root, at, tostring(e.dealt), if e.won then C.accentHi else C.paperHi, heavy)
					end
				end)
			elseif e.action == "strike" and e.won == false then
				arena:clash(e.key, "boss")
			end
			if e.healed then
				arena:heal(e.key)
			end
			if e.action == "guard" then
				arena:guard(e.key)
			end
			if e.taken and e.taken > 0 then
				local heavy = last.heavy or e.taken >= 60
				arena:strike("boss", e.key, { heavy = heavy, color = C.crimsonHi })
				task.delay(0.2, function()
					local at = self:arenaAt(e.key, 0.9)
					if at and self.root then
						Vfx.number(root, at, "-" .. tostring(e.taken), C.crimsonHi, heavy)
					end
					if e.key == myKey and self.root then
						Vfx.flash(root, C.crimson, if heavy then 0.3 else 0.15)
					end
				end)
			end
		end)
		delay += 0.55
	end
	if last.phase then
		task.delay(delay + 0.2, function()
			if self.root and not arena.closed then
				arena:phase("boss", C.crimsonHi)
				Vfx.banner(self.root, "Phase " .. tostring(last.phase), (view.log and view.log[#view.log] and view.log[#view.log].text) or nil, C.crimsonHi)
			end
		end)
	end
end

-- a moment on the turn that just happened
function BattleView:flashTurn(last)
	local Z = self.Z + 8
	local parts = {}
	for _, e in last.entries or {} do
		if e.dealt and e.dealt > 0 then
			table.insert(parts, e.name .. " " .. tostring(e.dealt))
		end
	end
	local text = if #parts > 0 then "HIT  ·  " .. table.concat(parts, "  ·  ") else (last.move or "")
	local flash = new("TextLabel", { Name = "TurnFlash", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.36), Size = UDim2.new(0.8, 0, 0, 40), FontFace = F.display, TextSize = 30, TextColor3 = if #parts > 0 then C.accentHi else C.crimsonHi, TextStrokeTransparency = 0.4, Text = string.upper(text), ZIndex = Z, Parent = self.root })
	task.delay(0.9, function()
		Kit.tween(flash, 0.4, { TextTransparency = 1, TextStrokeTransparency = 1 })
		task.delay(0.45, function()
			flash:Destroy()
		end)
	end)
end

function BattleView:done(done)
	local Z = self.Z + 10
	local outcome = done and done.outcome or "lost"
	local word = if outcome == "won" then "VICTORY" elseif outcome == "fled" then "ESCAPED" else "DEFEAT"
	local color = if outcome == "won" then C.accentHi elseif outcome == "fled" then C.sub else C.crimsonHi
	-- (v0.17) the end, felt (v0.18: on the stage, the boss falls, or you do)
	local myKey = nil
	for _, f in (self.view and self.view.fighters) or {} do
		if f.me then
			myKey = f.key
		end
	end
	if self.arena then
		if outcome == "won" then
			self.arena:down("boss")
			task.delay(0.7, function()
				if self.arena and myKey then
					self.arena:victory(myKey, C.accentHi)
				end
			end)
			Vfx.confetti(self.root, C.accentHi)
		elseif outcome ~= "fled" and myKey then
			self.arena:down(myKey)
			Vfx.flash(self.root, C.crimson, 0.4)
		end
	elseif outcome == "won" then
		Vfx.confetti(self.root, C.accentHi)
		Vfx.impact(self.root, self:centerOf(self.figureBox, Vector2.new(0.2, 0.4)), { heavy = true, color = C.accentHi })
	elseif outcome ~= "fled" then
		Vfx.flash(self.root, C.crimson, 0.6)
	end
	if self.arena and outcome ~= "fled" then
		task.wait(1.4) -- (let the last blow land on the stage before the word comes up)
		if not self.root then
			return
		end
	end
	for _, c in self.moves:GetChildren() do
		if c:IsA("GuiButton") then
			c:Destroy()
		end
	end
	self.waiting.Visible = false
	local scrim = new("Frame", { Name = "End", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = Z, Parent = self.root })
	new("TextLabel", { Name = "Word", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.new(1, 0, 0, 80), FontFace = F.display, TextSize = 72, TextColor3 = color, Text = word, ZIndex = Z + 1, Parent = scrim })
	new("TextLabel", { Name = "Who", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52), Size = UDim2.new(1, 0, 0, 24), FontFace = F.serifItalic, TextSize = 18, TextColor3 = C.text, Text = done and done.boss or "", ZIndex = Z + 1, Parent = scrim })
	local closed = false
	local btn = Kit.button({ name = "Continue", text = "Continue", style = "primary", size = UDim2.fromOffset(220, 46), position = UDim2.fromScale(0.5, 0.64), anchor = Vector2.new(0.5, 0.5), zIndex = Z + 2, parent = scrim, onClick = function()
		closed = true
	end })
	local _ = btn
	local t = 0
	while not closed and t < 8 do
		local dt = task.wait(0.1)
		t += math.max(if type(dt) == "number" then dt else 0, 0.1)
	end
	self:close()
end

function BattleView:close()
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

return BattleView
