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

	(v0.19) A meeting can say more about who they are (Engine/Party.luau reads it):
		meet = { role = "a Tanker from the next raid team", rank = 3 | "C" | { 2, 4 } | "near",
		         class = "tanker" | "any", hunter = true, kind = "acquaintance", bond = { 25, 40 },
		         age = { 20, 30 }, chance = 0.5, traits = { "brave" }, work = "Guild striker" }
	and a role in pack.acquaintances.roles can carry the same fields. Someone in your party,
	and anyone from the game's roster (rel.roster), never drifts away.
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

local function inParty(life: any, relId: number): boolean
	local p = life.party
	for _, m in (p and p.members) or {} do
		if m.rel == relId then
			return true
		end
	end
	return false
end

-- a new face. role: the words for who they are ("a neighbor from two floors down"), or a
-- table that also says their rank, class and the rest (see above)
function People.meet(self: any, life: any, extra: { any }?, role: any): any
	local cfg = self.pack.acquaintances
	if not cfg or not self.pack.relationKinds.acquaintance then
		return nil
	end
	local spec: any = nil
	if type(role) == "table" then
		spec = role
		if type(spec.chance) == "number" and not Rng.chance(life, spec.chance) then
			return nil
		end
		if spec.when and not Conditions.check(spec.when, life, self.pack, { noChance = true }) then
			return nil
		end
		role = spec.role or spec.text
	end
	if type(role) ~= "string" then
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
		spec = spec or picked
	end
	local kind = if spec and type(spec.kind) == "string" and self.pack.relationKinds[spec.kind] then spec.kind else "acquaintance"
	local add: any = { kind = kind, bond = if spec and spec.bond ~= nil then Rng.roll(life, spec.bond) else Rng.int(life, 12, 28) }
	-- kids meet kids; grown-ups meet grown-ups
	local function ageRoll(): number
		if life.age < 18 then
			return math.clamp(life.age + Rng.int(life, -2, 2), 5, 17)
		end
		return math.max(18, life.age + Rng.int(life, -8, 10))
	end
	local rel
	if self.pack.party then
		-- (v0.19) the age first, so their profile (Engine/Party) knows a child from a grown-up
		if spec then
			add.rank, add.class, add.hunter, add.traits, add.work, add.roster = spec.rank, spec.class, spec.hunter, spec.traits, spec.work, spec.roster
			add.name = spec.name
		end
		add.role = role
		add.age = if spec and spec.age ~= nil then Rng.roll(life, spec.age) else ageRoll()
		rel = self:addRelation(life, add)
	else
		-- (a pack without a party: the dice fall exactly as they always did)
		rel = self:addRelation(life, add)
		rel.age = ageRoll()
	end
	rel.role = self:render(life, role or "someone from the neighborhood")
	rel.metAt = life.age
	if extra then
		local who = rel.first
		if (rel.rank or 0) > 0 and self.pack.party then
			local letters = { "E", "D", "C", "B", "A", "S" }
			who = string.format("%s (%s-rank)", rel.first, letters[math.clamp(rel.rank, 1, 6)])
		end
		table.insert(extra, { kind = "system", tone = "strange", text = "You met " .. who .. ", " .. rel.role .. "." })
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
			-- (v0.19) the party, and the game's own named people, stay in your life
			local stays = inParty(life, r.id) or r.roster ~= nil
			r.bond = math.max(if stays then 5 else 0, r.bond - (cfg.drift or 3))
			if r.bond <= 0 and not stays and life.sceneRel ~= r.id and life.focusLink ~= r.id then
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
