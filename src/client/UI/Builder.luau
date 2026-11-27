--[[
	The build part of the character creator: fighting style, traits, bonus stat points,
	and the family name. Every part updates in place (no full rebuild), so the scroll
	position and anything typed elsewhere stay put.
		local state = Builder.new(ctx)
		Builder.append(ctx, scroll, nextOrder, state, layer)
		Builder.payload(state)   -> { traits, style, alloc } for newLife
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Sheets = require(script.Parent.Sheets)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Builder = {}

local STATS = { "fortitude", "prudence", "temperance", "justice" } -- replaced by the pack's own in Builder.new

function Builder.new(ctx)
	if ctx.info and ctx.info.stats and ctx.info.stats.order then
		STATS = ctx.info.stats.order
	end
	local state = { traits = {}, style = nil, alloc = {}, era = nil }
	for _, k in STATS do
		state.alloc[k] = 0
	end
	local styles = ctx.info and ctx.info.styles
	if styles and #styles > 0 then
		state.style = styles[1].id
	end
	for _, e in (ctx.info and ctx.info.eras) or {} do
		if e.default or not state.era then
			state.era = e.id
		end
	end
	return state
end

function Builder.payload(state)
	return { traits = table.clone(state.traits), style = state.style, alloc = table.clone(state.alloc), era = state.era }
end

-- perks the player owns (from the store): a third trait, bonus points
local function perks(ctx)
	return (ctx.state and ctx.state.meta and ctx.state.meta.perks) or {}
end
local function totalPoints(ctx): number
	local build = ctx.info and ctx.info.build
	return ((build and build.points) or 0) + (if perks(ctx).bonusPoints then 4 else 0)
end
local function traitPicks(ctx): number
	return ((ctx.info and ctx.info.traitPicks) or 2) + (if perks(ctx).extraTrait then 1 else 0)
end

local function pointsLeft(ctx, state): number
	local total = totalPoints(ctx)
	for _, k in STATS do
		total -= state.alloc[k] or 0
	end
	return total
end

function Builder.append(ctx, scroll: Instance, nextOrder, state, layer: Instance)
	local info = ctx.info or {}

	-- ── when you're born ──
	if info.eras and #info.eras > 0 then
		Sheets.sectionTitle(scroll, "When you're born", nextOrder())
		local list = new("Frame", { Name = "Eras", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = scroll }, {
			Kit.list(6),
		})
		local cards = {}
		local function paint()
			for id, card in cards do
				local sel = id == state.era
				card.stroke.Color = if sel then C.accent else C.stroke
				card.stroke.Transparency = if sel then 0 else 0.4
				card.button.BackgroundColor3 = if sel then C.panelHi else C.panelLo
			end
		end
		for i, e in info.eras do
			local b = new("TextButton", {
				Name = "Era_" .. e.id,
				AutoButtonColor = false,
				BackgroundColor3 = C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Text = "",
				LayoutOrder = i,
				Parent = list,
			}, { Kit.corner(2), Kit.padding(8, 12, 8, 12), Kit.list(2) })
			local stroke = Kit.stroke(C.stroke, 1, 0.4)
			stroke.Parent = b
			Kit.text({
				Text = Format.color(string.upper(Format.escape(e.name)), C.accentHi) .. (if e.years then "   " .. Format.color(Format.escape(e.years), C.faint) else ""),
				FontFace = F.display,
				TextSize = 14,
				LayoutOrder = 1,
				Parent = b,
			})
			if e.desc then
				Kit.text({ Text = Format.escape(e.desc), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, Parent = b })
			end
			cards[e.id] = { button = b, stroke = stroke }
			b.Activated:Connect(function()
				state.era = e.id
				ctx.sound("click")
				paint()
			end)
		end
		paint()
	end

	-- every section registers how to repaint itself, so a preset can update them all
	local repaint = {}

	-- ── build types: one tap sets a style, traits and points that work together ──
	if info.buildPresets and #info.buildPresets > 0 then
		Sheets.sectionTitle(scroll, "Build types", nextOrder())
		Kit.text({
			Text = "Pick a build to start from, then change anything you like below.",
			FontFace = F.serif,
			TextSize = 12,
			TextColor3 = C.sub,
			LayoutOrder = nextOrder(),
			Parent = scroll,
		})
		local grid = new("Frame", { Name = "Presets", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = scroll }, {
			new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		local descLabel
		for i, p in info.buildPresets do
			local color = C.accentHi
			for _, s in info.styles or {} do
				if s.id == p.style and s.color then
					color = Theme.rgb(s.color)
				end
			end
			local b = new("TextButton", {
				Name = "Preset_" .. p.id,
				AutoButtonColor = false,
				BackgroundColor3 = C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 150, 0, 40),
				Text = string.upper(p.name),
				FontFace = F.display,
				TextSize = 13,
				TextWrapped = true,
				TextColor3 = color,
				LayoutOrder = i,
				Parent = grid,
			}, { Kit.corner(2) })
			Kit.stroke(C.stroke, 1, 0.4).Parent = b
			b.Activated:Connect(function()
				state.style = p.style or state.style
				state.traits = {}
				for _, t in p.traits or {} do
					if #state.traits < traitPicks(ctx) then
						table.insert(state.traits, t)
					end
				end
				-- points: as the preset says, trimmed to what this player has
				local left = totalPoints(ctx)
				local maxPer = (info.build and info.build.maxPer) or left
				for _, k in STATS do
					local n = math.min((p.alloc and p.alloc[k]) or 0, maxPer, left)
					state.alloc[k] = n
					left -= n
				end
				ctx.sound("click")
				for _, f in repaint do
					f()
				end
				if descLabel then
					descLabel.Text = Format.color(string.upper(Format.escape(p.name)), color) .. "   " .. Format.escape(p.desc or "")
				end
			end)
		end
		descLabel = Kit.text({ Text = "", FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), Parent = scroll })
	end

	-- ── fighting style ──
	if info.styles and #info.styles > 0 then
		Sheets.sectionTitle(scroll, "How you fight", nextOrder())
		Kit.text({
			Text = "Only fights use it (not every risky choice is a fight). Every heads you land builds your style's status. Train it up during your life to make it hit harder.",
			FontFace = F.serif,
			TextSize = 12,
			TextColor3 = C.sub,
			LayoutOrder = nextOrder(),
			Parent = scroll,
		})
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = scroll }, {
			new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		local cards = {}
		local descLabel
		local function paint()
			for id, card in cards do
				local sel = id == state.style
				card.stroke.Color = if sel then card.color else C.stroke
				card.stroke.Transparency = if sel then 0 else 0.4
				card.button.BackgroundColor3 = if sel then C.panelHi else C.panelLo
			end
			for _, s in info.styles do
				if s.id == state.style and descLabel then
					descLabel.Text = Format.color(string.upper(Format.escape(s.name)), if s.color then Theme.rgb(s.color) else C.accentHi) .. "   " .. Format.escape(s.desc or "")
				end
			end
		end
		for i, s in info.styles do
			local color = if s.color then Theme.rgb(s.color) else C.accent
			local b = new("TextButton", {
				Name = "Style_" .. s.id,
				AutoButtonColor = false,
				BackgroundColor3 = C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 96, 0, 40),
				Text = string.upper(s.name),
				FontFace = F.display,
				TextSize = 14,
				TextColor3 = color,
				LayoutOrder = i,
				Parent = grid,
			}, { Kit.corner(2) })
			local stroke = Kit.stroke(C.stroke, 1, 0.4)
			stroke.Parent = b
			cards[s.id] = { button = b, stroke = stroke, color = color }
			b.Activated:Connect(function()
				state.style = s.id
				ctx.sound("click")
				paint()
			end)
		end
		descLabel = Kit.text({ Text = "", FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = nextOrder(), Parent = scroll })
		paint()
		table.insert(repaint, paint)
	end

	-- ── traits ──
	local picks = traitPicks(ctx)
	local pickable = {}
	for _, t in info.traits or {} do
		if t.pick then
			table.insert(pickable, t)
		end
	end
	if #pickable > 0 then
		local title = Sheets.sectionTitle(scroll, "", nextOrder())
		local cards = {}
		local function paint()
			title.Text = string.upper(string.format("Traits  ·  pick %d  (%d chosen)", picks, #state.traits))
			for id, card in cards do
				local sel = table.find(state.traits, id) ~= nil
				card.stroke.Color = if sel then C.accent else C.stroke
				card.stroke.Transparency = if sel then 0 else 0.45
				card.button.BackgroundColor3 = if sel then C.panelHi else C.panelLo
				card.mark.Text = if sel then "CHOSEN" else ""
			end
		end
		local grid = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = nextOrder(), Parent = scroll }, {
			new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		for i, t in pickable do
			local b = new("TextButton", {
				Name = "Trait_" .. t.id,
				AutoButtonColor = false,
				BackgroundColor3 = C.panelLo,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 240, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Text = "",
				LayoutOrder = i,
				Parent = grid,
			}, { Kit.corner(2), Kit.padding(8, 10, 8, 10), Kit.list(2) })
			local stroke = Kit.stroke(C.stroke, 1, 0.45)
			stroke.Parent = b
			Kit.text({ Text = string.upper(Format.escape(t.name)), FontFace = F.display, TextSize = 14, TextColor3 = C.text, LayoutOrder = 1, Parent = b })
			Kit.text({ Text = Format.escape(t.desc or ""), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, Parent = b })
			local mark = Kit.caps({ Text = "", FontFace = F.display, TextSize = 11, TextColor3 = C.accentHi, LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 14), Parent = b })
			cards[t.id] = { button = b, stroke = stroke, mark = mark }
			b.Activated:Connect(function()
				local at = table.find(state.traits, t.id)
				if at then
					table.remove(state.traits, at)
				elseif #state.traits < picks then
					table.insert(state.traits, t.id)
				else
					-- full: swap out the oldest pick
					table.remove(state.traits, 1)
					table.insert(state.traits, t.id)
				end
				ctx.sound("click")
				paint()
			end)
		end
		paint()
		table.insert(repaint, paint)
	end

	-- ── bonus stat points ──
	local build = info.build
	if build and (build.points or 0) > 0 then
		local title = Sheets.sectionTitle(scroll, "", nextOrder())
		local rows = {}
		local function paint()
			title.Text = string.upper(string.format("Stat points  ·  %d left", pointsLeft(ctx, state)))
			for k, row in rows do
				row.value.Text = string.format("+%d", (state.alloc[k] or 0) * (build.perPoint or 1))
			end
		end
		Kit.text({
			Text = string.format("Spend %d points on a head start. Each point is +%d to that stat at birth (at most %d per stat).", totalPoints(ctx), build.perPoint or 1, build.maxPer or build.points),
			FontFace = F.serif,
			TextSize = 12,
			TextColor3 = C.sub,
			LayoutOrder = nextOrder(),
			Parent = scroll,
		})
		for _, k in STATS do
			local def = info.stats and info.stats.defs and info.stats.defs[k]
			local color = if def and def.color then Theme.rgb(def.color) else C.text
			local row = new("Frame", { Name = "Points_" .. k, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = nextOrder(), Parent = scroll })
			Kit.caps({ Text = if def then def.name else k, FontFace = F.display, TextSize = 15, TextColor3 = color, Size = UDim2.new(0.5, 0, 1, 0), Parent = row })
			local value = Kit.caps({
				Text = "+0",
				FontFace = F.mono,
				TextSize = 15,
				TextColor3 = C.text,
				TextXAlignment = Enum.TextXAlignment.Center,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -44, 0, 0),
				Size = UDim2.new(0, 56, 1, 0),
				Parent = row,
			})
			Kit.button({ name = "Minus", text = "-", style = "ghost", size = UDim2.fromOffset(40, 32), position = UDim2.new(1, -104, 0, 2), anchor = Vector2.new(1, 0), textSize = 16, onClick = function()
				if (state.alloc[k] or 0) > 0 then
					state.alloc[k] -= 1
					paint()
				end
			end }).Parent = row
			Kit.button({ name = "Plus", text = "+", style = "secondary", size = UDim2.fromOffset(40, 32), position = UDim2.new(1, 0, 0, 2), anchor = Vector2.new(1, 0), textSize = 16, onClick = function()
				if pointsLeft(ctx, state) > 0 and (state.alloc[k] or 0) < (build.maxPer or build.points) then
					state.alloc[k] += 1
					ctx.sound("click")
					paint()
				end
			end }).Parent = row
			rows[k] = { value = value }
		end
		paint()
		table.insert(repaint, paint)
	end

	-- ── family name ──
	local sn = ctx.state.surnames
	if sn then
		Sheets.sectionTitle(scroll, "Family name", nextOrder())
		local current = sn.current
		local tierLabel = ""
		local color = C.text
		for _, t in sn.tiers or {} do
			if current and t.id == current.tier then
				tierLabel = t.name
				color = if t.color then Theme.rgb(t.color) else C.text
			end
		end
		Sheets.row(scroll, nextOrder(), {
			title = if current then Format.color(Format.escape(current.name), color) .. "  " .. Format.color(string.upper(tierLabel), C.faint) else "No family name yet",
			desc = if current then "Every life you start carries this name." else "Roll for one. Rarer names carry a small trait.",
			meta = string.format("Roll for a name  ·  %d rolls", sn.rolls or 0),
			onClick = function()
				ctx.actions.openSurnames()
			end,
		})
	end
end

return Builder
