--[[
	The talent card: the random talent the next life is born with, by rarity, with the
	rerolls. Used by the quick creator and the full creator.
		local card = Talent.card(ctx, parent, order)   -> { frame, refresh() }
	Reads ctx.state.talent (from the server: hello, newLife, talentReroll):
		{ talent = { id, name, desc, tier, tierName, color, rank }, free, lunacy, cost,
		  premiumCost, odds, premiumOdds, pityLeft, pityAt, restricted }
	Odds are the real ones, shown before every paid roll.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Talent = {}

local LUNACY = Color3.fromRGB(240, 92, 120)

local function oddsLine(list): string
	local parts = {}
	for _, o in list or {} do
		local pct = if o.percent >= 10 then string.format("%d%%", math.floor(o.percent + 0.5)) else string.format("%.1f%%", o.percent)
		table.insert(parts, o.name .. " " .. pct)
	end
	return table.concat(parts, " · ")
end
Talent.oddsLine = oddsLine

-- every talent's name, for the shuffle while a reroll lands
local function talentNames(ctx)
	local out = {}
	for _, t in (ctx.info and ctx.info.traits) or {} do
		if t.talent then
			table.insert(out, t)
		end
	end
	return out
end

local function tierColor(ctx, tierId: string?): Color3
	for _, t in (ctx.info and ctx.info.talentTiers) or {} do
		if t.id == tierId and t.color then
			return Theme.rgb(t.color)
		end
	end
	return C.sub
end

function Talent.card(ctx, parent: Instance, order: number)
	local frame = new("Frame", {
		Name = "Talent",
		BackgroundColor3 = C.panelHi,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		ClipsDescendants = false,
		Parent = parent,
	}, { Kit.corner(2), Kit.padding(12, 14, 12, 14), Kit.list(6) })
	local stroke = Kit.stroke(C.stroke, 2, 0.1)
	stroke.Parent = frame
	local top = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, Parent = frame })
	Kit.caps({ Text = "Your talent", FontFace = F.display, TextSize = 13, TextColor3 = C.sub, Size = UDim2.new(0.5, 0, 1, 0), Parent = top })
	local tierChip = new("TextLabel", {
		Name = "Tier",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		BackgroundColor3 = C.panelLo,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "",
		FontFace = F.display,
		TextSize = 12,
		TextColor3 = C.sub,
		Parent = top,
	}, { Kit.corner(2), Kit.padding(0, 10, 0, 10) })
	local chipStroke = Kit.stroke(C.stroke, 1, 0.2)
	chipStroke.Parent = tierChip
	local name = Kit.text({ Name = "TalentName", Text = "", FontFace = F.display, TextSize = 24, LayoutOrder = 2, Parent = frame })
	local desc = Kit.text({ Name = "TalentDesc", Text = "", FontFace = F.serif, TextSize = 13, TextColor3 = C.sub, LayoutOrder = 3, Parent = frame })
	-- its sin, and whether it resonates with yours
	local sin = Kit.text({ Name = "TalentSin", Text = "", FontFace = F.displayMed, TextSize = 12, TextColor3 = C.sub, LayoutOrder = 3, Visible = false, Parent = frame })
	local bar = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 4, Parent = frame }, {
		Kit.list(6, Enum.FillDirection.Horizontal),
	})
	local note = Kit.text({ Name = "Note", Text = "", FontFace = F.uiMedium, TextSize = 11, TextColor3 = C.faint, LayoutOrder = 5, Parent = frame })

	local busy = false
	local api = {}

	local function paintTalent(t)
		if not t then
			name.Text = "?"
			desc.Text = ""
			tierChip.Text = ""
			return
		end
		local color = if t.color then Theme.rgb(t.color) else tierColor(ctx, t.tier)
		name.Text = string.upper(Format.escape(t.name))
		name.TextColor3 = color
		desc.Text = Format.escape(t.desc or "")
		if t.affinityName then
			local sinColor = if t.affinityColor then Theme.rgb(t.affinityColor) else C.sub
			sin.Visible = true
			sin.Text = Format.color(string.upper((ctx.info and ctx.info.affinityLabel) or "Sin") .. "  ", C.faint)
				.. Format.color(string.upper(Format.escape(t.affinityName)), sinColor)
				.. (if t.resonance then "   " .. Format.color(string.format("RESONANCE  +%d%% HEADS", (ctx.info and ctx.info.affinityResonance) or 3), sinColor) else "")
		else
			sin.Visible = false
		end
		tierChip.Text = string.upper(t.tierName or t.tier or "")
		tierChip.TextColor3 = color
		chipStroke.Color = color
		stroke.Color = color
		stroke.Transparency = if (t.rank or 1) >= 4 then 0 else 0.45
		-- rarer talents tint the card more
		frame.BackgroundColor3 = C.panelHi:Lerp(color, if (t.rank or 1) >= 5 then 0.22 elseif (t.rank or 1) >= 3 then 0.12 else 0.05)
	end

	local function clearBar()
		for _, c in bar:GetChildren() do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
	end

	local function land(st, rolled)
		local names = talentNames(ctx)
		task.spawn(function()
			-- a quick shuffle through the talents, then the one you got
			sin.Visible = false
			for i = 1, 10 do
				local pick = names[math.random(1, math.max(1, #names))]
				if pick and frame.Parent then
					name.Text = string.upper(Format.escape(pick.name))
					name.TextColor3 = tierColor(ctx, pick.talent)
				end
				ctx.sound("click")
				task.wait(0.04 + i * 0.01)
			end
			api.refresh()
			local t = rolled or (st and st.talent)
			if t and (t.rank or 1) >= 4 then
				local color = if t.color then Theme.rgb(t.color) else C.accentHi
				ctx.sound("win")
				if ctx.fx then
					ctx.fx.flash(color, if (t.rank or 1) >= 5 then 0.45 else 0.25)
				end
				Kit.stamp(frame, string.upper(t.tierName or ""), color, { Position = UDim2.new(1, -60, 0, 8) })
				Kit.shake(frame, if (t.rank or 1) >= 6 then 10 else 5, 0.3)
			end
			busy = false
		end)
	end

	local function reroll(premium: boolean, lunacy: boolean)
		if busy then
			return
		end
		busy = true
		ctx.actions.talentReroll(premium, lunacy, function(st, rolled)
			if st then
				land(st, rolled)
			else
				busy = false
			end
		end)
	end

	function api.refresh()
		local st = ctx.state.talent
		frame.Visible = st ~= nil
		if not st then
			return
		end
		paintTalent(st.talent)
		clearBar()
		local premiumName = (ctx.info and ctx.info.lunacy) or "Lunacy"
		local free = st.free or 0
		local freeLabel = if free > 0 then string.format("Reroll  ·  %d free", free) elseif st.restricted then "No free rerolls today" else string.format("Reroll  ·  %d %s", st.cost or 0, premiumName)
		Kit.button({
			name = "Reroll",
			text = freeLabel,
			style = if free > 0 then "primary" else "secondary",
			size = UDim2.new(0, 170, 1, 0),
			order = 1,
			textSize = 13,
			enabled = free > 0 or not st.restricted,
			onClick = function()
				if free > 0 then
					reroll(false, false)
				else
					ctx.prompt({
						title = "Reroll your talent",
						text = string.format("No free rerolls left today. Spend %d %s? You have %d.\nOdds: %s", st.cost or 0, premiumName, st.lunacy or 0, oddsLine(st.odds)),
						buttons = {
							{ label = "Not now", style = "ghost" },
							{ label = "Reroll", style = "primary", onClick = function()
								reroll(false, true)
							end },
						},
					})
				end
			end,
		}).Parent = bar
		if not st.restricted then
			Kit.button({
				name = "RerollPremium",
				text = string.format("Rare+  ·  %d", st.premiumCost or 0),
				style = "secondary",
				size = UDim2.new(0, 130, 1, 0),
				order = 2,
				textSize = 13,
				onClick = function()
					ctx.prompt({
						title = "Rare-or-better reroll",
						text = string.format(
							"Spend %d %s? You have %d.\nOdds: %s\nLegendary or better within %d more.",
							st.premiumCost or 0,
							premiumName,
							st.lunacy or 0,
							oddsLine(st.premiumOdds),
							math.max(1, st.pityLeft or 0)
						),
						buttons = {
							{ label = "Not now", style = "ghost" },
							{ label = "Reroll", style = "primary", onClick = function()
								reroll(true, true)
							end },
						},
					})
				end,
			}).Parent = bar
		end
		Kit.button({
			name = "Odds",
			text = "Odds",
			style = "ghost",
			size = UDim2.new(0, 64, 1, 0),
			order = 3,
			textSize = 13,
			onClick = function()
				local lines = {}
				for _, o in st.odds or {} do
					local pct = if o.percent >= 10 then string.format("%d%%", math.floor(o.percent + 0.5)) else string.format("%.1f%%", o.percent)
					table.insert(lines, string.format("%s  %s  (%d talents)", o.name, pct, o.count or 0))
				end
				ctx.prompt({
					title = "Talent odds",
					text = table.concat(lines, "\n") .. "\n\nEvery life is born with one. Rarer ones are much stronger.",
					buttons = { { label = "Got it", style = "primary" } },
				})
			end,
		}).Parent = bar
		note.Text = if st.restricted
			then "Free rerolls come back every day."
			else string.format("%s %s  ·  free rerolls come back every day", Format.color(tostring(st.lunacy or 0), LUNACY), Format.escape(premiumName))
	end

	api.frame = frame
	api.refresh()
	return api
end

return Talent
