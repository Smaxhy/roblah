--[[
	THE LIVE CITY'S MONSTERS, ANIMATED ON THE CLIENT (BitLeveling).

	The server builds each monster (Hunter/Monsters) with a tree of Motor6D joints and tags the
	model with its Gait, Family, Behaviour, Attack style and Size. Here, every frame, each monster
	near the camera gets its joints' Transform set from how fast it moves, its gait, and what
	the server says it is doing (attributes on the model):

	  gaits      biped / stomp / golem   legs and arms swing; a stomp is slow and heavy, rolls the
	                                     shoulders and bobs the body; tails and folded wings sway
	             quad / centaur          a trot in diagonal pairs; the head bobs, the jaw pants,
	                                     the tail wags (a centaur's rider-half swings its arms)
	             crawler / hexapod /     legs lift and sweep in alternating tripods (or fours),
	             spider                  feelers twitch, mandibles work
	             slither / serpent       a wave runs down the segments; a serpent's neck sways
	             swim                    the tail kicks like a dolphin's under a bobbing body
	             flyer                   wings beat (an insect's buzz), the body bobs, legs dangle
	             float                   a slow bob, the robe sways, the arms drift
	             blob                    the jelly wobbles and the nucleus turns inside it
	             orbit                   shards circle the core, the fists hover
	             hop                     the body hops along when it moves; a mimic's lid snaps
	             tentacled               every arm curls in its own wave
	  states     Attacking (a counter)   a blow in the kind's style: swing, slam, claw, bite,
	                                     lunge, shoot, cast, sting, whip, peck, gore
	             Casting = "<special>"   the wind-up of a spell or a breath: arms up, head back,
	                                     the glow brightens
	             Charging = "<special>"  the wind-up of a charge or a slam: a lean, braced legs
	             Burrowed                sunk into the ground
	             Airborne                mid-leap or mid-dive: legs tucked, wings swept
	             Disguised               a mimic, still as a chest
	             Enraged / Empowered     the glow goes hot
	             (health dropping)       a flinch; (health at 0) it falls and fades
	It also draws the monsters' special attacks the server announces (Remotes.HunterLive, fx
	"monster"): telegraph rings and cones on the ground, arrows and spit and boulders in flight,
	breath, lightning, meteors, heals, war cries, summoning circles, dust.

	Nothing here touches the server: Transform is local, so it costs no network. Monsters further
	than ~260 studs from the camera are left still, and past ~110 they update every other frame.
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonsterAnim = {}

local FAR, NEAR = 260, 110
local tracked: { [Model]: any } = setmetatable({}, { __mode = "k" }) :: any
local IDENT = CFrame.identity

local function rx(a: number): CFrame
	return CFrame.Angles(a, 0, 0)
end
local function ry(a: number): CFrame
	return CFrame.Angles(0, a, 0)
end
local function rz(a: number): CFrame
	return CFrame.Angles(0, 0, a)
end
local function pos(x: number, y: number, z: number): CFrame
	return CFrame.new(x, y, z)
end
local function ease(x: number): number
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

-- an attack's shape over its length: wind up (0 to 0.42), strike (to 0.6), recover (to 1).
-- returns how wound-up it is (0..1) and how far through the strike (0..1)
local function blow(a: number): (number, number)
	if a < 0.42 then
		return ease(a / 0.42), 0
	elseif a < 0.6 then
		local k = (a - 0.42) / 0.18
		return 1 - ease(k), ease(k)
	end
	return 0, 1 - ease((a - 0.6) / 0.4)
end

function MonsterAnim.rig(model: Model): any?
	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		return nil
	end
	local joints = {}
	local top = {} -- the joints that hang straight off the root (what a fall or a burrow moves)
	for _, d in model:GetDescendants() do
		if d:IsA("Motor6D") then
			local name = (string.gsub(d.Name, "Joint$", ""))
			joints[name] = d
			if d.Part0 == root then
				table.insert(top, d)
			end
		end
	end
	local legsR, legsL = {}, {}
	for k = 1, 8 do
		if joints["LegR" .. k] then
			legsR[k] = joints["LegR" .. k]
		end
		if joints["LegL" .. k] then
			legsL[k] = joints["LegL" .. k]
		end
	end
	local size = model:GetAttribute("Size")
	local hum = model:FindFirstChildOfClass("Humanoid")
	return {
		model = model,
		root = root,
		hum = hum,
		joints = joints,
		top = top,
		legsR = legsR,
		legsL = legsL,
		gait = model:GetAttribute("Gait") or "biped",
		family = model:GetAttribute("Family") or "",
		beh = model:GetAttribute("Behaviour") or "melee",
		atk = model:GetAttribute("Attack") or "swing",
		size = if type(size) == "number" then size else math.max(0.6, root.Size.Y / 2),
		hip = if hum then hum.HipHeight else root.Size.Y,
		phase = math.random() * 10,
		seed = math.random() * 100,
		attackT = -99,
		hurtT = -99,
		castT = -99,
		chargeT = -99,
		specialT = -99,
		light = root:FindFirstChildOfClass("PointLight"),
	}
end

-- what the server says the monster is doing, read each frame (no connections to leak)
local function readState(r: any, t: number)
	local m = r.model
	local atk = m:GetAttribute("Attacking")
	if atk ~= r.atkVal then
		if r.atkVal ~= nil or r.seen then
			-- (a special attack that just landed already played its own move)
			if t - r.specialT > 0.9 then
				r.attackT = t
			end
		end
		r.atkVal = atk
	end
	r.seen = true
	local sp = m:GetAttribute("Special")
	if sp ~= r.spVal then
		r.spVal = sp
		r.specialT = t
		r.attackT = t
	end
	local cast = m:GetAttribute("Casting")
	if cast ~= r.cast then
		r.cast = cast
		if cast and cast ~= "" then
			r.castT = t
		end
	end
	local charge = m:GetAttribute("Charging")
	if charge ~= r.charge then
		r.charge = charge
		if charge and charge ~= "" then
			r.chargeT = t
		end
	end
	r.burrowed = m:GetAttribute("Burrowed") == true
	r.airborne = m:GetAttribute("Airborne") == true
	r.disguised = m:GetAttribute("Disguised") == true
	r.hot = m:GetAttribute("Enraged") == true or m:GetAttribute("Empowered") == true
	local hum = r.hum
	if hum then
		local hp = hum.Health
		if r.hp and hp < r.hp - 0.01 and hp > 0 then
			r.hurtT = t
		end
		if hp <= 0 and not r.deathT then
			r.deathT = t
		end
		r.hp = hp
	end
end

-- the pose this frame, layered: pose[name] = CFrame (multiplied as layers add to it)
local function layer(pose: { [string]: CFrame }, name: string, cf: CFrame)
	pose[name] = (pose[name] or IDENT) * cf
end

local function animate(r: any, dt: number, t: number)
	readState(r, t)
	local j = r.joints
	local s = r.size
	local gait = r.gait
	-- speed from how far the root moved since last frame (works however the server moves it)
	local p0 = r.root.CFrame.Position
	local last = r.lastPos or p0
	r.lastPos = p0
	local step = Vector3.new(p0.X - last.X, 0, p0.Z - last.Z).Magnitude
	local inst = if dt > 0 then step / dt else 0
	r.speed = (r.speed or 0) + (math.min(inst, 60) - (r.speed or 0)) * math.min(1, dt * 8)
	local speed = r.speed
	local moving = math.clamp(speed / (10 + s * 2), 0, 1)
	local heavy = gait == "stomp" or gait == "golem"
	local cadence = (3 + speed * 0.35) / math.sqrt(math.max(0.5, s)) * (if heavy then 0.75 else 1)
	if r.charge and r.charge ~= "" then
		cadence *= 1.5
	end
	r.phase += dt * cadence
	local p = r.phase
	local pose: { [string]: CFrame } = {}
	local breathe = math.sin(t * 1.7 + r.seed) * 0.035

	-- the attack, if one is playing
	local atkStyle = r.atk
	local aDur = if heavy then 0.75 else 0.55
	local a = (t - r.attackT) / aDur
	local wind, strike = 0, 0
	if a >= 0 and a < 1 then
		wind, strike = blow(a)
	end
	local casting = r.cast ~= nil and r.cast ~= ""
	local charging = r.charge ~= nil and r.charge ~= ""
	local castK = if casting then ease((t - r.castT) / 0.35) else 0
	local chargeK = if charging then ease((t - r.chargeT) / 0.3) else 0

	-- ── locomotion ──
	if gait == "biped" or gait == "stomp" or gait == "golem" or gait == "centaur" then
		local amp = (if gait == "golem" then 0.38 elseif gait == "stomp" then 0.5 else 0.72) * moving
		local legs = math.sin(p) * amp
		if gait == "centaur" then
			-- (four legs in a trot, and the rider-half above)
			for k, jt in r.legsR do
				local diag = if k % 2 == 0 then 0 else math.pi
				pose["LegR" .. k] = rx(math.sin(p + diag) * 0.7 * moving + 0.02)
				local l = r.legsL[k]
				if l then
					pose["LegL" .. k] = rx(math.sin(p + diag + math.pi) * 0.7 * moving + 0.02)
				end
			end
			layer(pose, "Body", pos(0, math.abs(math.sin(p)) * 0.12 * s * moving, 0) * rx(breathe * 0.5))
			-- (a rider's mount: its own head and jaw)
			layer(pose, "HeadM", rx(math.sin(p * 2) * 0.06 * moving) * ry((1 - moving) * math.sin(t * 0.5 + r.seed) * 0.3))
			layer(pose, "JawM", rx((math.sin(t * 9) * 0.5 + 0.5) * 0.18 * moving))
		else
			layer(pose, "LegR", rx(legs))
			layer(pose, "LegL", rx(-legs))
		end
		local bob = math.abs(math.cos(p)) * (if gait == "stomp" then 0.16 else 0.08) * s * moving
		local sway = math.sin(p) * (if gait == "stomp" then 0.07 else 0.04) * moving
		layer(pose, "Torso", pos(0, bob, 0) * ry(-sway * 1.5) * rz(sway) * rx(breathe))
		layer(pose, "Head", ry(sway * 1.2 + (1 - moving) * math.sin(t * 0.4 + r.seed) * 0.22) * rx(-breathe * 0.6))
		-- arms swing against the legs (an archer keeps the bow up, a caster the staff ready)
		local armAmp = if gait == "golem" then 0.55 elseif gait == "stomp" then 0.75 else 0.8
		local idleArm = math.sin(t * 1.6 + r.seed) * 0.05
		if atkStyle == "shoot" then
			layer(pose, "ArmL", rx(1.35 + idleArm * 0.5) * rz(0.15))
			layer(pose, "ArmR", rx(0.9 - legs * 0.2))
		else
			layer(pose, "ArmR", rx(-legs * armAmp + idleArm + (if atkStyle == "cast" then 0.25 else 0)) * rz(if gait == "stomp" then 0.06 else 0))
			layer(pose, "ArmL", rx(legs * armAmp + idleArm) * rz(if gait == "stomp" then -0.06 else 0))
		end
		layer(pose, "ArmR2", rx(-legs * 0.5 + 0.4))
		layer(pose, "ArmL2", rx(legs * 0.5 + 0.4))
		layer(pose, "Tail", ry(math.sin(t * 2.4 + r.seed) * 0.32))
		layer(pose, "Tail2", ry(math.sin(t * 2.4 + r.seed - 0.8) * 0.4))
		local flap = math.sin(t * 1.4 + r.seed) * 0.08
		layer(pose, "WingR", rz(0.25 + flap) * ry(0.2))
		layer(pose, "WingL", rz(-0.25 - flap) * ry(-0.2))
	elseif gait == "quad" then
		local amp = 0.75 * moving + 0.02
		for k, jt in r.legsR do
			local diag = if k % 2 == 0 then 0 else math.pi
			pose["LegR" .. k] = rx(math.sin(p + diag) * amp)
			local l = r.legsL[k]
			if l then
				pose["LegL" .. k] = rx(math.sin(p + diag + math.pi) * amp)
			end
		end
		layer(pose, "Body", pos(0, math.abs(math.sin(p)) * 0.1 * s * moving, 0) * rx(math.sin(p * 2) * 0.03 * moving + breathe * 0.5))
		local look = (1 - moving) * math.sin(t * 0.5 + r.seed) * 0.3
		layer(pose, "Head", rx(math.sin(p * 2) * 0.06 * moving) * ry(look))
		layer(pose, "Head2", ry(look * 0.7 + 0.1 * math.sin(t * 0.8)))
		layer(pose, "Head3", ry(-look * 0.7 - 0.1 * math.sin(t * 0.7)))
		local pant = (math.sin(t * 9) * 0.5 + 0.5) * 0.18 * moving
		layer(pose, "Jaw", rx(pant))
		layer(pose, "Jaw2", rx(pant))
		layer(pose, "Jaw3", rx(pant))
		layer(pose, "Tail", ry(math.sin(t * (4 + speed * 0.3)) * 0.45) * rx(-0.15))
		layer(pose, "Tail2", ry(math.sin(t * (4 + speed * 0.3) - 0.7) * 0.4))
		layer(pose, "Tail3", ry(math.sin(t * (4 + speed * 0.3) - 1.4) * 0.4))
		local flap = math.sin(t * 1.3 + r.seed) * 0.1
		layer(pose, "WingR", rz(0.35 + flap))
		layer(pose, "WingL", rz(-0.35 - flap))
	elseif gait == "crawler" or gait == "hexapod" or gait == "spider" then
		local amp = (if gait == "spider" then 0.42 else 0.36) * moving + 0.02
		local w = p * (if gait == "spider" then 1.3 else 1.5)
		for k, jt in r.legsR do
			-- (tripods: right 1 and 3 with left 2; spiders in alternating fours)
			local off = if (k % 2 == 1) then 0 else math.pi
			local ph = w + off
			pose["LegR" .. k] = rz(math.max(0, math.sin(ph)) * amp * 0.9) * rx(math.cos(ph) * amp)
			local l = r.legsL[k]
			if l then
				local phl = w + off + math.pi
				pose["LegL" .. k] = rz(-math.max(0, math.sin(phl)) * amp * 0.9) * rx(math.cos(phl) * amp)
			end
		end
		layer(pose, "Body", pos(0, math.abs(math.sin(w)) * 0.05 * s * moving, 0) * rx(breathe * 0.4))
		layer(pose, "Abdomen", rx(math.sin(t * 1.5 + r.seed) * 0.05) * ry(math.sin(w) * 0.05 * moving))
		local work = math.sin(t * 6 + r.seed) * 0.12
		layer(pose, "MandR", ry(-work))
		layer(pose, "MandL", ry(work))
		layer(pose, "AntR", rx(math.sin(t * 3.1 + r.seed) * 0.2) * rz(math.sin(t * 2.3) * 0.15))
		layer(pose, "AntL", rx(math.sin(t * 2.7 + r.seed + 1) * 0.2) * rz(-math.sin(t * 2.1) * 0.15))
		layer(pose, "Head", ry(math.sin(t * 0.9 + r.seed) * 0.15 * (1 - moving)))
		-- a scorpion's tail sways, poised; a mantis's scythes held folded
		for k = 1, 6 do
			layer(pose, if k == 1 then "Tail" else "Tail" .. k, rx(math.sin(t * 1.4 - k * 0.5 + r.seed) * 0.06) * ry(math.sin(t * 1.1 - k * 0.4) * 0.05))
		end
		layer(pose, "ArmR", rx(math.sin(t * 1.3 + r.seed) * 0.08))
		layer(pose, "ArmL", rx(math.sin(t * 1.3 + r.seed + 0.5) * 0.08))
	elseif gait == "slither" or gait == "serpent" then
		local speedW = 2.2 + moving * 2.8
		for k = 1, 12 do
			local key = "Seg" .. k
			if not j[key] then
				break
			end
			layer(pose, key, ry(math.sin(t * speedW - k * 0.75 + r.seed) * (0.14 + moving * 0.12)) * rx(math.sin(t * 1.1 - k * 0.5) * 0.03))
		end
		layer(pose, "Neck", ry(math.sin(t * 1.2 + r.seed) * 0.12) * rx(math.sin(t * 0.9) * 0.06 + breathe))
		layer(pose, "Head", ry(-math.sin(t * 1.2 + r.seed) * 0.1) * rx(math.sin(t * 1.6) * 0.05))
		layer(pose, "Jaw", rx(math.max(0, math.sin(t * 0.7 + r.seed)) * 0.15))
		layer(pose, "Torso", rz(math.sin(t * 1.4 + r.seed) * 0.05) * rx(breathe))
		layer(pose, "ArmR", rx(math.sin(p) * 0.35 * moving + 0.1))
		layer(pose, "ArmL", rx(-math.sin(p) * 0.35 * moving + 0.1))
		layer(pose, "ArmR2", rx(-math.sin(p) * 0.3 * moving + 0.4))
		layer(pose, "ArmL2", rx(math.sin(p) * 0.3 * moving + 0.4))
		layer(pose, "MandR", ry(-math.sin(t * 6) * 0.15))
		layer(pose, "MandL", ry(math.sin(t * 6) * 0.15))
		layer(pose, "AntR", rx(math.sin(t * 3) * 0.2))
		layer(pose, "AntL", rx(math.sin(t * 2.6 + 1) * 0.2))
	elseif gait == "swim" then
		for k = 1, 6 do
			local key = "Seg" .. k
			if not j[key] then
				break
			end
			layer(pose, key, rx(math.sin(t * (2.4 + moving * 2) - k * 0.8 + r.seed) * 0.2))
		end
		layer(pose, "Torso", pos(0, math.sin(t * 1.6 + r.seed) * 0.12 * s, 0) * rx(-0.1 * moving + breathe))
		layer(pose, "ArmR", rx(math.sin(t * 1.8) * 0.2 + 0.15))
		layer(pose, "ArmL", rx(-math.sin(t * 1.8) * 0.2 + 0.15))
		layer(pose, "Head", ry(math.sin(t * 0.6 + r.seed) * 0.25))
	elseif gait == "flyer" then
		local insect = r.family == "ants"
		local freq = if insect then 28 else 5 + moving * 4
		local beat = math.sin(t * freq + r.phase * 0.1)
		local amp = if insect then 0.35 else 0.72
		if r.airborne then
			beat, amp = 0.6, 0.9 -- (swept back in a dive)
		end
		layer(pose, "WingR", rz(beat * amp) * ry(if r.airborne then 0.6 else 0))
		layer(pose, "WingL", rz(-beat * amp) * ry(if r.airborne then -0.6 else 0))
		local bob = -beat * 0.12 * s * (if insect then 0.2 else 1)
		layer(pose, "Body", pos(0, bob, 0) * rx(0.15 * moving))
		layer(pose, "Torso", pos(0, bob, 0) * rx(-0.25 * moving))
		layer(pose, "Head", rx(-0.1 * moving) * ry(math.sin(t * 0.9 + r.seed) * 0.2))
		layer(pose, "Tail", ry(math.sin(t * 2.2) * 0.25) * rx(math.sin(t * 1.7) * 0.12))
		layer(pose, "Tail2", ry(math.sin(t * 2.2 - 0.7) * 0.3))
		layer(pose, "Tail3", ry(math.sin(t * 2.2 - 1.4) * 0.35))
		layer(pose, "LegR", rx(0.5 + (if r.airborne then -0.6 else 0)))
		layer(pose, "LegL", rx(0.5 + (if r.airborne then -0.6 else 0)))
		for k, jt in r.legsR do
			pose["LegR" .. k] = rz(0.3) * rx(math.sin(t * 2 + k) * 0.1)
			local l = r.legsL[k]
			if l then
				pose["LegL" .. k] = rz(-0.3) * rx(math.sin(t * 2 + k + 1) * 0.1)
			end
		end
		layer(pose, "AntR", rx(math.sin(t * 3) * 0.15))
		layer(pose, "AntL", rx(math.sin(t * 3.2) * 0.15))
		layer(pose, "Jaw", rx(math.max(0, math.sin(t * 0.8)) * 0.15))
	elseif gait == "float" then
		local drift = math.sin(t * 1.3 + r.phase * 0.1)
		layer(pose, "Torso", pos(0, math.sin(t * 1.1 + r.seed) * 0.15 * s, 0) * rz(math.sin(t * 0.8) * 0.03) * rx(-0.12 * moving))
		layer(pose, "ArmR", rx(-0.35 + drift * 0.18) * rz(0.12))
		layer(pose, "ArmL", rx(-0.35 - drift * 0.18) * rz(-0.12))
		layer(pose, "Head", ry(math.sin(t * 0.5 + r.seed) * 0.2) * rx(-breathe))
	elseif gait == "blob" then
		local wob = math.sin(t * (3 + moving * 5) + r.seed)
		layer(pose, "Body", pos(0, wob * 0.12 * s, 0) * rz(wob * 0.06) * rx(math.cos(t * 2.3) * 0.05))
		layer(pose, "Nucleus", pos(math.sin(t * 1.7) * 0.25, math.sin(t * (3 + moving * 4) + r.phase) * 0.3, math.cos(t * 1.3) * 0.25) * ry(t * 1.5))
	elseif gait == "orbit" then
		local spin = t * (1.4 + (if casting then 3 else 0)) + r.seed
		for k = 1, 8 do
			local key = "Orb" .. k
			if not j[key] then
				break
			end
			layer(pose, key, ry(spin) * pos(0, math.sin(t * 2 + k) * 0.2 * s, 0))
		end
		layer(pose, "Torso", pos(0, math.sin(t * 1.5 + r.seed) * 0.12 * s, 0) * ry(math.sin(t * 0.7) * 0.15))
		layer(pose, "ArmR", pos(0, math.sin(t * 1.9 + 1) * 0.15 * s, 0))
		layer(pose, "ArmL", pos(0, math.sin(t * 1.9) * 0.15 * s, 0))
	elseif gait == "hop" then
		-- a hop every stride while it moves; still otherwise
		local hop = math.max(0, math.sin(p * 0.75)) * moving
		layer(pose, "Body", pos(0, hop * 0.9 * s, 0) * rx(-hop * 0.25 + breathe))
		layer(pose, "Torso", pos(0, hop * 0.6 * s, 0) * rx(breathe))
		layer(pose, "LegR", rx(hop * 0.9 - 0.1 * moving))
		layer(pose, "LegL", rx(hop * 0.9 - 0.1 * moving))
		layer(pose, "LegR1", rz(hop * 0.4))
		layer(pose, "LegL1", rz(-hop * 0.4))
		layer(pose, "ArmR", rx(-hop * 0.6))
		layer(pose, "ArmL", rx(-hop * 0.6))
		layer(pose, "Head", ry(math.sin(t * 0.8 + r.seed) * 0.2 * (1 - moving)))
		layer(pose, "Jaw", rx(math.max(0, math.sin(t * 1.3 + r.seed)) * 0.08))
		layer(pose, "AntR", rx(math.sin(t * 3) * 0.2))
		layer(pose, "AntL", rx(math.sin(t * 3.3) * 0.2))
		layer(pose, "Tail", ry(math.sin(t * 2.4) * 0.3))
		layer(pose, "Tail2", ry(math.sin(t * 2.4 - 0.8) * 0.4))
		layer(pose, "WingR", rz(math.sin(t * 14) * 0.4))
		layer(pose, "WingL", rz(-math.sin(t * 14) * 0.4))
		-- a mimic's lid: shut while it waits, chattering as it comes
		if r.disguised then
			layer(pose, "Lid", IDENT)
		else
			layer(pose, "Lid", rx(-(0.35 + math.max(0, math.sin(t * 7)) * 0.35 * (0.4 + moving))))
		end
		for k = 1, 2 do
			layer(pose, "LegR" .. k, rx(math.sin(p * 2 + k) * 0.4 * moving))
			layer(pose, "LegL" .. k, rx(-math.sin(p * 2 + k) * 0.4 * moving))
		end
	elseif gait == "tentacled" then
		for k = 1, 10 do
			local key = "Tent" .. k
			if not j[key] then
				break
			end
			local w = math.sin(t * (1.6 + moving * 2) + k * 1.3 + r.seed)
			layer(pose, key, rx(w * 0.25) * rz(math.cos(t * 1.2 + k) * 0.12))
			layer(pose, key .. "b", rx(w * 0.4))
		end
		layer(pose, "Body", pos(0, math.sin(t * 1.4 + r.seed) * 0.1 * s, 0) * rz(math.sin(t * 0.9) * 0.04))
		layer(pose, "Head", ry(math.sin(t * 0.7 + r.seed) * 0.3) * rx(math.sin(t * 1.1) * 0.08))
	end

	-- ── an attack (its own move by style) ──
	if wind > 0 or strike > 0 then
		local st = atkStyle
		if st == "swing" then
			local arm = rx(wind * 2.5 - strike * 0.6 + strike * 0.2)
			layer(pose, "ArmR", arm)
			layer(pose, "ArmR2", arm)
			layer(pose, "Torso", ry(wind * 0.25 - strike * 0.35) * rx(-strike * 0.15))
			if j.ArmL and not j.ArmL2 then
				layer(pose, "ArmL", rx(wind * 0.6))
			end
		elseif st == "slam" then
			layer(pose, "ArmR", rx(wind * 2.7 - strike * 0.4))
			layer(pose, "ArmL", rx(wind * 2.7 - strike * 0.4))
			layer(pose, "Torso", rx(wind * 0.15 - strike * 0.35))
			layer(pose, "Body", pos(0, (wind * 0.3 - strike * 0.25) * s, 0))
		elseif st == "claw" then
			local first = a < 0.5
			layer(pose, "ArmR", rx(wind * 2.0 + (if first then -strike * 0.5 else 0)) * rz(wind * 0.4))
			layer(pose, "ArmL", rx((if first then 0 else strike * 1.6) + wind * 0.6) * rz(-strike * 0.4))
			layer(pose, "Torso", ry(-strike * 0.25) * rx(-strike * 0.2))
			layer(pose, "Body", rx(-strike * 0.12))
			layer(pose, "Head", rx(wind * 0.2))
		elseif st == "bite" or st == "peck" or st == "gore" then
			local lunge = strike * 0.55 * s
			local down = if st == "gore" then strike * 0.35 + wind * 0.3 else strike * 0.15
			layer(pose, "Head", pos(0, 0, -lunge) * rx(-down + wind * 0.25))
			layer(pose, "Head2", pos(0, 0, -lunge) * rx(-down))
			layer(pose, "Head3", pos(0, 0, -lunge) * rx(-down))
			layer(pose, "Neck", rx(-strike * 0.25 + wind * 0.2))
			local open = if st == "bite" then wind * 0.7 + strike * 0.1 else 0
			layer(pose, "Jaw", rx(open))
			layer(pose, "Jaw2", rx(open))
			layer(pose, "Jaw3", rx(open))
			layer(pose, "Lid", rx(-open * 1.2))
			layer(pose, "Body", pos(0, 0, -strike * 0.3 * s) * rx(-strike * 0.08))
			layer(pose, "Torso", rx(-strike * 0.3 + wind * 0.1))
			layer(pose, "MandR", ry(wind * 0.6 - strike * 0.3))
			layer(pose, "MandL", ry(-wind * 0.6 + strike * 0.3))
		elseif st == "lunge" then
			layer(pose, "ArmR", rx(wind * 1.6 - strike * 0.4))
			layer(pose, "ArmL", rx(wind * 1.6 - strike * 0.4))
			for k = 1, 1 do
				local lr, ll = r.legsR[k], r.legsL[k]
				if lr and ll then
					layer(pose, "LegR1", rz(wind * 0.9 - strike * 0.3))
					layer(pose, "LegL1", rz(-wind * 0.9 + strike * 0.3))
				end
			end
			layer(pose, "Body", pos(0, wind * 0.15 * s, -strike * 0.4 * s) * rx(wind * 0.2 - strike * 0.2))
			layer(pose, "Torso", rx(wind * 0.2 - strike * 0.4))
			layer(pose, "MandR", ry(wind * 0.5))
			layer(pose, "MandL", ry(-wind * 0.5))
		elseif st == "shoot" then
			layer(pose, "ArmL", rx(0.25))
			layer(pose, "ArmR", rx(0.45 * wind) * pos(0, 0, wind * 0.35 * s))
			layer(pose, "Torso", ry(wind * 0.25))
			layer(pose, "Head", rx(-strike * 0.15))
		elseif st == "cast" then
			layer(pose, "ArmR", rx(wind * 1.4 + strike * 1.6))
			layer(pose, "ArmL", rx(wind * 1.4 + strike * 1.6))
			layer(pose, "Torso", rx(wind * 0.12 - strike * 0.2))
			layer(pose, "Head", rx(wind * 0.2))
			layer(pose, "Body", pos(0, wind * 0.3 * s, 0))
		elseif st == "sting" then
			for k = 1, 6 do
				layer(pose, if k == 1 then "Tail" else "Tail" .. k, rx(-wind * 0.18 + strike * 0.32))
			end
			layer(pose, "ArmR", rx(wind * 0.4))
			layer(pose, "ArmL", rx(wind * 0.4))
			layer(pose, "Body", rx(-strike * 0.1))
		elseif st == "whip" then
			for k = 1, 10 do
				layer(pose, "Tent" .. k, rx(wind * 0.7 - strike * 1.1))
				layer(pose, "Tent" .. k .. "b", rx(-strike * 0.8))
			end
			layer(pose, "ArmR", rx(wind * 2.2 - strike * 0.8))
			layer(pose, "ArmL", rx(wind * 1.0 + strike * 1.4))
			layer(pose, "Torso", rx(-strike * 0.2))
		end
	end

	-- ── a wind-up (Casting / Charging) ──
	if castK > 0 then
		local tremble = math.sin(t * 31) * 0.04
		if gait == "quad" or gait == "serpent" or gait == "slither" or gait == "flyer" then
			-- (a breath, a spit, a gaze: the head comes up, the jaw opens)
			layer(pose, "Head", rx(0.35 * castK + tremble))
			layer(pose, "Neck", rx(0.2 * castK))
			layer(pose, "Jaw", rx(0.8 * castK))
			layer(pose, "Jaw2", rx(0.8 * castK))
			layer(pose, "Jaw3", rx(0.8 * castK))
		end
		if atkStyle == "shoot" then
			layer(pose, "ArmR", pos(0, 0, 0.35 * s * castK) * rx(0.5 * castK))
			layer(pose, "ArmL", rx(0.25 * castK))
		else
			layer(pose, "ArmR", rx(2.0 * castK + tremble) * rz(-0.25 * castK))
			layer(pose, "ArmL", rx(2.0 * castK - tremble) * rz(0.25 * castK))
		end
		layer(pose, "Torso", rx(0.08 * castK))
		layer(pose, "Head", rx(0.15 * castK))
		for k = 1, 10 do
			layer(pose, "Tent" .. k, rx(-0.4 * castK))
		end
	end
	if chargeK > 0 then
		local lean = 0.32 * chargeK
		layer(pose, "Torso", rx(-lean))
		layer(pose, "Body", rx(-lean * 0.4) * pos(0, -0.12 * s * chargeK, 0))
		layer(pose, "Head", rx(-lean * 0.6))
		layer(pose, "ArmR", rx(-0.6 * chargeK))
		layer(pose, "ArmL", rx(-0.6 * chargeK))
		layer(pose, "Neck", rx(-lean * 0.5))
		for k = 1, 6 do
			layer(pose, if k == 1 then "Tail" else "Tail" .. k, rx(-0.25 * chargeK))
		end
	end
	-- ── a flinch when it's hurt ──
	local hurt = t - r.hurtT
	if hurt >= 0 and hurt < 0.28 then
		local k = math.sin(hurt / 0.28 * math.pi)
		layer(pose, "Torso", rx(0.22 * k) * rz(0.06 * k))
		layer(pose, "Body", rx(0.12 * k) * pos(0, 0, 0.15 * s * k))
		layer(pose, "Head", rx(0.3 * k))
		layer(pose, "ArmR", rz(0.3 * k))
		layer(pose, "ArmL", rz(-0.3 * k))
	end
	if r.disguised then
		pose = { Lid = IDENT }
	end

	-- ── set the joints ──
	for name, jt in j do
		jt.Transform = pose[name] or IDENT
	end

	-- ── underground, falling, glowing ──
	local sink = 0
	if r.burrowed then
		r.burrowK = math.min(1, (r.burrowK or 0) + dt * 3)
	else
		r.burrowK = math.max(0, (r.burrowK or 0) - dt * 3)
	end
	sink = r.burrowK * (r.hip + 2 * s)
	if r.deathT then
		local e = ease((t - r.deathT) / 0.7)
		local side = if r.seed % 2 > 1 then 1 else -1
		for _, jt in r.top do
			jt.Transform = pos(0, -(r.hip * 0.8 + s * 0.4) * e - sink, 0) * rz(side * 1.25 * e) * rx(-0.3 * e) * jt.Transform
		end
		if not r.faded or r.faded < e then
			r.faded = e
			for _, d in r.model:GetDescendants() do
				if d:IsA("BasePart") then
					d.LocalTransparencyModifier = e * 0.85
				end
			end
		end
	elseif sink > 0 then
		for _, jt in r.top do
			jt.Transform = pos(0, -sink, 0) * jt.Transform
		end
	end
	local light = r.light
	if light then
		local want = if r.deathT then 0 elseif casting or charging then 4 elseif r.hot then 3 else 1.4
		light.Brightness += (want - light.Brightness) * math.min(1, dt * 6)
		if r.hot and not r.hotColor then
			r.baseColor = light.Color
			light.Color = Color3.fromRGB(255, 90, 50)
			r.hotColor = true
		elseif not r.hot and r.hotColor then
			light.Color = r.baseColor or light.Color
			r.hotColor = false
		end
	end
end
MonsterAnim.animate = animate

-- ══ the monsters' special attacks, drawn from what the server announces ══════════════
-- d = { fx = "monster", what, at, to?, dir?, r?, len?, angle?, t?, c?, rank?, points? }
local effects: { any } = {}
MonsterAnim.effects = effects
MonsterAnim.fxParent = nil :: Instance?
local MAX_FX_PARTS = 120
local fxParts = 0

local function v3(t: any): Vector3
	if typeof(t) == "Vector3" then
		return t
	end
	if type(t) == "table" then
		return Vector3.new(t[1] or 0, t[2] or 0, t[3] or 0)
	end
	return Vector3.zero
end
local function col(c: any, default: Color3): Color3
	if typeof(c) == "Color3" then
		return c
	end
	if type(c) == "table" then
		return Color3.fromRGB(c[1] or 255, c[2] or 255, c[3] or 255)
	end
	return default
end

local function fxPart(size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, shape: Enum.PartType?, transparency: number?): BasePart?
	if fxParts >= MAX_FX_PARTS then
		return nil
	end
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat or Enum.Material.Neon
	if shape then
		p.Shape = shape
	end
	p.Transparency = transparency or 0
	local parent = MonsterAnim.fxParent
	if not parent then
		local ok, cam = pcall(function()
			return Workspace.CurrentCamera
		end)
		parent = if ok and typeof(cam) == "Instance" then cam else nil
	end
	if parent then
		p.Parent = parent
	end
	fxParts += 1
	return p
end

-- an effect: parts, a life, and how each looks at alpha (0..1)
local function effect(life: number, parts: { BasePart? }, update: (number, { BasePart }) -> ())
	local list = {}
	for _, p in parts do
		if p then
			table.insert(list, p)
		end
	end
	table.insert(effects, { t = 0, life = math.max(0.05, life), parts = list, update = update })
end

local function ground(v: Vector3): Vector3
	return Vector3.new(v.X, v.Y - 2.6, v.Z)
end

local DRAW = {}
-- a ring on the ground that fills over the wind-up: where it will land
DRAW.tele_ring = function(d)
	local at, r, life = ground(v3(d.at)), d.r or 8, d.t or 1
	local c = col(d.c, Color3.fromRGB(255, 70, 50))
	local disc = fxPart(Vector3.new(0.15, 1, 1), CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90)), c, Enum.Material.Neon, Enum.PartType.Cylinder, 0.55)
	local rim = fxPart(Vector3.new(0.1, r * 2, r * 2), CFrame.new(at + Vector3.new(0, -0.02, 0)) * CFrame.Angles(0, 0, math.rad(90)), c, Enum.Material.ForceField, Enum.PartType.Cylinder, 0.2)
	effect(life, { disc, rim }, function(a, ps)
		local k = math.max(0.05, a) * r * 2
		ps[1].Size = Vector3.new(0.15, k, k)
		ps[1].Transparency = 0.65 - a * 0.25
		if ps[2] then
			ps[2].Transparency = 0.2 + math.sin(a * 20) * 0.1
		end
	end)
end
-- a wedge on the ground in front of it: a breath, a gaze, a sweep
DRAW.tele_cone = function(d)
	local at, dir = ground(v3(d.at)), v3(d.dir)
	if dir.Magnitude < 0.01 then
		dir = Vector3.new(0, 0, -1)
	end
	dir = Vector3.new(dir.X, 0, dir.Z).Unit
	local len, ang, life = d.len or 16, math.rad(d.angle or 30), d.t or 1
	local c = col(d.c, Color3.fromRGB(255, 120, 50))
	local parts = {}
	for k = -2, 2 do
		local yaw = ang * k / 2
		local dd = CFrame.fromAxisAngle(Vector3.yAxis, yaw):VectorToWorldSpace(dir)
		table.insert(parts, fxPart(Vector3.new(len * 0.18, 0.12, len), CFrame.lookAt(at + dd * len / 2, at + dd * len), c, Enum.Material.Neon, nil, 0.6))
	end
	effect(life, parts, function(a, ps)
		for _, p in ps do
			p.Transparency = 0.75 - a * 0.35
		end
	end)
end
-- a line on the ground: a charge's path, a quake's
DRAW.tele_line = function(d)
	local a0, b0 = ground(v3(d.at)), ground(v3(d.to))
	local w, life = d.r or 4, d.t or 0.8
	local c = col(d.c, Color3.fromRGB(255, 90, 60))
	local len = math.max(0.5, (b0 - a0).Magnitude)
	local p = fxPart(Vector3.new(w, 0.12, len), CFrame.lookAt((a0 + b0) / 2, b0), c, Enum.Material.Neon, nil, 0.65)
	effect(life, { p }, function(a, ps)
		ps[1].Transparency = 0.75 - a * 0.3
	end)
end
-- something thrown or spat or shot: flies from `at` to `to` in `t` (lobbed if d.lob)
DRAW.shot = function(d)
	local a0, b0, life = v3(d.at), v3(d.to), d.t or 0.4
	local c = col(d.c, Color3.fromRGB(230, 230, 220))
	local kind = d.kind or "ball"
	local size = d.size or (if kind == "boulder" then 2.2 elseif kind == "arrow" then 0.25 else 1)
	local shape = if kind == "arrow" then nil else Enum.PartType.Ball
	local mat = if kind == "boulder" then Enum.Material.Slate elseif kind == "arrow" then Enum.Material.SmoothPlastic else Enum.Material.Neon
	local p = fxPart(if kind == "arrow" then Vector3.new(0.18, 0.18, 2.6) else Vector3.one * size, CFrame.new(a0), c, mat, shape)
	effect(life, { p }, function(a, ps)
		local h = if d.lob then math.sin(a * math.pi) * math.max(6, (b0 - a0).Magnitude * 0.35) else 0
		local here = a0:Lerp(b0, a) + Vector3.new(0, h, 0)
		if kind == "arrow" then
			local nxt = a0:Lerp(b0, math.min(1, a + 0.05)) + Vector3.new(0, if d.lob then math.sin(math.min(1, a + 0.05) * math.pi) * math.max(6, (b0 - a0).Magnitude * 0.35) else 0, 0)
			ps[1].CFrame = CFrame.lookAt(here, if (nxt - here).Magnitude > 0.01 then nxt else here + (b0 - a0).Unit)
		else
			ps[1].CFrame = CFrame.new(here) * CFrame.Angles(a * 6, a * 4, 0)
		end
	end)
end
-- a burst where something landed
DRAW.burst = function(d)
	local at, r = v3(d.at), d.r or 5
	local c = col(d.c, Color3.fromRGB(255, 160, 80))
	local ball = fxPart(Vector3.one, CFrame.new(at), c, Enum.Material.Neon, Enum.PartType.Ball, 0.2)
	local ring = fxPart(Vector3.new(0.3, 1, 1), CFrame.new(ground(at) + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90)), c, Enum.Material.Neon, Enum.PartType.Cylinder, 0.3)
	effect(0.45, { ball, ring }, function(a, ps)
		ps[1].Size = Vector3.one * (0.5 + a * r * 1.2)
		ps[1].Transparency = 0.2 + a * 0.8
		if ps[2] then
			ps[2].Size = Vector3.new(0.3, 1 + a * r * 2.2, 1 + a * r * 2.2)
			ps[2].Transparency = 0.3 + a * 0.7
		end
	end)
end
-- a stream from the mouth: fire, frost, a gaze
DRAW.cone = function(d)
	local at, dir = v3(d.at), v3(d.dir)
	if dir.Magnitude < 0.01 then
		dir = Vector3.new(0, 0, -1)
	end
	dir = dir.Unit
	local len, ang, life = d.len or 16, math.rad(d.angle or 30), d.t or 0.7
	local c = col(d.c, Color3.fromRGB(255, 130, 40))
	local parts, dirs = {}, {}
	for k = 1, 9 do
		local yaw = (math.random() * 2 - 1) * ang
		local dd = CFrame.fromAxisAngle(Vector3.yAxis, yaw):VectorToWorldSpace(dir)
		table.insert(dirs, { dd = dd, delay = (k - 1) / 9 * 0.45 })
		table.insert(parts, fxPart(Vector3.one, CFrame.new(at), if k % 3 == 0 then Color3.new(1, 1, 0.85) else c, Enum.Material.Neon, Enum.PartType.Ball, 0.2))
	end
	effect(life, parts, function(a, ps)
		for i, p in ps do
			local q = dirs[i]
			local k = math.clamp((a - q.delay) / 0.55, 0, 1)
			p.CFrame = CFrame.new(at + q.dd * len * k)
			p.Size = Vector3.one * (0.6 + k * len * 0.22)
			p.Transparency = if k <= 0 then 1 else 0.15 + k * 0.85
		end
	end)
end
-- a beam between two points (a drain, a gaze held)
DRAW.beam = function(d)
	local a0, b0, life = v3(d.at), v3(d.to), d.t or 0.8
	local c = col(d.c, Color3.fromRGB(170, 120, 255))
	local len = math.max(0.5, (b0 - a0).Magnitude)
	local p = fxPart(Vector3.new(0.5, 0.5, len), CFrame.lookAt((a0 + b0) / 2, b0), c, Enum.Material.Neon, nil, 0.2)
	effect(life, { p }, function(a, ps)
		local w = 0.35 + math.sin(a * 40) * 0.15
		ps[1].Size = Vector3.new(w, w, len)
		ps[1].Transparency = 0.2 + a * 0.7
	end)
end
-- arrows raining into a circle
DRAW.rain = function(d)
	local c0, r, life = ground(v3(d.at)), d.r or 8, d.t or 0.7
	local c = col(d.c, Color3.fromRGB(220, 220, 200))
	local parts, spots = {}, {}
	for k = 1, 10 do
		local o = Vector3.new((math.random() - 0.5) * 2 * r, 0, (math.random() - 0.5) * 2 * r)
		table.insert(spots, { o = o, delay = math.random() * 0.4 })
		table.insert(parts, fxPart(Vector3.new(0.15, 0.15, 2.4), CFrame.new(c0 + o + Vector3.new(0, 40, 0)), c, Enum.Material.SmoothPlastic))
	end
	effect(life, parts, function(a, ps)
		for i, p in ps do
			local q = spots[i]
			local k = math.clamp((a - q.delay) / 0.45, 0, 1)
			local top = c0 + q.o + Vector3.new(4, 30, 0)
			local here = top:Lerp(c0 + q.o, k)
			p.CFrame = CFrame.lookAt(here, here + (c0 + q.o - top).Unit)
		end
	end)
end
-- lightning out of the sky
DRAW.bolt = function(d)
	local at = v3(d.at)
	local c = col(d.c, Color3.fromRGB(190, 230, 255))
	local parts = {}
	local prev = at + Vector3.new(0, 60, 0)
	for k = 1, 6 do
		local nxt = at + Vector3.new((math.random() - 0.5) * 6, 60 - k * 10, (math.random() - 0.5) * 6)
		if k == 6 then
			nxt = at
		end
		table.insert(parts, fxPart(Vector3.new(0.6, 0.6, (nxt - prev).Magnitude), CFrame.lookAt((prev + nxt) / 2, nxt), c, Enum.Material.Neon))
		prev = nxt
	end
	effect(0.35, parts, function(a, ps)
		for _, p in ps do
			p.Transparency = if a < 0.5 then (math.sin(a * 60) > 0 and 0 or 0.5) else a
		end
	end)
	DRAW.burst({ at = at, r = d.r or 5, c = d.c })
end
-- a meteor falling onto the spot
DRAW.meteor = function(d)
	local at, life = v3(d.at), d.t or 0.6
	local c = col(d.c, Color3.fromRGB(255, 120, 40))
	local from = at + Vector3.new(18, 70, 10)
	local rock = fxPart(Vector3.one * 3.5, CFrame.new(from), Color3.fromRGB(60, 40, 30), Enum.Material.CrackedLava, Enum.PartType.Ball)
	local glow = fxPart(Vector3.one * 5, CFrame.new(from), c, Enum.Material.Neon, Enum.PartType.Ball, 0.5)
	effect(life, { rock, glow }, function(a, ps)
		local here = from:Lerp(at, a * a)
		for _, p in ps do
			p.CFrame = CFrame.new(here)
		end
	end)
end
-- rocks bursting up along a line
DRAW.quake = function(d)
	local a0, b0 = ground(v3(d.at)), ground(v3(d.to))
	local c = col(d.c, Color3.fromRGB(120, 100, 80))
	local parts = {}
	for k = 1, 7 do
		local here = a0:Lerp(b0, k / 7)
		table.insert(parts, fxPart(Vector3.new(1.6, 2.6, 1.6), CFrame.new(here - Vector3.new(0, 2, 0)) * CFrame.Angles(math.random() - 0.5, math.random() * 3, math.random() - 0.5), c, Enum.Material.Slate))
	end
	effect(0.9, parts, function(a, ps)
		for i, p in ps do
			local k = math.clamp(a * 2 - i * 0.1, 0, 1)
			local here = a0:Lerp(b0, i / 7)
			p.CFrame = CFrame.new(here + Vector3.new(0, -2 + math.sin(k * math.pi) * 2.6, 0)) * CFrame.Angles(0.3, i, 0.2)
			p.Transparency = if a > 0.8 then (a - 0.8) * 5 else 0
		end
	end)
end
-- green motes rising where an ally was mended, and a thread back to the healer
DRAW.heal = function(d)
	local c = col(d.c, Color3.fromRGB(120, 255, 170))
	for _, pt in d.points or { d.to or d.at } do
		local at = v3(pt)
		local parts = {}
		for k = 1, 5 do
			table.insert(parts, fxPart(Vector3.one * 0.5, CFrame.new(at + Vector3.new(math.cos(k * 1.3) * 1.5, -1, math.sin(k * 1.3) * 1.5)), c, Enum.Material.Neon, Enum.PartType.Ball, 0.1))
		end
		effect(0.9, parts, function(a, ps)
			for i, p in ps do
				p.CFrame = CFrame.new(at + Vector3.new(math.cos(i * 1.3 + a * 3) * 1.5, -1 + a * 5, math.sin(i * 1.3 + a * 3) * 1.5))
				p.Transparency = a
			end
		end)
	end
	if d.to and d.at then
		DRAW.beam({ at = d.at, to = d.to, c = d.c or { 120, 255, 170 }, t = 0.5 })
	end
end
-- a war cry or a howl: a ring off the caster, and a glow on everyone it reaches
DRAW.buff = function(d)
	local at, r = v3(d.at), d.r or 30
	local c = col(d.c, Color3.fromRGB(255, 110, 60))
	local ring = fxPart(Vector3.new(0.4, 2, 2), CFrame.new(ground(at) + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90)), c, Enum.Material.Neon, Enum.PartType.Cylinder, 0.2)
	effect(0.8, { ring }, function(a, ps)
		ps[1].Size = Vector3.new(0.4, 2 + a * r * 2, 2 + a * r * 2)
		ps[1].Transparency = 0.2 + a * 0.8
	end)
	for _, pt in d.points or {} do
		local p = v3(pt)
		local pillar = fxPart(Vector3.new(3, 6, 3), CFrame.new(p + Vector3.new(0, 1, 0)), c, Enum.Material.ForceField, Enum.PartType.Ball, 0.3)
		effect(0.7, { pillar }, function(a, ps)
			ps[1].Transparency = 0.3 + a * 0.7
		end)
	end
end
-- a summoning circle where something is called up
DRAW.summon = function(d)
	local at = ground(v3(d.at))
	local c = col(d.c, Color3.fromRGB(170, 90, 255))
	local disc = fxPart(Vector3.new(0.15, 1, 1), CFrame.new(at) * CFrame.Angles(0, 0, math.rad(90)), c, Enum.Material.Neon, Enum.PartType.Cylinder, 0.3)
	local col_ = fxPart(Vector3.new(2, 1, 2), CFrame.new(at), c, Enum.Material.ForceField, Enum.PartType.Cylinder, 0.4)
	effect(d.t or 1.2, { disc, col_ }, function(a, ps)
		local r = (d.r or 6) * math.min(1, a * 3)
		ps[1].Size = Vector3.new(0.15, r * 2, r * 2)
		ps[1].CFrame = CFrame.new(at) * CFrame.Angles(0, a * 4, math.rad(90))
		if ps[2] then
			ps[2].Size = Vector3.new(a * 10, r * 1.2, r * 1.2)
			ps[2].CFrame = CFrame.new(at + Vector3.new(0, a * 5, 0)) * CFrame.Angles(0, 0, math.rad(90))
			ps[2].Transparency = 0.4 + a * 0.6
		end
	end)
end
-- dust where something charged, burrowed, landed
DRAW.dust = function(d)
	local pts = d.points or { d.at }
	local c = col(d.c, Color3.fromRGB(170, 150, 120))
	for _, pt in pts do
		local at = ground(v3(pt)) + Vector3.new(0, 0.6, 0)
		local puff = fxPart(Vector3.one * 2, CFrame.new(at), c, Enum.Material.SmoothPlastic, Enum.PartType.Ball, 0.3)
		effect(0.7, { puff }, function(a, ps)
			ps[1].Size = Vector3.one * (2 + a * (d.r or 4))
			ps[1].Transparency = 0.3 + a * 0.7
		end)
	end
end
-- a lingering cloud: spores, ink
DRAW.cloud = function(d)
	local at, r, life = ground(v3(d.at)) + Vector3.new(0, 2, 0), d.r or 7, d.t or 2
	local c = col(d.c, Color3.fromRGB(150, 200, 90))
	local parts = {}
	for k = 1, 5 do
		local o = Vector3.new(math.cos(k * 1.26) * r * 0.5, math.sin(k) * 0.8, math.sin(k * 1.26) * r * 0.5)
		table.insert(parts, fxPart(Vector3.one * r * 0.9, CFrame.new(at + o), c, Enum.Material.SmoothPlastic, Enum.PartType.Ball, 0.55))
	end
	effect(life, parts, function(a, ps)
		for _, p in ps do
			p.Transparency = 0.55 + a * 0.45
		end
	end)
end
-- a vanishing and an arrival
DRAW.blink = function(d)
	for _, pt in { d.at, d.to } do
		if pt then
			DRAW.burst({ at = pt, r = 3, c = d.c or { 170, 120, 255 } })
		end
	end
end
-- a shimmering bubble on something that's warded (the server's ForceField does the rest)
DRAW.shield = function(d)
	local at, r = v3(d.at), d.r or 5
	local c = col(d.c, Color3.fromRGB(150, 210, 255))
	local bubble = fxPart(Vector3.one * r * 2, CFrame.new(at), c, Enum.Material.ForceField, Enum.PartType.Ball, 0.2)
	effect(d.t or 1, { bubble }, function(a, ps)
		ps[1].Transparency = if a > 0.7 then 0.2 + (a - 0.7) * 2.6 else 0.2
	end)
end

function MonsterAnim.fx(d: any)
	if type(d) ~= "table" or type(d.what) ~= "string" then
		return
	end
	local draw = DRAW[d.what]
	if not draw then
		return
	end
	-- (far from this camera: not worth drawing)
	local ok, cam = pcall(function()
		return Workspace.CurrentCamera
	end)
	if ok and typeof(cam) == "Instance" and d.at then
		if ((cam :: Camera).CFrame.Position - v3(d.at)).Magnitude > FAR + 60 then
			return
		end
	end
	pcall(draw, d)
end

function MonsterAnim.stepFx(dt: number)
	for i = #effects, 1, -1 do
		local e = effects[i]
		e.t += dt
		local a = math.clamp(e.t / e.life, 0, 1)
		local ok = pcall(e.update, a, e.parts)
		if a >= 1 or not ok then
			for _, p in e.parts do
				p:Destroy()
				fxParts -= 1
			end
			table.remove(effects, i)
		end
	end
end

-- offline (tests, contact sheets): carry each joint's Transform to its parts, parents first
-- (pass the rig that posed it: offline, a joint's Transform is only kept on the reference that set it)
function MonsterAnim.applyOffline(model: Model, rig: any?)
	local root = model.PrimaryPart
	if not root then
		return
	end
	-- (parts are keyed by a number written on them: offline, one instance can come back as
	-- different values, so it can't key a table itself)
	local parts: { BasePart } = {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			table.insert(parts, d)
			d:SetAttribute("AnimKey", #parts)
		end
	end
	local function key(p: Instance?): number?
		local k = p and p:GetAttribute("AnimKey")
		return if type(k) == "number" then k else nil
	end
	local orig: { [number]: CFrame } = {}
	local motorOf: { [number]: Motor6D } = {}
	local weldOf: { [number]: number } = {}
	for i, p in parts do
		orig[i] = p.CFrame
	end
	for _, d in model:GetDescendants() do
		if d:IsA("Motor6D") and key(d.Part1) then
			motorOf[key(d.Part1) :: number] = d
		elseif d:IsA("WeldConstraint") and key(d.Part0) and key(d.Part1) then
			weldOf[key(d.Part1) :: number] = key(d.Part0) :: number
		end
	end
	local rootKey = key(root)
	local done: { [number]: CFrame } = {}
	if rootKey then
		done[rootKey] = root.CFrame
	end
	local function resolve(i: number): CFrame
		if done[i] then
			return done[i]
		end
		local cf = orig[i]
		local m = motorOf[i]
		local p0 = m and key(m.Part0)
		if m and p0 then
			local jn = (string.gsub(m.Name, "Joint$", ""))
			local from = if rig and rig.joints[jn] then rig.joints[jn] else m
			local ok, tf = pcall(function()
				return from.Transform
			end)
			cf = resolve(p0) * m.C0 * (if ok then tf else IDENT) * m.C1:Inverse()
		elseif weldOf[i] then
			local base = weldOf[i]
			cf = resolve(base) * orig[base]:ToObjectSpace(orig[i])
		end
		done[i] = cf
		return cf
	end
	for i in parts do
		resolve(i)
	end
	for i, p in parts do
		p.CFrame = done[i]
		p:SetAttribute("AnimKey", nil)
	end
end

function MonsterAnim.start(folderName: string?)
	local folder: Instance? = nil
	local function find()
		local world = Workspace:FindFirstChild(folderName or "BitLevelingLive")
		folder = world and world:FindFirstChild("LiveNPCs")
	end
	-- the server's announcements of special attacks (Remotes.HunterLive, fx = "monster")
	task.spawn(function()
		local shared = ReplicatedStorage:WaitForChild("LifeSim", 30)
		local remotes = shared and shared:WaitForChild("Remotes", 30)
		local ev = remotes and remotes:WaitForChild("HunterLive", 60)
		if ev and ev:IsA("RemoteEvent") then
			ev.OnClientEvent:Connect(function(d)
				if type(d) == "table" and d.fx == "monster" then
					MonsterAnim.fx(d)
				end
			end)
		end
	end)
	local frame = 0
	RunService.RenderStepped:Connect(function(dt)
		frame += 1
		MonsterAnim.stepFx(dt)
		if not folder or not folder.Parent then
			find()
			if not folder then
				return
			end
		end
		local cam = Workspace.CurrentCamera
		local eye = cam and cam.CFrame.Position or Vector3.zero
		local t = os.clock()
		for _, model in (folder :: Instance):GetChildren() do
			if model:IsA("Model") and model:GetAttribute("Gait") then
				local r = tracked[model]
				if r == nil then
					r = MonsterAnim.rig(model) or false
					tracked[model] = r
				end
				if r then
					local dist = (r.root.CFrame.Position - eye).Magnitude
					if dist < NEAR then
						animate(r, dt, t)
					elseif dist < FAR then
						-- (further off: every other frame, with the time that passed)
						r.skipped = (r.skipped or 0) + dt
						if frame % 2 == 0 then
							animate(r, r.skipped, t)
							r.skipped = 0
						end
					end
				end
			end
		end
	end)
end

return MonsterAnim
