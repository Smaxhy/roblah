--[[
	The mod menu (admins only; the server checks every action: server/Admin.luau).
		AdminMenu.open(ctx, layer) -> the sheet
	Open it from the MOD button at the top right, with F2, with /mod in chat, or from the Menu.

	(v0.17) In tabs:
	  Server   world events, today's event, an announcement (filtered like chat)
	  Player   gifts, any stat (past 100 to 400: the limit rises to meet it), make any event happen,
	           traits, style and mastery, form, talent, gear and augment arms, conditions, career,
	           standing with every faction, flags
	  Look     character customization for the picked player: body, skin, hair, eyes, outfit...
	  Power    every stat at a number, limit breaks, lifespan, a Color's name, old blood,
	           techniques, trainers
	  Fights   start any boss battle in turns (the extreme ones too), the extreme events
	  Codes    the redeem codes that are live, make one, take one away
	  Effects  preview the battle effects on your own screen
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Sheets = require(script.Parent.Sheets)
local Vfx = require(script.Parent.Vfx)
local Arena = require(script.Parent.Arena)
local World3D = require(script.Parent.World3D)
local Fx3D = require(script.Parent.Fx3D)
local Emblem = require(script.Parent.Emblem)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local AdminMenu = {}

local TABS = { "Server", "Player", "Talents", "Look", "Power", "Fights", "Codes", "Effects" }
-- (v0.18) every tab has its icon (UI/Emblem.luau)
local TAB_ICON = {
	Server = "tab.city", Player = "tab.you", Talents = "misc.star", Look = "tab.light",
	Power = "stat.justice", Fights = "misc.fight", Codes = "cur.lunacy", Effects = "style.charge",
}
-- the talents' rarities, as the City names them (pack.talents.tiers)
local TIERS = {
	{ id = "common", name = "Ordinary", color = Color3.fromRGB(190, 190, 196) },
	{ id = "uncommon", name = "Promising", color = Color3.fromRGB(120, 200, 140) },
	{ id = "rare", name = "Gifted", color = Color3.fromRGB(100, 160, 240) },
	{ id = "epic", name = "Prodigy", color = Color3.fromRGB(180, 110, 240) },
	{ id = "legendary", name = "One in a District", color = Color3.fromRGB(255, 196, 80) },
	{ id = "unreal", name = "One in the City", color = Color3.fromRGB(255, 70, 90) },
}
local TIER_OF = {}
for _, t in TIERS do
	TIER_OF[t.id] = t
end
local SINS = { "wrath", "lust", "sloth", "gluttony", "gloom", "pride", "envy" }

-- a section heading: an accent bar, an icon, the title in capitals
local function sectionTitle(parent: Instance, text: string, order: number, icon: string?, color: Color3?)
	local col = color or C.accentHi
	local holder = new("Frame", { Name = "Heading", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = order, ZIndex = 2, Parent = parent })
	new("Frame", { BackgroundColor3 = col, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 7), Size = UDim2.fromOffset(4, 18), ZIndex = 3, Parent = holder }, { Kit.corner(2) })
	local x = 12
	if icon then
		local ok, e = pcall(Emblem.make, icon, 18, col)
		if ok and e then
			e.Position = UDim2.fromOffset(12, 6)
			e.ZIndex = 3
			e.Parent = holder
			x = 36
		end
	end
	Kit.caps({ Text = text, FontFace = F.display, TextSize = 15, TextColor3 = C.text, Position = UDim2.fromOffset(x, 6), Size = UDim2.new(1, -x, 0, 20), ZIndex = 3, Parent = holder })
	new("Frame", { BackgroundColor3 = C.stroke, BackgroundTransparency = 0.5, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1), ZIndex = 3, Parent = holder })
	return holder
end

-- a small rounded label
local function badge(parent: Instance, text: string, color: Color3, order: number)
	return new("TextLabel", {
		BackgroundColor3 = color,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		FontFace = F.uiBold,
		TextSize = 12,
		TextColor3 = color,
		Text = text,
		LayoutOrder = order,
		ZIndex = 3,
		Parent = parent,
	}, { Kit.corner(12), Kit.padding(0, 10, 0, 10), Kit.stroke(color, 1, 0.55) })
end

-- the pack's stats (info.stats.order), then Sanity, money, age and renown
local function statKeys(ctx): { string }
	local out = {}
	for _, key in (ctx.info and ctx.info.stats and ctx.info.stats.order) or { "fortitude", "prudence", "temperance", "justice" } do
		table.insert(out, key)
	end
	for _, key in { "sanity", "money", "age", "renown" } do
		table.insert(out, key)
	end
	return out
end

local function textBox(parent: Instance, order: number, placeholder: string, width: UDim?): TextBox
	local box: TextBox = new("TextBox", {
		Name = "Input",
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Size = UDim2.new(width or UDim.new(1, 0), UDim.new(0, 34)),
		Text = "",
		PlaceholderText = placeholder,
		PlaceholderColor3 = C.faint,
		ClearTextOnFocus = false,
		FontFace = F.ui,
		TextSize = 14,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, { Kit.corner(2), Kit.stroke(C.stroke, 1, 0.2), Kit.padding(0, 10, 0, 10) }) :: any
	return box
end

local function row(parent: Instance, order: number): Frame
	return new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, ZIndex = 2, Parent = parent }, {
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
end

local function chip(parent: Instance, name: string, text: string, style: string, order: number, onClick)
	local b = Kit.button({ name = name, text = text, plain = true, style = style, size = UDim2.new(0, 0, 0, 30), autoSize = Enum.AutomaticSize.X, padding = 10, order = order, textSize = 12, zIndex = 2, onClick = onClick })
	b.TextWrapped = false
	b.Parent = parent
	return b
end

-- (v0.18) a talent as a card: rarity stripe and colour, its sin, what it does, and two buttons
local function talentCard(parent: Instance, t, order: number, isTheirs: boolean, has: boolean, onSet, onToggle)
	local tier = TIER_OF[t.tier or ""] or TIERS[1]
	local card = new("Frame", { Name = "Talent_" .. t.id, BackgroundColor3 = C.panel, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 2, Parent = parent }, {
		Kit.corner(6), Kit.stroke(tier.color, if isTheirs then 2 else 1, if isTheirs then 0.05 else 0.55),
	})
	new("Frame", { BackgroundColor3 = tier.color, BorderSizePixel = 0, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(0, 4, 1, -12), ZIndex = 3, Parent = card }, { Kit.corner(2) })
	if t.affinity then
		local ok, e = pcall(Emblem.make, "sin." .. t.affinity, 24)
		if ok and e then
			e.AnchorPoint = Vector2.new(1, 0)
			e.Position = UDim2.new(1, -8, 0, 8)
			e.ZIndex = 3
			e.Parent = card
		end
	end
	Kit.text({ Text = Format.escape(t.name or t.id), FontFace = F.uiBold, TextSize = 15, TextColor3 = C.text, AutomaticSize = Enum.AutomaticSize.None, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(18, 8), Size = UDim2.new(1, -56, 0, 18), ZIndex = 3, Parent = card })
	Kit.caps({ Text = tier.name .. (if t.affinity then "  ·  " .. string.upper(t.affinity) else ""), FontFace = F.displayMed, TextSize = 11, TextColor3 = tier.color, Position = UDim2.fromOffset(18, 28), Size = UDim2.new(1, -56, 0, 14), ZIndex = 3, Parent = card })
	Kit.text({ Text = Format.escape(t.desc or ""), FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, AutomaticSize = Enum.AutomaticSize.None, Position = UDim2.fromOffset(18, 46), Size = UDim2.new(1, -28, 0, 46), ZIndex = 3, Parent = card })
	Kit.button({ name = "SetTalent_" .. t.id, text = if isTheirs then "Their talent" else "Make it their talent", style = if isTheirs then "ghost" else "primary", size = UDim2.new(0.5, -14, 0, 28), position = UDim2.new(0, 18, 1, -36), textSize = 12, zIndex = 3, enabled = not isTheirs, onClick = onSet, parent = card })
	Kit.button({ name = "ToggleTalent_" .. t.id, text = if has then "Take away" else "Add as an extra", style = if has then "danger" else "secondary", size = UDim2.new(0.5, -14, 0, 28), position = UDim2.new(0.5, 4, 1, -36), textSize = 12, zIndex = 3, onClick = onToggle, parent = card })
	return card
end

-- a trait as a card: what it is, how it's earned, and give / take away
local function traitCard(parent: Instance, t, order: number, has: boolean, onToggle)
	local col = if t.earned then C.accentHi else C.sub
	local card = new("Frame", { Name = "Trait_" .. t.id, BackgroundColor3 = C.panel, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 2, Parent = parent }, {
		Kit.corner(6), Kit.stroke(if has then C.accentHi else C.stroke, 1, if has then 0.1 else 0.45),
	})
	Kit.text({ Text = Format.escape(t.name or t.id), FontFace = F.uiBold, TextSize = 14, TextColor3 = C.text, AutomaticSize = Enum.AutomaticSize.None, TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 18), ZIndex = 3, Parent = card })
	Kit.caps({ Text = if t.earned then "Earned by itself" elseif has then "They have it" else "Trait", FontFace = F.displayMed, TextSize = 11, TextColor3 = col, Position = UDim2.fromOffset(12, 27), Size = UDim2.new(1, -24, 0, 14), ZIndex = 3, Parent = card })
	Kit.text({ Text = Format.escape(t.desc or ""), FontFace = F.ui, TextSize = 12, TextColor3 = C.sub, AutomaticSize = Enum.AutomaticSize.None, Position = UDim2.fromOffset(12, 44), Size = UDim2.new(1, -24, 0, 30), ZIndex = 3, Parent = card })
	Kit.button({ name = "ToggleTrait_" .. t.id, text = if has then "Take away" else "Give", style = if has then "danger" else "primary", size = UDim2.new(1, -24, 0, 26), position = UDim2.new(0, 12, 1, -32), textSize = 12, zIndex = 3, onClick = onToggle, parent = card })
	return card
end

-- A searchable list of { id, name }: shows up to `limit` matches as buttons.
local function pickList(parent: Instance, order: number, items, placeholder: string, onPick, limit: number?, selected: string?)
	local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, ZIndex = 2, Parent = parent }, { Kit.list(4) })
	local search = textBox(holder, 1, placeholder)
	local results = row(holder, 2)
	local function refresh()
		Sheets.clear(results)
		local q = string.lower(search.Text)
		local shown = 0
		for _, item in items or {} do
			if shown >= (limit or 24) then
				break
			end
			if q == "" or string.find(string.lower(item.name), q, 1, true) or string.find(string.lower(item.id), q, 1, true) then
				shown += 1
				chip(results, "Pick_" .. item.id, item.name, if item.id == selected then "primary" else "secondary", shown, function()
					onPick(item)
				end)
			end
		end
		if shown == 0 then
			Kit.caps({ Text = "Nothing matches", FontFace = F.displayMed, TextSize = 12, TextColor3 = C.faint, Size = UDim2.new(1, 0, 0, 20), ZIndex = 2, Parent = results })
		end
	end
	search:GetPropertyChangedSignal("Text"):Connect(refresh)
	refresh()
	return holder
end

function AdminMenu.open(ctx, layer: Instance)
	local sheet = Sheets.open(layer, "Mod menu", nil, { wide = true })
	local content = sheet.content
	local state = nil
	local target: number? = nil
	local tab = "Player"
	-- (v0.18) the Talents tab's filters, kept while the menu redraws
	local tf = { tier = "all", sin = nil, query = "", traitQuery = "", show = 24, traitShow = 18, earnedOnly = false }
	local fill

	local catalog = nil -- (v0.18) sent once, when the menu opens; kept here after that

	-- (v0.18) plays one 3D effect for real: you (or a second dummy, with no life going) and a
	-- training dummy in the gym. The stage covers everything under the cinema layer, this menu
	-- too, and gives it back when it closes.
	local previewing = false
	local function preview3D(label: string, play)
		local stageLayer = ctx.cinemaLayer
		if previewing or not stageLayer or not World3D.available(ctx) then
			return
		end
		previewing = true
		local life = ctx.state.life
		local me = if life and life.appearance
			then { key = "me", name = life.name or "You", appearance = life.appearance, me = true }
			else { key = "me", name = "Dummy", dummy = true }
		local holder = new("Frame", { Name = "FxPreview", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = stageLayer })
		local ok, arena = pcall(Arena.open, ctx, holder, {
			set = "gym",
			time = "night",
			seed = "preview",
			left = { me },
			right = { { key = "dummy", name = "Training dummy", dummy = true } },
			rect = { 0.1, 0.16, 0.9, 0.68 },
		})
		if not ok or not arena then
			holder:Destroy()
			previewing = false
			return
		end
		-- dark fades above and below, as around a fight's panels: the set ends there (a tall
		-- phone screen sees past its walls and floor, so it gets more of them)
		local abs = holder.AbsoluteSize
		local tall = abs.Y > abs.X
		new("Frame", {
			Name = "ScrimBottom",
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, if tall then 0.5 else 0.42),
			ZIndex = 2,
			Parent = holder,
		}, {
			new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.15), NumberSequenceKeypoint.new(1, 0) }) }),
		})
		new("Frame", {
			Name = "ScrimTop",
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, if tall then 0.32 else 0.16),
			ZIndex = 2,
			Parent = holder,
		}, {
			new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.6, 0.15), NumberSequenceKeypoint.new(1, 1) }) }),
		})
		Kit.caps({
			Text = "Preview: " .. label,
			FontFace = F.display,
			TextSize = 20,
			TextColor3 = C.accentHi,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -64),
			Size = UDim2.new(0.8, 0, 0, 26),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 5,
			Parent = holder,
		})
		task.spawn(function()
			task.wait(0.7)
			pcall(play, arena)
			task.wait(2.8)
			pcall(arena.close, arena)
			holder:Destroy()
			previewing = false
		end)
	end
	local function call(payload)
		ctx.actions.adminCall(payload, function(res)
			if res and res.admin then
				state = res.admin
				if state.catalog then
					catalog = state.catalog
				else
					state.catalog = catalog
				end
			end
			if res and ctx.toast then
				ctx.toast(if res.ok then (res.toast or "Done.") else (res.error or "That didn't work."))
			end
			fill()
		end)
	end
	local function onTarget(payload)
		payload.target = target
		call(payload)
	end

	function fill()
		Sheets.clear(content)
		if sheet.isClosed() then
			return
		end
		if not state then
			Kit.text({ Text = "Loading...", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, ZIndex = 2, Parent = content })
			return
		end
		local cat = state.catalog
		local order = 0
		local function nextOrder()
			order += 1
			return order
		end

		-- the tabs: a grid of icon buttons, the open one lit
		local wide = content.AbsoluteSize.X >= 560
		local tabs = new("Frame", { Name = "Tabs", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
			new("UIGridLayout", { CellSize = UDim2.new(if wide then 0.125 else 0.25, -6, 0, 58), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		for i, name in TABS do
			local on = name == tab
			local b = Kit.button({ name = "AdminTab_" .. name, text = "", style = if on then "primary" else "secondary", size = UDim2.fromScale(1, 1), order = i, zIndex = 2, onClick = function()
				tab = name
				fill()
			end })
			b.Parent = tabs
			local okIcon, icon = pcall(Emblem.make, TAB_ICON[name] or "misc.star", 22, if on then C.ink else C.accentHi)
			if okIcon and icon then
				icon.AnchorPoint = Vector2.new(0.5, 0)
				icon.Position = UDim2.new(0.5, 0, 0, 7)
				icon.ZIndex = 3
				icon.Parent = b
			end
			Kit.caps({ Text = name, FontFace = F.displayMed, TextSize = 12, TextColor3 = if on then C.ink else C.text, TextXAlignment = Enum.TextXAlignment.Center, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -5), Size = UDim2.new(1, -4, 0, 16), ZIndex = 3, Parent = b })
		end

		-- ── Server ──
		if tab == "Server" then
			sectionTitle(content, "World event" .. (if state.worldActive then "  ·  running: " .. state.worldActive else ""), nextOrder())
			pickList(content, nextOrder(), cat.worldEvents, "Search world events", function(item)
				call({ op = "world", id = item.id })
			end)
			if state.worldActive then
				Kit.button({ name = "EndWorld", text = "End the world event", style = "danger", size = UDim2.new(1, 0, 0, 34), order = nextOrder(), textSize = 13, zIndex = 2, onClick = function()
					call({ op = "world", id = state.worldActive, on = false })
				end }).Parent = content
			end
			sectionTitle(content, "Today's event" .. (if state.daily then "  ·  now: " .. state.daily else ""), nextOrder())
			pickList(content, nextOrder(), cat.daily, "Search daily events", function(item)
				call({ op = "daily", id = item.id })
			end)
			sectionTitle(content, "Announcement (filtered like chat)", nextOrder())
			local msg = textBox(content, nextOrder(), "Type an announcement for everyone")
			Kit.button({ name = "Announce", text = "Announce", style = "primary", size = UDim2.new(1, 0, 0, 34), order = nextOrder(), textSize = 13, zIndex = 2, onClick = function()
				call({ op = "announce", text = msg.Text })
			end }).Parent = content
			return
		end

		-- ── Codes ──
		if tab == "Codes" then
			sectionTitle(content, "Live codes (players type them in the store)", nextOrder())
			if #(state.codes or {}) == 0 then
				Kit.text({ Text = "No codes yet.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
			end
			for _, c in state.codes or {} do
				local line = row(content, nextOrder())
				Kit.text({ Text = string.format("<b>%s</b>  ·  %s%s%s", Format.escape(c.code), Format.escape(table.concat(c.grants or {}, ", ")), if c.builtIn then "  ·  in Config" else "", if c.expires then "  ·  expires " .. os.date("%Y-%m-%d", c.expires) else ""), FontFace = F.ui, TextSize = 13, TextColor3 = C.text, Size = UDim2.new(0.7, 0, 0, 30), ZIndex = 2, Parent = line })
				if not c.builtIn then
					chip(line, "RemoveCode_" .. c.code, "Remove", "danger", 2, function()
						call({ op = "codeRemove", code = c.code })
					end)
				end
			end
			sectionTitle(content, "Make a code", nextOrder())
			local codeBox = textBox(content, nextOrder(), "The code (3-24 letters/numbers), e.g. SUMMER")
			local grantsBox = textBox(content, nextOrder(), "What it gives: lunacy:100, light:5, rolls:3, boost:heal, outfit:color_coat")
			local noteBox = textBox(content, nextOrder(), "Message when it's redeemed (optional)")
			local daysBox = textBox(content, nextOrder(), "Days until it expires (empty = never)")
			local presets = row(content, nextOrder())
			for i, p in { { "100 Lunacy", "lunacy:100" }, { "500 Lunacy", "lunacy:500" }, { "10 Light", "light:10" }, { "5 rolls", "rolls:5" }, { "Second Wind", "boost:heal" } } do
				chip(presets, "Preset_" .. i, p[1], "secondary", i, function()
					grantsBox.Text = if grantsBox.Text == "" then p[2] else grantsBox.Text .. ", " .. p[2]
				end)
			end
			Kit.button({ name = "MakeCode", text = "Make it live", style = "primary", size = UDim2.new(1, 0, 0, 36), order = nextOrder(), textSize = 14, zIndex = 2, onClick = function()
				call({ op = "codeAdd", code = codeBox.Text, grants = grantsBox.Text, note = noteBox.Text, days = tonumber(daysBox.Text) })
			end }).Parent = content
			return
		end

		-- ── Effects (on your own screen) ──
		if tab == "Effects" then
			-- (v0.18) the real 3D effects, on the stage: you and a training dummy for a few seconds
			sectionTitle(content, "Preview the 3D fight effects", nextOrder())
			Kit.text({
				Text = if World3D.available(ctx)
					then "Each one plays on the 3D stage for a few seconds, then the menu comes back."
					else "The 3D stage is off (Settings, 3D fight effects), so these can't play.",
				FontFace = F.ui,
				TextSize = 12,
				TextColor3 = C.sub,
				TextWrapped = true,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				LayoutOrder = nextOrder(),
				ZIndex = 2,
				Parent = content,
			})
			local fx3 = row(content, nextOrder())
			local function hit(opts)
				return function(ar)
					ar:strike("me", "dummy", opts)
				end
			end
			local list3 = {
				{ "Hit", hit({}) },
				{ "Heavy hit", hit({ heavy = true }) },
				{ "Critical", hit({ crit = true }) },
				{ "Burn", hit({ status = "burn" }) },
				{ "Bleed", hit({ status = "bleed" }) },
				{ "Tremor", hit({ status = "tremor" }) },
				{ "Rupture", hit({ status = "rupture" }) },
				{ "Sinking", hit({ status = "sinking" }) },
				{ "Poise", hit({ status = "poise" }) },
				{ "Charge", hit({ status = "charge" }) },
				{ "Clash", function(ar) ar:clash("me", "dummy") end },
				{ "Lightning", function(ar)
					local a, b = ar:actor("me"), ar:actor("dummy")
					if a and b then
						Fx3D.lightning(ar.w, ar:hitPos(a) + Vector3.new(0, 1.5, 0), ar:hitPos(b), C.accentHi)
						ar.w:shake("medium")
					end
				end },
				{ "Guard", function(ar) ar:guard("me") end },
				{ "Heal", function(ar) ar:heal("me") end },
				{ "Phase change", function(ar) ar:phase("dummy", C.crimsonHi) end },
				{ "Knock down", function(ar) ar:down("dummy") end },
				{ "Victory", function(ar) ar:victory("me") end },
				{ "Big shake", function(ar) ar.w:shake("huge") end },
			}
			for i, e in list3 do
				chip(fx3, "Fx3_" .. i, e[1], "secondary", i, function()
					preview3D(e[1], e[2])
				end)
			end
			sectionTitle(content, "Preview the battle effects", nextOrder())
			local fx = row(content, nextOrder())
			local at = Vector2.new(0.5, 0.45)
			local screen = layer
			local list = {
				{ "Hit", function() Vfx.impact(screen, at, { shake = true }) end },
				{ "Heavy hit", function() Vfx.impact(screen, at, { heavy = true, shake = true }) end },
				{ "Burn", function() Vfx.impact(screen, at, { status = "burn" }) end },
				{ "Bleed", function() Vfx.impact(screen, at, { status = "bleed" }) end },
				{ "Tremor", function() Vfx.impact(screen, at, { status = "tremor" }) end },
				{ "Rupture", function() Vfx.impact(screen, at, { status = "rupture" }) end },
				{ "Sinking", function() Vfx.impact(screen, at, { status = "sinking" }) end },
				{ "Poise", function() Vfx.impact(screen, at, { status = "poise" }) end },
				{ "Charge", function() Vfx.impact(screen, at, { status = "charge" }) end },
				{ "Heal", function() Vfx.heal(screen, at) end },
				{ "Guard", function() Vfx.guard(screen, at) end },
				{ "Damage number", function() Vfx.number(screen, at, "128", C.accentHi, true) end },
				{ "Banner", function() Vfx.banner(screen, "Phase 2", "The lantern opens its shutter.", C.crimsonHi) end },
				{ "Confetti", function() Vfx.confetti(screen) end },
			}
			for i, e in list do
				chip(fx, "Fx_" .. i, e[1], "secondary", i, e[2])
			end
			return
		end

		-- the rest are about one player
		sectionTitle(content, "Player", nextOrder())
		local pick = row(content, nextOrder())
		local selected = nil
		for i, p in state.players do
			if target == nil and i == 1 then
				target = p.userId
			end
			if p.userId == target then
				selected = p
			end
			chip(pick, "Player_" .. p.userId, p.name, if p.userId == target then "primary" else "secondary", i, function()
				target = p.userId
				fill()
			end)
		end
		if not selected then
			return
		end
		local life = selected.life
		-- (v0.18) who they are, as a card: the name big, the rest as badges
		local head = new("Frame", { Name = "PlayerCard", BackgroundColor3 = C.panel, BackgroundTransparency = 0.05, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
			Kit.corner(6), Kit.stroke(C.accent, 1, 0.55), Kit.padding(10, 12, 10, 12), Kit.list(6),
		})
		Kit.text({
			Text = if life then string.format("%s %s", Format.escape(life.first), Format.escape(life.last)) else Format.escape(selected.name or "") .. "  ·  no life started",
			FontFace = F.display,
			TextSize = 22,
			TextColor3 = C.text,
			LayoutOrder = 1,
			ZIndex = 3,
			Parent = head,
		})
		if life then
			local badges = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 3, Parent = head }, {
				new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			local talentDef = nil
			for _, t in cat.talents or {} do
				if t.id == life.talent then
					talentDef = t
				end
			end
			local n = 0
			local function add(text: string, color: Color3)
				n += 1
				badge(badges, text, color, n)
			end
			add("Age " .. tostring(life.age) .. (if life.alive then "" else "  ·  dead"), if life.alive then C.text else C.crimsonHi)
			add(string.upper(tostring(life.form or "human")), C.sub)
			if talentDef then
				local tier = TIER_OF[talentDef.tier or ""]
				add("Talent: " .. talentDef.name, if tier then tier.color else C.accentHi)
			end
			add(Format.number(life.money) .. " money", C.accentHi)
			add("Lifespan ~" .. tostring(life.lifespan or "?"), C.sub)
			add(tostring(#(life.traits or {})) .. " traits", C.sub)
			if life.style then
				add(string.upper(tostring(life.style)) .. "  ·  mastery " .. tostring(life.mastery or 0), C.sub)
			end
			if life.pending then
				add("Deciding", C.crimsonHi)
			end
		end

		-- ── (v0.18) Talents: set a talent, add extras, give and take away traits ──
		if tab == "Talents" then
			if not (life and life.alive) then
				Kit.text({ Text = "They aren't living a life right now.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
				return
			end
			local wideCards = content.AbsoluteSize.X >= 560
			local owned = {}
			for _, id in life.traits or {} do
				owned[id] = true
			end
			local byId = {}
			for _, t in cat.talents or {} do
				byId[t.id] = t
			end
			for _, t in cat.traits or {} do
				byId[t.id] = t
			end
			-- what they have now (tap one to take it away)
			sectionTitle(content, "What they have now  ·  tap to take away", nextOrder(), "tab.you")
			local mine = new("Frame", { Name = "Owned", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
				new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			local n = 0
			for _, id in life.traits or {} do
				n += 1
				local def = byId[id]
				local tier = def and def.tier and TIER_OF[def.tier]
				local b = chip(mine, "Owned_" .. id, (if id == life.talent then "TALENT  ·  " else "") .. ((def and def.name) or id) .. "   x", "secondary", n, function()
					onTarget({ op = "trait", id = id, on = false })
				end)
				if tier then
					(b :: any).TextColor3 = tier.color
				end
			end
			if n == 0 then
				Kit.caps({ Text = "Nothing yet", FontFace = F.displayMed, TextSize = 12, TextColor3 = C.faint, Size = UDim2.new(1, 0, 0, 20), ZIndex = 2, Parent = mine })
			end

			-- talents: rarity, sin, search
			sectionTitle(content, "Talents  ·  " .. tostring(#(cat.talents or {})), nextOrder(), "misc.star")
			local tiers = row(content, nextOrder())
			chip(tiers, "Tier_all", "Every rarity", if tf.tier == "all" then "primary" else "secondary", 0, function()
				tf.tier, tf.show = "all", 24
				fill()
			end)
			for i, t in TIERS do
				local b = chip(tiers, "Tier_" .. t.id, t.name, if tf.tier == t.id then "primary" else "secondary", i, function()
					tf.tier, tf.show = t.id, 24
					fill()
				end)
				if tf.tier ~= t.id then
					(b :: any).TextColor3 = t.color
				end
			end
			local sins = row(content, nextOrder())
			for i, s in SINS do
				local on = tf.sin == s
				local b = Kit.button({ name = "Sin_" .. s, text = "", style = if on then "primary" else "secondary", size = UDim2.fromOffset(40, 34), order = i, zIndex = 2, onClick = function()
					tf.sin = if tf.sin == s then nil else s
					tf.show = 24
					fill()
				end })
				b.Parent = sins
				local ok, e = pcall(Emblem.make, "sin." .. s, 22)
				if ok and e then
					e.AnchorPoint = Vector2.new(0.5, 0.5)
					e.Position = UDim2.fromScale(0.5, 0.5)
					e.ZIndex = 3
					e.Parent = b
				end
			end
			local search = textBox(content, nextOrder(), "Search talents by name or what they do")
			search.Text = tf.query
			local grid = new("Frame", { Name = "TalentGrid", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
				new("UIGridLayout", { CellSize = UDim2.new(if wideCards then 0.5 else 1, -6, 0, 136), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			local moreTalents = row(content, nextOrder())
			local function talents()
				Sheets.clear(grid)
				Sheets.clear(moreTalents)
				local q = string.lower(tf.query)
				local shown, matching = 0, 0
				for _, t in cat.talents or {} do
					local okTier = tf.tier == "all" or t.tier == tf.tier
					local okSin = tf.sin == nil or t.affinity == tf.sin
					local okQ = q == "" or string.find(string.lower(t.name or ""), q, 1, true) ~= nil or string.find(string.lower(t.desc or ""), q, 1, true) ~= nil
					if okTier and okSin and okQ then
						matching += 1
						if shown < tf.show then
							shown += 1
							talentCard(grid, t, shown, t.id == life.talent, owned[t.id] == true, function()
								onTarget({ op = "talent", id = t.id })
							end, function()
								onTarget({ op = "trait", id = t.id, on = if owned[t.id] then false else nil })
							end)
						end
					end
				end
				if matching == 0 then
					Kit.caps({ Text = "No talent matches", FontFace = F.displayMed, TextSize = 12, TextColor3 = C.faint, Size = UDim2.new(1, 0, 0, 20), ZIndex = 2, Parent = moreTalents })
				elseif matching > shown then
					chip(moreTalents, "MoreTalents", "Show more  (" .. tostring(matching - shown) .. " left)", "ghost", 1, function()
						tf.show += 24
						talents()
					end)
				end
			end
			search:GetPropertyChangedSignal("Text"):Connect(function()
				tf.query = search.Text
				tf.show = 24
				talents()
			end)
			talents()

			-- traits
			sectionTitle(content, "Traits  ·  " .. tostring(#(cat.traits or {})), nextOrder(), "thread.life")
			local traitFilters = row(content, nextOrder())
			chip(traitFilters, "EarnedOnly", if tf.earnedOnly then "Showing: earned by itself" else "Showing: every trait", if tf.earnedOnly then "primary" else "secondary", 1, function()
				tf.earnedOnly = not tf.earnedOnly
				tf.traitShow = 18
				fill()
			end)
			local traitSearch = textBox(content, nextOrder(), "Search traits by name or what they do")
			traitSearch.Text = tf.traitQuery
			local tgrid = new("Frame", { Name = "TraitGrid", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content }, {
				new("UIGridLayout", { CellSize = UDim2.new(if wideCards then 0.333 else 1, -6, 0, 112), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			local moreTraits = row(content, nextOrder())
			local function traits()
				Sheets.clear(tgrid)
				Sheets.clear(moreTraits)
				local q = string.lower(tf.traitQuery)
				local shown, matching = 0, 0
				for _, t in cat.traits or {} do
					local okE = not tf.earnedOnly or t.earned
					local okQ = q == "" or string.find(string.lower(t.name or ""), q, 1, true) ~= nil or string.find(string.lower(t.desc or ""), q, 1, true) ~= nil
					if okE and okQ then
						matching += 1
						if shown < tf.traitShow then
							shown += 1
							traitCard(tgrid, t, shown, owned[t.id] == true, function()
								onTarget({ op = "trait", id = t.id, on = if owned[t.id] then false else nil })
							end)
						end
					end
				end
				if matching == 0 then
					Kit.caps({ Text = "No trait matches", FontFace = F.displayMed, TextSize = 12, TextColor3 = C.faint, Size = UDim2.new(1, 0, 0, 20), ZIndex = 2, Parent = moreTraits })
				elseif matching > shown then
					chip(moreTraits, "MoreTraits", "Show more  (" .. tostring(matching - shown) .. " left)", "ghost", 1, function()
						tf.traitShow += 18
						traits()
					end)
				end
			end
			traitSearch:GetPropertyChangedSignal("Text"):Connect(function()
				tf.traitQuery = traitSearch.Text
				tf.traitShow = 18
				traits()
			end)
			traits()
			return
		end

		if tab == "Player" then
			local gifts = row(content, nextOrder())
			for i, g in {
				{ "+5 rolls", { op = "rolls", amount = 5 } },
				{ "+10 " .. ((ctx.info and ctx.info.meta and ctx.info.meta.glowName) or "Glow"), { op = "glow", amount = 10 } },
				{ "+200 " .. ((ctx.info and ctx.info.lunacy) or "Lunacy"), { op = "lunacy", amount = 200 } },
				{ "+5,000 money", { op = "stat", stat = "money", value = ((life and life.money) or 0) + 5000 } },
				{ "Unlock everything", { op = "unlockAll" } },
				{ "Heal", { op = "heal" } },
				{ "End this life", { op = "kill" } },
			} do
				chip(gifts, "Gift_" .. i, g[1], if g[2].op == "kill" then "danger" else "secondary", i, function()
					onTarget(table.clone(g[2]))
				end)
			end
			if not (life and life.alive) then
				return
			end
			sectionTitle(content, "Set a stat (past the limit: the limit rises to meet it)", nextOrder())
			for _, key in statKeys(ctx) do
				local line = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
				local current = if key == "sanity" then life.sanity elseif key == "money" then life.money elseif key == "age" then life.age elseif key == "renown" then life.renown else life.stats[key]
				local cap = life.caps and life.caps[key]
				Kit.caps({ Text = key .. "  (" .. tostring(current) .. (if cap then " / " .. tostring(cap) else "") .. ")", FontFace = F.displayMed, TextSize = 13, TextColor3 = C.sub, Size = UDim2.new(0.4, 0, 1, 0), ZIndex = 2, Parent = line })
				local box = textBox(line, 0, "value", UDim.new(0.24, 0))
				box.Position = UDim2.fromScale(0.4, 0)
				Kit.button({ name = "Set_" .. key, text = "Set", style = "secondary", size = UDim2.new(0.16, -4, 1, 0), position = UDim2.new(0.64, 4, 0, 0), textSize = 13, zIndex = 2, onClick = function()
					onTarget({ op = "stat", stat = key, value = tonumber(box.Text) })
				end }).Parent = line
				if life.stats[key] ~= nil then
					Kit.button({ name = "Set400_" .. key, text = "400", style = "ghost", size = UDim2.new(0.2, -4, 1, 0), position = UDim2.new(0.8, 4, 0, 0), textSize = 12, zIndex = 2, onClick = function()
						onTarget({ op = "stat", stat = key, value = 400 })
					end }).Parent = line
				end
			end
			sectionTitle(content, "Make an event happen", nextOrder())
			pickList(content, nextOrder(), cat.events, "Search events by name or id", function(item)
				onTarget({ op = "event", id = item.id })
			end, 20)
			-- (talents and traits have their own tab now: Talents)
			sectionTitle(content, "Fighting style and mastery", nextOrder())
			local masteryBox = textBox(content, nextOrder(), "Mastery (0-5), then pick a style")
			pickList(content, nextOrder(), cat.styles, "Search styles", function(item)
				onTarget({ op = "style", id = item.id, mastery = tonumber(masteryBox.Text) })
			end)
			if cat.forms and #cat.forms > 0 then
				sectionTitle(content, "What they are (human, E.G.O, Bloodfiend...)", nextOrder())
				pickList(content, nextOrder(), cat.forms, "Search forms", function(item)
					onTarget({ op = "form", id = item.id })
				end, nil, life.form)
			end
			sectionTitle(content, "Give gear (augment arms too: search \"arm\")", nextOrder())
			pickList(content, nextOrder(), cat.gear, "Search gear", function(item)
				onTarget({ op = "gear", id = item.id })
			end)
			sectionTitle(content, "Conditions (tap to add; cure below)", nextOrder())
			pickList(content, nextOrder(), cat.conditions, "Search conditions", function(item)
				onTarget({ op = "condition", id = item.id })
			end)
			Kit.button({ name = "CureAll", text = "Cure everything", style = "secondary", size = UDim2.new(1, 0, 0, 30), order = nextOrder(), textSize = 12, zIndex = 2, onClick = function()
				onTarget({ op = "condition", id = "any", on = false })
			end }).Parent = content
			sectionTitle(content, "Career (rank in the box)", nextOrder())
			local rankBox = textBox(content, nextOrder(), "Rank (0 = first), then pick a career")
			pickList(content, nextOrder(), cat.careers, "Search careers", function(item)
				onTarget({ op = "career", id = item.id, rank = tonumber(rankBox.Text) })
			end)
			sectionTitle(content, "Standing with a faction (-100 to 100)", nextOrder())
			local repBox = textBox(content, nextOrder(), "Value, then pick a faction")
			pickList(content, nextOrder(), cat.factions, "Search factions", function(item)
				onTarget({ op = "rep", id = item.id, value = tonumber(repBox.Text) })
			end)
			sectionTitle(content, "Flags", nextOrder())
			local flagBox = textBox(content, nextOrder(), "A flag id, e.g. color_fixer")
			local flagRow = row(content, nextOrder())
			chip(flagRow, "FlagOn", "Set", "secondary", 1, function()
				onTarget({ op = "flag", id = flagBox.Text })
			end)
			chip(flagRow, "FlagOff", "Clear", "ghost", 2, function()
				onTarget({ op = "flag", id = flagBox.Text, on = false })
			end)
			return
		end

		if not (life and life.alive) then
			Kit.text({ Text = "They aren't living a life right now.", FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.faint, LayoutOrder = nextOrder(), ZIndex = 2, Parent = content })
			return
		end

		-- ── Look: character customization ──
		if tab == "Look" then
			chip(row(content, nextOrder()), "RandomLook", "Random look", "secondary", 1, function()
				onTarget({ op = "look", random = true })
			end)
			for _, catId in cat.lookOrder or {} do
				local def = cat.looks[catId]
				if def then
					sectionTitle(content, def.name .. "  ·  now: " .. tostring(life.look and life.look[catId] or "default"), nextOrder())
					pickList(content, nextOrder(), def.options, "Search " .. string.lower(def.name), function(item)
						onTarget({ op = "look", category = catId, id = item.id })
					end, if catId == "body" then 4 else 18, life.look and life.look[catId])
				end
			end
			return
		end

		-- ── Power ──
		if tab == "Power" then
			sectionTitle(content, "Every stat at once (the limits rise to meet it)", nextOrder())
			local maxRow = row(content, nextOrder())
			for i, v in { 100, 200, 300, 400 } do
				chip(maxRow, "MaxAll_" .. v, "All " .. v, if v >= 300 then "primary" else "secondary", i, function()
					onTarget({ op = "maxStats", value = v })
				end)
			end
			chip(maxRow, "MaxAll_cap", "All to their limit", "ghost", 5, function()
				onTarget({ op = "maxStats" })
			end)
			sectionTitle(content, "Break a limit (a stat, or empty for all)", nextOrder())
			local limStat = textBox(content, nextOrder(), "Stat (strength, speed...) or empty for every stat")
			local limRow = row(content, nextOrder())
			for i, v in { 25, 50, 100, 200 } do
				chip(limRow, "Limit_" .. v, "+" .. v, "secondary", i, function()
					onTarget({ op = "limitBreak", stat = limStat.Text, amount = v })
				end)
			end
			sectionTitle(content, "Lifespan (now about " .. tostring(life.lifespan or "?") .. ")", nextOrder())
			local lifeRow = row(content, nextOrder())
			for i, v in { 10, 50, 100, 300 } do
				chip(lifeRow, "Lifespan_" .. v, "+" .. v .. " years", "secondary", i, function()
					onTarget({ op = "lifespan", amount = v })
				end)
			end
			sectionTitle(content, "Titles and blood", nextOrder())
			local titleRow = row(content, nextOrder())
			chip(titleRow, "MakeColor", "Make them a Color", "primary", 1, function()
				onTarget({ op = "color" })
			end)
			if life.form == "bloodfiend" then
				for i, v in { 25, 80, 120, 260 } do
					chip(titleRow, "Blood_" .. v, "Blood " .. v .. " years old", "secondary", i + 1, function()
						onTarget({ op = "bloodYears", value = v })
					end)
				end
			end
			sectionTitle(content, "Teach a technique (arm techniques give the arm)", nextOrder())
			pickList(content, nextOrder(), cat.techniques, "Search techniques", function(item)
				onTarget({ op = "technique", id = item.id })
			end, 40)
			sectionTitle(content, "Start training with" .. (if life.trainer then "  ·  now: " .. life.trainer else ""), nextOrder())
			pickList(content, nextOrder(), cat.trainers, "Search trainers", function(item)
				onTarget({ op = "trainer", id = item.id })
			end, 30, life.trainer)
			return
		end

		-- ── Fights ──
		if tab == "Fights" then
			sectionTitle(content, "Start a boss battle in turns (on their screen)", nextOrder())
			pickList(content, nextOrder(), cat.bosses, "Search bosses", function(item)
				onTarget({ op = "battle", id = item.id })
			end, 40)
			sectionTitle(content, "The extreme events", nextOrder())
			local exRow = row(content, nextOrder())
			local n = 0
			for _, e in cat.events do
				if string.sub(e.id, 1, 5) == "ex17_" then
					n += 1
					chip(exRow, "Extreme_" .. e.id, e.name, "danger", n, function()
						onTarget({ op = "event", id = e.id })
					end)
				end
			end
			return
		end
	end

	fill()
	ctx.actions.adminCall({ op = "__state" }, function(res)
		if res and res.admin then
			state = res.admin
			catalog = state.catalog or catalog
			state.catalog = catalog
		end
		fill()
	end)
	return sheet
end

return AdminMenu
