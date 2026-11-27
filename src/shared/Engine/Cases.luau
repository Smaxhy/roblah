--!strict
--[[
	CASES (v0.13): investigations that take years. pack.cases = { order, [id] = { name, desc,
	clues (how many to solve it), stat, coins, base, coinPower, steps = { one line per clue },
	finale (the event that closes it) } }.
	result.caseOpen = id opens one (flag case_open_<id>); the pack's "Work the case" activity
	for it (City/init.luau makes one per case) finds a clue on a win (result.caseClue = id);
	the last clue brings the finale, whose endings close it (result.caseClose = id).
]]

local Cases = {}

function Cases.def(self: any, id: string): any
	local c = self.pack.cases
	return c and c[id]
end

function Cases.open(self: any, life: any, id: string, extra: { any })
	local def = Cases.def(self, id)
	if not def then
		return
	end
	life.cases = life.cases or {}
	if life.cases[id] then
		return
	end
	life.cases[id] = { clues = 0, opened = life.age }
	life.flags["case_open_" .. id] = true
	table.insert(extra, { kind = "system", tone = "strange", text = "A case of your own: " .. def.name .. ". Work it from the DO tab, a clue at a time." })
end

function Cases.clue(self: any, life: any, id: string, extra: { any })
	local def = Cases.def(self, id)
	local rec = life.cases and life.cases[id]
	if not def or not rec or rec.solved then
		return
	end
	rec.clues += 1
	local line = def.steps and def.steps[rec.clues]
	if line then
		table.insert(extra, { kind = "log", text = "Clue " .. rec.clues .. " of " .. def.clues .. ": " .. self:render(life, line) })
	end
	if rec.clues >= def.clues and not life.flags["case_ready_" .. id] then
		life.flags["case_ready_" .. id] = true
		if def.finale and self.eventsById[def.finale] then
			table.insert(life.queue, 1, def.finale)
		end
	end
end

function Cases.close(self: any, life: any, id: string, extra: { any })
	local rec = life.cases and life.cases[id]
	if not rec or rec.solved then
		return
	end
	rec.solved = true
	rec.closed = life.age
	life.flags["case_done_" .. id] = true
	life.flags["case_open_" .. id] = nil
	self:tally(life, "cases")
	local def = Cases.def(self, id)
	table.insert(extra, { kind = "system", tone = "good", text = "Case closed: " .. ((def and def.name) or id) .. "." })
end

function Cases.view(self: any, life: any): any
	local out = {}
	for _, id in (self.pack.cases and self.pack.cases.order) or {} do
		local rec = life.cases and life.cases[id]
		if rec then
			local def = self.pack.cases[id]
			table.insert(out, { id = id, name = def.name, desc = self:render(life, def.desc or ""), clues = rec.clues, of = def.clues, solved = rec.solved == true })
		end
	end
	return out
end

-- the activity's name, with how far along it is ("Work the case: ... (2/4)")
function Cases.progressLabel(self: any, life: any, id: string): string?
	local def = Cases.def(self, id)
	local rec = life.cases and life.cases[id]
	if not def or not rec then
		return nil
	end
	local have: number = tonumber(rec.clues) or 0
	local need: number = tonumber(def.clues) or 1
	return string.format(" (%d/%d clues)", math.min(have, need), need)
end

return Cases
