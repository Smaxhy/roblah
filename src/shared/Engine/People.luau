--!strict
--[[
	PEOPLE YOU'VE MET (v0.12): acquaintances. Not family and not friends yet: a neighbor, a
	coworker, a kid from the academy, the cook at the night stall. pack.acquaintances =
	{ minAge, chance (a new face a year), cap (how many at once), drift (bond lost a year
	you don't talk), roles = { { text, when } } }. relationKinds.acquaintance is the kind.
	They can be talked to (the pack's interactions with kinds = { "acquaintance" }); one
	you're close enough to can be asked to be a friend (result.befriend); one you never talk
	to drifts out of your life (removed, quietly: they were never close).
	A result can introduce one too: result.meet = "a role" (or true for any that fits).
]]

local Rng = require(script.Parent.Rng)
local Conditions = require(script.Parent.Conditions)

local People = {}

function People.count(life: any): number
	local n = 0
	for _, r in life.relations do
		if r.alive and r.kind == "acquaintance" then
			n += 1
		end
	end
	return n
end

-- a new face. role: the words for who they are ("a neighbor from two floors down")
function People.meet(self: any, life: any, extra: { any }?, role: string?): any
	local cfg = self.pack.acquaintances
	if not cfg or not self.pack.relationKinds.acquaintance then
		return nil
	end
	if not role then
		local roles: { any } = {}
		for _, r in cfg.roles or {} do
			if Conditions.check(r.when, life, self.pack, { noChance = true }) then
				table.insert(roles, r)
			end
		end
		if #roles == 0 then
			return nil
		end
		local picked: any = Rng.pick(life, roles)
		role = picked and picked.text
	end
	local rel = self:addRelation(life, { kind = "acquaintance", bond = Rng.int(life, 12, 28) })
	-- kids meet kids; grown-ups meet grown-ups
	if life.age < 18 then
		rel.age = math.clamp(life.age + Rng.int(life, -2, 2), 5, 17)
	else
		rel.age = math.max(18, life.age + Rng.int(life, -8, 10))
	end
	rel.role = self:render(life, role or "someone from the neighborhood")
	rel.metAt = life.age
	if extra then
		table.insert(extra, { kind = "system", tone = "strange", text = "You met " .. rel.first .. ", " .. rel.role .. "." })
	end
	return rel
end

-- once a year: faces you never talk to fade; sometimes there's a new one
function People.yearly(self: any, life: any, report: any)
	local cfg = self.pack.acquaintances
	if not cfg or not life.alive or life.age < (cfg.minAge or 6) then
		return
	end
	for i = #life.relations, 1, -1 do
		local r = life.relations[i]
		if r.alive and r.kind == "acquaintance" then
			r.bond = math.max(0, r.bond - (cfg.drift or 3))
			if r.bond <= 0 and life.sceneRel ~= r.id and life.focusLink ~= r.id then
				table.remove(life.relations, i)
				self:push(life, report, { kind = "system", text = r.first .. " drifted out of your life. You never did get to know them." })
			end
		end
	end
	if People.count(life) < (cfg.cap or 6) and Rng.chance(life, cfg.chance or 0.3) then
		local extra = {}
		People.meet(self, life, extra)
		for _, e in extra do
			self:push(life, report, e)
		end
	end
end

return People
