--[[
	Client app: builds the UI layers, talks to the server, routes screens.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local SocialService = game:GetService("SocialService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local UI = script.Parent:WaitForChild("UI")
local Theme = require(UI:WaitForChild("Theme"))
local Kit = require(UI:WaitForChild("Kit"))
local Hud = require(UI:WaitForChild("Hud"))
local EventCard = require(UI:WaitForChild("EventCard"))
local ClashView = require(UI:WaitForChild("ClashView"))
local BattleView = require(UI:WaitForChild("BattleView"))
local DuelView = require(UI:WaitForChild("DuelView"))
local Sheets = require(UI:WaitForChild("Sheets"))
local Screens = require(UI:WaitForChild("Screens"))
local Prompt = require(UI:WaitForChild("Prompt"))
local Social = require(UI:WaitForChild("Social"))
local Celebrate = require(UI:WaitForChild("Celebrate"))
local Layout = require(UI:WaitForChild("Layout"))
local Format = require(UI:WaitForChild("Format"))
local SidePanel = require(UI:WaitForChild("SidePanel"))
local SurnameRoll = require(UI:WaitForChild("SurnameRoll"))
local Settings = require(UI:WaitForChild("Settings"))
local AdminMenu = require(UI:WaitForChild("AdminMenu"))
local Intro = require(UI:WaitForChild("Intro"))
-- (BitLeveling) the title screen and main menu, when the game's live city is on
local okTitle, TitleMenu = pcall(function()
	return require(UI:WaitForChild("TitleMenu", 2))
end)
local QuickStart = require(UI:WaitForChild("QuickStart"))
local Lobby = require(UI:WaitForChild("Lobby"))
local Guide = require(UI:WaitForChild("Guide"))
local BirthReveal = require(UI:WaitForChild("BirthReveal"))
local Cutscene = require(UI:WaitForChild("Cutscene"))
local Stage = require(UI:WaitForChild("Stage"))
local Fx3D = require(UI:WaitForChild("Fx3D"))
local World3D = require(UI:WaitForChild("World3D"))
local Tip = require(UI:WaitForChild("Tip"))
local OfficeSheet = require(UI:WaitForChild("OfficeSheet"))
-- (v0.19) the party and the people in your life (BitLeveling: Engine/Party, server/HunterParty)
local PartySheet = require(UI:WaitForChild("PartySheet"))
local NpcProfile = require(UI:WaitForChild("NpcProfile"))
local DeathScene = require(UI:WaitForChild("DeathScene"))
local ChapterCard = require(UI:WaitForChild("ChapterCard"))
local Tutorial = require(UI:WaitForChild("Tutorial"))
local BackdropMere = require(script.Parent:WaitForChild("Backdrop"))
local BackdropCity = require(script.Parent:WaitForChild("BackdropCity"))
local Music = require(script.Parent:WaitForChild("Music"))
local Sfx = require(script.Parent:WaitForChild("Sfx"))

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local App = {}
local started = false

local function layerGui(playerGui: Instance, name: string, order: number, shifted: boolean?)
	local gui: ScreenGui = new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = order,
		Parent = playerGui,
	})
	local column = new("Frame", {
		Name = "Column",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = gui,
	})
	column:SetAttribute("Column", true)
	local scale = new("UIScale", { Parent = column })
	local function fit()
		local abs = gui.AbsoluteSize
		if abs.X <= 0 or abs.Y <= 0 then
			return
		end
		-- fit the screen (a wide one is filled edge to edge), with the player's size setting
		local s = Layout.scaleFor(abs)
		scale.Scale = s
		-- the life column is as wide as the middle panel when the screen has three
		local full = shifted and Layout.mainWidth ~= nil
		local roomy = abs.X / s >= 1100 -- a wide canvas: cards and sheets get more room to read in
		local w = math.min(if full then Layout.mainWidth :: number elseif roomy then 660 else Theme.sizes.columnWidth, abs.X / s - 16)
		local h = abs.Y / s - (if full then 2 * Layout.MARGIN else 16)
		column.Size = UDim2.fromOffset(w, h)
		-- the life column steps left on a wide screen so it and the hub sit centered together
		column.Position = UDim2.new(0.5, if shifted then Layout.mainShift * s else 0, 0.5, 0)
	end
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	Layout.changed:Connect(fit)
	fit()
	return gui, column
end

function App.start()
	if started then
		return
	end
	started = true

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

	pcall(function()
		playerGui.ScreenOrientation = Enum.ScreenOrientation.Portrait
	end)
	for _, coreType in { Enum.CoreGuiType.Backpack, Enum.CoreGuiType.Health, Enum.CoreGuiType.EmotesMenu } do
		pcall(function()
			StarterGui:SetCoreGuiEnabled(coreType, false)
		end)
	end

	local Shared = ReplicatedStorage:WaitForChild("LifeSim")
	local Config = require(Shared:WaitForChild("Config"))
	local Remotes = Shared:WaitForChild("Remotes")
	local Request = Remotes:WaitForChild("Request") :: RemoteFunction
	local Push = Remotes:WaitForChild("Push") :: RemoteEvent
	Music.start(Config.music)
	Sfx.start(Config.sfx)
	Sfx.setDucker(Music.duck) -- (v0.18) big moments dip the music under them

	-- background: soft vignette so the column reads over the city
	local back = new("ScreenGui", {
		Name = "LifeSimBack",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1,
		Parent = playerGui,
	})
	local shade = new("Frame", {
		BackgroundColor3 = C.shade,
		BackgroundTransparency = if Config.backdrop then 0.25 else 0,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = back,
	})
	new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.3, 0.75),
			NumberSequenceKeypoint.new(0.7, 0.75),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
		Parent = shade,
	})
	-- the City pack gets its own skyline (built once the districts are known, after hello)
	-- (blueprint) which backdrop is the game's own choice (pack.backdrop: "city", "crater" or
	-- "none", sent with hello); the old packs default to theirs
	local NO_BACKDROP = { build = function() end, setArea = function() end, cinematic = function() end }
	local cityBackdrop = Config.pack == nil or Config.pack == "City"
	local Backdrop: any = if cityBackdrop then BackdropCity else BackdropMere

	local _, mainColumn = layerGui(playerGui, "LifeSimMain", 5, true)
	-- the side panels (lore, the city, you): docked on wide screens, a drawer on phones
	local sideGui = new("ScreenGui", {
		Name = "LifeSimSide",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 6,
		Parent = playerGui,
	})
	local _, sheetColumn = layerGui(playerGui, "LifeSimSheets", 7)
	local _, modalColumn = layerGui(playerGui, "LifeSimModal", 8)
	local _, clashColumn = layerGui(playerGui, "LifeSimClash", 9)
	local cinemaGui = new("ScreenGui", {
		Name = "LifeSimCinema",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 30,
		Parent = playerGui,
	})
	local _, toastColumn = layerGui(playerGui, "LifeSimToast", 10)
	-- (v0.19) the PARTY screen and people's profiles: whole-screen, over the sheets, under fights
	local partyGui = new("ScreenGui", {
		Name = "LifeSimParty",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 8,
		Parent = playerGui,
	})
	local tutorialGui = new("ScreenGui", {
		Name = "LifeSimTutorial",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 15,
		Parent = playerGui,
	})
	local introGui = new("ScreenGui", {
		Name = "LifeSimIntro",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 20,
		Parent = playerGui,
	})

	-- hover and tap explanations are drawn over everything but the intro
	Tip.setLayer(tutorialGui)

	-- full-screen effects: damage flash and sanity static
	local fxGui = new("ScreenGui", {
		Name = "LifeSimFX",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 11,
		Parent = playerGui,
	})
	local flashFrame = new("Frame", {
		BackgroundColor3 = C.crimson,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = fxGui,
	})
	local fx = {}
	function fx.flash(color: Color3, intensity: number)
		if not Kit.effects then
			return
		end
		flashFrame.BackgroundColor3 = color
		flashFrame.BackgroundTransparency = 1 - math.clamp(intensity, 0.05, 0.6)
		Kit.tween(flashFrame, 0.45, { BackgroundTransparency = 1 })
	end
	function fx.static(amount: number)
		if not Kit.effects then
			return
		end
		local bars = math.floor(4 + amount * 8)
		for _ = 1, bars do
			local bar = new("Frame", {
				BackgroundColor3 = if math.random() < 0.5 then C.text else C.strange,
				BackgroundTransparency = 0.55 + math.random() * 0.35,
				BorderSizePixel = 0,
				Position = UDim2.new(math.random() * 0.3 - 0.1, 0, math.random(), 0),
				Size = UDim2.new(0.6 + math.random() * 0.6, 0, 0, math.random(2, 7)),
				Parent = fxGui,
			})
			task.delay(0.05 + math.random() * 0.25, function()
				bar:Destroy()
			end)
		end
	end

	-- sound effects (Config.sfx); a few older names map onto the new set
	local SOUND_ALIAS = { ageUp = "confirm", win = "clashWin", lose = "defeat" }
	local function sound(name: string)
		Sfx.play(SOUND_ALIAS[name] or name)
	end

	-- toast
	local toastBox = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = toastColumn,
	}, { Kit.list(6, nil, Enum.HorizontalAlignment.Center) })
	local function toast(text: string)
		text = string.upper(text)
		local t = new("TextLabel", {
			BackgroundColor3 = C.panelHi,
			Size = UDim2.new(0, 0, 0, 36),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = text,
			FontFace = F.uiMedium,
			TextSize = 14,
			TextColor3 = C.text,
			Parent = toastBox,
		}, { Kit.corner(2), Kit.padding(0, 16, 0, 16), Kit.stroke(C.accent, 1, 0.3) })
		task.delay(2.4, function()
			Kit.tween(t, 0.3, { BackgroundTransparency = 1, TextTransparency = 1 })
			task.wait(0.3)
			t:Destroy()
		end)
	end

	local state = { info = nil, meta = nil, life = nil, busy = false, world = nil, crew = nil }
	local ctx = { state = state, info = nil, actions = {}, sound = sound, toast = toast, fx = fx }
	ctx.prompt = function(opts)
		return Prompt.show(modalColumn, opts)
	end
	App.ctx = ctx -- exposed for tests and for your own add-on scripts

	local loading = Screens.loading(ctx, mainColumn)
	loading.frame.Visible = true

	local function call(action: string, payload: any?)
		if state.busy then
			return nil
		end
		state.busy = true
		if ctx.hud then
			ctx.hud:setBusy(true)
		end
		local ok, res = pcall(function()
			return Request:InvokeServer(action, payload)
		end)
		state.busy = false
		if ctx.hud then
			ctx.hud:setBusy(false)
		end
		if not ok or type(res) ~= "table" then
			toast("Lost the thread. Try again.")
			return nil
		end
		state.lastError = nil
		if not res.ok then
			state.lastError = res.error
			toast(res.error or "That didn't work.")
			return nil
		end
		return res
	end

	-- first contact (retry while the save loads)
	local hello = nil
	for _ = 1, 30 do
		local ok, res = pcall(function()
			return Request:InvokeServer("hello")
		end)
		if ok and type(res) == "table" and res.ok then
			hello = res
			break
		end
		loading.setStatus(if ok and type(res) == "table" and res.error then res.error else "Waiting for the server...")
		task.wait(2)
	end
	if not hello then
		loading.setStatus("Couldn't reach the server. Please rejoin.")
		return
	end

	state.info = hello.info
	ctx.info = hello.info
	state.meta = hello.meta
	state.talent = hello.talent
	-- (blueprint) the game's look: its colors, its places to fight, its effects, its backdrop
	pcall(Theme.apply, hello.info.theme)
	pcall(Stage.usePlaces, hello.info.places)
	-- (blueprint) the 2D banner of a card set in one of the game's places draws that place's scene
	pcall(function()
		local SceneArt = require(script.Parent:WaitForChild("SceneArt")) :: any
		SceneArt.alias = SceneArt.alias or {}
		for _, place in hello.info.places or {} do
			if type(place) == "table" and type(place.id) == "string" then
				SceneArt.alias[place.id] = if type(place.scene) == "string" then place.scene else "street"
			end
		end
	end)
	pcall(function()
		require(UI:WaitForChild("Fx3D")).useVfx(hello.info.vfx)
	end)
	local backdropStyle = hello.info.backdrop or (if cityBackdrop then "city" else "crater")
	Backdrop = if backdropStyle == "city" then BackdropCity elseif backdropStyle == "crater" then BackdropMere else NO_BACKDROP
	if Config.backdrop and backdropStyle ~= "none" then
		task.spawn(function()
			local ok, err
			if backdropStyle == "city" then
				ok, err = pcall(BackdropCity.build, hello.info.city and hello.info.city.districts)
			else
				ok, err = pcall(BackdropMere.build)
			end
			if not ok then
				warn("[LifeSim] backdrop failed: " .. tostring(err))
			end
		end)
	end
	loading.setTitle(hello.info.meta.title)

	local hud = Hud.build(ctx, mainColumn)
	ctx.hud = hud
	-- (v0.19) PARTY on the life screen, beside this year's DO and PEOPLE: who's with you (a pack
	-- with a party only: the life's view has `party`)
	do
		local pill = new("TextButton", {
			Name = "Party",
			AutoButtonColor = true,
			BackgroundColor3 = Color3.fromRGB(14, 24, 52),
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "PARTY",
			RichText = true,
			FontFace = F.display,
			TextSize = 12,
			TextColor3 = Color3.fromRGB(150, 206, 255),
			LayoutOrder = 3,
			Visible = false,
			Parent = hud.yearStrip,
		}, {
			Kit.corner(3),
			Kit.stroke(Color3.fromRGB(84, 170, 255), 1, 0.2),
			Kit.padding(0, 10, 0, 10),
		})
		Tip.attach(pill, "PARTY", "Up to four people who follow you into the Gates. Ask anyone you know: they say yes or no.")
		pill.Activated:Connect(function()
			local acts: any = ctx.actions
			if acts.openParty then
				acts.openParty()
			end
		end)
		ctx.partyPill = pill
		local baseSetLife = hud.setLife
		hud.setLife = function(self: any, life: any)
			baseSetLife(self, life)
			local sum = life and life.party
			pill.Visible = sum ~= nil and life.alive == true and (life.age or 0) >= 16
			if sum then
				pill.Text = string.format("PARTY %d/%d", sum.count or 0, sum.max or 4) .. (if (sum.hurt or 0) > 0 then string.format("  <font color=\"#FFBE5A\">%d HURT</font>", sum.hurt) else "")
			end
			if PartySheet.isOpen() and life and not life.alive then
				PartySheet.close()
			end
		end
	end
	state.world = hello.world
	state.crew = hello.crew
	state.isAdmin = hello.isAdmin == true
	state.surnames = hello.surnames
	hud.setWorld(state.world)

	-- settings apply right away and again whenever they change
	local function applySettings(settings)
		settings = settings or {}
		local on = settings.music ~= false
		Music.setEnabled(on)
		Music.setVolume(settings.musicVolume or 0.6)
		hud:setMusicLabel(on)
		Sfx.setVolume(settings.sfxVolume or 0.8)
		Kit.effects = settings.effects ~= false
		Fx3D.setQuality(settings.vfx)
		Layout.setPref(settings.uiScale or "auto")
	end
	applySettings(hello.meta and hello.meta.settings)

	-- the side panels
	ctx.sheetLayer = sheetColumn
	ctx.cinemaLayer = cinemaGui -- (v0.14) full-screen cutscenes (UI/Stage.luau)
	local side = SidePanel.build(ctx, sideGui)
	-- on a wide screen the hub carries the tabs and the activities; the HUD slims down
	local onLifeScreen = false
	local function applyShift()
		if onLifeScreen and side.wide then
			Layout.setMain(side.shift or 0, side.mainWidth, side.leftWidth)
		else
			Layout.setMain(0, nil, nil)
		end
	end
	side.onWideChanged = function(wide: boolean)
		hud:setWide(wide, side.leftWidth)
		applyShift()
	end
	hud:setWide(side.wide, side.leftWidth)
	ctx.side = side
	side:setMeta(state.meta)
	side:setSurnames(state.surnames)
	side:setChronicle(hello.chronicle or {})
	side:setHolds(hello.holds or {})
	side:setDaily(hello.dailyEvent)
	side:setWorld(state.world)

	ctx.celebrate = function(title: string, sub: string?, color: Color3?)
		Celebrate.banner(ctx, toastColumn, { title = title, sub = sub, color = color or C.accentHi })
	end
	-- UI modules play sound effects through ctx.sfx("parry") (Config.sfx)
	ctx.sfx = function(name: string, opts: any?)
		Sfx.play(name, opts)
	end
	ctx.music = function(place: string)
		local places = Config.music and Config.music.places
		if places and places[place] then
			Music.setMood(places[place])
		end
	end

	-- city news goes into the chat as a system message
	local NEWS_COLORS = { news = "#E0B050", good = "#7AC28C", admin = "#E2564C", accent = "#EDC472", danger = "#E2564C", strange = "#60BAB2" }

	-- chat tags: each player's title in their current life ("[Grade 7 Fixer]"), set by the
	-- server from game data. Config.chatTags = false turns them off (or if your place sets
	-- its own OnIncomingMessage).
	if Config.chatTags ~= false then
		pcall(function()
			TextChatService.OnIncomingMessage = function(message: TextChatMessage)
				local props = Instance.new("TextChatMessageProperties")
				local source = message.TextSource
				local speaker = source and Players:GetPlayerByUserId(source.UserId)
				local tag = speaker and speaker:GetAttribute("LifeSimTag")
				if type(tag) == "string" and tag ~= "" then
					props.PrefixText = string.format('<font color="#CFA349">[%s]</font> %s', Format.escape(tag), message.PrefixText)
				end
				return props
			end
		end)
	end
	local function chatNews(text: string, tone: string?)
		if Config.chatNews == false then
			return
		end
		local color = NEWS_COLORS[tone or "news"] or NEWS_COLORS.news
		local line = string.format('<font color="%s"><b>[CITY]</b></font> %s', color, Format.escape(text))
		local ok = pcall(function()
			local channels = TextChatService:FindFirstChild("TextChannels")
			local general = channels and channels:FindFirstChild("RBXGeneral")
			if not general then
				error("no chat channel")
			end
			(general :: any):DisplaySystemMessage(line)
		end)
		if not ok then
			pcall(function()
				StarterGui:SetCore("ChatMakeSystemMessage", { Text = "[City] " .. text, Color = Color3.fromRGB(224, 176, 80) })
			end)
		end
	end

	-- gamepads: B closes the top sheet; new sheets take the selection
	ContextActionService:BindAction("LifeSimBack", function(_, inputState)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		local top = Sheets.stack[#Sheets.stack]
		if top then
			top()
			return Enum.ContextActionResult.Sink
		end
		if side.drawer and side.drawer.isOpen then
			side:closeDrawer()
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.ButtonB)
	Sheets.focus = function(panel: Instance)
		if not UserInputService.GamepadEnabled then
			return
		end
		for _, d in panel:GetDescendants() do
			if d:IsA("GuiButton") and d.Visible and d.Name ~= "Button" then
				pcall(function()
					GuiService.SelectedObject = d
				end)
				return
			end
		end
	end
	local newLifeScreen = Screens.newLife(ctx, mainColumn, sheetColumn)
	local quickScreen = QuickStart.new(ctx, mainColumn)
	local deathScreen = Screens.death(ctx, mainColumn)
	local menuHolder = new("Frame", {
		Name = "Menu",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = mainColumn,
	})
	-- the lobby (starting lives together): a whole screen, laid out like the menu
	local lobbyHolder = new("Frame", {
		Name = "LobbyScreen",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = mainColumn,
	})
	-- The side panels are hidden on the menu, so on a wide screen it spreads across the whole
	-- canvas (logical px, the same canvas Layout.panels lays the life screen out on).
	local menuShape = ""
	local function menuGui(): any
		local p = mainColumn.Parent
		while p and not p:IsA("ScreenGui") do
			p = p.Parent
		end
		return p
	end
	local function sizeMenu(): (boolean, number)
		local gui = menuGui()
		local abs = if gui then gui.AbsoluteSize else Vector2.zero
		if abs.X <= 0 or abs.Y <= 0 then
			menuHolder.Size = UDim2.fromScale(1, 1)
			lobbyHolder.Size = menuHolder.Size
			menuShape = "column"
			return false, 0
		end
		local s = Layout.scaleFor(abs)
		local w, h = abs.X / s, abs.Y / s
		-- (two columns need something for the second one: a pack without game modes keeps the
		-- single column)
		local info = ctx.info or {}
		local wide = w >= 1100 and #(info.modes or {}) > 0
		menuHolder.Size = if wide then UDim2.new(0, math.min(w - 72, 1240), 1, 0) else UDim2.fromScale(1, 1)
		lobbyHolder.Size = menuHolder.Size
		menuShape = if wide then string.format("wide %d", math.floor(h / 40)) else "column"
		return wide, h - 16
	end

	local screens = {
		loading = loading.frame,
		hud = hud.root,
		newLife = newLifeScreen.frame,
		quick = quickScreen.frame,
		death = deathScreen.frame,
		menu = menuHolder,
		lobby = lobbyHolder,
	}
	local currentScreen = "loading"
	local function districtInfo(id: string?)
		for _, d in (state.info and state.info.city and state.info.city.districts) or {} do
			if d.id == id then
				return d
			end
		end
		return nil
	end
	local function runPending()
		local life = state.life
		if life and life.run and life.run.stage then
			return life.run, false
		end
		local crew = state.crew
		if crew and crew.run and crew.run.stage then
			return crew.run, true
		end
		return nil, false
	end
	local function runKind(): string?
		local run = runPending()
		return run and run.kind
	end

	-- music and the backdrop follow where you are and what's going on
	local function updateScene()
		local mcfg = Config.music
		local life = state.life
		if mcfg then
			local places = mcfg.places or {}
			local mood = nil
			if currentScreen == "death" then
				mood = places.death
			elseif currentScreen ~= "hud" then
				mood = places.menu
			elseif life then
				local kind = runKind()
				local d = life.district and districtInfo(life.district.id)
				if kind then
					mood = places[kind] or places.mission
				elseif state.world and mcfg.worldEvents and mcfg.worldEvents[state.world.id] then
					mood = mcfg.worldEvents[state.world.id]
				elseif state.world and mcfg.worldEventTones and mcfg.worldEventTones[state.world.tone or ""] then
					-- a world event with no mood of its own plays by its tone
					mood = mcfg.worldEventTones[state.world.tone or ""]
				elseif d and d.music then
					mood = d.music
				elseif life.age < 13 then
					mood = places.childhood
				elseif life.side and life.side.rich then
					mood = places.charter
				else
					mood = places.gutters
				end
			end
			if currentScreen == "death" then
				Music.cut(mood)
			else
				Music.setMood(mood)
			end
		end
		if life and life.district then
			local d = districtInfo(life.district.id)
			local index = 1
			for i, dd in (state.info and state.info.city and state.info.city.districts) or {} do
				if dd.id == life.district.id then
					index = i
				end
			end
			pcall(Backdrop.setArea, {
				district = life.district.id,
				index = index,
				side = if life.side and life.side.rich then "charter" else "gutters",
				world = state.world and state.world.id,
				run = runKind(),
				custom = d and d.backdrop,
			})
		end
	end

	local function showScreen(name: string)
		for key, frame in screens do
			frame.Visible = key == name
		end
		if name ~= "loading" then
			loading.stop()
		end
		-- (v0.18) a life that ends is the whole screen: no drawer or sheet left over it, so the
		-- way back to the menu is the first thing you see (on a phone the drawer covered it)
		if name == "death" and currentScreen ~= "death" then
			pcall(function()
				side:closeDrawer()
			end)
			for _ = 1, 8 do
				local top = Sheets.stack[#Sheets.stack]
				if not top then
					break
				end
				top()
			end
		end
		currentScreen = name
		-- the side panels belong to the life screen (and the death screen's look back)
		side:setVisible(name == "hud" or name == "death")
		onLifeScreen = name == "hud" or name == "death"
		applyShift()
		updateScene()
	end

	-- big moments: a stamped banner, sparks and a burst of hero music
	local CELEBRATIONS = {
		ambition = { title = "Ambition met", color = C.accentHi },
		expedition = { title = "Expedition complete", color = C.strange },
		purchase = { title = "Unlocked", color = Color3.fromRGB(255, 214, 120) },
		quest = { title = "Quest", color = C.strange },
	}
	local function moment()
		-- celebrations keep the music as it is (it used to switch to a hero track); a sound instead
		Sfx.play("confirm")
	end
	local function celebrate(entries)
		for _, e in entries or {} do
			local c = e.celebrate and CELEBRATIONS[e.celebrate]
			if c then
				Celebrate.banner(ctx, toastColumn, { title = c.title, sub = e.text, color = c.color })
				moment()
			elseif e.kind == "gift" then
				Celebrate.banner(ctx, toastColumn, { title = e.title or "Your gift wakes", sub = e.text, color = if e.color then Theme.rgb(e.color) else C.strange, hold = 3.4 })
				moment()
			elseif e.kind == "renown" then
				Celebrate.banner(ctx, toastColumn, { title = e.title or "Renown", sub = e.text, color = if e.color then Theme.rgb(e.color) else C.accentHi, hold = 3.2 })
				moment()
			elseif e.kind == "feat" then
				-- (v0.13) a feat: its tier's color, held a little longer the rarer it is
				local tierWord = if e.tier then string.upper(string.sub(e.tier, 1, 1)) .. string.sub(e.tier, 2) else "Feat"
				Celebrate.banner(ctx, toastColumn, { title = tierWord .. " feat: " .. (e.title or ""), sub = e.text, color = if e.color then Theme.rgb(e.color) else C.accentHi, hold = if e.tier == "mythic" then 4.5 elseif e.tier == "gold" then 3.8 else 3 })
				moment()
			elseif e.kind == "phase" then
				-- (v0.14) a new part of life gets a scene of its own: out on a roof at dusk
				if Stage.enabled(ctx, "full") and not state.cinema then
					state.cinema = true
					Stage.moment(ctx, cinemaGui, { title = e.title, kicker = "A new part of life", line = e.text, color = e.color })
					state.cinema = false
				else
					Celebrate.banner(ctx, toastColumn, { title = e.title or "A new part of life", sub = e.text, color = if e.color then Theme.rgb(e.color) else C.strange, hold = 3.6 })
				end
				moment()
			elseif e.kind == "episodeEnd" then
				Celebrate.banner(ctx, toastColumn, { title = "Episode: " .. (e.title or ""), sub = e.text, color = if e.color then Theme.rgb(e.color) else C.strange, hold = 3.4 })
				moment()
			elseif e.kind == "system" and e.tone == "good" and type(e.text) == "string" and string.sub(e.text, 1, 8) == "Promoted" then
				Celebrate.banner(ctx, toastColumn, { title = "Promoted", sub = e.text, color = C.money })
				moment()
			end
		end
	end

	local closeEvent = nil
	local applyResponse
	local askOfficeName

	-- (v0.18) a view of the same life older than the one on screen (Sim:view numbers them)
	local function staleLife(l): boolean
		local cur = state.life
		return type(l) == "table" and type(l.seq) == "number" and cur ~= nil and type(cur.seq) == "number"
			and l.id == cur.id and l.seq < cur.seq
	end

	local playedScene = nil -- the last card whose cutscene played (one showing per card)
	local function openEvent()
		local life = state.life
		if closeEvent or not life or not life.pending then
			return
		end
		-- (v0.14) a card with a scene: you walk up to whoever it's about, then the card
		local pending = life.pending
		state.lastArt = pending.art or (pending.scene and pending.scene.set) or state.lastArt
		if pending.scene and pending.scene.key ~= playedScene and not state.cinema and Stage.enabled(ctx, "meet") then
			playedScene = pending.scene.key
			state.cinema = true
			Stage.meet(ctx, cinemaGui, pending.scene)
			state.cinema = false
			life = state.life
			if closeEvent or not life or not life.pending then
				return
			end
		end
		closeEvent = EventCard.show(ctx, modalColumn, life.pending, function(index: number, approach: string?)
			closeEvent = nil
			task.spawn(function()
				local res = call("choose", { index = index, approach = approach })
				if res then
					applyResponse(res)
				elseif state.lastError == "Nothing to decide." and ctx.actions.resync then
					-- (v0.18) the server has nothing waiting: this card was stale. Take its word.
					ctx.actions.resync()
				elseif state.life and state.life.pending then
					openEvent()
				end
			end)
		end)
	end

	-- A card the server is waiting on must be on screen. Whatever closed it or kept it from
	-- opening (an update that arrived mid-animation, an expedition card in the way, a screen
	-- change), this puts it back. Called after every update, by the DECIDE button, and on a
	-- slow tick, so "decide first" always comes with something to decide.
	local stuckSince = nil
	local function ensureDecision(force: boolean?)
		local life = state.life
		if currentScreen ~= "hud" or not life or not life.alive or not life.pending then
			stuckSince = nil
			return
		end
		-- (v0.18) a flag can outlive whatever set it (a scene or a fight screen that failed or is
		-- already gone). When nothing is actually showing on the cinema layer, a flag that has
		-- held for 15 seconds, or any flag at all when the player pressed DECIDE, is let go
		local blocked = state.battleOpen or state.duelOpen or state.applying or state.cinema
		if blocked then
			-- (a scene on the 3D stage may have nothing on the cinema layer between its captions)
			local showing = World3D.current() ~= nil
			for _, c in cinemaGui:GetChildren() do
				if c:IsA("GuiObject") and c.Visible then
					showing = true
				end
			end
			stuckSince = stuckSince or os.clock()
			if not showing and (force or os.clock() - stuckSince > 15) then
				state.battleOpen, state.duelOpen, state.applying, state.cinema = false, false, false, false
				blocked = false
			end
		end
		if not blocked then
			stuckSince = nil
		end
		if state.battleOpen or state.duelOpen then
			return
		end
		if state.busy or state.applying or state.cinema then
			return
		end
		if closeEvent and not modalColumn:FindFirstChild("EventCard", true) then
			closeEvent = nil -- the card was taken down with something else
		end
		if not closeEvent then
			openEvent()
		end
	end
	ctx.actions.showDecision = ensureDecision
	-- (v0.18) for tests and the mod menu: where the decision stands on this screen
	function ctx.actions.decisionState()
		return {
			screen = currentScreen,
			cardHeld = closeEvent ~= nil,
			cardOnScreen = modalColumn:FindFirstChild("EventCard", true) ~= nil,
			stuckSince = stuckSince,
		}
	end

	-- (v0.18) the server is waiting on a card this screen never got (or never showed): fetch the
	-- life again, and put the card up
	local function resync()
		local ok, res = pcall(function()
			return Request:InvokeServer("hello")
		end)
		if ok and type(res) == "table" and res.ok and res.life then
			applyResponse({ ok = true, life = res.life })
			task.defer(ensureDecision, true)
		end
	end
	ctx.actions.resync = resync
	task.spawn(function()
		while true do
			task.wait(2)
			ensureDecision()
		end
	end)

	-- a fight gets the full clash screen; any other risky choice is a quick check
	local function playClash(clash)
		if clash.fight or not (state.info and state.info.quickChecks) then
			local places = (Config.music and Config.music.places) or {}
			local boss = clash.boss == true or ((clash.foe and clash.foe.coins or 0) >= 4)
			clash.boss = boss
			if boss then
				Sfx.play("bossStart")
			end
			Music.moment((if boss then places.boss else nil) or places.fight or "battle", 90)
			-- (v0.14) a real fight is acted out: you and your foe walk in and square off, and
			-- after the coins, how it ended
			local acted = clash.fight and Stage.enabled(ctx, "fight")
			local place = nil
			local life = state.life
			if life and life.district then
				place = string.format("%s %d  ·  %s", (state.info.city and state.info.city.word) or "District", life.district.number or 0, (life.side and life.side.short) or "")
			end
			local fallback = if life and life.side and life.side.id == "nest" then "nest" else "street"
			if acted then
				state.cinema = true
				Stage.fightIntro(ctx, cinemaGui, clash, { art = state.lastArt, fallbackSet = fallback, kicker = place })
				state.cinema = false
			end
			ClashView.play(ctx, clashColumn, clash)
			if acted then
				state.cinema = true
				Stage.fightOutro(ctx, cinemaGui, clash, { art = state.lastArt, fallbackSet = fallback })
				state.cinema = false
			end
			Music.endMoment()
		else
			ClashView.check(ctx, clashColumn, clash)
		end
	end

	-- lore found: a banner per entry (titles from the catalog)
	local codexCache = nil
	local function loreFound(ids)
		codexCache = nil
		local titles = {}
		for _, id in ids or {} do
			for _, e in (state.info.codex and state.info.codex.entries) or {} do
				if e.id == id then
					table.insert(titles, e.title)
				end
			end
		end
		if #titles > 0 then
			Celebrate.banner(ctx, toastColumn, { title = "Archive", sub = "Added: " .. table.concat(titles, ", "), color = C.strange, hold = 2.6 })
		end
	end

	-- (v0.16) BOSS BATTLES in turns (UI/BattleView.luau): opened by a choose response (or a
	-- push, for a fight you joined), updated every turn, closed with its end
	local battleView = nil
	local bossIntroSeen = {}
	local function openBattle(view)
		if not battleView then
			local places = (Config.music and Config.music.places) or {}
			Music.moment(places.boss or places.fight or "battle", 600)
			Sfx.play("bossStart")
			-- (v0.18) a boss gets an entrance: its own scene on its own ground, once per fight
			local key = tostring(view and view.boss and view.boss.id) .. ":" .. tostring(state.life and state.life.age)
			if view and view.boss and (tonumber(view.turn) or 1) <= 1 and not bossIntroSeen[key] and Stage.enabled(ctx, "fight") then
				bossIntroSeen[key] = true
				state.cinema = true
				Stage.bossIntro(ctx, cinemaGui, view.boss, { kicker = view.title })
				state.cinema = false
			end
			battleView = BattleView.open(ctx, cinemaGui, {
				onAct = function(action: string, approach: string?)
					task.spawn(function()
						local res = call("battleAct", { action = action, approach = approach })
						if res then
							applyResponse(res)
						end
					end)
				end,
				onGo = function()
					task.spawn(function()
						local res = call("battleGo", {})
						if res then
							applyResponse(res)
						end
					end)
				end,
				onClose = function()
					battleView = nil
					state.battleOpen = false
					Music.endMoment()
				end,
			})
			state.battleOpen = true
		end
		battleView:set(view)
	end
	local function finishBattle(done)
		local bv = battleView
		if bv then
			sound(if done and done.outcome == "won" then "win" else "lose")
			bv:done(done)
		end
		battleView = nil
		state.battleOpen = false
	end
	local function closeBattle()
		if battleView then
			battleView:close()
		end
		battleView = nil
		state.battleOpen = false
	end
	ctx.battleOpen = function()
		return battleView ~= nil
	end

	-- (v0.17) DUELS in turns (UI/DuelView.luau): opened when a duel starts, updated every
	-- turn (your move, or theirs pushed to you), finished with its end
	local duelView = nil
	local function openDuel(view)
		if not duelView then
			local places = (Config.music and Config.music.places) or {}
			Music.moment(places.fight or "battle", 600)
			Sfx.play("bossStart")
			duelView = DuelView.open(ctx, cinemaGui, {
				onAct = function(action: string, approach: string?)
					task.spawn(function()
						local res = call("duelAct", { action = action, approach = approach })
						if res then
							applyResponse(res)
						end
					end)
				end,
				onGo = function()
					task.spawn(function()
						local res = call("duelGo", {})
						if res then
							applyResponse(res)
						end
					end)
				end,
				onClose = function()
					duelView = nil
					state.duelOpen = false
					Music.endMoment()
				end,
			})
			state.duelOpen = true
		end
		duelView:set(view)
	end
	local function finishDuel(view)
		local dv = duelView
		if dv then
			sound(if view and view.won then "win" else "lose")
			task.spawn(function()
				dv:done(view)
			end)
		end
		duelView = nil
		state.duelOpen = false
	end
	ctx.duelOpen = function()
		return duelView ~= nil
	end

	local function applyInner(res)
		if res.meta then
			state.meta = res.meta
			side:setMeta(state.meta)
		end
		if res.talent then
			state.talent = res.talent
		end
		if res.crew ~= nil then
			state.crew = res.crew or nil
			hud:setCrewAge(state.crew and state.crew.age)
		end
		if res.clash then
			playClash(res.clash)
		end
		if res.codexNew then
			loreFound(res.codexNew)
		end
		if res.life and not staleLife(res.life) then
			state.life = res.life
		end
		-- (v0.16) a boss battle: its end, or this turn of it
		if res.battleDone then
			finishBattle(res.battleDone)
		elseif res.battle == false then
			closeBattle()
		elseif type(res.battle) == "table" and res.battle.boss then
			openBattle(res.battle)
		elseif res.life and type(res.life.battle) == "table" and res.life.battle.boss then
			openBattle(res.life.battle)
		end
		-- (v0.17) a duel: its end, or this turn of it
		if res.duelDone then
			finishDuel(res.duelDone)
		elseif type(res.duel) == "table" and res.duel.me then
			openDuel(res.duel)
		end
		if res.log then
			hud:resetLog(res.log)
		elseif res.entries then
			hud:appendEntries(res.entries)
			celebrate(res.entries)
		end
		if res.entries and not res.skipCards then
			for _, e in res.entries do
				if e.kind == "chapter" or e.kind == "intervallo" then
					state.cinema = true
					ChapterCard.play(ctx, cinemaGui, e)
					state.cinema = false
				elseif e.kind == "cutscene" then
					-- a turning point: the Light, the Library, the voice, E.G.O
					state.cinema = true
					Cutscene.play(ctx, cinemaGui, e)
					state.cinema = false
				elseif e.kind == "story" then
					-- a new story takes hold of you
					state.cinema = true
					Cutscene.play(ctx, cinemaGui, { style = "story", kicker = "A new story", title = e.title, lines = { e.text }, color = Theme.tone(e.tone) })
					state.cinema = false
				end
			end
		end
		local life = state.life
		if life then
			hud:setLife(life)
			side:setLife(life)
			updateScene()
		end
		if res.crewDone and res.crewDone.outcome ~= "success" then
			Celebrate.banner(ctx, toastColumn, {
				title = if res.crewDone.outcome == "fail" then "Expedition failed" else "Turned back",
				sub = res.crewDone.name,
				color = C.crimsonHi,
			})
		end
		if life and not life.alive then
			sound("death")
			-- the last scene of the life, then the end-of-life screen
			state.cinema = true
			local okScene = pcall(function()
				DeathScene.play(ctx, cinemaGui, { life = life, cause = res.lantern and res.lantern.cause })
			end)
			state.cinema = false
			if not okScene then
				task.wait(1.2)
			end
			-- (v0.18) a new life (an heir, a fresh start) may have begun while the last scene was
			-- playing: then the death screen would cover a life that's going, with its cards hidden
			local now = state.life
			if now and now ~= life and now.alive then
				task.defer(ensureDecision)
				return
			end
			if res.lantern then
				showScreen("death")
				deathScreen.show(res.lantern, life)
			else
				ctx.actions.showNewLife()
			end
			return
		end
		if battleView or duelView then
			return -- the fight is on screen; cards wait for it
		end
		if life and life.pending then
			task.wait(0.15)
			openEvent()
		elseif runPending() then
			task.wait(0.15)
			ctx.actions.openRun()
		end
	end

	-- Plays clashes, updates the log/HUD and routes to the death screen.
	-- state.applying stays true until the player can act again.
	-- (v0.18) a new Office: ask for its name, once, when nothing else is waiting
	function askOfficeName()
		local l = state.life
		if l and l.alive and l.office and l.office.named == false and not l.pending and state.officeAsked ~= l.id then
			state.officeAsked = l.id
			task.delay(0.9, function()
				local now = state.life
				if now and now.id == l.id and now.office and now.office.named == false and not now.pending and ctx.actions.openOffice then
					ctx.actions.openOffice({ naming = true })
				end
			end)
		end
	end

	function applyResponse(res)
		state.applying = true
		local ok, err = pcall(applyInner, res)
		state.applying = false
		if not ok then
			warn("[LifeSim] UI update failed: " .. tostring(err))
		end
		task.defer(ensureDecision)
		askOfficeName()
	end

	-- ── actions ──
	local actions = ctx.actions

	function actions.ageUp()
		local life = state.life
		if life and life.alive and life.pending then
			-- DECIDE: the button brings the card back (and if none comes, asks the server again)
			ensureDecision(true)
			task.delay(0.6, function()
				if state.life and state.life.pending and not modalColumn:FindFirstChild("EventCard", true) then
					resync()
				end
			end)
			return
		end
		if state.busy or state.applying or not life or not life.alive then
			return
		end
		-- in a crew that ages together, a second press takes your ready back
		local crewAge = state.crew and state.crew.age
		if crewAge and crewAge.youReady then
			task.spawn(actions.crewCall, "crewAgeCancel")
			return
		end
		sound("ageUp")
		local res = call("ageUp")
		if not res and state.lastError == "Decide what to do first." then
			-- the server has a card this screen doesn't: get it
			task.spawn(resync)
			return
		end
		if res then
			if res.waiting then
				state.crew = res.crew or state.crew
				hud:setCrewAge(state.crew and state.crew.age)
				toast(res.toast or "Waiting for your crew.")
				return
			end
			applyResponse(res)
		end
	end

	-- the captain turns the year for whoever is ready
	function actions.crewAgeNow()
		local res = call("crewAgeNow")
		if res then
			if res.life and res.entries then
				applyResponse(res)
			else
				state.crew = res.crew or state.crew
				hud:setCrewAge(state.crew and state.crew.age)
			end
		end
	end

	-- ── duels ──
	function actions.duelChallenge(userId: number)
		local res = call("duelChallenge", { userId = userId })
		if res and res.toast then
			toast(res.toast)
		end
	end

	function actions.loadDuelTargets(after)
		task.spawn(function()
			local ok, res = pcall(function()
				return Request:InvokeServer("duelTargets")
			end)
			if ok and type(res) == "table" and res.ok then
				after(res.targets)
			else
				after({})
			end
		end)
	end

	function actions.openDuels()
		if not state.busy then
			sound("click")
			Social.duels(ctx, sheetColumn)
		end
	end

	-- ── expeditions ──
	local KIND_BAND = {
		mission = { label = "Mission", color = C.accentLo },
		dungeon = { label = "Dungeon", color = Color3.fromRGB(34, 92, 88) },
		trip = { label = "Undertow Line", color = Color3.fromRGB(58, 70, 96) },
		containment = { label = "Containment", color = C.crimson },
	}
	local openRunKey = nil
	local FORCE_PICK = 999 -- the captain's "go with the crew's picks" on a crew run card
	local runIntros = {} -- (v0.14) runs whose way in has been acted out
	function actions.openRun()
		if closeEvent then
			return
		end
		local run, isCrew = runPending()
		if not run then
			return
		end
		-- (v0.14) going in: the first time a run's card opens, you walk up to the way in
		local introKey = tostring(run.id or run.name)
		if (run.step or 1) <= 1 and not runIntros[introKey] and not state.cinema and Stage.enabled(ctx, "full") then
			runIntros[introKey] = true
			local word = if run.purpose
				then string.upper(string.sub(run.purpose, 1, 1)) .. string.sub(run.purpose, 2)
				else (KIND_BAND[run.kind] or KIND_BAND.mission).label
			state.cinema = true
			Stage.descent(ctx, cinemaGui, { title = run.name, kicker = word, set = Stage.descentSet(run) })
			state.cinema = false
			if closeEvent then
				return
			end
			run, isCrew = runPending()
			if not run then
				return
			end
		end
		local stage = run.stage
		local kb = KIND_BAND[run.kind] or KIND_BAND.mission
		local _captain = (not isCrew) or (state.crew ~= nil and state.crew.captain == true)
		local crewList = nil
		if isCrew then
			crewList = {}
			for _, m in state.crew.members do
				if m.character then
					table.insert(crewList, { appearance = m.character.appearance })
				end
			end
		end
		openRunKey = tostring(run.id) .. ":" .. tostring(run.step)
		-- (v0.16) the crew's picks: a count on each option, yours marked, and the captain's
		-- "go with the picks" once the crew has had its time
		local choices = stage.choices
		local voteNote = nil
		if isCrew then
			local votes = state.crew and state.crew.votes
			choices = {}
			for _, c in stage.choices do
				local copy = table.clone(c)
				local n = votes and votes.counts and votes.counts[tostring(c.index)]
				if n and n > 0 then
					copy.label = c.label .. "  ·  " .. tostring(n) .. (if n == 1 then " pick" else " picks")
				end
				if votes and votes.mine == c.index then
					copy.label = "(Your pick) " .. copy.label
				end
				table.insert(choices, copy)
			end
			if votes and votes.canForce then
				table.insert(choices, { index = FORCE_PICK, label = "Go with the crew's picks", hint = tostring(votes.voted) .. " of " .. tostring(votes.total) .. " have picked.", enabled = true })
			end
			if votes and votes.mine then
				voteNote = "You've picked. Waiting for " .. (if votes.waitingOn and #votes.waitingOn > 0 then table.concat(votes.waitingOn, ", ") else "the crew") .. ". You can still change your pick."
			else
				voteNote = "Everyone picks. The crew does what most of you pick; a tie goes the captain's way."
			end
		end
		-- (v0.13) a delve found in the world is drawn as a descent, and says how deep it is
		local purposeWord = if run.purpose then (string.upper(string.sub(run.purpose, 1, 1)) .. string.sub(run.purpose, 2)) else nil
		closeEvent = EventCard.show(ctx, modalColumn, {
			title = stage.title,
			text = stage.text,
			choices = choices,
			tone = stage.tone,
			theme = if run.purpose then "delve" else nil,
			band = {
				band = if stage.tone == "danger" then C.crimson else kb.color,
				label = run.name,
				stamp = if stage.tone == "danger" then "Danger" else nil,
			},
			step = if purposeWord
				then purposeWord .. "  ·  " .. (run.depthWord or "step") .. " " .. tostring(run.step or 1) .. (if run.length then " of ~" .. tostring(run.length) else "")
				else kb.label .. "  ·  step " .. tostring(run.step or 1),
			crew = crewList,
			-- (v0.16) everyone on a crew run picks; the crew does what most of them pick
			readOnly = false,
			note = voteNote,
		}, function(index: number, approach: string?)
			closeEvent = nil
			openRunKey = nil
			task.spawn(function()
				local res = if isCrew and index == FORCE_PICK
					then call("crewChoose", { force = true })
					elseif isCrew then call("crewChoose", { index = index, approach = approach })
					else call("expeditionChoose", { index = index, approach = approach })
				if res then
					applyResponse(res)
				elseif runPending() then
					actions.openRun()
				end
			end)
		end, function(index: number)
			task.spawn(function()
				local res = call("crewSuggest", { index = index })
				if res and res.toast then
					toast(res.toast)
				end
			end)
		end)
	end

	function actions.expeditionStart(id: string)
		local crew = state.crew
		if crew and #crew.members > 1 then
			if crew.captain then
				actions.crewCall("crewPropose", { id = id }, function()
					actions.openCrew()
				end)
			else
				toast("Your captain picks the expeditions.")
			end
			return
		end
		local res = call("expeditionStart", { id = id })
		if res then
			applyResponse(res)
		end
	end

	-- ── crews, rankings, the store, goals, music ──
	function actions.crewCall(action: string, payload: any?, after)
		local res = call(action, payload)
		if res then
			if res.toast then
				toast(res.toast)
			end
			if action ~= "crewSuggest" then
				state.crew = res.crew
				if res.players then
					state.crewPlayers = res.players
				end
				hud:setCrewAge(state.crew and state.crew.age)
			end
			if res.life then
				state.life = res.life
				hud:setLife(res.life)
			end
			if after then
				after(res)
			end
			updateScene()
		end
	end

	function actions.openCrew()
		if not state.busy then
			sound("click")
			Social.crew(ctx, sheetColumn)
		end
	end

	function actions.openRankings()
		if not state.busy then
			sound("click")
			Social.rankings(ctx, sheetColumn)
		end
	end

	function actions.loadLeaderboard(board: string, after)
		task.spawn(function()
			local ok, res = pcall(function()
				return Request:InvokeServer("leaderboard", { board = board })
			end)
			if ok and type(res) == "table" and res.ok and after then
				after(res.board)
			end
		end)
	end

	-- the guidebook: fetched once, then kept
	function actions.loadGuide(after)
		if state.guide then
			after(state.guide)
			return
		end
		task.spawn(function()
			local ok, res = pcall(function()
				return Request:InvokeServer("guide")
			end)
			if ok and type(res) == "table" and res.ok then
				state.guide = res.guide
				after(res.guide)
			else
				toast("The guidebook is stuck. Try again in a moment.")
				after(nil)
			end
		end)
	end

	function actions.openGuide(section: string?)
		if not state.busy then
			sound("click")
			Guide.open(ctx, sheetColumn, section)
		end
	end

	function actions.openStore()
		if not state.busy then
			sound("click")
			Social.store(ctx, sheetColumn)
		end
	end

	function actions.loadStore(after)
		task.spawn(function()
			local ok, res = pcall(function()
				return Request:InvokeServer("store")
			end)
			if ok and type(res) == "table" and res.ok and after then
				after(res.store, res.note, res.looksOnly)
			end
		end)
	end

	-- (v0.17) a redeem code, typed in the store
	function actions.redeemCode(code: string, after)
		task.spawn(function()
			local res = call("redeemCode", { code = code })
			if res then
				if res.meta then
					state.meta = res.meta
					side:setMeta(state.meta)
				end
				if res.life then
					applyResponse(res)
				end
				Celebrate.banner(ctx, toastColumn, { title = "Code redeemed", sub = res.toast or "", color = CELEBRATIONS.purchase.color })
			end
			if after then
				after(res)
			end
		end)
	end

	-- an item priced in Lunacy: confirm, then pay from your Lunacy (no Roblox prompt)
	function actions.spendItem(item, after)
		local premium = (ctx.info and ctx.info.lunacy) or "Lunacy"
		Prompt.show(modalColumn, {
			title = item.name,
			text = string.format("Spend %d %s? You have %d.", item.lunacy or 0, premium, (state.meta and state.meta.lunacy) or 0) .. (if item.random and item.odds then "\nOdds: " .. item.odds else ""),
			buttons = {
				{ label = "Not now", style = "ghost" },
				{ label = "Spend " .. tostring(item.lunacy or 0), style = "primary", onClick = function()
					task.spawn(function()
						local res = call("storeSpend", { key = item.key })
						if res then
							state.meta = res.meta or state.meta
							if res.life then
								applyResponse(res)
							end
							sound("win")
							Celebrate.banner(ctx, toastColumn, { title = "Yours", sub = item.name, color = CELEBRATIONS.purchase.color })
							if after then
								after(res.store)
							end
						end
					end)
				end },
			},
		})
	end

	function actions.buyItem(item, after)
		if item.currency == "lunacy" then
			actions.spendItem(item, after)
			return
		end
		if item.test then
			local res = call("storeTestBuy", { key = item.key })
			if res then
				state.meta = res.meta or state.meta
				-- a boost changes the life you're living
				if res.life then
					applyResponse(res)
				end
				Celebrate.banner(ctx, toastColumn, { title = "Unlocked", sub = item.name .. " (test purchase)", color = CELEBRATIONS.purchase.color })
				if after then
					after(res.store)
				end
			end
			return
		end
		pcall(function()
			if item.kind == "pass" then
				MarketplaceService:PromptGamePassPurchase(player, item.id)
			else
				MarketplaceService:PromptProductPurchase(player, item.id)
			end
		end)
	end

	function actions.openGoals()
		if state.life and not state.busy then
			sound("click")
			Social.goals(ctx, sheetColumn)
		end
	end

	function actions.toggleMusic()
		local on = not Music.isEnabled()
		Music.setEnabled(on)
		hud:setMusicLabel(on)
		task.spawn(function()
			pcall(function()
				Request:InvokeServer("setSetting", { key = "music", value = on })
			end)
		end)
	end

	function actions.setFrame(id: string, after)
		local res = call("setSetting", { key = "frame", value = id })
		if res then
			state.meta = res.meta or state.meta
			if res.life then
				state.life = res.life
				hud:setLife(res.life)
			end
			if after then
				after()
			end
		end
	end

	function actions.openActivities()
		if state.life and state.life.alive and not state.busy and not state.applying then
			sound("click")
			Sheets.activities(ctx, sheetColumn)
		end
	end

	function actions.openLife(tab: string?)
		if state.life and not state.busy then
			sound("click")
			Sheets.life(ctx, sheetColumn, tab)
		end
	end

	-- (v0.18) your own Office: the sign, the building, rooms, the roster, the lab
	function actions.openOffice(opts)
		if state.life and state.life.office and not state.busy then
			sound("click")
			OfficeSheet.open(ctx, sheetColumn, opts)
		end
	end

	function actions.officeAct(op: string, arg: any, after)
		local res = call("officeAct", { op = op, arg = arg })
		if res then
			applyResponse(res)
			sound(if op == "fire" then "click" else "win")
		end
		if after then
			after(res)
		end
	end

	function actions.officeName(name: string?, motto: string?, color: string?, after)
		local res = call("officeName", { name = name, motto = motto, color = color })
		if res then
			applyResponse(res)
			sound("win")
		end
		if after then
			after(res)
		end
	end

	function actions.openPerson(rel)
		if state.life and not state.busy then
			sound("click")
			-- (v0.19) a pack with a party: someone in your life opens their profile (their story,
			-- what they like, your history, everything you can do together); a linked friend, a
			-- pack without one: the kit's person sheet
			if state.life.party and rel and not rel.linked and rel.alive and actions.openNpc then
				actions.openNpc(rel.id)
				return
			end
			task.delay(0.25, function()
				Sheets.person(ctx, sheetColumn, rel)
			end)
		end
	end

	-- (v0.19) THE PARTY (UI/PartySheet) and one person's profile (UI/NpcProfile)
	local function partyOpts(extra: any?): any
		local o = {
			onResponse = function(res: any)
				applyResponse(res)
				if res and res.result and res.result.accepted == true then
					sound("win")
				elseif res and res.result and res.result.accepted == false then
					sound("lose")
				else
					sound("click")
				end
			end,
			toast = toast,
			currency = (ctx.info and ctx.info.meta and ctx.info.meta.currency) or "million won",
		}
		for k, v in extra or {} do
			o[k] = v
		end
		return o
	end
	function actions.openParty()
		if state.life and state.life.party and state.life.alive and not state.busy then
			sound("click")
			PartySheet.open(partyGui, call, partyOpts())
		end
	end
	function actions.openNpc(relId: number)
		if state.life and state.life.party and state.life.alive and not state.busy and type(relId) == "number" then
			NpcProfile.open(partyGui, call, partyOpts({ relId = relId }))
		end
	end
	function actions.closeParty()
		PartySheet.close()
		NpcProfile.close()
	end

	function actions.interact(relId: number, id: string, approach: string?)
		local res = call("interact", { relId = relId, id = id, approach = approach })
		if res then
			applyResponse(res)
		end
	end

	function actions.buyGear(id: string, after)
		local res = call("buyGear", { id = id })
		if res then
			applyResponse(res)
			if after then
				after()
			end
		end
	end

	function actions.buyMarket(market: string, good: string, after)
		local res = call("buyMarket", { market = market, good = good })
		if res then
			applyResponse(res)
			if after then
				after()
			end
		end
	end

	function actions.equipGear(id: string, after)
		local res = call("equipGear", { id = id })
		if res then
			applyResponse(res)
			if after then
				after()
			end
		end
	end

	function actions.sellGear(id: string, after)
		local res = call("sellGear", { id = id })
		if res then
			applyResponse(res)
			if after then
				after()
			end
		end
	end

	function actions.dropGear(slot: string, after)
		local res = call("dropGear", { slot = slot })
		if res then
			applyResponse(res)
			if after then
				after()
			end
		end
	end

	function actions.doActivity(id: string, arg: string?, approach: string?)
		local res = call("activity", { id = id, arg = arg, approach = approach })
		if res then
			-- (v0.14) what you did, acted out for a moment (a fight gets its own intro instead)
			local kind = Stage.vignetteFor(id)
			if kind and not res.clash and not state.cinema and Stage.enabled(ctx, "full") then
				state.cinema = true
				local life = state.life
				Stage.vignette(ctx, cinemaGui, kind, { time = if life and life.side and life.side.id == "nest" then "day" else "night" })
				state.cinema = false
			end
			applyResponse(res)
		end
	end

	-- a job off this year's board
	function actions.doJob(index: number, approach: string?)
		local res = call("job", { index = index, approach = approach })
		if res then
			applyResponse(res)
		end
	end

	function actions.openDistrict()
		if state.life and not state.busy then
			sound("click")
			Sheets.district(ctx, sheetColumn)
		end
	end

	-- ── friends ──
	local function friendsCall(action: string, payload: any?, after)
		local res = call(action, payload)
		if res then
			if res.toast then
				toast(res.toast)
			end
			if res.life then
				state.life = res.life
				hud:setLife(res.life)
			end
			if res.entries then
				hud:appendEntries(res.entries)
			end
			if after then
				after(res.friends)
			end
		end
	end

	function actions.loadFriends(after)
		friendsCall("friends", nil, after)
	end

	function actions.linkRequest(userId: number, after)
		friendsCall("linkRequest", { userId = userId }, after)
	end

	function actions.linkRespond(userId: number, accept: boolean, after)
		friendsCall("linkRespond", { userId = userId, accept = accept }, after)
	end

	function actions.setRough(on: boolean, after)
		friendsCall("setRough", { on = on }, after)
	end

	function actions.inviteFriends()
		local ok, canInvite = pcall(function()
			return SocialService:CanSendGameInviteAsync(player)
		end)
		if ok and canInvite then
			pcall(function()
				SocialService:PromptGameInvite(player)
			end)
		else
			toast("Invites aren't available right now.")
		end
	end

	function actions.joinCareer(id: string)
		local res = call("joinCareer", { id = id })
		if res then
			applyResponse(res)
		end
	end

	function actions.leaveCareer()
		local res = call("leaveCareer")
		if res then
			applyResponse(res)
		end
	end

	local maybeTutorial -- defined below

	local function closeAllSheets()
		for _ = 1, #Sheets.stack + 2 do
			local top = Sheets.stack[#Sheets.stack]
			if not top then
				break
			end
			top()
		end
	end

	-- a new life: the City rolls where you land (BirthReveal), Canto I, then the HUD
	local function arrive(res)
		closeAllSheets()
		local rolled = state.info and state.info.creatorPicks == false
		if rolled and res.life then
			state.cinema = true
			-- the age you were born into, in three lines, before anything else
			for _, era in (state.info and state.info.eras) or {} do
				if era.id == res.life.openingEra and era.opening then
					Cutscene.play(ctx, cinemaGui, { style = "age", kicker = "Year " .. tostring(res.life.year or ""), title = era.name, lines = era.opening })
				end
			end
			local release = BirthReveal.play(ctx, cinemaGui, res.life)
			for _, e in res.log or {} do
				if e.kind == "chapter" then
					ChapterCard.play(ctx, cinemaGui, e)
				end
			end
			res.skipCards = true
			showScreen("hud")
			release()
			state.cinema = false
		else
			showScreen("hud")
		end
		applyResponse(res)
		maybeTutorial()
	end

	function actions.newLife(originId: string, first: string, district: string?, look: any?, choices: any?)
		local res = call("newLife", {
			origin = originId,
			first = first,
			district = district,
			look = look,
			traits = choices and choices.traits,
			style = choices and choices.style,
			alloc = choices and choices.alloc,
			era = choices and choices.era,
			mode = state.mode,
			difficulty = state.difficulty,
			confirm = state.life ~= nil and state.life.alive == true,
		})
		if res then
			arrive(res)
		end
	end

	-- ── THE LOBBY: starting lives together ──
	-- "With friends" opens it. The host sets the age, the place and the rest; everyone makes a
	-- character in the same creator a life alone uses; the host starts every life at once.
	local lobbyView = nil
	local function drawLobby(animate: boolean?)
		if lobbyView then
			lobbyView.destroy()
			lobbyView = nil
		end
		local wide, canvasHeight = sizeMenu()
		local life = state.life
		lobbyView = Lobby.show(ctx, lobbyHolder, {
			wide = wide,
			canvasHeight = canvasHeight,
			crew = state.crew,
			players = state.crewPlayers,
			userId = player.UserId,
			hasLife = life ~= nil and life.alive == true,
			animate = animate == true,
			refresh = function()
				if currentScreen == "lobby" then
					drawLobby(false)
				end
			end,
		})
	end
	-- (the crew changed under an open lobby: a setting, someone ready, someone gone)
	ctx.lobbyRefresh = function()
		if currentScreen ~= "lobby" then
			return
		end
		if not state.crew then
			-- let go from the lobby: back to the menu
			state.together = false
			actions.showMenu()
			return
		end
		drawLobby(false)
	end

	-- who else is on the server changes while a lobby is open: the list is asked for again
	-- every few seconds, and the screen is redrawn only when it's different
	local lobbyWatch = 0
	local function watchLobby()
		lobbyWatch += 1
		local mine = lobbyWatch
		task.spawn(function()
			while mine == lobbyWatch and currentScreen == "lobby" do
				task.wait(6)
				if mine ~= lobbyWatch or currentScreen ~= "lobby" then
					break
				end
				local ok, res = pcall(function()
					return Request:InvokeServer("crewState")
				end)
				if ok and type(res) == "table" and res.ok and mine == lobbyWatch and currentScreen == "lobby" then
					local before, now = {}, {}
					for _, p in state.crewPlayers or {} do
						table.insert(before, tostring(p.userId) .. (if p.inCrew then "c" else ""))
					end
					for _, p in res.players or {} do
						table.insert(now, tostring(p.userId) .. (if p.inCrew then "c" else ""))
					end
					state.crewPlayers = res.players or {}
					if table.concat(before, ",") ~= table.concat(now, ",") and not state.busy then
						state.crew = res.crew or state.crew
						drawLobby(false)
					end
				end
			end
		end)
	end

	function actions.openLobby()
		if state.busy then
			return
		end
		local res = call("lobbyOpen")
		if not res then
			return
		end
		state.crew = res.crew
		state.crewPlayers = res.players or state.crewPlayers
		state.together = true
		closeAllSheets()
		showScreen("lobby")
		drawLobby(true)
		ctx.music("creator")
		watchLobby()
	end

	function actions.lobbySet(key: string, value: any)
		local res = call("lobbySet", { key = key, value = value })
		if res then
			state.crew = res.crew
			state.crewPlayers = res.players or state.crewPlayers
			ctx.lobbyRefresh()
		end
	end

	function actions.leaveLobby()
		local res = call("crewLeave")
		if res then
			state.crew = res.crew or nil
			state.together = false
			toast("You left the lobby.")
			actions.showMenu()
		end
	end

	function actions.togetherReady(originId: string, first: string, district: string?, look: any?, choices: any?)
		local res = call("crewTogetherReady", {
			origin = originId,
			first = first,
			district = district,
			look = look,
			traits = choices and choices.traits,
			style = choices and choices.style,
			alloc = choices and choices.alloc,
			era = choices and choices.era,
			mode = state.mode,
			confirm = true,
		})
		if res then
			state.crew = res.crew
			state.crewPlayers = res.players or state.crewPlayers
			local crew = state.crew
			toast(if crew and crew.captain then "You're ready. Start when everyone is." else "You're ready. The host starts everyone's lives.")
			if crew and crew.lobby then
				showScreen("lobby")
				drawLobby(false)
			else
				actions.openCrew()
			end
		end
	end

	-- the creator, for a life that starts with the lobby: the same one a life alone uses, on
	-- the way of beginning the host chose
	function actions.makeTogetherCharacter()
		state.together = true
		closeAllSheets()
		local lobby = state.crew and state.crew.lobby
		actions.showQuickStart(if lobby then lobby.mode else state.mode)
	end

	function actions.togetherStart()
		local res = call("crewTogetherStart")
		if res then
			state.together = false
			closeAllSheets()
			arrive(res)
		end
	end

	-- ── the start menu, the intro, the tutorial ──
	local menu = nil
	-- (BitLeveling) the title screen and main menu (UI/TitleMenu) stand in for the kit's intro
	-- and mode select when the pack's live city is on (Config.hunterLive.titleMenu ~= false)
	local useTitle = false
	do
		local okCfg, Cfg = pcall(function()
			return require(ReplicatedStorage:WaitForChild("LifeSim"):WaitForChild("Config"))
		end)
		useTitle = okTitle and okCfg and type(Cfg) == "table" and type(Cfg.hunterLive) == "table" and Cfg.hunterLive.enabled ~= false and Cfg.hunterLive.titleMenu ~= false
	end
	local title = nil
	function actions.showTitleMenu(direct: boolean?)
		if title then
			title.destroy()
			title = nil
		end
		if menu then
			menu.destroy()
			menu = nil
		end
		local life = state.life
		local hasLife = life ~= nil and life.alive == true
		local info = state.info or {}
		local diffs = info.difficulties or {}
		local hunter = ReplicatedStorage:WaitForChild("LifeSim"):FindFirstChild("Hunter")
		local function lib(name: string): any
			local ok, m = pcall(function()
				return require(hunter:WaitForChild(name, 2))
			end)
			return if ok then m else nil
		end
		local function ui(name: string): any
			local ok, m = pcall(function()
				return require(UI:WaitForChild(name, 2))
			end)
			return if ok then m else nil
		end
		local R6Rig = hunter and lib("R6Rig")
		local okG, GateVfx = pcall(function()
			return require(script.Parent:WaitForChild("GateVfx", 2))
		end)
		menuHolder.Size = UDim2.fromScale(1, 1)
		local modeId = info.modes and info.modes[1] and info.modes[1].id or nil
		title = TitleMenu.show(menuHolder, {
			R6Rig = R6Rig,
			Looks = hunter and lib("Looks"),
			GateVfx = if okG then GateVfx else nil,
			direct = direct,
			hasLife = hasLife,
			lifeLine = if hasLife then string.format("%s %s, %d", life.first, life.last, life.age) else nil,
			difficulties = diffs.list or {},
			difficulty = state.difficulty or (state.meta and state.meta.difficulty) or diffs.default,
			modes = info.modes,
			on = {
				continue = function()
					showScreen("hud")
					if state.life and state.life.pending then
						openEvent()
					end
				end,
				newLife = function(diffId)
					state.difficulty = diffId
					state.together = false
					actions.showQuickStart(modeId)
				end,
				together = function(diffId)
					state.difficulty = diffId
					actions.openLobby()
				end,
				character = function()
					local Creator = ui("R6Creator")
					if Creator and R6Rig then
						Creator.open(menuHolder, call, R6Rig)
					end
				end,
				lifeCreator = function()
					actions.showQuickStart(modeId)
				end,
				talentSpin = function()
					actions.showQuickStart(modeId)
				end,
				surnameSpin = function()
					actions.openSurnames()
				end,
				walk = function()
					task.spawn(call, "hwWalk", { on = true })
				end,
				news = function()
					local Board = ui("HunterBoard")
					if Board then
						Board.open(menuHolder, call, nil)
					end
				end,
				endings = function()
					local Board = ui("HunterBoard")
					if Board then
						Board.open(menuHolder, call, nil, { tab = "endings" })
					end
				end,
				market = function()
					local Market = ui("MarketUI")
					if Market then
						Market.open(menuHolder, call, nil)
					end
				end,
				guide = function()
					actions.openGuide()
				end,
				settings = function()
					actions.openMenu()
				end,
			},
		})
		showScreen("menu")
		-- your Hunter on the podium (the server has the saved look)
		task.spawn(function()
			local res = call("r6Get")
			if title and res and res.look then
				title.setLook(res.look)
			end
		end)
		updateScene()
	end
	function actions.showMenu()
		if useTitle then
			actions.showTitleMenu(true)
			return
		end
		if title then
			title.destroy()
			title = nil
		end
		if menu then
			menu.destroy()
		end
		local life = state.life
		local hasLife = life ~= nil and life.alive == true
		local wide, canvasHeight = sizeMenu()
		menu = Intro.menu(ctx, menuHolder, {
			wide = wide,
			canvasHeight = canvasHeight,
			hasLife = hasLife,
			lifeLine = if hasLife then string.format("%s %s, %d", life.first, life.last, life.age) else nil,
			onContinue = function()
				showScreen("hud")
				if state.life and state.life.pending then
					openEvent()
				end
			end,
			onMode = function(modeId)
				state.together = false
				actions.showQuickStart(modeId)
			end,
			onUnlockMode = function(modeId)
				local res = call("unlockMode", { id = modeId })
				if res then
					state.meta = res.meta or state.meta
					if res.toast then
						Celebrate.banner(ctx, toastColumn, { title = "Unlocked", sub = res.toast, color = CELEBRATIONS.purchase.color })
					end
					actions.showMenu()
				end
			end,
			onFriends = function()
				actions.openLobby()
			end,
			onGuide = function()
				actions.openGuide()
			end,
			onLore = function()
				side:open("lore")
			end,
			onMenu = function()
				actions.openMenu()
			end,
		})
		showScreen("menu")
		if UserInputService.GamepadEnabled and menu.first then
			pcall(function()
				GuiService.SelectedObject = menu.first
			end)
		end
	end
	-- the window changed shape while the menu is up: lay it out again for the new shape
	do
		local queued = false
		local function reshape()
			if queued then
				return
			end
			if currentScreen == "lobby" then
				-- the lobby is laid out for the window it was opened in: again for the new one
				queued = true
				task.defer(function()
					queued = false
					local before = menuShape
					sizeMenu()
					if menuShape ~= before and ctx.lobbyRefresh then
						ctx.lobbyRefresh()
					end
				end)
				return
			end
			if currentScreen ~= "menu" or not menu then
				return
			end
			queued = true
			task.defer(function()
				queued = false
				if currentScreen ~= "menu" or not menu then
					return
				end
				local before = menuShape
				sizeMenu()
				if menuShape ~= before then
					actions.showMenu()
				end
			end)
		end
		local gui = menuGui()
		if gui then
			gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(reshape)
		end
		Layout.changed:Connect(reshape)
	end

	-- the quick creator for a game mode (the full creator is one tap away)
	function actions.showQuickStart(modeId: string?)
		state.mode = modeId
		local info = state.info or {}
		-- (blueprint) a game made with Base always gets the one-screen creator (info.modernCreator)
		if not (info.buildPresets and #info.buildPresets > 0) and not state.talent and not info.modernCreator then
			actions.showNewLife()
			return
		end
		showScreen("quick")
		quickScreen.refresh(modeId)
		ctx.music("creator")
	end

	-- the sins a player leans toward (shape the next talent rolls)
	function actions.setAffinities(ids, after)
		task.spawn(function()
			local ok, res = pcall(function()
				return Request:InvokeServer("setAffinities", { ids = ids })
			end)
			if ok and type(res) == "table" and res.ok then
				state.talent = res.talent or state.talent
			end
			if after then
				after(if ok then res else nil)
			end
		end)
	end

	function actions.talentReroll(premium: boolean, lunacy: boolean, after)
		task.spawn(function()
			local res = call("talentReroll", { premium = premium, lunacy = lunacy })
			if res then
				state.talent = res.talent or state.talent
				state.meta = res.meta or state.meta
			end
			if after then
				after(if res then res.talent else nil, if res then res.rolled else nil)
			end
		end)
	end

	-- the intro's camera shots and shake (the City skyline only)
	function actions.shot(name: string, cut: boolean?)
		if Backdrop.shot then
			pcall(Backdrop.shot, name, cut)
		end
	end

	function actions.shake(amount: number)
		if Backdrop.shake then
			pcall(Backdrop.shake, amount)
		end
	end

	function actions.cinematic(on: boolean)
		pcall(Backdrop.cinematic, on)
		if not on then
			updateScene()
		end
	end

	-- the join cinematic: the full one the first time, a short title sting after that
	-- (Settings: intro = "full" | "short" | "off"); it hands over to the mode select
	function actions.playIntro(firstTime: boolean?, toMenu: boolean?)
		Intro.play(ctx, introGui, state.info.intro, function()
			if firstTime then
				task.spawn(call, "setFlag", { key = "seenIntro", value = true })
				state.meta.flags = state.meta.flags or {}
				state.meta.flags.seenIntro = true
			end
			if firstTime or toMenu then
				actions.showMenu()
			end
			updateScene()
		end, { short = not firstTime })
	end

	-- a pack may word the two lessons about its own stats (pack.tutorial = { stats, fights })
	local packTutorial = (ctx.info and ctx.info.tutorial) or {}
	local statsLesson = packTutorial.stats or { title = "Four virtues", text = "Fortitude is your body, Prudence your mind, Temperance your calm, Justice your nerve. Sanity tilts every coin you flip: above zero you land heads more often, below zero less." }
	local fightsLesson = packTutorial.fights or { title = "Fights and checks", text = "Most risks are a quick check of one virtue. Real fights use your discipline, and its status builds with every heads. Disciplines are taught by organisations: you'll find one, or it'll find you." }
	local TUTORIAL = {
		{ target = function() return hud.header end, title = "Your file", text = "Who you are: name, age, where you live, and your money. Tap it to see your district." },
		{ target = function() return hud.statsPanel end, title = statsLesson.title, text = statsLesson.text },
		{ target = function() return hud.ageButton end, title = "Live a year", text = "Each press is a year. Things happen to you; some of them ask you to decide." },
		{ target = function() return hud.activitiesButton end, title = "Spend your year", text = "You get a few actions a year: train, study, work, explore, take a trip. Today's City event is in here too." },
		{ target = function() return hud.lifeButton end, title = "Your life", text = "Career, people, gear, quests, friends. Climb a career all the way to the top, or don't." },
		{ target = function() return hud.root:FindFirstChild("Nav") end, title = "Everything else", text = "Your story, your family, the City and who you know of in it, goals, your crew, rankings, and the guidebook: what everything does." },
		{ target = nil, title = fightsLesson.title, text = fightsLesson.text },
		{ target = nil, title = "Stay alive", text = "The City kills people young. Heal at clinics, be indoors before 3:13, and don't take every fight." },
		{ target = nil, title = "You're not alone", text = "Big deeds on this server go into the chronicle and turn up in other lives. Crews start lives together, age up together, and can duel." },
	}

	function actions.startTutorial()
		showScreen("hud")
		Tutorial.start(ctx, tutorialGui, TUTORIAL, function()
			task.spawn(call, "setFlag", { key = "tutorialDone", value = true })
			state.meta.flags = state.meta.flags or {}
			state.meta.flags.tutorialDone = true
		end)
	end

	local tutorialWaiting = false
	local function screenClear(): boolean
		return currentScreen == "hud"
			and #Sheets.stack == 0
			and closeEvent == nil
			and not state.applying
			and not state.cinema
			and not state.busy
			and not (state.life and state.life.pending)
	end
	function maybeTutorial()
		local flags = state.meta and state.meta.flags
		if (flags and flags.tutorialDone) or tutorialWaiting then
			return
		end
		tutorialWaiting = true
		task.spawn(function()
			-- wait until nothing is on top of the HUD for a moment (up to a few minutes)
			local clearFor = 0
			for _ = 1, 400 do
				task.wait(0.5)
				clearFor = if screenClear() then clearFor + 0.5 else 0
				if clearFor >= 1.5 then
					break
				end
			end
			tutorialWaiting = false
			if screenClear() then
				actions.startTutorial()
			end
		end)
	end

	-- ── the side panels, the menu, family names, lore, the mod menu ──
	function actions.openLorePanel()
		side:open("lore")
	end

	function actions.openCityPanel()
		side:open("city")
	end

	function actions.openStory()
		side:open("story")
	end

	function actions.openYouPanel()
		side:open("you")
	end
	function actions.openMorePanel()
		side:open("more")
	end
	function actions.openFamily()
		side:open("family")
	end

	function actions.openMenu()
		Settings.open(ctx, sheetColumn)
	end

	function actions.setSetting(key: string, value: any)
		local res = call("setSetting", { key = key, value = value })
		if res and res.meta then
			state.meta = res.meta
			applySettings(state.meta.settings)
		end
	end

	function actions.loadSurnames(after)
		local res = call("surnames")
		if res then
			state.surnames = res.surnames
			side:setSurnames(state.surnames)
			if after then
				after(res.surnames)
			end
		end
	end

	function actions.openSurnames()
		SurnameRoll.open(ctx, sheetColumn, state.surnames)
	end

	function actions.surnameRoll(after, premium: boolean?)
		local res = call("surnameRoll", { premium = premium == true })
		if res then
			state.surnames = res.surnames
			side:setSurnames(state.surnames)
			if res.kept then
				state.meta.surname = res.surnames.current
			end
		end
		after(res or { ok = false })
	end

	function actions.surnameKeep(keep: boolean, after)
		local res = call("surnameKeep", { keep = keep })
		if res then
			state.surnames = res.surnames
			state.meta.surname = res.surnames and res.surnames.current
			side:setSurnames(state.surnames)
			side:setMeta(state.meta)
		end
		after(res)
	end

	function actions.loadCodex(after)
		if codexCache then
			after(codexCache)
			return
		end
		local ok, res = pcall(function()
			return Request:InvokeServer("codex")
		end)
		if ok and type(res) == "table" and res.ok then
			codexCache = res.entries
			after(codexCache)
		end
	end

	function actions.openLore(id: string)
		actions.loadCodex(function(entries)
			local entry = entries[id]
			if not entry then
				return
			end
			local sheet = Sheets.open(sheetColumn, entry.title)
			if entry.secret then
				Kit.caps({ Text = "Secret", FontFace = F.type, TextSize = 13, TextColor3 = C.strange, LayoutOrder = 1, ZIndex = 2, Parent = sheet.content })
			end
			Kit.text({ Text = Format.escape(entry.text), FontFace = F.serif, TextSize = 15, TextColor3 = C.text, LayoutOrder = 2, ZIndex = 2, Parent = sheet.content })
			ctx.music("lore")
			task.spawn(function()
				while not sheet.isClosed() do
					task.wait(0.5)
				end
				updateScene()
			end)
		end)
	end

	local adminSheet = nil
	function actions.openAdmin()
		if state.isAdmin then
			-- (v0.17) the same key or button closes it again
			if adminSheet and adminSheet.isClosed and not adminSheet.isClosed() and adminSheet.close then
				adminSheet.close()
				adminSheet = nil
				return
			end
			adminSheet = AdminMenu.open(ctx, sheetColumn)
		end
	end

	-- (v0.17) QUICK ACCESS: a small bar at the top right, on every screen. STORE for everyone
	-- (when the store is open); MOD for admins, who also get F2 and the chat command /mod.
	do
		local quickGui = new("ScreenGui", {
			Name = "LifeSimQuickBar",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 40,
			Parent = playerGui,
		})
		local bar = new("Frame", {
			Name = "QuickBar",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 8),
			Size = UDim2.fromOffset(240, 32),
			Parent = quickGui,
		}, {
			new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		local function pill(name: string, text: string, color: Color3, order: number, onClick)
			local b = new("TextButton", {
				Name = name,
				AutoButtonColor = true,
				BackgroundColor3 = Color3.fromRGB(14, 12, 16),
				BackgroundTransparency = 0.1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = text,
				FontFace = Theme.fonts.display,
				TextSize = 14,
				TextColor3 = color,
				LayoutOrder = order,
				Parent = bar,
			}, { Kit.corner(16), Kit.stroke(color, 1.5, 0.15), Kit.padding(0, 14, 0, 14) })
			b.Activated:Connect(onClick)
			return b
		end
		if ctx.info and (ctx.info.storeOpen or (ctx.info.storeOpen == nil and not ctx.info.fanWork)) then
			pill("QuickStore", "STORE", Color3.fromRGB(255, 214, 120), 1, function()
				actions.openStore()
			end)
		end
		if state.isAdmin then
			pill("QuickMod", "MOD", C.crimsonHi, 2, function()
				actions.openAdmin()
			end)
			UserInputService.InputBegan:Connect(function(input, processed)
				if not processed and input.KeyCode == Enum.KeyCode.F2 then
					actions.openAdmin()
				end
			end)
			pcall(function()
				local cmd = Instance.new("TextChatCommand")
				cmd.Name = "LifeSimModMenu"
				cmd.PrimaryAlias = "/mod"
				cmd.SecondaryAlias = "/admin"
				cmd.Parent = TextChatService
				cmd.Triggered:Connect(function()
					actions.openAdmin()
				end)
			end)
		end
	end

	-- the mod menu talks to the server directly (it shouldn't wait behind a life action)
	function actions.adminCall(payload, after)
		local ok, res = pcall(function()
			if payload.op == "__state" then
				return Request:InvokeServer("adminState")
			end
			return Request:InvokeServer("admin", payload)
		end)
		after(if ok then res else nil)
	end

	function actions.continueHeir(id: number)
		local res = call("continueHeir", { id = id })
		if res then
			showScreen("hud")
			applyResponse(res)
		end
	end

	function actions.showNewLife()
		showScreen("newLife")
		newLifeScreen.refresh()
		ctx.music("creator")
	end

	function actions.releaseLantern(id: string, after)
		local res = call("releaseLantern", { id = id })
		if res then
			state.meta = res.meta
			toast(state.info.meta.releaseToast or "The lantern drifts out over the water.")
			if after then
				after()
			end
		end
	end

	function actions.unlockCosmetic(category: string, id: string, after)
		local res = call("unlockCosmetic", { category = category, id = id })
		if res then
			state.meta = res.meta
			sound("coin")
			if after then
				after()
			end
		end
	end

	-- a mode bought with Light (from the hub's Light tab)
	function actions.unlockMode(modeId: string, after)
		local res = call("unlockMode", { id = modeId })
		if res then
			state.meta = res.meta or state.meta
			side:setMeta(state.meta)
			if res.toast then
				Celebrate.banner(ctx, toastColumn, { title = "Unlocked", sub = res.toast, color = CELEBRATIONS.purchase.color })
			end
		end
		if after then
			after()
		end
	end

	function actions.unlockOrigin(id: string, after)
		local res = call("unlockOrigin", { id = id })
		if res then
			state.meta = res.meta
			if after then
				after()
			end
		end
	end

	-- ── live updates from the server (linked friends, invites) ──
	local invitePrompts = {}
	Push.OnClientEvent:Connect(function(payload)
		-- whatever arrived, a card it brought (or one it found closed) ends up on screen
		task.delay(0.4, ensureDecision)
		if type(payload) ~= "table" then
			return
		end
		if payload.toast then
			toast(payload.toast)
		end
		-- a whole response pushed to us (a crew age-up, a duel we started): play it like our own
		if payload.applyAll then
			task.spawn(applyResponse, payload)
			return
		end
		-- (v0.16) a crewmate is fighting a big boss: step in?
		if payload.battleInvite then
			local inv = payload.battleInvite
			Prompt.show(modalColumn, {
				title = "Join the fight?",
				text = string.format("%s is fighting %s. Every fighter chooses their own move, every turn.", tostring(inv.hostName or "Your crewmate"), tostring(inv.boss or "a boss")),
				buttons = {
					{ label = "Not this time", style = "ghost", onClick = function() end },
					{ label = "Join", style = "danger", onClick = function()
						task.spawn(function()
							local res = call("battleJoin", { host = inv.host })
							if res then
								applyResponse(res)
							end
						end)
					end },
				},
			})
		end
		-- (v0.17) a duel: the other side's move came in, or it's over
		if payload.duelDone then
			task.spawn(applyResponse, payload)
		elseif type(payload.duel) == "table" and payload.duel.me then
			openDuel(payload.duel)
		end
		-- (v0.16) a turn of a fight you're in, decided by someone else's move
		if payload.battleDone then
			task.spawn(finishBattle, payload.battleDone)
		elseif payload.battle == false then
			closeBattle()
		elseif type(payload.battle) == "table" and payload.battle.boss then
			openBattle(payload.battle)
		end
		if payload.duelInvite then
			local inv = payload.duelInvite
			Prompt.show(modalColumn, {
				title = if inv.rough then "A blood duel" else "A duel",
				text = string.format(
					"%s challenges you: %s%s.%s",
					inv.name,
					inv.character or "",
					if inv.style then " (" .. inv.style .. ")" else "",
					if inv.rough then "\nYou both play rough: it goes to the end. Yield in time, or the loser dies.\nFought in turns: you both choose every move." else "\nFirst real blood wins. Nobody dies.\nFought in turns: you both choose every move."
				),
				buttons = {
					{ label = "Decline", style = "ghost", onClick = function()
						task.spawn(call, "duelRespond", { userId = inv.userId, accept = false })
					end },
					{ label = "Fight", style = if inv.rough then "danger" else "primary", onClick = function()
						task.spawn(function()
							local res = call("duelRespond", { userId = inv.userId, accept = true })
							if res then
								showScreen("hud")
								applyResponse(res)
							end
						end)
					end },
				},
			})
		end
		if payload.world then
			local w = payload.world
			state.world = if w.ended then nil else w
			hud.setWorld(state.world)
			side:setWorld(state.world)
			Celebrate.banner(ctx, toastColumn, {
				title = if w.ended then (w.name .. " is over") else w.headline,
				sub = w.text,
				color = if w.ended then C.sub elseif w.tone == "danger" then C.crimsonHi else C.accentHi,
				hold = 3.2,
			})
			updateScene()
		end
		if payload.crew ~= nil then
			state.crew = payload.crew or nil
			hud:setCrewAge(state.crew and state.crew.age)
			if ctx.crewSheetRefresh then
				ctx.crewSheetRefresh()
			end
			if ctx.lobbyRefresh then
				ctx.lobbyRefresh()
			end
			-- the captain moved the run on: close the old stage card
			local run = runPending()
			local key = if run then tostring(run.id) .. ":" .. tostring(run.step) else nil
			if closeEvent and openRunKey and key ~= openRunKey then
				closeEvent()
				closeEvent = nil
				openRunKey = nil
			end
			updateScene()
		end
		if payload.crewInvite then
			local inv = payload.crewInvite
			Prompt.show(modalColumn, {
				title = "Join their lobby?",
				text = inv.name .. " wants you in. You'd start new lives together, and can run expeditions as a crew.",
				buttons = {
					{ label = "Not now", style = "ghost", onClick = function()
						task.spawn(actions.crewCall, "crewRespond", { userId = inv.userId, accept = false })
					end },
					{ label = "Join", style = "primary", onClick = function()
						task.spawn(function()
							actions.crewCall("crewRespond", { userId = inv.userId, accept = true }, function(res)
								-- their lobby is open: straight in (unless a life is in the way of it)
								local crew = res and res.crew
								if crew and crew.lobby and (currentScreen == "menu" or currentScreen == "lobby" or not (state.life and state.life.alive)) then
									actions.openLobby()
								elseif crew and crew.lobby then
									toast("You're in. The lobby is under Menu > With friends.")
								end
							end)
						end)
					end },
				},
			})
		end
		if payload.lobbyOpened and state.crew then
			-- someone in your crew opened the lobby
			if currentScreen == "menu" then
				task.spawn(actions.openLobby)
			else
				toast(tostring(payload.lobbyOpened.name or "Someone") .. " opened the lobby: Menu, then With friends.")
			end
		end
		if payload.readyCheck and state.crew and state.crew.proposal and not state.crew.proposal.youReady then
			local proposal = state.crew.proposal
			Prompt.show(modalColumn, {
				title = "Ready to set out?",
				text = "Your captain wants to go: " .. proposal.name .. ". " .. (proposal.desc or ""),
				buttons = {
					{ label = "Not ready", style = "ghost", onClick = function()
						task.spawn(actions.crewCall, "crewReady", { accept = false })
					end },
					{ label = "Ready", style = "primary", onClick = function()
						task.spawn(actions.crewCall, "crewReady", { accept = true })
					end },
				},
			})
		end
		if payload.celebrate and CELEBRATIONS[payload.celebrate] then
			Celebrate.banner(ctx, toastColumn, { title = CELEBRATIONS[payload.celebrate].title, sub = payload.toast, color = CELEBRATIONS[payload.celebrate].color })
		end
		if payload.clash then
			task.spawn(function()
				state.applying = true
				-- (v0.18) a fight that fails to play never leaves the screen thinking it's busy
				local okClash, errClash = pcall(playClash, payload.clash)
				state.applying = false
				if not okClash then
					warn("[LifeSim] clash failed: " .. tostring(errClash))
				end
				task.defer(ctx.actions.showDecision)
			end)
		end
		if payload.news then
			chatNews(payload.news.text, payload.news.tone)
		end
		if payload.holds then
			side:setHolds(payload.holds)
		end
		if payload.chronicle then
			side:addChronicle(payload.chronicle)
		end
		if payload.daily ~= nil then
			side:setDaily(payload.daily)
		end
		if payload.codexNew then
			loreFound(payload.codexNew)
		end
		if payload.together and payload.life then
			-- the host started everyone's lives: the lobby (or the crew sheet) goes away first
			state.together = false
			if lobbyView then
				lobbyView.destroy()
				lobbyView = nil
			end
			closeAllSheets()
			task.spawn(arrive, payload)
			return
		end
		if payload.invite and not invitePrompts[payload.invite.userId] then
			local inv = payload.invite
			invitePrompts[inv.userId] = true
			Prompt.show(modalColumn, {
				title = "Link lives?",
				text = inv.name .. " wants to link lives with you. Linked friends show up in each other's lives and can help each other out.",
				buttons = {
					{ label = "Not now", style = "ghost", onClick = function()
						invitePrompts[inv.userId] = nil
						task.spawn(actions.linkRespond, inv.userId, false)
					end },
					{ label = "Link", style = "primary", onClick = function()
						invitePrompts[inv.userId] = nil
						task.spawn(actions.linkRespond, inv.userId, true)
					end },
				},
			})
		end
		if payload.meta then
			state.meta = payload.meta
			side:setMeta(state.meta)
		end
		if payload.life and staleLife(payload.life) then
			payload.life = nil -- (v0.18) older than what this screen has: the rest of it still counts
		end
		if payload.life then
			state.life = payload.life
			if payload.entries then
				hud:appendEntries(payload.entries)
				celebrate(payload.entries)
			end
			hud:setLife(payload.life)
			side:setLife(payload.life)
			updateScene()
			askOfficeName()
			-- (v0.17) a fight that started from somewhere else (the mod menu)
			if type(payload.life.battle) == "table" and payload.life.battle.boss then
				openBattle(payload.life.battle)
			end
			if not payload.life.alive and payload.lantern then
				task.spawn(function()
					task.wait(1.2)
					showScreen("death")
					deathScreen.show(payload.lantern, payload.life)
				end)
			elseif payload.life.alive and not state.busy and not state.applying then
				-- something arrived that needs a decision (a world event, the next crew stage)
				if payload.life.pending then
					openEvent()
				elseif runPending() then
					actions.openRun()
				end
			end
		elseif payload.crew ~= nil and runPending() and not closeEvent then
			actions.openRun()
		end
	end)

	-- the daily streak, once the first screen is up
	if hello.daily then
		task.delay(1.5, function()
			Celebrate.daily(ctx, modalColumn, hello.daily)
		end)
	end

	-- ── initial screen ──
	if hello.life and hello.life.alive then
		side:setLife(hello.life)
	end
	local firstJoin = not (state.meta and state.meta.flags and state.meta.flags.seenIntro)
	local introPref = (state.meta and state.meta.settings and state.meta.settings.intro) or "short"
	if useTitle and (hello.life == nil or hello.life.alive) then
		-- (BitLeveling) the opening has played (client/OpeningCutscene): the title, then PLAY
		state.life = hello.life
		if hello.life then
			hud:resetLog(hello.log or {})
			hud:setLife(hello.life)
		end
		if firstJoin then
			task.spawn(call, "setFlag", { key = "seenIntro", value = true })
		end
		actions.showTitleMenu(false)
	elseif firstJoin then
		state.life = hello.life
		showScreen("menu")
		actions.playIntro(true)
	elseif introPref ~= "off" and (hello.life == nil or hello.life.alive) then
		-- every join: the title sting, then the mode select (Continue is on top)
		state.life = hello.life
		if hello.life then
			hud:resetLog(hello.log or {})
			hud:setLife(hello.life)
		end
		showScreen("menu")
		if introPref == "full" then
			actions.playIntro(true)
		else
			actions.playIntro(false, true)
		end
	elseif hello.life == nil then
		actions.showMenu()
	elseif hello.life.alive then
		state.life = hello.life
		showScreen("hud")
		hud:resetLog(hello.log or {})
		hud:setLife(hello.life)
		if hello.life.pending then
			openEvent()
		end
	else
		state.life = hello.life
		showScreen("death")
		if hello.lantern then
			deathScreen.show(hello.lantern, hello.life)
		else
			actions.showNewLife()
		end
	end
end

return App
