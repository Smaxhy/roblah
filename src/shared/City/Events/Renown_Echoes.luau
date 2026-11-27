--[[
	ECHOES (v0.12): what other people on the server hear when someone does something big:
	a deed with a name on it (Activities/Deeds.luau), or standing against a Bloodfiend Family
	(Events/Bloodfiend_Hunt.luau). {actor} is who did it, {actorDistrict} where.
]]

return {
	{
		id = "rn_echo_legend_hunted",
		title = "The Bounty Board",
		text = "Hana's board in {actorDistrict} has a red line through an Urban Legend that's been up there for years. Underneath, in a clerk's neat hand: \"Closed. {actor}.\"",
		weight = 7,
		cooldown = 6,
		tags = { "fixers" },
		when = { chronicle = "deed_legend_hunted", minAge = 12 },
		choices = {
			{ label = "Read the whole report", result = { intelligence = 1, log = "You read it standing at the board. Every Fixer in the queue behind you was reading over your shoulder." } },
			{ label = "Look for the next one on the board", requires = { minAge = 18 }, result = { mind = 1, sanity = -1, log = "There's always a next one. This one has a picture, and you wish it didn't." } },
		},
	},
	{
		id = "rn_echo_capo_beaten",
		title = "A Street Changes Hands",
		text = "The fee box on a corner in {actorDistrict} is gone, and the Thumb's Soldati walk a different way home. People are saying {actor} took the street from a Capo, politely, and the Capo bowed.",
		weight = 7,
		cooldown = 6,
		tags = { "fingers" },
		when = { chronicle = "deed_capo_beaten", minAge = 12 },
		choices = {
			{ label = "Keep your head down: the Thumb will want it back", result = { sanity = 1, rep = { thumb = 2 }, log = "You didn't say the name out loud. The Thumb has long ears." } },
			{ label = "Walk that street, just to see", result = { charisma = 1, sanity = 2, log = "The street felt different. Lighter. A shopkeeper waved at you for no reason." } },
		},
	},
	{
		id = "rn_echo_finger_driven",
		title = "A Branch Closes",
		text = "A Finger's branch in {actorDistrict} has gone quiet: the windows are boarded, the cars are gone, and nobody will say where. The word on every corner is the same name: {actor}.",
		weight = 6,
		cooldown = 8,
		tags = { "fingers" },
		when = { chronicle = "deed_finger_driven", minAge = 12 },
		choices = {
			{ label = "Count it as good news", result = { sanity = 3, log = "Good news is rare enough in the City that you kept this one for a week." } },
			{ label = "Wonder who fills the gap", result = { intelligence = 1, mind = 1, log = "Something always fills the gap. You started watching who moved into the boarded building." } },
		},
	},
	{
		id = "rn_echo_became_color",
		title = "A New Color",
		text = "Hana has posted a notice on every board in the City: a new Color, {actor}, of {actorDistrict}. Fixers stand in front of the notice for a long time without saying anything.",
		weight = 6,
		cooldown = 10,
		tags = { "fixers" },
		when = { chronicle = "deed_became_color", minAge = 10 },
		choices = {
			{ label = "Imagine being that strong", result = { strength = 1, sanity = 1, log = "You trained an extra hour that night. You weren't sure what for." } },
			{ label = "Hope you never meet them on a bad day", result = { mind = 1, log = "A Color is worth an army. Armies have bad days too." } },
		},
	},
	{
		id = "rn_echo_hand_beaten",
		title = "Someone Stood",
		text = "There's a story going round {actorDistrict}: a Bloodfiend Family sent the one who speaks for its Elder after {actor}, and {actor} is still walking around. The Hemobars are very quiet this month.",
		weight = 6,
		cooldown = 8,
		tags = { "bloodfiend" },
		when = { chronicle = "bf_hand_beaten", minAge = 12 },
		choices = {
			{ label = "Be home before dark for a while", result = { sanity = 1, log = "It wasn't about you. You were home before dark anyway." } },
			{ label = "Ask what they did to anger a Family", requires = { minAge = 16 }, result = { intelligence = 1, sanity = -1, log = "Nobody would say. Everyone knew. That's how the City tells you something." } },
		},
	},
	{
		id = "rn_echo_elder_withdrew",
		title = "The Elder Who Left",
		text = "Old people in {actorDistrict} are telling a story about {actor}: a Bloodfiend Elder came in person, and then simply went away again. The old people tell it in whispers, like a prayer that worked.",
		weight = 5,
		cooldown = 10,
		tags = { "bloodfiend", "strange" },
		when = { chronicle = "bf_elder_withdrew", minAge = 10 },
		choices = {
			{ label = "Listen to the whole story", result = { sanity = 2, mind = 1, log = "It had no moral. The old woman telling it said that was the point." } },
		},
	},
}
