-- lune run tests/_show id1 id2 ...  : a card's words, in full (a review tool)
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local pack = Loader.require(root.Pack)
local want = {}
for _, a in process.args do want[a] = true end
local function s(t) if type(t) == "table" then return table.concat(t, "  ||  ") end return tostring(t) end
local function res(tag, r)
	if type(r) ~= "table" then return end
	local keys = {}
	for k, v in r do
		if k ~= "log" and k ~= "goal" and k ~= "dialogue" and k ~= "linked" then
			table.insert(keys, k .. "=" .. (if type(v) == "table" then "{" .. s((function() local o = {} for _, x in v do table.insert(o, tostring(x)) end return o end)()) .. "}" else tostring(v)))
		end
	end
	table.sort(keys)
	print("      " .. tag .. " [" .. table.concat(keys, " ") .. "] " .. s(r.log or ""))
end
for _, e in pack.events do
	local hit = want[e.id]
	if not hit then for a in want do if string.sub(a, -1) == "*" and string.sub(e.id, 1, #a - 1) == string.sub(a, 1, -2) then hit = true end end end
	if hit then
		print("== " .. e.id .. " :: " .. s(e.title))
		print("   " .. s(e.text))
		for _, d in e.dialogue or {} do print("   > " .. tostring(d.who) .. ": " .. s(d.line)) end
		res("result", e.result)
		for _, c in e.choices or {} do
			print("   - " .. s(c.label) .. (if c.hint then "  (" .. s(c.hint) .. ")" else ""))
			res("result", c.result); res("win", c.win); res("lose", c.lose)
		end
	end
end
