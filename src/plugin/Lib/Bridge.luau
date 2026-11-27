--[[
	THE LOCAL BRIDGE, STUDIO SIDE (BitLeveling Studio plugin).

	tools/studio_bridge/bridge.py runs a tiny web server on this computer (127.0.0.1 only). While
	"Connect" is on, this asks it for work every moment: a piece of Luau to run in this Studio
	session. It runs it, collects everything printed while it ran (and what it returned), and
	sends that back. So a terminal, a test script or an AI agent on the same computer can drive
	Studio:  python3 tools/studio_bridge/bridge.py run "print(workspace:GetChildren())"

	Only this computer can reach it, it only runs while you have it switched on, and every request
	carries a header a web page can't send (the server refuses browsers). Roblox Studio also has
	its own MCP server for AI tools (Assistant > Manage MCP Servers); this works without it.

		Bridge.start(port, log, onState)   Bridge.stop()   Bridge.runChunk(code) -> result
]]

local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

local Bridge = {}
local running = false
local generation = 0

-- run a chunk of Luau, with what it printed and returned
function Bridge.runChunk(code: string): any
	local out = {}
	local conn = LogService.MessageOut:Connect(function(msg, kind)
		table.insert(out, (if kind == Enum.MessageType.MessageWarning then "warn: " elseif kind == Enum.MessageType.MessageError then "error: " else "") .. msg)
	end)
	local fn, compileErr = loadstring(code, "=bridge")
	local result = { ok = false }
	if not fn then
		result.error = "compile: " .. tostring(compileErr)
	else
		local packed = table.pack(pcall(fn))
		result.ok = packed[1]
		if packed[1] then
			local rets = {}
			for i = 2, packed.n do
				table.insert(rets, tostring(packed[i]))
			end
			result.returns = rets
		else
			result.error = tostring(packed[2])
		end
	end
	task.wait() -- (let the last prints arrive)
	conn:Disconnect()
	result.output = out
	return result
end

local function request(port: number, method: string, path: string, body: any?): (boolean, any)
	local ok, res = pcall(function()
		return HttpService:RequestAsync({
			Url = string.format("http://127.0.0.1:%d%s", port, path),
			Method = method,
			Headers = { ["X-Bridge-Plugin"] = "1", ["Content-Type"] = "application/json" },
			Body = if body then HttpService:JSONEncode(body) else nil,
		})
	end)
	if not ok then
		return false, res
	end
	return true, res
end

function Bridge.start(port: number, log: (string) -> (), onState: (string) -> ())
	generation += 1
	local mine = generation
	running = true
	onState("connecting")
	task.spawn(function()
		local wasUp = false
		while running and generation == mine do
			local ok, res = request(port, "GET", "/poll")
			if not ok or not res.Success and res.StatusCode ~= 204 then
				if wasUp then
					log("Bridge: lost the server on port " .. port .. ". Retrying.")
				end
				wasUp = false
				onState("waiting for bridge.py on port " .. port)
				task.wait(2)
			else
				if not wasUp then
					log("Bridge: connected to bridge.py on port " .. port .. ".")
					onState("connected")
				end
				wasUp = true
				if res.StatusCode == 200 and res.Body ~= "" then
					local okJson, job = pcall(HttpService.JSONDecode, HttpService, res.Body)
					if okJson and type(job) == "table" and job.code then
						log("Bridge: running job " .. tostring(job.id))
						local result = Bridge.runChunk(job.code)
						result.id = job.id
						request(port, "POST", "/result", result)
					end
				end
			end
		end
	end)
end

function Bridge.stop()
	running = false
	generation += 1
end

return Bridge
