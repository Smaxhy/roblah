--[[
	Factions for the guidebook: who's who in the City, how to join, and what joining gives you.
	{ order = { ids }, [id] = { name, kind, desc, join, perks, career, color } }
		kind    "Association", "Office", "Finger", "Syndicate", "Wing", "Company", "Family"
		desc    one or two plain sentences
		join    how a life gets in (plain words)
		perks   what being in it gives you (pay, gear, traits, protection, risks)
		career  the career id, if joining is a career
		color   { r, g, b } for the guidebook card (a District's Wing color where there is one)
	Numbers follow Careers/*.luau; the recruiters who come for you are in
	Events/Factions_Recruit.luau. Canon: docs/CANON.md sections 2 to 8.
]]

return {
	order = {
		-- the Wings
		"fc_wing", "fc_lcorp", "fc_lcorp_research", "fc_kcorp", "fc_wcorp", "fc_rcorp", "fc_tcorp", "fc_hcorp",
		-- Fixers
		"fc_office", "fc_hana", "fc_zwei", "fc_shi", "fc_cinq", "fc_liu", "fc_seven", "fc_devyat", "fc_dieci", "fc_oufi",
		-- the Fingers and other Syndicates
		"fc_thumb", "fc_index", "fc_middle", "fc_ring", "fc_kurokumo",
		-- Limbus Company and the Families
		"fc_lccb", "fc_lce", "fc_lcd", "fc_bloodfiend",
	},

	-- ── the Wings ───────────────────────────────────────────────────────────
	fc_wing = {
		name = "Your District's Wing",
		kind = "Wing",
		career = "wing",
		color = { 196, 206, 226 },
		desc = "The megacorporation that owns your District and runs its Nest. Its staff are called Feathers and hold numbered Classes, with Class 1 at the bottom.",
		join = "Age 16+ and Intelligence 30, or 45 if you apply from the Backstreets. Sit the yearly intake exam, or get headhunted: Wings notice academy graduates, good fighters and senior Fixers. District 12 has no Wing after L Corp falls.",
		perks = "Pay from 70 Ahn a year at Class 1 to 950 as an Executive, promoted on Intelligence. A badge that opens checkpoints, and some offers come with Nest residence. Costs: the Wing owns your hours, and it cuts departments without warning.",
	},
	fc_lcorp = {
		name = "Lobotomy Corporation",
		kind = "Wing",
		career = "lcorp_agent",
		color = { 120, 255, 140 },
		desc = "District 12's Wing powers half the City with Enkephalin, drawn from the Abnormalities in its vaults. Clerks run its departments; Agents work inside the containment units.",
		join = "Age 18+, in District 12, during the age of the Wings only: L Corp falls in 978. Health 25 and Mental Strength 25. Recruiters look for breach survivors and hire hard during hiring drives.",
		perks = "The best pay in the City: 80 Ahn a year as a Clerk, up to 1,400 as Branch Manager, with a promotion every two years on Mental Strength. Costs: Sanity drains every year, and containment breaches kill Agents often.",
	},
	fc_lcorp_research = {
		name = "L Corp Research",
		kind = "Wing",
		career = "lcorp_research",
		color = { 150, 230, 170 },
		desc = "The science side of Lobotomy Corporation: observation logs, Enkephalin yields and the Abnormality encyclopedia.",
		join = "Age 18+, in District 12, during the age of the Wings only. Intelligence 35. Bookish people and academy graduates get letters, and K Corp sometimes bids for the same mind.",
		perks = "Pay from 70 Ahn a year as a Lab Assistant to 950 as Head of Research, promoted on Intelligence every two years. Costs: a little Sanity every year, and things you learn that you can't unlearn.",
	},
	fc_kcorp = {
		name = "K Corp",
		kind = "Wing",
		career = "kcorp",
		color = { 96, 220, 160 },
		desc = "District 11's Wing makes the HP Ampule, which puts a body back the way it remembers being. Checkpoints, drones and very clean streets.",
		join = "Age 18+, in District 11, Intelligence 32. K Corp's drones film people who rescue strangers, and an officer comes to the door with a contract.",
		perks = "Pay from 80 Ahn a year as Class 1 Rescue Staff to 720 as Lab Director, promoted on Intelligence. Recruits often get a spare ampule. Costs: K Corp watches its own, and memory wipes are routine.",
	},
	fc_wcorp = {
		name = "W Corp Cleanup Crew",
		kind = "Wing",
		career = "wcorp_cleanup",
		color = { 90, 200, 255 },
		desc = "District 23's Wing runs the WARP trains, which cross the City in seconds. Its Cleanup Agents tidy the carriages after every run, and never say what they cleaned.",
		join = "Age 18+, in District 23, Health 30. Cleanup Captains recruit people who stay calm on a late train.",
		perks = "Pay from 80 Ahn a year at Level 1 to 620 as a Cleanup Captain, promoted on Health every two years. The best Level 4 agents may wear CCA power armor. Costs: Sanity wears down, and bad trains kill whole crews.",
	},
	fc_rcorp = {
		name = "R Corp Packs",
		kind = "Wing",
		career = "rcorp",
		color = { 236, 120, 60 },
		desc = "District 18's Wing sells armies. Most of a Pack is hatched soldiers grown in the Hatchery, in three teams: Rabbits, Reindeer and Rhinos. Humans sign on as contractors.",
		join = "Age 17+, in District 18, Health 30 and Strength 25. The recruiting office never closes, and sergeants come looking for families with Smoke War records.",
		perks = "Pay from 70 Ahn a year as a Contract Recruit to 620 as Pack Commander, promoted on Strength every two years. Costs: the deadliest contracts in the City. Packs march out by the thousand, and fewer come back.",
	},
	fc_tcorp = {
		name = "T Corp Time Collection",
		kind = "Wing",
		career = "wg_tcorp",
		color = { 200, 200, 200 },
		desc = "District 20's Wing sells and taxes time itself. Its Collectors go door to door for what people owe, in hours and days.",
		join = "Age 18+, in District 20, Mental Strength 32, or 40 from the Backstreets. T Corp's ledgers notice people who are never late.",
		perks = "Pay from 80 Ahn a year as Class 1 Collection Staff to 560 as Class 5 Audit Staff, promoted on Mental Strength, and a timepiece of your own. Costs: a little Sanity every year, and collecting from people very like your neighbors.",
	},
	fc_hcorp = {
		name = "Hongyuan Households",
		kind = "Wing",
		career = "wg_hcorp",
		color = { 214, 64, 64 },
		desc = "District 8 is Hongyuan, H Corp's vast shifting home, ruled by the Four Families under the Family Hierarch. Every great house needs servants, retainers and stewards.",
		join = "Age 16+, in District 8, Intelligence 30. Heralds recruit at crossroads, and rival houses bid against each other for honest, quick people.",
		perks = "Pay from 60 Ahn a year as a Household Servant to 560 as Family Steward, promoted on Intelligence. In Hongyuan your room grows with your fortune. Costs: when two Families quarrel, someone has to take the blame.",
	},

	-- ── Fixers ──────────────────────────────────────────────────────────────
	fc_office = {
		name = "A Fixer Office",
		kind = "Office",
		career = "fixer",
		color = { 214, 96, 88 },
		desc = "Fixers are licensed freelancers for hire: escorts, retrievals, investigations and fights. Every Fixer must belong to an Office or an Association, and a one-person Office counts.",
		join = "Age 16+, Strength 20, and Hana's licensing exam. Offices like Latchkey sponsor promising locals, and during a Hana crackdown you can sit the exam on the spot.",
		perks = "Pay from 40 Ahn a year at Grade 9 to 700 at Grade 1. Hana grades you from your job reports, on Strength every two years, and puts your name on its quarterly board. Costs: jobs go wrong, and a high grade draws challengers.",
	},
	fc_hana = {
		name = "The Hana Association",
		kind = "Association",
		career = "hana",
		color = { 236, 236, 244 },
		desc = "The First Association runs the Fixer system itself: licenses, grades, hazard levels, Office credit and the Colors. Its members are high-grade Fixers.",
		join = "Age 24+, Mental Strength 62, and an invitation. Experienced, licensed Fixers get one, sometimes from the Examiner who failed them years ago.",
		perks = "Pay from 160 Ahn a year as a Hana Examiner to 920 as Section Director, promoted on Mental Strength. Costs: the Fixers you downgrade come to discuss it.",
	},
	fc_zwei = {
		name = "The Zwei Association",
		kind = "Association",
		career = "zwei",
		color = { 80, 120, 200 },
		desc = "The Second Association: protection and public peace. Zwei calls itself the client's shield, and Wings hire it to guard the lines between them.",
		join = "Age 18+, Health 40, and Zwei's own exam, which licenses you. Section Directors recruit people who stand in a doorway and don't move.",
		perks = "Pay from 90 Ahn a year in Section 6, the newest, to 860 as a Section 1 Director, promoted on Health. Recruits may get Zwei's shield drills. Costs: Association Fixers can't choose their jobs, and holding the line hurts.",
	},
	fc_shi = {
		name = "The Shi Association",
		kind = "Association",
		career = "shi",
		color = { 150, 150, 165 },
		desc = "The Fourth Association takes the quietest, most dangerous contracts in the City: takedowns of people with very powerful enemies.",
		join = "Age 18+, Strength 45 and Mental Strength 35. Shi never advertises. Quiet fighters find a note on their pillow, and saying no to it is risky.",
		perks = "The best Association pay, from 100 to 940 Ahn a year, promoted on Strength. Recruits may get paired knives. Costs: a little Sanity every year, and quiet contracts that go loud.",
	},
	fc_cinq = {
		name = "The Cinq Association",
		kind = "Association",
		career = "cinq",
		color = { 90, 220, 140 },
		desc = "The Fifth Association fights duels by contract, standing in for clients whose honor is at stake. The West throws a glove; the East announces its name and fights hand to hand.",
		join = "Age 18+, Strength 42, and win a duel. Cinq throws a glove at good duelists; stepping on it means a rematch.",
		perks = "Pay from 90 to 860 Ahn a year through the Sections, promoted on Strength. Recruits may get a Pyrojade bangle. Costs: contract duels go the full distance.",
	},
	fc_liu = {
		name = "The Liu Association",
		kind = "Association",
		career = "liu",
		color = { 230, 90, 50 },
		desc = "The Sixth Association fights between groups. Every Liu Fixer is trained to take on many at once, with incendiaries built into their weapons.",
		join = "Age 18+, Strength 40, and an exam that is a group brawl. The Liu notice fighters who burn, shake or charge, and anyone who takes on five at once.",
		perks = "Pay from 90 to 860 Ahn a year through the Sections, promoted on Strength. Recruits may get a book of Liu flame forms. Costs: burns, and Shi contracts on the other side of yours.",
	},
	fc_seven = {
		name = "The Seven Association",
		kind = "Association",
		career = "seven",
		color = { 160, 150, 110 },
		desc = "The Seventh Association does intelligence and investigation, by whatever means the contract allows.",
		join = "Age 18+, Mental Strength 40, and an exam that starts with finding their office. Seven recruits sharp observers, sometimes by stealing their notebooks and correcting them.",
		perks = "Pay from 90 to 860 Ahn a year through the Sections, promoted on Mental Strength. Recruits may get Seven's case files. Costs: you find things out, and someone finds out that you know.",
	},
	fc_devyat = {
		name = "The Devyat' Association",
		kind = "Association",
		career = "devyat",
		color = { 176, 124, 72 },
		desc = "The Ninth Association: couriers with dimensional Courier Trunks and a helper program, Poludnitsa, that pushes them harder as a deadline closes in.",
		join = "Age 18+, Intelligence 35 and Health 35, and a deadline that can't be met. Devyat' watches Backstreets couriers who are never late.",
		perks = "Pay from 80 to 830 Ahn a year through the Sections, promoted on Intelligence. Costs: Devyat' is never late, and some deadlines kill.",
	},
	fc_dieci = {
		name = "The Dieci Association",
		kind = "Association",
		career = "dieci",
		color = { 200, 170, 90 },
		desc = "The Tenth Association collects and studies knowledge. Its gear turns what you know into strength, and what you spend is gone. They fight with fists and keys.",
		join = "Age 18+, Intelligence 45. Dieci approaches readers, scholars and Library guests, and its exam costs a memory.",
		perks = "Pay from 90 to 860 Ahn a year through the Sections, promoted on Intelligence. Costs: a hard fight can cost something you used to know.",
	},
	fc_oufi = {
		name = "The Öufi Association",
		kind = "Association",
		career = "oufi",
		color = { 190, 90, 160 },
		desc = "The Eleventh Association handles contracts: it observes signings, notarizes wills and duels, and sees every notarized contract carried out. Gaudy hats, one warning.",
		join = "Age 18+, Mental Strength 45. Öufi recruits people who remember every clause, and reading the fine print can start you a Section higher.",
		perks = "Pay from 90 to 860 Ahn a year through the Sections, promoted on Mental Strength. Costs: you enforce what people signed, even when they'd rather you didn't.",
	},

	-- ── the Fingers and other Syndicates ────────────────────────────────────
	fc_thumb = {
		name = "The Thumb",
		kind = "Finger",
		career = "thumb",
		color = { 220, 170, 60 },
		desc = "The Finger of propriety. Every rank from Soldato Primo to Sottocapo has rules: when you eat, where you stand, how low you bow. Disrespect upward is punished.",
		join = "Backstreets only, age 16+, Strength 22 and Intelligence 15. Capi recruit people with perfect manners, people who pay on time, and people who owe them. A rude refusal brings Soldati to correct you.",
		perks = "Pay from 30 to 900 Ahn a year across nine ranks, promoted on Strength every two years. Recruits may get a Thumb pistol, and Thumb Protection keeps Rats away. Costs: discipline for every slip, and bullets cost money.",
	},
	fc_index = {
		name = "The Index",
		kind = "Finger",
		career = "index",
		color = { 160, 180, 230 },
		desc = "The Finger of faith. Prescripts arrive on slips of paper and are carried out exactly, however strange. Nobody outside the Index knows who writes them.",
		join = "Backstreets only, age 16+, Mental Strength 28. A Messenger hands a slip to people who follow orders well. Ignore it, and a second slip comes, with silent Proselytes.",
		perks = "Pay 50, 220 and 580 Ahn a year from Proselyte to Messenger, promoted on Mental Strength. Carrying out Prescripts brings something like grace. Costs: you do what the slip says.",
	},
	fc_middle = {
		name = "The Middle",
		kind = "Finger",
		career = "middle",
		color = { 200, 70, 90 },
		desc = "The Finger of loyalty: a family of Little, Big and Great Siblings, marked by their tattoos. The Middle remembers, and always pays its debts, kindness and slights alike.",
		join = "Backstreets only, age 16+, Strength 25. The family invites people who were kind to a sibling, and offers to cross your name out of the Book of Vengeance if you join.",
		perks = "Pay 60, 240 and 650 Ahn a year for the three ranks, promoted slowly on Strength, and you become Family of the Middle. Costs: family debts become your debts, and you'll be sent to collect grudges.",
	},
	fc_ring = {
		name = "The Ring",
		kind = "Finger",
		career = "ring",
		color = { 170, 110, 220 },
		desc = "The Finger of art and knowledge: schools with their own ideas of beauty, galleries by invitation, and work nobody else can look at for long.",
		join = "Backstreets only, age 16+, Intelligence 30. A Docent invites people with an eye. Say no, and you become a portrait subject instead.",
		perks = "Pay 40, 230 and 680 Ahn a year from Student to Maestro, promoted on Intelligence; a Maestro founds a movement of their own. Costs: Sanity wears away a little every year.",
	},
	fc_kurokumo = {
		name = "The Kurokumo Clan",
		kind = "Syndicate",
		career = "kurokumo",
		color = { 70, 80, 130 },
		desc = "A great Backstreets Syndicate of long sheathed blades and dark, wave-patterned coats. It lives on protection fees, demands strict obedience, and feuds with the Blade Lineage.",
		join = "Backstreets only, age 16+, Strength 25. Captains recruit quick, quiet fighters, especially those who fight with Poise or Bleed.",
		perks = "Pay 45, 120 and 380 Ahn a year from Wakashu to Captain, promoted on Strength. Recruits may get a long blade. Costs: sword fights in narrow alleys, and an old feud that isn't yours.",
	},

	-- ── Limbus Company and the Families ─────────────────────────────────────
	fc_lccb = {
		name = "Limbus Company: LCCB",
		kind = "Company",
		career = "limbus_lccb",
		color = { 180, 50, 60 },
		desc = "The Clearance Before Team scouts buried L Corp branches before Limbus Company's bus arrives. Preliminary Observation is its lowest paid, biggest and most dangerous section.",
		join = "In the Distortion era only. Age 18+, Health 30 and Mental Strength 25. The LCCB recruits people who have survived a Distortion.",
		perks = "Pay from 55 Ahn a year as a Preliminary Observer to 760 as Manager, promoted on Mental Strength every two years. Recruits may get a scout's lamp. Costs: the branches are never as empty as the map says.",
	},
	fc_lce = {
		name = "Limbus Company: LCE",
		kind = "Company",
		career = "limbus_lce",
		color = { 140, 220, 150 },
		desc = "The Enkephalin department researches Abnormalities, Distortions and the E.G.O gear made from them, under Chief Researcher Hohenheim.",
		join = "In the Distortion era only. Age 18+, Intelligence 38. Former L Corp staff get a letter: the LCE wants their memories of the old work.",
		perks = "Pay from 90 Ahn a year as a Lab Assistant to 700 as Lead Researcher, promoted on Intelligence. Costs: testing E.G.O gear wears on the mind.",
	},
	fc_lcd = {
		name = "Limbus Company: LCD",
		kind = "Company",
		career = "lim_lcd",
		color = { 160, 80, 140 },
		desc = "The Distortion department manages Distortions for paying clients. Its OSIR Team solves them like detectives, by finding the moment each one began.",
		join = "In the Distortion era only. Age 18+, Mental Strength 35. The OSIR Team recruits people who talked a Distortion down, and the LCD poaches from the LCCB.",
		perks = "Pay from 70 Ahn a year as a Case Clerk to 760 as Case Director, promoted on Mental Strength every two years. Costs: a little Sanity every year, and cases that turn Late while you're still taking notes.",
	},
	fc_bloodfiend = {
		name = "A Bloodfiend Family",
		kind = "Family",
		career = "bf_family",
		color = { 200, 40, 52 },
		desc = "Bloodfiends are an old people of the City: red-eyed, quick to heal, slow to age and always a little thirsty. They live in Families led by an Elder, and they are not Distortions.",
		join = "Bloodfiends only, age 18+. Take the Kindred's gift from a Family, or be raised by one. Strays are invited home, and they're also hunted.",
		perks = "Pay from 60 Ahn a year as a Fledgling to 900 as Steward of the Family, promoted on Strength, and the Family's cellars keep the Thirst quiet. Costs: hunters, rival Families, and the oldest rule: a Child never turns against their Parent.",
	},
}
