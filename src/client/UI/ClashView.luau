--[[
	Coin clash playback. The server already decided the outcome; this animates it.
		ClashView.play(ctx, layer, clash)   a fight: full screen, rounds, status effects.
		                                     Tap anywhere to fast-forward. Yields until Continue.
		ClashView.check(ctx, layer, clash)  a quick check (not a fight): a small card with the
		                                     coins and the result. Yields until it closes.
	Fights show each side's status effects (Tremor, Rupture, Bleed, Burn, Sinking, Poise,
	Charge) and call out bursts, crits and the like as they happen.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Vfx = require(script.Parent.Vfx)
local Format = require(script.Parent.Format)
local AvatarView = require(script.Parent.AvatarView)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Emblem = require(script.Parent.Emblem)

local ClashView = {}



-- status names and colors (a pack can override them with info.statuses)
local STATUS = {
	tremor = { name = "Tremor", color = { 214, 180, 92 } },
	rupture = { name = "Rupture", color = { 96, 200, 170 } },
	bleed = { name = "Bleed", color = { 214, 64, 64 } },
	burn = { name = "Burn", color = { 238, 120, 44 } },
	sinking = { name = "Sinking", color = { 92, 120, 220 } },
	poise = { name = "Poise", color = { 140, 210, 240 } },
	charge = { name = "Charge", color = { 120, 200, 255 } },
	-- weapon abilities (callouts only)
	guard = { name = "Guard", color = { 200, 200, 214 } },
	riposte = { name = "Riposte", color = { 240, 210, 120 } },
	crush = { name = "Crush", color = { 230, 140, 90 } },
	reach = { name = "Reach", color = { 150, 220, 190 } },
	volley = { name = "Volley", color = { 250, 230, 150 } },
}
local CALLOUTS = {
	burst = { "TREMOR BURST!", "tremor" },
	crit = { "CRITICAL!", "poise" },
	bleed = { "BLEED", "bleed" },
	burn = { "BURN", "burn" },
	discharge = { "DISCHARGE!", "charge" },
	guard = { "GUARD", "guard" },
	riposte = { "RIPOSTE", "riposte" },
	crush = { "CRUSH!", "crush" },
	reach = { "OUT OF REACH", "reach" },
	volley = { "VOLLEY!", "volley" },
}

local function statusDef(ctx, id: string)
	local custom = ctx.info and ctx.info.statuses and ctx.info.statuses[id]
	return custom or STATUS[id] or { name = id, color = { 200, 200, 200 } }
end

-- a creature that isn't a person any more: a silhouette with eyes (Foes.luau `shape`)
local function creature(parent: Instance, enemy, z: number)
	local body = Theme.rgb(enemy.color or { 40, 40, 46 })
	local eye = Theme.rgb(enemy.eye or { 236, 70, 52 })
	local holder = new("Frame", { Name = "Creature", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = z, Parent = parent })
	local function part(pos: UDim2, size: UDim2, color: Color3, round: boolean?, rot: number?)
		return new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = pos,
			Size = size,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Rotation = rot or 0,
			ZIndex = z,
			Parent = holder,
		}, if round then { Kit.round() } else { Kit.corner(4) })
	end
	local shape = enemy.shape or "blob"
	local eyes = {}
	if shape == "tall" then
		part(UDim2.fromScale(0.5, 0.62), UDim2.fromScale(0.28, 0.7), body)
		part(UDim2.fromScale(0.5, 0.2), UDim2.fromScale(0.24, 0.18), body, true)
		part(UDim2.fromScale(0.36, 0.6), UDim2.fromScale(0.06, 0.5), body, false, 8)
		part(UDim2.fromScale(0.64, 0.6), UDim2.fromScale(0.06, 0.5), body, false, -8)
		eyes = { UDim2.fromScale(0.46, 0.2), UDim2.fromScale(0.54, 0.2) }
	elseif shape == "beast" then
		part(UDim2.fromScale(0.48, 0.66), UDim2.fromScale(0.62, 0.3), body, false)
		part(UDim2.fromScale(0.78, 0.5), UDim2.fromScale(0.26, 0.24), body, true)
		for _, x in { 0.28, 0.42, 0.56, 0.68 } do
			part(UDim2.fromScale(x, 0.86), UDim2.fromScale(0.05, 0.18), body)
		end
		eyes = { UDim2.fromScale(0.76, 0.46), UDim2.fromScale(0.84, 0.46) }
	elseif shape == "swarm" then
		for i, pos in { { 0.3, 0.5 }, { 0.55, 0.38 }, { 0.72, 0.62 }, { 0.42, 0.74 }, { 0.6, 0.82 }, { 0.25, 0.8 } } do
			local sz = 0.16 + (i % 3) * 0.04
			part(UDim2.fromScale(pos[1], pos[2]), UDim2.fromScale(sz, sz * 0.8), body, true)
			table.insert(eyes, UDim2.fromScale(pos[1] + 0.02, pos[2] - 0.02))
		end
	elseif shape == "machine" then
		part(UDim2.fromScale(0.5, 0.6), UDim2.fromScale(0.5, 0.5), body)
		part(UDim2.fromScale(0.5, 0.28), UDim2.fromScale(0.3, 0.18), body)
		part(UDim2.fromScale(0.5, 0.14), UDim2.fromScale(0.02, 0.12), body)
		part(UDim2.fromScale(0.26, 0.6), UDim2.fromScale(0.08, 0.36), body)
		part(UDim2.fromScale(0.74, 0.6), UDim2.fromScale(0.08, 0.36), body)
		eyes = { UDim2.fromScale(0.44, 0.28), UDim2.fromScale(0.56, 0.28) }
	elseif shape == "bird" then
		part(UDim2.fromScale(0.5, 0.55), UDim2.fromScale(0.2, 0.3), body, true)
		part(UDim2.fromScale(0.3, 0.45), UDim2.fromScale(0.36, 0.1), body, false, -24)
		part(UDim2.fromScale(0.7, 0.45), UDim2.fromScale(0.36, 0.1), body, false, 24)
		eyes = { UDim2.fromScale(0.47, 0.48), UDim2.fromScale(0.53, 0.48) }
	else -- blob, mass
		part(UDim2.fromScale(0.5, 0.6), UDim2.fromScale(0.62, 0.62), body, true)
		part(UDim2.fromScale(0.34, 0.4), UDim2.fromScale(0.26, 0.26), body, true)
		part(UDim2.fromScale(0.66, 0.44), UDim2.fromScale(0.22, 0.22), body, true)
		eyes = { UDim2.fromScale(0.42, 0.5), UDim2.fromScale(0.58, 0.52), UDim2.fromScale(0.5, 0.66), UDim2.fromScale(0.34, 0.4) }
	end
	for _, pos in eyes do
		part(pos, UDim2.fromOffset(6, 6), eye, true)
	end
	return holder
end

-- the 3D creatures (Engine/Creatures, UI/CreatureView); the flat silhouette above is the fallback
local CreatureView = nil
do
	local ok, mod = pcall(function()
		return require(script.Parent:FindFirstChild("CreatureView"))
	end)
	if ok then
		CreatureView = mod
	end
end

-- a figure on the stage: a person (an avatar) or a creature.
-- Returns the holder and, for a creature, a function that puts it in a pose
-- ("idle" | "strike" | "hurt" | "down").
local function figure(ctx, parent: Instance, appearance, enemy, z: number)
	local holder = new("Frame", { Name = "Figure", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = z, Parent = parent })
	local pose = nil
	if enemy and enemy.kind == "creature" then
		local drawn = false
		if CreatureView then
			drawn = pcall(function()
				local view = CreatureView.new(ctx, { size = UDim2.fromScale(1, 1), framing = "full", zIndex = z, background = false })
				view.frame.Parent = holder
				view:set(enemy)
				pose = function(name: string)
					pcall(function()
						view:pose(name)
					end)
				end
			end)
		end
		if not drawn then
			pose = nil
			creature(holder, enemy, z)
		end
	elseif appearance then
		local view = AvatarView.new(ctx, { size = UDim2.fromScale(1, 1), framing = "full", zIndex = z, background = C.panel })
		view.frame.BackgroundTransparency = 1
		view.frame.Parent = holder
		view:set(appearance)
	else
		-- nobody to draw: a silhouette
		new("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.fromScale(0.5, 1), Size = UDim2.fromScale(0.36, 0.62), BackgroundColor3 = C.panelHi, BorderSizePixel = 0, ZIndex = z, Parent = holder }, { Kit.corner(6) })
		new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.26), Size = UDim2.fromScale(0.24, 0.2), BackgroundColor3 = C.panelHi, BorderSizePixel = 0, ZIndex = z, Parent = holder }, { Kit.round() })
	end
	return holder, pose
end

-- a line from a foe, in a little speech bubble over its head
local function bubble(parent: Instance, text: string, right: boolean, z: number)
	local b = new("TextLabel", {
		Name = "Bark",
		AnchorPoint = Vector2.new(if right then 1 else 0, 1),
		Position = UDim2.new(if right then 1 else 0, if right then -6 else 6, 0, 30),
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = C.paperHi,
		Text = text,
		TextWrapped = true,
		FontFace = F.serifItalic,
		TextSize = 13,
		TextColor3 = C.ink,
		TextTransparency = 1,
		BackgroundTransparency = 1,
		ZIndex = z,
		Parent = parent,
	}, { Kit.corner(6), Kit.padding(5, 9, 5, 9), new("UISizeConstraint", { MaxSize = Vector2.new(210, 120) }) })
	Kit.tween(b, 0.18, { TextTransparency = 0, BackgroundTransparency = 0 })
	task.delay(1.9, function()
		if b.Parent then
			Kit.tween(b, 0.3, { TextTransparency = 1, BackgroundTransparency = 1 })
			task.delay(0.32, function()
				b:Destroy()
			end)
		end
	end)
	return b
end

local function pickLine(list): string?
	if type(list) == "table" and #list > 0 then
		return list[math.random(1, #list)]
	end
	return nil
end

-- A fight on a stage: you on the left, them on the right. Coins flip over each side,
-- the powers clash in the middle, the winner lunges and the loser reels. Tap to hurry.
-- the scene illustration module (client/SceneArt); optional, loaded once
local sceneArt = nil
local function getSceneArt()
	if sceneArt == nil then
		sceneArt = false
		local mod = script.Parent.Parent:FindFirstChild("SceneArt")
		if mod then
			local ok, m = pcall(require, mod)
			if ok and type(m) == "table" and m.draw then
				sceneArt = m
			end
		end
	end
	return sceneArt or nil
end

-- the stage: its height, where the two powers meet, how big a coin is
local STAGE_FULL, COIN = 320, 28

function ClashView.play(ctx, layer: Instance, clash)
	-- (a narrow screen gets a shorter stage, so the fighters don't crowd the numbers)
	local layerW = (layer :: any).AbsoluteSize.X
	local narrow = layerW > 0 and layerW < 470
	local STAGE_H = if narrow then 264 else STAGE_FULL
	local MID_Y = STAGE_H / 2
	local speed = 1
	local done = false
	local continueEvent = Instance.new("BindableEvent")
	local function sfx(name: string, opts: any?)
		if ctx.sfx then
			ctx.sfx(name, opts)
		end
	end

	local scrim = Kit.scrim(layer, 1)
	scrim.BackgroundTransparency = 0.08
	Kit.stripes(scrim, C.crimsonLo, 0.82, 14)
	local skip = new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 2, Parent = scrim })
	skip.Activated:Connect(function()
		speed = 0.15
	end)

	local card = Kit.panel({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.new(1, -8, 0, 0),
		BackgroundColor3 = C.panel,
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = layer,
	}, nil, C.crimson)
	Kit.padding(14, 14, 16, 14).Parent = card
	Kit.list(8, nil, Enum.HorizontalAlignment.Center).Parent = card

	-- banner: FIGHT / DUEL / BLOOD DUEL / BOSS
	local statDef = clash.stat and ctx.info.stats.defs[clash.stat]
	local statName = if statDef then statDef.name else "Clash"
	local banner = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		Text = if clash.duel then (if clash.blood then "BLOOD DUEL" else "DUEL") elseif clash.boss then "BOSS" elseif clash.fight then "FIGHT" else "CLASH",
		FontFace = F.display,
		TextSize = 46,
		TextColor3 = C.crimsonHi,
		LayoutOrder = 1,
		Rotation = -3,
		ZIndex = 4,
		Parent = card,
	})
	local bannerScale = new("UIScale", { Scale = 2.2, Parent = banner })
	banner.TextTransparency = 1
	Kit.tween(bannerScale, 0.24, { Scale = 1 }, Enum.EasingStyle.Back)
	Kit.tween(banner, 0.14, { TextTransparency = 0 })
	local approachName = clash.approach and ctx.info.approaches and ctx.info.approaches[clash.approach]
	local subText = string.upper(statName) .. (if approachName then "  ·  " .. string.upper(tostring(approachName)) else "")
	local stance = clash.stance
	if stance and stance.name then
		-- fighting by stat: "YOU OUTTHINK (INTELLIGENCE)  ·  THEY ARE QUICK  ·  ADVANTAGE"
		local sdef = stance.stat and ctx.info.stats.defs[stance.stat]
		subText = "YOU " .. string.upper(stance.name) .. (if sdef then "  (" .. string.upper(sdef.name) .. ")" else "")
		if clash.temper then
			local tcolor = if clash.temper.color then Theme.rgb(clash.temper.color) else C.sub
			subText ..= "   ·   THEY ARE " .. Format.color(string.upper(clash.temper.name), tcolor)
		end
		local edge = clash.player and clash.player.edge
		if edge == "advantage" then
			subText ..= "   ·   " .. Format.color("ADVANTAGE", C.good)
		elseif edge == "resisted" then
			subText ..= "   ·   " .. Format.color("RESISTED", C.bad)
		end
	end
	Kit.caps({
		Name = "How",
		Text = subText,
		RichText = true,
		TextSize = 14,
		TextColor3 = C.accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 2,
		ZIndex = 4,
		Parent = card,
	})

	-- ── the stage ───────────────────────────────────────────────────────────
	local stage = new("Frame", {
		Name = "Stage",
		BackgroundColor3 = C.panelLo,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, STAGE_H),
		ClipsDescendants = true,
		LayoutOrder = 3,
		ZIndex = 3,
		Parent = card,
	}, { Kit.corner(2) })
	-- the place it's happening: the scene's own art (or a back street), under a dark veil so
	-- the fighters stand out
	local art = getSceneArt()
	if art then
		local back = new("Frame", { Name = "Backdrop", BackgroundColor3 = C.panelLo, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0.72, 0), ClipsDescendants = true, ZIndex = 3, Parent = stage })
		local seed = 0
		for i = 1, #((clash.foe and clash.foe.name) or "") do
			seed = (seed * 31 + string.byte(clash.foe.name, i)) % 100000
		end
		local okArt = pcall(function()
			art.draw(back, clash.art or (if clash.enemy and clash.enemy.kind == "creature" then "night" else "alley"), seed, { fade = C.panelLo })
		end)
		if not okArt then
			back:Destroy()
		else
			new("Frame", { Name = "Veil", BackgroundColor3 = C.panelLo, BackgroundTransparency = 0.38, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = stage })
		end
	end
	-- a floor and a little light on each side
	new("Frame", { BackgroundColor3 = C.crimsonLo, BackgroundTransparency = 0.6, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 46), ZIndex = 3, Parent = stage }, {
		new("UIGradient", { Rotation = 270, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }) }),
	})

	local Z = 4
	local function side(sideData, right: boolean, appearance, enemy)
		local col = new("Frame", {
			Name = if right then "Foe" else "Player",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(if right then 1 else 0, 0),
			Position = UDim2.new(if right then 1 else 0, if right then -4 else 4, 0, 0),
			Size = UDim2.new(if narrow then 0.37 else 0.42, 0, 1, 0),
			ZIndex = Z,
			Parent = stage,
		})
		-- the coins over their head
		local coinBar = new("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 8),
			Size = UDim2.new(1, 0, 0, COIN + 6),
			ZIndex = Z,
			Parent = col,
		}, { Kit.list(6, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center) })
		local coins = {}
		for i = 1, sideData.coins do
			local coin = new("TextLabel", {
				Size = UDim2.fromOffset(COIN, COIN),
				BackgroundColor3 = C.coinTails,
				Text = "",
				FontFace = F.display,
				TextSize = 15,
				TextColor3 = C.ink,
				LayoutOrder = i,
				ZIndex = Z,
				Parent = coinBar,
			}, { Kit.round() })
			local st = Kit.stroke(C.accentLo, 2, 0)
			st.Parent = coin
			table.insert(coins, { label = coin, stroke = st, broken = false })
		end
		-- the figure
		local figHolder = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, COIN + 16),
			Size = UDim2.new(1, 0, 0, STAGE_H - COIN - 66),
			ZIndex = Z,
			Parent = col,
		})
		local fig, pose = figure(ctx, figHolder, appearance, enemy, Z)
		local figScale = new("UIScale", { Parent = figHolder })
		-- when it's hit the figure itself flashes red (its viewport is tinted), and a cut is drawn across it
		local hitFlash = {
			flash = function(strength: number, time: number)
				for _, d in figHolder:GetDescendants() do
					if d:IsA("ViewportFrame") then
						d.ImageColor3 = Color3.new(1, 1 - 0.75 * strength, 1 - 0.75 * strength)
						Kit.tween(d, time, { ImageColor3 = Color3.new(1, 1, 1) })
					end
				end
			end,
		}
		local slash = new("Frame", { Name = "Slash", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 0, 0, 3), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Rotation = if right then -32 else 32, ZIndex = Z + 3, Parent = figHolder })
		-- name and statuses under them
		new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -24),
			Size = UDim2.new(1, 0, 0, 20),
			Text = string.upper(sideData.name or ""),
			FontFace = F.display,
			TextSize = 16,
			TextColor3 = C.text,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = Z + 1,
			Parent = col,
		})
		local strip = new("Frame", {
			Name = "Statuses",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -2),
			Size = UDim2.new(1, 0, 0, 20),
			ZIndex = Z + 1,
			Parent = col,
		}, { Kit.list(4, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center) })
		return { col = col, coins = coins, fig = fig, figHolder = figHolder, figScale = figScale, strip = strip, right = right, pose = pose, hitFlash = hitFlash, slash = slash }
	end

	local life = ctx.state and ctx.state.life
	local playerLook = life and (life.appearance or { look = life.look, age = life.age, form = life.form })
	local enemy = clash.enemy
	local foeLook = if enemy and enemy.kind ~= "creature" and enemy.look then { look = enemy.look, age = 30, form = "human" } else clash.foeAppearance
	local P = side(clash.player, false, playerLook, nil)
	local Fs = side(clash.foe, true, foeLook, enemy)
	P.col.Position -= UDim2.fromOffset(60, 0)
	Fs.col.Position += UDim2.fromOffset(60, 0)
	Kit.tween(P.col, 0.35, { Position = P.col.Position + UDim2.fromOffset(60, 0) }, Enum.EasingStyle.Quart)
	Kit.tween(Fs.col, 0.35, { Position = Fs.col.Position - UDim2.fromOffset(60, 0) }, Enum.EasingStyle.Quart)

	-- the middle: the two powers, and the round
	local mid = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(0.16, 0, 1, 0),
		ZIndex = Z + 1,
		Parent = stage,
	})
	new("Frame", {
		Name = "Plate",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, MID_Y),
		Size = if narrow then UDim2.fromOffset(60, 132) else UDim2.fromOffset(84, 150),
		ZIndex = Z + 1,
		Parent = mid,
	}, { Kit.corner(6) })
	local function powerLabel(y: number)
		local l = new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, y),
			Size = UDim2.new(1, 0, 0, 40),
			Text = "",
			FontFace = F.mono,
			TextSize = if narrow then 34 else 42,
			TextColor3 = C.text,
			ZIndex = Z + 2,
			Parent = mid,
		})
		return l, new("UIScale", { Parent = l })
	end
	local pPower, pScale = powerLabel(MID_Y - (if narrow then 36 else 42))
	local fPower, fScale = powerLabel(MID_Y + (if narrow then 36 else 42))
	local roundLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, MID_Y),
		Size = UDim2.new(1, 0, 0, 18),
		Text = "VS",
		FontFace = F.displayMed,
		TextSize = 13,
		TextColor3 = C.sub,
		ZIndex = Z + 2,
		Parent = mid,
	})
	-- the flash when the two sides meet
	local flash = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, MID_Y),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Rotation = 45,
		ZIndex = Z + 1,
		Parent = stage,
	})

	-- what each side brings: their style's status
	local function styleLine(sd)
		local st = sd.status
		if not st then
			return nil
		end
		local def = statusDef(ctx, st.id)
		return Format.color(string.upper(def.name) .. " x" .. st.potency, Theme.rgb(def.color))
	end
	local lines = {}
	local mine, theirs = styleLine(clash.player), styleLine(clash.foe)
	if mine then
		table.insert(lines, "You: " .. mine)
	end
	if theirs then
		table.insert(lines, "Them: " .. theirs)
	end
	if #lines > 0 then
		Kit.text({ Text = table.concat(lines, "     "), FontFace = F.displayMed, TextSize = 12, TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Center, LayoutOrder = 4, ZIndex = 4, Parent = card })
	end

	local resultHolder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 54), LayoutOrder = 11, ZIndex = 4, Parent = card })
	local calloutLayer = new("Folder", { Name = "Callouts", Parent = stage })
	local function callout(text: string, color: Color3, onPlayer: boolean)
		local label = new("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(if onPlayer then 0.24 else 0.76, 0, 0.42, 0),
			Size = UDim2.new(0.5, 0, 0, 36),
			Text = text,
			FontFace = F.display,
			TextSize = 26,
			TextColor3 = color,
			TextStrokeTransparency = 0.3,
			Rotation = math.random(-6, 6),
			ZIndex = Z + 4,
			Parent = calloutLayer,
		})
		local sc = new("UIScale", { Scale = 2, Parent = label })
		Kit.tween(sc, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
		task.delay(0.7 * speed, function()
			if label.Parent then
				Kit.tween(label, 0.3, { TextTransparency = 1, TextStrokeTransparency = 1, Position = label.Position - UDim2.fromOffset(0, 20) })
				task.delay(0.32, function()
					if label.Parent then
						label:Destroy()
					end
				end)
			end
		end)
	end
	local continueButton = Kit.button({
		text = "Continue",
		style = "primary",
		size = UDim2.new(1, 0, 0, 46),
		order = 12,
		zIndex = 4,
		textSize = 18,
		onClick = function()
			if not done then
				done = true
				continueEvent:Fire()
			end
		end,
	})
	continueButton.Visible = false
	continueButton.Parent = card
	Kit.raise(continueButton, 4)

	local function wait(t: number)
		task.wait(t * speed)
	end
	local function flipCoin(coin, heads: boolean)
		local label = coin.label
		Kit.tween(label, 0.07 * speed, { Size = UDim2.fromOffset(4, COIN) })
		wait(0.07)
		label.BackgroundColor3 = if heads then C.coinHeads else C.coinTails
		label.Text = if heads then "H" else ""
		Kit.tween(label, 0.09 * speed, { Size = UDim2.fromOffset(COIN, COIN) })
		if heads then
			sfx("coin", { volume = 0.6 })
		else
			sfx("tails", { volume = 0.5 })
		end
	end
	local function breakCoin(coins)
		for i = #coins, 1, -1 do
			local coin = coins[i]
			if not coin.broken then
				coin.broken = true
				coin.stroke.Color = C.crimsonHi
				Kit.tween(coin.label, 0.25 * speed, { BackgroundTransparency = 0.8 })
				coin.label.Text = "X"
				coin.label.TextColor3 = C.crimsonHi
				return
			end
		end
	end
	local function pop(s)
		s.Scale = 1.5
		Kit.tween(s, 0.25 * speed, { Scale = 1 }, Enum.EasingStyle.Back)
	end
	-- the winner lunges toward the middle; the loser is knocked back
	local function lunge(who, toward: number)
		local h = who.figHolder
		local base = h.Position
		-- a short wind-up the other way, then the strike
		Kit.tween(h, 0.05 * speed, { Position = base + UDim2.fromOffset(-toward * 8, 0) }, Enum.EasingStyle.Quad)
		if who.pose then
			who.pose("strike")
		end
		task.delay(0.05 * speed, function()
			if h.Parent then
				Kit.tween(h, 0.07 * speed, { Position = base + UDim2.fromOffset(toward * 40, 0) }, Enum.EasingStyle.Quad)
				Kit.tween(who.figScale, 0.07 * speed, { Scale = 1.08 })
			end
		end)
		task.delay(0.24 * speed, function()
			if h.Parent then
				Kit.tween(h, 0.2 * speed, { Position = base }, Enum.EasingStyle.Quad)
				Kit.tween(who.figScale, 0.2 * speed, { Scale = 1 })
				if who.pose then
					who.pose("idle")
				end
			end
		end)
	end
	local function reel(who, away: number)
		local h = who.figHolder
		local base = h.Position
		task.delay(0.1 * speed, function()
			if not h.Parent then
				return
			end
			if who.pose then
				who.pose("hurt")
			end
			Kit.tween(h, 0.07 * speed, { Position = base + UDim2.fromOffset(away * 22, 0), Rotation = away * 9 })
			Kit.shake(who.col, 6, 0.2 * speed)
			-- the hit lands: a flash, and a cut across the figure
			who.hitFlash.flash(0.8, 0.3 * speed)
			-- (v0.17) and an impact over it: a slash, sparks, a ring
			Vfx.impact(who.col, Vector2.new(0.5, 0.42), { color = if away > 0 then C.accentHi else C.crimsonHi })
			who.slash.Size = UDim2.new(0, 0, 0, 3)
			who.slash.BackgroundTransparency = 0
			Kit.tween(who.slash, 0.09 * speed, { Size = UDim2.new(1.3, 0, 0, 3) }, Enum.EasingStyle.Quad)
			task.delay(0.12 * speed, function()
				if who.slash.Parent then
					Kit.tween(who.slash, 0.2 * speed, { BackgroundTransparency = 1 })
				end
			end)
		end)
		task.delay(0.36 * speed, function()
			if h.Parent then
				Kit.tween(h, 0.2 * speed, { Position = base, Rotation = 0 })
				if who.pose then
					who.pose("idle")
				end
			end
		end)
	end
	local function spark(color: Color3)
		flash.BackgroundColor3 = color
		flash.Size = UDim2.fromOffset(8, 8)
		flash.BackgroundTransparency = 0
		Kit.tween(flash, 0.22 * speed, { Size = UDim2.fromOffset(90, 90), BackgroundTransparency = 1 })
	end
	local function paintStatuses(strip, statuses)
		for _, child in strip:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		for id, n in statuses or {} do
			local def = statusDef(ctx, id)
			local chip = Kit.chip(def.name .. " " .. n, Theme.rgb(def.color))
			chip.ZIndex = Z + 1
			chip.Parent = strip
		end
	end

	-- the opening line
	local barks = enemy and enemy.barks
	wait(0.3)
	local opener = pickLine(barks and barks.start)
	if opener then
		bubble(Fs.col, opener, true, Z + 3)
	end
	if not clash.boss then
		sfx("clash", { volume = 0.7 })
	end
	wait(0.55)

	local roundNo = 0
	for _, round in clash.rounds do
		-- THE FIRST STRIKE: the faster side attacks one-sided before the clashing starts. Only
		-- its coins flip; the other side has nothing to answer with.
		local oneSided = round.oneSided
		local i = roundNo
		if oneSided then
			roundLabel.Text = if oneSided == "player" then "FIRST STRIKE" else "THEY STRIKE FIRST"
			callout(if oneSided == "player" then "FASTER" else "TOO SLOW", if oneSided == "player" then C.good else C.crimsonHi, oneSided == "player")
		else
			roundNo += 1
			i = roundNo
			roundLabel.Text = "ROUND " .. i
		end
		local live = 0
		for _, coin in P.coins do
			if not coin.broken and oneSided ~= "foe" then
				live += 1
				task.spawn(flipCoin, coin, round.p[live] == true)
				wait(0.05)
			end
		end
		live = 0
		for _, coin in Fs.coins do
			if not coin.broken and oneSided ~= "player" then
				live += 1
				task.spawn(flipCoin, coin, round.f[live] == true)
				wait(0.05)
			end
		end
		wait(0.25)
		pPower.Text = tostring(round.pPower)
		fPower.Text = tostring(round.fPower)
		pop(pScale)
		pop(fScale)
		pPower.TextColor3 = if round.winner == "player" then C.good elseif round.winner == "foe" then C.crimsonHi else C.text
		fPower.TextColor3 = if round.winner == "foe" then C.good elseif round.winner == "player" then C.crimsonHi else C.text
		wait(0.15)
		if round.winner == "player" then
			spark(C.accentHi)
			lunge(P, 1)
			reel(Fs, 1)
			if not oneSided then
				breakCoin(Fs.coins)
			end
			sfx("parry")
			task.delay(0.12 * speed, function()
				sfx("hit", { volume = 0.7 })
			end)
		elseif round.winner == "foe" then
			spark(C.crimsonHi)
			lunge(Fs, -1)
			reel(P, -1)
			if not oneSided then
				breakCoin(P.coins)
			end
			sfx("hit")
			Kit.shake(card, 6, 0.2 * speed)
			if ctx.fx then
				ctx.fx.flash(C.crimson, 0.16)
			end
		elseif oneSided then
			-- the opening didn't land
			sfx("evade", { volume = 0.7 })
		else
			spark(Color3.new(1, 1, 1))
			roundLabel.Text = "ROUND " .. i .. " · CLASH"
			sfx("clash")
		end
		-- status effects: callouts and sounds
		for _, fx in round.fx or {} do
			local who, what = string.sub(fx, 1, 1), string.sub(fx, 2)
			if what == "offbalance" then
				-- down to a last coin, so the strike knocks them off balance instead
				callout("OFF BALANCE", C.accentHi, who ~= "p")
			end
			local c = CALLOUTS[what]
			if c then
				callout(c[1], Theme.rgb(statusDef(ctx, c[2]).color), who == "p")
				-- (v0.17) the status, on whoever it landed on
				Vfx.status((if who == "p" then Fs else P).col, Vector2.new(0.5, 0.45), c[2])
				if what == "burst" then
					reel(if who == "p" then Fs else P, if who == "p" then 1 else -1)
					sfx("tremorBurst")
					sfx("stagger", { volume = 0.7 })
					if ctx.fx then
						ctx.fx.flash(Theme.rgb(statusDef(ctx, "tremor").color), 0.15)
					end
				elseif what == "crit" then
					sfx("crit")
				elseif what == "burn" then
					sfx("burn", { volume = 0.7 })
				elseif what == "bleed" then
					sfx("slash", { volume = 0.7 })
				elseif what == "discharge" then
					sfx("blunt")
				elseif what == "crush" or what == "volley" then
					sfx("blunt")
				elseif what == "guard" or what == "reach" then
					sfx("evade", { volume = 0.6 })
				end
			end
		end
		paintStatuses(P.strip, round.pStatus)
		paintStatuses(Fs.strip, round.fStatus)
		local function sync(coins, left: number?)
			if not left then
				return
			end
			local alive = 0
			for _, coin in coins do
				if not coin.broken then
					alive += 1
				end
			end
			for _ = 1, alive - left do
				breakCoin(coins)
			end
		end
		sync(P.coins, round.pCoins)
		sync(Fs.coins, round.fCoins)
		wait(0.5)
	end

	-- the end: the loser goes down
	roundLabel.Text = "VS"
	local loser = if clash.won then Fs else P
	local winner = if clash.won then P else Fs
	-- the last blow: the winner steps in, the screen holds for a beat, the loser goes down
	Kit.tween(winner.figHolder, 0.1, { Position = winner.figHolder.Position + UDim2.fromOffset(if winner.right then -30 else 30, 0) }, Enum.EasingStyle.Quad)
	loser.hitFlash.flash(1, 0.6)
	Vfx.impact(loser.col, Vector2.new(0.5, 0.42), { heavy = true, color = if clash.won then C.accentHi else C.crimsonHi })
	if clash.won then
		Vfx.confetti(card, C.accentHi)
	end
	loser.slash.Size = UDim2.new(0, 0, 0, 4)
	loser.slash.BackgroundTransparency = 0
	Kit.tween(loser.slash, 0.1, { Size = UDim2.new(1.6, 0, 0, 4) }, Enum.EasingStyle.Quad)
	Kit.tween(loser.slash, 0.5, { BackgroundTransparency = 1 })
	wait(0.12)
	if loser.pose then
		-- a creature has its own way of going down
		loser.pose("down")
		Kit.tween(loser.figHolder, 0.4, { Position = loser.figHolder.Position + UDim2.fromOffset(if loser.right then 14 else -14, 10) }, Enum.EasingStyle.Quad)
	else
		-- a person staggers back, then drops
		Kit.tween(loser.figHolder, 0.14, { Rotation = if loser.right then 14 else -14, Position = loser.figHolder.Position + UDim2.fromOffset(if loser.right then 12 else -12, 0) }, Enum.EasingStyle.Quad)
		wait(0.16)
		Kit.tween(loser.figHolder, 0.4, { Rotation = if loser.right then 86 else -86, Position = loser.figHolder.Position + UDim2.fromOffset(if loser.right then 10 else -10, 46) }, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	end
	Kit.tween(loser.figScale, 0.4, { Scale = 0.92 })
	if clash.won then
		Kit.stamp(resultHolder, "Won", C.good, { Position = UDim2.fromScale(0.5, 0.5), TextSize = 34, Rotation = -6 })
		sfx("clashWin")
		local line = pickLine(barks and barks.lose)
		if line then
			bubble(Fs.col, line, true, Z + 3)
		end
	else
		Kit.stamp(resultHolder, "Lost", C.crimsonHi, { Position = UDim2.fromScale(0.5, 0.5), TextSize = 34, Rotation = 5 })
		Kit.shake(card, 8, 0.25)
		sfx("defeat")
		local line = pickLine(barks and barks.win)
		if line then
			bubble(Fs.col, line, true, Z + 3)
		end
	end
	continueButton.Visible = true
	speed = 1

	continueEvent.Event:Wait()
	continueEvent:Destroy()
	scrim:Destroy()
	card:Destroy()
end

-- A QUICK CHECK: not a fight, so no full screen. A card: which stat was tested and against
-- what, your coins and theirs landing, the two totals, and a band across the bottom that
-- says how it went. About two seconds; a tap ends it sooner.
function ClashView.check(ctx, layer: Instance, clash)
	local statDef = clash.stat and ctx.info.stats.defs[clash.stat]
	local statName = if statDef then statDef.name else "Check"
	local color = if statDef and statDef.color then Theme.rgb(statDef.color) else C.accent
	local closed = Instance.new("BindableEvent")
	local isClosed = false
	local Z = 4
	local scrim = Kit.scrim(layer, Z - 1)
	Kit.tween(scrim, 0.15, { BackgroundTransparency = 0.5 })
	local card = Kit.panel({
		Name = "Check",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.new(1, -32, 0, 214),
		AutomaticSize = Enum.AutomaticSize.None,
		ClipsDescendants = true,
		ZIndex = Z,
		Parent = layer,
	}, { new("UISizeConstraint", { MaxSize = Vector2.new(440, 214) }) }, color)

	-- the head: the stat's mark on a tile of its color, what was tested, against what
	local head = new("Frame", { Name = "Head", BackgroundColor3 = color, BackgroundTransparency = 0.86, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 52), ZIndex = Z, Parent = card })
	local tile = new("Frame", { BackgroundColor3 = color, BackgroundTransparency = 0.7, BorderSizePixel = 0, Position = UDim2.fromOffset(12, 10), Size = UDim2.fromOffset(32, 32), ZIndex = Z, Parent = head }, { Kit.corner(6), Kit.stroke(color, 1, 0.3) })
	local icon = Emblem.make("stat." .. tostring(clash.stat or ""), 20, color:Lerp(Color3.new(1, 1, 1), 0.4))
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.ZIndex = Z + 1
	icon.Parent = tile
	Kit.caps({ Text = statName .. " check", FontFace = F.display, TextSize = 19, TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.3), Position = UDim2.fromOffset(54, 8), Size = UDim2.new(1, -66, 0, 22), ZIndex = Z, Parent = head })
	Kit.caps({ Text = "against " .. tostring(clash.foe and clash.foe.name or "the odds"), FontFace = F.displayMed, TextSize = 12, TextColor3 = C.sub, Position = UDim2.fromOffset(54, 30), Size = UDim2.new(1, -66, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = Z, Parent = head })

	-- the two sides: coins over a total
	local function side(right: boolean, label: string)
		local col = new("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(if right then 1 else 0, 0),
			Position = UDim2.new(if right then 1 else 0, if right then -14 else 14, 0, 60),
			Size = UDim2.new(0.5, -40, 0, 100),
			ZIndex = Z,
			Parent = card,
		})
		Kit.caps({ Text = label, FontFace = F.displayMed, TextSize = 11, TextColor3 = C.faint, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 14), ZIndex = Z, Parent = col })
		local coins = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 30), ZIndex = Z, Parent = col }, {
			Kit.list(5, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center),
		})
		local power = new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 52),
			Size = UDim2.new(1, 0, 0, 40),
			Text = "",
			FontFace = F.mono,
			TextSize = 36,
			TextColor3 = C.text,
			ZIndex = Z,
			Parent = col,
		})
		return coins, power
	end
	local pCoins, pPower = side(false, "You")
	local fCoins, fPower = side(true, "Against")
	new("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 116), Size = UDim2.fromOffset(60, 30), Text = "VS", FontFace = F.display, TextSize = 14, TextColor3 = C.faint, ZIndex = Z, Parent = card })

	-- the band: how it went
	local band = new("Frame", { Name = "Band", BackgroundColor3 = C.panelLo, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 44), ZIndex = Z, Parent = card })
	local result = new("TextLabel", { Name = "Result", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", FontFace = F.display, TextSize = 24, TextColor3 = C.text, ZIndex = Z + 1, Parent = band })

	local sc = new("UIScale", { Scale = 0.92, Parent = card })
	Kit.tween(sc, 0.2, { Scale = 1 }, Enum.EasingStyle.Back)
	local tap = new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = Z + 3, Parent = card })
	local function close()
		if isClosed then
			return
		end
		isClosed = true
		-- it goes as one piece: nothing is left hanging over the feed
		Kit.tween(sc, 0.12, { Scale = 0.94 })
		Kit.tween(scrim, 0.12, { BackgroundTransparency = 1 })
		task.delay(0.12, function()
			card:Destroy()
			scrim:Destroy()
			closed:Fire()
		end)
	end
	tap.Activated:Connect(close)
	scrim.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			close()
		end
	end)

	local function coin(parent: Instance, heads: boolean, order: number)
		local c = new("TextLabel", {
			Size = UDim2.fromOffset(26, 26),
			BackgroundColor3 = if heads then C.coinHeads else C.coinTails,
			Text = if heads then "H" else "",
			FontFace = F.display,
			TextSize = 12,
			TextColor3 = C.ink,
			LayoutOrder = order,
			ZIndex = Z,
			Parent = parent,
		}, { Kit.round(), Kit.stroke(if heads then C.accentHi else C.strokeHi, 2, 0) })
		local csc = new("UIScale", { Scale = 0.2, Parent = c })
		Kit.tween(csc, 0.16, { Scale = 1 }, Enum.EasingStyle.Back)
	end

	task.spawn(function()
		-- the round that decided it: the coins land one at a time, then the totals
		local last = clash.rounds and clash.rounds[#clash.rounds]
		local pFlips: { boolean } = (last and last.p) or {}
		local fFlips: { boolean } = (last and last.f) or {}
		for i = 1, math.max(#pFlips, #fFlips) do
			if isClosed then
				return
			end
			if pFlips[i] ~= nil then
				coin(pCoins, pFlips[i], i)
			end
			if fFlips[i] ~= nil then
				coin(fCoins, fFlips[i], i)
			end
			ctx.sound("coin")
			task.wait(0.1)
		end
		if isClosed then
			return
		end
		task.wait(0.12)
		pPower.Text = if last and last.pPower then tostring(last.pPower) else ""
		fPower.Text = if last and last.fPower then tostring(last.fPower) else ""
		local won = clash.won == true
		pPower.TextColor3 = if won then C.good else C.sub
		fPower.TextColor3 = if won then C.sub else C.crimsonHi
		task.wait(0.22)
		if isClosed then
			return
		end
		local tone = if won then C.good else C.crimsonHi
		band.BackgroundColor3 = tone
		band.BackgroundTransparency = 0.78
		new("Frame", { BackgroundColor3 = tone, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), ZIndex = Z + 1, Parent = band })
		result.Text = if won then "SUCCESS" else "FAILED"
		result.TextColor3 = tone:Lerp(Color3.new(1, 1, 1), 0.25)
		local rsc = new("UIScale", { Scale = 1.5, Parent = result })
		Kit.tween(rsc, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
		ctx.sound(if won then "win" else "lose")
		task.wait(1.25)
		close()
	end)
	closed.Event:Wait()
	closed:Destroy()
end

return ClashView
