--[[
	The family name roll: spin for a surname. Shows the odds up front, the pity counter,
	a spin, and then keep-or-pass. Rolls are earned by playing.
		SurnameRoll.open(ctx, layer, state)
	ctx.actions.surnameRoll(cb(res)) and ctx.actions.surnameKeep(keep, cb(res)) talk to the server.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)
local Sheets = require(script.Parent.Sheets)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local SurnameRoll = {}

local function tierColor(state, tierId: string?): Color3
	for _, t in (state and state.tiers) or {} do
		if t.id == tierId and t.color then
			return Theme.rgb(t.color)
		end
	end
	return C.text
end

local function tierName(state, tierId: string?): string
	for _, t in (state and state.tiers) or {} do
		if t.id == tierId then
			return t.name
		end
	end
	return ""
end

function SurnameRoll.open(ctx, layer: Instance, initial)
	local sheet = Sheets.open(layer, "Family name")
	local content = sheet.content
	local state = initial
	local spinning = false
	local fill

	local function nameLine(parent, name: string?, tierId: string?, order: number, size: number)
		return Kit.text({
			Name = "SurnameText",
			Text = if name then Format.color(Format.escape(name), tierColor(state, tierId)) else "—",
			FontFace = F.display,
			TextSize = size,
			TextColor3 = C.text,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = order,
			ZIndex = 2,
			Parent = parent,
		})
	end

	function fill(rolledNow)
		Sheets.clear(content)
		if sheet.isClosed() then
			return
		end
		if not state then
			Kit.text({ Text = "No family names in this game.", FontFace = F.serifItalic, TextSize = 14, TextColor3 = C.sub, ZIndex = 2, Parent = content })
			return
		end
		Kit.text({
			Text = "Your family name goes on every new life you start. Rarer names carry a small trait. You earn rolls by playing: one a day for showing up, one for every life you finish, and more for big moments.",
			FontFace = F.serif,
			TextSize = 13,
			TextColor3 = C.sub,
			LayoutOrder = 1,
			ZIndex = 2,
			Parent = content,
		})
		-- the slot
		local slot = Kit.panel({ Name = "Slot", BackgroundColor3 = C.panelLo, LayoutOrder = 2, ZIndex = 2, Parent = content }, nil, C.accent)
		Kit.padding(16, 14, 16, 14).Parent = slot
		Kit.list(6, nil, Enum.HorizontalAlignment.Center).Parent = slot
		local showing = state.pending or state.current
		Kit.caps({
			Text = if state.pending then "You rolled" else "Your family name",
			FontFace = F.displayMed,
			TextSize = 12,
			TextColor3 = C.faint,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = 1,
			ZIndex = 2,
			Parent = slot,
		})
		local big = nameLine(slot, if showing then showing.name else nil, if showing then showing.tier else nil, 2, 34)
		Kit.caps({
			Text = if showing then tierName(state, showing.tier) else "Roll to get one",
			FontFace = F.display,
			TextSize = 13,
			TextColor3 = if showing then tierColor(state, showing.tier) else C.sub,
			TextXAlignment = Enum.TextXAlignment.Center,
			LayoutOrder = 3,
			ZIndex = 2,
			Parent = slot,
		})
		if showing and showing.flavor then
			Kit.text({
				Text = Format.escape(showing.flavor),
				FontFace = F.serifItalic,
				TextSize = 13,
				TextColor3 = C.sub,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = 4,
				ZIndex = 2,
				Parent = slot,
			})
		end
		if rolledNow and showing then
			local sc = new("UIScale", { Scale = 1.6, Parent = big })
			Kit.tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
		end
		-- keep or pass
		if state.pending then
			local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), LayoutOrder = 3, ZIndex = 2, Parent = content }, {
				Kit.list(8, Enum.FillDirection.Horizontal),
			})
			Kit.button({
				name = "KeepNew",
				text = "Keep " .. state.pending.name,
				style = "primary",
				size = UDim2.new(0.5, -4, 1, 0),
				order = 1,
				textSize = 14,
				zIndex = 2,
				onClick = function()
					ctx.actions.surnameKeep(true, function(res)
						if res and res.surnames then
							state = res.surnames
						end
						fill(false)
					end)
				end,
			}).Parent = row
			Kit.button({
				name = "KeepOld",
				text = if state.current then "Stay " .. state.current.name else "Pass",
				style = "ghost",
				size = UDim2.new(0.5, -4, 1, 0),
				order = 2,
				textSize = 14,
				zIndex = 2,
				onClick = function()
					ctx.actions.surnameKeep(false, function(res)
						if res and res.surnames then
							state = res.surnames
						end
						fill(false)
					end)
				end,
			}).Parent = row
		else
			-- one roll: spin through names while the server rolls (premium lands Rare or better)
			local function doRoll(premium: boolean)
				if spinning then
					return
				end
				spinning = true
				local pool = {}
				for _, t in state.tiers do
					for _, n in t.examples or {} do
						table.insert(pool, { name = n, tier = t.id })
					end
				end
				local result = nil
				ctx.actions.surnameRoll(function(res)
					result = res or { ok = false }
				end, premium)
				task.spawn(function()
					local t0 = os.clock()
					local i = 0
					while (os.clock() - t0 < 1.4 or result == nil) and os.clock() - t0 < 8 do
						i += 1
						local pick = pool[(i % math.max(1, #pool)) + 1]
						if pick and big.Parent then
							big.Text = Format.color(Format.escape(pick.name), tierColor(state, pick.tier))
							ctx.sound("click")
						end
						task.wait(0.05 + (os.clock() - t0) * 0.06)
					end
					spinning = false
					if result and result.ok and result.surnames then
						state = result.surnames
						local idx = 0
						for k, t in state.tiers do
							if t.id == result.rolled.tier then
								idx = k
							end
						end
						ctx.sound(if idx >= 3 then "win" else "coin")
						if idx >= 3 and ctx.celebrate then
							ctx.celebrate(string.upper(result.rolled.tierName or "Rare") .. " NAME", result.rolled.name, tierColor(state, result.rolled.tier))
						end
					elseif result and result.error and ctx.toast then
						ctx.toast(result.error)
					end
					fill(true)
				end)
			end
			local rollBtn = Kit.button({
				name = "Roll",
				text = string.format("Roll  (%d left)", state.rolls or 0),
				style = if (state.rolls or 0) > 0 then "primary" else "ghost",
				size = UDim2.new(1, 0, 0, 46),
				order = 3,
				textSize = 16,
				zIndex = 2,
				enabled = (state.rolls or 0) > 0,
				onClick = function()
					doRoll(false)
				end,
			})
			rollBtn.Parent = content
			if (state.premiumRolls or 0) > 0 then
				local premiumBtn = Kit.button({
					name = "RollPremium",
					text = string.format("Rare-or-better roll  (%d left)", state.premiumRolls),
					style = "primary",
					size = UDim2.new(1, 0, 0, 42),
					order = 3,
					textSize = 15,
					zIndex = 2,
					onClick = function()
						doRoll(true)
					end,
				})
				premiumBtn.Parent = content
			end
			-- the odds of a Rare-or-better roll, shown before it's used or bought
			if state.premiumOdds and #state.premiumOdds > 0 then
				local parts = {}
				for _, o in state.premiumOdds do
					table.insert(parts, string.format("%s %.1f%%", o.name, o.odds))
				end
				Kit.text({
					Text = "A Rare-or-better roll lands: " .. Format.escape(table.concat(parts, "  ·  ")),
					FontFace = F.uiMedium,
					TextSize = 12,
					TextColor3 = C.faint,
					TextXAlignment = Enum.TextXAlignment.Center,
					LayoutOrder = 3,
					ZIndex = 2,
					Parent = content,
				})
			end
			if ctx.info and ctx.info.storeOpen then
				local more = Kit.button({
					name = "MoreRolls",
					text = "More rolls in the Store",
					style = "ghost",
					size = UDim2.new(1, 0, 0, 34),
					order = 3,
					textSize = 13,
					zIndex = 2,
					onClick = function()
						ctx.actions.openStore()
					end,
				})
				more.Parent = content
			end
		end
		-- pity
		if state.pityAt and state.pityTier then
			local left = math.max(1, state.pityAt - (state.pity or 0))
			Kit.text({
				Text = string.format("%s or better guaranteed within %d %s.", state.pityTier, left, if left == 1 then "roll" else "rolls"),
				FontFace = F.uiMedium,
				TextSize = 12,
				TextColor3 = C.strange,
				TextXAlignment = Enum.TextXAlignment.Center,
				LayoutOrder = 4,
				ZIndex = 2,
				Parent = content,
			})
		end
		-- the odds, in full
		Sheets.sectionTitle(content, "The odds", 5)
		for i, t in state.tiers do
			local color = if t.color then Theme.rgb(t.color) else C.text
			local r = Kit.panel({ BackgroundColor3 = C.panelLo, LayoutOrder = 5 + i, ZIndex = 2, Parent = content })
			Kit.padding(8, 12, 8, 12).Parent = r
			Kit.list(3).Parent = r
			Kit.text({
				Text = Format.color(string.upper(t.name), color) .. "   " .. Format.color(string.format("%.1f%%", t.odds), C.sub),
				FontFace = F.display,
				TextSize = 14,
				LayoutOrder = 1,
				ZIndex = 2,
				Parent = r,
			})
			if t.perk then
				Kit.text({ Text = Format.escape(t.perk), FontFace = F.serif, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 2, ZIndex = 2, Parent = r })
			end
			if t.examples and #t.examples > 0 then
				Kit.text({ Text = "e.g. " .. Format.escape(table.concat(t.examples, ", ")), FontFace = F.ui, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 3, ZIndex = 2, Parent = r })
			end
		end
	end

	fill(false)
	if not state then
		ctx.actions.loadSurnames(function(s)
			state = s
			fill(false)
		end)
	end
	return sheet
end

return SurnameRoll
