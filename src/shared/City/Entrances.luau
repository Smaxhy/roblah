--[[
	WAYS IN (v0.13): how each place is found in the world. City/init.luau turns every entry into a
	one-time card (id "ex_in_<expedition>") that finds the place: go in now (no action, the descent
	plays out as cards), remember the way (it joins Places you know on the DO tab), or leave it.
	Places a story, a job or a world event already opens need no entry here.
	{ title, text, when? (added to the expedition's own), weight?, go?, later?, leave?, goLog?, tags?, art? }
]]

return {
	-- ── v0.13 delves ──
	dv_branch_laundromat = {
		title = "The Hatch Behind the Dryers",
		text = "The twenty-four-hour laundromat on the corner has a hatch behind its last row of dryers, and tonight it's open an inch. Cold air comes out of it, and a smell like a hospital, and on the hatch an old L Corp plate: BRANCH SERVICES.",
		go = "Go down now",
		tags = { "strange", "lcorp" },
	},
	dv_open_day = {
		title = "L Corp Is Hiring",
		text = "Posters on every wall in the District: Lobotomy Corporation is holding a recruitment day. Good pay, a room in the Nest, and a tour of the facility for every applicant. The posters don't say what the work is. They never do.",
		go = "Go to the recruitment day",
		later = "Keep the poster, and decide later",
		leave = "Tear the poster down",
		tags = { "lcorp" },
	},
	dv_thirteenth_floor = {
		title = "Thirteen",
		text = "The lift in the tenement across the street has a thirteenth button now, drawn on the wall in pencil. The building has twelve floors. A tenant from the eighth went up to look last month, and her mail is piling up at the door.",
		go = "Take the lift up",
		tags = { "strange" },
		when = { minAge = 14 },
	},
	dv_escort_feather = {
		title = "Lost Under a Dead Streetlight",
		text = "Two in the morning, and a man in a Nest coat is standing under a dead streetlight with a map upside down, waving a handful of Ahn at anyone who'll look. The Night begins at 3:13. He doesn't seem to know that.",
		go = "Walk him to the wall",
		later = "Tell him to find you tomorrow",
		leave = "Keep walking",
		tags = { "danger", "night" },
		weight = 6,
	},
	dv_lake_wreck = {
		title = "The Tender That Went Down",
		text = "Everyone at the fish market is saying it: a Portship tender went down in the fog last night, loaded. Old Haedo, who has a diving bell and no sense, is looking for someone to crank it.",
		go = "Go out with Haedo now",
		tags = { "lake" },
	},
	dv_hongyuan_audit = {
		title = "A Steward's Card",
		text = "A steward's card under your family's door, edged in gold: the room is to be reviewed. In Hongyuan, a room follows its family's fortune. Your mother has gone very quiet, and your father is counting ledgers.",
		go = "Go to the appointment yourself",
		later = "Ask for another date",
		leave = "Let the family handle it",
		tags = { "home" },
	},
	dv_ring_gallery = {
		title = "An Invitation in Gilt",
		text = "A gilt envelope on your doormat, your name on it in a beautiful hand. An exhibition, tonight, and a single line: 'We would so love to see you.' It's from the Ring. Everyone knows you don't turn down the Ring.",
		go = "Go tonight",
		later = "Put it on the mantel and pretend you haven't seen it",
		leave = "Burn it",
		leaveLog = "You burned it. The ashes were gold, and smelled of turpentine.",
		tags = { "fingers", "danger" },
		when = { minAge = 18 },
	},
	dv_prescript = {
		title = "A Sealed Envelope",
		text = "An envelope in your mailbox: heavy paper, no stamp, no sender, sealed with plain wax. Inside, a single page of instructions, written very precisely. You've heard about these. Everyone has.",
		go = "Read it, and do it",
		later = "Put it in a drawer, for now",
		leave = "Throw it away",
		leaveLog = "You threw it away. The next morning it was back in your mailbox.",
		tags = { "fingers", "strange" },
	},

	-- ── places from before, found in the world now ──
	bs_exp_home_before_three = {
		title = "Too Far From Home",
		text = "You've stayed out too late on the wrong side of the District. It's 2:40. Home is a long way off, the streets are emptying, and every shutter on the block is coming down.",
		go = "Make a run for home",
		later = "Remember the shortcuts for another night",
		tags = { "night" },
	},
	bs_exp_rat_tunnels = {
		title = "The Tunnel Under the Market",
		text = "A drain grate under the market has been prised up, and chalk marks lead down into the dark: the Rats' sign, and an arrow. Everyone knows the Rats keep their takings somewhere under the District.",
		go = "Go down after the chalk",
		tags = { "crime" },
	},
	fn_exp_ammo_run = {
		title = "A Crate That Needs Carrying",
		text = "A Thumb Soldato is standing at the corner beside a covered crate, looking at his watch. He needs it across the District before dark, discreetly, and he's paying well for discretion.",
		go = "Carry it now",
		tags = { "fingers" },
	},
	lc_exp_sealed_branch = {
		title = "The Stairwell Under the Car Park",
		text = "A car park has caved in overnight, and at the bottom of the hole there's a stairwell nobody knew about, going down to a heavy door with the old L Corp logo still on it. Scavengers are already gathering at the edge, arguing about who goes first.",
		go = "Go first",
		tags = { "lcorp", "strange" },
	},
	bl_exp_verdict = {
		title = "A Contract on the Board",
		text = "A Hana notice on the Office board, in red: an open contract on the Ivory Verdict, a threat graded Urban Legend. Anyone licensed or not may take it. Three crews have tried already.",
		go = "Take the contract",
		tags = { "fixers" },
	},
	bl_exp_lamplighter = {
		title = "The Lamps Going Out",
		text = "On your street the lamps are going out one at a time, from the far end, a little closer every night. People who walk under the dark ones aren't seen again. Someone has to go to the far end and see what's lighting them down.",
		go = "Go to the far end tonight",
		tags = { "strange", "night" },
	},
	bl_exp_reception = {
		title = "An Invitation for More Than One",
		text = "An invitation from the Library, but this one is addressed to you and anyone you choose. A crew may go together. It says a book is waiting, worth more than you can imagine.",
		go = "Go to the Library",
		tags = { "library" },
	},
	bl_exp_rustback = {
		title = "Past the Fence",
		text = "A caravan master at the edge of the District is hiring guards for a run past the last fence: a herd of rustbacks is grazing out there, and their shells sell well. So do the guards' wages.",
		go = "Sign on for the run",
		tags = { "outskirts" },
	},
	bl_exp_tea_house = {
		title = "The Tea House Door",
		text = "A Kurokumo Wakashu bows to you at the tea house door, which nobody does to strangers. You're expected, he says. You weren't aware.",
		go = "Go inside",
		tags = { "fingers" },
	},
	bl_exp_doorkeeper = {
		title = "One Door Too Many",
		text = "The stairwell in your building has one more door on your landing than it had yesterday. It's painted the same colour as the others. It's unlocked.",
		go = "Open it",
		tags = { "strange" },
	},
	bl_exp_stormgut = {
		title = "Stormgut Season",
		text = "The harbour bell is ringing the old warning: stormgut season. The big ones are running in the deep water, and every boat that can crew up is going out, because one good catch pays for a year.",
		go = "Crew up on a boat",
		tags = { "lake" },
	},
	bl_exp_inquisition = {
		title = "The Hammers Are Out Tonight",
		text = "N Corp's Nail and Hammer are going door to door tonight, looking for what they call impurity. Your neighbour has a prosthetic hand, and she's knocking on your door, very quietly.",
		go = "Help her through the night",
		tags = { "danger" },
	},
}
