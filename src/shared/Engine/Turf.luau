--!strict
--[[
	TURF (v0.13): the streets of your District, block by block, and who holds each one.
	pack.turf = { blocks = { names }, count, factions = { [id] = { name, color, foe, rep } },
	              contest = { faction ids that hold streets }, income, renown, minAge }
	life.turf = { district, blocks = { { name, holder } }, side? }
	A life joins a turf war (result.turfJoin = faction id, or "crew" for your own), then takes
	blocks (result.turfTake = n), loses them (result.turfLose = n), and collects from them
	every year. Holding every block is a feat, and a hold on the District (Engine/Renown.luau).
]]

local Rng = require(script.Parent.Rng)

local Turf = {}

local function cfg(self: any): any
	return self.pack.turf
end

-- the life's District, block by block (made the first time anyone looks)
function Turf.ensure(self: any, life: any): any
	local c = cfg(self)
	if not c then
		return nil
	end
	if life.turf and life.turf.district == life.district then
		return life.turf
	end
	local names = table.clone(c.blocks or {})
	local blocks = {}
	local count = math.min(c.count or 6, #names)
	for _ = 1, count do
		local name = table.remove(names, Rng.int(life, 1, #names))
		local holder = c.contest[Rng.int(life, 1, #c.contest)]
		table.insert(blocks, { name = name, holder = holder })
	end
	local side = life.turf and life.turf.side or nil
	life.turf = { district = life.district, blocks = blocks, side = side }
	return life.turf
end

function Turf.held(self: any, life: any): number
	local t = life.turf
	if not t or t.district ~= life.district then
		return 0
	end
	local n = 0
	for _, b in t.blocks do
		if b.holder == "you" then
			n += 1
		end
	end
	return n
end

local function factionName(self: any, id: string?): string
	local f = id and cfg(self).factions[id]
	return if f then f.name else (id or "nobody")
end

-- join a side (a faction id, or "crew": your own)
function Turf.join(self: any, life: any, side: string, extra: { any })
	local t = Turf.ensure(self, life)
	if not t then
		return
	end
	t.side = side
	life.flags.turf_in = true
	table.insert(extra, { kind = "system", tone = "strange", text = if side == "crew" then "You're in the turf war, for yourself." else "You're in the turf war, with " .. factionName(self, side) .. "." })
end

-- take n blocks from whoever holds them (not your own side's)
function Turf.take(self: any, life: any, n: number, extra: { any })
	local t = Turf.ensure(self, life)
	if not t then
		return
	end
	for _ = 1, n do
		local open = {}
		for i, b in t.blocks do
			if b.holder ~= "you" and b.holder ~= t.side then
				table.insert(open, i)
			end
		end
		if #open == 0 then
			for i, b in t.blocks do
				if b.holder ~= "you" then
					table.insert(open, i)
				end
			end
		end
		if #open == 0 then
			break
		end
		local i = open[Rng.int(life, 1, #open)]
		local from = t.blocks[i].holder
		t.blocks[i].holder = "you"
		local f = cfg(self).factions[from]
		if f and f.rep then
			self:addRep(life, f.rep, -6, extra)
		end
		table.insert(extra, { kind = "system", tone = "good", text = t.blocks[i].name .. " is yours now. " .. factionName(self, from) .. " won't forget it." })
	end
	if Turf.held(self, life) >= #t.blocks and not life.flags.turf_all then
		life.flags.turf_all = true
		table.insert(extra, { kind = "system", tone = "good", text = "Every block in the District answers to you." })
		self:highlight(life, "Held every block of " .. self:districtDef(life).name .. ".")
	end
end

-- lose n of your blocks to whoever wants them most
function Turf.lose(self: any, life: any, n: number, extra: { any })
	local t = life.turf
	if not t or t.district ~= life.district then
		return
	end
	for _ = 1, n do
		local mine = {}
		for i, b in t.blocks do
			if b.holder == "you" then
				table.insert(mine, i)
			end
		end
		if #mine == 0 then
			break
		end
		local i = mine[Rng.int(life, 1, #mine)]
		local c = cfg(self)
		local to = c.contest[Rng.int(life, 1, #c.contest)]
		t.blocks[i].holder = to
		table.insert(extra, { kind = "system", tone = "bad", text = t.blocks[i].name .. " fell to " .. factionName(self, to) .. "." })
	end
end

-- once a year: what your streets pay, and whether someone comes for them
function Turf.year(self: any, life: any, report: any)
	local n = Turf.held(self, life)
	if n <= 0 or not life.alive then
		return
	end
	local c = cfg(self)
	local pay = n * (c.income or 50)
	life.money += pay
	self:push(life, report, { kind = "log", text = string.format("Your %d block%s paid their dues.", n, if n == 1 then "" else "s"), deltas = { money = pay } })
	if (c.renown or 0) > 0 then
		self:addRenown(life, n * c.renown, report)
	end
	-- the more you hold, the more often someone tries their luck (a guard year halves it)
	local chance = math.min(0.7, 0.12 + 0.08 * n)
	if life.turf.guardAge == life.age - 1 then
		chance *= 0.5
	end
	if c.raid and Rng.chance(life, chance) and not table.find(life.queue, c.raid) and life.pending ~= c.raid then
		table.insert(life.queue, c.raid)
	end
end

function Turf.view(self: any, life: any): any
	local c = cfg(self)
	local t = life.turf
	if not c or not t or t.district ~= life.district or not life.flags.turf_in then
		return nil
	end
	local blocks = {}
	for _, b in t.blocks do
		local f = c.factions[b.holder]
		table.insert(blocks, { name = b.name, holder = b.holder, holderName = factionName(self, b.holder), color = f and f.color, yours = b.holder == "you" })
	end
	return { district = self:districtDef(life).name, blocks = blocks, held = Turf.held(self, life), side = t.side, sideName = if t.side then factionName(self, t.side) else nil }
end

-- the foe for a fight over a block held by `holder`
function Turf.foeOf(self: any, life: any): string?
	local t = life.turf
	if not t then
		return nil
	end
	for _, b in t.blocks do
		if b.holder ~= "you" and b.holder ~= t.side then
			local f = cfg(self).factions[b.holder]
			return f and f.foe
		end
	end
	return nil
end

return Turf
