--[[
	BASE ACTIVITIES: what anyone in any world can do with a year (the DO tab). One per stat,
	plus healing, the gear shop, odd jobs, moving house and family. A game's own activities
	(spec.activities and its Activities module) come after these, and a game can drop any of
	these by id (spec.dropActivities = { "odd_jobs" }) or reword them (spec.activityText =
	{ train = { name = "...", desc = "...", log = "..." } }).

	Same shape as a card's choice, plus when / cost / cooldown / minAge / category / move.
	`social = true` (or category "people") spends the year's time for people, not an action.
]]

local Activities = {}

Activities.CATEGORIES = {
	order = { "self", "money", "gear", "people", "home" },
	self = "Body & mind",
	money = "Money",
	gear = "Gear",
	people = "People",
	home = "Home",
}

function Activities.build(roles: any, sides: { any }): { any }
	local fight, speed, work, charm, will, health = roles.fight.id, roles.speed.id, roles.work.id, roles.charm.id, roles.will.id, roles.health.id
	local list = {
		{
			id = "train", category = "self", name = "Train", minAge = 8,
			desc = "Work on your " .. roles.fight.name .. " until something sticks.",
			result = { [fight] = { 2, 4 }, [health] = { 0, 1 }, sanity = { -1, 0 }, log = "You trained hard all year. Your hands remember it." },
		},
		{
			id = "drills", category = "self", name = "Run drills", minAge = 8,
			desc = "Footwork, sprints, getting out of the way. " .. roles.speed.name .. ".",
			result = { [speed] = { 2, 4 }, sanity = { -1, 0 }, log = "You ran until running felt like breathing." },
		},
		{
			id = "study", category = "self", name = "Study", minAge = 6,
			desc = "Books, lessons, whatever you can borrow. " .. roles.work.name .. ".",
			result = { [work] = { 2, 4 }, log = "You studied until your eyes ached, and it stayed in." },
		},
		{
			id = "mingle", category = "people", name = "Go out and meet people", minAge = 10,
			desc = "Talk to strangers. Some of them stop being strangers. " .. roles.charm.name .. ".",
			result = { [charm] = { 1, 3 }, sanity = { 1, 2 }, meet = true, log = "You went out and talked to people, and some of them talked back." },
		},
		{
			id = "reflect", category = "self", name = "A quiet hour", minAge = 4,
			desc = "Sit somewhere still and let the noise go. " .. roles.will.name .. " and mood.",
			result = { [will] = { 1, 3 }, sanity = { 2, 5 }, log = "You sat somewhere quiet until your head went still." },
		},
		{
			id = "healer", category = "self", name = "See a healer", cost = 30,
			desc = "Patch up whatever the year broke, and treat one injury or illness.",
			result = { [health] = { 6, 12 }, cure = "any", log = "A healer patched you up and took your {currency}." },
		},
		{
			id = "shop", category = "gear", name = "Visit the shops", minAge = 10, shop = true,
			desc = "Weapons, coats and charms. Gear changes your odds in fights. Browsing is free.",
		},
		{
			id = "treat", category = "self", name = "Treat yourself", minAge = 6, cost = 5,
			desc = "Something warm, somewhere loud, for not much.",
			result = { sanity = { 2, 5 }, log = "You treated yourself, and laughed at a stranger's joke." },
		},
		{
			id = "odd_jobs", category = "money", name = "Odd jobs", minAge = 10,
			desc = "Carry, fetch, sweep. Richer places pay more.",
			result = { [health] = { 0, 1 }, wage = { 6, 16 }, log = "You did odd jobs for a few {currency}." },
		},
		{
			id = "double_shift", category = "money", name = "Work a double shift",
			desc = "More pay. Less of you.",
			when = { anyCareer = true },
			result = { paycheck = 0.35, [health] = { -4, -1 }, sanity = { -3, -1 }, log = "You worked double shifts until your hands stopped feeling like yours." },
		},
		{
			id = "risky_job", category = "money", name = "Take a risky job", minAge = 15,
			desc = "Good money for something nobody else wants to do. It can go wrong.",
			clash = { stat = fight, foe = "A job that went wrong", coins = 2, base = 4, coinPower = 3, fight = true },
			win = { wage = { 30, 90 }, [fight] = 1, log = "It went wrong, the way they said it might, and you handled it. The pay was good." },
			lose = { [health] = { -12, -5 }, sanity = -3, log = "It went wrong, and you weren't ready.", cause = "A risky job that went wrong" },
		},
		{
			id = "visit_family", category = "people", name = "Visit family", minAge = 14,
			desc = "Sit with the people who knew you small.",
			when = { hasRelation = { "mother", "father", "sibling", "child" } },
			result = { sanity = { 1, 4 }, relationBond = { kind = "family", amount = 6 }, log = "You spent an evening with family. Nobody fixed anything, and it helped anyway." },
		},
	}
	-- moving house: up to the better side (it costs that place's price), down, or elsewhere
	if #sides >= 2 then
		local rich, poor = sides[1], sides[#sides]
		table.insert(list, {
			id = "move_up", category = "home", name = "Move to " .. rich.name, minAge = 18, move = "charter",
			desc = "Buy your way into " .. rich.name .. ". Safer, dearer, and the neighbors notice everything.",
			result = { sanity = 4, log = "You moved to " .. rich.name .. ". The first night, the quiet kept you awake." },
		})
		table.insert(list, {
			id = "move_down", category = "home", name = "Move to " .. poor.name, minAge = 16, move = "gutters",
			desc = "Cheaper rent. Louder nights.",
			result = { sanity = -2, log = "You moved to " .. poor.name .. ". It's cheaper. It's also louder." },
		})
	end
	table.insert(list, {
		id = "move_away", category = "home", name = "Move somewhere else", minAge = 18, move = "district", cost = 40,
		desc = "Pack a bag and start over somewhere new.",
		result = { sanity = 2, log = "You packed a bag and started over somewhere new." },
	})
	return list
end

return Activities
