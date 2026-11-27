--[[
	Deterministic RNG stored on a plain table (st.rng = number), so a life's
	randomness is saved with the life and the engine stays pure Luau.
	MINSTD (Park-Miller, multiplier 48271).
]]

local Rng = {}

local MOD = 2147483647
local MUL = 48271

function Rng.seed(n: number): number
	n = math.floor(math.abs(n)) % MOD
	if n == 0 then
		n = 1
	end
	return n
end

-- Returns a float in [0, 1).
function Rng.next(st): number
	st.rng = (st.rng * MUL) % MOD
	return (st.rng - 1) / (MOD - 1)
end

function Rng.int(st, a: number, b: number): number
	if a > b then
		a, b = b, a
	end
	return a + math.floor(Rng.next(st) * (b - a + 1))
end

function Rng.chance(st, p: number): boolean
	return Rng.next(st) < p
end

function Rng.pick(st, list)
	if #list == 0 then
		return nil
	end
	return list[Rng.int(st, 1, #list)]
end

-- A value that is either a number or a {min, max} range.
function Rng.roll(st, v): number
	if type(v) == "table" then
		return Rng.int(st, math.floor(v[1]), math.floor(v[2]))
	end
	return v or 0
end

-- Weighted pick; returns the index or nil.
function Rng.weighted(st, weights: { number }): number?
	local total = 0
	for _, w in weights do
		total += w
	end
	if total <= 0 then
		return nil
	end
	local r = Rng.next(st) * total
	for i, w in weights do
		r -= w
		if r < 0 then
			return i
		end
	end
	return #weights
end

return Rng
