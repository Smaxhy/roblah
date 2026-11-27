--[[
	THE HUNTER NEWS BOARD (BitLeveling): what the world around this life is doing.
		NEWS        headlines: the city, the country, the world, and the canon story's public events
		INCIDENTS   the Gates near this life this year and recent years, what came of each, and what you did
		RECORD      what this life has lived through (awakening, raids, breaks, evacuations...)
		LIVE        the incidents happening right now in the live city
	Opened from the dock; reads server handler hwBoard (Engine/HunterWorld.view).
]]

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent:WaitForChild("Theme"))
local C, F = Theme.colors, Theme.fonts

local Board = {}

local TONES = {
	danger = Color3.fromRGB(226, 86, 76),
	strange = Color3.fromRGB(170, 140, 255),
	good = Color3.fromRGB(122, 194, 140),
	plain = Color3.fromRGB(220, 224, 232),
}
local TAG_WORDS = { ["local"] = "LOCAL", national = "NATIONAL", world = "WORLD", canon = "STORY", live = "LIVE" }
local OUTCOMES = {
	cleared = "Cleared",
	break_contained = "Broke · contained",
	break_spread = "Broke · spread",
	zone_lost = "Area lost",
	red_survivors = "Red Gate · survivors",
	red_lost = "Red Gate · no survivors",
	double_survivors = "Double Dungeon · survivors",
	double_lost = "Double Dungeon · massacre",
}
local ROLES = {
	evacuated = "you got clear", helped = "you helped people out", filmed = "you filmed it", reported = "you called it in",
	held = "you held the line", entered = "you went in", fled = "you ran", sheltered = "you sheltered", fought = "you fought",
	raided = "you raided it", declined = "you turned it down", caught = "you were caught in it",
}
local KIND_WORDS = {
	awakened = "Awakened", reawakened = "Reawakened", city = "A Gate in your street", ["break"] = "Dungeon Break", raid = "Raid",
	red = "Red Gate", double = "Double Dungeon", evacuated = "Evacuated", rewritten = "The world was rewritten",
}
local RANKS = { "E", "D", "C", "B", "A", "S" }

local open: Frame? = nil

local function make(className: string, props: any, parent: Instance?): any
	local inst = Instance.new(className)
	for k, v in props do
		(inst :: any)[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function line(parent: Instance, order: number, chip: string?, chipColor: Color3?, text: string, color: Color3?)
	local row = make("Frame", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.panelHi, BackgroundTransparency = 0.2 }, parent)
	make("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
	make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, row)
	local x = 0
	if chip then
		local c = make("TextLabel", { Size = UDim2.fromOffset(78, 18), BackgroundColor3 = chipColor or C.accentLo, Text = chip, TextColor3 = Color3.new(1, 1, 1), FontFace = F.display, TextSize = 12 }, row)
		make("UICorner", { CornerRadius = UDim.new(0, 3) }, c)
		x = 86
	end
	make("TextLabel", {
		Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -x, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		Text = text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = color or C.text, FontFace = F.ui, TextSize = 14,
	}, row)
end

function Board.close()
	if open then
		open:Destroy()
		open = nil
	end
end

function Board.open(gui: Instance, call: (string, any?) -> any, liveList: { any }?, opts: any?)
	Board.close()
	local frame = make("Frame", { Name = "HunterBoard", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.86, 0, 0.82, 0), BackgroundColor3 = C.panel, ZIndex = 20 }, gui)
	make("UISizeConstraint", { MaxSize = Vector2.new(760, 680) }, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, frame)
	make("UIStroke", { Color = C.accent, Transparency = 0.35, Thickness = 1.5 }, frame)
	open = frame
	local head = make("TextLabel", { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -120, 0, 30), BackgroundTransparency = 1, Text = "HUNTER NEWS", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.accentHi, FontFace = F.display, TextSize = 26 }, frame)
	local sub = make("TextLabel", { Position = UDim2.fromOffset(16, 40), Size = UDim2.new(1, -32, 0, 20), BackgroundTransparency = 1, Text = "Loading...", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, FontFace = F.uiMedium, TextSize = 14 }, frame)
	local closeBtn = make("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(90, 30), BackgroundColor3 = C.panelHi, Text = "CLOSE", TextColor3 = C.text, FontFace = F.display, TextSize = 14 }, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 5) }, closeBtn)
	closeBtn.Activated:Connect(Board.close)
	local tabs = make("Frame", { Position = UDim2.fromOffset(16, 66), Size = UDim2.new(1, -32, 0, 30), BackgroundTransparency = 1 }, frame)
	make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, tabs)
	local body = make("ScrollingFrame", { Position = UDim2.fromOffset(16, 104), Size = UDim2.new(1, -32, 1, -116), BackgroundTransparency = 1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0 }, frame)
	make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, body)
	local _ = head

	local board: any = nil
	local function clear()
		for _, c in body:GetChildren() do
			if not c:IsA("UIListLayout") then
				c:Destroy()
			end
		end
	end
	local function showNews()
		clear()
		if not board or #board.news == 0 then
			line(body, 1, nil, nil, if board and board.beforeGates then "There are no Gates yet. The news is about ordinary things." else "No news yet.", C.sub)
			return
		end
		for i, n in board.news do
			line(body, i, (TAG_WORDS[n.tag] or "NEWS") .. " · " .. tostring(n.year), if n.tag == "canon" then Color3.fromRGB(90, 70, 160) elseif n.tag == "live" then C.crimson else C.accentLo, n.text, TONES[n.tone or "plain"])
		end
	end
	local function showIncidents()
		clear()
		if not board or #board.recent == 0 then
			line(body, 1, nil, nil, "No Gates near you yet.", C.sub)
			return
		end
		for i, r in board.recent do
			local kind = if r.kind == "red" then "RED GATE" elseif r.kind == "double" then "DOUBLE" else ((RANKS[r.rank] or "?") .. "-RANK")
			local you = if r.player and r.player.role then (" · " .. (ROLES[r.player.role] or r.player.role) .. (if r.player.won == true then " (it went well)" elseif r.player.won == false then " (it went badly)" else "")) else ""
			local text = string.format("%s, %s · %s%s%s", r.place or "?", r.city or "", OUTCOMES[r.outcome or ""] or tostring(r.outcome), if (r.dead or 0) > 0 then string.format(" · %d dead", r.dead) else "", you)
			line(body, i, kind .. " · " .. tostring(r.year), if r.broke then C.crimson elseif r.kind ~= "gate" then Color3.fromRGB(110, 70, 170) else C.accentLo, text, if r.broke then TONES.danger else C.text)
		end
	end
	local function showRecord()
		clear()
		if not board then
			return
		end
		local c = board.counts or {}
		line(body, 0, "TOTALS", C.accentLo, string.format("Incidents lived through: %d · survived: %d · raids: %d · Red Gates: %d · Double Dungeons: %d · people saved: %d", c.witnessed or 0, c.survived or 0, c.raids or 0, c.red or 0, c.double or 0, c.saved or 0))
		for i, h in board.history do
			local what = KIND_WORDS[h.kind] or h.kind
			local detail = ""
			if h.rank then
				detail ..= " · " .. (RANKS[h.rank] or "?") .. "-rank"
			end
			if h.place then
				detail ..= " · " .. tostring(h.place)
			end
			if h.role then
				detail ..= " · " .. (ROLES[h.role] or h.role)
			end
			if h.class then
				detail ..= " · " .. string.upper(string.sub(h.class, 1, 1)) .. string.sub(h.class, 2)
			end
			line(body, i, "AGE " .. tostring(h.age or "?"), C.accentLo, what .. detail)
		end
	end
	local function showLive()
		clear()
		local list = liveList or {}
		if #list == 0 then
			line(body, 1, nil, nil, "Nothing is happening in the live city right now. Walk the city and you'll be there when it does.", C.sub)
			return
		end
		for i, s in list do
			line(body, i, string.upper(s.stage or "?"), if s.broke or s.red then C.crimson else C.accentLo, string.format("%s-rank reading at %s · %s", RANKS[s.rank] or "?", s.label or "?", s.headline or ""), if s.broke or s.red then TONES.danger else C.text)
		end
	end
	-- every fate a life can end in: found ones in full, locked ones as a hint
	local fates: any = nil
	local current: any = nil
	local STAR_COLORS = { Color3.fromRGB(150, 156, 166), Color3.fromRGB(110, 190, 140), Color3.fromRGB(100, 160, 255), Color3.fromRGB(180, 110, 255), Color3.fromRGB(255, 190, 70) }
	local function showEndings()
		clear()
		if not fates then
			line(body, 1, nil, nil, "Loading your endings...", C.sub)
			task.spawn(function()
				local res = call("hwFates")
				fates = (res and res.fates) or { list = {}, found = 0, total = 0 }
				if open and current == showEndings then
					showEndings()
				end
			end)
			return
		end
		line(body, 0, "FOUND", C.accentLo, string.format("%d of %d endings. Each new one is worth 1 Glow. Non-canon endings happen only on the world line where the Gates were kept.", fates.found, fates.total), C.sub)
		for i, f in fates.list do
			local stars = string.rep("★", f.rarity or 1)
			local chip = (if f.canon then "" else "NC ") .. stars
			local text = if f.count > 0 then string.format("%s: %s%s", f.name, f.desc or "", if f.count > 1 then string.format(" (x%d)", f.count) else "") else string.format("???  Hint: %s", f.hint or "keep living")
			line(body, i, chip, if f.count > 0 then STAR_COLORS[math.clamp(f.rarity or 1, 1, 5)] else C.panelHi, text, if f.count > 0 then C.text else C.faint)
		end
	end
	current = showNews
	for _, t in { { "NEWS", showNews }, { "INCIDENTS", showIncidents }, { "RECORD", showRecord }, { "LIVE", showLive }, { "ENDINGS", showEndings } } do
		local b = make("TextButton", { Size = UDim2.fromOffset(112, 30), BackgroundColor3 = C.panelHi, Text = t[1], TextColor3 = C.text, FontFace = F.display, TextSize = 14 }, tabs)
		make("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
		b.Activated:Connect(function()
			current = t[2]
			current()
		end)
	end
	if opts and opts.tab == "endings" then
		current = showEndings
	end
	frame.Size = UDim2.new(0.86, 0, 0.78, 0)
	TweenService:Create(frame, TweenInfo.new(0.18), { Size = UDim2.new(0.86, 0, 0.82, 0) }):Play()
	task.spawn(function()
		local res = call("hwBoard")
		board = res and res.board
		if not open then
			return
		end
		if board then
			local yearText = if board.beforeGates then string.format("%d years before the Gates", -board.gateYear) else string.format("Gate Year %d", board.gateYear)
			sub.Text = string.format("%s · %s · %s, %s · %s%s", board.modeName or "", yearText, board.city or "?", board.country or "", if board.rank then board.rank .. "-rank Hunter" else "unawakened", if board.rewritten then " · the world was rewritten" else "")
		else
			sub.Text = "Start a life to follow the world's news."
		end
		current()
	end)
end

return Board
