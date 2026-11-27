--[[
	The guidebook: how to play and what everything does.
		Guide.open(ctx, layer, startSection?) -> sheet
	The pages come from the server (handlers.guide, built from the content pack), so what it
	says about stats, statuses, talents, gear, books, careers and factions is always true.
	A tab per section, and a search box that looks through every page.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Sheets = require(script.Parent.Sheets)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Guide = {}

local function clear(frame: Instance)
	for _, child in frame:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function entryCard(parent: Instance, order: number, e)
	local color = if e.color then Theme.rgb(e.color) else C.stroke
	local card = new("Frame", {
		Name = "Entry",
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		ZIndex = 2,
		Parent = parent,
	}, { Kit.corner(2), Kit.padding(9, 12, 10, 16), Kit.list(3) })
	Kit.stroke(C.stroke, 1, 0.5).Parent = card
	local edgeLayer = new("Folder", { Parent = card })
	new("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Position = UDim2.fromOffset(-9, 1), Size = UDim2.fromOffset(3, 16), ZIndex = 2, Parent = edgeLayer })
	local titleText = string.upper(Format.escape(e.title or ""))
	if e.tag then
		titleText ..= "   " .. Format.color(string.upper(Format.escape(e.tag)), if e.color then color else C.faint)
	end
	Kit.text({ Text = titleText, FontFace = F.display, TextSize = 15, LayoutOrder = 1, ZIndex = 2, Parent = card })
	if e.sub then
		Kit.text({ Text = Format.escape(e.sub), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.faint, LayoutOrder = 2, ZIndex = 2, Parent = card })
	end
	if e.text and e.text ~= "" then
		Kit.text({ Text = Format.escape(e.text), FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 3, ZIndex = 2, Parent = card })
	end
	return card
end

function Guide.open(ctx, layer: Instance, startSection: string?)
	local sheet = Sheets.open(layer, "Guidebook")
	local content = sheet.content
	local tabs = new("ScrollingFrame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 34),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = content,
	}, { Kit.list(6, Enum.FillDirection.Horizontal) })
	local search: any = new("TextBox", {
		Name = "Search",
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 34),
		Text = "",
		PlaceholderText = "Search the guidebook",
		PlaceholderColor3 = C.faint,
		ClearTextOnFocus = false,
		FontFace = F.uiMedium,
		TextSize = 14,
		TextColor3 = C.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		ZIndex = 2,
		Parent = content,
	}, { Kit.corner(2), Kit.padding(0, 10, 0, 10), Kit.stroke(C.stroke, 1, 0.3) })
	local body = new("Frame", {
		Name = "Page",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 3,
		ZIndex = 2,
		Parent = content,
	}, { Kit.list(8) })

	local guide = nil
	local current = startSection
	local buttons = {}

	local function showSection(id: string?)
		clear(body)
		if not guide then
			Kit.text({ Text = "Opening the guidebook...", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, ZIndex = 2, Parent = body })
			return
		end
		local sec = guide.sections[1]
		for _, s in guide.sections do
			if s.id == id then
				sec = s
			end
		end
		current = sec.id
		for key, b in buttons do
			b.BackgroundColor3 = if key == current then C.accent else C.panelHi
			b.TextColor3 = if key == current then C.ink else C.sub
		end
		if sec.intro then
			Kit.text({ Text = Format.escape(sec.intro), FontFace = F.serifItalic, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 0, ZIndex = 2, Parent = body })
		end
		for i, e in sec.entries do
			entryCard(body, i, e)
		end
		content.CanvasPosition = Vector2.new(0, 0)
	end

	local function showSearch(q: string)
		clear(body)
		q = string.lower(q)
		local n = 0
		for _, sec in guide.sections do
			for _, e in sec.entries do
				local hay = string.lower((e.title or "") .. " " .. (e.tag or "") .. " " .. (e.sub or "") .. " " .. (e.text or ""))
				if string.find(hay, q, 1, true) then
					n += 1
					if n <= 40 then
						local card = entryCard(body, n, e)
						Kit.text({ Text = string.upper(sec.name), FontFace = F.displayMed, TextSize = 10, TextColor3 = C.faint, LayoutOrder = 0, ZIndex = 2, Parent = card })
					end
				end
			end
		end
		if n == 0 then
			Kit.text({ Text = "Nothing in the guidebook matches that.", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.faint, ZIndex = 2, Parent = body })
		elseif n > 40 then
			Kit.text({ Text = string.format("%d more. Try a longer search.", n - 40), FontFace = F.uiMedium, TextSize = 12, TextColor3 = C.faint, LayoutOrder = 99, ZIndex = 2, Parent = body })
		end
	end

	search:GetPropertyChangedSignal("Text"):Connect(function()
		if not guide then
			return
		end
		local q = search.Text
		if #q >= 2 then
			showSearch(q)
		else
			showSection(current)
		end
	end)

	showSection(nil)
	ctx.actions.loadGuide(function(g)
		if sheet.isClosed() or not g then
			return
		end
		guide = g
		for i, s in g.sections do
			local b = Kit.button({ text = s.name, style = "secondary", size = UDim2.new(0, 0, 1, 0), order = i, textSize = 13, zIndex = 2, onClick = function()
				search.Text = ""
				showSection(s.id)
			end })
			b.AutomaticSize = Enum.AutomaticSize.X
			Kit.padding(0, 12, 0, 12).Parent = b
			b.Parent = tabs
			buttons[s.id] = b
		end
		showSection(current)
	end)
	return sheet
end

return Guide
