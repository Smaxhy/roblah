--[[
	THE HUNTERS' MARKET (BitLeveling): sell your weapons to other players on the server.

	(Canon has an auction house where Hunters' loot is traded; this is the game's own market.)
	A weapon you list leaves your life and is held in escrow on your profile until it sells or
	you take it back, so nothing is lost if a server closes: escrow comes back to your life the
	next time you open the market. A sale pays into the seller's life; if that life is over,
	the money waits in the seller's market wallet and is paid into their next life.

	Handlers (Request remote): mkOpen, mkSell, mkCancel, mkBuy
	Limits: 6 listings a player, prices 1..10,000,000 million won, no buying your own.
]]

local Players = game:GetService("Players")

local HunterMarket = {}

local MAX_LISTINGS = 6
local MAX_PRICE = 10000000

function HunterMarket.install(S)
	local Content = S.Content
	if not Content.hunterWorld then
		return
	end
	local sim = S.sim
	local HW = S.Engine.HunterWorld
	local Weapons = HW.weapons()
	if not Weapons then
		return
	end
	local listings: { any } = {}
	local serial = 0

	local function lifeOf(session: any): any
		local life = session and session.profile.Data.life
		return if life and life.alive then life else nil
	end

	local function itemView(gearId: string): any
		local base, stars, shiny = Weapons.parse(gearId)
		local def = Content.gear[gearId]
		if not base or not def then
			return nil
		end
		local w = Weapons.byId[base]
		return {
			gear = gearId,
			name = def.name,
			base = base,
			stars = stars,
			shiny = shiny,
			grade = Weapons.GRADES[w.grade],
			family = Weapons.FAMILIES[w.family].name,
			power = Weapons.power(base, stars, shiny),
			effect = def.effect,
			rarity = def.rarity,
			desc = w.desc,
			value = HunterMarket.value(Weapons, base, stars, shiny),
		}
	end

	-- what a weapon is worth to a broker, about (the market's suggested price)
	function HunterMarket.value(W: any, base: string, stars: number, shiny: boolean?): number
		local p = W.power(base, stars, shiny)
		return math.max(1, math.floor(p ^ 1.7 * 3 + 0.5))
	end

	-- escrowed weapons come home, and wallet money is paid in (a server closed mid-sale, or the life ended)
	local function settle(player: Player, session: any): { string }
		local data = session.profile.Data
		local life = lifeOf(session)
		local notes = {}
		if not life then
			return notes
		end
		data.marketEscrow = data.marketEscrow or {}
		local still = {}
		for _, gearId in data.marketEscrow do
			local listed = false
			for _, l in listings do
				if l.seller == player.UserId and l.gear == gearId then
					listed = true
				end
			end
			if listed then
				table.insert(still, gearId)
			else
				life.stash = life.stash or {}
				if not table.find(life.stash, gearId) and #life.stash < 30 then
					table.insert(life.stash, gearId)
					table.insert(notes, "Your unsold " .. ((Content.gear[gearId] or {}).name or gearId) .. " came back to your stash.")
				else
					table.insert(still, gearId)
				end
			end
		end
		data.marketEscrow = still
		if (data.marketWallet or 0) > 0 then
			life.money += data.marketWallet
			table.insert(notes, string.format("%d million won from market sales was paid into this life.", data.marketWallet))
			data.marketWallet = 0
		end
		return notes
	end

	local function sellables(life: any): { any }
		local out = {}
		local function add(gearId: string?, equipped: boolean)
			local v = gearId and itemView(gearId)
			if v then
				v.equipped = equipped
				table.insert(out, v)
			end
		end
		add(life.gear and life.gear.weapon, true)
		for _, id in life.stash or {} do
			add(id, false)
		end
		return out
	end

	local function view(player: Player, session: any): any
		local life = lifeOf(session)
		local rows = {}
		for _, l in listings do
			local v = itemView(l.gear)
			if v then
				v.id = l.id
				v.price = l.price
				v.seller = l.sellerName
				v.mine = l.seller == player.UserId
				table.insert(rows, v)
			end
		end
		table.sort(rows, function(a, b)
			if a.power ~= b.power then
				return a.power > b.power
			end
			return a.price < b.price
		end)
		return {
			listings = rows,
			mine = if life then sellables(life) else {},
			money = if life then life.money else 0,
			alive = life ~= nil,
			odds = Weapons.ODDS,
		}
	end

	local function broadcast(text: string, except: Player?)
		for p in S.sessions do
			if p ~= except then
				S.pushTo(p, { toast = text })
			end
		end
	end

	-- the life screen behind the market keeps up (the market calls the server on its own)
	local function refresh(player: Player, session: any, report: any?)
		if lifeOf(session) then
			S.pushTo(player, S.lifeResponse(session, report or sim.newReport()))
		end
	end

	local handlers = S.handlers
	function handlers.mkOpen(player, session)
		local notes = settle(player, session)
		local res = { ok = true, market = view(player, session) }
		if #notes > 0 then
			res.toast = table.concat(notes, " ")
			refresh(player, session)
		end
		return res
	end

	function handlers.mkSell(player, session, payload)
		local life = lifeOf(session)
		if not life then
			return { ok = false, error = "You need a living life to sell from." }
		end
		local gearId = type(payload) == "table" and payload.gear
		local price = type(payload) == "table" and tonumber(payload.price)
		if type(gearId) ~= "string" or not Weapons.parse(gearId) then
			return { ok = false, error = "That isn't a weapon." }
		end
		if not price or price ~= price or price < 1 or price > MAX_PRICE then
			return { ok = false, error = "Pick a price between 1 and 10,000,000 million won." }
		end
		price = math.floor(price)
		local count = 0
		for _, l in listings do
			if l.seller == player.UserId then
				count += 1
			end
		end
		if count >= MAX_LISTINGS then
			return { ok = false, error = "You can have six weapons on the market at once." }
		end
		-- take it out of the life: from the hand, or from the stash
		if life.gear and life.gear.weapon == gearId then
			life.gear.weapon = nil
		else
			local at = life.stash and table.find(life.stash, gearId)
			if not at then
				return { ok = false, error = "You don't have that weapon." }
			end
			table.remove(life.stash, at)
		end
		local data = session.profile.Data
		data.marketEscrow = data.marketEscrow or {}
		table.insert(data.marketEscrow, gearId)
		serial += 1
		table.insert(listings, { id = serial, seller = player.UserId, sellerName = player.DisplayName, gear = gearId, price = price, at = os.time() })
		local name = (Content.gear[gearId] or {}).name or gearId
		broadcast(string.format("MARKET: %s listed %s for %d million won.", player.DisplayName, name, price), player)
		refresh(player, session)
		return { ok = true, market = view(player, session), toast = "Listed. It's on the market until it sells or you take it back." }
	end

	function handlers.mkCancel(player, session, payload)
		local id = type(payload) == "table" and tonumber(payload.id)
		for i, l in listings do
			if l.id == id and l.seller == player.UserId then
				table.remove(listings, i)
				local notes = settle(player, session)
				refresh(player, session)
				return { ok = true, market = view(player, session), toast = notes[1] or "Taken off the market." }
			end
		end
		return { ok = false, error = "That listing is gone." }
	end

	function handlers.mkBuy(player, session, payload)
		local id = type(payload) == "table" and tonumber(payload.id)
		local life = lifeOf(session)
		if not life then
			return { ok = false, error = "You need a living life to buy with." }
		end
		local at, listing = nil, nil
		for i, l in listings do
			if l.id == id then
				at, listing = i, l
			end
		end
		if not listing then
			return { ok = false, error = "Someone else got there first." }
		end
		if listing.seller == player.UserId then
			return { ok = false, error = "That's your own listing." }
		end
		if life.money < listing.price then
			return { ok = false, error = string.format("You need %d million won.", listing.price) }
		end
		local seller = Players:GetPlayerByUserId(listing.seller)
		local sellerSession = seller and S.sessions[seller]
		if not sellerSession then
			table.remove(listings, at)
			return { ok = false, error = "The seller has left. The listing was taken down." }
		end
		-- the deal: money one way, the weapon the other, the escrow cleared
		table.remove(listings, at)
		life.money -= listing.price
		local report = sim.newReport()
		local extra = {}
		local base, stars, shiny = Weapons.parse(listing.gear)
		local cb, cs, csh = Weapons.parse(life.gear and life.gear.weapon)
		if not cb or Weapons.power(base, stars, shiny) > Weapons.power(cb, cs, csh) then
			sim:giveGear(life, listing.gear, extra)
		else
			life.stash = life.stash or {}
			if #life.stash < 30 and not table.find(life.stash, listing.gear) then
				table.insert(life.stash, listing.gear)
			end
		end
		for _, e in extra do
			sim:push(life, report, e)
		end
		local name = (Content.gear[listing.gear] or {}).name or listing.gear
		sim:push(life, report, { kind = "system", tone = "good", text = string.format("You bought %s from %s on the market for %d million won.", name, listing.sellerName, listing.price) })
		local sdata = sellerSession.profile.Data
		local escrowAt = table.find(sdata.marketEscrow or {}, listing.gear)
		if escrowAt then
			table.remove(sdata.marketEscrow, escrowAt)
		end
		local slife = lifeOf(sellerSession)
		if slife then
			slife.money += listing.price
			local sreport = sim.newReport()
			sim:push(slife, sreport, { kind = "system", tone = "good", text = string.format("%s bought your %s for %d million won.", player.DisplayName, name, listing.price) })
			local res = S.lifeResponse(sellerSession, sreport)
			res.toast = string.format("SOLD: %s, for %d million won.", name, listing.price)
			S.pushTo(seller :: Player, res)
		else
			sdata.marketWallet = (sdata.marketWallet or 0) + listing.price
			S.pushTo(seller :: Player, { toast = string.format("SOLD: %s. The money waits for your next life.", name) })
		end
		refresh(player, session, report)
		return { ok = true, market = view(player, session), toast = "Bought: " .. name .. "." }
	end

	-- a seller who leaves takes their listings down (the weapons stay in their escrow)
	Players.PlayerRemoving:Connect(function(player)
		for i = #listings, 1, -1 do
			if listings[i].seller == player.UserId then
				table.remove(listings, i)
			end
		end
	end)
end

return HunterMarket
