--[[
	Global leaderboards ("who had the best life").

	Boards live in OrderedDataStores (one number per player: their best) with a
	small card per entry in a normal DataStore (the life behind the number: the
	character's name, title, age). Results are cached for a minute and a half.
	Without DataStore access (an unpublished place, Studio with API access off,
	tests) everything falls back to this server's memory.

	Writes only happen on a personal best, so dying a lot costs nothing.
]]

local DataStoreService = game:GetService("DataStoreService")

local Leaderboards = {}

local WEEK = 7 * 24 * 3600
local EPOCH_MONDAY = 345600 -- 1970-01-05 00:00 UTC, a Monday
local CACHE_SECONDS = 90
local TOP = 50
local CARDS = 25

Leaderboards.BOARDS = {
	{ id = "best", name = "Best life", unit = "points", desc = "The highest-scoring life each player has lived." },
	{ id = "week", name = "This week", unit = "points", desc = "The best life scored this week. Resets every Monday.", weekly = true },
	{ id = "oldest", name = "Oldest", unit = "years", desc = "The oldest anyone has lived to." },
	{ id = "richest", name = "Richest", unit = "scrip", desc = "The most scrip held at once, in any life." },
	{ id = "lines", name = "Family lines", unit = "generations", desc = "The longest family line, heir after heir." },
	{ id = "records", name = "Records", unit = "records", desc = "The most Records earned across all lives." },
	{ id = "fixers", name = "Fixers", unit = "", desc = "The best Fixer grade reached in any life. Ties go to whoever won more fights.", format = "grade" },
	{ id = "fights", name = "Fights won", unit = "fights", desc = "The most fights won in a single life." },
}

-- how a board's number reads: the Fixers board packs grade * 1000 + fights won
local GRADE_NAMES = { "Grade 9", "Grade 8", "Grade 7", "Grade 6", "Grade 5", "Grade 4", "Grade 3", "Grade 2", "Grade 1", "Color" }
local function display(board, value: number): string?
	if board.format == "grade" then
		return GRADE_NAMES[math.clamp(math.floor(value / 1000), 1, #GRADE_NAMES)]
	end
	return nil
end
Leaderboards.display = display

local function weekNumber(): number
	return math.floor((os.time() - EPOCH_MONDAY) / WEEK)
end
Leaderboards.weekNumber = weekNumber

local function storeName(board): string
	if board.weekly then
		return "LifeSim_LB_" .. board.id .. "_" .. weekNumber()
	end
	return "LifeSim_LB_" .. board.id
end

local memory = {} -- [storeName] = { [userId string] = value }
local memoryCards = {} -- [storeName .. userId] = card
local cache = {} -- [boardId] = { at, entries, week }
local refreshing = {}

local function ordered(board)
	local ok, store = pcall(function()
		return DataStoreService:GetOrderedDataStore(storeName(board))
	end)
	return if ok then store else nil
end

local function cardStore()
	local ok, store = pcall(function()
		return DataStoreService:GetDataStore("LifeSim_LBCards")
	end)
	return if ok then store else nil
end

-- the money board names the pack's currency ("scrip", "Ahn")
function Leaderboards.setCurrency(word: string?)
	if not word then
		return
	end
	for _, b in Leaderboards.BOARDS do
		if b.id == "richest" then
			b.unit = word
			b.desc = "The most " .. word .. " held at once, in any life."
		end
	end
end

function Leaderboards.board(id: string)
	for _, b in Leaderboards.BOARDS do
		if b.id == id then
			return b
		end
	end
	return nil
end

-- Records a value for a player if it beats what's stored. card = { name, life, title, age, zone }
function Leaderboards.submit(boardId: string, userId: number, value: number, card)
	local board = Leaderboards.board(boardId)
	if not board or type(value) ~= "number" then
		return
	end
	value = math.floor(value)
	local name = storeName(board)
	local key = tostring(userId)
	memory[name] = memory[name] or {}
	local improved = (memory[name][key] or -1) < value
	if improved then
		memory[name][key] = value
		memoryCards[name .. key] = card
	end
	cache[boardId] = nil
	task.spawn(function()
		local store = ordered(board)
		local stored = false
		if store then
			stored = pcall(function()
				store:UpdateAsync(key, function(old)
					if type(old) == "number" and old >= value then
						return nil -- keep the better one
					end
					return value
				end)
			end)
		end
		local cards = cardStore()
		if cards and card and (improved or stored) then
			pcall(function()
				cards:SetAsync(name .. "_" .. key, card)
			end)
		end
	end)
end

local function refresh(board)
	if refreshing[board.id] then
		return
	end
	refreshing[board.id] = true
	local name = storeName(board)
	local entries = nil
	local store = ordered(board)
	if store then
		local ok, page = pcall(function()
			return store:GetSortedAsync(false, TOP):GetCurrentPage()
		end)
		if ok and type(page) == "table" then
			entries = {}
			local cards = cardStore()
			for i, item in page do
				local card = memoryCards[name .. item.key]
				if not card and cards and i <= CARDS then
					local gotOk, got = pcall(function()
						return cards:GetAsync(name .. "_" .. item.key)
					end)
					card = if gotOk then got else nil
				end
				table.insert(entries, { userId = tonumber(item.key), value = item.value, card = card })
			end
		end
	end
	if not entries then
		-- no DataStores here: this server's memory only
		entries = {}
		for key, value in memory[name] or {} do
			table.insert(entries, { userId = tonumber(key), value = value, card = memoryCards[name .. key] })
		end
		table.sort(entries, function(a, b)
			return a.value > b.value
		end)
		while #entries > TOP do
			table.remove(entries)
		end
	end
	cache[board.id] = { at = os.clock(), entries = entries, week = weekNumber() }
	refreshing[board.id] = nil
end

-- The board as the client shows it. Waits for the first load; later calls
-- return the cache and refresh it in the background.
function Leaderboards.view(boardId: string, viewerId: number?)
	local board = Leaderboards.board(boardId) or Leaderboards.BOARDS[1]
	local c = cache[board.id]
	if not c or c.week ~= weekNumber() then
		refresh(board)
		c = cache[board.id]
	elseif os.clock() - c.at > CACHE_SECONDS then
		task.spawn(refresh, board)
	end
	local out = {}
	for i, e in (c and c.entries) or {} do
		local card = e.card or {}
		table.insert(out, {
			rank = i,
			value = e.value,
			display = display(board, e.value),
			name = card.name or ("Player " .. tostring(e.userId)),
			life = card.life,
			title = card.title,
			detail = card.detail,
			patron = card.patron == true,
			you = viewerId ~= nil and e.userId == viewerId,
		})
	end
	return { id = board.id, name = board.name, unit = board.unit, desc = board.desc, entries = out }
end

function Leaderboards.list()
	local out = {}
	for _, b in Leaderboards.BOARDS do
		table.insert(out, { id = b.id, name = b.name, desc = b.desc })
	end
	return out
end

-- for tests
function Leaderboards._reset()
	memory, memoryCards, cache, refreshing = {}, {}, {}, {}
end

return Leaderboards
