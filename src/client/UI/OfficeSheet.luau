--[[
	YOUR OFFICE (v0.18): the sheet where you run it (Engine/Office.luau on the server).
		the sign      its name, a motto under it and its colour, typed by you and filtered by Roblox
		the building  where you are now, how many desks, and the next place you could move to
		rooms         training room, infirmary, archive, armory, lab, vault
		roster        your Fixers with their grades, wages and what they bring in; let one go
		hire          friends, family and people you've met who'd come and work for you
		the lab       run an experiment (an action and the materials)
	ctx.actions.officeAct(op, arg, after) and ctx.actions.officeName(name, motto, color, after) call
	the server; the sheet redraws itself from the life that comes back.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Sheets = require(script.Parent.Sheets)
local Format = require(script.Parent.Format)
local Tip = require(script.Parent.Tip)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local OfficeSheet = {}

local function rgb(t: any, fallback: Color3): Color3
	if type(t) == "table" and type(t[1]) == "number" then
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	return fallback
end

local function cap(s: string): string
	return string.upper(string.sub(s, 1, 1)) .. string.sub(s, 2)
end

local function panel(parent: Instance, order: number, accent: Color3?): Frame
	return new("Frame", {
		BackgroundColor3 = C.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, {
		Kit.corner(8),
		Kit.stroke(accent or C.stroke, 1, 0.35),
		Kit.padding(12, 14, 12, 14),
		new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	}) :: Frame
end

local function line(parent: Instance, order: number, text: string, opts: any?)
	local o = opts or {}
	return Kit.text({
		Text = text,
		RichText = true,
		FontFace = o.font or F.ui,
		TextSize = o.size or 13,
		TextColor3 = o.color or C.sub,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = order,
		ZIndex = 3,
		Parent = parent,
	})
end

-- a row: a title and a note on the left, a button on the right
local function actionRow(parent: Instance, order: number, name: string, title: string, note: string, button: string?, style: string?, enabled: boolean, onClick: (() -> ())?)
	local row = new("Frame", { Name = name, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, ZIndex = 3, Parent = parent })
	local textW = if button then -150 else 0
	Kit.text({ Text = title, RichText = true, FontFace = F.uiBold, TextSize = 14, TextColor3 = C.text, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, textW, 0, 0), ZIndex = 3, Parent = row })
	Kit.text({ Text = note, RichText = true, FontFace = F.ui, TextSize = 12, TextColor3 = C.faint, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.fromOffset(0, 20), Size = UDim2.new(1, textW, 0, 0), ZIndex = 3, Parent = row })
	if button then
		Kit.button({ name = name .. "Button", text = button, style = style or "secondary", size = UDim2.new(0, 138, 0, 32), position = UDim2.new(1, 0, 0, 2), anchor = Vector2.new(1, 0), textSize = 13, zIndex = 4, enabled = enabled, parent = row, onClick = onClick })
	end
	-- (the row is as tall as its note, and never shorter than its button)
	new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 1, 0, 40), ZIndex = 1, Parent = row })
	return row
end

function OfficeSheet.open(ctx, layer: Instance, opts: any?)
	local sheet = Sheets.open(layer, "Your Office", nil, { center = true })
	local content = sheet.content
	local busy = false
	-- what's typed for the sign is kept here, so a redraw doesn't lose it
	local form = { name = nil, motto = nil, color = nil, open = (opts and opts.naming) == true }

	local draw
	local function act(op: string, arg: any)
		if busy then
			return
		end
		busy = true
		ctx.actions.officeAct(op, arg, function()
			busy = false
			if sheet.isClosed and sheet.isClosed() then
				return
			end
			draw()
		end)
	end

	function draw()
		for _, c in content:GetChildren() do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		local life = ctx.state.life
		local o = life and life.office
		if not o then
			line(content, 1, "You don't have an Office. Open one from the DO tab, under Deeds.")
			return
		end
		local sign = rgb(o.colorRgb, C.money)
		local order = 0
		local function nextOrder()
			order += 1
			return order
		end

		-- ── the sign ──
		local signCard = panel(content, nextOrder(), sign)
		signCard.Name = "OfficeSign"
		line(signCard, 1, string.upper("The " .. Format.escape(o.name or "") .. " Office"), { font = F.display, size = 26, color = sign })
		if o.motto then
			line(signCard, 2, '"' .. Format.escape(o.motto) .. '"', { font = F.serifItalic, size = 14, color = C.sub })
		end
		line(signCard, 3, string.format("%s  ·  %s  ·  %d of %d desks taken", cap(tostring(o.rank or "")), Format.escape(tostring(o.building and o.building.name or "")), #(o.crew or {}), (o.building and o.building.crew) or 0), { font = F.mono, size = 12, color = C.faint })
		if not o.named or form.open then
			-- the form: the name, a motto, the colour
			local box = new("Frame", { Name = "SignForm", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4, ZIndex = 3, Parent = signCard }, {
				new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			line(box, 1, if o.named then "Change the sign." else "Name your Office. It goes on the door, the contracts and the news.", { color = C.text })
			local function field(order2: number, fname: string, placeholder: string, value: string, onText: (string) -> ())
				local tb = new("TextBox", {
					Name = fname,
					BackgroundColor3 = Color3.fromRGB(10, 8, 12),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 38),
					Text = value,
					PlaceholderText = placeholder,
					PlaceholderColor3 = C.faint,
					ClearTextOnFocus = false,
					FontFace = F.ui,
					TextSize = 15,
					TextColor3 = C.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = order2,
					ZIndex = 3,
					Parent = box,
				}, { Kit.corner(4), Kit.stroke(C.stroke, 1, 0.2), Kit.padding(0, 10, 0, 10) })
				local t = tb :: TextBox
				t:GetPropertyChangedSignal("Text"):Connect(function()
					onText(t.Text)
				end)
			end
			form.name = form.name or (if o.named then o.name else "")
			form.motto = form.motto or o.motto or ""
			field(2, "OfficeNameBox", "Its name (just the name: \"the ... Office\" is added)", form.name or "", function(t)
				form.name = t
			end)
			field(3, "OfficeMottoBox", "A motto under it (you can leave this empty)", form.motto or "", function(t)
				form.motto = t
			end)
			-- the colours of the sign
			local swatches = new("Frame", { Name = "SignColors", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 4, ZIndex = 3, Parent = box }, {
				new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
			})
			local chosen = form.color or o.color
			for i, col in o.colors or {} do
				local sw = new("TextButton", {
					Name = "SignColor_" .. col.id,
					Text = "",
					AutoButtonColor = false,
					BackgroundColor3 = rgb(col.color, C.money),
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(34, 34),
					LayoutOrder = i,
					ZIndex = 3,
					Parent = swatches,
				}, { Kit.corner(17), Kit.stroke(if col.id == chosen then C.text else C.stroke, if col.id == chosen then 3 else 1, 0) })
				Tip.attach(sw, col.name)
				;(sw :: TextButton).Activated:Connect(function()
					form.color = col.id
					draw()
				end)
			end
			Kit.button({ name = "SaveSign", text = if o.named then "Save the sign" else "Hang the sign", style = "primary", size = UDim2.new(0, 170, 0, 36), order = 5, textSize = 14, zIndex = 4, parent = box, onClick = function()
				if busy then
					return
				end
				busy = true
				ctx.actions.officeName(form.name, form.motto, form.color, function(res)
					busy = false
					if res and res.ok then
						form.open = false
						form.name, form.motto, form.color = nil, nil, nil
					end
					if not (sheet.isClosed and sheet.isClosed()) then
						draw()
					end
				end)
			end })
		else
			Kit.button({ name = "EditSign", text = "Change the sign", style = "ghost", size = UDim2.new(0, 160, 0, 30), order = 5, textSize = 12, zIndex = 4, parent = signCard, onClick = function()
				form.open = true
				draw()
			end })
		end

		-- ── the money and the muscle ──
		local sums = panel(content, nextOrder())
		line(sums, 1, string.format("Contracts <b>%s</b> Ahn a year  ·  wages <b>%s</b>  ·  the Office pays <b>%s</b> on top", Format.number(o.earns or 0), Format.number(o.wages or 0), Format.number(o.income or 0)), { color = C.text })
		line(sums, 2, if (o.fightBase or 0) > 0 then string.format("In a fight, your Office stands behind you: <b>+%d base</b>.", o.fightBase) else "Three Fixers on the roster and your Office starts to stand behind you in a fight.", { size = 12 })

		-- ── the building ──
		Sheets.sectionTitle(content, "Premises", nextOrder())
		local bcard = panel(content, nextOrder())
		line(bcard, 1, string.format("<b>%s</b>. %s", cap(Format.escape(tostring(o.building and o.building.name or ""))), Format.escape(tostring(o.building and o.building.desc or ""))), { color = C.text })
		local nb = o.nextBuilding
		if nb then
			local needs = {}
			if nb.minSize and (o.size or 1) < nb.minSize then
				table.insert(needs, "grow the Office with deeds first")
			end
			if nb.minRenown then
				table.insert(needs, "renown grade " .. tostring(nb.minRenown))
			end
			local can = #needs == 0 and (life.money or 0) >= (nb.price or 0)
			actionRow(bcard, 2, "MoveIn", string.format("Next: %s", Format.escape(nb.name)), string.format("%s %d desks. %s Ahn.%s", Format.escape(nb.desc or ""), nb.crew or 0, Format.number(nb.price or 0), if #needs > 0 then " Needs: " .. table.concat(needs, ", ") .. "." else ""), "Move in", "primary", can, function()
				act("building")
			end)
		else
			line(bcard, 2, "There's nowhere bigger in the City to move to.", { size = 12 })
		end

		-- ── rooms ──
		Sheets.sectionTitle(content, "Rooms", nextOrder())
		local rcard = panel(content, nextOrder())
		for i, r in o.rooms or {} do
			local note = Format.escape(r.desc or "")
			if r.owned then
				actionRow(rcard, i, "Room_" .. r.id, "✓ " .. Format.escape(r.name), note, nil, nil, false, nil)
			elseif not r.open then
				actionRow(rcard, i, "Room_" .. r.id, Format.escape(r.name), note .. "  Needs " .. Format.escape(tostring(r.needs or "a bigger building")) .. ".", "No space yet", "ghost", false, nil)
			else
				actionRow(rcard, i, "Room_" .. r.id, Format.escape(r.name), note, "Build: " .. Format.number(r.price or 0), "secondary", (life.money or 0) >= (r.price or 0), function()
					act("room", r.id)
				end)
			end
		end

		-- ── the lab ──
		if o.lab then
			Sheets.sectionTitle(content, "The lab", nextOrder())
			local lcard = panel(content, nextOrder(), Color3.fromRGB(120, 230, 170))
			actionRow(lcard, 1, "Experiment", "Run an experiment", string.format("One action and %s Ahn of materials. A breakthrough, a stronger you, a design to sell, nothing at all, or an accident.", Format.number(o.experimentCost or 2000)), "Run it", "primary", (life.actionsLeft or 0) > 0 and (life.money or 0) >= (o.experimentCost or 2000) and not life.pending, function()
				act("experiment")
			end)
		end

		-- ── the roster ──
		Sheets.sectionTitle(content, string.format("Your Fixers  ·  %d of %d", #(o.crew or {}), (o.building and o.building.crew) or 0), nextOrder())
		local crewCard = panel(content, nextOrder())
		crewCard.Name = "Roster"
		if #(o.crew or {}) == 0 then
			line(crewCard, 1, "Nobody on the roster yet. Hire someone below.", { size = 12 })
		end
		for i, m in o.crew or {} do
			actionRow(crewCard, i, "Crew_" .. tostring(m.rel), string.format("%s  <font color=\"#EDC472\">Grade %d</font>", Format.escape(m.name or ""), m.grade or 9), string.format("Your %s, %s. Wage %s a year, brings in %s.", Format.escape(tostring(m.kind or "friend")), tostring(m.age or "?"), Format.number(m.wage or 0), Format.number(m.earn or 0)), "Let go", "ghost", true, function()
				act("fire", m.rel)
			end)
		end

		-- ── who'd join ──
		if #(o.crew or {}) < ((o.building and o.building.crew) or 0) then
			Sheets.sectionTitle(content, "Who'd join you", nextOrder())
			local hcard = panel(content, nextOrder())
			hcard.Name = "Hire"
			if #(o.hire or {}) == 0 then
				line(hcard, 1, "Nobody grown-up enough or close enough yet. Make friends, keep family close.", { size = 12 })
			end
			for i, hrow in o.hire or {} do
				if i > 14 then
					break
				end
				local note = string.format("Your %s, %s. Bond %d.", Format.escape(tostring(hrow.kind or "friend")), tostring(hrow.age or "?"), hrow.bond or 0)
				if not hrow.ok and hrow.why then
					note ..= "  " .. Format.escape(hrow.why)
				end
				actionRow(hcard, i, "HireRow_" .. tostring(hrow.rel), Format.escape(hrow.name or ""), note, "Hire", "primary", hrow.ok == true, function()
					act("hire", hrow.rel)
				end)
			end
		else
			line(content, nextOrder(), "Every desk is taken. A bigger building has room for more.", { size = 12 })
		end
	end

	draw()
	sheet.refresh = draw
	return sheet
end

return OfficeSheet
