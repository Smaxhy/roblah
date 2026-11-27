--[[
	Text helpers: number formatting, RichText escaping and stat-change chips.
]]

local Theme = require(script.Parent.Theme)
local C = Theme.colors

local Format = {}

function Format.escape(s: string?): string
	if s == nil then
		return ""
	end
	s = string.gsub(s, "&", "&amp;")
	s = string.gsub(s, "<", "&lt;")
	s = string.gsub(s, ">", "&gt;")
	return s
end

function Format.number(n: number): string
	local negative = n < 0
	local s = tostring(math.floor(math.abs(n)))
	local out = string.reverse((string.gsub(string.reverse(s), "(%d%d%d)", "%1,")))
	if string.sub(out, 1, 1) == "," then
		out = string.sub(out, 2)
	end
	return (if negative then "-" else "") .. out
end

function Format.signed(n: number): string
	return (if n > 0 then "+" else "") .. Format.number(n)
end

function Format.hex(c: Color3): string
	return "#" .. c:ToHex()
end

function Format.color(text: string, c: Color3): string
	return '<font color="' .. Format.hex(c) .. '">' .. text .. "</font>"
end

-- ── chips: what a choice, a tile or a row says it gives ─────────────────────
-- The server sends each as { key, min, max } with the numbers THIS life would really be
-- given (or { text, tone } for things that aren't numbers), and these say it the same way
-- everywhere.

-- how much: "+2", "-4", "+2~4", "-1~3", "+0~1" (it may give nothing), "-2~+3" (either way)
function Format.stake(min: number, max: number): string
	if min == max then
		return if min > 0 then "+" .. min elseif min < 0 then "-" .. -min else ""
	elseif min >= 0 then
		return "+" .. min .. "~" .. max
	elseif max <= 0 then
		return "-" .. -max .. "~" .. -min
	end
	return "-" .. -min .. "~+" .. max
end

local STAKE_NAMES = { sanity = "SAN", bond = "BOND", die = "DEATH", injury = "INJURY", gear = "+ITEM", loseGear = "-ITEM" }
function Format.stakeName(info, key: string): string
	if key == "money" then
		return (info and info.meta and info.meta.currency) or "Ahn"
	end
	local def = info and info.stats and info.stats.defs and info.stats.defs[key]
	return (def and def.short) or STAKE_NAMES[key] or string.upper(string.sub(key, 1, 4))
end

-- one chip: its words and its tone ("good", "bad", "mixed", "strange", "money", "plain")
function Format.stakeChip(info, s): (string, string)
	if s.text then
		return s.text, if s.tone == "good" or s.tone == "bad" or s.tone == "strange" then s.tone else "plain"
	end
	local name = Format.stakeName(info, s.key)
	local lo, hi = s.min or 0, s.max or 0
	if s.capped then
		-- it would rise, and it is already at the top
		return name .. " MAX", "plain"
	elseif s.key == "die" or s.key == "injury" or s.key == "loseGear" then
		return name, "bad"
	elseif s.key == "gear" then
		return name, "good"
	elseif lo == 0 and hi == 0 then
		return name, "plain"
	end
	local tone = if lo >= 0 then (if s.key == "money" then "money" else "good") elseif hi <= 0 then "bad" else "mixed"
	return Format.stake(lo, hi) .. " " .. name, tone
end

-- the pack's stats first (info.stats.order), then Sanity, bonds and money
local TAIL = { "sanity", "bond", "money" }
local function orderFor(info): { string }
	local out = {}
	for _, key in (info and info.stats and info.stats.order) or { "fortitude", "prudence", "temperance", "justice" } do
		table.insert(out, key)
	end
	for _, key in TAIL do
		table.insert(out, key)
	end
	return out
end

-- deltas: { fortitude = 3, money = -20, ... } -> RichText chips
function Format.deltas(deltas, info): string
	if not deltas then
		return ""
	end
	local parts = {}
	for _, key in orderFor(info) do
		local d = deltas[key]
		if d and d ~= 0 then
			local label
			if key == "money" then
				label = info.meta.currency
			elseif key == "sanity" then
				label = "Sanity"
			elseif key == "bond" then
				label = "Bond"
			else
				local def = info.stats.defs[key]
				label = if def then def.short else key
			end
			local color
			if key == "money" then
				color = if d > 0 then C.money else C.bad
			else
				color = if d > 0 then C.good else C.bad
			end
			table.insert(parts, Format.color(Format.signed(d) .. " " .. label, color))
		end
	end
	return table.concat(parts, "   ")
end

return Format
