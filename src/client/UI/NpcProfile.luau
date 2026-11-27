--[[
	ONE PERSON (BitLeveling, v0.19): everything you know about someone in your life, and what
	you can do with them. Opened from the PARTY screen (UI/PartySheet) or a person in PEOPLE.

		NpcProfile.open(gui, call, {
			relId = 12,                    who
			profile = <partyProfile view>, (optional: what the server already sent)
			onResponse = function(res),    the app applies a life response (log, life, a fight)
			onChanged = function(res),     the party screen refreshes
			toast = function(text, color),
		})
		NpcProfile.close()

	Left: them, as an R6 Hunter (Hunter/R6Rig, dressed by Hunter/Looks in their class's outfit
	for their rank, or what their work says), their rank badge in its colour, class, how much
	they've trained, what they do. Right: what they said last, their personality, your bond (and
	loyalty, in your party), their story as far as they've told it (the next line needs a closer
	bond), what they like and can't stand (as far as you've learned), your history together, and
	everything you can do with them, with the odds.

	NpcProfile.kit is the look both party screens share: the navy panels, the mana glow, the rank
	colours (E grey, D green, C blue, B violet, A orange, S red and gold), badges, bars,
	buttons and the portraits.
]]

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Theme = require(script.Parent:WaitForChild("Theme"))
local F = Theme.fonts

local NpcProfile = {}

-- ── the kit ──────────────────────────────────────────────────────────────────
local Kit: any = {}
NpcProfile.kit = Kit

local C = {
	scrim = Color3.fromRGB(2, 4, 12),
	bg = Color3.fromRGB(6, 10, 24),
	panel = Color3.fromRGB(11, 18, 40),
	panelHi = Color3.fromRGB(18, 29, 60),
	panelLo = Color3.fromRGB(7, 12, 28),
	stroke = Color3.fromRGB(40, 64, 118),
	strokeHi = Color3.fromRGB(70, 110, 190),
	mana = Color3.fromRGB(84, 170, 255),
	manaHi = Color3.fromRGB(160, 214, 255),
	manaLo = Color3.fromRGB(24, 60, 140),
	text = Color3.fromRGB(230, 238, 255),
	sub = Color3.fromRGB(150, 166, 204),
	faint = Color3.fromRGB(92, 108, 146),
	good = Color3.fromRGB(104, 222, 156),
	warn = Color3.fromRGB(255, 190, 90),
	bad = Color3.fromRGB(255, 92, 108),
	gold = Color3.fromRGB(255, 208, 100),
	ink = Color3.fromRGB(6, 10, 22),
}
Kit.C = C

-- rank colours: 0 is nobody with a rank
local RANK_COLOR = {
	[0] = Color3.fromRGB(120, 128, 146),
	[1] = Color3.fromRGB(168, 174, 186), -- E grey
	[2] = Color3.fromRGB(96, 214, 128), -- D green
	[3] = Color3.fromRGB(80, 160, 255), -- C blue
	[4] = Color3.fromRGB(178, 112, 255), -- B violet
	[5] = Color3.fromRGB(255, 154, 58), -- A orange
	[6] = Color3.fromRGB(255, 66, 78), -- S red (and gold)
}
local LETTERS = { "E", "D", "C", "B", "A", "S" }
Kit.LETTERS = LETTERS
function Kit.rankColor(rank: number?): Color3
	return RANK_COLOR[math.clamp(math.floor(rank or 0), 0, 6)]
end
local CONDITION = {
	fine = { text = "FINE", color = C.good },
	hurt = { text = "HURT", color = C.warn },
	down = { text = "DOWN", color = C.bad },
}
Kit.CONDITION = CONDITION

function Kit.make(className: string, props: any, parent: Instance?): any
	local inst = Instance.new(className)
	for k, v in props do
		(inst :: any)[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end
local make = Kit.make

function Kit.corner(parent: Instance, r: number?): any
	return make("UICorner", { CornerRadius = UDim.new(0, r or 6) }, parent)
end
function Kit.stroke(parent: Instance, color: Color3, thickness: number?, transparency: number?): any
	return make("UIStroke", { Color = color, Thickness = thickness or 1, Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, parent)
end
-- (a UIGradient multiplies the background colour, so the background goes white and the
-- gradient carries the colours; keypoints, not ColorSequence.new(a, b), so every runtime agrees)
function Kit.gradient(parent: Instance, top: Color3, bottom: Color3, rotation: number?): any
	if parent:IsA("GuiObject") then
		(parent :: any).BackgroundColor3 = Color3.new(1, 1, 1)
	end
	return make("UIGradient", {
		Rotation = rotation or 90,
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, top), ColorSequenceKeypoint.new(1, bottom) }),
	}, parent)
end
function Kit.padding(parent: Instance, t: number, r: number?, b: number?, l: number?): any
	return make("UIPadding", { PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r or t), PaddingBottom = UDim.new(0, b or t), PaddingLeft = UDim.new(0, l or r or t) }, parent)
end
function Kit.list(parent: Instance, gap: number, horizontal: boolean?, align: any?): any
	return make("UIListLayout", {
		Padding = UDim.new(0, gap),
		FillDirection = if horizontal then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		VerticalAlignment = if horizontal then Enum.VerticalAlignment.Center else Enum.VerticalAlignment.Top,
	}, parent)
end
function Kit.label(parent: Instance, props: any): any
	local p = {
		BackgroundTransparency = 1,
		TextColor3 = C.text,
		FontFace = F.uiMedium,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.new(1, 0, 0, 18),
	}
	for k, v in props do
		p[k] = v
	end
	return make("TextLabel", p, parent)
end
-- a section heading: small caps in mana blue, with a thin glow line
function Kit.heading(parent: Instance, text: string, order: number, right: string?): any
	local h = make("Frame", { Name = "Heading", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = order }, parent)
	Kit.label(h, { Text = string.upper(text), FontFace = F.display, TextSize = 14, TextColor3 = C.manaHi, Size = UDim2.new(1, 0, 0, 18) })
	if right then
		Kit.label(h, { Text = right, FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(1, 0, 0, 18) })
	end
	local line = make("Frame", { BackgroundColor3 = C.mana, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 1) }, h)
	make("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.6, 0.7), NumberSequenceKeypoint.new(1, 1) }) }, line)
	return h
end
-- the rank badge: the letter in its colour (S in red with a gold rim); "-" without a rank
function Kit.rankBadge(parent: Instance, rank: number?, size: number, props: any?): any
	local r = math.clamp(math.floor(rank or 0), 0, 6)
	local col = Kit.rankColor(r)
	local b = make("Frame", { Name = "RankBadge", Size = UDim2.fromOffset(size, size), BackgroundColor3 = col:Lerp(C.ink, 0.62), ZIndex = 4 }, parent)
	for k, v in props or {} do
		(b :: any)[k] = v
	end
	Kit.corner(b, math.floor(size * 0.24))
	Kit.stroke(b, if r == 6 then C.gold else col, if r >= 5 then 2 else 1.5, 0)
	Kit.gradient(b, col:Lerp(C.ink, 0.45), col:Lerp(C.ink, 0.8))
	Kit.label(b, {
		Name = "Letter",
		Text = if r > 0 then LETTERS[r] else "-",
		FontFace = F.display,
		TextSize = math.floor(size * 0.62),
		TextColor3 = if r == 6 then C.gold else col:Lerp(Color3.new(1, 1, 1), 0.25),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
	})
	return b
end
-- a labelled bar (LOYALTY 62 ▮▮▮▮▯), 0..max
function Kit.bar(parent: Instance, label: string, value: number, max: number, color: Color3, order: number?): any
	local row = make("Frame", { Name = "Bar_" .. label, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), LayoutOrder = order or 0 }, parent)
	Kit.label(row, { Text = string.upper(label), FontFace = F.display, TextSize = 11, TextColor3 = C.sub, Size = UDim2.new(0, 62, 1, 0) })
	local track = make("Frame", { Name = "Track", BackgroundColor3 = C.panelLo, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 64, 0.5, 0), Size = UDim2.new(1, -96, 0, 6) }, row)
	Kit.corner(track, 3)
	Kit.stroke(track, C.stroke, 1, 0.3)
	local share = math.clamp((value or 0) / math.max(1, max), 0, 1)
	local fill = make("Frame", { Name = "Fill", BackgroundColor3 = color, BorderSizePixel = 0, Size = UDim2.new(share, 0, 1, 0) }, track)
	Kit.corner(fill, 3)
	Kit.gradient(fill, color:Lerp(Color3.new(1, 1, 1), 0.25), color, 0)
	Kit.label(row, { Text = tostring(math.floor((value or 0) + 0.5)), FontFace = F.mono, TextSize = 12, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 30, 1, 0) })
	return row
end
-- a button: navy with a coloured rim, or filled (primary)
function Kit.button(parent: Instance, text: string, color: Color3, onClick: () -> (), opts: any?): any
	opts = opts or {}
	local enabled = opts.enabled ~= false
	local primary = opts.primary == true and enabled
	local b = make("TextButton", {
		Name = opts.name or ("Button_" .. string.gsub(text, "%W", "")),
		Size = opts.size or UDim2.fromOffset(96, 30),
		Position = opts.position or UDim2.new(),
		AnchorPoint = opts.anchor or Vector2.new(),
		LayoutOrder = opts.order or 0,
		BackgroundColor3 = if primary then color else (if enabled then C.panelHi else C.panelLo),
		AutoButtonColor = enabled,
		Text = text,
		TextColor3 = if primary then C.ink elseif enabled then color:Lerp(Color3.new(1, 1, 1), 0.35) else C.faint,
		FontFace = F.display,
		TextSize = opts.textSize or 13,
		ZIndex = opts.zIndex or 3,
	}, parent)
	Kit.corner(b, 5)
	Kit.stroke(b, if enabled then color else C.stroke, 1, if enabled then 0.15 else 0.4)
	if primary then
		Kit.gradient(b, color:Lerp(Color3.new(1, 1, 1), 0.3), color)
	end
	b:SetAttribute("Enabled", enabled)
	b.Activated:Connect(function()
		if enabled then
			onClick()
		end
	end)
	return b
end
function Kit.chip(parent: Instance, text: string, color: Color3, order: number?): any
	local c = make("TextLabel", {
		Name = "Chip",
		BackgroundColor3 = color:Lerp(C.ink, 0.72),
		Size = UDim2.new(0, 0, 0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = text,
		TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.3),
		FontFace = F.uiBold,
		TextSize = 12,
		LayoutOrder = order or 0,
	}, parent)
	Kit.corner(c, 11)
	Kit.stroke(c, color, 1, 0.35)
	Kit.padding(c, 0, 10, 0, 10)
	return c
end

-- the Hunter modules (Hunter/R6Rig, Hunter/Looks), found once
local hunterMods: any = nil
function Kit.hunter(): (any, any)
	if hunterMods == nil then
		hunterMods = false
		pcall(function()
			local Shared = ReplicatedStorage:WaitForChild("LifeSim")
			local H = Shared:WaitForChild("Hunter")
			hunterMods = { R6Rig = require(H:WaitForChild("R6Rig")), Looks = require(H:WaitForChild("Looks")) }
		end)
	end
	if not hunterMods then
		return nil, nil
	end
	return hunterMods.R6Rig, hunterMods.Looks
end

-- how someone looks (Engine/Party.lookOf: { preset, overrides, seed, rank, class, civilian }):
-- their face and hair from their seed, their clothes from their preset (a Hunter with none
-- wears their class's outfit for their rank)
function Kit.lookFor(desc: any): any
	local _R6Rig, Looks = Kit.hunter()
	if not Looks or type(desc) ~= "table" then
		return nil
	end
	local s = math.max(1, math.floor(tonumber(desc.seed) or 1)) % 2147483647
	local function rand(a: number, b: number): number
		s = (s * 48271) % 2147483647
		return a + (s % math.max(1, b - a + 1))
	end
	local base = Looks.random(rand, if desc.civilian then { civilian = true } else { class = desc.class or "fighter" })
	local preset = desc.preset
	if preset == nil and not desc.civilian then
		preset = Looks.classPreset(desc.class or "fighter", desc.rank or 1)
	end
	local look = if preset then Looks.applyPreset(base, preset) else base
	for k, v in desc.overrides or {} do
		look[k] = v
	end
	return Looks.clean(look)
end

-- a portrait: their R6 rig in a ViewportFrame, lit, on a panel tinted by their rank. opts:
-- size, position, order, full (the whole body; else head and shoulders), zIndex
function Kit.portrait(parent: Instance, desc: any, opts: any?): any
	opts = opts or {}
	local rank = (desc and desc.rank) or 0
	local tint = Kit.rankColor(rank)
	local vp = make("ViewportFrame", {
		Name = "Portrait",
		Size = opts.size or UDim2.fromOffset(120, 120),
		Position = opts.position or UDim2.new(),
		AnchorPoint = opts.anchor or Vector2.new(),
		LayoutOrder = opts.order or 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Ambient = Color3.fromRGB(120, 132, 170),
		LightColor = Color3.fromRGB(235, 242, 255),
		LightDirection = Vector3.new(-0.4, -0.6, 1),
		ZIndex = opts.zIndex or 2,
	}, parent)
	Kit.gradient(vp, tint:Lerp(C.panel, 0.55), C.panelLo)
	if opts.corner ~= false then
		Kit.corner(vp, opts.cornerRadius or 6)
	end
	-- (looking straight down the axis at a rig that faces the camera)
	local cam = make("Camera", {
		FieldOfView = if opts.full then 30 else 32,
		CFrame = if opts.full then CFrame.new(0, 2.85, -13.5) * CFrame.Angles(0, math.pi, 0) else CFrame.new(0, 4.3, -7.4) * CFrame.Angles(0, math.pi, 0),
	}, vp)
	vp.CurrentCamera = cam
	local R6Rig = Kit.hunter()
	local look = Kit.lookFor(desc)
	if R6Rig and look then
		local ok, m = pcall(R6Rig.build, look, {
			name = "NPC",
			npc = true,
			civilian = desc.civilian == true,
			rank = if rank > 0 then rank else nil,
			weapon = if opts.full then nil else false,
		})
		if ok and m then
			for _, d in m:GetDescendants() do
				if d:IsA("BasePart") then
					d.Anchored = true
				end
			end
			m.Parent = vp
		end
	end
	return vp
end

-- a little entrance: grows from a little smaller, the way a card lands
function Kit.pop(frame: GuiObject, from: number?)
	local scale = frame:FindFirstChildOfClass("UIScale") or make("UIScale", { Scale = from or 0.8 }, frame)
	scale.Scale = from or 0.8
	TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end
-- a glow that flares and fades (a stroke)
function Kit.flare(stroke: UIStroke, color: Color3)
	stroke.Color = color
	stroke.Thickness = 6
	stroke.Transparency = 0
	TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Thickness = 2, Transparency = 0.25 }):Play()
end

-- the odds as a colour: good odds green, a coin flip gold, long odds red
function Kit.oddsColor(p: number): Color3
	if p >= 0.6 then
		return C.good
	elseif p >= 0.35 then
		return C.gold
	end
	return C.bad
end
-- a colour as RichText hex (RRGGBB)
function Kit.hex(c: Color3): string
	return string.format("%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
function Kit.pct(p: number?): string
	return tostring(math.floor((p or 0) * 100 + 0.5)) .. "%"
end
-- a factor of the odds as words: "+12%  Your bond: 62"
function Kit.factorText(f: any): string
	local d = math.floor((f.delta or 0) * 100 + (if (f.delta or 0) >= 0 then 0.5 else -0.5))
	return string.format("%s%d%%  %s", if d >= 0 then "+" else "", d, f.text or "")
end

-- a modal frame over a scrim, centred, navy with a mana rim. Returns the frame and the scrim.
function Kit.modal(gui: Instance, name: string, maxW: number, maxH: number, z: number): (any, any)
	local scrim = make("Frame", { Name = name, BackgroundColor3 = C.scrim, BackgroundTransparency = 0.25, Size = UDim2.fromScale(1, 1), ZIndex = z, Active = true }, gui)
	local frame = make("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.94, 0.92),
		BackgroundColor3 = C.panel,
		ZIndex = z + 1,
	}, scrim)
	make("UISizeConstraint", { MaxSize = Vector2.new(maxW, maxH) }, frame)
	Kit.corner(frame, 10)
	Kit.gradient(frame, C.panelHi, C.bg)
	local rim = Kit.stroke(frame, C.mana, 1.5, 0.25)
	-- the mana glow along the top edge
	local glow = make("Frame", { Name = "Glow", BackgroundColor3 = C.mana, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), ZIndex = z + 2 }, frame)
	make("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) }, glow)
	return frame, scrim, rim
end

-- ── the profile ─────────────────────────────────────────────────────────────
local current: any = nil

function NpcProfile.close()
	if current then
		current:Destroy()
		current = nil
	end
end

function NpcProfile.isOpen(): boolean
	return current ~= nil
end

local function interactionMeta(it: any, currency: string): (string, Color3)
	local bits = {}
	local color = C.mana
	if it.party and it.party.odds and it.id == "bl_ask" then
		table.insert(bits, Kit.pct(it.party.odds) .. " they say yes")
		color = Kit.oddsColor(it.party.odds)
	elseif it.clash then
		local p = it.clash.bestOdds or it.clash.odds or 0
		table.insert(bits, Kit.pct(p) .. " odds")
		color = Kit.oddsColor(p)
	end
	if it.cost and it.cost > 0 then
		table.insert(bits, tostring(it.cost) .. " " .. currency)
	end
	if not it.enabled and it.reason then
		table.insert(bits, it.reason)
		color = C.faint
	end
	return table.concat(bits, "  ·  "), color
end

function NpcProfile.open(gui: Instance, call: (string, any?) -> any, opts: any)
	NpcProfile.close()
	opts = opts or {}
	local currency = opts.currency or "million won"
	local frame, scrim = Kit.modal(gui, "NpcProfile", 900, 640, 40)
	current = scrim
	local root = scrim
	local Z = 42

	local profile: any = opts.profile
	local render: () -> ()
	local function apply(res: any)
		if not res then
			return
		end
		if opts.onResponse then
			opts.onResponse(res)
		end
		if res.profile then
			profile = res.profile
		end
		if opts.onChanged then
			opts.onChanged(res)
		end
		if res.result and opts.onResult then
			opts.onResult(res.result)
		end
		if current == root then
			render()
		end
	end
	local function act(it: any)
		local payload = { relId = profile.relId, id = it.id, profile = true }
		if it.clash and it.clash.best then
			-- a fight: the best way you have of fighting them (the odds shown are that way's)
			payload.approach = it.clash.best
		end
		if it.id == "bl_gift" and opts.pickGift then
			opts.pickGift(profile, function(giftId: string?)
				if giftId then
					payload.gift = giftId
					apply(call("partyDo", payload))
				end
			end)
			return
		end
		apply(call("partyDo", payload))
	end

	-- header
	local header = make("Frame", { Name = "Header", BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 14), Size = UDim2.new(1, -40, 0, 52), ZIndex = Z }, frame)
	local nameLabel = Kit.label(header, { Name = "Name", FontFace = F.display, TextSize = 28, Size = UDim2.new(1, -110, 0, 32), ZIndex = Z })
	local kindLabel = Kit.label(header, { Name = "Kind", FontFace = F.uiMedium, TextSize = 13, TextColor3 = C.sub, Position = UDim2.fromOffset(0, 32), Size = UDim2.new(1, -110, 0, 18), ZIndex = Z })
	Kit.button(header, "CLOSE", C.mana, NpcProfile.close, { name = "Close", anchor = Vector2.new(1, 0), position = UDim2.new(1, 0, 0, 4), size = UDim2.fromOffset(96, 32), zIndex = Z })

	-- left: them
	local left = make("Frame", { Name = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 76), Size = UDim2.new(0, 270, 1, -96), ZIndex = Z }, frame)
	-- right: what you know
	local body = make("ScrollingFrame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(310, 76),
		Size = UDim2.new(1, -330, 1, -96),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = C.mana,
		ZIndex = Z,
	}, frame)
	Kit.list(body, 10)
	Kit.padding(body, 0, 10, 12, 0)

	local function clear(f: Instance)
		for _, c in f:GetChildren() do
			if not (c:IsA("UIListLayout") or c:IsA("UIPadding")) then
				c:Destroy()
			end
		end
	end

	render = function()
		clear(left)
		clear(body)
		if not profile then
			Kit.label(body, { Text = "Loading...", TextColor3 = C.sub, LayoutOrder = 1 })
			return
		end
		local p = profile
		local rank = p.rank or 0
		local rcol = Kit.rankColor(rank)
		nameLabel.Text = p.name or "?"
		kindLabel.Text = string.format("%s  ·  age %s%s", p.kindName or "", tostring(p.age or "?"), if p.metAt then "  ·  you met at " .. tostring(p.metAt) else "")

		-- ── left ──
		local card = make("Frame", { Name = "Figure", BackgroundColor3 = C.panelLo, Size = UDim2.new(1, 0, 0, 330), ZIndex = Z }, left)
		Kit.corner(card, 8)
		local cardRim = Kit.stroke(card, rcol, if rank >= 5 then 2 else 1.5, 0.15)
		Kit.portrait(card, p.look, { full = true, size = UDim2.fromScale(1, 1), zIndex = Z + 1, cornerRadius = 8 })
		Kit.rankBadge(card, rank, 46, { Position = UDim2.fromOffset(10, 10), ZIndex = Z + 3 })
		if p.inParty then
			local cond = CONDITION[p.condition or "fine"] or CONDITION.fine
			local chip = Kit.chip(card, cond.text, cond.color)
			chip.AnchorPoint = Vector2.new(1, 0)
			chip.Position = UDim2.new(1, -10, 0, 12)
			chip.ZIndex = Z + 3
			local banner = Kit.label(card, { Name = "InParty", Text = "IN YOUR PARTY", FontFace = F.display, TextSize = 14, TextColor3 = C.ink, TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 0, BackgroundColor3 = C.mana, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.fromOffset(140, 24), ZIndex = Z + 3 })
			Kit.corner(banner, 12)
		end
		if p.canon then
			Kit.flare(cardRim, C.gold)
		end
		local info = make("Frame", { Name = "Info", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 340), Size = UDim2.new(1, 0, 1, -340), ZIndex = Z }, left)
		Kit.list(info, 4)
		Kit.label(info, { Name = "Class", Text = if rank > 0 then string.format("%s-rank %s", LETTERS[rank], p.className or "Hunter") else "No rank: never awakened", FontFace = F.display, TextSize = 18, TextColor3 = if rank == 6 then C.gold else rcol:Lerp(Color3.new(1, 1, 1), 0.2), LayoutOrder = 1, ZIndex = Z })
		if rank > 0 then
			local pips = string.rep("■", p.power or 0) .. string.rep("□", 5 - (p.power or 0))
			Kit.label(info, { Name = "Power", Text = "TRAINED UP  " .. pips, FontFace = F.mono, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = Z })
		end
		local what = p.work or p.role
		if what then
			Kit.label(info, { Name = "Work", Text = what, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.ui, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = Z })
		end
		if p.guild then
			Kit.label(info, { Name = "Guild", Text = p.guild, FontFace = F.uiBold, TextSize = 13, TextColor3 = C.manaHi, LayoutOrder = 4, ZIndex = Z })
		end

		-- ── right ──
		local order = 0
		local function nextOrder(): number
			order += 1
			return order
		end
		if p.quote then
			Kit.label(body, { Name = "Quote", Text = "\u{201C}" .. p.quote .. "\u{201D}", TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.serifItalic, TextSize = 16, TextColor3 = C.text, LayoutOrder = nextOrder(), ZIndex = Z })
		end
		-- personality
		local traits = make("Frame", { Name = "Traits", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = nextOrder(), ZIndex = Z }, body)
		Kit.list(traits, 6, true)
		for i, t in p.traits or {} do
			Kit.chip(traits, t.name, C.mana, i).ZIndex = Z
		end
		for _, t in p.traits or {} do
			Kit.label(body, { Name = "TraitDesc", Text = t.name .. ": " .. (t.desc or ""), TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, LayoutOrder = nextOrder(), ZIndex = Z })
		end
		-- the bond (and loyalty), or the odds they'd join
		local bars = make("Frame", { Name = "Bars", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = Z }, body)
		Kit.list(bars, 6)
		Kit.bar(bars, "Bond", p.bond or 0, 100, C.good, 1)
		if p.inParty and p.loyalty then
			Kit.bar(bars, "Loyalty", p.loyalty, 100, C.mana, 2)
		elseif p.odds then
			local odds = make("Frame", { Name = "Odds", BackgroundColor3 = C.panelHi, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 }, bars)
			Kit.corner(odds, 6)
			Kit.stroke(odds, C.stroke, 1, 0.2)
			Kit.padding(odds, 8, 10)
			Kit.list(odds, 2)
			Kit.label(odds, { Name = "Chance", RichText = true, Text = string.format("CHANCE THEY'D JOIN YOUR PARTY  <font color=\"#%s\"><b>%s</b></font>", Kit.hex(Kit.oddsColor(p.odds)), Kit.pct(p.odds)), FontFace = F.display, TextSize = 14, LayoutOrder = 0 })
			for i, f in p.factors or {} do
				if i <= 6 then
					Kit.label(odds, { Text = Kit.factorText(f), FontFace = F.ui, TextSize = 12, TextColor3 = if (f.delta or 0) >= 0 then C.good else C.bad, LayoutOrder = i })
				end
			end
			if p.why then
				Kit.label(odds, { Text = p.why, FontFace = F.uiBold, TextSize = 12, TextColor3 = C.warn, LayoutOrder = 20 })
			end
		end
		-- their story, as far as they've told it
		local told = #(p.backstory or {})
		Kit.heading(body, "Their story", nextOrder(), string.format("%d of %d told", told, told + (p.backstoryHidden or 0)))
		for i, line in p.backstory or {} do
			local row = make("Frame", { Name = "Story", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = Z }, body)
			Kit.label(row, { Text = tostring(i), FontFace = F.display, TextSize = 16, TextColor3 = C.mana, Size = UDim2.fromOffset(22, 20) })
			Kit.label(row, { Text = line, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.serif, TextSize = 14, Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -24, 0, 18) })
		end
		local hidden = p.backstoryHidden or 0
		if hidden > 0 then
			-- what's still untold: the next thing needs a bond (or just asking, if you're close enough)
			local ready = p.nextNeed ~= nil and (p.bond or 0) >= p.nextNeed
			local text = if ready
				then string.format("They're ready to tell you more. Ask about their past.  (%d more untold)", hidden)
				elseif p.nextNeed then string.format("Locked: they'll tell you more at a bond of %d.  (%d more untold)", p.nextNeed, hidden)
				else string.format("%d more untold", hidden)
			local locked = Kit.label(body, {
				Name = "Locked",
				Text = text,
				FontFace = F.uiMedium,
				TextSize = 12,
				TextColor3 = if ready then C.manaHi else C.faint,
				BackgroundTransparency = 0.1,
				BackgroundColor3 = if ready then C.manaLo else C.panelLo,
				Size = UDim2.new(1, 0, 0, 28),
				LayoutOrder = nextOrder(),
				ZIndex = Z,
			})
			Kit.corner(locked, 4)
			Kit.padding(locked, 0, 10, 0, 10)
			if ready then
				Kit.stroke(locked, C.mana, 1, 0.4)
			end
		end
		if told == 0 and (p.backstoryHidden or 0) == 0 then
			Kit.label(body, { Text = "Nothing to tell, yet.", FontFace = F.serifItalic, TextColor3 = C.faint, LayoutOrder = nextOrder() })
		end
		-- likes and dislikes
		Kit.heading(body, "What you've learned about them", nextOrder())
		local function listLine(title: string, list: { string }?, hidden: number?, color: Color3)
			local known = if list and #list > 0 then table.concat(list, ", ") else "nothing yet"
			local more = if (hidden or 0) > 0 then string.format("  (%d more to learn)", hidden) else ""
			Kit.label(body, { RichText = true, Text = string.format("<font color=\"#%s\"><b>%s</b></font>  %s%s", Kit.hex(color), title, known, more), TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.ui, TextSize = 13, LayoutOrder = nextOrder(), ZIndex = Z })
		end
		listLine("LOVES", p.likes, p.likesHidden, C.good)
		listLine("CAN'T STAND", p.dislikes, p.dislikesHidden, C.bad)
		-- your history together
		Kit.heading(body, "Your history together", nextOrder())
		local hist = p.history or {}
		if #hist == 0 then
			Kit.label(body, { Text = "Nothing yet.", FontFace = F.serifItalic, TextColor3 = C.faint, LayoutOrder = nextOrder() })
		end
		for i = #hist, math.max(1, #hist - 9), -1 do
			local h = hist[i]
			Kit.label(body, { RichText = true, Text = string.format("<font color=\"#%s\">AGE %s</font>   %s", Kit.hex(C.mana), tostring(h.age), h.text or ""), TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.ui, TextSize = 13, TextColor3 = C.text, LayoutOrder = nextOrder(), ZIndex = Z })
		end
		-- things to do
		Kit.heading(body, "Do something together", nextOrder())
		for _, it in p.interactions or {} do
			local row = make("Frame", { Name = "Do_" .. it.id, BackgroundColor3 = C.panelHi, BackgroundTransparency = if it.enabled then 0 else 0.4, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = Z }, body)
			Kit.corner(row, 6)
			Kit.stroke(row, if it.enabled then C.stroke else C.panelLo, 1, 0.1)
			Kit.padding(row, 8, 120, 8, 10)
			Kit.list(row, 2)
			Kit.label(row, { Text = it.name, FontFace = F.uiBold, TextSize = 14, TextColor3 = if it.enabled then C.text else C.faint, LayoutOrder = 1 })
			local meta, mcol = interactionMeta(it, currency)
			if meta ~= "" then
				Kit.label(row, { Text = meta, FontFace = F.uiBold, TextSize = 12, TextColor3 = mcol, LayoutOrder = 2 })
			end
			Kit.label(row, { Text = it.desc or "", TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 3 })
			local holder = make("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 110, 0.5, 0), Size = UDim2.fromOffset(100, 32), ZIndex = Z + 1 }, row)
			Kit.button(holder, if it.id == "bl_ask" then "ASK" elseif it.id == "bl_dismiss" then "PART WAYS" else "GO", if it.id == "bl_dismiss" then C.bad else C.mana, function()
				act(it)
			end, { name = "Go_" .. it.id, size = UDim2.fromScale(1, 1), enabled = it.enabled, primary = it.id == "bl_ask", zIndex = Z + 1 })
		end
	end

	render()
	Kit.pop(frame, 0.92)
	if not profile and opts.relId then
		task.spawn(function()
			local res = call("partyProfile", { relId = opts.relId })
			if res and res.profile then
				profile = res.profile
				if current == root then
					render()
				end
			end
		end)
	end
	return {
		frame = frame,
		root = root,
		set = function(p: any)
			profile = p
			render()
		end,
		close = NpcProfile.close,
	}
end

return NpcProfile
