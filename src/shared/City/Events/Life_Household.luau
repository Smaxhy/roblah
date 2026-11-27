--[[
	THE FAMILY BUSINESS (origins with household.business; the flag family_business_<id> is set
	at birth). At eighteen to twenty-two the business is offered to you: take it over, sell it,
	or leave it to the people who run it. Taking over an Office is the first step of running
	one (see Events/Adult_Office.luau); the others start you high on their career ladder.
]]

return {
	{
		id = "hh_office_keys",
		title = "The Keys to the {office} Office",
		art = "office",
		text = "Your mother has put the {office} Office's keys on the kitchen table: the street door, the desk, and the little one for the cabinet with the contracts in it. \"I've had twenty years of it,\" she says. \"Somebody should have the next twenty.\"",
		weight = 40,
		once = true,
		when = { minAge = 18, maxAge = 24, flags = { "family_business_office" }, hasRelation = "mother", notFlags = { "owns_office" } },
		codex = "fx_lore_offices",
		choices = {
			{
				label = "Take the keys",
				hint = "You run the {office} Office now: its contracts, its rent, its name.",
				result = { money = 150, rep = { fixers = 10 }, setFlags = { "owns_office", "office_inherited" }, relationBond = { kind = "mother", amount = 8 }, log = "You took the keys. Your mother showed you the books, the good contracts and the ones to refuse, and then she went home and slept for two days." },
			},
			{
				label = "Sell the lease",
				result = { money = { 500, 800 }, relationBond = { kind = "mother", amount = -10 }, log = "A bigger Office bought the lease and painted over the sign within the week. Your mother didn't say anything. She didn't have to." },
			},
			{
				label = "Leave it with her",
				result = { sanity = 3, relationBond = { kind = "mother", amount = 6 }, log = "You put the keys back in her hand. \"Twenty more, then,\" she said, and laughed, and you heard her humming on the stairs." },
			},
		},
	},
	{
		id = "hh_workshop_keys",
		title = "The Forge",
		art = "workshop",
		text = "Your mother hands you her hammer, handle first, the way a smith hands over a blade. The {office} Workshop's mark is cut into its cheek. \"My hands are tired,\" she says. \"Yours aren't.\"",
		weight = 40,
		once = true,
		when = { minAge = 18, maxAge = 24, flags = { "family_business_workshop" }, hasRelation = "mother" },
		choices = {
			{
				label = "Take over the forge",
				hint = "You start as a Smith of the Workshop trade.",
				result = { career = "workshop", careerRank = 3, setFlags = { "owns_workshop" }, relationBond = { kind = "mother", amount = 8 }, log = "You took the hammer. The first blade you signed with the {office} mark went to a Grade 7 who came back a month later to say it had saved his life." },
			},
			{
				label = "Sell the mark to a bigger Workshop",
				result = { money = { 900, 1400 }, relationBond = { kind = "mother", amount = -10 }, log = "A Workshop with three floors bought the {office} mark. Their blades carry it now. Your mother says they're good blades, and won't look at them." },
			},
			{
				label = "Keep your own road",
				result = { sanity = 2, relationBond = { kind = "mother", amount = 4 }, log = "You gave her the hammer back. She hung it on its nail and said the forge would keep." },
			},
		},
	},
	{
		id = "hh_diner_keys",
		title = "Six Stools and a Pot",
		art = "diner",
		text = "Your father pours you a bowl at closing, puts the ladle in your hand, and doesn't take it back. \"The broth,\" he says, \"is the whole recipe. I'll tell you the rest when you've ruined it twice.\"",
		weight = 40,
		once = true,
		when = { minAge = 18, maxAge = 24, flags = { "family_business_diner" }, hasRelation = "father" },
		choices = {
			{
				label = "Take over {office} Noodles",
				hint = "You start as the shop's Owner.",
				result = { career = "diner", careerRank = 4, setFlags = { "owns_diner" }, relationBond = { kind = "father", amount = 8 }, log = "You took the ladle. You ruined the broth twice, as promised, and on the third night a Grade 9 Fixer asked for seconds." },
			},
			{
				label = "Sell the shop",
				result = { money = { 400, 700 }, relationBond = { kind = "father", amount = -10 }, log = "The shop sells dumplings now. Your father eats there sometimes, and says nothing about the broth." },
			},
			{
				label = "Leave him the ladle",
				result = { sanity = 2, health = 1, relationBond = { kind = "father", amount = 5 }, log = "You gave the ladle back, and he poured you another bowl, and you ate it at the counter like a regular." },
			},
		},
	},
	{
		id = "hh_landlord_keys",
		title = "The Rent Book",
		art = "home",
		text = "Your mother puts the rent book in your lap: twenty flats, five floors, and forty years of who paid late. \"Every name in there is a family,\" she says. \"Some of them are terrible families. They're still ours.\"",
		weight = 40,
		once = true,
		when = { minAge = 18, maxAge = 26, flags = { "family_business_landlord" }, hasRelation = "mother" },
		choices = {
			{
				label = "Take over the building",
				hint = "You start as its Building Owner.",
				result = { career = "landlord", careerRank = 3, setFlags = { "owns_building" }, relationBond = { kind = "mother", amount = 8 }, log = "You took the book. On your first rent day, three tenants paid on time out of sheer surprise." },
			},
			{
				label = "Sell the building",
				result = { money = { 1800, 2600 }, relationBond = { kind = "mother", amount = -12 }, log = "A man in a good coat bought it with cash and raised every rent by a third. You moved out before the tenants found out who'd sold it." },
			},
			{
				label = "Leave it in her hands",
				result = { sanity = 2, relationBond = { kind = "mother", amount = 5 }, log = "You put the rent book back on her shelf. She was relieved. She likes the arguments." },
			},
		},
	},
}
