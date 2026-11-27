--[[
	THE HUNTERS' MARKET SCREEN (BitLeveling): buy weapons other players are selling, and sell
	your own. BROWSE lists every weapon on the server's market, strongest first, with its stars,
	its shine, its grade, what it does and its price. SELL lists your weapons (the one in your
	hand and your stash) with a price box (the broker's value is filled in) and your listings.
	The server does every check (server/HunterMarket).
]]

local Theme = require(script.Parent:WaitForChild("Theme"))
local C, F = Theme.colors, Theme.fonts

local MarketUI = {}
local open: Frame? = nil

local RARITY = {
	common = Color3.fromRGB(200, 200, 206),
	rare = Color3.fromRGB(110, 170, 255),
	epic = Color3.fromRGB(190, 120, 255),
	legendary = Color3.fromRGB(255, 200, 90),
	unreal = Color3.fromRGB(255, 110, 140),
}

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

function MarketUI.close()
	if open then
		open:Destroy()
		open = nil
	end
end

function MarketUI.open(gui: ScreenGui, call: (string, any?) -> any, toast: ((string, Color3?) -> ())?)
	MarketUI.close()
	local frame = make("Frame", { Name = "Market", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.9, 0.84), BackgroundColor3 = C.panel, ZIndex = 25 }, gui)
	make("UISizeConstraint", { MaxSize = Vector2.new(900, 700) }, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, frame)
	make("UIStroke", { Color = RARITY.legendary, Transparency = 0.4, Thickness = 1.5 }, frame)
	open = frame
	make("TextLabel", { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -140, 0, 30), BackgroundTransparency = 1, Text = "HUNTERS' MARKET", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = RARITY.legendary, FontFace = F.display, TextSize = 26 }, frame)
	local sub = make("TextLabel", { Position = UDim2.fromOffset(16, 40), Size = UDim2.new(1, -32, 0, 18), BackgroundTransparency = 1, Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, FontFace = F.uiMedium, TextSize = 13 }, frame)
	local closeBtn = make("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(90, 30), BackgroundColor3 = C.panelHi, Text = "CLOSE", TextColor3 = C.text, FontFace = F.display, TextSize = 14 }, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 5) }, closeBtn)
	closeBtn.Activated:Connect(MarketUI.close)
	local tabs = make("Frame", { Position = UDim2.fromOffset(16, 64), Size = UDim2.new(1, -32, 0, 30), BackgroundTransparency = 1 }, frame)
	make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, tabs)
	local body = make("ScrollingFrame", { Position = UDim2.fromOffset(16, 100), Size = UDim2.new(1, -32, 1, -112), BackgroundTransparency = 1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BorderSizePixel = 0 }, frame)
	make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, body)

	local market: any = nil
	local tab = "browse"
	local render: () -> ()
	local function say(text: string?, good: boolean?)
		if text and toast then
			toast(text, if good then C.good else C.crimsonHi)
		end
	end
	local function act(action: string, payload: any)
		local res = call(action, payload)
		if res and res.market then
			market = res.market
		end
		if res then
			say(res.toast or res.error, res.ok)
		end
		render()
	end

	local function row(order: number, v: any, right: (Frame) -> ())
		local r = make("Frame", { LayoutOrder = order, Size = UDim2.new(1, -8, 0, 64), BackgroundColor3 = C.panelHi, BackgroundTransparency = 0.15 }, body)
		make("UICorner", { CornerRadius = UDim.new(0, 5) }, r)
		local color = RARITY[v.rarity or "common"] or C.text
		if v.shiny then
			make("UIStroke", { Color = RARITY.legendary, Thickness = 1.5, Transparency = 0.2 }, r)
		end
		make("TextLabel", { Position = UDim2.fromOffset(10, 6), Size = UDim2.new(0.62, 0, 0, 20), BackgroundTransparency = 1, Text = v.name .. (if v.equipped then "  (in hand)" else ""), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = color, FontFace = F.uiBold, TextSize = 15 }, r)
		make("TextLabel", { Position = UDim2.fromOffset(10, 26), Size = UDim2.new(0.62, 0, 0, 16), BackgroundTransparency = 1, Text = string.format("%s-grade %s · power %.1f%s", v.grade or "?", string.lower(v.family or ""), v.power or 0, if v.seller then " · sold by " .. v.seller else ""), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, FontFace = F.ui, TextSize = 12 }, r)
		make("TextLabel", { Position = UDim2.fromOffset(10, 42), Size = UDim2.new(0.62, 0, 0, 16), BackgroundTransparency = 1, Text = v.effect or "", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = C.faint, FontFace = F.ui, TextSize = 12 }, r)
		local side = make("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.36, 0, 0, 40), BackgroundTransparency = 1 }, r)
		make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6) }, side)
		right(side)
	end
	local function button(parent: Instance, text: string, color: Color3, onClick: () -> ())
		local b = make("TextButton", { Size = UDim2.fromOffset(96, 34), BackgroundColor3 = color, Text = text, TextColor3 = Color3.new(1, 1, 1), FontFace = F.display, TextSize = 14 }, parent)
		make("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
		b.Activated:Connect(onClick)
		return b
	end
	local function note(order: number, text: string)
		make("TextLabel", { LayoutOrder = order, Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.sub, FontFace = F.ui, TextSize = 14 }, body)
	end

	render = function()
		for _, c in body:GetChildren() do
			if not c:IsA("UIListLayout") then
				c:Destroy()
			end
		end
		if not market then
			note(1, "Loading the market...")
			return
		end
		local odds = market.odds or {}
		local sw = odds.stars or { 70, 24, 6 }
		local total = sw[1] + sw[2] + sw[3]
		sub.Text = string.format("Your money: %d million won · a drop's odds: ★ %d%%, ★★ %d%%, ★★★ %d%%, Shiny 1 in %d", market.money or 0, math.floor(sw[1] / total * 100 + 0.5), math.floor(sw[2] / total * 100 + 0.5), math.floor(sw[3] / total * 100 + 0.5), math.floor(1 / (odds.shiny or (1 / 60)) + 0.5))
		if tab == "browse" then
			if #market.listings == 0 then
				note(1, "Nothing is for sale on this server right now. Weapons come out of Gates (raids, breaks, Red Gates and Double Dungeons drop better ones): sell yours on the SELL tab.")
			end
			for i, v in market.listings do
				row(i, v, function(side)
					make("TextLabel", { Size = UDim2.fromOffset(120, 34), BackgroundTransparency = 1, Text = string.format("%d M won", v.price), TextColor3 = RARITY.legendary, FontFace = F.display, TextSize = 16 }, side)
					if v.mine then
						button(side, "TAKE BACK", C.panel, function()
							act("mkCancel", { id = v.id })
						end)
					else
						button(side, "BUY", Color3.fromRGB(60, 130, 90), function()
							act("mkBuy", { id = v.id })
						end)
					end
				end)
			end
		else
			if not market.alive then
				note(1, "Start a life to sell its weapons.")
				return
			end
			if #market.mine == 0 then
				note(1, "You don't have any weapons. The workshops sell plain ones; Gates drop the rest.")
			end
			for i, v in market.mine do
				row(i, v, function(side)
					local box = make("TextBox", { Size = UDim2.fromOffset(100, 34), BackgroundColor3 = C.panelLo, Text = tostring(v.value or 1), PlaceholderText = "price", TextColor3 = C.text, FontFace = F.uiBold, TextSize = 14, ClearTextOnFocus = false }, side)
					make("UICorner", { CornerRadius = UDim.new(0, 5) }, box)
					button(side, "SELL", Color3.fromRGB(150, 110, 40), function()
						local price = tonumber((string.gsub(box.Text, "[^%d]", "")))
						if not price then
							say("Type a price in million won.", false)
							return
						end
						act("mkSell", { gear = v.gear, price = price })
					end)
				end)
			end
			local mineListed = 0
			for _, v in market.listings do
				if v.mine then
					mineListed += 1
				end
			end
			if mineListed > 0 then
				note(500, string.format("You have %d weapon%s on the market (BROWSE to take one back).", mineListed, if mineListed == 1 then "" else "s"))
			end
		end
	end

	for _, t in { { "browse", "BROWSE" }, { "sell", "SELL" }, { "refresh", "REFRESH" } } do
		local b = make("TextButton", { Size = UDim2.fromOffset(110, 30), BackgroundColor3 = C.panelHi, Text = t[2], TextColor3 = C.text, FontFace = F.display, TextSize = 14 }, tabs)
		make("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
		b.Activated:Connect(function()
			if t[1] == "refresh" then
				act("mkOpen", nil)
			else
				tab = t[1]
				render()
			end
		end)
	end
	render()
	task.spawn(act, "mkOpen", nil)
end

return MarketUI
