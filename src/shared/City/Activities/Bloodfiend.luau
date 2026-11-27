--[[
	Bloodfiend activities: Hemobars (the artificial blood substitute La Manchaland put its
	Kindred on) keep the Thirst quiet; Hardblood practice trains your fighting style; the
	Family cellar feeds its own; and a human who knows where the Family drinks can knock.
	Nobody here ever feeds on a person.
]]

return {
	{
		id = "bf_hemobar",
		name = "Drink a Hemobar",
		desc = "An artificial blood substitute in red foil. It quiets the Thirst for a while.",
		category = "self",
		cost = 30,
		when = { form = "bloodfiend" },
		result = { sanity = { 7, 11 }, health = { 1, 3 }, log = "You drank a Hemobar in a doorway out of the wind. Copper and cherry syrup. The Thirst lay down like a tired dog." },
	},
	{
		id = "bf_hardblood_practice",
		name = "Practice Hardblood",
		desc = "Harden your blood into an edge, again and again, until it comes without thinking. Trains your fighting style.",
		category = "self",
		when = { form = "bloodfiend" },
		result = { mastery = 1, strength = { 1, 2 }, sanity = -1, log = "You practiced Hardblood in a locked basement until the edge came on its own. Your {style} is sharper for it." },
	},
	{
		id = "bf_cellar",
		name = "Visit the Family cellar",
		desc = "The Family keeps Hemobars and quiet company for its own. Free, for Kindred in good standing.",
		category = "people",
		when = { form = "bloodfiend", flags = { "bf_family_member" } },
		result = { sanity = { 9, 13 }, log = "The cellar was warm, and the Elder's Hand poured for you herself. Nobody asked how you were. Everybody knew." },
	},
	{
		id = "bf_seek_family",
		name = "Look for the Family again",
		desc = "You know where the red-eyed people buy their Hemobars. You could knock.",
		category = "people",
		minAge = 18,
		cooldown = 3,
		when = { form = "human", flags = { "bf_knows" }, notFlags = { "bf_refused" } },
		result = { log = "You knocked on a shuttered door after dark. Someone with red eyes opened it, and remembered your name.", trigger = "bf_gift_offer" },
	},
}
