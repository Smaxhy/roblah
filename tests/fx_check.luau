--[[
	The 3D stage and its effects (v0.18), on the real client in the harness:
	  - every Fx3D effect plays on an open stage without an error, and the particle ones emit
	  - the stage hides the HUD while it's up; closing it gives back the HUD, the camera and the
	    lighting it borrowed, and leaves nothing in the Workspace
	  - an Arena opens with you and a training dummy, and every move it has plays
	  - "3D fight effects: Lite" emits fewer particles; "Off" keeps the flat fight screens
	  - head parts (every hair style) are tagged as the head's, so they never swing with an
	    arm or a leg when someone walks
		lune run tests/fx_check
]]

local process = require("@lune/process")
local roblox = require("@lune/roblox")
local Harness = require("./harness")
local vtask = Harness.task
local Vector3, Color3 = roblox.Vector3, roblox.Color3

local DEVICE = { name = "pc", width = 1440, height = 900, inset = 58, touch = false, keyboard = true, mouse = true }
local h = Harness.boot(DEVICE, { seed = 11 })
-- what the client's own code gets from Instance.new (the harness's wrapped instances)
local Instance = h.Loader.globals.Instance

local failures = {}
local function check(cond, msg: string)
	if not cond then
		table.insert(failures, msg)
		print("  FAIL  " .. msg)
	end
end

local function wait(seconds: number)
	local stop = h.now() + seconds
	vtask.wait(seconds)
	while h.now() < stop - 1e-6 do
		vtask.wait(stop - h.now())
	end
end

-- what an effect put on the stage: run it, give it a moment (some parts of an effect come a
-- beat later), then count what's new and the particles it asked for (Fx3D counts every Emit
-- on its emitter, as LifeSimEmitted). What was there before is marked first, so effects
-- that finish meanwhile don't skew the count.
local function measure(root: Instance, fn, settle: number?): (boolean, any, number, number)
	for _, d in root:GetDescendants() do
		d:SetAttribute("FxOld", true)
	end
	local ok, err = pcall(fn)
	wait(settle or 0.2)
	local parts, particles = 0, 0
	for _, d in root:GetDescendants() do
		if not d:GetAttribute("FxOld") then
			parts += 1
			if d:IsA("ParticleEmitter") then
				particles += (d:GetAttribute("LifeSimEmitted") or 0) :: number
			end
		end
	end
	return ok, err, parts, particles
end

local LIGHT = { "ClockTime", "Brightness", "Ambient", "OutdoorAmbient", "ExposureCompensation", "FogEnd", "FogStart", "FogColor" }
local function lightOf(lighting: Instance)
	local out = {}
	for _, k in LIGHT do
		local ok, v = pcall(function()
			return (lighting :: any)[k]
		end)
		if ok then
			out[k] = v
		end
	end
	return out
end

local notes: { string } = {}
local finished = false
local function driver()
	local Server = h.require(h.serverRoot)
	Server.start()
	local App = h.require(h.clientRoot.App)
	App.start()
	local ctx = App.ctx
	wait(1)
	check(ctx and ctx.state and ctx.state.info ~= nil, "the app didn't say hello to the server")
	ctx.actions.setSetting("cutscenes", "off")
	ctx.actions.newLife("backstreets_family", "Petra", nil, nil, { mode = "fixer" })
	wait(2)
	local life = ctx.state.life
	check(life and life.appearance ~= nil, "no life with a look to put on the stage")

	local World3D = h.require(h.clientRoot.UI.World3D)
	local Fx3D = h.require(h.clientRoot.UI.Fx3D)
	local Arena = h.require(h.clientRoot.UI.Arena)
	local Stage = h.require(h.clientRoot.UI.Stage)
	local Avatar = h.require(h.sharedRoot.Engine.Avatar)
	local ws = h.dm:GetService("Workspace")
	local lighting = h.dm:GetService("Lighting")
	local pg = h.realPlayerGui
	local main = pg:FindFirstChild("LifeSimMain")
	check(main ~= nil and main.Enabled, "no HUD layer to hide")

	-- ── the stage opens, hides the HUD, and gives everything back when it closes ──
	check(World3D.available(ctx), "the 3D stage should be available with the default setting")
	local lightBefore = lightOf(lighting)
	local cam = ws.CurrentCamera
	local camType = cam and cam.CameraType
	local w = World3D.open(ctx, ctx.cinemaLayer, { mood = "night" })
	check(w ~= nil, "World3D.open gave nothing")
	if w then
		check(ws:FindFirstChild("LifeSimWorld3D") ~= nil, "the stage's folder isn't in the Workspace")
		check(main and not main.Enabled, "the HUD should step aside while the stage is up")

		-- every effect, at the middle of the stage
		local at = Vector3.new(0, 3, 0)
		local effects = {
			{ "impact", function() Fx3D.impact(w, at, {}) end, true },
			{ "impact heavy", function() Fx3D.impact(w, at, { heavy = true }) end, true },
			{ "slash", function() Fx3D.slash(w, at + Vector3.new(-3, 1, 0), at, {}) end, true },
			{ "slash crit", function() Fx3D.slash(w, at + Vector3.new(-3, 1, 0), at, { heavy = true, status = "burn" }) end, true },
			{ "lightning", function() Fx3D.lightning(w, at + Vector3.new(-4, 2, 0), at, nil) end, false },
			{ "heal", function() Fx3D.heal(w, at, {}) end, true },
			{ "guard", function() Fx3D.guard(w, at, nil) end, false },
			{ "dust", function() Fx3D.dust(w, Vector3.new(0, 0, 0)) end, true },
			{ "anticipate", function() Fx3D.anticipate(w, at, nil) end, false },
			{ "phase", function() Fx3D.phase(w, at, nil, {}) end, true },
			{ "ko", function() Fx3D.ko(w, at, nil) end, true },
			{ "victory", function() Fx3D.victory(w, at, nil) end, true },
		}
		for id in Fx3D.STATUS do
			-- (charge is drawn as lightning: Neon segments, no particles)
			table.insert(effects, { "status " .. id, function() Fx3D.status(w, at, id, { floor = 0 }) end, id ~= "charge" })
		end
		local played = 0
		for _, e in effects do
			local ok, err, parts, particles = measure(w.folder, e[2])
			check(ok, "Fx3D " .. e[1] .. " failed: " .. tostring(err))
			if ok then
				check(parts > 0, "Fx3D " .. e[1] .. " put nothing on the stage")
				if e[3] then
					check(particles > 0, "Fx3D " .. e[1] .. " emitted nothing")
				end
			end
			played += 1
		end
		-- an aura follows someone and stops cleanly
		local okA, aura = pcall(Fx3D.aura, w, Color3.fromRGB(255, 80, 80), "fire")
		check(okA and aura ~= nil, "Fx3D.aura failed: " .. tostring(aura))
		if okA and aura then
			pcall(aura.move, Vector3.new(1, 0, 0))
			wait(0.3)
			check(pcall(aura.stop), "an aura didn't stop")
		end
		-- the camera's moves
		for _, kind in { "light", "medium", "heavy", "huge" } do
			check(pcall(w.shake, w, kind), "the stage couldn't shake (" .. kind .. ")")
		end
		check(pcall(w.punch, w, 4), "the stage couldn't punch the camera in")

		-- Lite: fewer particles for the same hit
		Fx3D.setQuality("full")
		local _, _, _, full = measure(w.folder, function()
			Fx3D.impact(w, at, { heavy = true })
		end, 0.3)
		Fx3D.setQuality("lite")
		local _, _, _, lite = measure(w.folder, function()
			Fx3D.impact(w, at, { heavy = true })
		end, 0.3)
		Fx3D.setQuality("full")
		check(full > 0 and lite < full, string.format("Lite should emit fewer particles than Full (%d vs %d)", lite, full))

		wait(2)
		w:close()
		wait(0.5)
		check(ws:FindFirstChild("LifeSimWorld3D") == nil, "the stage left its folder in the Workspace")
		check(main and main.Enabled, "the HUD didn't come back after the stage closed")
		local lightAfter = lightOf(lighting)
		for k, v in lightBefore do
			check(lightAfter[k] == v, "the stage didn't give back Lighting." .. k)
		end
		if cam then
			check(cam.CameraType == camType, "the stage didn't give back the camera type")
		end
		table.insert(notes, string.format("stage: %d effects played on an open stage (and an aura, the shakes, a punch); a heavy hit is %d particles on Full and %d on Lite; closing gave back the HUD, the camera and the lighting", played, full, lite))
	end

	-- ── an Arena with you and a training dummy, every move ──
	local holder = Instance.new("Frame")
	holder.Parent = ctx.cinemaLayer
	local okO, arena = pcall(Arena.open, ctx, holder, {
		set = "gym",
		time = "night",
		seed = "fx_check",
		left = { { key = "me", name = "Petra", appearance = life and life.appearance, me = true } },
		right = { { key = "dummy", name = "Training dummy", dummy = true } },
	})
	check(okO and arena ~= nil, "the Arena didn't open: " .. tostring(arena))
	if okO and arena then
		check(arena:actor("me") ~= nil and arena:actor("dummy") ~= nil, "the Arena is missing someone")
		local moves = {
			{ "strike", function() arena:strike("me", "dummy", {}) end },
			{ "strike heavy", function() arena:strike("me", "dummy", { heavy = true }) end },
			{ "strike crit", function() arena:strike("me", "dummy", { crit = true, status = "bleed" }) end },
			{ "strike back", function() arena:strike("dummy", "me", { status = "tremor" }) end },
			{ "clash", function() arena:clash("me", "dummy") end },
			{ "guard", function() arena:guard("me") end },
			{ "heal", function() arena:heal("me") end },
			{ "status", function() arena:status("dummy", "rupture") end },
			{ "phase", function() arena:phase("dummy", nil) end },
			{ "kneel", function() arena:kneel("me") end },
			{ "down", function() arena:down("dummy") end },
			{ "victory", function() arena:victory("me", nil) end },
		}
		for _, m in moves do
			local ok, err = pcall(m[2])
			check(ok, "Arena " .. m[1] .. " failed: " .. tostring(err))
			wait(0.7)
		end
		local p = arena:screenPos("me")
		check(p ~= nil, "the Arena can't say where you are on screen")
		check(pcall(arena.close, arena), "the Arena didn't close")
		wait(0.5)
		check(ws:FindFirstChild("LifeSimWorld3D") == nil, "the Arena left its stage in the Workspace")
		check(main and main.Enabled, "the HUD didn't come back after the Arena")
		table.insert(notes, string.format("arena: you and a training dummy in the gym; all %d moves played and it closed clean", #moves))
	end
	holder:Destroy()

	-- ── "3D fight effects: Off" keeps the flat screens ──
	ctx.actions.setSetting("vfx", "flat")
	wait(0.6)
	local s = ctx.state.meta and ctx.state.meta.settings
	check(s and s.vfx == "flat", "the server didn't keep the vfx setting")
	check(not World3D.available(ctx), "with 3D effects Off there should be no stage")
	local okF, none = pcall(Arena.open, ctx, ctx.cinemaLayer, { set = "gym" })
	check(okF and none == nil, "with 3D effects Off the Arena shouldn't open")
	ctx.actions.setSetting("vfx", "lite")
	wait(0.6)
	check(World3D.available(ctx) and Fx3D.scale < 1, "Lite should keep the stage with fewer particles")
	ctx.actions.setSetting("vfx", "nonsense")
	wait(0.6)
	s = ctx.state.meta and ctx.state.meta.settings
	check(s and s.vfx == "lite", "the server took a vfx setting that isn't one")
	ctx.actions.setSetting("vfx", "full")
	wait(0.6)
	check(Fx3D.scale == 1, "Full should put every particle back")
	table.insert(notes, "settings: Off has no stage (the flat screens), Lite keeps it with fewer particles, Full puts them back; the server refused a made-up value")

	-- ── every place to fight builds (v0.18: 27 of them) ──
	local ids = Stage.setIds()
	check(#ids >= 27, "there should be at least 27 places to fight (" .. #ids .. ")")
	local smallest, smallestId = math.huge, nil
	for _, id in ids do
		local m = Instance.new("Model")
		local okB, errB = pcall(Stage.buildSet, m, id, "night", nil, id)
		check(okB, "the " .. id .. " set failed to build: " .. tostring(errB))
		local n = #m:GetChildren()
		if n < smallest then
			smallest, smallestId = n, id
		end
		m:Destroy()
	end
	check(smallest >= 12, string.format("the %s set is too bare (%d parts)", tostring(smallestId), smallest))
	-- street fights are spread over many places, and the same fight keeps its place
	local seen = {}
	for i = 1, 60 do
		seen[Stage.fightSet("street", nil, "Thug " .. i .. ":24")] = true
	end
	local kinds = 0
	for _ in seen do
		kinds += 1
	end
	check(kinds >= 8, "street fights should land in many places (" .. kinds .. ")")
	check(Stage.fightSet("alley", nil, "Rat:19") == Stage.fightSet("alley", nil, "Rat:19"), "the same fight should keep its place")
	check(Stage.fightSet("office", nil, "x") == "office" and Stage.fightSet("lcorp", nil, "x") == "facility", "a named place stays itself")
	table.insert(notes, string.format("places: %d sets build (the barest has %d parts); 60 street fights landed in %d different places", #ids, smallest, kinds))

	-- ── (v0.18) a boss walks in: the boss intro plays on its own ground, without a warning ──
	do
		local before = #h.errors
		local boss = { id = "thumb_capo_boss", name = "A Thumb Capo", title = "Capo IIII", phases = 3, enemy = { id = "thumb_capo", name = "Thumb Capo", look = { skin = "peach", hair = "slick", hairColor = "ink", eyes = "dark", outfit = "thumb_suit", accessory = "fedora", weapon = "thumb_rifle" }, barks = { start = { "Manners first." } } } }
		local done = false
		local started = h.now()
		vtask.spawn(function()
			Stage.bossIntro(ctx, ctx.cinemaLayer, boss, { kicker = "District 16" })
			done = true
		end)
		local spins = 0
		while not done and spins < 400 do
			wait(0.1)
			spins += 1
		end
		local took = h.now() - started
		local warned = {}
		for i = before + 1, #h.errors do
			table.insert(warned, h.errors[i])
		end
		check(done, "the boss intro never finished")
		check(#warned == 0, "the boss intro warned: " .. table.concat(warned, " | "))
		check(took > 3, string.format("the boss intro should take a few seconds (took %.1f)", took))
		check(ws:FindFirstChild("LifeSimWorld3D") == nil, "the boss intro left its stage in the Workspace")
		table.insert(notes, string.format("boss intro: %.1f s on its own ground, no warnings", took))
	end

	-- ── no hair style swings with an arm or a leg ──
	local cat = Avatar.category(ctx.info.avatar, "hair")
	local styles, swinging = 0, {}
	local model = Instance.new("Model")
	for _, o in (cat and cat.options) or {} do
		local app = table.clone(life.appearance)
		app.look = table.clone(app.look or {})
		app.look.hair = o.id
		local ok, actor = pcall(Stage.newActor, ctx, model, app and { appearance = app, name = "Petra" })
		if ok and actor then
			styles += 1
			for _, p in actor.parts do
				local name = p.part.Name
				if string.find(name, "Hair", 1, true) and p.group ~= "body" then
					table.insert(swinging, o.id .. " (" .. name .. " in " .. tostring(p.group) .. ")")
				end
			end
			pcall(function()
				actor.model:Destroy()
			end)
		end
	end
	model:Destroy()
	check(styles > 10, "too few hair styles built (" .. styles .. ")")
	check(#swinging == 0, "hair that swings with a limb: " .. table.concat(swinging, ", "))
	table.insert(notes, string.format("hair: %d styles built on a stage figure; every hair part stays with the head", styles))

	finished = true
end

Harness.run(driver, h, nil, 600)
for _, line in notes do
	print(line)
end
if not finished then
	check(false, "the test did not run to its end")
	for _, e in h.errors do
		print("    " .. string.sub(tostring(e), 1, 400))
	end
end
if #failures > 0 then
	print(string.format("\n%d fx checks failed.", #failures))
	process.exit(1)
end
print("OK")
