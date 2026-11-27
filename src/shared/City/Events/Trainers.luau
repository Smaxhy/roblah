--[[
	MEETING A TEACHER (v0.17): one card per trainer in City/Trainers.luau. They only come up
	when you go looking ("Look for someone to train you": Engine/Training.luau puts the card of
	someone who'd take you on in this year's queue). Ask, or prove you're worth teaching.
]]

local Trainers = require(script.Parent.Parent:WaitForChild("Trainers"))

local events = {}
for _, t in Trainers.list do
	local choices = {
		{ label = "Ask " .. t.short .. " to teach you", requires = t.accept, result = { train = { start = t.id }, log = t.yes or (t.short .. " agreed.") } },
	}
	if t.test then
		table.insert(choices, {
			label = "Prove you're worth teaching",
			clash = t.test,
			win = { train = { start = t.id }, log = t.yes or (t.short .. " agreed.") },
			lose = { health = { -10, -4 }, log = t.no or (t.short .. " wasn't impressed. Yet.") },
		})
	end
	table.insert(choices, { label = "Not now", result = { log = "You thanked " .. t.short .. " and left. The offer didn't seem to expire." } })
	table.insert(events, {
		id = "tr_meet_" .. t.id,
		title = t.name,
		art = t.art or "street",
		weight = 0,
		tags = { "training" },
		text = t.text,
		scene = { set = t.set or "street", title = t.name, line = t.line, other = { name = t.name, role = t.role, pose = "stand", look = t.look } },
		choices = choices,
	})
end

return events
