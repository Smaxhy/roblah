--[[
	THE BITLEVELING STUDIO PLUGIN: a "BitLeveling" toolbar button opens a panel with

	  GAME        install the game into this place, or update it (the plugin carries a copy)
	  MESH KIT    the Blender meshes (tools/blender): register an imported kit, or load it by id
	  PREVIEW     galleries in the editor: every monster, outfit preset, weapon, Gate
	  CHECKS      validate the content pack, simulate lives, right here in Studio
	  PLAY TEST   while the game runs: open a Gate, a Dungeon Break or a Red Gate, any rank
	  BRIDGE      let a terminal or an AI agent on this computer run Luau in Studio
	              (tools/studio_bridge/bridge.py)
	  LOG         what happened

	Everything that changes the place is one undo step (ChangeHistoryService).
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local Lib = script.Parent
local Install = require(Lib:WaitForChild("Install"))
local Previews = require(Lib:WaitForChild("Previews"))
local Checks = require(Lib:WaitForChild("Checks"))
local Kit = require(Lib:WaitForChild("Kit"))
local Bridge = require(Lib:WaitForChild("Bridge"))

local App = {}

local C = {
	bg = Color3.fromRGB(30, 32, 40),
	panel = Color3.fromRGB(40, 43, 54),
	button = Color3.fromRGB(58, 62, 80),
	accent = Color3.fromRGB(110, 150, 255),
	good = Color3.fromRGB(110, 210, 140),
	bad = Color3.fromRGB(255, 110, 110),
	text = Color3.fromRGB(230, 232, 240),
	sub = Color3.fromRGB(160, 164, 178),
}
local RANKS = { "E", "D", "C", "B", "A", "S" }

local function make(className: string, props: any, parent: Instance?): any
	local i = Instance.new(className)
	for k, v in props do
		(i :: any)[k] = v
	end
	if parent then
		i.Parent = parent
	end
	return i
end

local function recorded(name: string, fn: () -> ())
	local id = ChangeHistoryService:TryBeginRecording(name)
	local ok, err = pcall(fn)
	if id then
		ChangeHistoryService:FinishRecording(id, if ok then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel)
	end
	if not ok then
		error(err, 0)
	end
end

function App.start(plugin: Plugin, root: Instance)
	local bundled = root:FindFirstChild("LifeSimKit")
	local toolbar = plugin:CreateToolbar("BitLeveling")
	local button = toolbar:CreateButton("BitLeveling", "Install, preview, check and play-test BitLeveling", "rbxasset://textures/AnimationEditor/icon_checkmark.png")
	button.ClickableWhenViewportHidden = true
	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 340, 640, 280, 360)
	local widget = plugin:CreateDockWidgetPluginGuiAsync("BitLevelingStudio", info)
	widget.Title = "BitLeveling Studio"
	button.Click:Connect(function()
		widget.Enabled = not widget.Enabled
	end)
	widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		button:SetActive(widget.Enabled)
	end)
	App.build(widget, plugin, bundled)
end

-- the panel (separate from start so the tests can build it into any frame)
function App.build(container: Instance, plugin: any, bundled: Instance?): any
	local scroll = make("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.bg, BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6 }, container)
	make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
	make("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, scroll)
	local order = 0
	local function nextOrder()
		order += 1
		return order
	end
	local logLines: { string } = {}
	local logLabel: TextLabel
	local function log(text: string)
		table.insert(logLines, 1, os.date("%H:%M:%S") .. "  " .. text)
		while #logLines > 40 do
			table.remove(logLines)
		end
		if logLabel then
			logLabel.Text = table.concat(logLines, "\n")
		end
		print("[BitLeveling Studio] " .. text)
	end
	local function header(text: string)
		make("TextLabel", { LayoutOrder = nextOrder(), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = text, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C.accent, Font = Enum.Font.GothamBold, TextSize = 14 }, scroll)
	end
	local function note(text: string, color: Color3?): TextLabel
		return make("TextLabel", { LayoutOrder = nextOrder(), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = color or C.sub, Font = Enum.Font.Gotham, TextSize = 12 }, scroll)
	end
	local function row(): Frame
		local f = make("Frame", { LayoutOrder = nextOrder(), Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1 }, scroll)
		make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, f)
		return f
	end
	local function btn(parent: Instance, text: string, width: number, fn: () -> ()): TextButton
		local b = make("TextButton", { Size = UDim2.new(width, -4, 1, 0), BackgroundColor3 = C.button, Text = text, TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = true }, parent)
		make("UICorner", { CornerRadius = UDim.new(0, 4) }, b)
		b.Activated:Connect(function()
			local ok, err = pcall(fn)
			if not ok then
				log("Error: " .. tostring(err))
			end
		end)
		return b
	end

	local ui: any = {}
	local game_ = game

	-- ── GAME ──
	header("GAME")
	local gameStatus = note("")
	local function refreshGame()
		local st = Install.status(game_)
		if st.installed then
			gameStatus.Text = "Installed in ServerScriptService.LifeSimKit" .. (if st.version then " (" .. tostring(st.version) .. ")" else "") .. ". Press Play to run it."
			gameStatus.TextColor3 = C.good
		else
			gameStatus.Text = "Not installed in this place. Install puts the whole game in ServerScriptService."
			gameStatus.TextColor3 = C.sub
		end
	end
	local gr = row()
	ui.install = btn(gr, "Install / Update game", 1, function()
		if not bundled then
			log("This copy of the plugin has no game inside it. Rebuild it with tools/plugin/build_plugin.luau.")
			return
		end
		local res
		recorded("Install BitLeveling", function()
			res = Install.install(game_, bundled)
		end)
		log(if res.replaced then "Updated the game to " .. tostring(res.version) .. "." else "Installed the game (" .. tostring(res.version) .. "). Press Play.")
		refreshGame()
	end)
	refreshGame()

	-- ── MESH KIT ──
	header("MESH KIT (Blender)")
	local kitStatus = note("")
	local roles: { string } = {}
	local function loadRoles()
		Install.withShared(game_, bundled, function(shared)
			local lib = require(shared:WaitForChild("Hunter"):WaitForChild("MeshLibrary") :: ModuleScript) :: any
			roles = lib.ROLES
		end)
	end
	local function refreshKit()
		if #roles == 0 then
			pcall(loadRoles)
		end
		local st = Kit.status(game_, roles)
		if st.present then
			kitStatus.Text = string.format("In this place: %d of %d meshes.%s Monsters, weapons and gear use them.", st.found, #roles, if #st.missing > 0 then " Missing: " .. table.concat(st.missing, ", ", 1, math.min(#st.missing, 6)) .. "." else "")
			kitStatus.TextColor3 = if #st.missing == 0 then C.good else C.accent
		else
			kitStatus.Text = "Not in this place: everything is built from parts. Import tools/blender/out/kit.fbx (Home > Import 3D), select it, then Register."
			kitStatus.TextColor3 = C.sub
		end
	end
	local kr = row()
	btn(kr, "Register selected", 0.5, function()
		local sel = Selection:Get()
		if #sel == 0 then
			log("Select the model Studio's 3D Importer made from kit.fbx first.")
			return
		end
		local res
		recorded("Register BitLeveling mesh kit", function()
			res = Kit.register(game_, sel, roles)
		end)
		log(string.format("Mesh kit: %d of %d roles found in the selection.", res.found, #roles))
		refreshKit()
	end)
	local idBox = make("TextBox", { Size = UDim2.new(0.25, -4, 1, 0), BackgroundColor3 = C.panel, Text = "", PlaceholderText = "asset id", TextColor3 = C.text, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false }, kr)
	btn(kr, "Load by id", 0.25, function()
		local id = tonumber(idBox.Text)
		if not id then
			log("Type the kit's asset id (tools/blender/upload.py prints it).")
			return
		end
		local res
		recorded("Load BitLeveling mesh kit", function()
			res = Kit.loadAsset(game_, id, roles)
		end)
		log(string.format("Mesh kit %d loaded: %d of %d roles.", id, res.found, #roles))
		refreshKit()
	end)
	local kr2 = row()
	btn(kr2, "Remove kit (use parts)", 1, function()
		recorded("Remove BitLeveling mesh kit", function()
			Kit.remove(game_)
		end)
		log("Mesh kit removed: monsters, weapons and gear are parts again.")
		refreshKit()
	end)
	refreshKit()

	-- ── PREVIEW ──
	header("PREVIEW (in the editor)")
	note("Builds the galleries in Workspace.BitLevelingPreview in front of the camera, with the mesh kit if there is one.")
	local function gallery(what: string)
		local cam = workspace.CurrentCamera
		local at = if cam then (cam.CFrame * CFrame.new(0, 0, -60)).Position * Vector3.new(1, 0, 1) else nil
		local n = 0
		recorded("BitLeveling preview " .. what, function()
			local ok, res = Install.withShared(game_, bundled, function(shared, server, client)
				return Previews.build(game_, what, shared, server, client, at)
			end)
			if not ok then
				error(res, 0)
			end
			n = res
		end)
		log(string.format("Preview: %d %s.", n, what))
	end
	local pr = row()
	btn(pr, "Monsters", 0.25, function()
		gallery("monsters")
	end)
	btn(pr, "Outfits", 0.25, function()
		gallery("outfits")
	end)
	btn(pr, "Weapons", 0.25, function()
		gallery("weapons")
	end)
	btn(pr, "Gates", 0.25, function()
		gallery("gates")
	end)
	local pr2 = row()
	btn(pr2, "Accessories", 0.5, function()
		gallery("accessories")
	end)
	btn(pr2, "Clear previews", 0.5, function()
		recorded("Clear BitLeveling previews", function()
			Previews.clear(game_)
		end)
		log("Previews cleared.")
	end)

	-- ── CHECKS ──
	header("CHECKS")
	local cr = row()
	btn(cr, "Validate content", 0.5, function()
		local ok, res = Install.withShared(game_, bundled, function(shared)
			return Checks.validate(shared)
		end)
		if not ok then
			log("Validate failed to run: " .. tostring(res))
			return
		end
		log(string.format("%s: %d cards, %d errors, %d warnings.", tostring(res.title), res.events, #res.errors, #res.warnings))
		for i = 1, math.min(8, #res.errors) do
			log("  ERROR " .. tostring(res.errors[i]))
		end
	end)
	btn(cr, "Simulate 20 lives", 0.5, function()
		log("Simulating 20 lives...")
		local ok, res = Install.withShared(game_, bundled, function(shared)
			return Checks.simulate(shared, 20, function()
				task.wait()
			end)
		end)
		if not ok then
			log("Simulation failed: " .. tostring(res))
			return
		end
		local top = {}
		for i = 1, math.min(5, #res.fates) do
			table.insert(top, res.fates[i].id .. " " .. res.fates[i].n)
		end
		log(string.format("%d lives: median age %d, %d awakened, %d crashed. Fates: %s", res.lives, res.median, res.awakened, #res.crashes, table.concat(top, ", ")))
		for i = 1, math.min(3, #res.crashes) do
			log("  CRASH " .. res.crashes[i])
		end
	end)

	-- ── PLAY TEST ──
	header("PLAY TEST (while the game runs)")
	note("Press Play (or Run), switch to the Server view, then open one at the nearest free site.")
	local rank = 3
	local tr = row()
	local rankBtn
	rankBtn = btn(tr, "Rank: C", 0.25, function()
		rank = rank % 6 + 1
		rankBtn.Text = "Rank: " .. RANKS[rank]
	end)
	local function spawn(kind: string?, breaks: boolean?)
		local fn = ServerStorage:FindFirstChild("BitLevelingStudio")
		if not (RunService:IsRunning() and RunService:IsServer() and fn and fn:IsA("BindableFunction")) then
			log("Play test: run the game and switch to the Server view first.")
			return
		end
		local res = fn:Invoke("spawn", { rank = rank, kind = kind, breaks = breaks })
		log("Play test: " .. tostring(res and (res.toast or res.error) or "no answer"))
	end
	btn(tr, "Gate", 0.25, function()
		spawn(nil, false)
	end)
	btn(tr, "Break", 0.25, function()
		spawn(nil, true)
	end)
	btn(tr, "Red Gate", 0.25, function()
		spawn("red", false)
	end)

	-- ── BRIDGE ──
	header("BRIDGE (terminal / AI on this computer)")
	note("Run  python3 tools/studio_bridge/bridge.py serve  then Connect. Anything on this computer can then run Luau here: bridge.py run \"print(1)\". Studio's own MCP server (Assistant > Manage MCP Servers) is the other way to connect an AI tool.")
	local bridgeState = note("Off.")
	local br = row()
	local portBox = make("TextBox", { Size = UDim2.new(0.3, -4, 1, 0), BackgroundColor3 = C.panel, Text = "28754", TextColor3 = C.text, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false }, br)
	local connected = false
	local connectBtn
	connectBtn = btn(br, "Connect", 0.7, function()
		if connected then
			Bridge.stop()
			connected = false
			connectBtn.Text = "Connect"
			bridgeState.Text = "Off."
			log("Bridge off.")
			return
		end
		connected = true
		connectBtn.Text = "Disconnect"
		Bridge.start(tonumber(portBox.Text) or 28754, log, function(state)
			bridgeState.Text = "Bridge: " .. state
		end)
	end)

	-- ── LOG ──
	header("LOG")
	logLabel = make("TextLabel", { LayoutOrder = nextOrder(), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.panel, Text = "", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = C.text, Font = Enum.Font.Code, TextSize = 11 }, scroll)
	make("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, logLabel)
	log("Ready." .. (if bundled then " Carrying " .. tostring(bundled:GetAttribute("BitLevelingVersion") or "the game") .. "." else ""))

	ui.log = log
	ui.refreshGame = refreshGame
	ui.refreshKit = refreshKit
	local _ = plugin
	return ui
end

return App
