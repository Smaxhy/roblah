--[[
	UI SOUNDS (BitLeveling): every button in every GUI clicks, by itself, and the app has a set
	of named sounds for everything else a screen does.

		UiSounds.start()                -- (init.client) watch PlayerGui: every GuiButton there now
		                                   or added later clicks when pressed and ticks softly on
		                                   hover (not on touch screens: there's no hover there)
		UiSounds.play("purchase")       -- a named sound (the list below)
		UiSounds.hook(button)           -- a button somewhere else (a SurfaceGui on a part)
		local spin = UiSounds.spin(2.4) -- a roll: ticks that slow down, then the win sting
		spin:stop(false)                --   (stop it early; false: no sting)

	A button picks its own sounds with attributes:
		UiSound = "confirm"   what pressing it plays (any name below); "none" (or false) = silent
		UiHover = "tile"      what hovering it plays; "none" = silent
		Disabled = true       pressing it plays "deny" (a greyed-out button)
	and a whole panel can opt out: UiSoundsOff = true on any ancestor of its buttons (a screen
	that plays its own sound for every press, like the clash screen).
	A button whose press plays an app sound of its own (the app's sound("confirm")) isn't
	clicked over: the click waits a moment and only plays if nothing else did for that press.

	The named sounds:
		click hover tile select slider back open close tab confirm purchase deny error toast
		notify notifyLow rankUp tick spinWin ending unlock play begin card letter slam shimmer
		whoosh equip pickup sell pop
	and the app's own older names, layered (Sfx.play("confirm") anywhere plays these):
		click confirm tab transition reroll intro resonance bossStart death defeat shatter ego

	Every one is built from the sources in Config.sfx, Roblox's own interface sounds first (see
	docs/SFX.md for each id); a source that can't load just leaves its layer out.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Sfx = require(script.Parent:WaitForChild("Sfx"))

local UiSounds = {}

local function L(src: string, vol: number, pitch: any, extra: any?): any
	local l = extra or {}
	l.src = src
	l.vol = vol
	l.pitch = pitch
	return l
end
-- one of several sources, picked fresh every time
local function A(srcs: { string }, vol: number, pitch: any, extra: any?): any
	local list = {}
	for _, s in srcs do
		local l = table.clone(extra or {})
		table.insert(list, L(s, vol, pitch, l))
	end
	return { any = list }
end

local HOVERS = { "ui_hover1", "ui_hover2", "ui_hover3" }
local WHOOSHES = { "ui_whoosh1", "ui_whoosh2", "ui_whoosh3", "ui_whoosh4" }

-- ── the cues ────────────────────────────────────────────────────────────────
local CUES: { [string]: any } = {
	-- pressing and pointing
	click = { layers = { A({ "ui_click", "ui_click2" }, 0.34, { 0.97, 1.05 }) } },
	hover = { layers = { A(HOVERS, 0.12, { 0.98, 1.04 }) }, gap = 0.05 },
	tile = { layers = { A(HOVERS, 0.16, { 1, 1.06 }), L("ho_bell", 0.025, { 1.9, 2.1 }, { len = 0.3, fade = 0.2, chance = 0.5 }) }, gap = 0.05 },
	select = { layers = { L("ui_select2", 0.34, { 0.98, 1.03 }), L("ui_click", 0.1, 1.2) } },
	slider = { layers = { L("eng_slider", 0.3, { 0.95, 1.1 }) }, gap = 0.03 },
	back = { layers = { A({ "ui_back", "ui_back2" }, 0.32, { 0.98, 1.02 }) } },
	-- sheets and tabs
	open = { layers = { A({ "ui_swipe", "ui_swipe2" }, 0.3, { 1, 1.08 }), L("ui_sweep", 0.08, 1.15, { chance = 0.5 }) } },
	close = { layers = { L("ui_paper", 0.3, { 0.95, 1.02 }), L("ui_back", 0.08, 1.1, { delay = 0.03 }) } },
	tab = { layers = { L("ui_tab", 0.32, { 0.98, 1.04 }) } },
	-- yes, no, done
	confirm = { layers = { L("ui_select", 0.34, { 0.99, 1.02 }), L("rb_checkpoint", 0.07, { 1.45, 1.5 }, { len = 0.5, fade = 0.3 }) } },
	purchase = { layers = { A({ "ui_purchase", "ui_purchase2" }, 0.38, { 0.99, 1.01 }), L("ui_coins", 0.15, 1.05, { delay = 0.05, len = 1, fade = 0.4 }) } },
	deny = { layers = { L("ui_negative", 0.36, { 0.98, 1.02 }) } },
	error = { layers = { L("ui_delete", 0.32, 0.9), L("ui_negative", 0.2, 0.8, { delay = 0.08 }) } },
	-- things that arrive
	toast = { layers = { L("ui_toast", 0.26, { 0.99, 1.02 }, { len = 1.4, fade = 0.5 }) } },
	notify = { layers = { L("ui_notify", 0.32, 1, { len = 1.8, fade = 0.5 }) } },
	notifyLow = { layers = { L("ui_notifyLow", 0.3, 1, { len = 2, fade = 0.6 }) } },
	rankUp = { layers = {
		L("ui_aura", 0.38, 1),
		L("mg_powerup", 0.22, 1, { delay = 0.05 }),
		L("mg_deepboom", 0.18, 1.2, { len = 1.2, fade = 0.6 }),
		L("ho_tree", 0.18, 1.1, { delay = 0.3, len = 2.2, fade = 1 }),
	}, duck = { 0.5, 1.6 } },
	ending = { layers = {
		L("mg_stinger", 0.3, 0.9, { len = 3, fade = 1.5 }),
		L("he_shimmer", 0.16, 0.85, { attack = 0.4, len = 3.2, fade = 1.6 }),
		L("ct_gong", 0.12, 1.2, { delay = 0.1, len = 3, fade = 1.5 }),
	}, duck = { 0.6, 3 }, prio = 3 },
	unlock = { layers = { L("ui_stinger", 0.32, 1), L("ho_tree", 0.14, 1.2, { delay = 0.1, len = 1.6, fade = 0.8 }) } },
	-- rolls and spins
	tick = { layers = { A({ "ui_tick", "ui_tick2" }, 0.26, { 1, 1.12 }, { len = 0.12, fade = 0.03 }) }, gap = 0.02 },
	spinWin = { layers = {
		L("rb_victory", 0.3, 1),
		L("ui_stinger", 0.28, 1, { delay = 0.02 }),
		L("ho_tree", 0.14, 1.2, { delay = 0.15, len = 1.6, fade = 0.8 }),
	}, duck = { 0.55, 1.2 } },
	-- the title and the opening
	play = { layers = {
		L("gt_open", 0.42, { 0.95, 1 }),
		L("ui_sweep", 0.2, 0.9),
		L("ho_bell", 0.14, 1, { delay = 0.12, len = 1.2, fade = 0.6 }),
		L("mg_deepboom", 0.24, 0.9, { delay = 0.15, len = 2, fade = 1 }),
	}, duck = { 0.6, 1.2 } },
	begin = { layers = {
		L("ui_select", 0.32, 0.92),
		L("mg_rise2", 0.3, 1),
		L("mg_deepboom", 0.3, 0.85, { delay = 0.55, len = 2.2, fade = 1.1 }),
		L("ho_chimes2", 0.16, 1, { delay = 0.55, len = 2, fade = 1 }),
	}, duck = { 0.5, 1.5 } },
	card = { layers = { A(WHOOSHES, 0.3, { 0.95, 1.05 }), L("ui_click2", 0.1, 0.8, { delay = 0.32 }) } },
	letter = { layers = { L("bl_boxing", 0.22, { 1.5, 1.7 }, { len = 0.25, fade = 0.1 }), L("ui_tick", 0.12, { 0.8, 0.9 }) }, gap = 0.02 },
	slam = { layers = {
		L("mg_deepboom", 0.6, 0.9, { len = 2.6, fade = 1.3 }),
		L("ct_gong", 0.3, 0.8, { delay = 0.05, len = 5, fade = 2.5 }),
		L("gt_open", 0.3, 0.8),
		L("wi_sonic", 0.22, 1.1, { len = 1.6, fade = 1 }),
	}, duck = { 0.45, 2.2 }, prio = 3 },
	shimmer = { layers = { L("he_fall", 0.22, 1.25, { len = 1.6, fade = 0.8 }), L("ho_tree", 0.12, 1.3, { len = 1.6, fade = 0.8 }) } },
	whoosh = { layers = { A(WHOOSHES, 0.28, { 0.9, 1.05 }) } },
	equip = { layers = { L("ui_equip", 0.32, { 0.98, 1.03 }) } },
	pickup = { layers = { L("ui_pickup", 0.32, { 0.98, 1.05 }), L("ct_crystal", 0.1, 1.2, { delay = 0.04 }) } },
	sell = { layers = { L("ui_coins", 0.3, 1, { len = 1.4, fade = 0.4 }) } },
	pop = { layers = { L("ui_pop", 0.3, { 0.98, 1.04 }) } },
	-- ── the app's older names, layered ──
	transition = { layers = { L("ui_sweep", 0.3, { 0.95, 1.05 }), A(WHOOSHES, 0.12, { 0.8, 0.9 }, { delay = 0.05 }) } },
	reroll = { layers = {
		L("ui_tally", 0.3, { 1, 1.06 }, { len = 1.4, fade = 0.4 }),
		L("ui_tick", 0.15, 1.2, { rep = 5, gap = 0.05, pitchStep = 1.04, repFall = 0.95 }),
	} },
	intro = { layers = { L("mg_deepboom", 0.4, 0.95, { len = 2.4, fade = 1.2 }), L("he_fall", 0.15, 0.8, { delay = 0.15, len = 2, fade = 1 }) } },
	resonance = { layers = { L("ui_aura", 0.34, { 0.9, 0.95 }), L("ho_chimes1", 0.14, 0.9, { delay = 0.05 }) } },
	bossStart = { layers = {
		L("ct_gong", 0.34, 0.8, { len = 4, fade = 2 }),
		L("mg_deepboom", 0.42, 0.8, { len = 2.5, fade = 1.2 }),
		L("mo_crabRoar", 0.22, 0.7, { delay = 0.25, len = 2.4, fade = 1 }),
		L("mg_warp", 0.2, 0.9),
	}, duck = { 0.4, 1.8 }, prio = 3 },
	death = { layers = { L("he_fall", 0.32, 0.75, { len = 3.6, fade = 1.8 }), L("ct_gong", 0.16, 0.6, { delay = 0.2, len = 4, fade = 2 }) }, prio = 3 },
	defeat = { layers = { L("mg_rumbledecay", 0.32, 0.9, { len = 3.5, fade = 1.5 }), L("ui_negative", 0.18, 0.7) }, prio = 2 },
	shatter = { layers = { L("gt_glass", 0.3, { 1.1, 1.2 }, { len = 1.6, fade = 0.6 }), L("ac_poof1", 0.14, 0.9) } },
	ego = { layers = { L("ac_transform", 0.34, 0.9), L("vo_reverse", 0.22, 0.8), L("mg_deepboom", 0.2, 1.1, { len = 1.5, fade = 0.8 }) } },
}
UiSounds.CUES = CUES

-- the app's own names that UiSounds plays layered (Sfx.play(name) anywhere)
UiSounds.OVERRIDES = { "click", "confirm", "tab", "transition", "reroll", "intro", "resonance", "bossStart", "death", "defeat", "shatter", "ego" }

local started = false
local hooked = setmetatable({}, { __mode = "k" })
local lastHover = 0
UiSounds.presses = 0 -- (tests read these)
UiSounds.hovers = 0
UiSounds.played = {} :: { string }
local defer = (task :: any).defer or function(f: () -> ())
	f()
end

function UiSounds.has(name: string): boolean
	return CUES[name] ~= nil
end

function UiSounds.play(name: string, opts: any?)
	local cue = CUES[name]
	if not cue then
		-- not one of ours: the app's own sound by that name, if there is one
		pcall(Sfx.play, name, opts)
		return
	end
	local o = table.clone(opts or {})
	o.bus = "ui"
	o.name = name
	table.insert(UiSounds.played, name)
	if #UiSounds.played > 64 then
		table.remove(UiSounds.played, 1)
	end
	pcall(Sfx.recipe, cue, o.at, o)
end

local function attr(b: Instance, key: string): any
	local ok, v = pcall(function()
		return b:GetAttribute(key)
	end)
	return if ok then v else nil
end

-- a panel that opted all its buttons out (UiSoundsOff on an ancestor)
local function quietPanel(b: Instance): boolean
	local ok, quiet = pcall(function()
		local p = b.Parent
		while p do
			if p:GetAttribute("UiSoundsOff") == true then
				return true
			end
			if p:IsA("LayerCollector") then
				return false
			end
			p = p.Parent
		end
		return false
	end)
	return ok and quiet == true
end

local function touchOnly(): boolean
	local ok, yes = pcall(function()
		return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
	end)
	return ok and yes == true
end

local function silent(v: any): boolean
	return v == "none" or v == "" or v == false
end

local function pressed(b: Instance)
	local cue = attr(b, "UiSound")
	if silent(cue) or quietPanel(b) then
		return
	end
	UiSounds.presses += 1
	if attr(b, "Disabled") == true then
		UiSounds.play("deny")
		return
	end
	if type(cue) == "string" then
		UiSounds.play(cue)
		return
	end
	-- the app may play its own sound for this press (its handler can run before or after this
	-- one): it leads, and the click stays out of its way
	local stamp = os.clock()
	defer(function()
		if Sfx.lastAny() >= stamp - 0.03 then
			return
		end
		UiSounds.play("click")
	end)
end

local function hovered(b: Instance)
	local cue = attr(b, "UiHover")
	if silent(cue) or silent(attr(b, "UiSound")) or quietPanel(b) then
		return
	end
	if touchOnly() then
		return
	end
	local now = os.clock()
	if now - lastHover < 0.045 then
		return
	end
	lastHover = now
	UiSounds.hovers += 1
	UiSounds.play(if type(cue) == "string" then cue else "hover")
end

-- one button: its press and its hover
function UiSounds.hook(b: Instance)
	local ok, isButton = pcall(function()
		return b:IsA("GuiButton")
	end)
	if not ok or not isButton or hooked[b] then
		return
	end
	hooked[b] = true
	pcall(function()
		(b :: any).Activated:Connect(function()
			pressed(b)
		end)
	end)
	pcall(function()
		(b :: any).MouseEnter:Connect(function()
			hovered(b)
		end)
	end)
end

function UiSounds.isHooked(b: Instance): boolean
	return hooked[b] == true
end

-- watch a whole tree (PlayerGui): every button there now, and every one added later
function UiSounds.watch(root: Instance)
	pcall(function()
		for _, d in root:GetDescendants() do
			UiSounds.hook(d)
		end
	end)
	pcall(function()
		root.DescendantAdded:Connect(function(d)
			UiSounds.hook(d)
		end)
	end)
end

function UiSounds.start(root: Instance?)
	if started then
		if root then
			UiSounds.watch(root)
		end
		return
	end
	started = true
	-- the mix and the sources (init.client starts these first; this is for anyone else)
	if not Sfx.started() then
		pcall(function()
			local shared = game:GetService("ReplicatedStorage"):WaitForChild("LifeSim", 10)
			Sfx.start(require(shared:WaitForChild("Config")).sfx)
		end)
	end
	-- the app's own names play the layered versions
	for _, name in UiSounds.OVERRIDES do
		Sfx.define(name, function(opts: any?)
			UiSounds.play(name, opts)
		end)
	end
	local where = root
	if not where then
		pcall(function()
			where = Players.LocalPlayer:WaitForChild("PlayerGui", 30)
		end)
	end
	if where then
		UiSounds.watch(where)
	end
end

-- a roll: ticks that start fast and slow down over `duration`, then (unless told not to) the
-- win sting. Returns { stop(win?) }. opts: win = false (no sting), sting = a cue name.
function UiSounds.spin(duration: number?, opts: any?): any
	local dur = math.clamp(duration or 2.4, 0.3, 12)
	local o = opts or {}
	local h = { alive = true, ticks = 0 }
	local t = 0
	-- the gap grows as the wheel slows: from fast to slow
	local function nextGap(k: number): number
		return 0.045 + 0.26 * k * k
	end
	local function step()
		if not h.alive then
			return
		end
		local k = math.clamp(t / dur, 0, 1)
		h.ticks += 1
		UiSounds.play("tick", { pitch = 1 + 0.12 * (1 - k) - (if h.ticks % 2 == 0 then 0.03 else 0) })
		local gap = nextGap(k)
		t += gap
		if t < dur then
			task.delay(gap, step)
		else
			h.alive = false
			if o.win ~= false then
				task.delay(0.12, function()
					UiSounds.play(o.sting or "spinWin")
				end)
			end
		end
	end
	function h.stop(_, win: boolean?)
		if not h.alive then
			return
		end
		h.alive = false
		if win then
			UiSounds.play(o.sting or "spinWin")
		end
	end
	step()
	return h
end

return UiSounds
