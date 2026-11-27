--!strict
--[[
	FEATS AND PHASES (v0.13): goals worth chasing, and a life that changes shape as it goes.

	pack.feats = { order, [id] = { name, desc, tier ("bronze" | "silver" | "gold" | "mythic"),
	               need = { ... } } }. A feat is earned the year its `need` holds; it's kept in
	life.feats[id] = age (and, on the server, in the player's record of feats ever earned).
	need keys (all must hold):
	  age, money, peakMoney, renown (grade), stat = { key = n }, anyStat (one stat >= n),
	  allStats (every stat but Health >= n), flags = { ... }, episodes, cases, blocks (turf held),
	  office (size), home (true or an id), children, closeFriends (bond >= 70), married,
	  uniques (unique items owned), legendary (items of legendary rarity or better owned),
	  delves (expeditions finished), form, careerTop (true: the top rank of any career),
	  lives (generation), clashes (won)
	pack.phases = { { id, name, from, line, unlocks } }: the year a life reaches `from`, a phase
	card says what this part of life is about and what has opened.
	(v0.18) EARNED TRAITS: a trait with `earn = { need keys, as above }` comes by itself the year
	its need holds (once per life), with a card in the year's feed.
]]

local Feats = {}

local function countKind(life: any, kind: string): number
	local n = 0
	for _, r in life.relations do
		if r.alive and r.kind == kind then
			n += 1
		end
	end
	return n
end

local function owned(self: any, life: any): { any }
	local list = {}
	for _, g in self:gearIn(life) do
		table.insert(list, g.def)
	end
	for _, id in life.stash or {} do
		local def = self.pack.gear and self.pack.gear[id]
		if def then
			table.insert(list, def)
		end
	end
	return list
end

local RARITY_RANK = { common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5, unreal = 6 }

-- how far a life is toward one requirement: value now, value needed (for the progress bar)
local function measure(self: any, life: any, key: string, want: any): (number, number)
	local t = life.tally or {}
	if key == "age" then
		return life.age, want
	elseif key == "money" then
		return life.money, want
	elseif key == "peakMoney" then
		return life.peakMoney or life.money, want
	elseif key == "renown" then
		return self:renownRank(life), want
	elseif key == "anyStat" then
		local best = 0
		for _, k in self.coreStats do
			if k ~= self.vital then
				best = math.max(best, life.stats[k] or 0)
			end
		end
		return best, want
	elseif key == "allStats" then
		local worst = math.huge
		for _, k in self.coreStats do
			if k ~= self.vital then
				worst = math.min(worst, life.stats[k] or 0)
			end
		end
		return worst, want
	elseif key == "episodes" then
		local n = 0
		for _ in life.episodes or {} do
			n += 1
		end
		return n, want
	elseif key == "cases" then
		return t.cases or 0, want
	elseif key == "blocks" then
		return self:turfHeld(life), want
	elseif key == "office" then
		return (life.office and life.office.size) or 0, want
	elseif key == "children" then
		return countKind(life, "child"), want
	elseif key == "closeFriends" then
		local n = 0
		for _, r in life.relations do
			if r.alive and r.bond >= 70 and (r.kind == "friend" or r.kind == "partner") then
				n += 1
			end
		end
		return n, want
	elseif key == "uniques" then
		local n = 0
		for _, d in owned(self, life) do
			if d.unique then
				n += 1
			end
		end
		return n, want
	elseif key == "legendary" then
		local n = 0
		for _, d in owned(self, life) do
			if (RARITY_RANK[d.rarity or "common"] or 1) >= 5 then
				n += 1
			end
		end
		return n, want
	elseif key == "delves" then
		return t.expeditions or 0, want
	elseif key == "clashes" then
		return t.clashesWon or 0, want
	elseif key == "lives" then
		return life.generation or 1, want
	end
	return 0, 1
end

local function holds(self: any, life: any, need: any): boolean
	for key, want in need do
		if key == "stat" then
			for k, v in want do
				if (life.stats[k] or 0) < v then
					return false
				end
			end
		elseif key == "flags" then
			for _, f in want do
				if not life.flags[f] then
					return false
				end
			end
		elseif key == "home" then
			if not life.home or (type(want) == "string" and life.home.id ~= want) then
				return false
			end
		elseif key == "married" then
			if (countKind(life, "partner") > 0) ~= (want == true) then
				return false
			end
		elseif key == "form" then
			if life.form ~= want then
				return false
			end
		elseif key == "careerTop" then
			local c = life.career
			local def = c and self.pack.careers[c.id]
			local top = (life.flags.career_top == true) or (def ~= nil and c.rank >= #def.ranks)
			if not top then
				return false
			end
		else
			local have, need2 = measure(self, life, key, want)
			if have < need2 then
				return false
			end
		end
	end
	return true
end

-- every year (and after big moments): any feat newly earned?
function Feats.check(self: any, life: any, report: any)
	local feats = self.pack.feats
	if not feats or not life.alive then
		return
	end
	-- (the top of a career, once reached, stays reached)
	local c = life.career
	local cdef = c and self.pack.careers[c.id]
	if cdef and c.rank >= #cdef.ranks then
		life.flags.career_top = true
	end
	life.feats = life.feats or {}
	for _, id in feats.order or {} do
		local f = feats[id]
		if not life.feats[id] and f.need and holds(self, life, f.need) then
			life.feats[id] = life.age
			local tier = feats.tiers and feats.tiers[f.tier or "bronze"]
			if report then
				self:push(life, report, { kind = "feat", id = id, title = f.name, text = f.desc or "", tier = f.tier, color = tier and tier.color })
			end
			self:highlight(life, "Feat: " .. f.name .. ".")
			if f.limitBreak then
				-- (a feat that pushes a limit: higher caps for this life)
				life.capBonus = life.capBonus or {}
				for k, v in f.limitBreak do
					life.capBonus[k] = (life.capBonus[k] or 0) + v
				end
			end
		end
	end
	Feats.earnTraits(self, life, report)
end

-- (v0.18) traits a life grows into: the year a trait's `earn` holds, it's yours
function Feats.earnTraits(self: any, life: any, report: any)
	local traits = self.pack.traits
	if not traits or not life.alive then
		return
	end
	for _, id in traits.order or {} do
		local def = traits[id]
		if type(def) == "table" and type(def.earn) == "table" and not self:hasTrait(life, id) and holds(self, life, def.earn) then
			if self:addTrait(life, id, nil) then
				if report then
					self:push(life, report, { kind = "system", tone = "good", text = "You've become something: " .. def.name .. ". " .. (def.desc or "") })
				end
				self:highlight(life, "Trait: " .. def.name .. ".")
			end
		end
	end
end
Feats.holds = holds

-- the feats board: every feat, earned or not, with how close this life is
function Feats.view(self: any, life: any): any
	local feats = self.pack.feats
	if not feats then
		return nil
	end
	local list = {}
	local earned = 0
	for _, id in feats.order or {} do
		local f = feats[id]
		local done = life.feats ~= nil and life.feats[id] ~= nil
		if done then
			earned += 1
		end
		-- progress: the first numeric requirement, as a share
		local p = nil
		if not done and f.need then
			for key, want in f.need do
				if type(want) == "number" and key ~= "stat" then
					local have, need2 = measure(self, life, key, want)
					p = math.clamp(have / math.max(1, need2), 0, 1)
					break
				end
			end
		end
		table.insert(list, { id = id, name = f.name, desc = f.desc, tier = f.tier or "bronze", done = done, age = done and life.feats[id] or nil, progress = p, hidden = f.hidden == true and not done, reward = f.reward })
	end
	return { list = list, earned = earned, total = #list, tiers = feats.tiers }
end

-- ── phases ──────────────────────────────────────────────────────────────

function Feats.phaseOf(self: any, life: any): any
	local cur = nil
	for _, p in self.pack.phases or {} do
		if life.age >= p.from then
			cur = p
		end
	end
	return cur
end

function Feats.phaseCheck(self: any, life: any, report: any)
	for _, p in self.pack.phases or {} do
		if p.from == life.age and p.from > 0 then
			self:push(life, report, { kind = "phase", title = p.name, text = self:render(life, p.line or ""), unlocks = p.unlocks, color = p.color })
		end
	end
end

function Feats.phaseView(self: any, life: any): any
	local p = Feats.phaseOf(self, life)
	if not p then
		return nil
	end
	local nextP = nil
	for _, q in self.pack.phases or {} do
		if q.from > life.age and (not nextP or q.from < nextP.from) then
			nextP = q
		end
	end
	return { id = p.id, name = p.name, line = self:render(life, p.line or ""), unlocks = p.unlocks, color = p.color, nextName = nextP and nextP.name, nextAt = nextP and nextP.from }
end

return Feats
