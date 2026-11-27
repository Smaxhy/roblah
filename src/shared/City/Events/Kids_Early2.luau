--[[
	Early childhood, part two (ke_): ages 4-6, when the City starts showing through. The WARP
	rail's shadow, the Nest wall, a Fixer's coat on the stairwell rail, the sound at 3:13, Rats
	on the courtyard wall, a sibling's secrets, and the first time somebody says "the Night".
	Parents and neighbors teach the rules of the Night around 5-6 (knows_night).
	Lore flags set here when a child really learns something: knows_night, knows_fixers,
	knows_syndicates, knows_wings, knows_lcorp, and knows_bloodfiends (Raised by a Family only).
	Ages 1-3 are in Kids_Early.luau. Faces: Cast/Kids_Early.luau.

	Follow-ups (weight 0, ages 7-12) at the end of this file. Each sets and checks its own
	*_done flag, so a follow-up scheduled from two scenes still plays once.
		ke_k_coat_rail, ke_k_tali_prices -> ke_f_iseul_moving   the coat lady leaves
		ke_k_rats_wall                   -> ke_f_dosan_hides    somebody's looking for Dosan
		ke_k_bird_clock                  -> ke_f_bird_clock     the late family on four
		ke_k_floorboard                  -> ke_f_floorboard_jar the sibling's savings
		ke_k_crow_pegs                   -> ke_f_crow_stones    your crow
		ke_k_grisha                      -> ke_f_grisha_rounds  Thursday rounds
		ke_k_practice, ke_t_two_names    -> ke_f_real_name      runaway family
		ke_n_aptitude, ke_n_camera       -> ke_f_nest_file      the academy interview
		ke_n_painted_door                -> ke_f_arno_queue     the boy across the corridor
		ke_n_grandmother                 -> ke_f_grandma_pass
		ke_t_redfoot                     -> ke_f_redfoot
		ke_t_cot_friend                  -> ke_f_ivo
]]

-- scenes set in a family flat (a landing, neighbors, the front door)
local NO_HOME = { "foundling", "bf_family_raised" }

-- checks at these ages stay small (spec: ages 1-5); every check scene here is ages 4-5
local function kid(stat: string, foe: string)
	return { stat = stat, foe = foe, coins = 1, base = 1, coinPower = 2, fixed = true }
end
-- the follow-ups at 7-12 (spec: ages 6-12)
local function older(stat: string, foe: string)
	return { stat = stat, foe = foe, coins = 1, base = 2, coinPower = 2, fixed = true }
end

return {
	-- ── the building, the courtyard, the street ────────────────────────────
	{
		id = "ke_k_coat_rail",
		title = "The Coat on the Rail",
		art = "home",
		text = "A long grey coat hangs over the stairwell rail on the fourth floor, dripping onto the steps. One sleeve is torn from cuff to elbow, and it smells like a struck match.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 6, notFlags = NO_HOME },
		dialogue = {
			{ who = "ke_iseul", line = "Hands off, third floor. That's a work coat." },
			{ who = "ke_iseul", line = "Tell your folks I'm sorry about Tuesday. It won't happen again. Probably." },
		},
		choices = {
			{ label = "Fold it for her", result = { intelligence = 1, setFlags = { "ke_iseul_met", "ke_coat_folded" }, schedule = { event = "ke_f_iseul_moving", inYears = 4 }, log = "You folded it badly, sleeves inside. She looked at it a long time, then carried it upstairs exactly like that." } },
			{ label = "Ask what her work is", result = { mind = 1, setFlags = { "ke_iseul_met", "knows_fixers" }, schedule = { event = "ke_f_iseul_moving", inYears = 4 }, log = "\"Fixer,\" she said, looking at the sleeve. \"People pay me to fix things, mostly.\"" } },
			{ label = "Run and tell Tali", result = { speed = 1, sanity = -1, setFlags = { "ke_iseul_met", "knows_fixers" }, schedule = { event = "ke_f_iseul_moving", inYears = 4 }, log = "Tali said Fixers fight anybody for money, and one once ate a whole cake in one go. Only one of those was a lie." } },
			{
				label = "\"I saw you at the market.\"",
				requires = { flags = { "ke_saw_coat" } },
				result = { mind = 1, sanity = 1, setFlags = { "ke_iseul_met", "knows_fixers" }, schedule = { event = "ke_f_iseul_moving", inYears = 4 }, log = "\"Good eyes, bad habit,\" she said. Then she told you she was a Fixer, so you'd stop following her." },
			},
		},
	},
	{
		id = "ke_k_rats_wall",
		title = "Rats on the Wall",
		art = "alley",
		text = "Three older boys in matching jackets sit on the courtyard wall, eating the laundry lady's oranges. The grown-ups call them Rats, quietly, the way you'd name a bad smell.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 6 },
		codex = "bs_lore_rats",
		dialogue = {
			{ who = "ke_dosan", line = "What're you looking at, shrimp?" },
			{ who = "ke_dosan", line = "Want one? Catch." },
		},
		choices = {
			{ label = "Catch the orange", result = { sanity = 2, setFlags = { "ke_rat_orange", "knows_syndicates" }, schedule = { event = "ke_f_dosan_hides", inYears = 5 }, log = "You caught it with both arms, and Dosan laughed. \"Good hands, and don't tell the laundry lady.\"" } },
			{ label = "Tell the laundry lady", result = { strength = 1, setFlags = { "ke_rat_snitch", "knows_syndicates" }, schedule = { event = "ke_f_dosan_hides", inYears = 5 }, log = "She came out with a broom and the Rats scattered. Dosan looked back from the gate and learned your face." } },
			{ label = "Go in the long way", result = { mind = 1, setFlags = { "knows_syndicates" }, log = "You went round by the bins and up the back stairs. A grown-up on the stairs said that was the right answer, and the boring one." } },
		},
	},
	{
		id = "ke_k_rail_shadow",
		title = "Riding the Shadow",
		art = "rooftop",
		text = "Every eleven minutes a WARP train crosses the sky above your street, and its shadow runs across the courtyard faster than anything alive. Stand in it as it passes, the older kids say, and you've ridden the train.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 5 },
		choices = {
			{
				label = "Wait in exactly the right spot",
				hint = "Intelligence check.",
				clash = kid("intelligence", "Eleven minutes"),
				win = { intelligence = 1, sanity = 2, setFlags = { "ke_rode_shadow" }, log = "The shadow went right over you, cold for half a second. You'd ridden the WARP, and you told everyone for a year." },
				lose = { sanity = -3, log = "You were one step short. The older kids said it didn't count, and they made the rules." },
			},
			{ label = "Chase the shadow", result = { health = 1, speed = 1, log = "You chased it across the courtyard and lost by the whole courtyard. The next week you lost by less." } },
			{ label = "Ask where the trains go", result = { mind = 1, log = "\"Anywhere you can't afford,\" said Tali from downstairs, the way she'd heard a grown-up say it." } },
		},
	},
	{
		id = "ke_k_capital_n",
		title = "Capital N",
		art = "street",
		text = "Tali from downstairs is two years older than you and knows everything. Today she says a word with a capital letter in it.",
		weight = 14,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 5, notFlags = NO_HOME },
		dialogue = {
			{ who = "ke_tali", line = "You don't know about the Night? Everybody knows about the Night." },
			{ who = "ke_tali", line = "It comes up out of the drains at 3:13 and eats shoes. That's why all the shoes are inside. Look." },
		},
		choices = {
			{ label = "Check your shoes are inside", result = { mind = 1, setFlags = { "knows_night" }, log = "Every pair of shoes on the landing was inside. You checked again before bed, and most nights after that." } },
			{
				label = "Ask Granny Vondra",
				result = {
					mind = 1,
					sanity = -1,
					setFlags = { "knows_night" },
					log = "Granny Vondra laughed, and then she stopped laughing.",
					dialogue = { { who = "ke_granny_vondra", line = "Not shoes. Never you mind what. Be inside, that's all." } },
				},
			},
			{ label = "Tell Tali she's lying", result = { strength = 1, setFlags = { "knows_night", "ke_tali_doubter" }, log = "\"Fine, leave yours out, then,\" said Tali. You didn't, and neither did she." } },
		},
	},
	{
		id = "ke_k_door_rule",
		title = "Not Even for Me",
		art = "home",
		text = "{father} sits you down on the floor by the front door. You've never seen him sit on the floor before.",
		weight = 14,
		once = true,
		when = { side = "backstreets", hasRelation = "father", minAge = 5, maxAge = 6 },
		codex = "city_sweepers",
		dialogue = {
			{ who = "{father}", line = "After 3:13, this door stays shut. Not for a neighbor. Not for somebody crying." },
			{ who = "you", line = "What if it's you?" },
			{ who = "{father}", line = "Then I'll be fine out there, and you'll be fine in here. That's the deal." },
		},
		choices = {
			{ label = "Promise", result = { mind = 2, setFlags = { "knows_night", "ke_door_rule" }, log = "You promised. He made you say it back, then checked the locks, then checked them again." } },
			{
				label = "Ask what's out there",
				result = {
					mind = 1,
					sanity = -2,
					setFlags = { "knows_night", "ke_door_rule" },
					log = "He thought about lying, and you watched him decide not to.",
					dialogue = { { who = "{father}", line = "Sweepers. They clean the streets. Don't say it twice." } },
				},
			},
			{ label = "Make him promise too", result = { sanity = 2, relationBond = { kind = "father", amount = 8 }, setFlags = { "knows_night" }, log = "\"Deal,\" he said, and shook your hand like a businessman. He was home before three every night you can remember." } },
		},
	},
	{
		id = "ke_k_bird_clock",
		title = "Seven Minutes Fast",
		art = "home",
		text = "{mother} gives you a clock of your own: dented tin, with a painted bird on the face. She sets it seven minutes fast and makes you watch her do it.",
		weight = 14,
		once = true,
		when = { side = "backstreets", hasRelation = "mother", minAge = 5, maxAge = 6 },
		codex = "bs_lore_night_rules",
		dialogue = {
			{ who = "{mother}", line = "Every clock in this house is fast. So when it says three, it isn't three yet. Understand?" },
			{ who = "{mother}", line = "And at three you're inside. Not near inside. Inside." },
		},
		choices = {
			{ label = "Wind it every morning", result = { intelligence = 1, setFlags = { "knows_night", "ke_bird_clock" }, schedule = { event = "ke_f_bird_clock", inYears = 4 }, log = "You wound it every morning, eleven turns and never twelve. The bird went everywhere in your pocket." } },
			{
				label = "Ask why three",
				result = {
					mind = 1,
					sanity = -1,
					setFlags = { "knows_night", "ke_bird_clock" },
					schedule = { event = "ke_f_bird_clock", inYears = 4 },
					log = "She said it like a recipe, and made you say it back.",
					dialogue = { { who = "{mother}", line = "Because at 3:13 the Night starts, and the Night isn't for people. That's all." } },
				},
			},
			{ label = "Set it even faster", result = { mind = 1, setFlags = { "knows_night", "ke_bird_clock", "ke_clock_faster" }, schedule = { event = "ke_f_bird_clock", inYears = 4 }, log = "You turned it on another five minutes when she wasn't looking. You were early for everything, for years." } },
		},
	},
	{
		id = "ke_k_brooms",
		title = "A Hundred Brooms",
		art = "night",
		text = "3:13, and you're awake. Under the hum in the floor there's a second sound, from the street: like a hundred brooms on wet stone, coming closer.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 5 },
		choices = {
			{ label = "Count the waves", result = { mind = 1, log = "One, then a long quiet, then two. You fell asleep somewhere in the middle of three, still counting." } },
			{ label = "Pillow over your head", result = { sanity = 1, log = "You pulled the pillow over your head and sang inside it, without a sound, until it was morning." } },
			{
				label = "Listen at the front door",
				hint = "Mental Strength check. Don't make a sound.",
				clash = kid("mind", "Holding your breath"),
				win = { mind = 1, sanity = 2, log = "The sound went past the door and on down the street. You counted your breaths until it was gone." },
				lose = { sanity = -3, log = "The sound stopped right outside the door. Then it went on, and you couldn't remember getting back to bed." },
			},
			{
				label = "Lie still, like when you were tiny",
				requires = { flags = { "ke_hush" } },
				result = { mind = 1, sanity = 2, log = "You lay on your back and breathed slow, the way you'd learned before you could talk. The brooms went by and didn't come back." },
			},
		},
	},
	{
		id = "ke_k_floorboard",
		title = "Under the Floorboard",
		art = "home",
		text = "{sibling} keeps a jam jar under the loose floorboard by the stove. Tonight you saw them put something in it and look over their shoulder first.",
		weight = 12,
		once = true,
		when = { side = "backstreets", hasRelation = "sibling", minAge = 4, maxAge = 5 },
		choices = {
			{
				label = "Look in the jar quietly",
				hint = "Intelligence check.",
				clash = kid("intelligence", "A squeaky floorboard"),
				win = { intelligence = 1, sanity = 2, setFlags = { "ke_jar_seen" }, schedule = { event = "ke_f_floorboard_jar", inYears = 5 }, log = "Inside were coins, a lot of them, and a WARP timetable folded very small. You put the board back exactly as it was." },
				lose = { sanity = -3, relationBond = { kind = "sibling", amount = -6 }, log = "The board squealed like a cat. {sibling} was there in a second and didn't say anything, which was worse than yelling." },
			},
			{ label = "Ask {sibling} about it", result = { mind = 1, setFlags = { "ke_jar_asked" }, schedule = { event = "ke_f_floorboard_jar", inYears = 5 }, log = "\"It's nothing,\" they said. \"And if you tell, I'll tell about the plum jam.\"" } },
			{ label = "Leave it alone", result = { mind = 1, log = "You left it where it was. Sometimes, walking past the stove, you heard it clink." } },
		},
	},
	{
		id = "ke_k_window_231",
		title = "2:31",
		art = "home",
		text = "{sibling}'s bed is empty. The window is open a crack, and the clock in the hall says 2:31.",
		weight = 10,
		once = true,
		when = { side = "backstreets", hasRelation = "sibling", minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Wait up by the window", result = { sanity = -2, relationBond = { kind = "sibling", amount = 6 }, setFlags = { "ke_sib_night_out" }, log = "They climbed back in at 2:58 with a bag of hot buns from the night bakery. \"Don't tell,\" they said, and gave you the biggest." } },
			{ label = "Wake the grown-ups", result = { mind = 1, relationBond = { kind = "sibling", amount = -6 }, log = "The whole flat was up in a second. {sibling} came in at 2:56 to a kitchen full of people, and didn't speak to you for a week." } },
			{ label = "Go back to sleep", result = { sanity = 1, log = "In the morning {sibling} was in bed as if nothing had happened, and there was a sugar bun on your pillow, still warm." } },
		},
	},
	{
		id = "ke_k_over_wall",
		title = "Over the Wall",
		art = "street",
		text = "Your ball goes over the Nest wall at the end of the street. Every kid on the street goes quiet, as if you've broken something that belongs to somebody important.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 5 },
		codex = "bs_lore_nests",
		choices = {
			{ label = "Wait by the wall", result = { mind = 1, sanity = 1, setFlags = { "ke_ball_returned" }, log = "In the morning the ball was on your step, washed, with a printed tag tied on: RETURNED. DO NOT REPEAT." } },
			{
				label = "Climb the drainpipe to look",
				hint = "Strength check.",
				clash = kid("strength", "The drainpipe"),
				win = { strength = 1, sanity = 2, setFlags = { "ke_saw_over_wall" }, log = "At the top you saw white streets and a garden with nobody in it. A camera turned toward you, and you slid down fast." },
				lose = { sanity = -3, log = "You got halfway. A whistle blew on the other side, and you were home before you remembered climbing down." },
			},
			{ label = "Say you didn't want it anyway", result = { intelligence = 1, sanity = -1, log = "The older kids said that was the saddest thing they'd ever heard. One of them gave you her second-best marble." } },
		},
	},
	{
		id = "ke_k_grisha",
		title = "The Knife-Grinder",
		art = "street",
		text = "Old Grisha pedals his grinding wheel into the courtyard every Thursday, ringing a bell. Sparks come off the wheel in orange fans.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 6 },
		dialogue = {
			{ who = "ke_grisha", line = "Kitchen knives and scissors. And something longer, for the lady on five." },
			{ who = "ke_grisha", line = "You. Strong legs? One coin if you pedal." },
		},
		choices = {
			{ label = "Pedal the wheel", result = { health = 1, money = 1, setFlags = { "ke_grisha_pedal" }, schedule = { event = "ke_f_grisha_rounds", inYears = 4 }, log = "You pedaled until your legs shook. Grisha paid you one Ahn and said you had the knees of a much older person." } },
			{ label = "Watch the sparks", result = { sanity = 2, log = "You watched until the bell rang for the next courtyard. The sparks left tiny black stars on the stones." } },
			{ label = "Ask about the lady on five", result = { mind = 1, setFlags = { "knows_fixers" }, log = "\"Fixers bring me the long ones,\" said Grisha. \"Ask her yourself, if you're brave.\"" } },
		},
	},
	{
		id = "ke_k_tooth",
		title = "A Tooth for the Pigeons",
		art = "home",
		text = "Your first tooth came out in a bun. In your building you leave teeth on the windowsill for the pigeons, and in the morning there's a button.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 5, maxAge = 6 },
		choices = {
			{ label = "Leave it on the sill", result = { sanity = 2, setFlags = { "ke_tooth_button" }, log = "In the morning there was a brass button with an anchor on it where the tooth had been. Nobody in the building would say whose." } },
			{ label = "Keep it in a tin", result = { intelligence = 1, log = "You kept it in a tin with a lid, and opened it sometimes to look at the small white piece of you." } },
			{ label = "Sell it to Tali", result = { money = 1, mind = 1, log = "Tali paid one Ahn for it. \"Teeth go up in value,\" she said, and never told you why she wanted it." } },
		},
	},
	{
		id = "ke_k_crow_pegs",
		title = "The Peg Thief",
		art = "rooftop",
		text = "A crow has landed on the washing line on the roof. It's pulling the pegs off the sheets one by one and dropping them over the edge, watching you the whole time.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 5 },
		choices = {
			{
				label = "Chase it off the line",
				clash = { stat = "speed", foe = "A crow", coins = 1, base = 1, coinPower = 2, fixed = true, fight = true, enemy = "crow" },
				win = { speed = 1, sanity = 2, log = "You flapped your arms and shouted until it flew off, cawing. You saved nine pegs and most of a sheet." },
				lose = { sanity = -3, log = "It flew off with the last peg, and the sheet went over the edge after it. You were the one who had to say so." },
			},
			{ label = "Offer it a peg", result = { sanity = 1, setFlags = { "ke_crow_friend" }, schedule = { event = "ke_f_crow_stones", inYears = 4 }, log = "You held out a peg. It took it very carefully, and came back every morning after that to see what else you had." } },
			{ label = "Fetch a grown-up", result = { mind = 1, log = "By the time you came back with a grown-up the crow was gone, and so were the pegs. The grown-up looked at you as if it was your fault." } },
		},
	},
	{
		id = "ke_k_eleven_pots",
		title = "Eleven Pots",
		art = "home",
		text = "Granny Vondra across the landing keeps eleven plant pots on the balcony rail, and every night they all come in by two. Tonight her back is bad, so she's asked you.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 5, maxAge = 6, notFlags = NO_HOME },
		dialogue = {
			{ who = "ke_granny_vondra", line = "In by two. All of them. The Night doesn't like clutter." },
		},
		choices = {
			{ label = "Carry all eleven", result = { health = 1, sanity = 2, setFlags = { "knows_night" }, log = "You carried all eleven, the cactus last, in your sleeves. Granny Vondra counted them twice and gave you a sweet from the jar." } },
			{
				label = "Ask what happens to clutter",
				result = {
					mind = 1,
					setFlags = { "knows_night" },
					log = "She said it to the cactus, not to you.",
					dialogue = { { who = "ke_granny_vondra", line = "It's gone in the morning. Like it was never bought. Like it was never anybody's." } },
				},
			},
			{ label = "Leave the cactus out", result = { strength = 1, sanity = -2, setFlags = { "knows_night" }, log = "In the morning the cactus was gone, pot and all, down to the ring of dirt on the rail. Granny Vondra looked at the space for a long time." } },
		},
	},
	{
		id = "ke_k_tali_prices",
		title = "Tali's Prices",
		art = "street",
		text = "Tali from downstairs sells information on the back steps. What's in the locked basement costs two Ahn. Who the coat lady on five really is costs five.",
		weight = 10,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 5 },
		choices = {
			{
				label = "Pay five for the coat lady",
				hint = "5 Ahn",
				requires = { min = { money = 5 } },
				result = { money = -5, setFlags = { "knows_fixers", "ke_iseul_curious" }, schedule = { event = "ke_f_iseul_moving", inYears = 4 }, log = "\"She's a Fixer, Grade 6, and she once beat a whole gang with an umbrella,\" said Tali. One of those was true." },
			},
			{
				label = "Haggle her down",
				hint = "Mental Strength check.",
				clash = kid("mind", "Tali's prices"),
				win = { charisma = 1, sanity = 2, setFlags = { "knows_fixers", "ke_iseul_curious" }, schedule = { event = "ke_f_iseul_moving", inYears = 4 }, log = "You got it for nothing, plus a marble. \"She's a Fixer,\" Tali said, sulking, \"and don't tell her I told.\"" },
				lose = { sanity = -3, log = "Tali got bored and told you the basement had a dragon in it, for free. You didn't sleep well." },
			},
			{ label = "Find out yourself", result = { strength = 1, setFlags = { "knows_fixers", "ke_iseul_curious" }, schedule = { event = "ke_f_iseul_moving", inYears = 4 }, log = "You sat on the fifth-floor stairs for a week. On the seventh day the coat lady stepped over you and said, \"Fixer, now shoo.\"" } },
		},
	},
	{
		id = "ke_k_knock_back",
		title = "Knock Back",
		art = "home",
		text = "At half past two Mr. Albrecht, the super, walks every floor and knocks once on every door. You're supposed to knock back once, so he knows you're in.",
		weight = 12,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 6, notFlags = NO_HOME },
		dialogue = {
			{ who = "ke_mr_albrecht", line = "Third floor, door B. One knock if you're all in. Then I lock the street door." },
		},
		choices = {
			{ label = "Knock back once", result = { mind = 1, setFlags = { "ke_knocks_back" }, log = "You knocked once, and his footsteps went on to door C. You did it every night after that, even when a grown-up already had." } },
			{ label = "Knock twice", result = { strength = 1, log = "You knocked twice, and after a pause two knocks came back. A tired voice said, \"Very funny, now bed.\"" } },
			{ label = "Don't knock", result = { sanity = -2, log = "He knocked again, harder, and the whole family ran for the door at once. Nobody laughed." } },
			{
				label = "Look at his shoes",
				requires = { flags = { "ke_brown_shoes" } },
				result = { sanity = 3, log = "Brown, with a brass buckle: the shoes that stopped outside your door when you were tiny. It had only ever been him." },
			},
		},
	},
	{
		id = "ke_k_shutters",
		title = "Shutters",
		art = "street",
		text = "At two o'clock the shops on your street pull their shutters down, one after another, all the way to the corner. It sounds like a wave going out.",
		weight = 8,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 6 },
		result = { intelligence = 1, log = "You started counting them from the window every night. Forty-one, and if it was ever forty, somebody was in trouble." },
	},
	{
		id = "ke_k_clean_morning",
		title = "Clean",
		art = "street",
		text = "In the morning the street is spotless. The bins are gone, and so is every poster on the wall. The older kids say the Night was hungry.",
		weight = 8,
		once = true,
		when = { side = "backstreets", minAge = 4, maxAge = 6 },
		result = { mind = 1, sanity = -1, setFlags = { "knows_night" }, log = "You looked for the torn poster with the dog on it. Even the nail it had hung from was gone." },
	},

	-- ── where you were born ────────────────────────────────────────────────
	{
		id = "ke_k_client_sweet",
		title = "Before the Contract",
		art = "office",
		text = "A client comes up the stairs to your parents' Office and gives you a sweet in gold paper. {mother} takes it out of your hand before you can open it.",
		weight = 14,
		once = true,
		when = { flags = { "fixer_blood" }, hasRelation = "mother", minAge = 4, maxAge = 6 },
		dialogue = {
			{ who = "{mother}", line = "Never take anything from a client before the contract. Never." },
			{ who = "The Client", line = "It's a sweet." },
			{ who = "{mother}", line = "Then it'll keep until the contract." },
		},
		choices = {
			{ label = "Ask what a contract is", result = { mind = 1, setFlags = { "knows_fixers" }, log = "\"A promise with a price on it,\" said {mother}. You got the sweet at six o'clock, after the signing." } },
			{ label = "Cry for the sweet", result = { sanity = -1, setFlags = { "knows_fixers" }, log = "You cried until the client signed faster just to make it stop. {mother} gave you the sweet and put his money in the drawer." } },
			{ label = "Hide under the desk", result = { strength = 1, setFlags = { "knows_fixers", "ke_office_listener" }, log = "Under the desk you heard the whole job: a missing brother, last seen at the WARP depot. {mother} asked what he could pay, then what he really could." } },
		},
	},
	{
		id = "ke_k_three_washes",
		title = "Three Washes",
		art = "home",
		text = "When your parents come home from the company, they wash their hands three times each at the kitchen sink before they'll touch you.",
		weight = 14,
		once = true,
		when = { flags = { "lcorp_family" }, hasRelation = "father", world = { era = "wings" }, minAge = 4, maxAge = 6 },
		dialogue = {
			{ who = "{father}", line = "Wait. Work smell. Two more." },
		},
		choices = {
			{ label = "Wait by the sink", result = { mind = 1, setFlags = { "knows_lcorp" }, log = "On the third wash he picked you up, and you read his badge upside down: L CORP, and a department you couldn't pronounce." } },
			{ label = "Hug him anyway", result = { strength = 1, sanity = 1, setFlags = { "knows_lcorp" }, log = "You hugged him with wet hands. He went stiff, then soft, holding you and the soap at the same time." } },
			{
				label = "Ask what work smells like",
				result = {
					mind = 1,
					sanity = -1,
					setFlags = { "knows_lcorp" },
					log = "He said it to the sink, and then washed his hands a fourth time.",
					dialogue = { { who = "{father}", line = "Like a hospital. And green lamps. Go and set the table." } },
				},
			},
		},
	},
	{
		id = "ke_k_war_song",
		title = "The Song on the Radio",
		art = "home",
		text = "A children's choir on the radio is singing a bright old song about the front. {father} crosses the kitchen and switches it off in the middle of a word.",
		weight = 14,
		once = true,
		when = { flags = { "smoke_war_family" }, hasRelation = "father", minAge = 4, maxAge = 6 },
		codex = "bs_lore_smoke_war",
		choices = {
			{ label = "Sing the next line", result = { strength = 1, sanity = -2, setFlags = { "ke_war_song" }, log = "You sang it. He went out, and you heard the front door, and he didn't come back until nearly two." } },
			{ label = "Ask what the song is about", result = { mind = 1, log = "\"About children your age, so go and play,\" he said. The radio stayed off for a year." } },
			{ label = "Turn it back on, quietly", result = { mind = 1, sanity = 1, log = "He let it play. He sat at the table with his eyes shut and his hands flat until the choir was done." } },
		},
	},
	{
		id = "ke_k_practice",
		title = "Practice",
		art = "home",
		text = "Tonight's game: {father} pretends to be a stranger in a headband. He crouches down to your height and puts on a kind voice.",
		weight = 14,
		once = true,
		when = { flags = { "runaway_family" }, hasRelation = "father", minAge = 4, maxAge = 6 },
		dialogue = {
			{ who = "{father}", line = "Hello, little one. What's your mother's name? Where do you live?" },
		},
		choices = {
			{ label = "Give the outside names", result = { mind = 2, setFlags = { "ke_drilled_names" }, schedule = { event = "ke_f_real_name", inYears = 4 }, log = "You gave the outside names without blinking. He smiled with half his face and said, \"Again.\"" } },
			{ label = "Walk away without a word", result = { strength = 1, setFlags = { "ke_drilled_names" }, schedule = { event = "ke_f_real_name", inYears = 4 }, log = "You walked off and stood behind the stove. \"Even better,\" he said in his own voice, and sounded very tired." } },
			{ label = "Say the real ones", result = { mind = 1, sanity = -2, setFlags = { "ke_drilled_names" }, schedule = { event = "ke_f_real_name", inYears = 4 }, log = "He went white. You practiced until the lamp ran low, and you never got them wrong again." } },
		},
	},
	{
		id = "ke_k_found_day",
		title = "Found Day",
		art = "home",
		text = "Matron Hesketh writes the day they found you in the big book as your birthday. Today is Found Day, and you get the top of the loaf.",
		weight = 14,
		once = true,
		when = { flags = { "foundling" }, minAge = 4, maxAge = 6 },
		dialogue = {
			{ who = "ke_matron_hesketh", line = "Found Day. Top of the loaf, and no pots tonight. Don't get used to it." },
		},
		choices = {
			{ label = "Share the top of the loaf", result = { sanity = 2, log = "You tore it into fourteen pieces, one for every cot. They were very small pieces, and nobody complained." } },
			{
				label = "Ask who found you",
				result = {
					mind = 1,
					sanity = -1,
					setFlags = { "knows_night", "ke_asked_found" },
					log = "She said it like a list of chores, then cut you a second slice.",
					dialogue = { { who = "ke_matron_hesketh", line = "The baker, at dawn, after a Night. You were the only thing on that street the Sweepers left." } },
				},
			},
			{ label = "Eat it very slowly", result = { intelligence = 1, sanity = 1, log = "You made it last until the lamps were lit. The others watched every bite, and you let them." } },
		},
	},
	{
		id = "ke_k_supper_for_one",
		title = "Supper for One",
		art = "theater",
		text = "At supper the theater people sit round the long table with you, smiling, and watch you eat. Their own plates are empty. Mireille says they ate earlier.",
		weight = 14,
		once = true,
		when = { flags = { "bf_family_raised" }, minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Offer your bread around", result = { sanity = 2, setFlags = { "knows_bloodfiends" }, log = "A tall man took a crumb, chewed it with great ceremony, and thanked you as if it were a feast." } },
			{ label = "Ask what they ate", result = { mind = 1, setFlags = { "knows_bloodfiends" }, log = "\"Something red, darling,\" said Mireille. \"You'll understand when you're older,\" and the whole table laughed, kindly." } },
			{ label = "Eat faster", result = { health = 1, setFlags = { "knows_bloodfiends" }, log = "You ate fast, with everyone watching. When you finished the whole table clapped, and Mireille wiped your chin with a lace napkin." } },
		},
	},
	{
		id = "ke_k_laundry",
		title = "Under the Folding Table",
		art = "street",
		text = "You spend afternoons under the folding table at the laundry where {mother} works. The steam smells like hot coins, and the women talk over your head as if you're a basket.",
		weight = 14,
		once = true,
		when = { side = "backstreets", hasRelation = "mother", noRelation = "father", minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Pair the socks", result = { intelligence = 1, money = 1, log = "You paired socks for an hour. The owner gave you one Ahn and said you'd be running the place by ten." } },
			{ label = "Listen to the women talk", result = { charisma = 1, sanity = -2, setFlags = { "knows_night" }, log = "The Ferenc boy didn't make it home before the Night, they said. Then they saw your feet under the table and talked about prices." } },
			{ label = "Sleep in a basket", result = { sanity = 2, log = "You fell asleep in a basket of warm sheets. {mother} carried you home in it and brought it back in the morning." } },
		},
	},

	-- ── the Nest ───────────────────────────────────────────────────────────
	{
		id = "ke_n_aptitude",
		title = "Aptitude Day",
		art = "school",
		text = "A woman in white with a tablet sits in the corner of the kindergarten all morning, watching you play with blocks. Every time you touch a red one, she writes something down.",
		weight = 14,
		once = true,
		when = { side = "nest", minAge = 4, maxAge = 5 },
		choices = {
			{
				label = "Build the tallest tower",
				hint = "Intelligence check.",
				clash = kid("intelligence", "A tower of blocks"),
				win = { intelligence = 1, sanity = 2, setFlags = { "ke_assessed", "ke_tall_tower" }, schedule = { event = "ke_f_nest_file", inYears = 4 }, log = "Your tower was taller than Elodie's. The woman in white wrote for a long time." },
				lose = { sanity = -3, setFlags = { "ke_assessed" }, schedule = { event = "ke_f_nest_file", inYears = 4 }, log = "It came down on the eleventh block. She wrote one short word, and Elodie's tower stayed up." },
			},
			{ label = "Only use the red blocks", result = { mind = 1, setFlags = { "ke_assessed", "ke_red_blocks" }, schedule = { event = "ke_f_nest_file", inYears = 4 }, log = "You built with red blocks only. She stopped writing and watched you, then wrote very fast." } },
			{ label = "Ask what she's writing", result = { strength = 1, setFlags = { "ke_assessed" }, schedule = { event = "ke_f_nest_file", inYears = 4 }, log = "\"Your future, dear,\" she said, without looking up. You kept playing, because there was nothing else to do." } },
		},
	},
	{
		id = "ke_n_rule_nine",
		title = "Rule Nine",
		art = "nest",
		text = "Nanny Ottilie's rules are on a laminated card by the door. There are thirty-one, and rule nine has a strip of tape over it.",
		weight = 14,
		once = true,
		when = { side = "nest", minAge = 4, maxAge = 6 },
		dialogue = {
			{ who = "ke_nanny_ottilie", line = "Rule one, shoes off. Rule two, hands washed. Rule nine is for older children." },
		},
		choices = {
			{ label = "Peel back the tape", result = { mind = 1, sanity = -1, setFlags = { "knows_night", "ke_rule_nine" }, log = "RULE 9: DO NOT WATCH THE BACKSTREETS AFTER ONE O'CLOCK. You pressed the tape back down, very flat." } },
			{ label = "Learn the other thirty", result = { intelligence = 2, log = "You learned all thirty by heart, in order. Nanny Ottilie tested you at supper and gave you an orange segment for every ten." } },
			{
				label = "Ask her what it says",
				result = {
					mind = 1,
					setFlags = { "knows_night" },
					log = "She said it while folding a towel into perfect thirds.",
					dialogue = { { who = "ke_nanny_ottilie", line = "That at night the Backstreets belong to the Night, and nothing out there is your business." } },
				},
			},
		},
	},
	{
		id = "ke_n_painted_door",
		title = "The Painted Door",
		art = "nest",
		text = "Arno from across the corridor hasn't come to kindergarten all week. Today his family's nameplate is gone, and their door has been painted a fresh, careful white.",
		weight = 12,
		once = true,
		when = { side = "nest", minAge = 5, maxAge = 6 },
		choices = {
			{ label = "Ask Nanny Ottilie", result = { mind = 1, log = "\"Families move,\" Nanny Ottilie said, before you'd finished asking. \"Finish your milk.\"" } },
			{ label = "Knock on the white door", result = { strength = 1, sanity = -2, log = "A smiling stranger opened it. \"We've always lived here,\" she said, and closed it gently in your face." } },
			{ label = "Draw him a picture anyway", result = { intelligence = 1, sanity = -1, setFlags = { "ke_drew_for_arno" }, schedule = { event = "ke_f_arno_queue", inYears = 4 }, log = "You drew Arno and you on the roof garden under a yellow sun. You kept it in a drawer for when he came back." } },
		},
	},
	{
		id = "ke_n_wall_side",
		title = "The Wall Side",
		art = "nest",
		text = "Your bedroom is on the wall side of the tower. Once a night the window glass ticks, very softly, like fingernails, and the nanny says it's the heating.",
		weight = 12,
		once = true,
		when = { side = "nest", minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Believe the nanny", result = { sanity = 1, log = "It was the heating. You decided so every night, and it went on ticking anyway." } },
			{ label = "Put your ear to the glass", result = { mind = 1, sanity = -3, setFlags = { "ke_ear_glass" }, log = "Far down, past the wall, a great many somethings were walking in step. Your ear stayed cold for an hour." } },
			{ label = "Ask to change rooms", result = { strength = 1, log = "\"The wall side was what we could afford,\" you were told. You stayed, and turned your bed to face the door." } },
		},
	},
	{
		id = "ke_n_yellow_line",
		title = "The Yellow Line",
		art = "nest",
		text = "The kindergarten playground has painted lines on it. If you step over the yellow one, a speaker on a pole says your full name, very politely.",
		weight = 12,
		once = true,
		when = { side = "nest", minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Step over it again", result = { strength = 1, sanity = -1, setFlags = { "ke_line_stepper" }, log = "It said your name again. Then it said your family's names and your floor number, and you stepped back." } },
			{ label = "Stay inside the lines", result = { intelligence = 1, log = "You stayed inside the lines all year. At the end of term there was a certificate with a gold sticker." } },
			{ label = "Dare Elodie to do it", result = { mind = 1, log = "Elodie stepped over without blinking. The speaker said her name, and she curtsied to it." } },
		},
	},
	{
		id = "ke_n_pin",
		title = "The Pin",
		art = "nest",
		text = "Every morning {mother} pins the Wing's silver feather to her collar before she says good morning to anyone.",
		weight = 12,
		once = true,
		when = { side = "nest", hasRelation = "mother", minAge = 4, maxAge = 6 },
		dialogue = {
			{ who = "{mother}", line = "This pin is why we live here. Don't ever play with it. Ever." },
		},
		choices = {
			{
				label = "Ask what a Wing is",
				result = {
					mind = 1,
					setFlags = { "knows_wings" },
					log = "She said it to the hall mirror, checking her collar.",
					dialogue = { { who = "{mother}", line = "The company that owns the District. And the Nest. And us, a little. Shoes on." } },
				},
			},
			{ label = "Polish the pin for her", result = { intelligence = 1, setFlags = { "knows_wings" }, log = "You polished it on your sleeve until you could see your face in it. She wore it crooked all day, because you'd pinned it." } },
			{ label = "Hide the pin", result = { strength = 1, sanity = -2, setFlags = { "knows_wings", "ke_hid_pin" }, log = "She found it in your shoe at 7:58. She didn't shout, and she went to work with her hands shaking." } },
		},
	},
	{
		id = "ke_n_anthem",
		title = "Seven O'Clock",
		art = "nest",
		text = "At seven every morning the Wing's anthem plays from the speakers in the corridor, and everyone in the tower stands up, even the ones in pajamas.",
		weight = 8,
		once = true,
		when = { side = "nest", minAge = 4, maxAge = 6 },
		result = { intelligence = 1, setFlags = { "knows_wings" }, log = "You stood up too. Nobody had told you to." },
	},
	{
		id = "ke_n_red_button",
		title = "Something Red",
		art = "nest",
		text = "In the gravel of the kindergarten garden you find a button. It's red, really red, the color of a stoplight.",
		weight = 14,
		once = true,
		when = { district = "d20", side = "nest", minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Hide it in your shoe", result = { sanity = 2, setFlags = { "ke_red_button" }, log = "You wore it in your shoe for a year, under your heel. Some days it was the only thing you thought about." } },
			{ label = "Hand it to a Collector", result = { mind = 1, sanity = -1, log = "The Collector in gray took it with tweezers and wrote your name in a little book, for good citizenship." } },
			{ label = "Show the other children", result = { strength = 1, log = "They crowded round it in silence, the way you'd stand round a fire. By lunch someone had told, and it was gone." } },
			{
				label = "Finally. Keep it forever",
				requires = { flags = { "ke_wants_red" } },
				result = { sanity = 4, setFlags = { "ke_red_button" }, log = "You'd asked for red every day for a month, years ago. Now you had some, and you never told a single grown-up." },
			},
		},
	},

	-- ── Districts ──────────────────────────────────────────────────────────
	{
		id = "ke_k_wrong_door",
		title = "The Wrong Door",
		art = "home",
		text = "On Butter Street you walk into the wrong flat by mistake. The family at the table doesn't look up. Somebody pushes a bowl toward the empty chair.",
		weight = 12,
		once = true,
		when = { district = "d14", side = "backstreets", minAge = 4, maxAge = 6 },
		codex = "bs_lore_butter_street",
		choices = {
			{ label = "Sit down and eat", result = { sanity = 2, setFlags = { "ke_butter_supper" }, log = "You ate a whole bowl of somebody else's soup and nobody asked your name. When you left, someone said \"Mind the step.\"" } },
			{ label = "Back out quietly", result = { mind = 1, log = "You backed out and closed the door, and nobody looked up then either. On Butter Street, that's manners." } },
			{ label = "Say whose flat you meant", result = { intelligence = 1, log = "A man pointed at the ceiling without looking up from his paper. \"One floor up, same door.\"" } },
		},
	},
	{
		id = "ke_k_green_lamp",
		title = "The Green Lamp",
		art = "home",
		text = "The lamp on your stairwell landing runs on a little glass cell from the company, and it never goes out. The older kids say that if you stare at it long enough, it hums a song.",
		weight = 12,
		once = true,
		when = { district = "d12", world = { era = "wings" }, minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Stare at it", result = { mind = 1, sanity = -2, setFlags = { "ke_lamp_song" }, log = "You stared until your eyes watered. There was a song, and you decided there wasn't, and went upstairs." } },
			{ label = "Hang your hat over it", result = { strength = 1, log = "The landing went dark green. Someone on the floor below yelled at the ceiling until you took it off." } },
			{ label = "Ask the super about it", result = { mind = 1, setFlags = { "knows_lcorp" }, log = "\"L Corp,\" said Mr. Albrecht, changing the cell with two pairs of gloves on. \"Don't touch it, and don't ask.\"" } },
		},
	},
	{
		id = "ke_k_men_in_white",
		title = "The Men in White",
		art = "train",
		text = "At the WARP depot behind your street, men in white suits hose out a train car. They never talk, and they never take their masks off.",
		weight = 12,
		once = true,
		when = { district = "d23", side = "backstreets", minAge = 4, maxAge = 6 },
		codex = "districts_w_corp",
		choices = {
			{ label = "Wave at them", result = { mind = 1, sanity = -1, log = "One of them waved back, slowly, with a white glove. The others kept hosing." } },
			{ label = "Ask what they're washing", result = { mind = 1, sanity = -2, setFlags = { "ke_asked_cleanup" }, log = "\"The insides of the trains,\" Tali said. \"Don't ask me the insides of what.\"" } },
			{ label = "Count the cars", result = { intelligence = 1, log = "Forty-one cars on the siding. By morning there were forty-two, and one of them was very clean." } },
			{
				label = "Look for the one from before",
				requires = { flags = { "ke_saw_cleanup" } },
				result = { mind = 1, sanity = 1, log = "You'd seen them from your pram, years ago. One of them stopped hosing and looked straight at you, as if he remembered too." },
			},
		},
	},
	{
		id = "ke_k_harvest_bus",
		title = "The Five O'Clock Bus",
		art = "nest",
		text = "At harvest the Nest hires half the Backstreets to work its fields. {mother} has nobody to leave you with, so you ride the five o'clock bus out with her, asleep on a sack.",
		weight = 12,
		once = true,
		when = { district = "d19", side = "backstreets", hasRelation = "mother", minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Bow to the overseer", result = { charisma = 1, log = "The overseer said children bow too. You bowed so low your hat fell off, and he walked on." } },
			{ label = "Hide behind {mother}", result = { sanity = 1, log = "You hid behind {mother}'s legs. The overseer took it as a bow; he took most things as bows." } },
			{ label = "Count the rings on his hand", result = { strength = 1, sanity = -1, log = "He had a ring on every finger, and he saw you counting. {mother} was paid a little less that evening." } },
		},
	},
	{
		id = "ke_k_beetle_jar",
		title = "The Jar on the Sill",
		art = "home",
		text = "Old Mr. Kassel on the second floor keeps a jar on his windowsill with a dead beetle in it the size of your hand. He says it's older than the new Wing.",
		weight = 12,
		once = true,
		when = { district = "d7", side = "backstreets", minAge = 4, maxAge = 6 },
		codex = "dz_lore_smoke_relics",
		choices = {
			{ label = "Ask where he found it", result = { mind = 1, log = "\"The front,\" he said, and then nothing for a long time. He let you hold the jar with both hands." } },
			{ label = "Tap the glass", result = { strength = 1, sanity = -2, log = "Nothing happened. That night you dreamed it tapped back, and in the morning the jar was turned to face the wall." } },
			{ label = "Bring him a live one", result = { sanity = 1, log = "You brought him a moth in a cup. He looked at it a long time, then opened the window and let it go." } },
		},
	},
	{
		id = "ke_k_office_signs",
		title = "Reading the Signs",
		art = "street",
		text = "You're learning to read from the signs on your street. There are seven Fixer Offices between your door and the bakery, and every one has a better sign than the bakery.",
		weight = 12,
		once = true,
		when = { district = "d4", side = "backstreets", minAge = 5, maxAge = 6 },
		choices = {
			{ label = "Read every sign out loud", result = { intelligence = 1, setFlags = { "knows_fixers" }, log = "RIVET OFFICE and FULL MOON, WALK-INS WELCOME: you read them every morning, like a song nobody else knew." } },
			{ label = "Pick a favorite", result = { sanity = 2, setFlags = { "knows_fixers", "ke_fav_office" }, log = "You picked FULL MOON, for the painted moon. The Fixer in its window saw you choose, and saluted." } },
			{ label = "Ask what a Fixer is", result = { mind = 1, setFlags = { "knows_fixers" }, log = "\"Somebody you pay to have a bad day for you,\" said the baker, and gave you yesterday's bun for nothing." } },
		},
	},
	{
		id = "ke_k_good_as_new",
		title = "Good as New",
		art = "street",
		text = "The sweet seller on the corner came back from the K Corp clinic good as new. He doesn't remember the accident. He doesn't remember you, either.",
		weight = 12,
		once = true,
		when = { district = "d11", side = "backstreets", minAge = 4, maxAge = 6 },
		choices = {
			{ label = "Introduce yourself again", result = { sanity = 2, log = "You told him your name. He said it back twice to get it right, and gave you a sweet for the trouble." } },
			{ label = "Remind him of the old days", result = { mind = 1, sanity = -2, log = "You told him about the striped sweets and his dog. He listened politely, like it was a story about somebody else." } },
			{ label = "Ask what an ampule is", result = { mind = 1, log = "\"The best medicine there is,\" he said. \"Puts you back how you were,\" and then he frowned at his hands." } },
		},
	},
	{
		id = "ke_k_sideways_lift",
		title = "The Sideways Lift",
		art = "home",
		text = "The lift at the end of your corridor goes up and down most days. On Thursdays, for reasons nobody will explain, it goes sideways.",
		weight = 12,
		once = true,
		when = { district = "d8", minAge = 4, maxAge = 5 },
		choices = {
			{
				label = "Ride it to the end",
				hint = "Mental Strength check.",
				clash = kid("mind", "Hongyuan's corridors"),
				win = { mind = 1, sanity = 2, setFlags = { "ke_sideways" }, log = "It opened onto a corridor of red lanterns you'd never seen. You learned every turn, and walked home the long way, proud." },
				lose = { sanity = -3, log = "It opened onto a corridor where every door was the same. You walked for an hour before the lift came back for you, empty." },
			},
			{ label = "Get off at the first stop", result = { mind = 1, log = "It was the noodle stall from the next corridor, which was now your corridor. Nobody seemed surprised but you." } },
			{ label = "Press every button", result = { strength = 1, sanity = 1, log = "The lift went every way at once and opened on your own front door. The neighbors clapped." } },
		},
	},

	-- ── follow-ups (weight 0): ages 7-12 ───────────────────────────────────
	{
		id = "ke_f_iseul_moving",
		title = "Moving Day on Five",
		art = "home",
		text = "Iseul from the fifth floor is carrying boxes down the stairs, the grey coat over one shoulder. Her door is open, and the room behind it is bare.",
		weight = 0,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 12, notFlags = { "ke_iseul_done" } },
		dialogue = {
			{ who = "ke_iseul", line = "The Office is moving to a better street. Better street, worse jobs." },
			{ who = "ke_iseul", line = "You're the coat kid. Here. Catch." },
		},
		choices = {
			{ label = "Catch it", result = { strength = 1, sanity = 2, setFlags = { "ke_iseul_done", "ke_iseul_whistle", "knows_fixers" }, log = "A dented steel whistle on a cord. \"Three short blasts means a Fixer's coming,\" she said, \"and nobody ever checks.\"" } },
			{ label = "Carry a box down", result = { health = 1, money = 5, setFlags = { "ke_iseul_done", "knows_fixers" }, log = "You carried the heaviest box down five floors, and it clinked. She paid you five Ahn and told you never to guess what was in it." } },
			{
				label = "Ask to come with her",
				result = {
					mind = 1,
					setFlags = { "ke_iseul_done", "ke_iseul_invite", "knows_fixers" },
					log = "She wrote an address on the back of your hand in pen. You copied it out before you washed.",
					dialogue = { { who = "ke_iseul", line = "Come and find me when you're sixteen and can hold a door shut on your own." } },
				},
			},
			{
				label = "Fold her coat properly",
				requires = { flags = { "ke_coat_folded" } },
				result = { intelligence = 1, sanity = 3, setFlags = { "ke_iseul_done", "knows_fixers" }, log = "You folded it properly this time, sleeves out. She laughed for the first time you could remember: \"Took you long enough.\"" },
			},
		},
	},
	{
		id = "ke_f_dosan_hides",
		title = "Somebody's Looking for Dosan",
		art = "alley",
		text = "Dosan comes over the courtyard wall fast, older now, in a real Rat's jacket. He rolls behind the bins a second before a big man with a ledger walks into the courtyard.",
		weight = 0,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12, notFlags = { "ke_dosan_done" } },
		dialogue = {
			{ who = "ke_dosan", line = "You never saw me. You never saw me, shrimp." },
			{ who = "A Man With a Ledger", line = "Kid. A boy in a jacket come through here? Rat on the back." },
		},
		choices = {
			{
				label = "Point the wrong way",
				hint = "Mental Strength check.",
				clash = older("mind", "A man who reads faces"),
				win = { mind = 2, sanity = 2, setFlags = { "ke_dosan_done", "ke_dosan_owes" }, log = "You pointed at the laundry gate, and he went. Dosan crawled out ten minutes later and said \"I owe you one,\" like it hurt." },
				lose = { sanity = -4, setFlags = { "ke_dosan_done" }, log = "He watched your face instead of your finger and walked straight to the bins. Dosan ran for it, and you went inside." },
			},
			{ label = "Say nothing at all", result = { strength = 1, sanity = -1, setFlags = { "ke_dosan_done" }, log = "You stared at the man until he shrugged and left. Dosan was over the wall before you turned round." } },
			{ label = "Point at the bins", result = { money = 5, mind = 1, sanity = -3, setFlags = { "ke_dosan_done", "ke_sold_dosan" }, log = "The man put a five-Ahn coin on your step without looking at you. You heard Dosan round the corner, explaining." } },
			{
				label = "Throw your jacket over him",
				requires = { flags = { "ke_rat_orange" } },
				result = { strength = 1, sanity = 2, setFlags = { "ke_dosan_done", "ke_dosan_owes" }, log = "The man walked past a heap of bins wearing your jacket. Dosan gave it back a week later, washed, with an orange in the pocket." },
			},
		},
	},
	{
		id = "ke_f_bird_clock",
		title = "The Bird Clock",
		art = "home",
		text = "The new family on the fourth floor keep getting home late: 2:50, 2:55, once 3:04. Tonight their girl is sitting on the stairs, crying, holding a clock with no hands.",
		weight = 0,
		once = true,
		when = { side = "backstreets", minAge = 8, maxAge = 12, flags = { "ke_bird_clock" }, notFlags = { "ke_bird_clock_done" } },
		choices = {
			{ label = "Give her your bird clock", result = { sanity = 3, setFlags = { "ke_bird_clock_done", "ke_gave_clock" }, clearFlags = { "ke_bird_clock" }, log = "You showed her the trick: it's seven minutes fast, so three isn't three yet. She held it in both hands, the way you used to." } },
			{ label = "Fix their kitchen clock", result = { mind = 1, intelligence = 1, setFlags = { "ke_bird_clock_done" }, log = "You set their kitchen clock seven minutes fast while her father watched, frowning. They were home by 2:45 after that." } },
			{ label = "Leave it to her parents", result = { sanity = -1, setFlags = { "ke_bird_clock_done" }, log = "You went inside. For a month you listened for their door every night, and some nights it came very close to three." } },
		},
	},
	{
		id = "ke_f_floorboard_jar",
		title = "Two Hundred and Twelve",
		art = "home",
		text = "{sibling} pries up the loose floorboard and tips the jam jar out onto your bed. Coins, mostly, and a picture of a Nest garden cut from a magazine.",
		weight = 0,
		once = true,
		when = { side = "backstreets", hasRelation = "sibling", minAge = 8, maxAge = 12, notFlags = { "ke_jar_done" } },
		dialogue = {
			{ who = "{sibling}", line = "Two hundred and twelve Ahn. Five years of it." },
			{ who = "{sibling}", line = "A ticket anywhere costs eleven thousand. I asked at the window." },
		},
		choices = {
			{
				label = "Add your own coins",
				hint = "5 Ahn",
				requires = { min = { money = 5 } },
				result = { money = -5, sanity = 2, relationBond = { kind = "sibling", amount = 10 }, setFlags = { "ke_jar_done" }, log = "You added five Ahn. {sibling} put the jar back and said \"Two hundred and seventeen,\" like it was much closer." },
			},
			{ label = "Spend it on something good", result = { sanity = 4, setFlags = { "ke_jar_done" }, log = "You talked them into two sugar birds and a postcard of a WARP train. {sibling} pinned the postcard over the bed." } },
			{
				label = "Ask where they'd go",
				result = {
					mind = 1,
					setFlags = { "ke_jar_done" },
					log = "They put the coins back one at a time, counting.",
					dialogue = { { who = "{sibling}", line = "Somewhere with a different number on it. Any number." } },
				},
			},
		},
	},
	{
		id = "ke_f_redfoot",
		title = "Old Redfoot",
		art = "rooftop",
		text = "Up on the roof, the pigeon keeper is feeding his birds when a grey one with a red foot lands on your shoulder and taps your ear, twice.",
		weight = 0,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 12, notFlags = { "ke_redfoot_done" } },
		dialogue = {
			{ who = "pigeon_keeper", line = "Old Redfoot. She used to visit a window on your floor, years back." },
			{ who = "pigeon_keeper", line = "Birds remember who tapped back." },
		},
		choices = {
			{ label = "Ask to help with the birds", result = { intelligence = 1, sanity = 2, setFlags = { "ke_redfoot_done", "ke_pigeon_helper" }, log = "He gave you a bag of grain and one rule: never name a bird you can't keep. You named Redfoot anyway." } },
			{ label = "Tap her beak twice", result = { sanity = 3, setFlags = { "ke_redfoot_done" }, log = "You tapped twice, and she tapped twice. The pigeon keeper pretended to be looking at the sky." } },
			{ label = "Ask how old pigeons get", result = { mind = 1, setFlags = { "ke_redfoot_done" }, log = "\"Older than most people on this street,\" he said, with grain in both fists. \"Mind your feet.\"" } },
		},
	},
	{
		id = "ke_f_nest_file",
		title = "Your File",
		art = "school",
		text = "The academy interviewer opens a file with your name on it. It's thicker than your arm, and the first page is from the nursery camera.",
		weight = 0,
		once = true,
		when = { side = "nest", minAge = 7, maxAge = 12, notFlags = { "ke_file_done" } },
		dialogue = {
			{ who = "The Interviewer", line = "We like to know a child from the very beginning. Shall we?" },
		},
		choices = {
			{
				label = "Smile like you did for the camera",
				requires = { flags = { "ke_camera_smiler" } },
				result = { charisma = 2, sanity = 2, setFlags = { "ke_file_done" }, log = "She made a mark in a green box. You'd been practicing that smile since before you could talk." },
			},
			{
				label = "Explain where you used to go",
				requires = { flags = { "ke_camera_dodger" } },
				result = { mind = 2, sanity = -2, setFlags = { "ke_file_done" }, log = "\"Out of view two hundred and fourteen times,\" she read. You told her about the wardrobe, which wasn't the whole truth." },
			},
			{
				label = "Answer every question",
				hint = "Mental Strength check.",
				clash = older("mind", "The interviewer"),
				win = { mind = 2, money = 15, setFlags = { "ke_file_done" }, log = "You answered everything, in order. She closed the file and gave you a ribbon and an envelope with fifteen Ahn in it, for promise." },
				lose = { sanity = -4, setFlags = { "ke_file_done", "ke_file_flagged" }, log = "You got muddled on the fourth question. She wrote one word in the margin, and you never found out which." },
			},
			{ label = "Ask to see the file", result = { strength = 1, setFlags = { "ke_file_done" }, log = "\"Of course not,\" she said, smiling, and closed it. \"It isn't yours.\"" } },
		},
	},
	{
		id = "ke_f_grandma_pass",
		title = "Not Renewed",
		art = "checkpoint",
		text = "Your grandmother doesn't come through the checkpoint this season. A letter comes instead: VISITOR PASS NOT RENEWED. No reason is given, and nobody has signed it.",
		weight = 0,
		once = true,
		when = { side = "nest", minAge = 7, maxAge = 12, notFlags = { "ke_grandma_done" } },
		choices = {
			{ label = "Save her sweets in a tin", result = { sanity = -2, setFlags = { "ke_grandma_done", "ke_grandma_tin" }, log = "You saved her a sweet every week in a tin under your bed. By the end of the year the lid wouldn't close." } },
			{ label = "Write her a letter", result = { intelligence = 1, mind = 1, setFlags = { "ke_grandma_done" }, log = "You wrote three pages. The Nest post office charged double for a Backstreets address, and you paid it yourself." } },
			{ label = "Wait at the checkpoint", result = { strength = 1, sanity = -3, setFlags = { "ke_grandma_done" }, log = "You stood at the barrier all afternoon, looking out. A guard brought you a chair, and at five he walked you home." } },
		},
	},
	{
		id = "ke_f_ivo",
		title = "Ivo's Turn",
		art = "home",
		text = "Visiting day at the foundling house. A couple in good coats walk down the line of children twice, then stop in front of Ivo.",
		weight = 0,
		once = true,
		when = { flags = { "foundling", "ke_cot_friend" }, minAge = 7, maxAge = 12, notFlags = { "ke_ivo_done" } },
		dialogue = {
			{ who = "ke_ivo", line = "They've got a dog. A real one. I'll write to you. I can't write yet. I'll learn." },
		},
		choices = {
			{ label = "Squeeze his hand, let go", result = { mind = 1, sanity = -1, setFlags = { "ke_ivo_done", "ke_ivo_letters" }, log = "You squeezed and let go. He wrote once a year after that, in very big letters, mostly about the dog." } },
			{ label = "Tell them Ivo bites", result = { strength = 1, sanity = 1, setFlags = { "ke_ivo_done" }, log = "\"So do we,\" said the woman, and took him anyway. Ivo waved from the door with the hand you'd said he bit with." } },
			{ label = "Ask if they want two", result = { sanity = -3, setFlags = { "ke_ivo_done" }, log = "The woman laughed, kindly, the way that means no. Matron Hesketh put her hand on your shoulder and left it there." } },
		},
	},
	{
		id = "ke_f_real_name",
		title = "Your Name in the Market",
		art = "market",
		text = "In the market, a man in a plain coat calls a name across the stalls. It's your home name, and nobody outside your family has ever said it out loud.",
		weight = 0,
		once = true,
		when = { flags = { "runaway_family" }, minAge = 8, maxAge = 12, notFlags = { "ke_name_done" } },
		choices = {
			{
				label = "Keep walking",
				hint = "Mental Strength check.",
				clash = older("mind", "Your own name"),
				win = { mind = 2, sanity = 2, setFlags = { "ke_name_done" }, log = "You didn't turn. Your neck ached with not turning, all the way home." },
				lose = { sanity = -4, setFlags = { "ke_name_done", "ke_name_heard" }, log = "You turned, only your head and only a little. He smiled, and wrote something in a small book." },
			},
			{ label = "Turn and look", result = { strength = 1, sanity = -3, setFlags = { "ke_name_done", "ke_name_heard" }, log = "You looked. Under his hat he wore a painted headband, and he was already walking away." } },
			{ label = "Hide behind the fish stall", result = { intelligence = 1, sanity = -1, setFlags = { "ke_name_done" }, log = "You crouched behind the ice until the fishmonger said, without looking down, \"He's gone. Go home a different way.\"" } },
		},
	},
	{
		id = "ke_f_arno_queue",
		title = "The Other Side of the Barrier",
		art = "checkpoint",
		text = "On a class trip to the checkpoint you see Arno from across the corridor, taller now, standing in the Backstreets queue past the barrier in a coat that isn't his.",
		weight = 0,
		once = true,
		when = { side = "nest", flags = { "ke_drew_for_arno" }, minAge = 8, maxAge = 12, notFlags = { "ke_arno_done" } },
		choices = {
			{ label = "Pass him the drawing", result = { strength = 1, sanity = -2, setFlags = { "ke_arno_done", "ke_arno_drawing" }, log = "You pushed it through the bars. He looked at it a long time, and then the queue moved, and he moved with it." } },
			{ label = "Wave", result = { sanity = -1, setFlags = { "ke_arno_done" }, log = "You waved. He looked at your uniform, and didn't wave back." } },
			{ label = "Look at the guards instead", result = { mind = 1, sanity = -2, setFlags = { "ke_arno_done" }, log = "You looked at the guards until the class moved on. That night you took the drawing out of the drawer, and put it back." } },
		},
	},
	{
		id = "ke_f_crow_stones",
		title = "Stones at the Crows",
		art = "rooftop",
		text = "A boy from the next block is up on your roof, throwing stones at the crows. One of them is yours: you'd know that bent tail feather anywhere.",
		weight = 0,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 12, notFlags = { "ke_crow_done" } },
		choices = {
			{
				label = "Tell him to stop",
				hint = "Strength check.",
				clash = older("strength", "A boy with a pocket of stones"),
				win = { strength = 2, sanity = 2, setFlags = { "ke_crow_done", "ke_crow_defended" }, log = "He looked at you, then at the crows lined up behind you on the parapet, and found somewhere else to be." },
				lose = { health = -2, sanity = -4, setFlags = { "ke_crow_done" }, log = "He told you to make him, and that day you couldn't. The crows were back the next morning anyway, every one." },
			},
			{ label = "Clap and scatter them", result = { mind = 1, setFlags = { "ke_crow_done" }, log = "The crows went up all at once, out of range. Yours circled twice and landed on your head, which nobody believed." } },
			{ label = "Throw him your bread", result = { intelligence = 1, sanity = 1, setFlags = { "ke_crow_done" }, log = "You threw him your heel of bread. He looked at it, confused, then ate it and forgot about the crows." } },
		},
	},
	{
		id = "ke_f_grisha_rounds",
		title = "Thursday Rounds",
		art = "street",
		text = "Old Grisha's knees are bad this year. He asks if you'll pedal the grinding wheel on his Thursday rounds, one coin a street.",
		weight = 0,
		once = true,
		when = { side = "backstreets", minAge = 7, maxAge = 12, notFlags = { "ke_grisha_done" } },
		choices = {
			{ label = "Pedal the whole route", result = { health = 2, money = 12, setFlags = { "ke_grisha_done" }, log = "Twelve streets, twelve coins. Your legs shook on the stairs that night, and you slept like a stone." } },
			{ label = "Stop at the Fixer Office", result = { strength = 1, money = 6, setFlags = { "ke_grisha_done", "knows_fixers" }, log = "A Fixer handed Grisha a long blade wrapped in cloth. Behind her was a board of pinned papers, each one with a price." } },
			{
				label = "Ask him to teach you the wheel",
				result = {
					intelligence = 2,
					setFlags = { "ke_grisha_done", "ke_grinder_hand" },
					log = "He held your wrist at the angle until your arm remembered it.",
					dialogue = { { who = "ke_grisha", line = "Every blade wants the same thing. The right angle, and not too much." } },
				},
			},
		},
	},
}
