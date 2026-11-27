--[[
	HOW THE LIVE CITY'S MONSTERS FIGHT (server; called from Npcs.stepMonsters ~4 times a second).

	Every kind (Hunter/Monsters) has a BEHAVIOUR and 1-3 SPECIALS:
	  melee      closes in and strikes; pack-mates fan out around the target
	  brute      the same, slower and harder, with charges and slams
	  swarm      fast and weak, circles to flank
	  ranged     keeps its distance (backs off when you close in) and shoots
	  caster     the same, with spells: bolts, novas, marked ground
	  flier      hovers in, dives
	  burrower   goes under the street and comes up beneath you
	  healer     hangs back behind its kin and mends them, wards them
	  summoner   calls up more of its kind (or what it commands)
	  leader     a war cry that drives the pack harder, and fights at its head

	A special winds up first, visibly: the model's Casting or Charging attribute is set to its
	id (client/MonsterAnim poses it: arms up and a brighter glow, or a lean) and the ground shows
	where it will land (a ring, a cone, a line: fx "monster" on Remotes.HunterLive, drawn by
	client/MonsterAnim). A shot is aimed where you were when it left the hand, so you can step out
	of it. Damage goes through the director's own onHit (so a guard, the injury in your life, the
	knock-down of a civilian all work the same as a plain blow), scaled by the special.

		MonsterAI.prepare(m, now)                 -- when it spawns
		MonsterAI.step(m, target, kind, pos, dist, ctx)
		MonsterAI.update(monsters, ctx)          -- what's in flight, passives, buffs, summons
	ctx = { now, onHit(m, kind, victim), targets(pos, r) -> { {kind, victim, pos} },
	        allies(m, r) -> { m }, spawn(kind, pos, master) -> m?, fx(data), move(m, pos),
	        remove(m), rand() -> 0..1 }
]]

local MonsterAI = {}

-- ── the special abilities ───────────────────────────────────────────────────────
-- mech: shot | lob | mark | line | aoe | cone | dash | jump | burrow | blink | drain | reach |
--       buff | heal | ward | shield | summon | passive
-- tele: which attribute shows the wind-up (Casting: a spell, a breath, a shot; Charging: a
-- charge, a slam, a leap). c: the colour it's drawn in. mult: times the kind's blow.
local S: { [string]: any } = {}
MonsterAI.SPECIALS = S
-- shots (aimed at where you stood when it was loosed)
S.arrow = { name = "Arrow", mech = "shot", windup = 0.55, cd = 3.5, range = 70, min = 5, speed = 120, radius = 3.2, mult = 1, tele = "Casting", kind = "arrow", c = { 230, 225, 210 } }
S.javelin = { name = "Javelin", mech = "shot", windup = 0.6, cd = 5, range = 55, min = 6, speed = 85, radius = 3.6, mult = 1.3, tele = "Casting", kind = "arrow", c = { 210, 200, 170 }, lob = true }
S.sling = { name = "Sling Stone", mech = "shot", windup = 0.5, cd = 3, range = 50, min = 5, speed = 85, radius = 3, mult = 0.9, tele = "Casting", kind = "ball", size = 0.6, c = { 150, 140, 120 }, lob = true }
S.spit = { name = "Acid Spit", mech = "shot", windup = 0.45, cd = 4.5, range = 45, min = 4, speed = 60, radius = 4, mult = 1, tele = "Casting", kind = "ball", size = 1, c = { 170, 255, 80 }, lob = true }
S.scald = { name = "Scalding Spray", mech = "shot", windup = 0.45, cd = 4, range = 38, min = 4, speed = 65, radius = 4.5, mult = 1.05, tele = "Casting", kind = "ball", size = 1.1, c = { 255, 170, 60 } }
S.web = { name = "Web", mech = "shot", windup = 0.5, cd = 7, range = 40, min = 4, speed = 55, radius = 5, mult = 0.7, tele = "Casting", kind = "ball", size = 1.6, c = { 240, 240, 236 }, lob = true }
S.firebolt = { name = "Firebolt", mech = "shot", windup = 0.8, cd = 4, range = 60, min = 4, speed = 75, radius = 4.5, mult = 1.3, tele = "Casting", kind = "ball", size = 1.4, c = { 255, 120, 40 } }
S.frostbolt = { name = "Frost Shard", mech = "shot", windup = 0.8, cd = 4, range = 60, min = 4, speed = 80, radius = 4.5, mult = 1.25, tele = "Casting", kind = "ball", size = 1.3, c = { 150, 220, 255 } }
S.shadowbolt = { name = "Shadow Bolt", mech = "shot", windup = 0.8, cd = 4, range = 60, min = 4, speed = 70, radius = 4.5, mult = 1.3, tele = "Casting", kind = "ball", size = 1.3, c = { 170, 90, 255 } }
S.shard = { name = "Mana Shard", mech = "shot", windup = 0.6, cd = 3.5, range = 55, min = 4, speed = 85, radius = 4, mult = 1.1, tele = "Casting", kind = "ball", size = 1, c = { 120, 190, 255 } }
-- thrown in an arc, with its landing marked
S.boulder = { name = "Hurled Boulder", mech = "lob", windup = 1, cd = 7, range = 60, min = 12, speed = 50, radius = 7, mult = 1.6, tele = "Charging", kind = "boulder", c = { 120, 110, 100 } }
S.firepot = { name = "Firepot", mech = "lob", windup = 0.6, cd = 4.5, range = 45, min = 6, speed = 45, radius = 6, mult = 1.15, tele = "Casting", kind = "ball", size = 0.8, c = { 255, 140, 40 } }
-- marked ground: a ring where you stand, then it comes down
S.volley = { name = "Volley", mech = "mark", windup = 0.9, delay = 0.8, cd = 10, range = 70, radius = 9, mult = 1.3, tele = "Casting", draw = "rain", c = { 230, 225, 210 } }
S.lightning = { name = "Lightning", mech = "mark", windup = 1, delay = 0, cd = 7, range = 65, radius = 5, mult = 1.7, tele = "Casting", draw = "bolt", c = { 190, 230, 255 } }
S.meteor = { name = "Meteor", mech = "mark", windup = 1.2, delay = 0.6, cd = 14, range = 70, radius = 9, mult = 2.2, tele = "Casting", draw = "meteor", c = { 255, 120, 40 } }
S.spores = { name = "Spore Cloud", mech = "mark", windup = 0.8, delay = 0, cd = 10, range = 35, radius = 7, mult = 0.45, ticks = 3, tele = "Casting", draw = "cloud", c = { 170, 210, 90 } }
S.quake = { name = "Quake", mech = "line", windup = 1, cd = 10, range = 40, len = 40, width = 5, mult = 1.5, tele = "Charging", c = { 140, 110, 80 } }
-- around itself
S.slam = { name = "Ground Slam", mech = "aoe", windup = 0.9, cd = 7, radius = 8, mult = 1.5, tele = "Charging", draw = "dust", c = { 170, 150, 120 } }
S.stomp = { name = "Stomp", mech = "aoe", windup = 1.1, cd = 9, radius = 12, mult = 1.6, tele = "Charging", draw = "dust", c = { 170, 150, 120 } }
S.frost_nova = { name = "Frost Nova", mech = "aoe", windup = 1, cd = 9, radius = 12, mult = 1.3, tele = "Casting", draw = "burst", c = { 170, 230, 255 } }
S.fire_nova = { name = "Fire Nova", mech = "aoe", windup = 1, cd = 9, radius = 12, mult = 1.35, tele = "Casting", draw = "burst", c = { 255, 130, 50 } }
S.scream = { name = "Shriek", mech = "aoe", windup = 0.7, cd = 8, radius = 14, mult = 0.8, tele = "Casting", draw = "burst", c = { 220, 150, 255 } }
S.ink = { name = "Ink Cloud", mech = "aoe", windup = 0.5, cd = 10, radius = 10, mult = 0.7, tele = "Casting", draw = "cloud", c = { 40, 30, 50 } }
S.tail_sweep = { name = "Tail Sweep", mech = "aoe", windup = 0.55, cd = 6, radius = 7, mult = 1.2, tele = "Charging", draw = "dust", c = { 200, 190, 160 } }
-- in front of it
S.cleave = { name = "Cleave", mech = "cone", windup = 0.6, cd = 5, len = 8, angle = 60, mult = 1.4, tele = "Charging", draw = "burst", c = { 255, 210, 150 } }
S.fire_breath = { name = "Fire Breath", mech = "cone", windup = 1, cd = 9, len = 20, angle = 28, mult = 1.6, tele = "Casting", draw = "cone", c = { 255, 130, 40 } }
S.frost_breath = { name = "Frost Breath", mech = "cone", windup = 1, cd = 9, len = 20, angle = 28, mult = 1.5, tele = "Casting", draw = "cone", c = { 170, 230, 255 } }
S.gaze = { name = "Petrifying Gaze", mech = "cone", windup = 1.1, cd = 10, len = 28, angle = 14, mult = 1.5, tele = "Casting", draw = "beam", c = { 220, 255, 120 } }
-- moves
S.charge = { name = "Charge", mech = "dash", windup = 0.8, cd = 8, range = 40, min = 10, mult = 1.5, speedMult = 2.8, tele = "Charging", c = { 170, 150, 120 } }
S.leap = { name = "Pounce", mech = "jump", windup = 0.45, cd = 6, range = 28, min = 7, radius = 5, mult = 1.3, air = 0.6, tele = "Charging", c = { 170, 150, 120 } }
S.dive = { name = "Dive", mech = "jump", windup = 0.7, cd = 7, range = 45, min = 6, radius = 6, mult = 1.5, air = 0.7, flier = true, tele = "Charging", c = { 200, 200, 220 } }
S.burrow = { name = "Burrow", mech = "burrow", windup = 0.45, cd = 9, range = 45, min = 10, radius = 6, mult = 1.4, under = 1.6, tele = "Charging", c = { 150, 120, 90 } }
S.blink = { name = "Shadow Step", mech = "blink", windup = 0.35, cd = 8, range = 35, min = 5, mult = 1.5, tele = "Casting", c = { 170, 120, 255 } }
S.drain = { name = "Life Drain", mech = "drain", windup = 0.5, cd = 9, range = 28, mult = 1.2, heal = 0.6, tele = "Casting", c = { 170, 90, 255 } }
S.lash = { name = "Lash", mech = "reach", windup = 0.45, cd = 4, range = 13, mult = 1.2, tele = "Charging", c = { 200, 120, 140 } }
S.sting = { name = "Sting", mech = "reach", windup = 0.5, cd = 5, range = 3, mult = 1.8, tele = "Charging", c = { 190, 120, 255 } }
-- for its kin
S.warcry = { name = "War Cry", mech = "buff", windup = 0.8, cd = 16, radius = 35, dur = 8, tele = "Casting", c = { 255, 110, 60 } }
S.howl = { name = "Howl", mech = "buff", windup = 0.8, cd = 16, radius = 35, dur = 8, tele = "Casting", c = { 200, 220, 255 } }
S.heal = { name = "Mend", mech = "heal", windup = 1, cd = 7, radius = 35, amount = 0.25, tele = "Casting", c = { 120, 255, 170 } }
S.ward = { name = "Ward", mech = "ward", windup = 0.7, cd = 12, radius = 25, dur = 2.5, tele = "Casting", c = { 150, 210, 255 } }
S.shield = { name = "Guard", mech = "shield", windup = 0.3, cd = 12, dur = 2.5, tele = "Charging", c = { 200, 210, 230 } }
S.summon = { name = "Call Kin", mech = "summon", windup = 1.2, cd = 16, n = 2, cap = 3, tele = "Casting", c = { 170, 90, 255 } }
S.raise = { name = "Raise the Dead", mech = "summon", windup = 1.3, cd = 18, n = 2, cap = 2, tele = "Casting", c = { 120, 220, 255 } }
-- always on
S.split = { name = "Split", mech = "passive", at = 0.5 }
S.enrage = { name = "Frenzy", mech = "passive", at = 0.4 }
S.regen = { name = "Regeneration", mech = "passive", rate = 0.015 }
S.ambush = { name = "Ambush", mech = "passive", mult = 2 }

MonsterAI.MECHS = { "shot", "lob", "mark", "line", "aoe", "cone", "dash", "jump", "burrow", "blink", "drain", "reach", "buff", "heal", "ward", "shield", "summon", "passive" }
MonsterAI.BEHAVIOURS = {
	melee = "closes in and strikes; pack-mates fan out around its target",
	brute = "slower, hits harder, charges and slams",
	swarm = "fast and weak; circles to flank",
	ranged = "keeps its distance and shoots; backs off when you close in",
	caster = "keeps its distance and casts: bolts, novas, marked ground",
	flier = "hovers in and dives",
	burrower = "goes under the street and comes up beneath you",
	healer = "hangs back behind its kin, mends and wards them",
	summoner = "calls up more of its kind",
	leader = "a war cry that drives its pack harder; fights at their head",
}
local KEEP_AWAY = { ranged = true, caster = true, healer = true, summoner = true }

-- what's in the air or under the ground: { at, fn }
MonsterAI.pending = {} :: { any }
MonsterAI.lastUpdate = nil :: number?

local function v3(v: Vector3): { number }
	return { v.X, v.Y, v.Z }
end
local function flat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end
local function alive(m: any): boolean
	return m.model ~= nil and m.model.Parent ~= nil and m.hum.Health > 0
end
local function schedule(at: number, fn: () -> ())
	table.insert(MonsterAI.pending, { at = at, fn = fn })
end

function MonsterAI.prepare(m: any, now: number)
	m.cds = {}
	m.baseSpeed = m.hum.WalkSpeed
	m.baseHip = m.hum.HipHeight
	m.busyUntil = 0
	m.cool = m.cool or 0
	m.lastHurt = now
	m.lastHp = m.hum.Health
	m.flank = (math.random() * 2 - 1) * (if m.def.beh == "swarm" then 1.6 else 0.9)
	m.summons = 0
	-- (the specials come ready at different times, not all at once)
	for _, id in m.def.sp or {} do
		local sp = S[id]
		if sp and sp.cd then
			m.cds[id] = now + 1 + math.random() * sp.cd * 0.6
		end
	end
	if table.find(m.def.sp or {}, "ambush") then
		m.disguised = true
		m.model:SetAttribute("Disguised", true)
	end
end

-- a blow (or a special's hit) on one victim, through the director's onHit, scaled
local function strike(m: any, v: any, mult: number, ctx: any)
	local base = m.def.dmg
	local boost = (if m.empoweredUntil and m.empoweredUntil > ctx.now then 1.3 else 1) * (if m.enraged then 1.35 else 1)
	m.def.dmg = base * mult * boost
	local ok, err = pcall(ctx.onHit, m, v.kind, v.victim)
	m.def.dmg = base
	if not ok then
		warn("[MonsterAI] a hit failed: " .. tostring(err))
	end
end
local function area(m: any, center: Vector3, radius: number, mult: number, ctx: any): number
	local n = 0
	for _, v in ctx.targets(center, radius) do
		strike(m, v, mult, ctx)
		n += 1
	end
	return n
end
MonsterAI.strike = strike

local function face(m: any, at: Vector3)
	local root = m.model.PrimaryPart
	if root then
		local here = root.CFrame.Position
		local look = Vector3.new(at.X, here.Y, at.Z)
		if (look - here).Magnitude > 0.1 then
			root.CFrame = CFrame.lookAt(here, look)
		end
	end
end

local function setTele(m: any, attr: string?, id: string?)
	if attr then
		m.model:SetAttribute(attr, id)
	end
end
local function done(m: any, sp: any)
	setTele(m, sp.tele, nil)
	m.model:SetAttribute("Special", (m.model:GetAttribute("Special") or 0) + 1)
end

local function fx(ctx: any, data: any)
	data.fx = "monster"
	pcall(ctx.fx, data)
end

local function headPos(m: any): Vector3
	local root = m.model.PrimaryPart :: BasePart
	return root.CFrame.Position + Vector3.new(0, root.Size.Y * 0.5 + m.def.size * 0.8, 0)
end

-- ── starting a special ───────────────────────────────────────────────────────────
local START: { [string]: (any, any, any, any) -> () } = {}

-- shots and lobs: wind up, loose it at where the target stands, it lands later
START.shot = function(m, sp, tgt, ctx)
	local windup = sp.windup * (if sp.basic then 0.75 else 1)
	face(m, tgt.pos)
	ctx.move(m, m.model.PrimaryPart.CFrame.Position)
	schedule(ctx.now + windup, function()
		if not alive(m) then
			return
		end
		local from = headPos(m)
		local aim = tgt.pos
		if tgt.live then
			local p = tgt.live()
			if p then
				aim = p
			end
		end
		local travel = math.max(0.1, (aim - from).Magnitude / sp.speed)
		local lob = sp.mech == "lob" or sp.lob == true
		fx(ctx, { what = "shot", at = v3(from), to = v3(aim), t = travel, kind = sp.kind, size = (sp.size or 1) * math.max(1, m.def.size * 0.6), c = sp.c, lob = lob })
		if sp.mech == "lob" then
			fx(ctx, { what = "tele_ring", at = v3(aim), r = sp.radius, t = travel, c = { 255, 80, 60 } })
		end
		done(m, sp)
		schedule(ctx.now + windup + travel, function()
			if m.model.Parent then
				area(m, aim, sp.radius, sp.mult, ctx)
				fx(ctx, { what = "burst", at = v3(aim), r = sp.radius * 0.6, c = sp.c })
			end
		end)
	end)
	m.busyUntil = ctx.now + windup + 0.15
	setTele(m, sp.tele, sp.id)
end
START.lob = START.shot

-- marked ground: a ring at your feet that fills, then it falls
START.mark = function(m, sp, tgt, ctx)
	local aim = tgt.pos
	face(m, aim)
	ctx.move(m, m.model.PrimaryPart.CFrame.Position)
	local total = sp.windup + (sp.delay or 0)
	fx(ctx, { what = "tele_ring", at = v3(aim), r = sp.radius, t = total, c = sp.c })
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.1
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		if sp.draw == "rain" or sp.draw == "meteor" then
			fx(ctx, { what = sp.draw, at = v3(aim), r = sp.radius, t = sp.delay, c = sp.c })
		elseif sp.draw == "cloud" then
			fx(ctx, { what = "cloud", at = v3(aim), r = sp.radius, t = (sp.ticks or 1) * 1.0 + 0.5, c = sp.c })
		end
		for k = 1, sp.ticks or 1 do
			schedule(ctx.now + (sp.delay or 0) + (k - 1) * 1.0, function()
				if not m.model.Parent then
					return
				end
				if sp.draw == "bolt" then
					fx(ctx, { what = "bolt", at = v3(aim), r = sp.radius, c = sp.c })
				elseif k == 1 and sp.draw ~= "cloud" then
					fx(ctx, { what = "burst", at = v3(aim), r = sp.radius, c = sp.c })
				end
				area(m, aim, sp.radius, sp.mult, ctx)
			end)
		end
	end)
end

-- a line of upheaval from itself toward you
START.line = function(m, sp, tgt, ctx)
	local root = m.model.PrimaryPart :: BasePart
	local from = root.CFrame.Position
	local dir = flat(tgt.pos - from)
	dir = if dir.Magnitude > 0.1 then dir.Unit else root.CFrame.LookVector
	local to = from + dir * sp.len
	face(m, tgt.pos)
	ctx.move(m, from)
	fx(ctx, { what = "tele_line", at = v3(from), to = v3(to), r = sp.width, t = sp.windup, c = { 255, 90, 60 } })
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.3
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		fx(ctx, { what = "quake", at = v3(from), to = v3(to), c = sp.c })
		for _, v in ctx.targets((from + to) / 2, sp.len / 2 + sp.width) do
			-- (the distance from the line)
			local rel = v.pos - from
			local along = math.clamp(rel:Dot(dir), 0, sp.len)
			local off = flat(rel - dir * along).Magnitude
			if off <= sp.width then
				strike(m, v, sp.mult, ctx)
			end
		end
	end)
end

-- around itself: a ring on the ground, then it goes off
START.aoe = function(m, sp, tgt, ctx)
	local root = m.model.PrimaryPart :: BasePart
	local r = sp.radius + m.def.size * 1.5
	face(m, tgt.pos)
	ctx.move(m, root.CFrame.Position)
	fx(ctx, { what = "tele_ring", at = v3(root.CFrame.Position), r = r, t = sp.windup, c = sp.c })
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.25
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		local at = (m.model.PrimaryPart :: BasePart).CFrame.Position
		if sp.draw == "cloud" then
			fx(ctx, { what = "cloud", at = v3(at), r = r, t = 1.6, c = sp.c })
		elseif sp.draw == "dust" then
			fx(ctx, { what = "dust", at = v3(at), r = r, c = sp.c })
			fx(ctx, { what = "burst", at = v3(at), r = r * 0.6, c = sp.c })
		else
			fx(ctx, { what = "burst", at = v3(at), r = r, c = sp.c })
		end
		area(m, at, r, sp.mult, ctx)
	end)
end

-- in front of it: a cone on the ground, then a breath (or a sweep, or a gaze)
START.cone = function(m, sp, tgt, ctx)
	local root = m.model.PrimaryPart :: BasePart
	local len = sp.len + m.def.size * 2
	face(m, tgt.pos)
	ctx.move(m, root.CFrame.Position)
	local dir = flat(tgt.pos - root.CFrame.Position)
	dir = if dir.Magnitude > 0.1 then dir.Unit else flat(root.CFrame.LookVector).Unit
	fx(ctx, { what = "tele_cone", at = v3(root.CFrame.Position), dir = v3(dir), len = len, angle = sp.angle, t = sp.windup, c = sp.c })
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.4
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		local from = (m.model.PrimaryPart :: BasePart).CFrame.Position
		local mouth = headPos(m) + dir * m.def.size
		if sp.draw == "cone" then
			fx(ctx, { what = "cone", at = v3(mouth), dir = v3(dir), len = len, angle = sp.angle, t = 0.7, c = sp.c })
		elseif sp.draw == "beam" then
			fx(ctx, { what = "beam", at = v3(mouth), to = v3(mouth + dir * len), t = 0.6, c = sp.c })
		else
			fx(ctx, { what = "burst", at = v3(from + dir * len * 0.5), r = len * 0.5, c = sp.c })
		end
		local cosA = math.cos(math.rad(sp.angle))
		for _, v in ctx.targets(from + dir * len * 0.5, len * 0.75) do
			local rel = flat(v.pos - from)
			if rel.Magnitude <= len and (rel.Magnitude < 2 or rel.Unit:Dot(dir) >= cosA) then
				strike(m, v, sp.mult, ctx)
			end
		end
	end)
end

-- a charge: lean in, then run through whatever's on the line
START.dash = function(m, sp, tgt, ctx)
	local root = m.model.PrimaryPart :: BasePart
	local from = root.CFrame.Position
	local dir = flat(tgt.pos - from)
	dir = if dir.Magnitude > 0.1 then dir.Unit else flat(root.CFrame.LookVector).Unit
	local len = math.min(sp.range, (flat(tgt.pos - from)).Magnitude + 8)
	local to = from + dir * len
	face(m, tgt.pos)
	ctx.move(m, from)
	fx(ctx, { what = "tele_line", at = v3(from), to = v3(to), r = 3 + m.def.size, t = sp.windup, c = { 255, 120, 60 } })
	setTele(m, sp.tele, sp.id)
	local speed = (m.baseSpeed or 16) * sp.speedMult
	local runFor = len / speed
	m.busyUntil = ctx.now + sp.windup + runFor + 0.2
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		m.hum.WalkSpeed = speed
		ctx.move(m, to)
		local hit: { [any]: boolean } = {}
		local untilT = ctx.now + runFor
		local function tick()
			if not alive(m) then
				return
			end
			local here = (m.model.PrimaryPart :: BasePart).CFrame.Position
			for _, v in ctx.targets(here, 4 + m.def.size * 1.5) do
				if not hit[v.victim] then
					hit[v.victim] = true
					strike(m, v, sp.mult, ctx)
				end
			end
			fx(ctx, { what = "dust", at = v3(here), r = 2 + m.def.size, c = sp.c })
			if ctx.now < untilT then
				schedule(ctx.now + 0.25, tick)
			else
				m.hum.WalkSpeed = m.baseSpeed
				done(m, sp)
			end
		end
		tick()
	end)
end

-- a leap (or a flier's dive): crouch, then come down on where you were
START.jump = function(m, sp, tgt, ctx)
	local root = m.model.PrimaryPart :: BasePart
	local aim = tgt.pos
	face(m, aim)
	ctx.move(m, root.CFrame.Position)
	fx(ctx, { what = "tele_ring", at = v3(aim), r = sp.radius, t = sp.windup + sp.air, c = { 255, 90, 60 } })
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + sp.air + 0.2
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		m.model:SetAttribute("Airborne", true)
		local here = (m.model.PrimaryPart :: BasePart).CFrame.Position
		local d = flat(aim - here).Magnitude
		m.hum.WalkSpeed = math.max(m.baseSpeed, d / sp.air)
		ctx.move(m, aim)
		if sp.flier then
			-- (a dive: it drops out of its hover onto you, and climbs back after)
			m.hum.HipHeight = math.max(0.5, m.baseHip * 0.25)
		else
			pcall(function()
				local horiz = flat(aim - here)
				local v = (if horiz.Magnitude > 0.1 then horiz.Unit * (d / sp.air) else Vector3.zero) + Vector3.new(0, 196.2 * sp.air * 0.5, 0)
				root.AssemblyLinearVelocity = v
				m.hum.Jump = true
			end)
		end
		schedule(ctx.now + sp.air, function()
			if not alive(m) then
				return
			end
			m.model:SetAttribute("Airborne", nil)
			m.hum.WalkSpeed = m.baseSpeed
			done(m, sp)
			local land = (m.model.PrimaryPart :: BasePart).CFrame.Position
			fx(ctx, { what = "dust", at = v3(land), r = sp.radius, c = sp.c })
			area(m, land, sp.radius + m.def.size, sp.mult, ctx)
			if sp.flier then
				schedule(ctx.now + 0.6, function()
					if alive(m) then
						m.hum.HipHeight = m.baseHip
					end
				end)
			end
		end)
	end)
end

-- under the street, after you, and up beneath you
START.burrow = function(m, sp, tgt, ctx)
	local root = m.model.PrimaryPart :: BasePart
	ctx.move(m, root.CFrame.Position)
	setTele(m, sp.tele, sp.id)
	fx(ctx, { what = "dust", at = v3(root.CFrame.Position), r = 3 + m.def.size, c = sp.c })
	m.busyUntil = ctx.now + sp.windup + sp.under + 0.3
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		m.model:SetAttribute("Burrowed", true)
		local ff = Instance.new("ForceField")
		ff.Visible = false
		ff.Name = "Underground"
		ff.Parent = m.model
		m.hum.WalkSpeed = m.baseSpeed * 1.8
		local untilT = ctx.now + sp.under
		local function follow()
			if not alive(m) then
				return
			end
			local p = tgt.live and tgt.live() or tgt.pos
			ctx.move(m, p)
			local here = (m.model.PrimaryPart :: BasePart).CFrame.Position
			fx(ctx, { what = "dust", at = v3(here), r = 2, c = sp.c })
			if ctx.now < untilT then
				schedule(ctx.now + 0.25, follow)
			else
				m.model:SetAttribute("Burrowed", nil)
				ff:Destroy()
				m.hum.WalkSpeed = m.baseSpeed
				done(m, sp)
				fx(ctx, { what = "burst", at = v3(here), r = sp.radius, c = sp.c })
				fx(ctx, { what = "dust", at = v3(here), r = sp.radius, c = sp.c })
				area(m, here, sp.radius + m.def.size, sp.mult, ctx)
			end
		end
		follow()
	end)
end

-- a step through the dark to behind you, and a blow
START.blink = function(m, sp, tgt, ctx)
	local root = m.model.PrimaryPart :: BasePart
	setTele(m, sp.tele, sp.id)
	ctx.move(m, root.CFrame.Position)
	m.busyUntil = ctx.now + sp.windup + 0.3
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		local p = tgt.live and tgt.live() or tgt.pos
		local from = root.CFrame.Position
		local dir = flat(p - from)
		dir = if dir.Magnitude > 0.1 then dir.Unit else Vector3.new(0, 0, -1)
		local to = p + dir * 4
		local dest = Vector3.new(to.X, from.Y, to.Z)
		root.CFrame = CFrame.lookAt(dest, Vector3.new(p.X, from.Y, p.Z))
		fx(ctx, { what = "blink", at = v3(from), to = v3(dest), c = sp.c })
		done(m, sp)
		if (flat(p - dest)).Magnitude < 8 then
			strike(m, tgt, sp.mult, ctx)
		end
	end)
end

-- a beam that drinks: it hurts you and mends it
START.drain = function(m, sp, tgt, ctx)
	face(m, tgt.pos)
	ctx.move(m, m.model.PrimaryPart.CFrame.Position)
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.6
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		local p = tgt.live and tgt.live() or tgt.pos
		if (p - (m.model.PrimaryPart :: BasePart).CFrame.Position).Magnitude > sp.range + 6 then
			done(m, sp)
			return
		end
		fx(ctx, { what = "beam", at = v3(headPos(m)), to = v3(p), t = 0.9, c = sp.c })
		strike(m, tgt, sp.mult, ctx)
		m.hum.Health = math.min(m.hum.MaxHealth, m.hum.Health + m.def.dmg * sp.mult * sp.heal)
		fx(ctx, { what = "heal", at = v3((m.model.PrimaryPart :: BasePart).CFrame.Position), c = sp.c })
		done(m, sp)
	end)
end

-- a long reach: a lash, a sting
START.reach = function(m, sp, tgt, ctx)
	face(m, tgt.pos)
	ctx.move(m, m.model.PrimaryPart.CFrame.Position)
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.2
	local reach = m.def.reach + sp.range + m.def.size
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		local p = tgt.live and tgt.live() or tgt.pos
		local here = (m.model.PrimaryPart :: BasePart).CFrame.Position
		if (flat(p - here)).Magnitude <= reach + 2 then
			if sp.id == "lash" then
				fx(ctx, { what = "beam", at = v3(here + Vector3.new(0, m.def.size, 0)), to = v3(p), t = 0.25, c = sp.c })
			else
				fx(ctx, { what = "burst", at = v3(p), r = 2, c = sp.c })
			end
			strike(m, tgt, sp.mult, ctx)
		end
	end)
end

-- a war cry: every kin in earshot hits harder and moves faster for a while
START.buff = function(m, sp, tgt, ctx)
	ctx.move(m, m.model.PrimaryPart.CFrame.Position)
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.2
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		local points = {}
		local kin = ctx.allies(m, sp.radius)
		table.insert(kin, m)
		for _, a in kin do
			a.empoweredUntil = ctx.now + sp.dur
			a.model:SetAttribute("Empowered", true)
			a.hum.WalkSpeed = (a.baseSpeed or a.hum.WalkSpeed) * 1.2
			local ar = a.model.PrimaryPart
			if ar then
				table.insert(points, v3(ar.CFrame.Position))
			end
		end
		fx(ctx, { what = "buff", at = v3((m.model.PrimaryPart :: BasePart).CFrame.Position), r = sp.radius, points = points, c = sp.c })
	end)
	local _ = tgt
end

-- mending the most hurt of its kin (itself included)
local function mostHurt(m: any, radius: number, ctx: any): any?
	local best, worst = nil, 0.85
	local kin = ctx.allies(m, radius)
	table.insert(kin, m)
	for _, a in kin do
		local f = a.hum.Health / math.max(1, a.hum.MaxHealth)
		if a.hum.Health > 0 and f < worst then
			best, worst = a, f
		end
	end
	return best
end
START.heal = function(m, sp, tgt, ctx)
	local who = mostHurt(m, sp.radius, ctx)
	if not who then
		return
	end
	ctx.move(m, m.model.PrimaryPart.CFrame.Position)
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.2
	schedule(ctx.now + sp.windup, function()
		if not alive(m) or not alive(who) then
			setTele(m, sp.tele, nil)
			return
		end
		done(m, sp)
		who.hum.Health = math.min(who.hum.MaxHealth, who.hum.Health + who.hum.MaxHealth * sp.amount)
		fx(ctx, { what = "heal", at = v3(headPos(m)), to = v3((who.model.PrimaryPart :: BasePart).CFrame.Position), points = { v3((who.model.PrimaryPart :: BasePart).CFrame.Position) }, c = sp.c })
	end)
	local _ = tgt
end

-- a ward: a brief shell over its kin (nothing gets through it while it holds)
local function shellOn(m: any, dur: number, ctx: any, color: any)
	local ff = Instance.new("ForceField")
	ff.Name = "Ward"
	ff.Visible = true
	ff.Parent = m.model
	m.model:SetAttribute("Warded", true)
	local r = m.model.PrimaryPart
	if r then
		fx(ctx, { what = "shield", at = v3(r.CFrame.Position), r = 3 + m.def.size * 2, t = dur, c = color })
	end
	schedule(ctx.now + dur, function()
		ff:Destroy()
		if m.model.Parent then
			m.model:SetAttribute("Warded", nil)
		end
	end)
end
START.ward = function(m, sp, tgt, ctx)
	ctx.move(m, m.model.PrimaryPart.CFrame.Position)
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup + 0.2
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		for _, a in ctx.allies(m, sp.radius) do
			shellOn(a, sp.dur, ctx, sp.c)
		end
	end)
	local _ = tgt
end
START.shield = function(m, sp, tgt, ctx)
	setTele(m, sp.tele, sp.id)
	m.busyUntil = ctx.now + sp.windup
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		shellOn(m, sp.dur, ctx, sp.c)
	end)
	local _ = tgt
end

-- calling up more: its own kind, or what it commands (Monsters' sum)
START.summon = function(m, sp, tgt, ctx)
	local root = m.model.PrimaryPart :: BasePart
	ctx.move(m, root.CFrame.Position)
	setTele(m, sp.tele, sp.id)
	fx(ctx, { what = "summon", at = v3(root.CFrame.Position), r = 5 + m.def.size * 2, t = sp.windup + 0.4, c = sp.c })
	m.busyUntil = ctx.now + sp.windup + 0.2
	schedule(ctx.now + sp.windup, function()
		if not alive(m) then
			return
		end
		done(m, sp)
		local kind = m.def.sum or m.kind
		for k = 1, sp.n do
			if m.summons >= sp.cap then
				break
			end
			local a = k / sp.n * math.pi * 2 + math.random()
			local at = root.CFrame.Position + Vector3.new(math.cos(a) * (4 + m.def.size * 2), 0, math.sin(a) * (4 + m.def.size * 2))
			local s = ctx.spawn(kind, at, m)
			if s then
				m.summons += 1
			end
		end
	end)
	local _ = tgt
end

-- can it use this special now? (in range, something to heal, room for more...)
local function usable(m: any, id: string, sp: any, dist: number, ctx: any): boolean
	local mech = sp.mech
	if mech == "passive" then
		return false
	elseif mech == "shot" or mech == "lob" or mech == "mark" or mech == "line" or mech == "dash" or mech == "jump" or mech == "burrow" or mech == "blink" or mech == "drain" then
		if sp.flier and m.def.gait ~= "flyer" then
			return false
		end
		return dist <= sp.range and dist >= (sp.min or 0)
	elseif mech == "aoe" then
		return dist <= sp.radius + m.def.size * 1.5 - 1
	elseif mech == "cone" then
		return dist <= (sp.len + m.def.size * 2) * 0.9
	elseif mech == "reach" then
		return dist <= m.def.reach + sp.range + m.def.size and (sp.range > 4 or dist <= m.def.reach + 3)
	elseif mech == "buff" then
		return dist < 45 and not (m.empoweredUntil and m.empoweredUntil > ctx.now)
	elseif mech == "heal" then
		return mostHurt(m, sp.radius, ctx) ~= nil
	elseif mech == "ward" then
		return dist < 40 and #ctx.allies(m, sp.radius) > 0
	elseif mech == "shield" then
		return dist < m.def.reach + 6 and m.hum.Health < m.hum.MaxHealth * 0.9
	elseif mech == "summon" then
		return dist < 60 and m.summons < sp.cap
	end
	local _ = id
	return false
end
MonsterAI.usable = usable

-- start a special now (the tests call this directly)
function MonsterAI.start(m: any, id: string, tgt: any, ctx: any): boolean
	local sp = S[id]
	local fn = sp and START[sp.mech]
	if not fn then
		return false
	end
	local spec = table.clone(sp)
	spec.id = id
	m.cds[id] = ctx.now + sp.cd * (0.85 + math.random() * 0.3)
	fn(m, spec, tgt, ctx)
	return true
end

-- the always-on ones: splitting, frenzy, regrowth, lying in wait
local function passives(m: any, ctx: any, dt: number)
	local sp = m.def.sp or {}
	local f = m.hum.Health / math.max(1, m.hum.MaxHealth)
	if m.hum.Health < (m.lastHp or m.hum.Health) - 0.01 then
		m.lastHurt = ctx.now
	end
	m.lastHp = m.hum.Health
	if table.find(sp, "split") and not m.didSplit and not m.summoned and f < S.split.at and m.hum.Health > 0 then
		m.didSplit = true
		local root = m.model.PrimaryPart
		if root then
			fx(ctx, { what = "burst", at = v3(root.CFrame.Position), r = 4 + m.def.size * 2, c = { 140, 255, 210 } })
			for k = 1, 2 do
				local a = k * math.pi + math.random()
				ctx.spawn(m.def.sum or m.kind, root.CFrame.Position + Vector3.new(math.cos(a) * 3, 0, math.sin(a) * 3), m)
			end
		end
	end
	if table.find(sp, "enrage") and not m.enraged and f < S.enrage.at and m.hum.Health > 0 then
		m.enraged = true
		m.model:SetAttribute("Enraged", true)
		m.hum.WalkSpeed = (m.baseSpeed or m.hum.WalkSpeed) * 1.25
		m.baseSpeed = m.hum.WalkSpeed
		local root = m.model.PrimaryPart
		if root then
			fx(ctx, { what = "buff", at = v3(root.CFrame.Position), r = 6 + m.def.size * 2, c = { 255, 60, 40 } })
		end
	end
	if table.find(sp, "regen") and m.hum.Health > 0 and m.hum.Health < m.hum.MaxHealth and ctx.now - (m.lastHurt or 0) > 3 then
		m.hum.Health = math.min(m.hum.MaxHealth, m.hum.Health + m.hum.MaxHealth * S.regen.rate * dt)
		m.lastHp = m.hum.Health
	end
end

-- ── one step of one monster ───────────────────────────────────────────────────────
-- target: who it's after (a Player, or a responder/civilian table), kind: "player" |
-- "responder" | "civilian", pos: where they are, dist: how far
function MonsterAI.step(m: any, target: any, kind: string?, pos: Vector3?, dist: number, ctx: any)
	local now = ctx.now
	local def = m.def
	local root = m.model.PrimaryPart :: BasePart
	if not root then
		return
	end
	if now < (m.busyUntil or 0) then
		return -- mid-special: let it play out
	end
	-- a mimic lies in wait until something comes close
	if m.disguised then
		if target and dist <= def.aggro then
			m.disguised = false
			m.model:SetAttribute("Disguised", nil)
			m.ambushNext = true
		else
			ctx.move(m, root.CFrame.Position)
			return
		end
	end
	if not target or not pos then
		ctx.move(m, m.home or root.CFrame.Position)
		return
	end
	local tgt = {
		kind = kind,
		victim = target,
		pos = pos,
		live = function(): Vector3?
			return ctx.whereIs and ctx.whereIs(kind, target) or pos
		end,
	}
	-- a special, if one is ready and fits
	if now >= (m.nextSpecial or 0) then
		m.nextSpecial = now + 0.5
		local order = table.clone(def.sp or {})
		for i = #order, 2, -1 do
			local k = math.floor(ctx.rand() * i) + 1
			order[i], order[k] = order[k], order[i]
		end
		for _, id in order do
			local sp = S[id]
			if sp and sp.mech ~= "passive" and (m.cds[id] or 0) <= now and usable(m, id, sp, dist, ctx) and ctx.rand() < 0.7 then
				MonsterAI.start(m, id, tgt, ctx)
				return
			end
		end
	end
	local beh = def.beh
	local away = flat(root.CFrame.Position - pos)
	away = if away.Magnitude > 0.1 then away.Unit else Vector3.new(1, 0, 0)
	-- the ones that keep their distance: back off, close in, or hold and shoot
	if KEEP_AWAY[beh] then
		local band = math.max(14, def.range)
		local basic = def.basic and S[def.basic]
		if dist < band * 0.45 then
			ctx.move(m, root.CFrame.Position + away * 14)
		elseif dist > band then
			ctx.move(m, pos + away * band * 0.8)
		else
			-- (drifting sideways around you while it holds the range)
			local side = Vector3.new(-away.Z, 0, away.X) * (if m.flank > 0 then 1 else -1)
			ctx.move(m, root.CFrame.Position + side * 4)
		end
		if basic and dist <= basic.range and now > m.cool then
			m.cool = now + def.cd * 1.8
			local spec = table.clone(basic)
			spec.id = def.basic
			spec.basic = true
			START[basic.mech](m, spec, tgt, ctx)
			return
		end
		-- (and a blow, if you've come right up to it)
		if dist < def.reach and now > m.cool then
			m.cool = now + def.cd
			strike(m, tgt, 0.8, ctx)
		end
		return
	end
	-- the rest close in; near the target, a pack spreads around it
	local goal = pos
	if dist < 30 and dist > def.reach * 0.6 then
		local a = m.flank
		local dir = Vector3.new(away.X * math.cos(a) - away.Z * math.sin(a), 0, away.X * math.sin(a) + away.Z * math.cos(a))
		goal = pos + dir * def.reach * 0.6
	end
	-- (a leader lets its pack go in first, while it still has one)
	if beh == "leader" and dist < 16 and dist > def.reach and m.hum.Health > m.hum.MaxHealth * 0.6 and #ctx.allies(m, 25) >= 2 and math.floor(now) % 6 < 2 then
		goal = pos + away * 12
	end
	ctx.move(m, goal)
	if dist < def.reach and now > m.cool then
		m.cool = now + def.cd
		local mult = if m.ambushNext then S.ambush.mult else 1
		m.ambushNext = nil
		strike(m, tgt, mult, ctx)
	end
end

-- everything in flight, the passives, buffs wearing off, summons fading
function MonsterAI.update(monsters: { any }, ctx: any)
	local now = ctx.now
	local dt = math.clamp(now - (MonsterAI.lastUpdate or now), 0, 1)
	MonsterAI.lastUpdate = now
	-- (what's due: run it; some of it schedules more)
	local due = {}
	local keep = {}
	for _, p in MonsterAI.pending do
		if p.at <= now then
			table.insert(due, p)
		else
			table.insert(keep, p)
		end
	end
	MonsterAI.pending = keep
	for _, p in due do
		local ok, err = pcall(p.fn)
		if not ok then
			warn("[MonsterAI] " .. tostring(err))
		end
	end
	for _, m in monsters do
		if m.model.Parent and m.cds then
			if m.hum.Health > 0 then
				passives(m, ctx, dt)
			end
			if m.empoweredUntil and m.empoweredUntil <= now then
				m.empoweredUntil = nil
				m.model:SetAttribute("Empowered", nil)
				m.hum.WalkSpeed = m.baseSpeed or m.hum.WalkSpeed
			end
		end
	end
end

-- (tests: forget everything in flight)
function MonsterAI.reset()
	MonsterAI.pending = {}
	MonsterAI.lastUpdate = nil
end

return MonsterAI
