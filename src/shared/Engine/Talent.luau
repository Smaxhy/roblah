--!strict
--[[
	A GIFT THAT WAKES (v0.12): prodigies unlock things at different ages.

	pack.talentWake = { tiers = { tier ids }, bands = { { id, name, min, max, weight, line } },
	                    event? (queued when it wakes), scouts? = { [bandId] = event } }
	A talent of one of those tiers doesn't start working at birth. The life rolls when it
	wakes (a band: early, on time, late), and until then the talent is asleep: none of its
	bonuses, no resonance. The year it wakes it's added like any trait (Sim:addTrait), the
	report says so, and the pack's wake event and a scout for that band (a prodigy's opening:
	a scholarship, an Office that wants you at eighteen, Hana noticing a late bloomer) follow.
]]

local Rng = require(script.Parent.Rng)

local Talent = {}

local function bandOf(self: any, id: string?): any
	for _, b in (self.pack.talentWake and self.pack.talentWake.bands) or {} do
		if b.id == id then
			return b
		end
	end
	return nil
end

-- gives the life its talent: at once, or asleep until a rolled age
function Talent.grant(self: any, life: any, tid: string, tdef: any)
	life.talent = tid
	local cfg = self.pack.talentWake
	local sleeps = cfg ~= nil and tdef.talent ~= nil and table.find(cfg.tiers or {}, tdef.talent) ~= nil
	if sleeps and cfg then
		local weights = {}
		for _, b in cfg.bands or {} do
			table.insert(weights, b.weight or 1)
		end
		local i = Rng.weighted(life, weights)
		local band = i and cfg.bands[i]
		if band then
			life.talentWake = Rng.int(life, band.min, band.max)
			life.talentBand = band.id
			if life.age >= life.talentWake then
				-- (an heir born grown, or a mode that starts late: it's already awake)
				life.talentWake = nil
				self:addTrait(life, tid)
			end
			return
		end
	end
	self:addTrait(life, tid)
end

function Talent.asleep(self: any, life: any): boolean
	return life.talent ~= nil and life.talentWake ~= nil and not self:hasTrait(life, life.talent)
end

-- every year: is this the year it wakes?
function Talent.wakeCheck(self: any, life: any, report: any)
	local tid = life.talent
	if not tid or not life.talentWake or life.age < life.talentWake or not life.alive then
		return
	end
	life.talentWake = nil
	if self:hasTrait(life, tid) then
		return
	end
	self:addTrait(life, tid)
	local def = self:traitDef(tid)
	local tier = def and self:talentTier(def.talent)
	local band = bandOf(self, life.talentBand)
	if def then
		self:push(life, report, {
			kind = "gift",
			title = "Your gift wakes",
			text = def.name .. (if tier then " (" .. tier.name .. ")" else "") .. ". " .. (def.desc or "") .. (if band and band.line then " " .. band.line else ""),
			color = tier and tier.color,
			gift = true,
		})
		self:highlight(life, "A gift woke at " .. life.age .. ": " .. def.name .. ".")
	end
	life.flags["gift_" .. (life.talentBand or "woke")] = true
	local cfg = self.pack.talentWake
	if cfg and cfg.event and self.eventsById[cfg.event] then
		table.insert(life.queue, cfg.event)
	end
	-- a prodigy's opening: who comes looking depends on when it woke
	local scout = cfg and cfg.scouts and cfg.scouts[life.talentBand or ""]
	if scout and def and table.find(cfg.scoutTiers or cfg.tiers or {}, def.talent) and self.eventsById[scout.event] then
		table.insert(life.scheduled, { event = scout.event, age = life.age + (scout.inYears or 1) })
	end
end

-- for the talent card: asleep, and roughly when it will wake
function Talent.viewExtra(self: any, life: any, v: any)
	if not v then
		return v
	end
	if Talent.asleep(self, life) then
		local band = bandOf(self, life.talentBand)
		v.asleep = true
		v.wakes = band and band.name or nil
		v.resonance = false
	end
	return v
end

return Talent
