--[[
	TRAINING (v0.17): looking for a teacher, the lessons with whoever took you on (one activity
	per trainer in City/Trainers.luau, shown while you're their student), and the long-life
	treatments a grown body can buy (the `lifespan` effect: Engine/Body.luau lifespan).
]]

local Trainers = require(script.Parent.Parent:WaitForChild("Trainers"))

local STAT_NAMES = {
	health = "Health", strength = "Strength", speed = "Speed", intelligence = "Intelligence",
	charisma = "Charisma", luck = "Luck", mind = "Mental Strength",
}

local acts = {
	{
		id = "tr_find", category = "self", icon = "misc.fight", name = "Look for someone to train you",
		desc = "Noodle stalls, Office back rooms, a gym that's also a garage. Somebody out there could teach you what you can't teach yourself, if they think you're worth it. Teachers grow a stat past its limits, teach techniques, and break your ceiling.",
		minAge = 18, cooldown = 1,
		result = { train = { find = true }, log = "You asked around: noodle stalls, Office back rooms, a gym that's also a garage. Somebody pointed you somewhere." },
	},
	{
		id = "tr_kcorp_regen", category = "self", icon = "stat.health", name = "A K Corp regeneration course",
		desc = "A K Corp clinic behind a Nest wall takes walk-ins who can pay: a month of ampules and a body that feels ten years younger, and lasts six years longer. Every five years, if you can afford it.",
		minAge = 40, cost = 4000, cooldown = 5,
		result = { lifespan = 6, maxHealth = 5, health = { 10, 20 }, sanity = { 1, 3 }, log = "A month in a white bed with green ampules going into your arm. You walked out lighter. The clerk at the desk said they'd see you in five years, cheerfully." },
	},
	{
		id = "tr_workshop_body", category = "self", icon = "stat.health", name = "A Workshop body",
		desc = "The most expensive thing a Workshop sells: most of a body, rebuilt. Twenty-five more years, a stronger frame, and a ceiling that's higher. People will look at you differently. You'll look at yourself differently too.",
		minAge = 45, cost = 25000, when = { notFlags = { "workshop_body" } },
		result = { lifespan = 25, maxHealth = 30, limitBreak = { strength = 20, speed = 10 }, charisma = -3, sanity = { -12, -6 }, setFlags = { "workshop_body" }, log = "Three months in a Workshop. You came out heavier, steadier, and quieter. Your hands are warm in a way they weren't. The mirror took a while." },
	},
}

for _, t in Trainers.list do
	table.insert(acts, {
		id = "tr_lesson_" .. t.id,
		category = "self",
		icon = "stat." .. t.stat,
		name = "Train with " .. t.short,
		desc = string.format("Lessons with %s, %s. Grows your %s, past its old limits too; techniques and limit courses come as you go.", t.name, t.role, STAT_NAMES[t.stat] or t.stat),
		minAge = 16,
		when = { flags = { "tr_" .. t.id } },
		cost = t.fee or 0,
		result = { train = { lesson = t.id }, health = { -4, -1 }, log = t.lessonLog or ("Another lesson with " .. t.short .. ". It hurt in the useful way.") },
	})
end

return acts
