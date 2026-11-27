--[[
	The guidebook: how to play and what everything does, built from the content pack so it
	never drifts from the game. Sent on request (handlers.guide) and cached.

	{ sections = { { id, name, intro?, entries = { { title, tag?, color?, sub?, text } } } } }
	Sections: Start here (pack.guide.basics), Stats, Fights (statuses), Builds (styles and
	build types), Talents (with the real odds), Traits, Gear, Books, Careers, Factions,
	Modes, Family names, World events, Expeditions.
]]

local Guide = {}

local SLOT_NAMES = { tool = "Weapon", coat = "Armor", charm = "Charm" }
local RARITY_COLORS = {
	common = { 190, 190, 196 },
	uncommon = { 120, 200, 140 },
	rare = { 100, 160, 240 },
	epic = { 180, 110, 240 },
	legendary = { 255, 196, 80 },
	unreal = { 255, 70, 90 },
}

local function titleCase(s: string?): string
	s = s or ""
	return (string.gsub(s, "^%l", string.upper))
end

local function pct(p: number): string
	if p >= 10 then
		return string.format("%d%%", math.floor(p + 0.5))
	end
	return string.format("%.1f%%", p)
end

local function build(S)
	local Content = S.Content
	local sim = S.sim
	local meta = Content.meta or {}
	local currency = meta.currency or ""
	local sections = {}
	local function section(id: string, name: string, intro: string?)
		local s = { id = id, name = name, intro = intro, entries = {} }
		table.insert(sections, s)
		return s.entries
	end
	local function statName(key: string): string
		local def = Content.stats[key]
		return (def and def.name) or titleCase(key)
	end

	-- ── start here ──
	local basics = section("start", "Start here", "The short version. Everything else is in the other tabs.")
	for _, b in (Content.guide and Content.guide.basics) or {} do
		table.insert(basics, { title = b.title, text = b.text })
	end
	if #basics == 0 then
		table.insert(basics, { title = "One year at a time", text = "Press Age Up to live a year. Some years ask you to choose." })
	end

	-- ── stats ──
	local stats = section("stats", "Stats")
	for _, key in Content.stats.order do
		local def = Content.stats[key]
		table.insert(stats, { title = def.name, color = def.color, text = def.desc or "" })
	end
	local san = Content.stats.sanity
	if san then
		table.insert(stats, {
			title = san.name or "Sanity",
			sub = string.format("%d to %d", san.min or -45, san.max or 45),
			text = san.desc or "Tilts every coin you flip: above zero you land heads more often, below zero less.",
		})
	end

	-- ── fights ──
	local fights = section("fights", "Fights", "A clash: both sides flip coins; each heads adds power; the higher total wins. A real fight runs several rounds and statuses pile up.")
	for _, id in { "tremor", "rupture", "bleed", "burn", "sinking", "poise", "charge" } do
		local st = Content.statuses and Content.statuses[id]
		if st then
			table.insert(fights, { title = st.name, color = st.color, text = st.desc })
		end
	end
	table.insert(fights, {
		title = "Mastery",
		text = "Drill your discipline to raise its mastery (up to "
			.. tostring(Content.maxMastery or 5)
			.. "). Every 2 points of mastery add 1 potency to your status."
			.. (if Content.schools then " Outside the organisation that owns it, a discipline stops at mastery " .. tostring(Content.outsideMastery or 2) .. "." else ""),
	})
	table.insert(fights, { title = "Quick checks", text = "Most risks aren't fights: one " .. (Content.stats.word or "virtue") .. " against the danger, a single clash, no statuses." })

	-- ── builds ──
	local builds = section(
		"builds",
		if Content.schools then "Disciplines" else "Builds",
		if Content.schools
			then "A discipline is a way of fighting, and each one belongs to the organisation that trains it. Join one and you're taught it. A veteran can show you the basics. Past the basics, it's only taught inside."
			else "Your fighting style decides which status you build in fights. A build type sets a style, two traits and your stat points in one tap."
	)
	for _, id in (Content.styles and Content.styles.order) or {} do
		local st = Content.styles[id]
		table.insert(builds, { title = st.name, tag = "Status", color = st.color, text = st.desc or "" })
	end
	-- who teaches what
	for _, id in (Content.schools and Content.schools.order) or {} do
		local sc = Content.schools[id]
		local st = sc.style and Content.styles and Content.styles[sc.style]
		table.insert(builds, {
			title = sc.name,
			tag = (if st then st.name .. "  ·  " else "") .. (sc.org or ""),
			color = st and st.color,
			text = sc.desc or "",
		})
	end
	for _, p in Content.buildPresets or {} do
		local traits = {}
		for _, t in p.traits or {} do
			local def = Content.traits[t]
			table.insert(traits, (def and def.name) or t)
		end
		local style = Content.styles and Content.styles[p.style]
		table.insert(builds, {
			title = p.name,
			tag = "Build",
			color = style and style.color,
			sub = (if style then style.name .. "  ·  " else "") .. table.concat(traits, ", "),
			text = p.desc or "",
		})
	end

	-- ── talents ──
	if Content.talents and Content.talents.tiers then
		local odds = sim:talentOdds(nil)
		local parts = {}
		for _, o in odds do
			table.insert(parts, o.name .. " " .. pct(o.percent))
		end
		local talents = section("talents", "Talents", "Every life is born with one talent, by rarity. The odds: " .. table.concat(parts, " · ") .. ". You get free rerolls every day.")
		for _, tier in Content.talents.tiers do
			for _, id in sim:talentPool(tier.id) do
				local def = Content.traits[id]
				local aff = def.affinity and Content.affinities and Content.affinities[def.affinity]
				table.insert(talents, { title = def.name, tag = tier.name, color = tier.color, sub = if aff then "Sin: " .. aff.name else nil, text = def.desc or "" })
			end
		end
	end

	-- ── affinities (the seven sins) ──
	if Content.affinities and Content.affinities.order then
		local aff = section(
			"affinities",
			"Sins",
			string.format(
				if Content.affinityRoll
					then "Every life is dealt two sins at birth. Nobody picks them. A family's sins make talents of those sins %dx as likely for its next child, within whatever rarity is rolled; the rarity odds never change. A talent of one of your sins resonates: +%d%% heads in every clash."
					else "Pick up to two sins in the creator. Talents of your sins are %dx as likely within whatever rarity is rolled; the rarity odds never change. A talent of one of your sins resonates: +%d%% heads in every clash. Heirs keep the family's sins.",
				sim.AFFINITY_WEIGHT or 3,
				Content.affinityResonance or 3
			)
		)
		for _, id in Content.affinities.order do
			local a = Content.affinities[id]
			local names = {}
			for _, tier in (Content.talents and Content.talents.tiers) or {} do
				for _, tid in sim:talentPool(tier.id) do
					local def = Content.traits[tid]
					if def and def.affinity == id then
						table.insert(names, def.name .. " (" .. tier.name .. ")")
					end
				end
			end
			table.insert(aff, { title = a.name, color = a.color, sub = a.desc, text = "Talents: " .. table.concat(names, ", ") .. "." })
		end
	end

	-- ── traits ──
	local traits = section("traits", "Traits", "Pick traits in the creator. More come from your family name, books, careers and what happens to you.")
	for _, id in (Content.traits and Content.traits.order) or {} do
		local def = Content.traits[id]
		if def and def.pick and not def.talent then
			table.insert(traits, {
				title = def.name,
				tag = if def.style then "Style trait" else def.category,
				color = if def.rarity then RARITY_COLORS[def.rarity] else nil,
				text = def.desc or "",
			})
		end
	end

	-- ── gear ──
	local gear = section("gear", "Gear", "One weapon, one armor and one charm. Buy them at workshops; the best are boss drops.")
	for _, id in (Content.gear and Content.gear.order) or {} do
		local g = Content.gear[id]
		if type(g) == "table" then
			local sub = { SLOT_NAMES[g.slot] or g.slot }
			if g.unique then
				table.insert(sub, "not sold: boss drops and rewards")
			elseif g.price then
				table.insert(sub, string.format("%d %s", g.price, currency))
			end
			if g.minAge then
				table.insert(sub, "age " .. g.minAge .. "+")
			end
			table.insert(gear, {
				title = g.name,
				tag = if g.rarity then titleCase(g.rarity) else nil,
				color = if g.rarity then RARITY_COLORS[g.rarity] else nil,
				sub = table.concat(sub, "  ·  "),
				text = (g.effect or "") .. (if g.desc then (if g.effect then "  " else "") .. g.desc else ""),
			})
		end
	end

	-- ── books ──
	if Content.books and #Content.books.order > 0 then
		local books = section("books", "Books", "Found in fights, expeditions and odd shops. Reading one (an activity) teaches its ability for good. Unread books pass to your heir.")
		for _, id in Content.books.order do
			local b = Content.books[id]
			local teaches = b.trait and Content.traits[b.trait]
			table.insert(books, {
				title = b.name,
				tag = if b.rarity then titleCase(b.rarity) else nil,
				color = if b.rarity then RARITY_COLORS[b.rarity] else nil,
				sub = if teaches then "Teaches " .. teaches.name else nil,
				text = (if teaches then (teaches.desc or "") else "") .. (if b.desc then "  " .. b.desc else ""),
			})
		end
	end

	-- ── careers ──
	local careers = section("careers", "Careers", "Join a career from Your Life. Each year you can be promoted if your key " .. (Content.stats.word or "virtue") .. " is high enough.")
	local ids = {}
	for id, c in Content.careers do
		if type(c) == "table" and c.ranks then
			table.insert(ids, id)
		end
	end
	table.sort(ids, function(a, b)
		local ca, cb = Content.careers[a], Content.careers[b]
		if (ca.sort or 99) ~= (cb.sort or 99) then
			return (ca.sort or 99) < (cb.sort or 99)
		end
		return a < b
	end)
	for _, id in ids do
		local c = Content.careers[id]
		if not c.hidden then
			local needs = {}
			if c.minAge then
				table.insert(needs, "age " .. c.minAge .. "+")
			end
			for key, n in (c.requires and c.requires.min) or {} do
				table.insert(needs, statName(key) .. " " .. n .. "+")
			end
			if c.promoteStat then
				table.insert(needs, "promoted on " .. statName(c.promoteStat))
			end
			table.insert(careers, {
				title = titleCase(c.name),
				sub = string.format("%s → %s", c.ranks[1], c.ranks[#c.ranks]) .. (if #needs > 0 then "  ·  " .. table.concat(needs, ", ") else ""),
				text = c.desc or "",
			})
		end
	end

	-- ── factions ──
	local factionList = Content.factions
	if factionList and factionList.order and #factionList.order > 0 then
		local factions = section("factions", "Factions", "Who runs what, how to get in, and what it gives you.")
		for _, id in factionList.order do
			local f = factionList[id]
			if f then
				local text = f.desc or ""
				if f.perks then
					text ..= "\nMembership: " .. f.perks
				end
				if f.join then
					text ..= "\nJoin: " .. f.join
				end
				table.insert(factions, { title = f.name, tag = f.kind, color = f.color, text = text })
			end
		end
	end

	-- ── modes ──
	if Content.modes and #Content.modes > 0 then
		local modes = section("modes", "Modes", "How a life starts. Pick one on the start menu.")
		for _, m in Content.modes do
			if m.hidden then
				continue -- (v0.18: a hidden mode isn't on the start menu)
			end
			table.insert(modes, {
				title = m.name,
				tag = if m.unlock then "Unlock" else nil,
				color = m.color,
				sub = m.tagline,
				text = (m.desc or "") .. (if m.unlockText then "\nUnlock: " .. m.unlockText else ""),
			})
		end
	end

	-- ── family names ──
	local sn = Content.surnames
	if sn and sn.tiers then
		local parts = {}
		local total = 0
		for _, t in sn.tiers do
			total += t.weight
		end
		for _, t in sn.tiers do
			table.insert(parts, t.name .. " " .. pct(t.weight / total * 100))
		end
		local fam = section("families", "Family names", "Roll for a family name from the menu. Rarer names carry a trait into every life you start. Odds: " .. table.concat(parts, " · ") .. ".")
		for _, t in sn.tiers do
			local trait = t.trait and Content.traits[t.trait]
			local names = sn.names and sn.names[t.id] or {}
			table.insert(fam, {
				title = t.name .. " names",
				tag = t.name,
				color = t.color,
				sub = if trait then "Comes with " .. trait.name else "No trait",
				text = (t.desc or "") .. (if trait and trait.desc then "\n" .. trait.name .. ": " .. trait.desc else "") .. (if #names > 0 then "\nFor example: " .. table.concat(names, ", ", 1, math.min(6, #names)) .. "." else ""),
			})
		end
	end

	-- ── world events ──
	local we = Content.worldEvents
	if we and we.order and #we.order > 0 then
		local world = section("world", "World events", "Things that happen to the whole server at once. While one runs, its events turn up in everyone's lives.")
		for _, id in we.order do
			local w = we[id]
			if w then
				table.insert(world, { title = w.name, tag = if w.tone == "danger" then "Danger" elseif w.tone == "strange" then "Strange" else nil, color = if w.tone == "danger" then { 226, 86, 76 } else nil, text = w.text or "" })
			end
		end
	end

	-- ── expeditions ──
	local ex = Content.expeditions
	if ex and ex.order and #ex.order > 0 then
		local KIND = { mission = "Mission", dungeon = "Dungeon", trip = "Trip", containment = "Containment" }
		local exps = section("expeditions", "Expeditions", "Multi-stage jobs from Activities. Go alone or with your crew; every crewmate adds a coin to your clashes.")
		for _, id in ex.order do
			local e = ex[id]
			if e then
				local sub = {}
				table.insert(sub, KIND[e.kind or ""] or "Expedition")
				if e.minAge then
					table.insert(sub, "age " .. e.minAge .. "+")
				end
				if e.crew then
					table.insert(sub, string.format("%d-%d players", e.crew.min or 1, e.crew.max or 4))
				end
				local text = e.desc or ""
				if #text > 220 then
					text = string.sub(text, 1, 217) .. "..."
				end
				table.insert(exps, { title = e.name, sub = table.concat(sub, "  ·  "), text = text })
			end
		end
	end

	return { sections = sections }
end

function Guide.install(S)
	local cached = nil
	function S.handlers.guide()
		if not cached then
			local ok, res = pcall(build, S)
			if not ok then
				warn("[LifeSim] guidebook failed: " .. tostring(res))
				return { ok = false, error = "The guidebook couldn't be put together." }
			end
			cached = res
		end
		return { ok = true, guide = cached }
	end
end

-- for tests
Guide._build = build

return Guide
