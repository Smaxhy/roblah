--[[
	CASES (v0.13): investigations that take years (Engine/Cases.luau). An event opens one
	(result.caseOpen); "Work the case" on the DO tab (made per case in City/init.luau) finds a
	clue on a win; the last clue brings the case's finale (Events/Cases.luau), whose choices
	close it in different ways. Each needs a different stat to work.
	Canon: Fixers take investigation jobs as much as fights; Hana grades and licenses them; the
	Index, Ring and the Corporations are as described in LoR and Limbus. The cases themselves,
	and everyone in them, are this game's own.
]]

return {
	order = { "case_missing_courier", "case_counterfeit_prescripts", "case_painted_doors", "case_hollow_branch", "case_quiet_auction" },

	case_missing_courier = {
		name = "The Courier Who Didn't Arrive",
		desc = "A Devyat' courier went missing between two Districts with a sealed trunk. The Association wants the trunk back. Their family wants them back.",
		clues = 4,
		stat = "intelligence",
		coins = 2,
		base = 4,
		coinPower = 3,
		foe = "A trail three weeks cold",
		steps = {
			"The courier's last stamp was at a WARP platform in District 23. They never boarded.",
			"A noodle cook remembers a courier who paid in exact change and asked for the back door.",
			"The trunk's seal turned up at a pawn arcade. Someone pried it off carefully, the way you'd do it if you meant to put it back.",
			"The courier is alive, hiding in a laundry court, and the trunk is under their bed. They opened it. They won't say what was inside.",
		},
		finale = "case_courier_finale",
	},
	case_counterfeit_prescripts = {
		name = "Prescripts in the Wrong Hand",
		desc = "Someone is leaving forged Index Prescripts on doorsteps. People are obeying them. Someone has to find the forger before the real Index does.",
		clues = 4,
		stat = "intelligence",
		coins = 3,
		base = 5,
		coinPower = 3,
		foe = "A forger who doesn't want to be found",
		steps = {
			"The forged cards are a stock no stationer in your District sells. Three Districts over, one does.",
			"Every forged order told someone to be somewhere at a time. Plot them, and the places draw a shape.",
			"The shape is a route a delivery van takes on Thursdays.",
			"The van belongs to a print shop, and the print shop belongs to a former Proxy who was cast out and kept the habit.",
		},
		finale = "case_prescripts_finale",
	},
	case_painted_doors = {
		name = "The Painted Doors",
		desc = "Doors along your District are being painted overnight: one color each, very well. Then the people behind them stop coming outside.",
		clues = 3,
		stat = "mind",
		coins = 2,
		base = 5,
		coinPower = 3,
		foe = "Something that wants to be looked at",
		steps = {
			"The paint is the kind the Ring's Docents favour. Whoever is doing this studied under one, or wants you to think so.",
			"The people behind the doors are fine. They're just painting too, inside, and they won't stop to eat.",
			"The painter signs each door in the bottom corner, very small. It's the same name every time, and it's a name from an old exhibition catalogue.",
		},
		finale = "case_doors_finale",
	},
	case_hollow_branch = {
		name = "The Hollow Branch",
		desc = "A building's tenants keep hearing machinery under the floor. The landlord says there's nothing down there. The building's oldest plans say there was once something very large.",
		clues = 4,
		stat = "intelligence",
		coins = 3,
		base = 5,
		coinPower = 4,
		foe = "A facility that was built not to be found",
		steps = {
			"The building's foundation plans have a second set of numbers in the margin: depths, in a format only one company ever used.",
			"A retired clerk from the old L Corp remembers the branch codes. This one was never on the public list.",
			"The machinery runs on a timer: every day at the same hour, something below opens and closes.",
			"There is a service lift behind the boiler, painted over twelve times. It still works.",
		},
		finale = "case_branch_finale",
	},
	case_quiet_auction = {
		name = "The Quiet Auction",
		desc = "Once a year, in a District nobody names, things that shouldn't exist are sold to people who shouldn't own them. This year, someone you know is on the list of lots.",
		clues = 4,
		stat = "charisma",
		coins = 3,
		base = 6,
		coinPower = 4,
		foe = "Rich people who never answer questions",
		steps = {
			"The auction's invitations are hand-delivered by someone who never says a word. You learn which courier Office hires them.",
			"A catalogue changes hands at a Nest tea house. Lot nine is a person's contract, and you know the name on it.",
			"The auction moves every year. This year's hall belongs to a family that owes the Middle a great deal.",
			"You get a seat at the auction. All it cost you was a name you'd rather not have given.",
		},
		finale = "case_auction_finale",
	},
}
