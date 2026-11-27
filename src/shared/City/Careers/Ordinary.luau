--[[
	Ordinary work: the jobs most people in the City actually do. Staying small is a life too,
	and every one of these ladders goes all the way up: a cook can end up owning half the
	street's kitchens, a runner can end up owning the route.
	Canon notes: docs/CANON.md sections 1.6, 8.1, 8.2 and 8.7.
	Fields: name, desc, ranks, salary (per rank), minAge, requires (conditions: district,
	world.era, stats...), sides, guttersRequire (extra need from the Backstreets),
	promoteStat + promoteAt (stat needed for ranks 2..n), yearsPerRank, yearly, hazard,
	rankFlags = { [rank] = "flag" } (a lasting mark, for records and stories), sort (UI order).
	`company = true` means the District's own Wing (its name comes from the District's corp).
	Every module in Careers/ is merged by init.luau; ids must be unique across files.

	Rank bands for the career events in Events/Life_Careers.luau:
		rank 1          career = id, notFlags = { "bs_<id>_r2" }
		ranks 2-3       career = id, minRank = 2, notFlags = { "bs_<id>_r4" }
		ranks 4-5       career = id, minRank = 4
	Every top rank sets bs_ordinary_top (a record and a title look for it).
]]

return {
	order = { "workshop", "diner", "academy", "courier", "clinic", "nest_clerk", "landlord" },

	workshop = {
		sort = 40,
		name = "Workshop",
		uniform = "workshop_apron",
		desc = "Design, build and sell weapons, armor and prosthetics for Fixers. A good maker's mark is worth more than a good name, and every useful trick is somebody's patent.",
		ranks = { "Apprentice", "Journeyman", "Smith", "Master Smith", "Workshop Rep" },
		salary = { 35, 70, 140, 260, 480 },
		minAge = 14,
		requires = { min = { intelligence = 22 } },
		promoteStat = "intelligence",
		promoteAt = { 34, 48, 62, 76 },
		yearsPerRank = 3,
		rankFlags = { [1] = "bs_workshop_trained", [2] = "bs_workshop_r2", [4] = "bs_workshop_r4", [5] = "bs_ordinary_top" },
		hazard = { chance = 0.06, result = { condition = "burns", health = { -4, -1 }, log = "The forge bit you. Every smith has the scars, and now you have one more." } },
	},

	diner = {
		sort = 41,
		name = "Backstreets Diner",
		uniform = "diner_whites",
		desc = "Noodles, soup, and closing time well before three. The pay is bad, the regulars are worse, the Syndicate wants its fee, and you'll eat every day.",
		ranks = { "Dishwasher", "Line Cook", "Head Cook", "Owner", "Restaurateur" },
		salary = { 25, 45, 85, 170, 330 },
		minAge = 12,
		sides = { "backstreets" },
		promoteStat = "intelligence",
		promoteAt = { 24, 38, 54, 70 },
		yearsPerRank = 2,
		rankFlags = { [1] = "bs_job_diner", [2] = "bs_diner_r2", [4] = "bs_diner_r4", [5] = "bs_ordinary_top" },
		yearly = { sanity = { 0, 1 } },
		hazard = { chance = 0.07, result = { money = { -40, -10 }, sanity = -2, log = "A pack of Rats came in at closing time and left with the till." } },
	},

	academy = {
		sort = 42,
		name = "Academy",
		desc = "Teach at a Backstreets academy: arithmetic, history, Wing exam prep, and the rules that keep kids alive. Some of your students will be Fixers. Some will be Rats. You teach them all.",
		ranks = { "Teaching Assistant", "Teacher", "Head Teacher", "Academy Director", "Academy Owner" },
		salary = { 45, 85, 150, 250, 420 },
		minAge = 18,
		requires = { min = { intelligence = 36 } },
		promoteStat = "intelligence",
		promoteAt = { 48, 60, 72, 84 },
		yearsPerRank = 3,
		rankFlags = { [1] = "bs_job_academy", [2] = "bs_academy_r2", [4] = "bs_academy_r4", [5] = "bs_ordinary_top" },
		yearly = { sanity = { 0, 1 } },
		hazard = { chance = 0.04, result = { sanity = { -6, -2 }, log = "One of your students didn't come back after a Night. Their desk stayed empty all year." } },
	},

	courier = {
		sort = 43,
		name = "Backstreets Courier",
		uniform = "courier_vest",
		desc = "Letters, parcels and things people would rather not carry themselves, through streets that change their minds. Never late, never curious, always home before three. The Devyat' Association is the dream; the route is the job.",
		ranks = { "Neighborhood Runner", "Licensed Courier", "Route Rider", "Route Boss", "Route Owner" },
		salary = { 20, 45, 90, 180, 340 },
		minAge = 12,
		promoteStat = "strength",
		promoteAt = { 22, 34, 48, 62 },
		yearsPerRank = 2,
		rankFlags = { [1] = "bs_job_courier", [2] = "bs_courier_r2", [4] = "bs_courier_r4", [5] = "bs_ordinary_top" },
		hazard = { chance = 0.07, result = { money = { -30, -10 }, health = { -6, -2 }, log = "Rats jumped you halfway through a delivery. You kept the parcel and lost your wages.", cause = "Mugged on a delivery" } },
	},

	clinic = {
		sort = 44,
		name = "Back-Alley Clinic",
		uniform = "street_medic",
		desc = "Stitches, ampules and the odd Bolus for people who can't afford a Nest hospital. Licensed or not, you will see everything the City can do to a body, and you'll be open when nobody else is.",
		ranks = { "Clinic Aide", "Practitioner", "Doctor", "Senior Doctor", "Clinic Owner" },
		salary = { 35, 70, 140, 260, 460 },
		minAge = 16,
		requires = { min = { intelligence = 30 } },
		promoteStat = "intelligence",
		promoteAt = { 42, 54, 66, 78 },
		yearsPerRank = 3,
		rankFlags = { [1] = "bs_job_clinic", [2] = "bs_clinic_r2", [4] = "bs_clinic_r4", [5] = "bs_ordinary_top" },
		yearly = { sanity = { -1, 1 } },
		hazard = { chance = 0.06, result = { sanity = { -6, -2 }, log = "Someone came in too late for anything you had on the shelf. You sat with them anyway." } },
	},

	nest_clerk = {
		sort = 45,
		name = "Nest Records Office",
		uniform = "nest_suit",
		desc = "Residence papers, checkpoint passes, permits and tax files for the Nest's own government. A stamp from your desk decides who gets through the wall, and everyone outside it wants a favor.",
		ranks = { "Junior Clerk", "Clerk", "Senior Clerk", "Registrar", "Chief Registrar" },
		salary = { 50, 90, 160, 290, 520 },
		minAge = 17,
		requires = { notDistrict = "d12", min = { mind = 26 } },
		guttersRequire = { min = { mind = 34 } },
		promoteStat = "mind",
		promoteAt = { 36, 48, 60, 74 },
		yearsPerRank = 3,
		rankFlags = { [1] = "bs_job_nest_clerk", [2] = "bs_nest_clerk_r2", [4] = "bs_nest_clerk_r4", [5] = "bs_ordinary_top" },
		hazard = { chance = 0.05, result = { sanity = { -5, -2 }, log = "You stamped a residence application \"refused\". The family waited outside the checkpoint until the guards moved them on." } },
	},

	landlord = {
		sort = 46,
		name = "Landlord",
		desc = "Rooms to rent in the Backstreets: thin walls, three locks to a door, and the Night outside. Tenants pay late, the Syndicate wants its cut, and the Sweepers will take any floor you built without a permit.",
		ranks = { "Building Super", "Room Landlord", "Building Owner", "Block Owner", "Street Owner" },
		salary = { 30, 60, 120, 240, 450 },
		minAge = 18,
		sides = { "backstreets" },
		requires = { min = { mind = 22 } },
		promoteStat = "mind",
		promoteAt = { 32, 44, 56, 70 },
		yearsPerRank = 3,
		rankFlags = { [1] = "bs_job_landlord", [2] = "bs_landlord_r2", [4] = "bs_landlord_r4", [5] = "bs_ordinary_top" },
		hazard = { chance = 0.07, result = { money = { -60, -20 }, sanity = -2, log = "A tenant left in the middle of the night, owing three months, and took the door handles with them." } },
	},
}
