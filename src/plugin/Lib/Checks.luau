--[[
	CHECKS INSIDE STUDIO (BitLeveling Studio plugin): the same checks the repo's tools run
	(tools/checkgame), on the game installed in this place, so an edit made in Studio is checked
	where it was made.

		Checks.validate(shared)            -> { errors = {..}, warnings = {..}, title }
		Checks.simulate(shared, n, yield)  -> { lives, median, awakened, fates = {..}, crashes = {..} }
]]

local Checks = {}

function Checks.validate(shared: Instance): any
	local Engine = require(shared:WaitForChild("Engine") :: ModuleScript) :: any
	local pack = require(shared:WaitForChild("Pack") :: ModuleScript) :: any
	local issues = Engine.Validate.run(pack)
	return {
		title = pack.meta and pack.meta.title or pack.id,
		errors = issues.errors or {},
		warnings = issues.warnings or {},
		events = #(pack.events or {}),
	}
end

-- headless lives with random choices (boss fights fled): what a crash or a broken card shows
function Checks.simulate(shared: Instance, n: number, yield: (() -> ())?): any
	local Engine = require(shared:WaitForChild("Engine") :: ModuleScript) :: any
	local pack = require(shared:WaitForChild("Pack") :: ModuleScript) :: any
	local sim = Engine.new(pack)
	local ages, crashes, fates, awakened = {}, {}, {}, 0
	local rng = Random.new(os.time())
	for i = 1, n do
		local ok, err = pcall(function()
			local life = sim:newLife({ seed = rng:NextInteger(1, 1e9), difficulty = if i % 2 == 0 then "crisis" else "normal" })
			local guard = 0
			while life.alive and guard < 130 do
				guard += 1
				local g = 0
				while life.alive and life.pending and g < 30 do
					g += 1
					local ev = sim.eventsById[life.pending]
					local open = {}
					for k, c in (ev and ev.choices) or {} do
						if Engine.Conditions.check(c.requires, life, pack, { noChance = true }) then
							table.insert(open, k)
						end
					end
					if #open == 0 then
						life.pending = nil
						break
					end
					sim:choose(life, open[rng:NextInteger(1, #open)], nil)
					local turns = 0
					while life.battle and turns < 60 do
						turns += 1
						local key = tostring(life.id)
						Engine.Battle.act(sim, life, { [key] = life }, key, "flee")
					end
				end
				if life.alive then
					sim:ageUp(life)
				end
			end
			table.insert(ages, life.age)
			if life.form and life.form ~= "human" then
				awakened += 1
			end
			if life.fate then
				fates[life.fate] = (fates[life.fate] or 0) + 1
			end
		end)
		if not ok then
			table.insert(crashes, tostring(err))
		end
		if yield then
			yield()
		end
	end
	table.sort(ages)
	local list = {}
	for id, c in fates do
		table.insert(list, { id = id, n = c })
	end
	table.sort(list, function(a, b)
		return a.n > b.n
	end)
	return { lives = n, median = ages[math.max(1, #ages // 2)] or 0, awakened = awakened, fates = list, crashes = crashes }
end

return Checks
