--[[
	NEW GAME: scaffold a game made with the blueprint.

		lune run tools/newgame <Id>                    from templates/Starter
		lune run tools/newgame <Id> --from Emberhold   from another game (or template)
		lune run tools/newgame <Id> --title "My Game"  and set its title
		lune run tools/newgame --use <Id>              make an existing game the one that runs (and
		                                               rewrite its two project files)
		lune run tools/newgame --list                  the games and templates there are

	What it does:
		1. copies the template into src/shared/Games/<Id>/ (Spec.luau, Events/, Careers.luau...)
		2. sets the copy's spec id (and title)
		3. writes games/<Id>.project.json (the place) and games/<Id>.kit.project.json (the kit):
		   Rojo projects with only the engine, Base and this game in them (the City and
		   Undermere reference packs stay out of the build)
		4. points src/shared/Config.luau at it (pack = "<Id>", its own DataStore name)
	Then: edit src/shared/Games/<Id>/Spec.luau and the content beside it, and check it with
		lune run tools/checkgame <Id>
]]

local fs = require("@lune/fs")
local process = require("@lune/process")

local args = process.args
local function flag(name: string): string?
	for i, a in args do
		if a == name then
			return args[i + 1]
		end
	end
	return nil
end
local function has(name: string): boolean
	return table.find(args, name) ~= nil
end

local GAMES = "src/shared/Games"
local TEMPLATES = "templates"
local CONFIG = "src/shared/Config.luau"

local function fail(msg: string)
	print("newgame: " .. msg)
	process.exit(1)
end

local function copyDir(src: string, dst: string)
	fs.writeDir(dst)
	for _, name in fs.readDir(src) do
		local s, d = src .. "/" .. name, dst .. "/" .. name
		if fs.isDir(s) then
			copyDir(s, d)
		else
			fs.writeFile(d, fs.readFile(s))
		end
	end
end

local function useGame(id: string)
	if not fs.isDir(GAMES .. "/" .. id) then
		fail("there's no game called " .. id .. " in " .. GAMES)
	end
	local cfg = fs.readFile(CONFIG)
	local n1, n2
	cfg, n1 = string.gsub(cfg, '\n(\t)pack = "[^"]*",', '\n%1pack = "' .. id .. '",', 1)
	cfg, n2 = string.gsub(cfg, '\n(\t)dataStoreName = "[^"]*",', '\n%1dataStoreName = "LifeSim_' .. id .. '_v1",', 1)
	if n1 ~= 1 or n2 ~= 1 then
		fail("couldn't find `pack = ...` and `dataStoreName = ...` in " .. CONFIG)
	end
	fs.writeFile(CONFIG, cfg)
	print(string.format("Config.pack = %q, dataStoreName = %q", id, "LifeSim_" .. id .. "_v1"))
end

local function projectFor(id: string): string
	return string.format(
		[[{
  "name": "%s",
  "tree": {
    "$className": "DataModel",
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "LifeSimKit": {
        "$className": "Folder",
        "Install": { "$path": "../src/Install.server.luau" },
        "Shared": {
          "$className": "Folder",
          "Engine": { "$path": "../src/shared/Engine" },
          "Base": { "$path": "../src/shared/Base" },
          "Games": {
            "$className": "Folder",
            "%s": { "$path": "../src/shared/Games/%s" }
          },
          "Pack": { "$path": "../src/shared/Pack.luau" },
          "Config": { "$path": "../src/shared/Config.luau" }
        },
        "Server": { "$path": "../src/server" },
        "Client": { "$path": "../src/client" }
      }
    },
    "Players": { "$className": "Players", "$properties": { "CharacterAutoLoads": false } },
    "ReplicatedStorage": { "$className": "ReplicatedStorage" },
    "Lighting": { "$className": "Lighting" },
    "Workspace": { "$className": "Workspace" }
  }
}
]],
		id,
		id,
		id
	)
end

-- the importable kit for this game alone: drag build/<Id>Kit.rbxmx into a place you already have
local function kitFor(id: string): string
	return string.format(
		[[{
  "name": "%sKit",
  "tree": {
    "$className": "Folder",
    "Install": { "$path": "../src/Install.server.luau" },
    "Shared": {
      "$className": "Folder",
      "Engine": { "$path": "../src/shared/Engine" },
      "Base": { "$path": "../src/shared/Base" },
      "Games": {
        "$className": "Folder",
        "%s": { "$path": "../src/shared/Games/%s" }
      },
      "Pack": { "$path": "../src/shared/Pack.luau" },
      "Config": { "$path": "../src/shared/Config.luau" }
    },
    "Server": { "$path": "../src/server" },
    "Client": { "$path": "../src/client" }
  }
}
]],
		id,
		id,
		id
	)
end

local function writeProjects(id: string)
	fs.writeDir("games")
	fs.writeFile("games/" .. id .. ".project.json", projectFor(id))
	fs.writeFile("games/" .. id .. ".kit.project.json", kitFor(id))
end

if has("--list") then
	print("games (" .. GAMES .. "):")
	for _, name in fs.readDir(GAMES) do
		if fs.isDir(GAMES .. "/" .. name) then
			print("  " .. name)
		end
	end
	print("templates (" .. TEMPLATES .. "):")
	for _, name in fs.readDir(TEMPLATES) do
		if fs.isDir(TEMPLATES .. "/" .. name) then
			print("  " .. name)
		end
	end
	return
end

local useId = flag("--use")
if useId then
	useGame(useId)
	writeProjects(useId)
	return
end

local id = args[1]
if not id or string.sub(id, 1, 2) == "--" then
	fail("usage: lune run tools/newgame <Id> [--from <Game or template>] [--title \"Title\"]")
end
if not string.match(id :: string, "^[A-Z][A-Za-z0-9]+$") then
	fail("the id is a folder and a save name: letters and digits, starting with a capital (" .. id .. ")")
end
local dest = GAMES .. "/" .. id
if fs.isDir(dest) and not has("--force") then
	fail(dest .. " already exists (--force writes over it)")
end

local from = flag("--from") or "Starter"
local src = nil
if fs.isDir(GAMES .. "/" .. from) then
	src = GAMES .. "/" .. from
elseif fs.isDir(TEMPLATES .. "/" .. from) then
	src = TEMPLATES .. "/" .. from
else
	fail("no game or template called " .. from)
end

copyDir(src :: string, dest)

-- the copy's own id (and title)
local specPath = dest .. "/Spec.luau"
if fs.isFile(specPath) then
	local spec = fs.readFile(specPath)
	spec = string.gsub(spec, '\n(\t)id = "[^"]*",', '\n%1id = "' .. id .. '",', 1)
	local title = flag("--title")
	if title then
		spec = string.gsub(spec, '\n(\t\t)title = "[^"]*",', '\n%1title = "' .. string.gsub(title, '"', '\\"') .. '",', 1)
	end
	fs.writeFile(specPath, spec)
end

-- a build with only this game in it
writeProjects(id)

useGame(id)
print(string.format(
	[[
New game: %s (from %s)
  src/shared/Games/%s/Spec.luau     the spec: title, stats, world, careers, look, places, store...
  src/shared/Games/%s/Events/       the cards
  src/shared/Games/%s/*.luau        careers, activities, gear, foes, bosses, dungeons, store
  games/%s.project.json             the build (rojo build games/%s.project.json -o build/%s.rbxlx)
Check it:  lune run tools/checkgame %s]],
	id, from, id, id, id, id, id, id, id
))
