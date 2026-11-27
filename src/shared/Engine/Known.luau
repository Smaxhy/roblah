--!strict
--[[
	KNOWN: what a life knows of the City (pack.storyGates), and how it comes to know it.

	A gate's `flag` ("knows_thumb") is learned:
	  · by seeing an event the gate holds back (its `prefixes`, see Sim:gateOpen), or one it
	    `teaches` (prefixes that teach without holding anything back);
	  · by reading its name on a card: `words`, looked for as names the way the glossary looks
	    (Sim:termMatches), in the card's text but never its headline (headlines capitalise
	    everything); `mid` works as the glossary's does;
	  · by living in one of its `districts`: you know the Wing that owns your streets;
	  · by working one of its `careers`, by a result's setFlags, or by having any standing at
	    all with the faction whose reputation `flag` it is (pack.reputation);
	  · `implies`: flags learned along with it, quietly ("K Corp" is one of the Wings).
	pack.knownGroups ({ id, name, flags }) sorts "Who you know of" into sections.
]]

local Known = {}

function Known.build(self: any)
	local pack = self.pack
	self.teachOf = {}
	self.wordGates = {}
	self.placeGates = {}
	self.repOfFlag = {}
	local teachers: { any } = {}
	for _, g in pack.storyGates or {} do
		if g.flag then
			if g.teaches then
				table.insert(teachers, g)
			end
			if g.words or g.mid then
				table.insert(self.wordGates, { flag = g.flag, match = g.words or {}, mid = g.mid })
			end
			for _, d in g.districts or {} do
				self.placeGates[d] = self.placeGates[d] or {}
				table.insert(self.placeGates[d], g.flag)
			end
		end
	end
	if #teachers > 0 then
		for _, e in pack.events do
			for _, g in teachers do
				for _, prefix in g.teaches do
					if string.sub(e.id, 1, #prefix) == prefix then
						local list = self.teachOf[e.id] or {}
						self.teachOf[e.id] = list
						table.insert(list, g.flag)
						break
					end
				end
			end
		end
	end
	local repPack = pack.reputation
	for _, id in (repPack and repPack.order) or {} do
		local def = repPack[id]
		if def.flag and not self.repOfFlag[def.flag] then
			self.repOfFlag[def.flag] = id
		end
	end
end

-- Sets a "knows_" flag and whatever it implies. Returns the gate when this was news.
function Known.set(self: any, life: any, flag: string): any
	if life.flags[flag] then
		return nil
	end
	life.flags[flag] = true
	local g = self.gateByFlag[flag]
	for _, other in (g and g.implies) or {} do
		Known.set(self, life, other)
	end
	return g
end

-- the words a life is shown on a card (its own variant of each line), before names go in
local function bodyOf(self: any, life: any, event: any): string
	local function shown(text: any): string
		if type(text) == "table" then
			return self:variant(life, text)
		end
		return if type(text) == "string" then text else ""
	end
	local body = shown(event.text)
	for _, d in event.dialogue or {} do
		body ..= "\n" .. shown(d.line)
	end
	return body
end

-- a card the life has just been shown: what it holds back, what it teaches, what it names
function Known.learnFrom(self: any, life: any, event: any, report: any)
	if not event then
		return
	end
	local g = self.gateOf[event.id]
	if g and g.flag then
		self:learn(life, g.flag, report)
	end
	for _, flag in self.teachOf[event.id] or {} do
		self:learn(life, flag, report)
	end
	local body: string? = nil
	for _, w in self.wordGates do
		if not life.flags[w.flag] then
			body = body or bodyOf(self, life, event)
			local text = body :: string
			if self:termMatches(w, "", text, string.lower(text)) then
				self:learn(life, w.flag, report)
			end
		end
	end
end

-- where the life lives: the Wing that owns the District, quietly
function Known.learnPlace(self: any, life: any)
	for _, flag in self.placeGates[life.district or ""] or {} do
		Known.set(self, life, flag)
	end
end

local function statusOf(self: any, life: any, g: any): (string, string?)
	local member = life.career ~= nil and g.careers ~= nil and table.find(g.careers, life.career.id) ~= nil
	local key = string.gsub(g.flag, "^knows_", "")
	local status = if member then "One of them" elseif life.flags["met_" .. key] then "Met" elseif life.flags["seen_" .. key] then "Seen" else "Heard of"
	local blurb = g.blurb
	-- what became of it (gate.after = { eras, status, blurb }): L Corp after its fall
	local era = life.world and life.world.era
	if g.after and era and table.find(g.after.eras, era) then
		status = g.after.status or status
		blurb = g.after.blurb or blurb
	end
	return status, blurb
end

--[[ "Who you know of": { list, hidden, hiddenBy, groups }. Each entry { flag, name, blurb,
	emblem, status, group, rep? }; `rep` = { id, name, value, standing, note } is the life's
	standing with that faction, so standings and what you know of are one list. ]]
function Known.view(self: any, life: any)
	local pack = self.pack
	local era = life.world and life.world.era
	local repPack = pack.reputation
	local placed: { [string]: string } = {}
	local groups = {}
	for _, gr in pack.knownGroups or {} do
		table.insert(groups, { id = gr.id, name = gr.name })
		for _, flag in gr.flags or {} do
			placed[flag] = placed[flag] or gr.id
		end
	end
	local order: { string } = {}
	local seen: { [string]: boolean } = {}
	for _, gr in pack.knownGroups or {} do
		for _, flag in gr.flags or {} do
			if not seen[flag] and self.gateByFlag[flag] then
				seen[flag] = true
				table.insert(order, flag)
			end
		end
	end
	local others = false
	for _, g in pack.storyGates or {} do
		if g.flag and g.name and not seen[g.flag] then
			seen[g.flag] = true
			table.insert(order, g.flag)
			others = true
		end
	end
	if others then
		table.insert(groups, { id = "others", name = if #groups > 0 then "Others" else "Who you know of" })
	end
	local list: { any } = {}
	local hidden = 0
	local hiddenBy: { [string]: number } = {}
	for _, flag in order do
		local g = self.gateByFlag[flag]
		if g and g.name then
			local group = placed[flag] or "others"
			if life.flags[flag] then
				local status, blurb = statusOf(self, life, g)
				local entry: any = { flag = flag, name = g.name, blurb = blurb, emblem = g.emblem, status = status, group = group }
				local repId = self.repOfFlag[flag]
				if repId and repPack and not (repPack[repId] and repPack[repId].nobody) then
					local def = repPack[repId]
					local n = self:repOf(life, repId)
					entry.rep = {
						id = repId,
						name = def.name,
						value = n,
						standing = self:standing(n),
						note = if n <= (def.grudge or -20) then def.grudgeNote elseif n >= 30 then def.favorNote else nil,
					}
				end
				table.insert(list, entry)
			elseif not (g.eras and era and not table.find(g.eras, era)) then
				-- (something that doesn't exist yet in this age isn't waiting to be heard of)
				hidden += 1
				hiddenBy[group] = (hiddenBy[group] or 0) + 1
			end
		end
	end
	return { list = list, hidden = hidden, hiddenBy = hiddenBy, groups = groups }
end

return Known
