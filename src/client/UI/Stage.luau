--[[
	STAGE: full-screen cutscenes acted out on a small 3D set (v0.14).

		Stage.fightIntro(ctx, layer, clash, opts)   you and your foe walk in, size each other up,
		                                             and square off; then the fight screen plays
		Stage.fightOutro(ctx, layer, clash, opts)   the fight's own rounds acted out (whoever took
		                                             a round lands a blow, a tie is a parry), then
		                                             the blow that settled it: a fall, or you on
		                                             one knee
		Stage.meet(ctx, layer, scene, opts)          you walk up to someone, and they speak
		Stage.vignette(ctx, layer, kind, opts)       a year's activity in a few seconds: training on
		                                             a dummy, a run over the roofs, study, work, rest
		Stage.moment(ctx, layer, opts)               a new part of life: you walk out, it's named
		Stage.descent(ctx, layer, opts)              going into a delve or out on an expedition
		Stage.play(ctx, layer, spec)                 anything else (see below)
		Stage.enabled(ctx, kind)                     the player's setting ("full" | "fights" | "off")

	Every one of them takes over the whole screen, yields until it's over, and ends at once on
	a tap. A cutscene that can't be drawn (no avatar data yet) is simply skipped.

	spec = {
		set = "street" | "alley" | "facility" | "rooftop" | "room" | "nest" | "underpass" | "hall"
		      | "lake" | "stairs" | "gym",      (an event's `art` maps onto these: Stage.setFor)
		time = "night" | "dusk" | "day",
		kicker, title,                          words over the opening shot
		actors = { [id] = { appearance? | creature?, name?, x, face = "left" | "right" | "camera",
		                    pose = "stand" | "sit" } },
		beats = { { op, ... }, ... },           run in order:
		  { "shot", kind, a?, b?, move = seconds }   wide | track | close | low | over | high
		  { "walk", id, to = x, run = bool, wait = bool }
		  { "face", id, otherId | "left" | "right" | "camera" }
		  { "pose", id, "guard" | "idle" | "raise" | "sit" | "stand" | "kneel" }
		  { "strike", id } { "hurt", id } { "fall", id } { "kneel", id }
		  { "say", id, line, time }         a subtitle with the speaker's name
		  { "plate", id, label, sub }       a name plate in the corner
		  { "title", text, color, slam = bool }
		  { "spread", id, otherId, gap }    two fighters step back to their marks
		  { "flash" } { "shake", strength } { "wait", seconds }
		  { "fx", kind, id, color }         (v0.18) a 3D effect on an actor: phase | anticipate |
		                                    dust | guard | victory | impact (Fx3D)
	}
	Actors face -Z in their own space (as Engine/Avatar builds them); the camera looks from +Z,
	so screen-right is +X and an actor walking right turns to yaw -90 degrees.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Vfx = require(script.Parent.Vfx)
local Format = require(script.Parent.Format)
-- (v0.18) the real 3D stage and its effects; a scene falls back to its ViewportFrame without them
local World3D = require(script.Parent.World3D)
local Fx3D = require(script.Parent.Fx3D)

local Engine = ReplicatedStorage:WaitForChild("LifeSim"):WaitForChild("Engine")
local Avatar = require(Engine:WaitForChild("Avatar"))
local okCreatures, Creatures = pcall(function()
	return require(Engine:WaitForChild("Creatures"))
end)
if not okCreatures then
	Creatures = nil
end

local C, F = Theme.colors, Theme.fonts
local new = Kit.new

local Stage = {}

local MATERIALS = {
	plastic = Enum.Material.SmoothPlastic,
	neon = Enum.Material.Neon,
	metal = Enum.Material.Metal,
	fabric = Enum.Material.Fabric,
	wood = Enum.Material.Wood,
	concrete = Enum.Material.Concrete,
	glass = Enum.Material.Glass,
	-- (blueprint) more for a game's own places (spec.places)
	grass = Enum.Material.Grass,
	sand = Enum.Material.Sand,
	ice = Enum.Material.Ice,
	slate = Enum.Material.Slate,
	brick = Enum.Material.Brick,
	marble = Enum.Material.Marble,
	cobblestone = Enum.Material.Cobblestone,
	rock = Enum.Material.Rock,
	planks = Enum.Material.WoodPlanks,
	granite = Enum.Material.Granite,
	foil = Enum.Material.Foil,
}

local MAX_SECONDS = 14

-- ── small helpers ─────────────────────────────────────────────────────────

local function rgb(t: any, fallback: Color3?): Color3
	if typeof(t) == "Color3" then
		return t
	end
	if type(t) == "table" and #t >= 3 then
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	return fallback or Color3.new(1, 1, 1)
end

local function smooth(t: number): number
	t = math.clamp(t, 0, 1)
	return t * t * (3 - 2 * t)
end

-- a tiny repeatable random (the set looks the same each time for the same seed)
local function rng(seed: number)
	local s = (math.floor(seed) % 2147483646) + 1
	return function(a: number?, b: number?): number
		s = (s * 16807) % 2147483647
		local r = (s - 1) / 2147483646
		if a and b then
			return a + (b - a) * r
		end
		return r
	end
end

local function makePart(spec): Part
	local part = Instance.new("Part")
	part.Name = spec.name or "Part"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = MATERIALS[spec.material or "plastic"] or Enum.Material.SmoothPlastic
	part.Color = rgb(spec.color, Color3.fromRGB(120, 120, 120))
	part.Transparency = spec.transparency or 0
	local cf = CFrame.new(spec.pos[1], spec.pos[2], spec.pos[3])
	if spec.rot then
		cf *= CFrame.Angles(math.rad(spec.rot[1]), math.rad(spec.rot[2]), math.rad(spec.rot[3]))
	end
	local size = spec.size
	if spec.shape == "ball" then
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(size[1], size[1], size[1])
	elseif spec.shape == "cyl" then
		-- Roblox cylinders run along X; turn them upright
		part.Shape = Enum.PartType.Cylinder
		part.Size = Vector3.new(size[2], size[1], size[3] or size[1])
		cf *= CFrame.Angles(0, 0, math.rad(90))
	else
		part.Size = Vector3.new(size[1], size[2], size[3])
	end
	part.CFrame = cf
	return part
end

-- ── the sets ───────────────────────────────────────────────────────────────
-- Each builder adds parts with box(...) / cyl(...) / ball(...) and returns what the stage
-- needs to know: its sky, its light, and where people stand.

local TIMES = {
	night = { skyTop = { 6, 8, 18 }, skyLow = { 34, 26, 52 }, ambient = { 104, 106, 132 }, light = { 190, 180, 220 }, dir = { -0.4, -1, -0.6 } },
	dusk = { skyTop = { 30, 24, 56 }, skyLow = { 214, 116, 84 }, ambient = { 130, 108, 108 }, light = { 240, 180, 150 }, dir = { -0.8, -0.7, -0.4 } },
	day = { skyTop = { 104, 150, 204 }, skyLow = { 206, 222, 236 }, ambient = { 160, 160, 168 }, light = { 255, 246, 232 }, dir = { -0.5, -1, -0.3 } },
	inside = { skyTop = { 10, 10, 12 }, skyLow = { 24, 24, 28 }, ambient = { 140, 138, 132 }, light = { 230, 222, 206 }, dir = { -0.3, -1, -0.5 } },
	facility = { skyTop = { 4, 8, 6 }, skyLow = { 10, 22, 16 }, ambient = { 120, 134, 126 }, light = { 200, 236, 214 }, dir = { -0.2, -1, -0.4 } },
}

local WINDOW_LIT = { { 255, 214, 140 }, { 255, 190, 110 }, { 180, 220, 255 }, { 255, 236, 190 } }
local NEON = { { 255, 70, 140 }, { 70, 230, 220 }, { 255, 176, 60 }, { 170, 120, 255 }, { 90, 255, 150 } }

local function builder(model: Instance)
	local b = {}
	function b.box(x, y, z, sx, sy, sz, color, material, transparency)
		local p = makePart({ size = { sx, sy, sz }, pos = { x, y, z }, color = color, material = material, transparency = transparency })
		p.Parent = model
		return p
	end
	function b.cyl(x, y, z, d, h, color, material, transparency)
		local p = makePart({ shape = "cyl", size = { d, h, d }, pos = { x, y, z }, color = color, material = material, transparency = transparency })
		p.Parent = model
		return p
	end
	function b.ball(x, y, z, d, color, material, transparency)
		local p = makePart({ shape = "ball", size = { d }, pos = { x, y, z }, color = color, material = material, transparency = transparency })
		p.Parent = model
		return p
	end
	-- a building front: a block with lit and dark windows on the side that faces the camera
	function b.building(x, z, w, h, depth, color, r, litShare)
		b.box(x, h / 2, z - depth / 2, w, h, depth, color, "concrete")
		local cols = math.max(1, math.floor((w - 1) / 1.7))
		local rows = math.max(1, math.floor((h - 2) / 2.2))
		for i = 1, cols do
			for j = 1, rows do
				local lit = r() < (litShare or 0.4)
				local wx = x - w / 2 + 0.85 + (i - 1) * ((w - 1.7) / math.max(1, cols - 1 + 0.0001))
				if cols == 1 then
					wx = x
				end
				local wy = 2 + (j - 1) * 2.2
				local col = if lit then WINDOW_LIT[math.floor(r() * #WINDOW_LIT) + 1] else { 26, 28, 36 }
				b.box(wx, wy, z + 0.03, 0.8, 1.1, 0.1, col, if lit then "neon" else "plastic")
			end
		end
	end
	function b.lamp(x, z, color)
		b.cyl(x, 3.2, z, 0.22, 6.4, { 40, 42, 48 }, "metal")
		b.box(x + 0.6, 6.35, z, 1.4, 0.16, 0.2, { 40, 42, 48 }, "metal")
		b.box(x + 1.15, 6.15, z, 0.6, 0.18, 0.5, color or { 255, 220, 150 }, "neon")
		-- the pool of light under it
		b.cyl(x + 1.15, 0.03, z + 1.2, 4.2, 0.02, color or { 255, 214, 140 }, "neon", 0.86)
	end
	return b
end

local SETS = {}
local INSIDE_PLACES: { [string]: boolean } = {} -- (blueprint) a game's own indoor places

function SETS.street(b, r, time)
	local t = TIMES[time] or TIMES.night
	b.box(0, -0.5, 0, 80, 1, 40, { 34, 34, 40 }, "concrete") -- the road
	b.box(0, 0.12, -6.5, 80, 0.25, 5, { 58, 58, 64 }, "concrete") -- the pavement
	for i = -6, 6 do
		b.box(i * 6, 0.02, 3, 2.6, 0.02, 0.25, { 190, 180, 120 }, "plastic") -- road markings
	end
	local x = -40
	while x < 40 do
		local w = r(5, 10)
		local h = r(9, 22)
		b.building(x + w / 2, -9, w - 0.3, h, 6, { math.floor(r(30, 52)), math.floor(r(30, 46)), math.floor(r(38, 60)) }, r, if time == "day" then 0.08 else 0.45)
		-- a neon sign on some of them
		if r() < 0.55 then
			local col = NEON[math.floor(r() * #NEON) + 1]
			b.box(x + w / 2 + r(-1.5, 1.5), r(4, 7), -8.85, r(1.6, 3.4), 0.5, 0.15, col, "neon")
		end
		x += w
	end
	-- the far skyline, and the Nest towers far off
	for i = -8, 8 do
		local h = r(20, 60)
		b.box(i * 9 + r(-2, 2), h / 2, -48, r(6, 10), h, 4, { 18, 20, 30 }, "plastic")
		for k = 1, 6 do
			if r() < 0.5 then
				b.box(i * 9 + r(-2.5, 2.5), r(4, h - 2), -45.9, 0.7, 0.9, 0.1, WINDOW_LIT[1], "neon")
			end
		end
	end
	b.lamp(-9, -4.4, nil)
	b.lamp(10, -4.4, { 200, 230, 255 })
	-- things on the street
	b.box(-14, 0.7, -5.2, 1.8, 1.4, 1.2, { 40, 70, 52 }, "metal") -- a bin
	b.box(14.5, 0.5, -5.6, 1.2, 1.0, 1.2, { 60, 50, 40 }, "wood") -- crates
	b.box(15.6, 0.4, -5.2, 0.9, 0.8, 0.9, { 70, 58, 44 }, "wood")
	b.cyl(-4.5, 0.02, 1.8, 3.2, 0.02, { 90, 110, 150 }, "glass", 0.5) -- a puddle
	return { time = t, marks = { left = -2.6, right = 2.6 } }
end

function SETS.alley(b, r, time)
	local t = TIMES[time] or TIMES.night
	b.box(0, -0.5, 0, 60, 1, 30, { 30, 30, 34 }, "concrete")
	-- brick walls close behind
	b.box(0, 7, -4.5, 60, 14, 1, { 58, 40, 36 }, "concrete")
	for i = -10, 10 do
		for j = 0, 6 do
			if r() < 0.25 then
				b.box(i * 3 + r(-1, 1), j * 2 + 1, -3.95, r(1.2, 2.4), 0.5, 0.1, { 72, 50, 44 }, "concrete")
			end
		end
	end
	-- pipes, a fire escape, a dumpster, a single lamp
	b.box(-6, 6, -3.6, 0.35, 12, 0.35, { 70, 74, 80 }, "metal")
	b.box(5, 4.2, -3.6, 12, 0.3, 0.3, { 70, 74, 80 }, "metal")
	b.box(8, 3.5, -3.2, 4, 0.2, 1.4, { 40, 40, 44 }, "metal")
	b.box(8, 5.8, -3.2, 4, 0.2, 1.4, { 40, 40, 44 }, "metal")
	b.box(-11, 1, -3.2, 3.2, 2, 1.6, { 34, 60, 46 }, "metal")
	b.box(-11, 2.05, -3.2, 3.3, 0.1, 1.7, { 26, 46, 36 }, "metal")
	b.box(3.5, 7.2, -3.8, 1, 0.5, 0.5, { 255, 200, 120 }, "neon")
	b.cyl(3.5, 0.03, -1.2, 5, 0.02, { 255, 196, 120 }, "neon", 0.85)
	-- graffiti
	for _ = 1, 4 do
		local col = NEON[math.floor(r() * #NEON) + 1]
		b.box(r(-16, 16), r(1.5, 4), -3.94, r(1.5, 3.5), r(0.6, 1.4), 0.05, col, "plastic", 0.35)
	end
	b.cyl(-2, 0.02, 1.2, 2.6, 0.02, { 80, 100, 140 }, "glass", 0.5)
	-- a strip of sky between the roofs, far off
	for i = -6, 6 do
		local h = r(30, 50)
		b.box(i * 10, h / 2, -40, 8, h, 4, { 16, 16, 26 }, "plastic")
	end
	return { time = t, marks = { left = -2.4, right = 2.4 } }
end

function SETS.facility(b, r, time)
	local t = TIMES.facility
	-- a corridor of an old L Corp branch: pale tiles, steel walls, green emergency lights
	for i = -10, 10 do
		for k = -2, 2 do
			local c = if (i + k) % 2 == 0 then { 150, 158, 154 } else { 128, 136, 132 }
			b.box(i * 3, -0.5, k * 3, 3, 1, 3, c, "plastic")
		end
	end
	b.box(0, 5, -5, 64, 10, 1, { 96, 106, 102 }, "metal")
	b.box(0, 9.6, -2, 64, 0.4, 7, { 70, 78, 76 }, "metal") -- the ceiling edge
	for i = -9, 9 do
		b.box(i * 3.5, 8.2, -4.4, 1.6, 0.18, 0.18, { 120, 255, 170 }, "neon") -- emergency strips
	end
	-- doors with plates
	for _, dx in { -13, -4.5, 6, 14 } do
		b.box(dx, 3.2, -4.45, 3, 6.4, 0.2, { 60, 66, 64 }, "metal")
		b.box(dx, 6.9, -4.3, 2.2, 0.5, 0.1, { 220, 226, 210 }, "plastic")
		b.box(dx + 1.1, 3.2, -4.3, 0.2, 0.6, 0.1, { 255, 70, 60 }, "neon")
	end
	-- a containment window, red light behind the glass
	b.box(0.8, 4.2, -4.5, 3.6, 2.4, 0.1, { 255, 60, 50 }, "neon", 0.55)
	b.box(0.8, 4.2, -4.35, 3.8, 2.6, 0.1, { 180, 220, 230 }, "glass", 0.75)
	b.box(-9.5, 0.6, -3.6, 1.6, 1.2, 1, { 200, 200, 190 }, "plastic") -- a cart
	return { time = t, marks = { left = -2.4, right = 2.4 } }
end

function SETS.rooftop(b, r, time)
	local t = TIMES[time] or TIMES.night
	b.box(0, -0.5, 0, 60, 1, 24, { 52, 52, 58 }, "concrete")
	b.box(0, 0.6, -5, 60, 1.2, 0.6, { 70, 70, 76 }, "concrete") -- the parapet
	b.cyl(-12, 4, -2, 4.2, 6, { 90, 70, 56 }, "wood") -- a water tank
	b.box(-12, 7.2, -2, 4.6, 0.4, 4.6, { 60, 46, 38 }, "wood")
	b.box(11, 4, -3, 0.2, 8, 0.2, { 70, 70, 76 }, "metal") -- an antenna
	b.ball(11, 8.1, -3, 0.35, { 255, 60, 60 }, "neon")
	b.ball(30, 26, -90, 7, { 236, 232, 210 }, "neon") -- the moon
	-- the whole City below
	for i = -14, 14 do
		for row = 0, 1 do
			local h = r(12, 48) + row * 14
			local z = -32 - row * 22
			local x = i * 6 + r(-2, 2)
			b.box(x, h / 2 - 20, z, r(4, 7), h, 4, { 20 + row * 4, 22 + row * 4, 34 + row * 6 }, "plastic")
			for _ = 1, 5 do
				if r() < 0.6 then
					b.box(x + r(-2, 2), r(-18, h - 22), z + 2.05, 0.6, 0.8, 0.1, WINDOW_LIT[math.floor(r() * 4) + 1], "neon")
				end
			end
		end
	end
	return { time = t, marks = { left = -2.6, right = 2.6 } }
end

function SETS.room(b, r, time, variant)
	local t = TIMES.inside
	local wall = { 92, 80, 70 }
	local floor = { 74, 56, 42 }
	if variant == "office" then
		wall, floor = { 70, 74, 84 }, { 52, 54, 60 }
	elseif variant == "clinic" then
		wall, floor = { 186, 196, 194 }, { 140, 150, 150 }
	elseif variant == "diner" then
		wall, floor = { 120, 50, 44 }, { 60, 60, 64 }
	elseif variant == "library" then
		wall, floor = { 70, 48, 32 }, { 90, 62, 40 }
	end
	b.box(0, -0.5, 0, 40, 1, 20, floor, "wood")
	b.box(0, 6, -4.6, 40, 12, 0.6, wall, "plastic")
	-- a window with the night in it
	b.box(-5, 5, -4.25, 5, 3.4, 0.1, { 30, 40, 70 }, "neon", 0.2)
	b.box(-5, 5, -4.2, 5.4, 0.2, 0.15, { 40, 34, 30 }, "wood")
	b.box(-5, 5, -4.2, 0.2, 3.6, 0.15, { 40, 34, 30 }, "wood")
	-- a table, a lamp, shelves
	b.box(6, 1.6, -2.2, 4, 0.25, 2, { 96, 70, 50 }, "wood")
	b.box(4.4, 0.75, -1.5, 0.25, 1.5, 0.25, { 70, 52, 38 }, "wood")
	b.box(7.6, 0.75, -1.5, 0.25, 1.5, 0.25, { 70, 52, 38 }, "wood")
	b.box(4.4, 0.75, -2.9, 0.25, 1.5, 0.25, { 70, 52, 38 }, "wood")
	b.box(7.6, 0.75, -2.9, 0.25, 1.5, 0.25, { 70, 52, 38 }, "wood")
	b.cyl(6.6, 2.3, -2.4, 0.5, 1.2, { 60, 50, 40 }, "metal")
	b.ball(6.6, 3.1, -2.4, 0.8, { 255, 214, 150 }, "neon")
	for j = 0, 2 do
		b.box(12, 1.5 + j * 1.8, -4.1, 4, 0.2, 0.9, { 80, 60, 44 }, "wood")
		for k = 0, 5 do
			b.box(10.4 + k * 0.6, 2.05 + j * 1.8, -4.1, 0.4, 0.9, 0.7, NEON[(k + j) % #NEON + 1], "plastic", 0.1)
		end
	end
	return { time = t, marks = { left = -2.4, right = 2.4 } }
end

function SETS.nest(b, r, time)
	local t = TIMES[time] or TIMES.day
	for i = -8, 8 do
		for k = -2, 2 do
			b.box(i * 4, -0.5, k * 4, 4, 1, 4, if (i + k) % 2 == 0 then { 214, 214, 206 } else { 196, 196, 190 }, "plastic")
		end
	end
	for i = -5, 5 do
		local h = r(30, 70)
		b.box(i * 8, h / 2, -22 - r(0, 8), r(4, 6), h, 4, { 226, 228, 232 }, "plastic")
		b.box(i * 8, h - 2, -19.9 - r(0, 0.1), 1.2, 0.5, 0.1, { 140, 200, 255 }, "neon")
	end
	for _, px in { -10, -4, 4, 10 } do
		b.box(px, 0.6, -5, 1.6, 1.2, 1.6, { 170, 170, 164 }, "concrete")
		b.ball(px, 1.8, -5, 1.8, { 70, 130, 80 }, "plastic")
	end
	b.box(0, 9, -6, 0.15, 6, 0.15, { 200, 200, 200 }, "metal")
	b.box(1.2, 10.5, -6, 2.2, 3, 0.05, { 70, 110, 200 }, "fabric")
	return { time = t, marks = { left = -2.6, right = 2.6 } }
end

function SETS.underpass(b, r, time)
	local t = TIMES.night
	b.box(0, -0.5, 0, 60, 1, 24, { 40, 40, 42 }, "concrete")
	b.box(0, 8.6, -1, 60, 1.2, 14, { 50, 50, 54 }, "concrete") -- the road overhead
	for _, px in { -14, -5, 5, 14 } do
		b.box(px, 4, -4.5, 1.6, 8, 1.6, { 72, 72, 76 }, "concrete")
	end
	b.box(0, 4, -7, 60, 8, 0.5, { 46, 46, 50 }, "concrete")
	for _ = 1, 5 do
		local col = NEON[math.floor(r() * #NEON) + 1]
		b.box(r(-16, 16), r(1.5, 5), -6.7, r(2, 4), r(0.8, 1.6), 0.05, col, "plastic", 0.3)
	end
	for _, lx in { -9, 0, 9 } do
		b.box(lx, 7.9, -2, 1.4, 0.2, 0.5, { 255, 170, 90 }, "neon")
		b.cyl(lx, 0.03, -1, 4, 0.02, { 255, 170, 90 }, "neon", 0.88)
	end
	b.box(-8, 0.4, -5.5, 2, 0.8, 1, { 60, 52, 40 }, "wood")
	return { time = t, marks = { left = -2.4, right = 2.4 } }
end

function SETS.hall(b, r, time)
	local t = TIMES.inside
	b.box(0, -0.5, 0, 50, 1, 26, { 36, 30, 30 }, "wood")
	b.box(0, 10, -9, 50, 20, 1, { 30, 24, 26 }, "plastic")
	for i = -6, 6 do
		b.box(i * 3.6, 3.5, -8.3, 0.8, 7, 0.8, { 60, 44, 40 }, "wood")
	end
	-- rows of the watching, in the dark
	for row = 0, 2 do
		for i = -10, 10 do
			b.box(i * 1.6 + row * 0.5, 0.8 + row * 1.2, -5 - row * 1.4, 1.1, 1.6, 0.9, { 24, 22, 26 }, "plastic")
			b.ball(i * 1.6 + row * 0.5, 2 + row * 1.2, -5 - row * 1.4, 0.8, { 30, 28, 32 }, "plastic")
		end
	end
	b.cyl(0, 0.03, 0.5, 9, 0.02, { 255, 236, 200 }, "neon", 0.8) -- the spotlight's pool
	return { time = t, marks = { left = -2.4, right = 2.4 } }
end

function SETS.lake(b, r, time)
	local t = TIMES[time] or TIMES.dusk
	b.box(0, -1.6, -10, 120, 1, 60, { 30, 70, 90 }, "glass", 0.1) -- the Great Lake
	b.box(0, -0.4, 0, 40, 0.4, 6, { 96, 72, 50 }, "wood") -- the pier
	for i = -9, 9 do
		b.box(i * 2.1, -0.15, 0, 0.12, 0.05, 6, { 70, 52, 36 }, "wood")
		b.cyl(i * 2.1, -1, 3.1, 0.4, 2, { 70, 52, 36 }, "wood")
		b.cyl(i * 2.1, -1, -3.1, 0.4, 2, { 70, 52, 36 }, "wood")
	end
	for _, sx in { -30, 18, 44 } do
		b.box(sx, 1.5, -50, 14, 3, 4, { 26, 28, 34 }, "plastic") -- ships far out
		b.box(sx + 2, 4.5, -50, 3, 3, 3, { 30, 32, 38 }, "plastic")
		b.ball(sx + 2, 6.5, -50, 0.5, { 255, 200, 120 }, "neon")
	end
	b.box(-12, 1.5, -2.2, 1.6, 1.4, 1.2, { 60, 50, 40 }, "wood")
	return { time = t, marks = { left = -2.6, right = 2.6 }, floorY = -0.2 }
end

function SETS.stairs(b, r, time)
	local t = TIMES.inside
	-- a stairwell landing: a door on each side, and steps going up behind
	b.box(0, -0.5, 0, 40, 1, 16, { 70, 66, 60 }, "concrete")
	b.box(0, 7, -4.6, 40, 14, 0.6, { 96, 92, 84 }, "plastic")
	for s = 0, 6 do
		b.box(6.5 + s * 1.1, 0.25 + s * 0.5, -1.8, 1.1, 0.5 + s * 1.0, 3.2, { 90, 86, 80 }, "concrete")
	end
	b.box(5.6, 3.5, -0.2, 0.15, 3.4, 0.15, { 60, 56, 50 }, "metal") -- the railing
	b.box(-6, 3.2, -4.25, 3, 6.4, 0.2, { 70, 52, 40 }, "wood")
	b.box(-12, 3.2, -4.25, 3, 6.4, 0.2, { 60, 70, 80 }, "wood")
	b.box(-6, 3.4, -4.1, 0.3, 0.3, 0.1, { 200, 180, 90 }, "metal")
	b.box(0, 9.5, -4.2, 1.2, 0.3, 0.6, { 255, 230, 170 }, "neon")
	b.cyl(0, 0.03, -1, 5, 0.02, { 255, 226, 170 }, "neon", 0.9)
	return { time = t, marks = { left = -2.4, right = 2.0 }, seat = { x = 6.5, y = 0.5 } }
end

function SETS.gym(b, r, time)
	local t = TIMES.inside
	-- an Office's training room after hours: mats, a heavy bag, a rack of practice weapons
	b.box(0, -0.5, 0, 50, 1, 20, { 58, 54, 50 }, "concrete")
	for i = -3, 3 do
		b.box(i * 2.2, 0.04, 0.4, 2.1, 0.08, 4.2, if i % 2 == 0 then { 52, 70, 92 } else { 46, 62, 82 }, "fabric") -- the mats
	end
	-- the back wall in brick courses, with high windows on the City
	for row = 0, 7 do
		local shift = if row % 2 == 0 then 0 else 1.7
		for i = -7, 7 do
			local tone = 70 + math.floor(r() * 14)
			b.box(i * 3.4 + shift, 0.4 + row * 0.8, -5, 3.3, 0.72, 0.6, { tone + 18, tone - 4, tone - 14 }, "concrete")
		end
	end
	b.box(0, 10.2, -5.05, 50, 7.6, 0.6, { 64, 56, 52 }, "concrete")
	for _, wx in { -10, -3.4, 3.4, 10 } do
		b.box(wx, 9.4, -4.7, 3.2, 2.2, 0.1, { 120, 150, 200 }, "neon", 0.35)
		b.box(wx, 9.4, -4.6, 0.12, 2.2, 0.12, { 40, 40, 44 }, "metal")
	end
	-- the rack of practice weapons
	b.box(-8, 2.2, -4.3, 4.4, 0.2, 0.5, { 90, 66, 44 }, "wood")
	b.box(-8, 1.2, -4.3, 4.4, 0.2, 0.5, { 90, 66, 44 }, "wood")
	for k = 0, 4 do
		b.box(-9.8 + k * 0.9, 2.1, -4.0, 0.14, 3.6, 0.14, { 150, 130, 100 }, "wood")
	end
	-- the heavy bag on its chain
	b.cyl(7.5, 2.8, -2.6, 1.3, 2.8, { 120, 50, 40 }, "fabric")
	b.box(7.5, 5.6, -2.6, 0.1, 2.8, 0.1, { 120, 120, 126 }, "metal")
	-- a bench and a towel
	b.box(10.5, 0.55, -3.2, 3.6, 0.3, 1, { 80, 60, 44 }, "wood")
	b.box(10.2, 0.75, -3.2, 0.9, 0.1, 0.8, { 220, 214, 200 }, "fabric")
	-- one lamp over the middle of the floor
	b.box(0, 9.8, -0.5, 0.1, 2.4, 0.1, { 40, 40, 44 }, "metal")
	b.box(0, 8.5, -0.5, 1.4, 0.4, 1.4, { 255, 232, 180 }, "neon")
	b.cyl(0, 0.1, 0.4, 7, 0.02, { 255, 232, 190 }, "neon", 0.82)
	return { time = t, marks = { left = -2.2, right = 2.2 } }
end

-- an event's scene art, or a place, as one of the sets above
-- (v0.18) sixteen more places (UI/Sets18.luau)
require(script.Parent:WaitForChild("Sets18"))(SETS, { TIMES = TIMES, NEON = NEON, WINDOW_LIT = WINDOW_LIT })

local SET_OF = {
	alley = "alley", night = "alley", street = "street", market = "market", checkpoint = "street", bus = "street",
	train = "trainyard", syndicate = "alley", rooftop = "rooftop", nest = "plaza", wing = "nest", lcorp = "facility",
	distortion = "facility", office = "office", workshop = "factory", diner = "noodle", clinic = "room", school = "room",
	home = "room", library = "library", underpass = "underpass", ruins = "underpass", outskirts = "underpass",
	hall = "hall", arena = "hall", theater = "hall", lake = "lake", stairs = "stairs", facility = "facility",
	room = "room", corridor = "facility", gym = "gym", academy = "gym", dojo = "gym",
	-- (v0.18) the new places by name, and a few more words for them
	docks = "docks", pier = "docks", harbor = "docks", subway = "subway", station = "subway", factory = "factory",
	forge = "factory", bridge = "bridge", canal = "bridge", construction = "construction", noodle = "noodle",
	warehouse = "warehouse", depot = "warehouse", sewer = "sewer", tunnel = "sewer", plaza = "plaza",
	trainyard = "trainyard", rails = "trainyard", greenhouse = "greenhouse", garden = "greenhouse",
	parking = "parking", garage = "parking", arcade = "arcade",
}
function Stage.setFor(art: string?, fallback: string?): string
	return (art and SET_OF[art]) or fallback or "street"
end

-- (v0.18) where a fight happens. A place the card names (an Office, a Workshop, the facility)
-- stays itself; a fight out on the streets could be anywhere the streets go, so it's dealt one
-- of these by `seedText` (the same fight always gets the same place).
local STREET_FIGHTS = { "street", "alley", "market", "bridge", "construction", "trainyard", "docks", "parking", "underpass", "rooftop", "sewer", "plaza", "warehouse", "arcade" }
local NEST_FIGHTS = { "nest", "plaza", "greenhouse", "rooftop" }
local function hashOf(text: string): number
	local h = 0
	for i = 1, #text do
		h = (h * 31 + string.byte(text, i)) % 1000003
	end
	return h
end
Stage.hashOf = hashOf
function Stage.fightSet(art: string?, fallback: string?, seedText: string?): string
	local set = Stage.setFor(art, fallback)
	local pool = nil
	if set == "street" or set == "alley" or set == "underpass" then
		pool = STREET_FIGHTS
	elseif set == "nest" or set == "plaza" then
		pool = NEST_FIGHTS
	end
	if pool and seedText then
		return pool[hashOf(seedText) % #pool + 1]
	end
	return set
end
Stage.STREET_FIGHTS = STREET_FIGHTS

--[[
	(blueprint) A GAME'S OWN PLACES (spec.places, sent with hello). Each is a recipe the set
	builder draws as a 3D stage: people stand at x -3..3 on the floor (y = 0), the camera looks
	from +z, so dress the set behind them (negative z) and at the sides.
		{
			id = "castle_court", time = "night" | "dusk" | "day" | "inside",
			ground = { color = { r, g, b }, material = "concrete", size = { 70, 30 } },
			skyline = { z = -34, rows = 2, color = { r, g, b }, lit = 0.4 },   (towers far off)
			parts = {
				{ "box", x, y, z, sx, sy, sz, color, material, transparency },
				{ "cyl", x, y, z, diameter, height, color, material },
				{ "ball", x, y, z, diameter, color, material },
				{ "building", x, z, width, height, depth, color, litShare },
				{ "lamp", x, z, color },
				{ "tree", x, z, height, leafColor },
				{ "pillar", x, z, height, color },
				{ "glow", x, z, diameter, color },          (a soft pool of light on the floor)
				{ "row", "lamp" | "tree" | "pillar" | "building", from = -24, to = 24, step = 8, z = -8, jitter = 1 },
			},
			words = { "castle", "throne" },   an event's `art` that comes here
			fights = "street" | "nest",       dealt for fights out in the open (a seeded pick)
			bosses = { "dragon", "lich" },    a boss whose id has one of these words fights here
			inside = true,                    lit like a room (the stage's mood)
		}
	Materials: plastic, neon, metal, fabric, wood, concrete, glass, grass, sand, ice, slate,
	brick, marble (Enum.Material names; an unknown one falls back to plastic).
]]
Stage.bossPlaces = {} -- (Arena.setFor reads this: { { word, setId } })
local function placeBuilder(recipe: any)
	return function(b, r, time)
		local t = TIMES[recipe.time or time] or TIMES[time] or TIMES.night
		local g = recipe.ground or {}
		local size = g.size or { 70, 30 }
		b.box(0, -0.5, 0, size[1], 1, size[2], g.color or { 60, 58, 56 }, g.material or "concrete")
		local sk = recipe.skyline
		if sk then
			for row = 0, (sk.rows or 1) - 1 do
				for i = -12, 12 do
					local hh = r(14, 40) + row * 10
					local zz = (sk.z or -34) - row * 18
					local x = i * 6 + r(-2, 2)
					b.box(x, hh / 2 - 6, zz, r(4, 7), hh, 4, sk.color or { 26, 26, 36 }, "plastic")
					if r() < (sk.lit or 0.4) then
						b.box(x + r(-1.5, 1.5), r(0, hh - 8), zz + 2.05, 0.6, 0.8, 0.1, WINDOW_LIT[math.floor(r() * #WINDOW_LIT) + 1], "neon")
					end
				end
			end
		end
		local function one(kind: string, p: any, x: number?, z: number?)
			if kind == "box" then
				b.box(p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10])
			elseif kind == "cyl" then
				b.cyl(p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9])
			elseif kind == "ball" then
				b.ball(p[2], p[3], p[4], p[5], p[6], p[7], p[8])
			elseif kind == "building" then
				b.building(x or p[2], z or p[3], p.w or p[4] or r(6, 9), p.h or p[5] or r(12, 24), p.depth or p[6] or 6, p.color or p[7] or { 40, 38, 46 }, r, p.lit or p[8] or 0.35)
			elseif kind == "lamp" then
				b.lamp(x or p[2], z or p[3], p.color or p[4])
			elseif kind == "tree" then
				local tx, tz = x or p[2], z or p[3]
				local h = p.height or p[4] or r(5, 8)
				b.cyl(tx, h * 0.35, tz, 0.6, h * 0.7, { 78, 58, 40 }, "wood")
				b.ball(tx, h * 0.8, tz, h * 0.6, p.color or p[5] or { 52, 104, 60 }, "grass")
			elseif kind == "pillar" then
				local h = p.height or p[4] or 8
				b.cyl(x or p[2], h / 2, z or p[3], 1.2, h, p.color or p[5] or { 180, 176, 168 }, "marble")
			elseif kind == "glow" then
				b.cyl(p[2], 0.03, p[3], p[4] or 8, 0.02, p[5] or { 255, 214, 140 }, "neon", 0.86)
			end
		end
		for _, p in recipe.parts or {} do
			if type(p) == "table" then
				local kind = p[1]
				if kind == "row" then
					local step = p.step or 8
					local x = p.from or -24
					while x <= (p.to or 24) do
						one(p[2], p, x + (if p.jitter then r(-p.jitter, p.jitter) else 0), p.z or -8)
						x += step
					end
				elseif type(kind) == "string" then
					one(kind, p)
				end
			end
		end
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end
end

function Stage.usePlaces(places: any)
	if type(places) ~= "table" then
		return
	end
	local own = {}
	for _, recipe in places do
		if type(recipe) == "table" and type(recipe.id) == "string" then
			SETS[recipe.id] = placeBuilder(recipe)
			SET_OF[recipe.id] = recipe.id
			for _, w in recipe.words or {} do
				SET_OF[w] = recipe.id
			end
			if recipe.inside then
				INSIDE_PLACES[recipe.id] = true
			end
			if recipe.fights == "street" then
				table.insert(own, recipe.id)
			elseif recipe.fights == "nest" and not table.find(NEST_FIGHTS, recipe.id) then
				table.insert(NEST_FIGHTS, recipe.id)
			end
			for _, w in recipe.bosses or {} do
				table.insert(Stage.bossPlaces, { string.lower(w), recipe.id })
			end
		end
	end
	-- a game with places of its own fights in those; the stock places stay for what its
	-- cards name
	if #own > 0 then
		table.clear(STREET_FIGHTS)
		for _, id in own do
			table.insert(STREET_FIGHTS, id)
		end
	end
end

function Stage.setIds(): { string }
	local out = {}
	for id in SETS do
		table.insert(out, id)
	end
	table.sort(out)
	return out
end

-- ── the actors ─────────────────────────────────────────────────────────────

local Actor = {}
Actor.__index = Actor

local function classify(spec, torso)
	if spec.name == "Ground" then
		return nil
	end
	-- (v0.18) hair, hats and everything else on the head stay with the head, however far they
	-- reach out to the side or down the back (a ponytail used to walk along with an arm)
	if spec.onHead or spec.name == "Hair" then
		return "body"
	end
	local x, y = spec.pos[1], spec.pos[2]
	local hipY = torso.y - torso.h / 2
	local half = torso.w / 2
	if y < hipY - 0.02 and math.abs(x) > 0.05 and math.abs(x) <= half + 0.12 then
		return if x < 0 then "legL" else "legR"
	end
	if math.abs(x) > half + 0.02 and spec.name ~= "Hair" then
		return if x < 0 then "armL" else "armR"
	end
	return "body"
end

local function newActor(ctx, world: Instance, who)
	local self = setmetatable({}, Actor)
	self.parts = {}
	self.x, self.y, self.z = who.x or 0, who.y or 0, who.z or 0
	self.yaw = 0
	self.targetYaw = 0
	self.angles = { legL = 0, legR = 0, armL = 0, armR = 0 }
	self.pivot, self.pivotInv = {}, {}
	self.gait = "idle"
	self.phase = 0
	self.speed = 7
	self.lean = 0
	self.bob = 0
	self.fall = 0
	self.kneel = 0
	self.sit = 0
	self.pose = "idle"
	self.strikeT = nil
	self.hurtT = nil
	self.name = who.name
	self.creature = who.creature ~= nil
	local model = new("Model", { Name = who.name or "Actor", Parent = world })
	self.model = model
	local specs, info
	if who.dummy then
		-- a straw training dummy on a post
		specs = {
			{ name = "Post", shape = "cyl", size = { 0.35, 3.2, 0.35 }, pos = { 0, 1.6, 0 }, color = { 92, 70, 50 }, material = "wood" },
			{ name = "Body", size = { 1.5, 1.9, 0.9 }, pos = { 0, 3.6, 0 }, color = { 196, 168, 110 }, material = "fabric" },
			{ name = "Bar", size = { 3.0, 0.3, 0.3 }, pos = { 0, 4.1, 0 }, color = { 92, 70, 50 }, material = "wood" },
			{ name = "Head", shape = "ball", size = { 1.0 }, pos = { 0, 5.0, 0 }, color = { 204, 176, 118 }, material = "fabric" },
			{ name = "Rope", size = { 1.56, 0.12, 0.96 }, pos = { 0, 3.2, 0 }, color = { 140, 110, 70 }, material = "fabric" },
			{ name = "Base", shape = "cyl", size = { 1.6, 0.25, 1.6 }, pos = { 0, 0.12, 0 }, color = { 70, 56, 44 }, material = "wood" },
		}
		info = { top = 5.5, height = 5.5, headY = 5.0 }
		self.creature = true
	elseif who.creature and Creatures then
		local def = table.clone(who.creature)
		def.pose = def.pose or "idle"
		local ok, a, b = pcall(Creatures.build, def, { ground = false })
		if ok then
			specs, info = a, b
		end
		self.def = def
	elseif who.appearance and ctx.info and ctx.info.avatar then
		local ok, a, b = pcall(Avatar.build, ctx.info.avatar, who.appearance, { ground = false })
		if ok then
			specs, info = a, b
		end
	end
	if not specs then
		return nil
	end
	self.height = (info and (info.top or info.height)) or 5
	self.headY = (info and info.headY) or self.height * 0.85
	-- the torso decides where the hips and shoulders are
	local torso = { y = self.height * 0.55, h = self.height * 0.37, w = 2 }
	for _, s in specs do
		if s.name == "Torso" then
			torso = { y = s.pos[2], h = s.size[2], w = s.size[1] }
		end
	end
	local legX, armX = 0.5, 1.5
	for _, s in specs do
		local group = if self.creature then "body" else classify(s, torso)
		if group then
			local part = makePart(s)
			part.Parent = model
			table.insert(self.parts, { part = part, base = part.CFrame, group = group })
			if group == "legR" and s.name == "Leg" then
				legX = math.abs(s.pos[1])
			elseif group == "armR" and (s.name == "Sleeve" or s.name == "CoatSleeve") then
				armX = math.abs(s.pos[1])
			end
		end
	end
	local hipY = torso.y - torso.h / 2
	local shoulderY = torso.y + torso.h / 2 - 0.3
	local joints = {
		legL = Vector3.new(-legX, hipY, 0),
		legR = Vector3.new(legX, hipY, 0),
		armL = Vector3.new(-armX, shoulderY, 0),
		armR = Vector3.new(armX, shoulderY, 0),
	}
	for g, v in joints do
		self.pivot[g] = CFrame.new(v)
		self.pivotInv[g] = CFrame.new(-v)
	end
	self.hipY = hipY
	return self
end

local FACE = { right = -math.pi / 2, left = math.pi / 2, camera = math.pi }

-- (v0.18) the same sets and people for the 3D battle and duel stages
Stage.FACE = FACE
Stage.newActor = function(ctx, world: Instance, who)
	return newActor(ctx, world, who)
end
Stage.smooth = smooth
-- builds a set into `world` and returns its meta (floorY, time...) and the light it's lit by
function Stage.buildSet(world: Instance, setId: string?, time: string?, variant: any?, seedText: string?)
	local id = if setId and SETS[setId] then setId else "street"
	local text = seedText or id
	local seed = 0
	for i = 1, #text do
		seed = (seed * 31 + string.byte(text, i)) % 1000003
	end
	local r = rng(seed + 7)
	local b = builder(world)
	local meta = SETS[id](b, r, time or "night", variant) or {}
	return meta, meta.time or TIMES[time or "night"] or TIMES.night
end

-- the light a set is lit by, as a World3D mood
local INSIDE = setmetatable({ room = true, hall = true, gym = true, noodle = true, library = true, warehouse = true, factory = true, subway = true, office = true, arcade = true, parking = true }, { __index = INSIDE_PLACES })
function Stage.moodFor(time: string?, setId: string?): string
	if setId == "facility" then
		return "facility"
	elseif time == "day" then
		return "day"
	elseif time == "dusk" then
		return "dusk"
	elseif time == "inside" or INSIDE[setId or ""] then
		return "inside"
	end
	return "night"
end

function Actor:faceDir(): number
	-- +1 when looking toward screen-right, -1 toward screen-left
	return if math.sin(self.yaw) < 0 then 1 else -1
end

function Actor:update(dt: number)
	-- walking
	if self.moveTo then
		local d = self.moveTo - self.x
		local step = self.speed * dt
		if math.abs(d) <= step then
			self.x = self.moveTo
			self.moveTo = nil
			self.gait = "idle"
		else
			self.x += if d > 0 then step else -step
		end
	end
	-- turning eases round
	local dy = (self.targetYaw - self.yaw + math.pi) % (2 * math.pi) - math.pi
	self.yaw += dy * math.min(1, dt * 10)
	-- the gait
	local swing, freq = 0, 0
	if self.gait == "walk" then
		swing, freq = 0.55, 7.5
	elseif self.gait == "run" then
		swing, freq = 0.95, 12
	end
	self.phase += dt * freq
	local s = math.sin(self.phase)
	local legs = s * swing
	local arms = -s * swing * 0.8
	self.bob = if swing > 0 then math.abs(math.sin(self.phase)) * 0.14 * swing else math.sin(os.clock() * 2) * 0.03
	local armL, armR = arms, -arms
	local lean = if self.gait == "run" then -0.14 else 0
	-- poses on top
	if self.pose == "guard" then
		armR, armL = 1.25 + arms * 0.2, 0.85
	elseif self.pose == "raise" then
		armR = 2.7
	end
	if self.strikeT then
		self.strikeT += dt
		local t = self.strikeT
		if t < 0.16 then
			armR = 1.2 + (2.8 - 1.2) * smooth(t / 0.16)
			lean = 0.08
		elseif t < 0.32 then
			armR = 2.8 - (2.8 - 0.7) * smooth((t - 0.16) / 0.16)
			lean = -0.3
		elseif t < 0.6 then
			armR, lean = 0.7, -0.22
		else
			self.strikeT = nil
		end
	end
	if self.hurtT then
		self.hurtT += dt
		local t = self.hurtT
		if t < 0.5 then
			lean = 0.3 * math.sin(math.min(1, t / 0.25) * math.pi * 0.5)
			armL, armR = -0.5, -0.4
		else
			self.hurtT = nil
		end
	end
	if self.kneel > 0 then
		legs = 0
		self.angles.legL = 1.25 * self.kneel
		self.angles.legR = -0.35 * self.kneel
		lean = -0.25 * self.kneel
	else
		self.angles.legL = legs
		self.angles.legR = -legs
	end
	if self.sit > 0 then
		self.angles.legL = 1.45 * self.sit
		self.angles.legR = 1.45 * self.sit
		armL, armR = 0.5 * self.sit, 0.5 * self.sit
	end
	self.angles.armL = armL
	self.angles.armR = armR
	self.lean = lean
	self:place()
end

function Actor:place()
	local drop = self.kneel * 1.0 + self.sit * (self.hipY * 0.62)
	local root = CFrame.new(self.x, self.y + self.bob - drop, self.z) * CFrame.Angles(0, self.yaw, 0)
	if self.fall > 0 then
		root *= CFrame.Angles(self.fall * 1.48, 0, 0)
	end
	root *= CFrame.Angles(self.lean, 0, 0)
	for _, p in self.parts do
		local cf = p.base
		local g = p.group
		if g ~= "body" then
			local a = self.angles[g]
			if a and a ~= 0 then
				cf = self.pivot[g] * CFrame.Angles(a, 0, 0) * self.pivotInv[g] * cf
			end
		end
		p.part.CFrame = root * cf
	end
end

function Actor:headPos(): Vector3
	local y = self.y + self.headY - self.kneel * 1.0 - self.sit * (self.hipY * 0.62)
	return Vector3.new(self.x, y, self.z)
end

-- ── the player ─────────────────────────────────────────────────────────────

function Stage.enabled(ctx, kind: string?): boolean
	local meta = ctx.state and ctx.state.meta
	local s = meta and meta.settings and meta.settings.cutscenes
	if s == "off" then
		return false
	end
	if s == "fights" and kind ~= "fight" then
		return false
	end
	return ctx.info ~= nil and ctx.info.avatar ~= nil
end

function Stage.play(ctx, layer: Instance, spec)
	if type(spec) ~= "table" then
		return
	end
	local before = World3D.current()
	local ok, err = pcall(Stage._play, ctx, layer, spec)
	if not ok then
		warn("[Stage] " .. tostring(err))
	end
	-- (v0.18) a scene never leaves its 3D stage up (or the HUD hidden) behind it
	World3D.closeAbove(before)
end

function Stage._play(ctx, layer: Instance, spec)
	local root = new("Frame", {
		Name = "Stage",
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 50,
		Active = true,
		Parent = layer,
	})
	local Z = 51
	local timeOf = TIMES[spec.time or "night"] or TIMES.night
	-- (v0.18) on the real 3D stage when it can be (real light, real particles); in a
	-- ViewportFrame otherwise
	local w3 = World3D.open(ctx, layer, { mood = Stage.moodFor(spec.time, spec.set) })
	if w3 then
		root.BackgroundTransparency = 1
	end
	local sky = new("Frame", { Name = "Sky", BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = Z, Visible = w3 == nil, Parent = root })
	local skyGrad = new("UIGradient", { Rotation = 90, Parent = sky })
	local vp = new("ViewportFrame", {
		Name = "Scene",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = Z + 1,
		Visible = w3 == nil,
		Parent = root,
	})
	local camera = Instance.new("Camera")
	-- a tall screen (a phone held upright) sees a thin slice at the usual lens: open the lens,
	-- and step the camera back for whatever the lens can't cover, so both people still fit
	local okSize, size = pcall(function()
		return (workspace.CurrentCamera :: Camera).ViewportSize
	end)
	if not okSize or not size then
		size = Vector2.new(16, 10)
	end
	local aspect = if size.Y > 0 then size.X / size.Y else 1.6
	local lens, pull = 38, 1
	local wantHalf = math.tan(math.rad(24)) -- the half-width a 38-degree lens gives a 16:10 screen
	if aspect < 1.3 then
		lens = math.clamp(math.deg(2 * math.atan(wantHalf / aspect)), 38, 72)
		local haveHalf = math.tan(math.rad(lens / 2)) * aspect
		pull = math.clamp(wantHalf / haveHalf, 1, 2.2)
	end
	camera.FieldOfView = lens
	camera.Parent = vp
	vp.CurrentCamera = camera
	local world = new("Model", { Name = "World", Parent = if w3 then w3.folder else vp })
	-- where the camera is: the 3D stage's camera, or the viewport's
	local function putCamera(cf: CFrame)
		if w3 then
			w3:setCamera(cf, lens)
		else
			camera.CFrame = cf
		end
	end

	-- the set
	local setId = spec.set or "street"
	local seed = 0
	for i = 1, #(spec.seedText or setId) do
		seed = (seed * 31 + string.byte(spec.seedText or setId, i)) % 1000003
	end
	local r = rng(seed + 7)
	local b = builder(world)
	local build = SETS[setId] or SETS.street
	local meta = build(b, r, spec.time or "night", spec.variant)
	local tm = meta.time or timeOf
	skyGrad.Color = ColorSequence.new(rgb(tm.skyTop), rgb(tm.skyLow))
	vp.Ambient = rgb(tm.ambient)
	vp.LightColor = rgb(tm.light)
	vp.LightDirection = Vector3.new(tm.dir[1], tm.dir[2], tm.dir[3])
	local floorY = meta.floorY or 0

	-- the actors
	local actors = {}
	for id, who in spec.actors or {} do
		local a = newActor(ctx, world, who)
		if a then
			a.y = floorY + (who.y or 0)
			a.yaw = FACE[who.face or "camera"] or FACE.camera
			a.targetYaw = a.yaw
			if who.pose == "sit" then
				a.sit = 1
			end
			a:place()
			actors[id] = a
		end
	end

	-- the frame around it: a vignette, the letterbox, words
	new("Frame", { Name = "Vignette", BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = Z + 2, Parent = root }, {
		new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.22, 1), NumberSequenceKeypoint.new(0.78, 1), NumberSequenceKeypoint.new(1, 0.35) }), Rotation = 0 }),
	})
	local barTop = new("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), ZIndex = Z + 6, Parent = root })
	local barBottom = new("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 0), ZIndex = Z + 6, Parent = root })
	Kit.tween(barTop, 0.4, { Size = UDim2.new(1, 0, 0.11, 0) })
	Kit.tween(barBottom, 0.4, { Size = UDim2.new(1, 0, 0.11, 0) })
	local kicker = Kit.caps({ Name = "Kicker", Text = string.upper(spec.kicker or ""), FontFace = F.displayMed, TextSize = 14, TextColor3 = C.accentHi, TextTransparency = 1, AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0, 28, 0.13, 0), Size = UDim2.new(1, -56, 0, 18), ZIndex = Z + 7, Parent = root })
	local title = Kit.text({ Name = "Title", Text = spec.title or "", FontFace = F.display, TextSize = 34, TextColor3 = C.text, TextTransparency = 1, AutomaticSize = Enum.AutomaticSize.None, Position = UDim2.new(0, 28, 0.13, 20), Size = UDim2.new(1, -56, 0, 42), ZIndex = Z + 7, Parent = root })
	local sub = new("Frame", { Name = "Subtitle", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.865, 0), Size = UDim2.new(0.8, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = Z + 7, Parent = root }, {
		Kit.list(2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center),
	})
	local subWho = Kit.caps({ Text = "", FontFace = F.display, TextSize = 14, TextColor3 = C.accentHi, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1, Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, ZIndex = Z + 7, Parent = sub })
	local subLine = Kit.text({ Text = "", FontFace = F.serif, TextSize = 20, TextColor3 = C.text, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1, LayoutOrder = 2, ZIndex = Z + 7, Parent = sub })
	new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1.5, Transparency = 0.3, Parent = subLine })
	local plate = new("Frame", { Name = "Plate", BackgroundColor3 = Color3.fromRGB(10, 10, 14), BackgroundTransparency = 0.15, BorderSizePixel = 0, Position = UDim2.new(0, -320, 0.66, 0), Size = UDim2.fromOffset(300, 58), ZIndex = Z + 7, Parent = root }, { Kit.padding(8, 12, 8, 18) })
	local plateEdge = new("Frame", { BackgroundColor3 = C.crimson, BorderSizePixel = 0, Size = UDim2.new(0, 5, 1, 0), Position = UDim2.fromOffset(-18, -8), ZIndex = Z + 8, Parent = plate })
	plateEdge.Size = UDim2.new(0, 5, 1, 16)
	local plateName = Kit.text({ Text = "", FontFace = F.display, TextSize = 24, TextColor3 = C.text, Size = UDim2.new(1, 0, 0, 26), AutomaticSize = Enum.AutomaticSize.None, ZIndex = Z + 8, Parent = plate })
	local plateSub = Kit.caps({ Text = "", FontFace = F.displayMed, TextSize = 12, TextColor3 = C.sub, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 16), ZIndex = Z + 8, Parent = plate })
	local slam = Kit.text({ Name = "Slam", Text = "", FontFace = F.display, TextSize = 120, TextColor3 = C.text, TextTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.47), Size = UDim2.fromScale(1, 0.3), AutomaticSize = Enum.AutomaticSize.None, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = Z + 9, Parent = root })
	local slamScale = new("UIScale", { Scale = 1, Parent = slam })
	new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 3, Transparency = 0.2, Parent = slam })
	local flash = new("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = Z + 10, Parent = root })
	local skipHint = Kit.caps({ Text = "TAP TO SKIP", FontFace = F.displayMed, TextSize = 11, TextColor3 = C.faint, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, -10), Size = UDim2.fromOffset(160, 14), ZIndex = Z + 9, Parent = root })
	skipHint.TextTransparency = 0.3

	-- the camera, and the shots it can take
	local camCF = CFrame.lookAt(Vector3.new(0, 4.4, 16), Vector3.new(0, 2.8, 0))
	local camFrom, camTo, camT, camDur = camCF, camCF, 1, 0
	local drift = Vector3.zero
	local shake = 0
	local function center(a, b2)
		if a and b2 then
			return (a.x + b2.x) / 2
		end
		return if a then a.x else 0
	end
	local function framed(from: Vector3, at: Vector3): CFrame
		return CFrame.lookAt(at + (from - at) * pull, at)
	end
	local function shotCF(kind: string, a, b2): CFrame
		if kind == "close" and a then
			-- head and shoulders, from the side the face is turned to
			local head = a:headPos()
			local face = a:faceDir()
			return framed(head + Vector3.new(face * 3.4, 0.5, 7.2), head + Vector3.new(face * 0.5, -0.9, 0))
		elseif kind == "low" then
			-- from down by the ground, both of them standing over the frame
			local cx = center(a, b2)
			return framed(Vector3.new(cx - 1.6, 1.2, 14.5), Vector3.new(cx, 3.1, 0))
		elseif kind == "over" and a and b2 then
			local face = if b2.x > a.x then 1 else -1
			local from = a:headPos() + Vector3.new(-face * 3.6, 1.0, 7.5)
			return framed(from, b2:headPos() + Vector3.new(0, -1.1, 0))
		elseif kind == "track" and a then
			local face = a:faceDir()
			return framed(Vector3.new(a.x - face * 2, 4, 14), Vector3.new(a.x + face * 3, 2.8, 0))
		elseif kind == "high" then
			local cx = center(a, b2)
			return framed(Vector3.new(cx, 13, 12), Vector3.new(cx, 1.5, 0))
		end
		local cx = center(a, b2)
		return framed(Vector3.new(cx, 4.4, 16.5), Vector3.new(cx, 2.8, 0))
	end
	local follow = nil -- { kind, a, b }: a shot that keeps up with moving actors
	local function setShot(kind: string, a, b2, move: number?)
		camFrom = camCF
		camTo = shotCF(kind, a, b2)
		camT, camDur = 0, move or 0
		follow = { kind = kind, a = a, b = b2 }
		drift = Vector3.zero
		if (move or 0) <= 0 then
			camCF = camTo
			camT = 1
		end
	end

	-- the clock
	local skipped = false
	local done = false
	local elapsed = 0
	local conn = RunService.Heartbeat:Connect(function(dt)
		dt = math.min(dt, 1 / 15)
		elapsed += dt
		for _, a in actors do
			a:update(dt)
		end
		if follow and camT >= 1 then
			-- keep the shot on its subjects as they move, with a slow push in
			drift += Vector3.new(0, 0, -dt * 0.35)
			local target = shotCF(follow.kind, follow.a, follow.b)
			camCF = camCF:Lerp(target + drift, math.min(1, dt * 4))
		elseif camT < 1 then
			camT = math.min(1, camT + dt / math.max(0.01, camDur))
			camTo = shotCF(follow and follow.kind or "wide", follow and follow.a, follow and follow.b)
			camCF = camFrom:Lerp(camTo, smooth(camT))
		end
		local cf = camCF
		if shake > 0 then
			shake = math.max(0, shake - dt * 2.5)
			cf *= CFrame.new((math.random() - 0.5) * shake * 0.6, (math.random() - 0.5) * shake * 0.6, 0)
		end
		putCamera(cf)
		if elapsed > MAX_SECONDS then
			skipped = true
		end
	end)
	putCamera(camCF)

	local tap = new("TextButton", { Name = "Skip", BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1, 1), ZIndex = Z + 11, Parent = root })
	tap.Activated:Connect(function()
		skipped = true
	end)

	-- one tick of a beat: counts at least its own length, and a scene that runs past its time
	-- by the wall clock ends even if no frame ever arrives
	local startedAt = os.clock()
	local function step(): number
		local dt = task.wait(0.03)
		if os.clock() - startedAt > MAX_SECONDS + 2 then
			skipped = true
		end
		return math.max(if type(dt) == "number" then dt else 0, 0.03)
	end

	local function wait(seconds: number)
		local t = 0
		while t < seconds and not skipped do
			t += step()
		end
	end

	-- a hit: sparks fly from where it landed, and a streak cuts across the screen
	local function sparks(at: Vector3, color: Color3)
		if w3 then
			Fx3D.impact(w3, at, { color = color, noCamera = not Kit.effects })
			return
		end
		local bits = {}
		for i = 1, 10 do
			local p = makePart({ size = { 0.18, 0.18, 0.18 }, pos = { at.X, at.Y, at.Z }, color = color, material = "neon" })
			p.Parent = world
			local ang = (i / 10) * math.pi * 2
			table.insert(bits, { part = p, dir = Vector3.new(math.cos(ang) * 1.6, math.sin(ang) * 1.2 + 0.6, (math.random() - 0.5) * 1.2) })
		end
		task.spawn(function()
			local t = 0
			while t < 0.35 do
				t += step()
				for _, bit in bits do
					if bit.part.Parent then
						bit.part.CFrame = CFrame.new(at + bit.dir * (t / 0.35) * 1.4)
						bit.part.Transparency = math.clamp(t / 0.35, 0, 1)
					end
				end
			end
			for _, bit in bits do
				bit.part:Destroy()
			end
		end)
	end
	local function slash(color: Color3)
		if not Kit.effects then
			return
		end
		local bar = new("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(-0.2, 0.62), Size = UDim2.new(0.9, 0, 0, 6), Rotation = -14, ZIndex = Z + 8, Parent = root })
		Kit.tween(bar, 0.22, { Position = UDim2.fromScale(1.2, 0.36), BackgroundTransparency = 0.4 })
		task.delay(0.24, function()
			bar:Destroy()
		end)
	end
	local function hitPoint(a, b2): Vector3
		if a and b2 then
			return Vector3.new((a.x + b2.x) / 2, a.y + a.height * 0.6, 0.6)
		end
		return Vector3.new(0, 3, 0.6)
	end

	local function fadeWords(on: boolean)
		Kit.tween(kicker, 0.35, { TextTransparency = if on then 0 else 1 })
		Kit.tween(title, 0.35, { TextTransparency = if on then 0 else 1 })
	end

	-- opening words
	if (spec.kicker and spec.kicker ~= "") or (spec.title and spec.title ~= "") then
		fadeWords(true)
	end

	-- the beats
	local function actorOf(id)
		return if type(id) == "string" then actors[id] else nil
	end
	for i, beat in spec.beats or {} do
		if skipped then
			break
		end
		local op = beat[1]
		if i == 3 then
			fadeWords(false)
		end
		if op == "shot" then
			setShot(beat[2] or "wide", actorOf(beat[3]), actorOf(beat[4]), beat.move)
			if beat.hold then
				wait(beat.hold)
			end
		elseif op == "walk" then
			local a = actorOf(beat[2])
			if a then
				a.moveTo = beat.to or a.x
				a.gait = if beat.run then "run" else "walk"
				a.speed = beat.speed or (if beat.run then 12 else 6.5)
				a.targetYaw = if a.moveTo > a.x then FACE.right else FACE.left
				if beat.from then
					a.x = beat.from
					a.targetYaw = if a.moveTo > a.x then FACE.right else FACE.left
					a.yaw = a.targetYaw
				end
				if beat.wait ~= false then
					local guard = 0
					while a.moveTo and not skipped and guard < 400 do
						guard += 1
						task.wait(0.03)
					end
				end
			end
		elseif op == "face" then
			local a = actorOf(beat[2])
			if a then
				local other = actorOf(beat[3])
				if other then
					a.targetYaw = if other.x > a.x then FACE.right else FACE.left
				else
					a.targetYaw = FACE[beat[3]] or a.targetYaw
				end
			end
			wait(beat.time or 0.15)
		elseif op == "pose" then
			local a = actorOf(beat[2])
			if a then
				local p = beat[3]
				if p == "sit" then
					a.sit = 1
				elseif p == "stand" then
					local t0 = 0
					while t0 < 0.35 and not skipped do
						t0 += step()
						a.sit = math.max(0, 1 - t0 / 0.35)
					end
					a.sit = 0
				else
					a.pose = p or "idle"
				end
			end
			wait(beat.time or 0.2)
		elseif op == "strike" then
			local a = actorOf(beat[2])
			if a then
				a.strikeT = 0
				if a.creature and a.def and Creatures then
					a.pose = "strike"
				end
				-- a lunge toward whoever it faces, stopping at arm's (or blade's) length
				local dir = a:faceDir()
				local reach = 1.3
				for _, o in actors do
					if o ~= a and (o.x - a.x) * dir > 0 then
						reach = math.min(reach, math.max(0.25, math.abs(o.x - a.x) - 3.6))
					end
				end
				local t0 = 0
				local x0 = a.x
				while t0 < 0.3 and not skipped do
					t0 += step()
					a.x = x0 + dir * reach * smooth(t0 / 0.3)
				end
			end
			wait(beat.time or 0.15)
		elseif op == "hurt" then
			local a = actorOf(beat[2])
			if a then
				-- whoever is nearest landed it
				local near = nil
				for _, o in actors do
					if o ~= a and (not near or math.abs(o.x - a.x) < math.abs(near.x - a.x)) then
						near = o
					end
				end
				local hitColor = if beat.color then rgb(beat.color) else Color3.fromRGB(255, 226, 150)
				if w3 then
					-- (v0.18) a real crescent from whoever landed it, the hit, and the one hit flashes
					local at = hitPoint(a, near)
					local from = if near then Vector3.new(near.x, near.y + near.height * 0.75, 0.8) else at + Vector3.new(-2.5, 1.2, 0)
					Fx3D.slash(w3, from, at, { color = hitColor })
					Fx3D.flashModel(a.model)
				else
					sparks(hitPoint(a, near), hitColor)
					slash(Color3.fromRGB(255, 244, 220))
					-- (v0.17) and the hit over the whole screen: a slash, sparks, a ring
					Vfx.impact(layer, Vector2.new(0.5, 0.45), { color = hitColor })
				end
				a.hurtT = 0
				local dir = -a:faceDir()
				local x0 = a.x
				local t0 = 0
				while t0 < 0.25 and not skipped do
					t0 += step()
					a.x = x0 + dir * 0.8 * smooth(t0 / 0.25)
				end
			end
			shake = math.max(shake, 0.8)
			wait(beat.time or 0.1)
		elseif op == "spread" then
			-- the two step apart again after an exchange, still facing each other
			local a, b2 = actorOf(beat[2]), actorOf(beat[3])
			if a and b2 then
				local left, right = a, b2
				if b2.x < a.x then
					left, right = b2, a
				end
				local cx = (left.x + right.x) / 2
				local half = (beat.gap or 3.2) / 2
				local l0, r0 = left.x, right.x
				local t0, dur = 0, beat.time or 0.25
				while t0 < dur and not skipped do
					t0 += step()
					local k = smooth(math.min(1, t0 / dur))
					left.x = l0 + (cx - half - l0) * k
					right.x = r0 + (cx + half - r0) * k
				end
				left.x, right.x = cx - half, cx + half
			end
		elseif op == "fall" then
			local a = actorOf(beat[2])
			if a then
				local t0 = 0
				while t0 < 0.55 and not skipped do
					t0 += step()
					a.fall = smooth(t0 / 0.55)
				end
				a.fall = 1
				if w3 then
					Fx3D.dust(w3, Vector3.new(a.x, a.y, a.z + 1.5))
					w3:shake("medium")
				end
			end
			shake = math.max(shake, 0.5)
			wait(beat.time or 0.2)
		elseif op == "kneel" then
			local a = actorOf(beat[2])
			if a then
				local t0 = 0
				while t0 < 0.45 and not skipped do
					t0 += step()
					a.kneel = smooth(t0 / 0.45)
				end
				a.kneel = 1
			end
			wait(beat.time or 0.2)
		elseif op == "say" then
			local a = actorOf(beat[2])
			subWho.Text = string.upper(Format.escape((a and a.name) or beat.who or ""))
			subLine.Text = Format.escape(beat[3] or "")
			Kit.tween(subWho, 0.2, { TextTransparency = 0 })
			Kit.tween(subLine, 0.2, { TextTransparency = 0 })
			wait(beat.time or math.clamp(#(beat[3] or "") / 18, 1.4, 3.6))
			Kit.tween(subWho, 0.2, { TextTransparency = 1 })
			Kit.tween(subLine, 0.2, { TextTransparency = 1 })
		elseif op == "plate" then
			local a = actorOf(beat[2])
			plateName.Text = string.upper(Format.escape(beat.label or (a and a.name) or ""))
			plateSub.Text = string.upper(Format.escape(beat.sub or ""))
			plateEdge.BackgroundColor3 = rgb(beat.color, C.crimson)
			local right = beat.side == "right"
			plate.Position = if right then UDim2.new(1, 20, 0.66, 0) else UDim2.new(0, -320, 0.66, 0)
			Kit.tween(plate, 0.25, { Position = if right then UDim2.new(1, -330, 0.66, 0) else UDim2.new(0, 28, 0.66, 0) })
			wait(beat.time or 0.9)
			Kit.tween(plate, 0.2, { Position = if right then UDim2.new(1, 20, 0.66, 0) else UDim2.new(0, -320, 0.66, 0) })
		elseif op == "title" then
			slam.Text = beat[2] or ""
			slam.TextColor3 = rgb(beat.color, C.text)
			slam.TextTransparency = 0
			slamScale.Scale = if beat.slam ~= false then 2.2 else 1
			Kit.tween(slamScale, 0.18, { Scale = 1 })
			if beat.slam ~= false and Kit.effects then
				shake = math.max(shake, 1)
			end
			wait(beat.time or 0.8)
			Kit.tween(slam, 0.25, { TextTransparency = 1 })
		elseif op == "flash" then
			flash.BackgroundTransparency = if Kit.effects then 0.1 else 0.6
			Kit.tween(flash, 0.35, { BackgroundTransparency = 1 })
			wait(beat.time or 0.05)
		elseif op == "shake" then
			if Kit.effects then
				shake = math.max(shake, beat[2] or 1)
			end
		elseif op == "wait" then
			wait(beat[2] or 0.5)
		elseif op == "fx" then
			-- (v0.18) a 3D effect where an actor stands; without the 3D stage, a flash on the screen
			local a = actorOf(beat[3])
			local color = if beat.color then rgb(beat.color) else Color3.fromRGB(220, 40, 52)
			local kind = beat[2]
			if w3 and a then
				local at = Vector3.new(a.x, (a.y or 0) + (a.height or 5) * 0.55, 0.6)
				pcall(function()
					if kind == "phase" then
						Fx3D.phase(w3, at, color, { floor = a.y or 0 })
					elseif kind == "anticipate" then
						Fx3D.anticipate(w3, at, color)
					elseif kind == "dust" then
						Fx3D.dust(w3, Vector3.new(a.x, (a.y or 0) + 0.2, 1.5))
					elseif kind == "guard" then
						Fx3D.guard(w3, at, color)
					elseif kind == "victory" then
						Fx3D.victory(w3, at, color)
					else
						Fx3D.impact(w3, at, { color = color, heavy = true, noCamera = not Kit.effects })
					end
				end)
			else
				flash.BackgroundTransparency = if Kit.effects then 0.2 else 0.7
				Kit.tween(flash, 0.4, { BackgroundTransparency = 1 })
			end
			wait(beat.time or 0.15)
		end
	end

	-- out
	if not skipped then
		wait(spec.tail or 0.35)
	end
	done = true
	Kit.tween(barTop, 0.25, { Size = UDim2.new(1, 0, 0.5, 0) })
	Kit.tween(barBottom, 0.25, { Size = UDim2.new(1, 0, 0.5, 0) })
	task.wait(0.27)
	conn:Disconnect()
	if w3 then
		w3:close()
	end
	root:Destroy()
	return done
end

-- ── the cutscenes the game plays ───────────────────────────────────────────

local function foeActor(clash)
	local enemy = clash.enemy or {}
	local name = enemy.name or (clash.foe and clash.foe.name) or "Someone"
	if enemy.kind == "creature" then
		return { creature = { shape = enemy.shape, color = enemy.color, eye = enemy.eye, seed = enemy.id, name = name }, name = name }
	end
	if enemy.look then
		return { appearance = { look = enemy.look, age = 30, form = "human" }, name = name }
	end
	return nil
end
-- (v0.18) an enemy (a boss's, a foe's) as an actor spec for the 3D stages
function Stage.foeWho(enemy, fallbackName: string?)
	return foeActor({ enemy = enemy or {}, foe = { name = fallbackName } })
end

local function bark(enemy, kind: string): string?
	local list = enemy and enemy.barks and enemy.barks[kind]
	if type(list) == "table" and #list > 0 then
		return list[math.random(1, #list)]
	end
	return nil
end

-- you and your foe walk in, size each other up, and square off. The first fight of a session,
-- a boss and a fight in an episode get the whole thing; the rest a short version (walk in,
-- square off, FIGHT), so a life full of fights doesn't drag.
Stage.fightsSeen = 0
Stage.lastFull = false
function Stage.fightIntro(ctx, layer: Instance, clash, opts)
	opts = opts or {}
	local full = Stage.fightsSeen == 0 or clash.boss == true or opts.full == true
	Stage.fightsSeen += 1
	Stage.lastFull = full
	local life = ctx.state and ctx.state.life
	if not life or not life.appearance or not clash then
		return
	end
	local foe = foeActor(clash)
	if not foe then
		return
	end
	-- (v0.18) the same fight, the same place: its foe and the year pick it
	local set = Stage.fightSet(opts.art, opts.fallbackSet, tostring((clash.foe and clash.foe.name) or (clash.enemy and clash.enemy.name) or "") .. ":" .. tostring(life.age))
	local marks = { left = -2.6, right = 2.6 }
	local stance = clash.stance and clash.stance.name
	local foeLine = bark(clash.enemy, "start")
	if not full then
		Stage.play(ctx, layer, {
			set = set,
			time = opts.time or "night",
			seedText = (clash.enemy and clash.enemy.id) or set,
			actors = {
				you = { appearance = life.appearance, name = life.name or "You", x = -9, face = "right" },
				foe = { appearance = foe.appearance, creature = foe.creature, name = foe.name, x = 9, face = "left" },
			},
			beats = {
				{ "shot", "low", "you", "foe" },
				{ "walk", "you", from = -9, to = marks.left, run = true, wait = false },
				{ "walk", "foe", from = 9, to = marks.right, run = true, wait = true },
				{ "pose", "you", "guard", time = 0.05 },
				{ "pose", "foe", "guard", time = 0.05 },
				{ "plate", "foe", label = foe.name, sub = (clash.temper and clash.temper.name) or "", side = "right", color = { 190, 150, 90 }, time = 0.55 },
				{ "flash" },
				{ "title", "FIGHT", color = { 240, 220, 170 }, time = 0.45 },
			},
			tail = 0.05,
		})
		return
	end
	local beats = {
		{ "shot", "wide", "you", "foe" },
		{ "walk", "you", from = -13, to = marks.left, wait = false },
		{ "walk", "foe", from = 13, to = marks.right, run = clash.boss == true, wait = true },
		{ "face", "you", "foe" },
		{ "face", "foe", "you" },
		{ "shot", "close", "foe", move = 0.35 },
		{ "plate", "foe", label = foe.name, sub = if clash.boss then "a dangerous foe" else (clash.temper and clash.temper.name) or "", side = "right", color = if clash.boss then { 214, 60, 60 } else { 190, 150, 90 }, time = 0.8 },
	}
	if foeLine then
		table.insert(beats, { "say", "foe", foeLine, time = 1.3 })
	end
	table.insert(beats, { "shot", "close", "you", move = 0.3 })
	table.insert(beats, { "pose", "you", "guard", time = 0.1 })
	table.insert(beats, { "plate", "you", label = life.name or "You", sub = if stance then ("You " .. stance) else "", side = "left", color = { 90, 200, 180 }, time = 0.75 })
	table.insert(beats, { "shot", "low", "you", "foe", move = 0.4 })
	table.insert(beats, { "pose", "foe", "guard", time = 0.05 })
	table.insert(beats, { "flash" })
	table.insert(beats, { "title", "FIGHT", color = if clash.boss then { 240, 80, 70 } else { 240, 220, 170 }, time = 0.7 })
	Stage.play(ctx, layer, {
		set = set,
		time = opts.time or "night",
		seedText = (clash.enemy and clash.enemy.id) or set,
		kicker = opts.kicker,
		title = opts.title,
		actors = {
			you = { appearance = life.appearance, name = life.name or "You", x = -13, face = "right" },
			foe = { appearance = foe.appearance, creature = foe.creature, name = foe.name, x = 13, face = "left" },
		},
		beats = beats,
		tail = 0.1,
	})
end

-- (v0.18) A BOSS WALKS IN: before a boss battle, its own scene on the boss's ground. The boss
-- comes out of the dark, the floor answers it, its name in red, a line, and BOSS.
--   boss = the battle view's boss: { id, name, title, enemy, phases }
function Stage.bossIntro(ctx, layer: Instance, boss, opts)
	opts = opts or {}
	local life = ctx.state and ctx.state.life
	if not life or not life.appearance or type(boss) ~= "table" then
		return
	end
	local foe = Stage.foeWho(boss.enemy, boss.name)
	if not foe then
		return
	end
	local Arena = require(script.Parent.Arena) :: any
	local okSet, set = pcall(Arena.setFor, boss.id, boss.enemy)
	set = if okSet and type(set) == "string" then set else Stage.fightSet(opts.art, opts.fallbackSet, tostring(boss.id))
	local red = { 226, 52, 52 }
	local line = bark(boss.enemy, "start")
	local phases = tonumber(boss.phases) or 1
	local beats = {
		{ "shot", "wide", "you", "boss" },
		{ "walk", "you", from = -14, to = -3.2, wait = false },
		{ "wait", 0.6 },
		{ "shot", "low", "boss", move = 0.6 },
		{ "fx", "anticipate", "boss", color = red, time = 0.2 },
		{ "walk", "boss", from = 14, to = 3.2, wait = true },
		{ "fx", "dust", "boss", time = 0.05 },
		{ "shake", 1.2 },
		{ "fx", "phase", "boss", color = red, time = 0.35 },
		{ "shot", "close", "boss", move = 0.4 },
		{ "plate", "boss", label = foe.name, sub = (boss.title or (if phases > 1 then phases .. " phases" else "a boss")), side = "right", color = red, time = 1.0 },
	}
	if line then
		table.insert(beats, { "say", "boss", line, time = 1.4 })
	end
	table.insert(beats, { "face", "you", "boss" })
	table.insert(beats, { "shot", "close", "you", move = 0.3 })
	table.insert(beats, { "pose", "you", "guard", time = 0.1 })
	table.insert(beats, { "fx", "guard", "you", color = { 120, 200, 255 }, time = 0.2 })
	table.insert(beats, { "shot", "low", "you", "boss", move = 0.4 })
	table.insert(beats, { "pose", "boss", "guard", time = 0.05 })
	table.insert(beats, { "flash" })
	table.insert(beats, { "title", "BOSS", color = red, time = 0.9 })
	Stage.play(ctx, layer, {
		set = set,
		time = "night",
		seedText = tostring(boss.id or set),
		kicker = opts.kicker,
		title = opts.title,
		actors = {
			you = { appearance = life.appearance, name = life.name or "You", x = -14, face = "right" },
			boss = { appearance = foe.appearance, creature = foe.creature, name = foe.name, x = 14, face = "left" },
		},
		beats = beats,
		tail = 0.1,
	})
end

-- the fight's own rounds, acted out: whoever took a round lands a blow, a tie is a parry
-- (the last round is the finishing blow, played after these)
local EXCHANGE_SHOTS = { "wide", "low", "high", "over" }
local function exchangeBeats(clash, count: number)
	local out = {}
	local rounds = if type(clash.rounds) == "table" then clash.rounds else {}
	local n = math.min(count, math.max(0, #rounds - 1))
	for i = 1, n do
		local winner = rounds[i] and rounds[i].winner
		local kind = EXCHANGE_SHOTS[(i - 1) % #EXCHANGE_SHOTS + 1]
		if kind == "over" then
			table.insert(out, { "shot", "over", if winner == "foe" then "foe" else "you", if winner == "foe" then "you" else "foe" })
		else
			table.insert(out, { "shot", kind, "you", "foe", move = 0.3 })
		end
		if winner == "player" then
			table.insert(out, { "strike", "you", time = 0.02 })
			table.insert(out, { "hurt", "foe", time = 0.18 })
		elseif winner == "foe" then
			table.insert(out, { "strike", "foe", time = 0.02 })
			table.insert(out, { "hurt", "you", time = 0.18 })
		else
			table.insert(out, { "strike", "you", time = 0 })
			table.insert(out, { "strike", "foe", time = 0 })
			table.insert(out, { "flash" })
			table.insert(out, { "shake", 0.5 })
			table.insert(out, { "wait", 0.15 })
		end
		table.insert(out, { "spread", "you", "foe", gap = 4.8, time = 0.22 })
	end
	return out
end

-- how it ended, acted out: a few of the exchanges, then the blow that settled it
function Stage.fightOutro(ctx, layer: Instance, clash, opts)
	opts = opts or {}
	local life = ctx.state and ctx.state.life
	if not life or not life.appearance or not clash then
		return
	end
	local foe = foeActor(clash)
	if not foe then
		return
	end
	-- (v0.18) the same fight, the same place: its foe and the year pick it
	local set = Stage.fightSet(opts.art, opts.fallbackSet, tostring((clash.foe and clash.foe.name) or (clash.enemy and clash.enemy.name) or "") .. ":" .. tostring(life.age))
	local beats
	if clash.won then
		beats = {
			{ "shot", "wide", "you", "foe" },
			{ "pose", "you", "guard", time = 0.1 },
			{ "pose", "foe", "guard", time = 0.05 },
			{ "strike", "you", time = 0.05 },
			{ "hurt", "foe", time = 0.05 },
			{ "flash" },
			{ "shot", "low", "you", "foe", move = 0.25 },
			{ "fall", "foe", time = 0.25 },
			{ "pose", "you", "idle", time = 0.1 },
			{ "title", "VICTORY", color = { 240, 200, 100 }, slam = false, time = 0.9 },
		}
		local line = bark(clash.enemy, "lose")
		if line then
			table.insert(beats, 9, { "say", "foe", line, time = 1.1 })
		end
	else
		beats = {
			{ "shot", "wide", "you", "foe" },
			{ "pose", "foe", "guard", time = 0.1 },
			{ "pose", "you", "guard", time = 0.05 },
			{ "strike", "foe", time = 0.05 },
			{ "hurt", "you", time = 0.05 },
			{ "flash" },
			{ "kneel", "you", time = 0.2 },
			{ "shot", "over", "foe", "you", move = 0.35 },
			{ "title", "DEFEAT", color = { 226, 86, 76 }, slam = false, time = 0.9 },
		}
		local line = bark(clash.enemy, "win")
		if line then
			table.insert(beats, 8, { "say", "foe", line, time = 1.1 })
		end
	end
	-- before the finishing blow, the exchanges: three in a big fight, one in an everyday one
	local exchanges = exchangeBeats(clash, if Stage.lastFull or clash.boss then 3 else 1)
	for i, beat in exchanges do
		table.insert(beats, 3 + i, beat) -- after the opening shot and both guards
	end
	Stage.play(ctx, layer, {
		set = set,
		time = opts.time or "night",
		seedText = (clash.enemy and clash.enemy.id) or set,
		actors = {
			you = { appearance = life.appearance, name = life.name or "You", x = -2.4, face = "right" },
			foe = { appearance = foe.appearance, creature = foe.creature, name = foe.name, x = 2.4, face = "left" },
		},
		beats = beats,
		tail = 0.2,
	})
end

-- ── everyday vignettes: what you did with your year, acted out in a couple of seconds ──
-- kind = "train" | "run" | "study" | "work" | "rest" | "walk"
local VIGNETTE_OF = {
	train = "train", train_together = "train", drill_style = "train", spar_rival = "train",
	run_rooftops = "run",
	study = "study", street_school = "study", enroll_academy = "study",
	odd_jobs = "work", double_shift = "work", apprentice_work = "work", shift_together = "work", workshop = "work", diner = "work",
	quiet = "rest", still_heart = "rest", visit_family = "rest",
	turf_walk = "walk", turf_collect = "walk", night_watch_together = "walk",
}
function Stage.vignetteFor(activityId: string?): string?
	if type(activityId) ~= "string" then
		return nil
	end
	if VIGNETTE_OF[activityId] then
		return VIGNETTE_OF[activityId]
	end
	if string.sub(activityId, 1, 5) == "read_" then
		return "study"
	end
	if string.sub(activityId, 1, 5) == "work_" then
		return "work"
	end
	return nil
end

Stage.vignettesSeen = {}
function Stage.vignette(ctx, layer: Instance, kind: string, opts)
	opts = opts or {}
	local life = ctx.state and ctx.state.life
	if not life or not life.appearance then
		return
	end
	-- the first time each kind, then now and then, so a busy year doesn't drag
	local seen = Stage.vignettesSeen[kind] or 0
	Stage.vignettesSeen[kind] = seen + 1
	if seen > 0 and math.random() > 0.3 then
		return
	end
	local you = { appearance = life.appearance, name = life.name or "You", x = -1, face = "right" }
	local spec = { time = opts.time or "night", title = opts.title, kicker = opts.kicker, actors = { you = you }, tail = 0.15 }
	if kind == "train" then
		-- a straw dummy to hit, in a training room after hours
		spec.set = "gym"
		you.x = -2.4
		spec.actors.dummy = { dummy = true, name = "", x = 2.4, face = "left" }
		spec.beats = {
			{ "shot", "wide", "you", "dummy" },
			{ "pose", "you", "guard", time = 0.35 },
			{ "shot", "low", "you", "dummy", move = 0.5 },
			{ "strike", "you", time = 0.05 },
			{ "hurt", "dummy", time = 0.22 },
			{ "strike", "you", time = 0.05 },
			{ "hurt", "dummy", time = 0.18 },
			{ "shot", "over", "you", "dummy" },
			{ "strike", "you", time = 0.05 },
			{ "shake", 0.6 },
			{ "hurt", "dummy", time = 0.35 },
			{ "wait", 0.25 },
		}
	elseif kind == "run" then
		spec.set = "rooftop"
		you.x = -12
		spec.beats = {
			{ "shot", "track", "you" },
			{ "walk", "you", from = -12, to = 12, run = true, speed = 13, wait = true },
			{ "wait", 0.1 },
		}
	elseif kind == "study" then
		spec.set = "room"
		spec.variant = "library"
		you.x = 5.2
		you.face = "camera"
		you.pose = "sit"
		spec.beats = {
			{ "shot", "wide", "you", move = 0 },
			{ "shot", "close", "you", move = 1.6 },
			{ "wait", 0.6 },
		}
	elseif kind == "work" then
		spec.set = "street"
		you.x = -10
		spec.beats = {
			{ "shot", "track", "you" },
			{ "walk", "you", from = -10, to = 4, wait = true },
			{ "face", "you", "camera", time = 0.2 },
			{ "pose", "you", "guard", time = 0.6 },
		}
	elseif kind == "rest" then
		spec.set = "stairs"
		you.x = 6.6
		you.face = "camera"
		you.pose = "sit"
		spec.beats = {
			{ "shot", "wide", "you" },
			{ "shot", "close", "you", move = 1.8 },
			{ "wait", 0.5 },
		}
	else -- walk
		spec.set = "street"
		you.x = -12
		spec.beats = {
			{ "shot", "wide", "you" },
			{ "walk", "you", from = -12, to = 10, wait = true },
		}
	end
	Stage.play(ctx, layer, spec)
end

-- a turning point: you walk out into the open, and the moment gets its name
-- opts = { title, kicker, line, set, time, color }
function Stage.moment(ctx, layer: Instance, opts)
	opts = opts or {}
	local life = ctx.state and ctx.state.life
	if not life or not life.appearance then
		return
	end
	local beats = {
		{ "shot", "track", "you" },
		{ "walk", "you", from = -12, to = 0, wait = true },
		{ "face", "you", "camera", time = 0.35 },
		{ "shot", "close", "you", move = 1.0 },
		{ "title", string.upper(opts.title or ""), color = opts.color or { 240, 220, 170 }, slam = false, time = 1.3 },
	}
	if opts.line then
		table.insert(beats, { "say", "none", opts.line, who = "", time = 2.2 })
	end
	Stage.play(ctx, layer, {
		set = opts.set or "rooftop",
		time = opts.time or "dusk",
		seedText = opts.title or "moment",
		kicker = opts.kicker,
		actors = { you = { appearance = life.appearance, name = life.name or "You", x = -12, face = "right" } },
		beats = beats,
		tail = 0.3,
	})
end

-- going in: you walk up to the way in, look back once, and the place takes you
-- opts = { title, kicker, set, time }
local DESCENT_SET = {
	exploration = "underpass", survival = "underpass", investigation = "alley", escort = "street",
	salvage = "lake", negotiation = "room", escape = "alley", compliance = "facility",
}
local DESCENT_KIND = { dungeon = "underpass", containment = "facility", mission = "street", trip = "street" }
function Stage.descentSet(run): string
	if type(run) ~= "table" then
		return "underpass"
	end
	return DESCENT_SET[run.purpose or ""] or DESCENT_KIND[run.kind or ""] or "underpass"
end
function Stage.descent(ctx, layer: Instance, opts)
	opts = opts or {}
	local life = ctx.state and ctx.state.life
	if not life or not life.appearance then
		return
	end
	Stage.play(ctx, layer, {
		set = opts.set or "underpass",
		time = opts.time or "night",
		seedText = opts.title or "descent",
		kicker = opts.kicker,
		title = opts.title,
		actors = { you = { appearance = life.appearance, name = life.name or "You", x = -11, face = "right" } },
		beats = {
			{ "shot", "track", "you" },
			{ "walk", "you", from = -11, to = 1, wait = true },
			{ "face", "you", "camera", time = 0.35 },
			{ "shot", "close", "you", move = 0.6 },
			{ "wait", 0.6 },
			{ "face", "you", "right", time = 0.25 },
			{ "shot", "high", "you", move = 0.9 },
			{ "walk", "you", to = 10, wait = false },
			{ "wait", 0.9 },
		},
		tail = 0.3,
	})
end

Stage.peopleSeen = {}
-- you walk up to someone, and they speak
-- scene = { set, time, title, kicker, line, reply, other = { name, appearance | creature, pose } }
function Stage.meet(ctx, layer: Instance, scene, opts)
	opts = opts or {}
	local life = ctx.state and ctx.state.life
	if not life or not life.appearance or type(scene) ~= "table" then
		return
	end
	local other = scene.other or {}
	local set = Stage.setFor(scene.set, opts.fallbackSet)
	local alone = scene.other == nil
	if alone then
		-- nobody to meet: you walk in, and the place speaks for itself
		local beats = {
			{ "shot", "track", "you" },
			{ "walk", "you", from = -12, to = -0.5, wait = true },
			{ "face", "you", "camera", time = 0.3 },
			{ "shot", "wide", "you", move = 0.8 },
		}
		if scene.line then
			table.insert(beats, { "say", "none", scene.line, who = "" })
		end
		table.insert(beats, { "wait", 0.4 })
		Stage.play(ctx, layer, {
			set = set,
			time = scene.time or "night",
			seedText = scene.title or set,
			kicker = scene.kicker,
			title = scene.title,
			actors = { you = { appearance = life.appearance, name = life.name or "You", x = -12, face = "right" } },
			beats = beats,
		})
		return
	end
	-- time with someone you know (scene.short): the first time with each of them, then now and
	-- then, and a shorter walk, so an afternoon with family doesn't become a wait
	if scene.short then
		local who = tostring(other.name or "")
		local n = Stage.peopleSeen[who] or 0
		Stage.peopleSeen[who] = n + 1
		if n > 0 and math.random() > 0.25 then
			return
		end
	end
	local startX = if scene.short then -7 else -12
	local sitting = other.pose == "sit"
	local otherX = if sitting then 2.6 else 2.4
	local beats = {
		{ "shot", "wide", "you", "other" },
		{ "walk", "you", from = startX, to = -2.2, wait = true },
		{ "face", "you", "other", time = 0.2 },
	}
	if sitting then
		table.insert(beats, { "shot", "close", "other", move = 0.5 })
	else
		table.insert(beats, { "face", "other", "you", time = 0.25 })
		table.insert(beats, { "shot", "over", "you", "other", move = 0.5 })
	end
	if other.name then
		table.insert(beats, { "plate", "other", label = other.name, sub = other.role or "", side = "right", color = scene.color or { 200, 170, 110 }, time = 0.8 })
	end
	if scene.line then
		local voice = scene.voice or "other"
		table.insert(beats, { "say", if voice == "you" then "you" elseif voice == "narrator" then "none" else "other", scene.line, who = if voice == "narrator" then "" else nil })
	end
	if scene.reply then
		table.insert(beats, { "shot", "close", "you", move = 0.3 })
		table.insert(beats, { "say", "you", scene.reply })
	end
	if sitting and scene.stand then
		table.insert(beats, { "pose", "other", "stand" })
	end
	table.insert(beats, { "shot", "wide", "you", "other", move = 0.6 })
	table.insert(beats, { "wait", 0.4 })
	Stage.play(ctx, layer, {
		set = set,
		time = scene.time or "night",
		seedText = scene.title or set,
		kicker = scene.kicker,
		title = scene.title,
		actors = {
			you = { appearance = life.appearance, name = life.name or "You", x = startX, face = "right" },
			other = { appearance = other.appearance, creature = other.creature, name = other.name, x = otherX, face = if sitting then "camera" else "left", pose = other.pose },
		},
		beats = beats,
	})
end

return Stage
