--[[
	REDEEM CODES (v0.17): type a code in the store ("Have a code?"), get what it gives, once
	per player.

	Codes come from two places:
	  Config.codes    written into the game: { WELCOME = { grants = { "lunacy:60" }, note = "...",
	                  expires = os.time()-style number or nil } }
	  the mod menu    made in game by an admin (Admin.luau ops codeAdd / codeRemove), saved in a
	                  DataStore so every server sees them (each server re-reads it every minute)
	A code matches without caring about case or spaces. Each player can redeem a code once
	(profile Data.codes[CODE] = os.time()). A player gets six wrong tries a minute.
	Grants use the store's keys (server/Store.luau): "lunacy:N", "light:N", "rolls:N",
	"premiumRolls:N", "boost:heal", "boost:ahn:N", "<cosmetic category>:<id>".
]]

local DataStoreService = game:GetService("DataStoreService")

local Codes = {}

local STORE_NAME = "LifeSim_Codes_v1"
local KEY = "codes"
local REFRESH = 60
local TRIES = 6

-- the kinds of thing a code may give (checked when an admin makes one)
local KINDS = {
	lunacy = true, light = true, rolls = true, premiumRolls = true, boost = true,
	outfit = true, hair = true, hairColor = true, eyes = true, accessory = true, frame = true, skin = true, mark = true, weapon = true, body = true,
}

function Codes.norm(code: string): string
	local s = string.gsub(code, "%s", "")
	return string.upper(s)
end

-- "lunacy:100, light:5" -> { "lunacy:100", "light:5" }, or nil and why
function Codes.parseGrants(text: string): ({ string }?, string?)
	local out = {}
	for part in string.gmatch(text, "[^,]+") do
		local key = string.gsub(part, "%s", "")
		local kind = string.match(key, "^([%w_]+):[%w_:]+$")
		if not kind or not KINDS[kind] then
			return nil, "Can't give \"" .. key .. "\". Use lunacy:N, light:N, rolls:N, boost:heal or a look like outfit:id."
		end
		table.insert(out, key)
	end
	if #out == 0 then
		return nil, "A code has to give something."
	end
	return out, nil
end

function Codes.install(S)
	local cfg = {}
	for code, def in (S.Config and S.Config.codes) or {} do
		if type(def) == "table" then
			cfg[Codes.norm(code)] = def
		end
	end
	local made = {}
	local store = nil
	pcall(function()
		store = DataStoreService:GetDataStore(STORE_NAME)
	end)
	local lastLoad = -REFRESH
	local function load(force: boolean?)
		if not store or (not force and os.clock() - lastLoad < REFRESH) then
			return
		end
		lastLoad = os.clock()
		local ok, data = pcall(function()
			return store:GetAsync(KEY)
		end)
		if ok and type(data) == "table" then
			made = data
		end
	end
	local function save(change)
		-- (read, change, write in one step, so two servers don't overwrite each other)
		change(made)
		if store then
			pcall(function()
				store:UpdateAsync(KEY, function(old)
					old = if type(old) == "table" then old else {}
					change(old)
					made = old
					return old
				end)
			end)
		end
	end

	local function find(code: string)
		load(false)
		local key = Codes.norm(code)
		local def = made[key] or cfg[key]
		if not def then
			return nil, key, "That code doesn't work."
		end
		if def.expires and os.time() > def.expires then
			return nil, key, "That code has expired."
		end
		return def, key, nil
	end

	-- give a code's grants: through the store when it's open, or directly
	local function grant(data, def)
		local Store = S.Store
		if Store and Store.grant then
			return Store.grant(data, { key = "code", consumable = true, grants = def.grants })
		end
		data.cosmetics = data.cosmetics or {}
		for _, key in def.grants or {} do
			local kind, rest = string.match(key, "^([%w_]+):(.+)$")
			local n = tonumber(rest)
			if kind == "lunacy" and n then
				data.lunacy = (data.lunacy or 0) + n
			elseif kind == "light" and n then
				data.glow = (data.glow or 0) + n
			elseif kind == "rolls" and n then
				data.rolls = (data.rolls or 0) + n
			elseif kind and kind ~= "boost" then
				data.cosmetics[key] = true
			end
		end
		return nil
	end

	local tries = {} -- [userId] = { n, since }
	function S.handlers.redeemCode(player, session, payload)
		local t = tries[player.UserId]
		if t and os.clock() - t.since < 60 and t.n >= TRIES then
			return { ok = false, error = "Too many tries. Wait a minute." }
		end
		local code = type(payload) == "table" and payload.code
		if type(code) ~= "string" or #code < 2 or #code > 40 then
			return { ok = false, error = "Type a code." }
		end
		local def, key, why = find(code)
		if not def then
			if not t or os.clock() - t.since >= 60 then
				t = { n = 0, since = os.clock() }
				tries[player.UserId] = t
			end
			t.n += 1
			return { ok = false, error = why }
		end
		local data = session.profile.Data
		data.codes = data.codes or {}
		if data.codes[key] then
			return { ok = false, error = "You've already used that code." }
		end
		data.codes[key] = os.time()
		local report = grant(data, def)
		local res = { ok = true, toast = def.note or "Code redeemed.", meta = S.metaView(data), celebrate = "purchase" }
		if report and data.life then
			res.life = S.sim:view(data.life)
			res.entries = report.entries
		end
		return res
	end

	-- for the mod menu
	function Codes.list()
		load(false)
		local out = {}
		for code, def in cfg do
			table.insert(out, { code = code, note = def.note, grants = def.grants, expires = def.expires, builtIn = true })
		end
		for code, def in made do
			table.insert(out, { code = code, note = def.note, grants = def.grants, expires = def.expires, by = def.by })
		end
		table.sort(out, function(a, b)
			return a.code < b.code
		end)
		return out
	end

	function Codes.add(code: string, grants: { string }, note: string?, days: number?, by: string?): string?
		local key = Codes.norm(code)
		if #key < 3 or #key > 24 or not string.match(key, "^[%w_]+$") then
			return "A code is 3 to 24 letters, numbers or _."
		end
		if cfg[key] then
			return "That code is written into the game (Config.codes)."
		end
		local def = { grants = grants, note = note, by = by, expires = if days and days > 0 then os.time() + math.floor(days * 86400) else nil }
		save(function(t)
			t[key] = def
		end)
		return nil
	end

	function Codes.remove(code: string): string?
		local key = Codes.norm(code)
		if cfg[key] then
			return "That code is written into the game: remove it from Config.codes."
		end
		save(function(t)
			t[key] = nil
		end)
		return nil
	end

	game:GetService("Players").PlayerRemoving:Connect(function(p)
		tries[p.UserId] = nil
	end)
	S.Codes = Codes
end

return Codes
