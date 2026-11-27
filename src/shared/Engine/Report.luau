--[[
	WHAT A CHOICE OFFERS AND WHAT A LIFE CAME TO (v0.12), kept out of Sim.luau (which is at the
	type checker's limit). Sim delegates to these with thin wrappers.
		scaledResult, stakesOf, stakesView   the chips on a card: what a result gives this life
		deathReport                          the end screen's account of how a life ended
		lantern                              the record a finished life leaves
]]

local Effects = require(script.Parent.Effects)
local Rng = require(script.Parent.Rng)

local Report = {}

local function scaleNumber(n: number, gain: number, loss: number): number
	if n > 0 then
		return math.max(1, math.floor(n * gain + 0.5))
	elseif n < 0 then
		return -math.max(1, math.floor(-n * loss + 0.5))
	end
	return 0
end

function Report.scaledResult(self: any, result: any, gain: any, loss: any)
	if type(result) ~= "table" or (gain == 1 and loss == 1) then
		return result
	end
	local out = table.clone(result)
	for _, key in self.scaledKeys do
		local v = out[key]
		if type(v) == "number" then
			out[key] = scaleNumber(v, gain, loss)
		elseif type(v) == "table" and type(v[1]) == "number" and type(v[2]) == "number" then
			local a, b = scaleNumber(v[1], gain, loss), scaleNumber(v[2], gain, loss)
			out[key] = { math.min(a, b), math.max(a, b) }
		end
	end
	if type(out.paycheck) == "number" and out.paycheck > 0 then
		out.paycheck *= gain
	end
	return out
end

function Report.stakesOf(self: any, result: any, gain: any, loss: any, life: any, ctx: any)
	local r = self:scaledResult(result, gain or 1, loss or 1)
	local list = {}
	if type(r) ~= "table" then
		return list
	end
	local paid = false
	if life then
		local seen = Effects.preview(self, life, r, ctx)
		local keys = table.clone(self.scaledKeys)
		table.insert(keys, "bond")
		for _, key in keys do
			local p = seen[key]
			if p and (p.min ~= 0 or p.max ~= 0) then
				table.insert(list, { key = key, min = p.min, max = p.max })
			elseif p then
				-- written to change, and it can't: say why rather than promise it
				local written = r[key]
				local up = if type(written) == "table" then math.max(written[1], written[2]) > 0 else type(written) == "number" and written > 0
				local at = if key == "bond" then (ctx and ctx.target and ctx.target.bond) elseif key == "sanity" then life.sanity else life.stats[key]
				local top = if key == "sanity" then self.pack.stats.sanity.max else 100
				if up and type(at) == "number" and at >= top then
					table.insert(list, { key = key, min = 0, max = 0, capped = true })
				end
			end
		end
		paid = seen.money ~= nil and (r.wage ~= nil or (r.paycheck ~= nil and life.career ~= nil))
	else
		for _, key in self.scaledKeys do
			local v = r[key]
			if type(v) == "number" and v ~= 0 then
				table.insert(list, { key = key, min = v, max = v })
			elseif type(v) == "table" and type(v[1]) == "number" then
				table.insert(list, { key = key, min = math.min(v[1], v[2]), max = math.max(v[1], v[2]) })
			end
		end
	end
	if r.die then
		table.insert(list, { key = "die", min = 0, max = 0 })
	end
	if r.condition then
		-- by its name when it has one ("Night Terrors"), so the card says what you'd be taking home
		local cdef = type(r.condition) == "string" and self.pack.conditions and self.pack.conditions[r.condition]
		if cdef and cdef.name then
			table.insert(list, { key = "injury", min = 0, max = 0, text = cdef.name, tone = if cdef.good then "good" else "bad" })
		else
			table.insert(list, { key = "injury", min = 0, max = 0 })
		end
	end
	if r.gear then
		table.insert(list, { key = "gear", min = 0, max = 0 })
	end
	-- a book or a scroll, by name; and whether this life could follow it
	for _, id in if type(r.book) == "table" then r.book elseif r.book then { r.book } else {} do
		local def = self:bookDef(id)
		if def then
			local closed = life ~= nil and def.schools ~= nil and not (life.school and table.find(def.schools, life.school))
			table.insert(list, {
				key = "book",
				min = 0,
				max = 0,
				text = def.name .. (if closed then " (needs " .. self:schoolNames(def.schools) .. " training to read)" else ""),
				tone = if closed then nil else "good",
			})
		end
	end
	if r.loseGear then
		table.insert(list, { key = "loseGear", min = 0, max = 0 })
	end
	-- the rest of what a choice can do, as plain words (the UI shows `text`)
	local function note(key: string, text: string, tone: string?)
		table.insert(list, { key = key, min = 0, max = 0, text = text, tone = tone })
	end
	if type(r.rep) == "table" then
		for id, n in r.rep do
			local def = self.pack.reputation and self.pack.reputation[id]
			local lo = if type(n) == "table" then math.min(n[1], n[2]) else n
			local hi = if type(n) == "table" then math.max(n[1], n[2]) else n
			if def and type(lo) == "number" and type(hi) == "number" and (lo ~= 0 or hi ~= 0) then
				local amount = if lo == hi
					then string.format("%s%d", if hi > 0 then "+" else "", hi)
					elseif lo >= 0 then string.format("+%d~%d", lo, hi)
					elseif hi <= 0 then string.format("-%d~%d", -hi, -lo)
					else string.format("%d~+%d", lo, hi)
				note("rep", string.format("%s %s", def.short or def.name, amount), if hi > 0 then "good" else "bad")
			end
		end
	end
	if r.mastery then
		note("mastery", "Mastery", "good")
	end
	if r.addTrait then
		local def = self:traitDef(r.addTrait)
		note("trait", "Trait: " .. ((def and def.name) or "?"), "good")
	end
	if r.school then
		note("school", "A discipline", "good")
	end
	if r.career then
		local def = self.pack.careers[r.career]
		note("career", "Job: " .. ((def and def.name) or "?"), "good")
	end
	if r.promote then
		note("promote", "Promotion", "good")
	end
	if r.quitCareer then
		note("quit", "Lose your job", "bad")
	end
	if r.form and self.pack.forms[r.form] and not r.die then
		note("form", "Become: " .. self.pack.forms[r.form].name, "strange")
	end
	if r.addRelation then
		note("relation", "Someone new", "good")
	end
	if r.killRelation then
		note("loss", "Someone may die", "bad")
	end
	if type(r.relationBond) == "table" and type(r.relationBond.amount) == "number" and r.relationBond.amount ~= 0 then
		note("bond", if r.relationBond.amount > 0 then "Closer to people" else "Further from people", if r.relationBond.amount > 0 then "good" else "bad")
	end
	if (r.wage or r.paycheck) and not paid then
		note("pay", "Pay", "good")
	end
	if r.cure then
		note("cure", "Heals an injury", "good")
	end
	-- (v0.12) for good: more most Health; for now: past full; a home of your own
	if type(r.maxHealth) == "number" and r.maxHealth ~= 0 then
		note("maxHealth", string.format("%s%d most Health", if r.maxHealth > 0 then "+" else "", r.maxHealth), if r.maxHealth > 0 then "good" else "bad")
	end
	if type(r.overheal) == "number" and r.overheal > 0 then
		note("overheal", string.format("Up to %d past full", r.overheal), "good")
	end
	if type(r.home) == "string" then
		local h = self.pack.homes and self.pack.homes[r.home]
		if h then
			local bits = {}
			if (h.safety or 0) > 0 then
				table.insert(bits, string.format("%d%% safer", math.floor(h.safety * 100 + 0.5)))
			end
			if (h.sanity or 0) ~= 0 then
				table.insert(bits, string.format("%s%d Sanity a year", if h.sanity > 0 then "+" else "", h.sanity))
			end
			note("home", "Home" .. (if #bits > 0 then ": " .. table.concat(bits, ", ") else ""), "good")
		end
	end
	if r.sellHome then
		note("sellHome", "Sell for half", nil)
	end
	if r.schedule or r.trigger then
		note("later", "Leads somewhere", nil)
	end
	if r.quest then
		note("quest", "Starts a quest", nil)
	end
	return list
end

-- what a clash choice can win or cost: as it stands, and by each way of going in (a stance
-- can pay more or cost less). With a life, what that life would really be given (see stakesOf).
function Report.stakesView(self: any, choice: any, life: any, ctx: any)
	local out = { win = self:stakesOf(choice.win, nil, nil, life, ctx), lose = self:stakesOf(choice.lose, nil, nil, life, ctx), approaches = {} }
	local approaches = self.pack.approaches
	for _, id in (approaches and approaches.order) or {} do
		local a = approaches[id]
		out.approaches[id] = {
			win = self:stakesOf(choice.win, a.gain, a.loss, life, ctx),
			lose = self:stakesOf(choice.lose, a.gain, a.loss, life, ctx),
		}
	end
	return out
end

function Report.deathReport(self: any, life: any, cause: any)
	local pack = self.pack
	local vitalDef = pack.stats[self.vital]
	local vitalName = (vitalDef and vitalDef.name) or "Health"
	local d = { cause = cause, age = life.age, scene = life.scene, choice = life.lastChoice, lines = {}, tips = {} }
	local ending = self:endingOf(life)
	d.ending = if ending then ending.id else nil
	-- no body, no wounds: a book or an erasure isn't explained by a Health bar
	local hit = if ending and ending.noBody then nil else life.lastHit
	local c = life.lastClash
	if c then
		d.check = c
		if c.fight then
			table.insert(d.lines, string.format("You fought %s and %s.", c.foe, if c.won then "won" else "lost"))
		else
			table.insert(d.lines, string.format("You tried a %s check against %s and %s.", c.statName, c.foe, if c.won then "passed" else "failed"))
		end
		table.insert(d.lines, string.format("Your side: %d coin%s, %d base, +%d a heads, %d%% heads. Theirs: %d coin%s, %d base, +%d a heads.", c.pCoins, if c.pCoins == 1 then "" else "s", c.pBase, c.pCoinPower, c.pHeads, c.fCoins, if c.fCoins == 1 then "" else "s", c.fBase, c.fCoinPower))
		if c.first == "foe" then
			table.insert(d.lines, string.format("They were faster (Speed %d against your %d) and struck first.", c.fSpeed or 0, c.pSpeed or 0))
			table.insert(d.tips, "Train Speed. The faster side strikes first, one-sided, and Speed is how many coins you bring to a fight.")
		end
		if c.pHeads < 40 then
			table.insert(d.tips, string.format("Your Sanity was %d, so your coins came up heads only %d%% of the time. Rest, eat, see people.", life.sanity, c.pHeads))
		end
		if c.approach == "reckless" then
			table.insert(d.tips, "You went in Reckless: a loss hits twice as hard.")
		end
		if c.edge == "resisted" and c.stance then
			table.insert(d.tips, string.format("You chose to %s, and that is what %s handles best. The card shows what each foe is weak to.", string.lower(c.stance), c.foe))
		end
		if not c.won and c.odds and c.odds < 0.35 then
			table.insert(d.tips, string.format("The odds were %d%% before you started. The card shows them for every way of fighting.%s", math.floor(c.odds * 100 + 0.5), if ending then "" else " Walking away is allowed."))
		end
	end
	if hit then
		d.hit = hit
		table.insert(d.lines, string.format("It cost you %d %s. You had %d.", hit.amount, vitalName, hit.before))
		if hit.before <= 30 then
			table.insert(d.tips, string.format("You went in with only %d %s. A clinic visit is one action and a little money.", hit.before, vitalName))
		end
		if hit.mult and hit.mult > 1.2 then
			table.insert(d.tips, "Adults take the City at full weight: every wound lands harder than it did when you were a child. Armor and some talents soften it.")
		end
	end
	local form = pack.forms[life.form]
	if form and form.terminal then
		if c and not c.won and not c.fight then
			-- lost the check that was holding it off (a volatile E.G.O, the second time)
			table.insert(d.lines, "What you were holding came apart, and there was nothing left between you and what the voice offered.")
			table.insert(d.tips, "A volatile E.G.O is no protection the second time. Before she comes back: train Mental Strength, keep someone close (it's far easier with a face to hold on to), or let it go out and stay yourself. The card shows the odds before you choose.")
		else
			table.insert(d.lines, "You took the hand the voice held out.")
			table.insert(d.tips, "Following her is how people Distort. You can refuse: look and say no (Mental Strength decides what you come back with), or turn away and pay for it in weeks.")
		end
		table.insert(d.tips, "Keep Sanity off the floor and the question never comes: rest, see your people, and don't spend it all on one bad year.")
	end
	local diff = self:difficultyDef(life)
	if diff and (diff.lethality or 1) > 1 then
		table.insert(d.tips, "You were playing on " .. diff.name .. ": wounds land harder there.")
	end
	if ending then
		for i, line in ending.lines or {} do
			table.insert(d.lines, i, self:render(life, line))
		end
		for _, tip in ending.tips or {} do
			table.insert(d.tips, self:render(life, tip))
		end
	end
	if #d.lines == 0 then
		table.insert(d.lines, if life.scene then "It happened during: " .. tostring(life.scene) .. "." else "Nothing in particular did it. The years did.")
	end
	-- (BitLeveling) the fate this life ended in, first
	local fate = life.fate and self.fatesById and self.fatesById[life.fate]
	if fate then
		d.fate = { id = fate.id, name = fate.name, desc = self:render(life, fate.desc or ""), rarity = fate.rarity or 1, canon = fate.canon ~= false }
		table.insert(d.lines, 1, string.format("FATE: %s%s. %s", fate.name, if fate.canon == false then " (non-canon)" else "", d.fate.desc))
	end
	return d
end

function Report.lantern(self: any, life: any)
	local pack = self.pack
	local def = if life.career then pack.careers[life.career.id] else nil
	local pick = nil
	local ep = pack.epitaphs
	local st = { rng = Rng.seed(life.rng + life.age) }
	local ending = self:endingOf(life)
	if ending and ending.epitaphs then
		pick = Rng.pick(st, ending.epitaphs)
	elseif ep.form and ep.form[life.form] then
		pick = Rng.pick(st, ep.form[life.form])
	elseif def and ep.career and ep.career[life.career.id] and Rng.chance(st, 0.6) then
		pick = Rng.pick(st, ep.career[life.career.id])
	end
	pick = pick or Rng.pick(st, ep.generic)
	local worth = life.age / 8 + (life.peakRank or 0) * 1.5 + math.log10(math.max(1, life.peakMoney or 0) + 1)
	if life.form == "surfaced" then
		worth += 3
	end
	local glow = 1 + (if worth >= 10 then 1 else 0) + (if worth >= 18 then 1 else 0)
	local ribbon = self:ribbon(life)
	-- (BitLeveling) a fate other than the plain fallback names the life and writes its epitaph
	local fate = life.fate and self.fatesById and self.fatesById[life.fate]
	if fate and (fate.priority or 0) > 0 then
		ribbon = { name = fate.name, desc = self:render(life, fate.desc or "") }
		if fate.epitaph then
			pick = fate.epitaph
		end
	end
	local highlights = {}
	for i = #life.highlights, math.max(1, #life.highlights - 2), -1 do
		table.insert(highlights, life.highlights[i].text)
	end
	local district = self:districtDef(life)
	return {
		id = life.id,
		name = life.first .. " " .. life.last,
		born = life.bornYear,
		died = life.year,
		age = life.age,
		zone = (district.name or life.district) .. ", " .. (self:sideDef(life).short or life.side),
		career = if def then def.ranks[life.career.rank] .. ", " .. self:careerName(life) else nil,
		form = (pack.forms[life.form] or {}).name or life.form,
		cause = life.cause or "Unknown",
		ending = if ending then ending.id else nil,
		epitaph = self:render(life, pick),
		highlights = highlights,
		score = self:score(life),
		title = if ribbon then ribbon.name else nil,
		titleDesc = if ribbon then ribbon.desc else nil,
		generation = life.generation or 1,
		fate = if fate then fate.id else nil,
		fateRarity = if fate then fate.rarity else nil,
		fateCanon = if fate then fate.canon ~= false else nil,
		peakMoney = life.peakMoney or 0,
		fixerGrade = self:fixerRating(life),
		fightsWon = (life.tally and life.tally.fightsWon) or 0,
		talent = life.talent,
		mode = life.mode,
		glow = glow,
		released = false,
		heirOf = life.heirOf,
	}
end

return Report
