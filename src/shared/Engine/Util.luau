local Util = {}

function Util.clamp(x: number, lo: number, hi: number): number
	if x < lo then
		return lo
	elseif x > hi then
		return hi
	end
	return x
end

function Util.asList(v): { any }?
	if v == nil then
		return nil
	end
	if type(v) == "table" then
		return v
	end
	return { v }
end

function Util.contains(list, value): boolean
	if list == nil then
		return false
	end
	for _, v in list do
		if v == value then
			return true
		end
	end
	return false
end

function Util.deepCopy(t)
	if type(t) ~= "table" then
		return t
	end
	local out = {}
	for k, v in t do
		out[k] = Util.deepCopy(v)
	end
	return out
end

-- Replaces {token} with ctx[token] (if present). Unknown tokens are left as-is.
function Util.render(text: string?, ctx): string
	if text == nil then
		return ""
	end
	return (string.gsub(text, "{(%w+)}", function(key)
		local v = ctx[key]
		if v == nil then
			return nil
		end
		return tostring(v)
	end))
end

function Util.signed(n: number): string
	if n > 0 then
		return "+" .. tostring(n)
	end
	return tostring(n)
end

return Util
