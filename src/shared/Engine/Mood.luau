--!strict
--[[
	YEAR MOODS (v0.12): no two years feel the same. pack.yearMoods = { chance, list = { mood } }
	mood: { id, name, text, color, tags = { [tag] = weight x }, lucky? (x on lucky events),
	        sanity? (once, when the year starts), minAge?, maxAge?, when? }
	A year that's already a hard one (pack.crises) has no mood: the crisis is its theme. The
	year card wears the mood's name and colour; its tags tilt which events come.
	TAG FATIGUE: the themes of last year's cards come up a little less this year
	(pack.tagFatigue = { after, mult, skip = { tags } }), so a year of Fixers isn't followed
	by another year of Fixers.
]]

local Rng = require(script.Parent.Rng)
local Conditions = require(script.Parent.Conditions)
local People = require(script.Parent.People)

local Mood = {}

function Mood.def(self: any, id: string?): any
	local cfg = self.pack.yearMoods
	if not cfg or not id then
		return nil
	end
	for _, m in cfg.list or {} do
		if m.id == id then
			return m
		end
	end
	return nil
end

-- the start of a year: last year's themes move back, and maybe a mood for this one
function Mood.roll(self: any, life: any, report: any, yearEntry: any)
	life.tagsLast = life.tagsThis or {}
	life.tagsThis = {}
	life.mood = nil
	local cfg = self.pack.yearMoods
	if not cfg or life.crisis or not life.alive then
		return
	end
	if not Rng.chance(life, cfg.chance or 0.5) then
		return
	end
	local list: { any } = {}
	local weights: { number } = {}
	for _, m in cfg.list or {} do
		local ok = (not m.minAge or life.age >= m.minAge) and (not m.maxAge or life.age <= m.maxAge)
		if ok and m.when then
			ok = Conditions.check(m.when, life, self.pack, { noChance = true })
		end
		-- not the same mood two years running
		if ok and m.id ~= life.lastMood then
			table.insert(list, m)
			table.insert(weights, m.weight or 10)
		end
	end
	local i = Rng.weighted(life, weights)
	local m = i and list[i]
	if not m then
		return
	end
	life.mood = m.id
	life.lastMood = m.id
	if yearEntry then
		yearEntry.mood = { name = m.name, text = self:render(life, m.text or ""), color = m.color }
	end
	-- a year of strangers: somebody new, for certain
	if m.meet then
		local extra: { any } = {}
		People.meet(self, life, extra, nil)
		for _, e in extra do
			self:push(life, report, e)
		end
	end
	if type(m.sanity) == "number" and m.sanity ~= 0 then
		local sc = self.pack.stats.sanity
		local before = life.sanity
		life.sanity = math.clamp(life.sanity + m.sanity, sc.min, sc.max)
		if life.sanity ~= before and report then
			self:push(life, report, { kind = "log", text = self:render(life, m.text or ""), deltas = { sanity = life.sanity - before } })
		end
	end
end

-- how this year's mood, and last year's themes, tilt an event
function Mood.weight(self: any, life: any, event: any, w: number): number
	if w <= 0 then
		return w
	end
	local m = life.mood and Mood.def(self, life.mood)
	if m then
		for _, tag in event.tags or {} do
			local x = m.tags and m.tags[tag]
			if x then
				w *= x
			end
		end
		if m.lucky and event.lucky then
			w *= m.lucky
		end
	end
	local fat = self.pack.tagFatigue
	if fat and life.tagsLast and not event.story and not event.always then
		-- a card with one of the `skip` tags never fades (the City's danger stays the City's)
		local exempt = false
		for _, tag in event.tags or {} do
			if fat.skip and table.find(fat.skip, tag) then
				exempt = true
				break
			end
		end
		if not exempt then
			local factor = 1
			for _, tag in event.tags or {} do
				if (life.tagsLast[tag] or 0) >= (fat.after or 2) then
					factor *= fat.mult or 0.7
				end
			end
			w *= math.max(fat.floor or 0.45, factor)
		end
	end
	return w
end

-- a card was shown: its themes count toward this year
function Mood.saw(self: any, life: any, event: any)
	if not event or not event.tags then
		return
	end
	life.tagsThis = life.tagsThis or {}
	for _, tag in event.tags do
		life.tagsThis[tag] = (life.tagsThis[tag] or 0) + 1
	end
end

function Mood.view(self: any, life: any): any
	local m = life.mood and Mood.def(self, life.mood)
	return if m then { name = m.name, text = self:render(life, m.text or ""), color = m.color } else nil
end

return Mood
