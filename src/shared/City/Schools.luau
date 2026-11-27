--[[
	SCHOOLS: who teaches which way of fighting.
	In the City a discipline belongs to the organisation that trains it. You learn it by
	joining (career.teaches / career.teachesRoll), a veteran can show you the basics (an event
	with result.school), and past mastery 2 (pack.outsideMastery) it is only taught inside.
	A manual written for a school (book.schools) only makes sense to someone trained in it.

	The status each school fights with follows the games: Liu burns; Seven and Devyat'
	rupture; Shi, Cinq and the Blade Lineage fight on Poise; Dieci sinks; Zwei, Öufi and
	T Corp shake (Tremor); W Corp charges; the Kurokumo, the Ring, N Corp's nails and
	Bloodfiends bleed; the Thumb's rounds burn. A small Office fights however its Rep does.

	school = { name, style, org (who owns it), careers = { careers that keep training it },
	           free = true (handed from person to person: no organisation left to lock it), desc }
]]

return {
	order = {
		"zwei", "liu", "seven", "devyat", "shi", "cinq", "dieci", "oufi",
		"office_tremor", "office_rupture", "office_bleed", "office_burn", "office_sinking", "office_poise", "office_charge",
		"thumb", "index", "middle", "ring", "kurokumo", "blade_lineage",
		"wcorp", "rcorp_rabbit", "rcorp_reindeer", "rcorp_rhino", "kcorp", "tcorp", "lccb", "hardblood",
	},

	-- the Associations
	zwei = { name = "Zwei shield work", style = "tremor", org = "the Zwei Association", careers = { "zwei" }, desc = "The client's shield. Plant your feet, take the hit, and give it back as a shock." },
	liu = { name = "Liu combat arts", style = "burn", org = "the Liu Association", careers = { "liu" }, desc = "Made for whole battlefields: gauntlets and blades with fire built in, and partners who cover your back." },
	seven = { name = "Seven fencing", style = "rupture", org = "the Seven Association", careers = { "seven" }, desc = "An investigator's swordwork. Find where they're weak, mark it, and keep coming back to it." },
	devyat = { name = "Devyat' courier arts", style = "rupture", org = "the Devyat' Association", careers = { "devyat" }, desc = "The parcel arrives on time. The Courier Trunk opens a way through whatever stands in front of it." },
	shi = { name = "Shi blade arts", style = "poise", org = "the Shi Association", careers = { "shi" }, desc = "Quiet work. One breath, one cut, taken at the moment it can't miss." },
	cinq = { name = "Cinq duelling form", style = "poise", org = "the Cinq Association", careers = { "cinq" }, desc = "Duels by the book: the declaration, the stance, and one clean exchange in front of witnesses." },
	dieci = { name = "Dieci key arts", style = "sinking", org = "the Dieci Association", careers = { "dieci" }, desc = "Fists and keys. Dieci spends what it knows, and what it spends lands on the other side's mind." },
	oufi = { name = "Öufi enforcement", style = "tremor", org = "the Öufi Association", careers = { "oufi" }, desc = "A contract is read out, agreed, and kept. Öufi teaches what happens, clause by clause, when it isn't." },

	-- a small Office: its Rep decides how the Office fights (rolled when you sign on)
	office_tremor = { name = "Office hammerwork", style = "tremor", org = "a Fixer Office", careers = { "fixer" }, desc = "Your Office's Rep fights with a Workshop hammer, so now you do too. Hit until they can't stand straight." },
	office_rupture = { name = "Office gunnery", style = "rupture", org = "a Fixer Office", careers = { "fixer" }, desc = "Your Office buys Workshop rounds by the box. Put one where it matters and the rest go in easier." },
	office_bleed = { name = "Office knife work", style = "bleed", org = "a Fixer Office", careers = { "fixer" }, desc = "Your Office's Rep came up with a knife. Small cuts, and patience while they add up." },
	office_burn = { name = "Office fire gear", style = "burn", org = "a Fixer Office", careers = { "fixer" }, desc = "The Office saved for years for heated Workshop gear. You're trusted with it now. Don't drop it." },
	office_sinking = { name = "Office pressure work", style = "sinking", org = "a Fixer Office", careers = { "fixer" }, desc = "Your Rep wins fights before they start: a look, a word, a weight on the other person's nerve." },
	office_poise = { name = "Office swordsmanship", style = "poise", org = "a Fixer Office", careers = { "fixer" }, desc = "Your Office's Rep fights with a sword and a lot of waiting. Breathe, hold, and take the opening." },
	office_charge = { name = "Office charge gear", style = "charge", org = "a Fixer Office", careers = { "fixer" }, desc = "The Office runs on second-hand charged gear. Build it up, round by round, and let it go at once." },

	-- the Fingers and their Syndicates
	thumb = { name = "Thumb gunnery", style = "burn", org = "the Thumb", careers = { "thumb" }, desc = "Manners first, then ammunition. Every round is costly, counted, and fired exactly as ordered." },
	index = { name = "Index blade work", style = "charge", org = "the Index", careers = { "index" }, desc = "Strength kept under lock until the Prescript calls for it. Then all of it, at once." },
	middle = { name = "Middle chain-fighting", style = "tremor", org = "the Middle", careers = { "middle" }, desc = "Every slight gets written down, and every one of them goes into the swing." },
	ring = { name = "Ring brushwork", style = "bleed", org = "the Ring", careers = { "ring" }, desc = "A Student learns that a fight is a canvas, and that the other person brought the paint." },
	kurokumo = { name = "Kurokumo blade", style = "bleed", org = "the Kurokumo Clan", careers = { "kurokumo" }, desc = "The Dark Cloud's sword: drawn fast, sheathed slow, shown to people who owe." },
	blade_lineage = { name = "Blade Lineage swordplay", style = "poise", org = "the Blade Lineage", free = true, desc = "What's left of an old school of swordsmen, handed from one person to the next. One cut, practiced until it's the only one you need." },

	-- the Wings
	wcorp = { name = "W Corp cleanup drills", style = "charge", org = "W Corp", careers = { "wcorp_cleanup" }, desc = "Charge the gear, clear the carriage, don't ask what was in it. Cleanup Agents fight on stored power." },
	rcorp_rabbit = { name = "Rabbit Team drills", style = "bleed", org = "R Corp's 4th Pack", careers = { "rcorp" }, desc = "You were assigned to the Rabbits: first in, fastest out. Quick suppression, at close range." },
	rcorp_reindeer = { name = "Reindeer Team drills", style = "sinking", org = "R Corp's 4th Pack", careers = { "rcorp" }, desc = "You were assigned to the Reindeer: long staves, and a way of reaching into someone's head with them." },
	rcorp_rhino = { name = "Rhino Team drills", style = "charge", org = "R Corp's 4th Pack", careers = { "rcorp" }, desc = "You were assigned to the Rhinos: powered armor, built to walk through a wall and keep going." },
	kcorp = { name = "K Corp excision", style = "rupture", org = "K Corp", careers = { "kcorp" }, desc = "Staff are issued a baton and ampules, and taught to open up whatever the ampules are meant for." },
	tcorp = { name = "T Corp collection", style = "tremor", org = "T Corp", careers = { "wg_tcorp" }, desc = "Collection Staff carry tools that shake loose what's owed. Time, usually." },
	lccb = { name = "LCCB clearance drills", style = "rupture", org = "Limbus Company", careers = { "limbus_lccb" }, desc = "Go in before the bus does. Find what's weak in whatever is down there, and use it." },

	-- Bloodfiends
	hardblood = { name = "Hardblood arts", style = "bleed", org = "a Bloodfiend Family", careers = { "bf_family" }, desc = "Blood given an edge. A Family teaches its own, and nobody else could use it anyway." },
}
