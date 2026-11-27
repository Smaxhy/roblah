--[[
	Compiles every .luau file under src/ (syntax only: Roblox-side code can't run headless).
		lune run tests/compile_check
]]
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local bad, n = 0, 0
local function walk(dir: string)
	for _, name in fs.readDir(dir) do
		local path = dir .. "/" .. name
		if fs.isDir(path) then
			walk(path)
		elseif string.sub(name, -5) == ".luau" then
			n += 1
			local ok, err = pcall(luau.compile, fs.readFile(path))
			if not ok then
				bad += 1
				print("  SYNTAX " .. path .. ": " .. tostring(err))
			end
		end
	end
end
walk("src")
print(string.format("compiled %d files, %d with syntax errors", n, bad))
if bad > 0 then
	process.exit(1)
end
