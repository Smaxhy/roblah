--[[
	The opening of a life (area A). These are queued by the toddler ambitions in
	Ambitions/Life.luau, so every new life sees them in its first minutes:
		age 2  a first memory      one variant per origin / side
		age 3  the rule            "be home before three" (Backstreets) or the wall (Nest)
		age 5  the first friend    Bori, the bread girl (Backstreets) or Lotte (Nest)
	Each variant's `when` is exclusive, so exactly one fits a life; all are weight 0.
	Bori's and Lotte's stories continue in Life_Arcs.luau.
]]

local ORIGIN_FLAGS = { "bs_first_memory", "foundling", "fixer_blood", "smoke_war_family", "runaway_family", "hongyuan_family", "lcorp_family" }

return {
	-- ── age 2: a first memory ──────────────────────────────────────────────
	{
		id = "bs_c_first_backstreets",
		title = "Three Locks",
		text = "Your first memory: your father's big hands on the front door at bedtime. Click. Click. Click. Three locks, in the same order, every night. Outside, the Backstreets hum like a pot about to boil. {father} catches you watching and lifts you up so you can reach the last one.",
		weight = 0,
		when = { side = "backstreets", hasRelation = "father", notFlags = ORIGIN_FLAGS },
		choices = {
			{
				label = "Turn the last lock yourself",
				result = { mind = 1, sanity = 2, setFlags = { "bs_first_memory", "bs_lock_turner" }, log = "You turned the third lock with both hands. {father} said you were a natural. It was the proudest moment of your life so far, which was not yet a long life." },
			},
			{
				label = "Ask what's outside",
				result = { mind = 1, sanity = 1, setFlags = { "bs_first_memory" }, log = "\"Nothing,\" {father} said, \"as long as we're in here.\" You thought about that answer for years, and it got stranger every time." },
			},
			{
				label = "Wriggle down and hide under the table",
				result = { strength = 1, sanity = 1, setFlags = { "bs_first_memory" }, log = "You crawled under the table and refused to come out. {father} sat on the floor beside you until you fell asleep. You slept under that table most nights until you were four." },
			},
		},
	},
	{
		id = "bs_c_first_single",
		title = "The Diner Counter",
		text = "Your first memory is a diner counter at closing time. {mother} is wiping it down with one hand and holding you with the other, and a big woman at the stove is singing along to the radio. The clock over the door says 1:40. In all the years to come, your mother never once misses the walk home.",
		weight = 0,
		when = { side = "backstreets", hasRelation = "mother", noRelation = "father", notFlags = ORIGIN_FLAGS },
		choices = {
			{
				label = "Fall asleep on the counter",
				result = { sanity = 3, setFlags = { "bs_first_memory", "bs_knows_mun" }, log = "You fell asleep between the soy sauce and the napkins. The cook, a big woman everyone called Auntie Mun, covered you with her apron and served the last customer around you." },
			},
			{
				label = "Steal a dumpling",
				result = { strength = 1, sanity = 1, setFlags = { "bs_first_memory", "bs_knows_mun" }, log = "You stole a dumpling off a plate. Auntie Mun saw, and gave you a second one, \"so you learn that crime doesn't pay double.\" You didn't learn that. It did pay double." },
			},
			{
				label = "Watch the clock with her",
				result = { mind = 2, setFlags = { "bs_first_memory" }, log = "You watched the clock hands crawl. At two, {mother} hung up her apron, picked you up, and walked you home through the wet streets, counting the locks out loud when you got there." },
			},
		},
	},
	{
		id = "bs_c_first_orphan",
		title = "The Coat",
		text = "Your first memory is the coat. It's far too big for you: dark, heavy, smelling of rain, with a little metal crest pinned to the collar, a key inside a circle. Matron Hesketh at the foundling house says it was wrapped around you the morning they found you on the step, after a Night. Nobody ever came back for the coat. Or for you.",
		weight = 0,
		when = { side = "backstreets", flags = { "foundling" }, notFlags = { "bs_first_memory" } },
		choices = {
			{
				label = "Sleep in it every night",
				result = { sanity = 3, setFlags = { "bs_first_memory", "bs_coat_kept" }, log = "You slept in the coat every night. It was the only thing in the foundling house that was definitely, completely yours." },
			},
			{
				label = "Trace the crest with your finger",
				result = { mind = 2, setFlags = { "bs_first_memory", "bs_coat_kept", "bs_coat_crest" }, log = "You traced the little key in its circle until you could draw it with your eyes shut. Somebody, somewhere, wore this crest on purpose. You decided you'd find out who." },
			},
			{
				label = "Let the older kids have it",
				result = { health = 1, sanity = -1, setFlags = { "bs_first_memory" }, log = "The older kids took turns wearing it. You let them. One morning it was gone, and you didn't cry, and the older kids respected that more than anything you could have said." },
			},
		},
	},
	{
		id = "bs_c_first_fixer",
		title = "The Sign Downstairs",
		text = "Your first memory is the sign over the door downstairs, older than your parents: HINGE OFFICE in chipped paint, and under it, smaller, CONTRACTS TAKEN. Through the floor you can hear your parents talking to a client in low voices, and the soft, careful click of somebody checking a weapon.",
		weight = 0,
		when = { side = "backstreets", flags = { "fixer_blood" }, notFlags = { "bs_first_memory" } },
		choices = {
			{
				label = "Creep down the stairs to listen",
				result = { strength = 1, mind = 1, setFlags = { "bs_first_memory" }, log = "You sat on the third stair and listened. The client wanted someone found. Your mother asked, \"Found, or brought back?\" You didn't understand the difference for years. Then you did." },
			},
			{
				label = "Play with the spare whetstone",
				result = { intelligence = 1, sanity = 1, setFlags = { "bs_first_memory" }, log = "You found a whetstone under the desk and spent the whole afternoon making it very wet and very proud of itself." },
			},
			{
				label = "Draw the sign",
				result = { sanity = 2, setFlags = { "bs_first_memory", "bs_drew_the_sign" }, log = "You drew the sign in crayon, with yourself standing under it in a long coat. Your father pinned it up in the Office. For years, clients asked who the little Fixer was." },
			},
		},
	},
	{
		id = "bs_c_first_nest",
		title = "The White Ceiling",
		text = "Your first memory is very white: the ceiling, the walls, the little drone that floats past your window every evening and blinks at you. Inside the Nest everything hums quietly and nothing is ever dirty. The nanny says the drone is your friend. It does not blink like a friend.",
		weight = 0,
		when = { side = "nest", notFlags = { "bs_first_memory" } },
		choices = {
			{
				label = "Wave at the drone",
				result = { sanity = 2, setFlags = { "bs_first_memory" }, log = "You waved at the drone every evening. Once, it blinked twice. You told everyone. Nobody believed you except, you suspect, the drone." },
			},
			{
				label = "Hide your toy from it",
				result = { mind = 2, setFlags = { "bs_first_memory", "bs_nest_wary" }, log = "You hid your favorite toy under the bed whenever it passed. Your parents laughed. Then one evening your father hid a letter the same way, and stopped laughing." },
			},
			{
				label = "Press your face to the glass and look past it",
				result = { sanity = -1, mind = 1, codex = "bs_lore_nests", setFlags = { "bs_first_memory", "bs_saw_backstreets" }, log = "Past the drone, past the gardens, past the wall, the Backstreets went on forever: dark roofs, steam, a thousand little lights. You asked who lived there. \"Nobody you'll ever need to meet,\" said the nanny." },
			},
		},
	},
	{
		id = "bs_c_first_lcorp",
		title = "The Green Light",
		text = "Your first memory is green. Every night the light of the L Corp tower comes through the curtains and paints your room the color of new leaves. Your parents come home after you're asleep and leave before you wake. Some nights you hear them in the kitchen, talking very quietly about someone who didn't come back.",
		weight = 0,
		when = { side = "backstreets", flags = { "lcorp_family" }, world = { era = "wings" }, notFlags = { "bs_first_memory" } },
		choices = {
			{
				label = "Stay awake to see them",
				result = { mind = 1, sanity = -1, setFlags = { "bs_first_memory" }, log = "You stayed awake until the door clicked. Your mother came in smelling of disinfectant, kissed your forehead, and didn't say a word. You pretended to be asleep. So did she, probably." },
			},
			{
				label = "Count the windows of the tower",
				result = { intelligence = 2, setFlags = { "bs_first_memory" }, log = "You counted the lit windows of the tower every night, until you reached a number no grown-up would believe." },
			},
			{
				label = "Pull the curtains shut",
				result = { sanity = 2, setFlags = { "bs_first_memory" }, log = "You pulled the curtains shut. The green came through anyway, softer. You got used to sleeping in it. Years later, in other Districts, real darkness felt wrong." },
			},
		},
	},
	{
		id = "bs_c_first_veteran",
		title = "The Fly at the Window",
		text = "Your first memory is a sound: a fly buzzing against the window, and your father going completely still. He doesn't move until it's gone. Under his bed there's a long metal box with two locks. You are not to touch it. You think about it all the time.",
		weight = 0,
		when = { side = "backstreets", flags = { "smoke_war_family" }, notFlags = { "bs_first_memory" } },
		choices = {
			{
				label = "Catch the fly for him",
				result = { strength = 1, sanity = 1, setFlags = { "bs_first_memory", "bs_vet_bond" }, log = "You trapped the fly under a cup and let it out the window. Your father looked at you for a long moment and said, \"Good. Good,\" and went to make tea. His hands were shaking." },
			},
			{
				label = "Ask about the box",
				result = { mind = 1, setFlags = { "bs_first_memory", "bs_asked_box" }, codex = "bs_lore_smoke_war", log = "You asked about the box. He said \"the War\", in a voice like a door closing. You didn't ask again. You didn't stop wondering, either." },
			},
			{
				label = "Climb into his lap",
				result = { sanity = 3, setFlags = { "bs_first_memory", "bs_vet_bond" }, log = "You climbed into his lap, and he held on to you like you were the only solid thing in the room." },
			},
		},
	},
	{
		id = "bs_c_first_runaway",
		title = "Keep the Lamp Low",
		text = "Your first memory is your mother's hand cupped around the lamp, keeping it low. Your parents whisper even in the daytime. When men in headbands walk past the shed, everybody stops breathing, even you, though you don't know why yet.",
		weight = 0,
		when = { side = "backstreets", flags = { "runaway_family" }, notFlags = { "bs_first_memory" } },
		choices = {
			{
				label = "Stay perfectly quiet",
				result = { mind = 2, setFlags = { "bs_first_memory" }, log = "You learned to be so quiet that the mice stopped noticing you. It was the first thing you were ever good at." },
			},
			{
				label = "Peek through the boards",
				result = { strength = 1, setFlags = { "bs_first_memory", "bs_saw_chunokkun" }, log = "Through a gap in the boards you saw their headbands: one painted character, sharp as a hook. You drew it in the dirt later. Your father scrubbed it out with his boot, fast." },
			},
			{
				label = "Hum, very softly",
				result = { sanity = 2, setFlags = { "bs_first_memory" }, log = "You hummed. Your mother put a finger to your lips, then, after a moment, hummed along, so softly it was more like breathing. It was a song from the King's Court. She never told you its name." },
			},
		},
	},
	{
		id = "bs_c_first_hongyuan",
		title = "The Room That Shrank",
		text = "Your first memory: waking up because your crib has bumped into the wall. The room is smaller than it was last night. In Hongyuan, your room is exactly as big as your family's fortune, and this month the fortune went down. Your grandmother pushes the furniture back into place and tells you not to worry. She's done this before.",
		weight = 0,
		when = { side = "backstreets", flags = { "hongyuan_family" }, notFlags = { "bs_first_memory" } },
		choices = {
			{
				label = "Help push",
				result = { health = 1, sanity = 1, setFlags = { "bs_first_memory" }, log = "You pushed the crib with your tiny hands. It didn't move at all, but your grandmother said you'd saved the family a fortune." },
			},
			{
				label = "Ask why the walls move",
				result = { mind = 1, codex = "bs_lore_hongyuan_rooms", setFlags = { "bs_first_memory" }, log = "\"Because we're poor this month,\" your grandmother said. \"Next month we'll be rich, and the walls will run away from us.\" They didn't, but you loved the idea for years." },
			},
			{
				label = "Draw a door on the new wall",
				result = { intelligence = 1, sanity = 2, setFlags = { "bs_first_memory" }, log = "You drew a door on the wall in chalk. By morning the building had shifted again and your door was on the ceiling. You were delighted." },
			},
		},
	},

	-- ── age 3: the rule ────────────────────────────────────────────────────
	{
		id = "bs_c_rule_backstreets",
		title = "Home Before Three",
		text = "Tonight you're old enough for the rule. The grown-ups sit you at the table, very serious. \"Every night at 3:13, the Sweepers come up out of the ground and clean the streets. Anything left outside gets cleaned. Anyone left outside gets cleaned. So what do we do?\"",
		weight = 0,
		when = { side = "backstreets", notFlags = { "bs_rule_learned" } },
		codex = "city_sweepers",
		choices = {
			{
				label = "\"Be home before three.\"",
				result = { mind = 2, sanity = 1, setFlags = { "bs_rule_learned" }, log = "\"Be home before three,\" you said. Everyone at the table nodded as if you'd said something wise. You said it every night after that, even when nobody asked." },
			},
			{
				label = "\"What do the Sweepers look like?\"",
				result = { mind = 1, sanity = -2, setFlags = { "bs_rule_learned", "bs_night_curious" }, log = "\"Nobody knows,\" they said, \"because nobody who looks comes back to tell.\" That wasn't quite true, you found out later. But it worked. You didn't sleep for a week." },
			},
			{
				label = "\"Can I stay up and listen?\"",
				result = { strength = 1, setFlags = { "bs_rule_learned", "bs_night_curious" }, codex = "bs_lore_night_rules", log = "They let you, once, wrapped in a blanket on the floor. At 3:13 the whole building hummed, the floor shivered, and something like a crowd went past outside, slowly, for a very long time. You were asleep before the third wave." },
			},
		},
	},
	{
		id = "bs_c_rule_nest",
		title = "The Wall",
		text = "Your class takes a walk to the edge of the Nest. The wall is taller than anything, and through the bars of the gate you can see the Backstreets: steam, noise, a man selling skewers off a cart, a boy your age staring back at you. The guide says the people out there must be home before three every night, \"or else.\" Somebody asks, \"Or else what?\" The guide walks on very quickly.",
		weight = 0,
		when = { side = "nest", notFlags = { "bs_rule_learned" } },
		choices = {
			{
				label = "Wave at the boy",
				result = { sanity = 2, setFlags = { "bs_rule_learned", "bs_waved_wall" }, schedule = { event = "bs_a_wall_boy", inYears = 22 }, log = "You waved. He waved back, then stuck his tongue out, then ran off. You thought about him for weeks. Was he home before three? You hoped so." },
			},
			{
				label = "Ask the guide, \"Or else what?\"",
				result = { mind = 2, codex = "bs_lore_night_rules", setFlags = { "bs_rule_learned" }, log = "\"Or else they aren't home,\" the guide said, smiling the way grown-ups smile when a question is closed. You looked it up later, in the school library. You wished you hadn't." },
			},
			{
				label = "Count the guards",
				result = { intelligence = 2, setFlags = { "bs_rule_learned" }, codex = "bs_lore_nests", log = "Six guards at the gate, two drones, one camera on a pole. You counted them every time you passed, for the rest of your childhood. The guards noticed." },
			},
		},
	},

	-- ── age 5: the first friend ────────────────────────────────────────────
	{
		id = "bs_c_bori_bread",
		title = "The Bread Girl",
		text = "A girl about your age is sitting on the bakery step, watching people go in and out. She's very thin and very still, like a cat deciding something. You have a sweet bun in a paper bag, still warm. She doesn't ask for it. She looks at the bag, then at you, and says: \"I'm Bori. I live behind the bins.\"",
		weight = 0,
		when = { side = "backstreets", maxAge = 9, notFlags = { "bs_bori_met" } },
		choices = {
			{
				label = "Split the bun with her",
				result = {
					sanity = 3,
					setFlags = { "bs_bori_met", "bs_bori_shared" },
					addRelation = { kind = "friend", name = "Bori", bond = 60, age = { 5, 6 } },
					schedule = { event = "bs_c_bori_pack", inYears = 6 },
					log = "You split the bun down the middle. Bori ate her half in four bites and watched you eat yours like it was a show. After that, she was waiting on the bakery step most mornings.",
				},
			},
			{
				label = "Give her the whole thing",
				result = {
					sanity = 2,
					mind = 1,
					setFlags = { "bs_bori_met", "bs_bori_shared" },
					addRelation = { kind = "friend", name = "Bori", bond = 70, age = { 5, 6 } },
					schedule = { event = "bs_c_bori_pack", inYears = 6 },
					log = "You gave her the whole bun. She didn't say thank you. She said, \"Tomorrow I'll show you where the Rats sleep,\" which, you learned, was how Bori said thank you.",
				},
			},
			{
				label = "Hold the bag tight and walk past",
				result = {
					mind = 1,
					setFlags = { "bs_bori_met", "bs_bori_refused" },
					schedule = { event = "bs_c_bori_tax", inYears = 6 },
					log = "You held the bag tight and walked past. When you looked back, the step was empty. You ate the bun at home. It wasn't as good as you'd hoped.",
				},
			},
		},
	},
	{
		id = "bs_c_nest_lotte",
		title = "The Scholarship Girl",
		text = "First day at the Nest's prep school: pressed uniforms, a brass bell, a teacher who calls everyone by their family name. The girl at the next desk has a uniform two sizes too big and hands rough from real work. \"Scholarship,\" she whispers, as if it's a confession. \"From the Backstreets. I'm Lotte.\" Three of your classmates have already moved their chairs away from her.",
		weight = 0,
		when = { side = "nest", maxAge = 9, notFlags = { "bs_lotte_met" } },
		choices = {
			{
				label = "Move your chair closer",
				result = {
					sanity = 2,
					setFlags = { "bs_lotte_met", "bs_lotte_friend" },
					addRelation = { kind = "friend", name = "Lotte", bond = 65, age = { 5, 6 } },
					schedule = { event = "bs_y_lotte_scholarship", inYears = 8 },
					log = "You moved your chair closer. Lotte looked at you like you'd done something illegal, and then grinned. She taught you three words you weren't allowed to say in the Nest. You taught her where the good library was.",
				},
			},
			{
				label = "Ask her what the Backstreets are like",
				result = {
					mind = 2,
					codex = "bs_lore_backstreets",
					setFlags = { "bs_lotte_met", "bs_lotte_friend" },
					addRelation = { kind = "friend", name = "Lotte", bond = 55, age = { 5, 6 } },
					schedule = { event = "bs_y_lotte_scholarship", inYears = 8 },
					log = "\"Loud,\" said Lotte. \"Wet. Everyone knows everybody. You have to be home before three.\" She thought. \"I like it better than here.\" Nobody in the Nest had ever said anything so interesting to you.",
				},
			},
			{
				label = "Keep your chair where it is",
				result = { intelligence = 1, sanity = -1, setFlags = { "bs_lotte_met" }, log = "You kept your chair where it was. So did everyone else. By the end of the term Lotte sat alone by the window, top of the class, and didn't look at any of you." },
			},
		},
	},
}
