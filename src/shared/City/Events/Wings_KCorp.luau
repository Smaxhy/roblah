--[[
	K Corp (District 11): the HP Ampule, Classes that count upward, memory wipes, and the
	secret on the top floor (wg_lore_kcorp_tears, CANON 2: a sorrowful creature kept
	watching sad reels; keep the moral mystery, never the details).
	Career kcorp ranks: 1 Class 1 Rescue Staff, 2 Class 2 Clerical, 3 Class 3 Excision Staff,
	4 Class 4 Researcher, 5 Class 5 Senior Researcher, 6 Lab Director.
]]

return {
	{
		id = "wg_k_rescue",
		title = "Rescue Duty",
		text = "Class 1 Rescue Staff go where the ambulances won't. Tonight it's a stairwell collapse in the District 11 Backstreets: five people hurt, and you have three ampules in your kit. One dose and a body puts itself back the way it remembers being. The rule book says who gets one. The man with the broken leg is begging.",
		weight = 24,
		cooldown = 4,
		tags = { "wing", "kcorp" },
		when = { career = "kcorp" },
		codex = "wg_lore_kcorp",
		choices = {
			{
				label = "Triage by the book",
				hint = "An Intelligence check: fast, cold, right.",
				clash = { stat = "intelligence", foe = "Five people and three ampules", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 2, paycheck = 0.1, sanity = -1, log = "You chose by the book, and you chose right: three doses, three people who would have died without them, two who would mend on their own. The man with the broken leg cursed you. He walked again in a month." },
				lose = { sanity = -4, log = "You hesitated over the book, and lost a minute, and the minute mattered. You'll replay it for a long time." },
			},
			{
				label = "Use your own spare ampule too",
				hint = "Company property. They'll dock your pay.",
				result = { money = -40, sanity = 3, setFlags = { "wg_k_kind" }, log = "You used the spare from your own locker. Four people walked out of that stairwell. K Corp docked forty Ahn from your pay and a supervisor wrote \"generous\" in your file, which in K Corp is not a compliment." },
			},
			{
				label = "Call for a second team and wait",
				result = { mind = 1, sanity = -3, log = "The second team came in twenty minutes. Twenty minutes is a long time on a stairwell. Everyone lived. Not everyone will be the same." },
			},
		},
	},
	{
		id = "wg_k_excision",
		title = "Excision Staff",
		text = "You're Class 3 now: Excision Staff, the ones who remove intruders and guard classified technology. Off duty, Excision Staff wait in glass tubes along a white corridor, and you're in yours when the alarm goes: an intruder on the research floor, carrying a case of stolen ampules toward the freight lift.",
		weight = 22,
		cooldown = 4,
		tags = { "wing", "kcorp" },
		when = { career = "kcorp", minRank = 3 },
		choices = {
			{
				label = "Stop the intruder",
				hint = "A real fight.",
				clash = { stat = "strength", foe = "An ampule thief", coins = 2, base = 5, coinPower = 3, fight = true, status = "bleed" },
				win = { strength = 2, paycheck = 0.15, log = "You caught him at the lift and put him down before the doors closed. The case of ampules went back to the lab. He went somewhere else. You didn't ask where." },
				lose = { health = { -9, -4 }, log = "He was better than he looked. The lift doors closed on him and the case. Two floors down, Excision Staff with longer tubes than yours stopped him.", cause = "Stopping an ampule thief" },
			},
			{
				label = "Talk him down at the lift",
				hint = "A Charisma check.",
				clash = { stat = "charisma", foe = "A desperate man", coins = 2, base = 4, coinPower = 3 },
				win = { charisma = 2, sanity = 1, log = "He was stealing them for his daughter, he said, and you believed him, and you talked him into putting the case down. You wrote in your report that he surrendered. You didn't write about the daughter." },
				lose = { health = -3, sanity = -2, log = "He listened, nodded, and swung the case at your head." },
			},
			{
				label = "Lock down the floor and let the drones handle it",
				result = { sanity = -1, log = "You locked the floor. The drones found him in the ventilation shaft. Your report says the threat was neutralized. You wonder what that means, on the paperwork for him." },
			},
		},
	},
	{
		id = "wg_k_wipe",
		title = "The Memory Wipe",
		text = "There was an incident on your floor last week. Nobody will say what. Now the whole floor is scheduled for a memory-wipe procedure on Friday, in a quiet room with reclining chairs. You will remember everything except the incident, the notice says. You have one evening to decide whether to hide a note for yourself somewhere they won't look.",
		weight = 20,
		cooldown = 6,
		tags = { "wing", "kcorp" },
		when = { career = "kcorp", minRank = 2 },
		choices = {
			{
				label = "Hide a note to yourself",
				result = { sanity = -2, setFlags = { "wg_k_note" }, schedule = { event = "wg_k_note_found", inYears = 1 }, log = "You wrote what you remembered on a slip of paper and sewed it into the lining of your coat. On Friday, you sat in the reclining chair. On Saturday, you couldn't remember why your coat felt lumpy." },
			},
			{
				label = "Accept the procedure",
				result = { sanity = 2, log = "You sat in the chair. Afterward you felt fine, better than fine, and you couldn't think why you'd been worried. Your colleagues all said the same. That was the part that stayed with you." },
			},
			{
				label = "Ask what the incident was",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "K Corp's silence", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, sanity = -3, codex = "wg_lore_kcorp", log = "A tired Class 4 told you, off the record: someone from your floor took the wrong lift and came back from the top floor crying, and couldn't stop. You were wiped on Friday, but you remember being told. You don't remember anything else." },
				lose = { sanity = -2, log = "Your question was noted. You were wiped first, on Thursday. You don't know what you asked." },
			},
		},
	},
	{
		id = "wg_k_note_found",
		title = "A Note in Your Coat",
		text = "Your coat has had a lump in the lining for a year. Tonight you finally unpick it, and find a slip of paper in your own handwriting, which you don't remember writing. It says: \"THE TOP FLOOR. IT CRIES. THAT IS WHERE THE AMPULES COME FROM. DON'T LET THEM WIPE THIS.\"",
		weight = 0,
		when = { flags = { "wg_k_note" } },
		choices = {
			{
				label = "Find a way up to the top floor",
				hint = "A Mental Strength check.",
				clash = { stat = "mind", foe = "K Corp's top floor", coins = 2, base = 6, coinPower = 3 },
				win = { sanity = -6, mind = 2, codex = "wg_lore_kcorp_tears", log = "You took the wrong lift on purpose. At the top, behind glass, something was crying, and in front of it screens were playing sad things, over and over. You took the lift back down before the drones found you. You haven't used an ampule since." },
				lose = { sanity = -3, log = "The lift wouldn't go past the fortieth floor. A drone followed you home. On Monday, there was another wipe scheduled. Yours." },
			},
			{
				label = "Burn the note",
				result = { sanity = 2, log = "You burned it in the sink. Whatever you were, the week you wrote it, you're someone who doesn't want to know now. Maybe that's what the wipe was for." },
			},
		},
	},
	{
		id = "wg_k_top_floor",
		title = "The Top Floor",
		text = "As a Class 5 Senior Researcher, you're finally cleared for the top floor. The Director who takes you up says nothing in the lift. At the top, behind thick glass, is the source of every HP Ampule in the City: a living creature, curled up, crying. Its tears are collected drop by drop. In front of it, screens are playing reels of sad things, over and over.",
		weight = 30,
		once = true,
		tags = { "wing", "kcorp" },
		when = { career = "kcorp", minRank = 5 },
		codex = "wg_lore_kcorp_tears",
		choices = {
			{
				label = "Keep the reels running. The City needs ampules",
				result = { paycheck = 0.3, sanity = -8, setFlags = { "wg_k_knows" }, log = "You signed the form. Ampules saved four hundred thousand lives in the City last year; you've seen the figures. You take the stairs now, so you don't have to pass the top-floor button in the lift." },
			},
			{
				label = "Propose gentler reels",
				hint = "An Intelligence check: you'd have to prove the yield won't fall.",
				clash = { stat = "intelligence", foe = "The yield figures", coins = 2, base = 6, coinPower = 3 },
				win = { intelligence = 2, sanity = 2, setFlags = { "wg_k_knows" }, log = "You proved, with a year of numbers, that sad reels worked as well as the cruel ones had. They switched. It still cries. But you chose what it watches now, and you chose with care." },
				lose = { sanity = -5, setFlags = { "wg_k_knows" }, log = "The yield fell during your trial, and the Director switched the reels back. You were thanked for your contribution." },
			},
			{
				label = "Quit",
				result = { quitCareer = true, sanity = 4, setFlags = { "wg_k_knows" }, log = "You handed in your badge in the lift on the way down. They scheduled a memory wipe for your exit interview. You didn't go. You still dream about the screens." },
			},
		},
	},
	{
		id = "wg_ampule",
		title = "An Ampule",
		text = "A street medic with a K Corp crate under her stall is selling HP Ampules at half the clinic price: one dose and your body puts itself back the way it remembers being. \"Real ones,\" she says. \"Off the back of a truck, but real.\" The little glass vials glow faintly green-white in the lamplight.",
		weight = 12,
		cooldown = 6,
		tags = { "kcorp" },
		when = { minAge = 14, side = "backstreets" },
		codex = "wg_lore_kcorp",
		choices = {
			{
				label = "Buy one and use it now",
				hint = "40 Ahn.",
				requires = { min = { money = 40 } },
				result = { money = -40, health = { 10, 16 }, cure = "any", log = "You cracked it on the spot. Every ache in your body unwound at once, the way it does when you wake from a good sleep, and the old injury you'd stopped noticing was simply gone." },
			},
			{
				label = "Buy one to keep for the worst day of your life",
				hint = "50 Ahn.",
				requires = { min = { money = 50 } },
				result = { money = -50, gear = "ampule", log = "You bought one for a cord around your neck. Everyone in the City says you should keep one for the worst day of your life. Now you can." },
			},
			{
				label = "Ask her where K Corp gets them",
				result = { mind = 1, log = "\"Nobody knows,\" she said. \"And the people who find out have very clean memories afterward.\" She laughed. You didn't." },
			},
		},
	},
}
