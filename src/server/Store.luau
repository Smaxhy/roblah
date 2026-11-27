--[[
	The store: Robux purchases.

	The catalog comes from the content pack (pack.store.items), or from Config.store.items.
	A fan pack (pack.fanWork) only sells when Config.store.sellInFanPacks is true: the owner's
	call, for a small private game.

	Each item has `grants`, a list of keys:
		"outfit:id", "eyes:id", "frame:id"...   a cosmetic (the creator's unlock keys)
		"rolls:N"                                N family-name rolls
		"premiumRolls:N"                         N rolls that land Rare or better
		"light:N"                                N Light (the meta currency)
		"lunacy:N"                               N Lunacy (the premium currency)
		"perk:extraTrait" / "perk:bonusPoints" / "perk:vip"   permanent perks
		"origin:id"                              unlock an origin
		"boost:heal" / "boost:ahn:N" / "boost:mastery:N"      a boost for the current life
		                                         (or the next one, if no life is going)
	`consumable = true` items can be bought again and again (rolls, Light, boosts).
	`lunacy = N` (instead of a Robux id) prices an item in Lunacy: it's bought in game with
	storeSpend, no Roblox prompt. Lunacy itself is sold for Robux (grants "lunacy:N").
	`random = true` marks paid random items (rolls): their odds are shown before buying, and
	they're hidden from players whose Roblox policy restricts paid random items.

	Paste your Developer Product ids (kind = "product") and Game Pass ids (kind = "pass")
	from the Creator Dashboard. With testInStudio = true, items in Studio can be "bought"
	for free so you can try them before setting up real products.

	Receipts are idempotent: each PurchaseId is granted once and remembered.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PolicyService = game:GetService("PolicyService")

local Store = {}

local KEEP_RECEIPTS = 60

function Store.install(S)
	local cfg = (S.Config and S.Config.store) or {}
	local packStore = S.Content.store
	-- A fan work sells nothing unless the owner turns it on (Config.store.sellInFanPacks)
	if S.Content.fanWork and cfg.sellInFanPacks ~= true then
		Store.enabled = false
		function S.handlers.store()
			return { ok = true, store = {}, note = "This is a fan game, so nothing here is for sale. Every look unlocks by playing.", closed = true }
		end
		function S.handlers.storeTestBuy()
			return { ok = false, error = "The store is closed in this game." }
		end
		function Store.checkPasses() end
		function Store.applyPending() end
		return
	end
	Store.enabled = true
	local items = (packStore and packStore.items) or cfg.items or {}
	local note = (packStore and packStore.note) or cfg.note
	local looksOnly = not (packStore and packStore.items)
	local byKey, byProduct, byPass = {}, {}, {}
	for _, item in items do
		byKey[item.key] = item
		if item.kind == "pass" and (item.id or 0) > 0 then
			byPass[item.id] = item
		elseif (item.id or 0) > 0 then
			byProduct[item.id] = item
		end
	end

	-- Roblox's policy for this player: may they buy paid random items (the rolls)?
	local function randomRestricted(player: Player?, session): boolean
		if not player then
			return true
		end
		if session and session.randomRestricted ~= nil then
			return session.randomRestricted
		end
		local ok, info = pcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(player)
		end)
		local restricted
		if ok and type(info) == "table" then
			restricted = info.ArePaidRandomItemsRestricted == true
		else
			-- no answer: allow it in Studio (for testing), be careful in a live game
			restricted = not RunService:IsStudio()
		end
		if session then
			session.randomRestricted = restricted
		end
		return restricted
	end
	Store.randomRestricted = randomRestricted

	-- boosts for a life: applied now if a life is going, or kept for the next one
	local function applyBoost(data, boost: string, report)
		local life = data.life
		if not (life and life.alive) then
			return false
		end
		local sim = S.sim
		local kind, amount = string.match(boost, "^([%w_]+):?(%d*)$")
		amount = tonumber(amount) or 0
		local result
		if kind == "heal" then
			result = { [sim.vital] = 40, sanity = 15, cure = "any", log = "A Second Wind: a good clinic, a long sleep, and someone else paying. You feel like yourself again." }
			-- every curable condition, not just one
			local still = {}
			for _, c in life.conditions or {} do
				local def = S.Content.conditions and S.Content.conditions[c.id]
				if def and def.curable == false then
					table.insert(still, c)
				end
			end
			life.conditions = still
		elseif kind == "ahn" then
			result = { money = amount, log = string.format("A Fortune: %d %s, delivered in a plain envelope.", amount, S.Content.meta.currency or "") }
		elseif kind == "mastery" then
			result = { mastery = amount, log = "A Master's Lesson: an afternoon with someone who has done this for forty years. Your {style} is sharper." }
		else
			return true -- unknown boost: drop it
		end
		local Effects = S.Engine.Effects
		Effects.apply(sim, life, result, report)
		return true
	end

	-- boosts bought while no life was going wait for the next life
	function Store.applyPending(data, report)
		local pending = data.pendingBoosts
		if not pending or #pending == 0 then
			return
		end
		local still = {}
		for _, b in pending do
			if not applyBoost(data, b, report) then
				table.insert(still, b)
			end
		end
		data.pendingBoosts = still
	end

	local function grant(data, item)
		if not item.consumable then
			data.owned = data.owned or {}
			data.owned[item.key] = true
		end
		data.cosmetics = data.cosmetics or {}
		local boosted = false
		local report = S.sim.newReport()
		for _, key in item.grants or {} do
			local kind, rest = string.match(key, "^([%w_]+):(.+)$")
			local n = tonumber(rest)
			if kind == "rolls" and n then
				data.rolls = (data.rolls or 0) + n
			elseif kind == "premiumRolls" and n then
				data.premiumRolls = (data.premiumRolls or 0) + n
			elseif kind == "light" and n then
				data.glow = (data.glow or 0) + n
			elseif kind == "lunacy" and n then
				data.lunacy = (data.lunacy or 0) + n
			elseif kind == "perk" and rest then
				data.perks = data.perks or {}
				data.perks[rest] = true
			elseif kind == "origin" and rest then
				data.unlocked = data.unlocked or {}
				data.unlocked[rest] = true
			elseif kind == "boost" and rest then
				if applyBoost(data, rest, report) then
					boosted = true
				else
					data.pendingBoosts = data.pendingBoosts or {}
					table.insert(data.pendingBoosts, rest)
				end
			elseif kind then
				data.cosmetics[key] = true
			end
		end
		return if boosted then report else nil
	end
	Store.grant = grant

	function Store.owns(data, key: string): boolean
		return data.owned ~= nil and data.owned[key] == true
	end

	-- the catalog as the client shows it
	local function catalog(player: Player?, session)
		local data = session.profile.Data
		local out = {}
		local studio = RunService:IsStudio()
		local restricted = nil
		for _, item in items do
			local inLunacy = type(item.lunacy) == "number"
			local ready = inLunacy or (item.id or 0) > 0
			local reason = nil
			if item.random then
				if restricted == nil then
					restricted = randomRestricted(player, session)
				end
				if restricted then
					reason = "Not available where you live (Roblox's rules on paid random items)."
				end
			end
			table.insert(out, {
				key = item.key,
				name = item.name,
				desc = item.desc or "",
				price = item.price,
				tier = item.tier or "Small",
				kind = item.kind or "product",
				id = item.id or 0,
				owned = not item.consumable and Store.owns(data, item.key),
				consumable = item.consumable == true,
				random = item.random == true,
				odds = item.odds,
				grants = item.grants or {}, -- what it unlocks, so the client can show it on you
				buyable = reason == nil and (ready or (studio and cfg.testInStudio == true)),
				reason = reason,
				test = not ready,
				currency = if inLunacy then "lunacy" else "robux",
				lunacy = item.lunacy,
				affordable = not inLunacy or (data.lunacy or 0) >= item.lunacy,
				bonus = item.bonus,
			})
		end
		return out
	end

	-- after a purchase: the new meta, and the life if a boost changed it
	local function afterGrant(player: Player, session, item, report, testBuy: boolean?)
		local data = session.profile.Data
		local push = {
			toast = item.name .. (if testBuy then " (test purchase) unlocked." else " unlocked. Thank you!"),
			meta = S.metaView(data),
			celebrate = "purchase",
		}
		if report and data.life then
			push.life = S.sim:view(data.life)
			push.entries = report.entries
		end
		return push
	end

	S.handlers.store = function(player, session)
		return { ok = true, store = catalog(player, session), note = note, looksOnly = looksOnly }
	end

	-- an item priced in Lunacy: paid from the player's Lunacy, no Roblox prompt
	S.handlers.storeSpend = function(player, session, payload)
		local item = type(payload) == "table" and byKey[payload.key]
		if not item or type(item.lunacy) ~= "number" then
			return { ok = false, error = "No such item." }
		end
		local data = session.profile.Data
		if item.random and randomRestricted(player, session) then
			return { ok = false, error = "Not available where you live (Roblox's rules on paid random items)." }
		end
		if not item.consumable and Store.owns(data, item.key) then
			return { ok = false, error = "You already have that." }
		end
		if (data.lunacy or 0) < item.lunacy then
			return { ok = false, error = string.format("You need %d Lunacy (you have %d).", item.lunacy, data.lunacy or 0) }
		end
		data.lunacy -= item.lunacy
		local report = grant(data, item)
		local push = afterGrant(player, session, item, report, false)
		push.toast = item.name .. " is yours."
		return { ok = true, store = catalog(player, session), meta = push.meta, life = push.life, entries = push.entries, toast = push.toast }
	end

	-- Studio testing: grant an item that has no real product id yet
	S.handlers.storeTestBuy = function(player, session, payload)
		if not RunService:IsStudio() or cfg.testInStudio ~= true then
			return { ok = false, error = "Test purchases only work in Studio." }
		end
		local item = type(payload) == "table" and byKey[payload.key]
		if not item then
			return { ok = false, error = "No such item." }
		end
		if item.random and randomRestricted(player, session) then
			return { ok = false, error = "Not available where you live." }
		end
		local report = grant(session.profile.Data, item)
		local push = afterGrant(player, session, item, report, true)
		return { ok = true, store = catalog(player, session), meta = push.meta, life = push.life, entries = push.entries, toast = push.toast }
	end

	-- developer products
	local ok = pcall(function()
		MarketplaceService.ProcessReceipt = function(receipt)
			local player = Players:GetPlayerByUserId(receipt.PlayerId)
			local session = player and S.sessions[player]
			if not session then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			local data = session.profile.Data
			data.receipts = data.receipts or {}
			for _, id in data.receipts do
				if id == receipt.PurchaseId then
					return Enum.ProductPurchaseDecision.PurchaseGranted
				end
			end
			local item = byProduct[receipt.ProductId]
			if not item then
				warn("[LifeSim] receipt for an unknown product id " .. tostring(receipt.ProductId))
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			local report = grant(data, item)
			table.insert(data.receipts, receipt.PurchaseId)
			while #data.receipts > KEEP_RECEIPTS do
				table.remove(data.receipts, 1)
			end
			pcall(function()
				session.profile:Save()
			end)
			S.pushTo(player, afterGrant(player, session, item, report))
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end)
	if not ok then
		warn("[LifeSim] store: ProcessReceipt unavailable here")
	end

	-- game passes: bought now, or owned from before
	pcall(function()
		MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
			local item = byPass[passId]
			local session = S.sessions[player]
			if purchased and item and session then
				local report = grant(session.profile.Data, item)
				S.pushTo(player, afterGrant(player, session, item, report))
			end
		end)
	end)

	function Store.checkPasses(player: Player, data)
		for passId, item in byPass do
			if not Store.owns(data, item.key) then
				local has = false
				pcall(function()
					has = MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
				end)
				if has then
					grant(data, item)
				end
			end
		end
	end
end

return Store
