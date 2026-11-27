--[[
	The Archive: Lobotomy Corporation. How the facility worked, in the words of the people
	who worked there, plus the secrets the long discovery chains end in (secret = true).
	{ id, category, title, text, secret }. Canon: docs/CANON.md sections 1.3, 1.4 and 5.
	The Abnormalities themselves are in Lore/Abnormalities.luau.
]]

return {
	-- ── how the facility works ──
	{
		id = "lc_lore_risk_levels",
		category = "lobotomy",
		title = "Risk Levels",
		text = "L Corp graded every Abnormality on five levels, from least to most dangerous: ZAYIN, TETH, HE, WAW and ALEPH. On paper, the grade measured how efficiently a creature gave off energy. Agents used it to measure something simpler: their odds of walking back out.\n\nNew Agents work ZAYIN and TETH units. HE needs experience. WAW needs veterans. ALEPH needs veterans, luck, and a Manager who knows exactly what they're doing. A low-level Agent sent to a high-level unit feels the fear before they reach the door.",
	},
	{
		id = "lc_lore_virtues",
		category = "lobotomy",
		title = "Work and the Four Virtues",
		text = "Each kind of work trains one of an Agent's four Virtues. Instinct, the physical care, trains Health. Insight, keeping the unit and its routines in order, trains Mental Strength. Attachment, company and conversation, trains Intelligence. Repression, force and discipline, trains Strength.\n\nEvery Abnormality likes some kinds of work and hates others, and the file says which, once enough Agents have survived finding out. When work goes wrong it hurts in a color: red for the body, white for the mind, black for both, and pale for something that takes a share of everything.",
	},
	{
		id = "lc_lore_departments",
		category = "lobotomy",
		title = "The Departments",
		text = "The facility is split into departments, each with its own team and its own floor: Control, Information, Safety and Training at the top; Central Command, Welfare and Disciplinary in the middle; Extraction and Record below them; and Architecture at the very bottom, where almost nobody goes.\n\nControl watches the cameras and gives orders. Information keeps a file on every Abnormality. Safety writes the emergency plans. Training writes the rules and runs orientation. Welfare looks after your body and your nerves. Disciplinary handles suppression and punishment, and is proud of it. Extraction makes E.G.O and repairs the walls. Record writes down everything you do, and promotions are decided from what it writes.",
	},
	{
		id = "lc_lore_sephirot",
		category = "lobotomy",
		title = "The Sephirot",
		text = "Every department is run by a Sephirah: a thinking machine with a name borrowed from an old diagram called the Tree of Life. Most of them look like robots. Malkuth runs Control and gives too many orders. Yesod runs Information and corrects your spelling. Netzach runs Safety and would rather be asleep. Hod runs Training and badly wants to be liked.\n\nFurther down are the Tiphereth twins of Central Command, who care a great deal about their outfits; Chesed of Welfare, easygoing and fond of coffee; Gebura of Disciplinary, who fights like she remembers doing it for a living; Binah of Extraction, who speaks in riddles; and Hokma of Record, who forgets nothing. Below them is Architecture, and nobody you know has met its head.\n\nNobody at L Corp asks how a company got permission to build machines that think.",
	},
	{
		id = "lc_lore_agents",
		category = "lobotomy",
		title = "Agents and Clerks",
		text = "Clerks keep the departments running: paperwork, schedules, the coffee machine. They never enter a containment unit, and they panic easily when the Agents aren't around. As long as enough of them survive the day, the department works better. The company calls that bonus Clerk Benefits, which tells you how it thinks of them.\n\nAgents do the work. They start at Level 1 and rise to Level 5 as their Virtues grow, and higher-level Agents feel less fear. An Agent who stays in one department earns titles and an armband for Continued Service, and the longest-serving becomes Department Captain. Transfer out, and you start counting again.",
	},
	{
		id = "lc_lore_qliphoth",
		category = "lobotomy",
		title = "Qliphoth Counters and Meltdowns",
		text = "Every Abnormality has a Qliphoth Counter: a number on the board outside its unit that tracks how settled it is. Bad work, the wrong kind of work, or just a bad day knocks the number down. When it reaches zero, the Abnormality breaches its containment, or does whatever it does instead.\n\nAll the work done in a day also fills a gauge for the whole facility. When the gauge is full, a Qliphoth Meltdown hits: alarms go off on several units at once, and the work there must be done now, by whoever is closest. Sometimes the full gauge brings something worse than a meltdown. Those are called Ordeals.",
	},
	{
		id = "lc_lore_pe_boxes",
		category = "lobotomy",
		title = "PE-Boxes and the Quota",
		text = "Good work makes an Abnormality give off Positive Enkephalin, collected in neat green units called PE-Boxes. Bad work gives off Negative Enkephalin instead, which hurts whoever is in the room.\n\nEvery day the facility has an energy quota to fill, and the day isn't over until it's filled. The Boxes go up, the green goes out along the City's power lines, and the lights stay on in twenty-six Districts. Nobody outside asks how.",
	},
	{
		id = "lc_lore_ordeals",
		category = "lobotomy",
		title = "Ordeals",
		text = "Ordeals are named for the time of day they come at, Dawn, Noon, Dusk and Midnight, and each comes in a color. Green Ordeals are machines asking why they were made. Crimson is a grinning circus troupe. Violet is something trying to understand you and failing. Amber burrows up through the floor, hungry. Indigo is the Sweepers, come down from the Backstreets.\n\nDawn is a warning. Noon is a fight. Dusk is a disaster. Midnight is the kind of day the memorial wall gets longer. Captains whisper about a White Ordeal too, the kind that wears Fixers' coats.",
	},
	{
		id = "lc_lore_ego_gear",
		category = "lobotomy",
		title = "E.G.O Gear",
		text = "Ordinary weapons barely scratch an Abnormality, so the Extraction Team takes something from the Abnormalities instead: a piece of what each creature is, shaped into a weapon or a suit. It's called E.G.O. The letters stood for something once; even the company spells it out wrong.\n\nE.G.O carries its Abnormality's character. A suit from a mourner makes you quiet. A blade from a judge makes you weigh your words. Strong gear needs strong Virtues, and Agents who wear more than they can bear start to talk like what they're wearing.",
	},
	{
		id = "lc_lore_suppression",
		category = "lobotomy",
		title = "Suppression",
		text = "When an Abnormality breaches, the Agents nearest to it are sent to suppress it: to fight it until it gives up its shape and goes back into its egg. Abnormalities don't die. They return to their units afterward, and the work starts again the next day.\n\nThe Disciplinary Team leads the worst suppressions. Everyone else is expected to hold the corridor and keep the Clerks alive until they arrive.",
	},
	{
		id = "lc_lore_manager",
		category = "lobotomy",
		title = "Managers",
		text = "Every facility has one Manager. They sit in a control room above the departments and decide who works on what, when, and with which Abnormality. They watch every corridor through the cameras, and they never go down into the units.\n\nHeadquarters' own Manager is a rumor even inside the company: orders come over the speakers in a calm assistant's voice, and nobody you know has seen the Manager's face. Branch Managers are easier to spot. They're the ones who look like they haven't slept in years.",
	},
	{
		id = "lc_lore_branches",
		category = "lobotomy",
		title = "L Corp's Branches",
		text = "Lobotomy Corporation's headquarters stood in District 12, but the company had branches all over the City: facilities with their own containment units, under other Districts' streets. A Branch Manager ran each one and answered to headquarters.\n\nAfter the fall, every branch sealed itself and sank. Some neighborhoods sit right on top of one. On quiet nights, people say, the floors hum.",
	},

	-- ── the secrets the discovery chains end in ──
	{
		id = "lc_secret_green",
		category = "lobotomy",
		title = "Where the Green Comes From",
		secret = true,
		text = "Enkephalin isn't mined, brewed or burned. It comes out of the Abnormalities, and the Abnormalities come out of people. Each of them began as something human minds held too tightly: a fairy tale, a fear, a story everyone knows. The oldest notes in the archive say they are materialized from the unconscious.\n\nSo the green that lights the City is drawn, in the end, from inside people's heads. The company never lied about this. It just never said it.",
	},
	{
		id = "lc_secret_well",
		category = "lobotomy",
		title = "The Well",
		secret = true,
		text = "Below the departments, the Extraction Team works at the edge of something its staff call the Well: a sea beneath every mind, holding every possibility of humanity, past, present and future. The research that came before the company found a way to draw from it. Abnormalities are what comes up.\n\nThe Extraction Team has one rule above all its others: never look down into the Well while you work. One of them did, once. He was never the same, and the rule was written the next morning.",
	},
	{
		id = "lc_secret_sephirot",
		category = "lobotomy",
		title = "Who the Sephirot Were",
		secret = true,
		text = "Machines that think like people are against the Taboos of the City, and the Sephirot think like people. They have habits no machine needs. They mention a lab that existed before the company, hidden in the Backstreets, and sometimes they say \"we\" about people who died there.\n\nEach of them was someone, once: a member of that first research team, carried on in a machine by the colleague who outlived them. Ask the right one the right question, and an old name answers.",
	},
	{
		id = "lc_secret_loop",
		category = "lobotomy",
		title = "The Same Day",
		secret = true,
		text = "Some old Clerks swear the facility lived the same day more than once. The same alarm at the same minute. The same breach in the same corridor. A colleague lost, then back at their desk the next morning, asking why everyone is staring. Forms turn up in your own handwriting that you don't remember filling in.\n\nNobody official will say how. The ones who remember most clearly say the Manager kept trying certain days again until they came out right, and that every try was paid for by somebody.",
	},
	{
		id = "lc_secret_seed",
		category = "lobotomy",
		title = "The Seed of Light",
		secret = true,
		text = "Lobotomy Corporation was never really an energy company. Selling the green paid for something else, grown at the very bottom of the facility where almost nobody goes: a Light. The people who began the research believed the City was sick in its heart, every heart, and that enough Light released at once could wake every heart in it.\n\nThey called it the Seed of Light. Every PE-Box anyone ever filled was a little more of it.",
	},
	{
		id = "lc_secret_white_nights",
		category = "lobotomy",
		title = "What the White Nights Were",
		secret = true,
		text = "The pillar of light over District 12 was the Seed of Light, released at last. For a few days it did what it was meant to do: people were kind, the streets were safe, and almost nobody died. Then the Light was split. Something took a great part of it to raise a tower where the company had stood, and what was left settled into the City wrong.\n\nPeople started turning into Distortions after that. The Light was meant to heal. The people who grew it believed it still might.",
	},
}
