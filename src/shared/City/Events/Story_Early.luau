--[[
	THE SWEEPERS' HOUR and WHAT THE SMOKE LEFT (Storylines/Early.luau).
	Seven chapters each, at 2, 5, 8, 11, 13, 15 and 17. Short: a line or two, then the choice.
	Checks are `fixed` and gentle: these are a child's years. Nobody small is hurt on the page.
]]

local SW = "sl_sweepers_hour"
local SM = "sl_smoke_left"
local LCORP_AGE = { era = { "wings", "white_nights" } }

local function chk(stat: string, foe: string, hard: boolean?)
	return { stat = stat, foe = foe, coins = 1, base = if hard then 3 else 2, coinPower = 2, fixed = true }
end

local function beat(story: string, age: number, e)
	e.story = story
	e.always = true
	e.once = true
	e.when = e.when or {}
	e.when.minAge = age
	e.when.maxAge = age
	return e
end

return {
	-- ════ THE SWEEPERS' HOUR ════════════════════════════════════════════════════
	beat(SW, 2, {
		id = "sl_sw_count",
		title = "The Count",
		art = "home",
		text = "Ten past three. The bolt goes across. Your mother counts heads out loud, the way she does every night. Tonight she counts twice.",
		choices = {
			{ label = "Count along", result = { intelligence = 1, goal = "She counts to one more than there are. Find out who the one was.", log = "You counted with her. She got to one more than you did, and stopped." } },
			{ label = "Hide under the table", result = { speed = 1, sanity = 1, goal = "Be inside by ten past three. Every night.", log = "She counted you last, under the table, and didn't laugh." } },
			{ label = "Ask who's missing", result = { mind = 1, sanity = -1, goal = "She counts to one more than there are. Find out who the one was.", log = "\"Nobody,\" she said. \"Everybody's here.\" She checked the bolt again." } },
		},
	}),
	beat(SW, 5, {
		id = "sl_sw_chalk",
		title = "The Chalk Line",
		art = "street",
		text = "The old woman next door draws a chalk line across her step every evening. \"That's where they turn,\" she says. \"They don't come in. They only take what's out.\"",
		choices = {
			{ label = "Help her draw it", result = { charisma = 1, sanity = 1, log = "She let you do the last foot of it. \"Straight. They like things straight.\"" } },
			{ label = "Ask what they look like", result = { mind = 1, sanity = -2, setFlags = { "knows_sweepers" }, log = "\"Like something that's come to clean,\" she said. \"That's all they are. That's the worst of it.\"" } },
			{ label = "Stand on the line at noon", result = { strength = 1, log = "Nothing happened. At noon it's only chalk. You knew that. You still stepped back." } },
		},
	}),
	beat(SW, 8, {
		id = "sl_sw_knock",
		title = "Twenty Past",
		art = "night",
		text = "3:20. Somebody is knocking on your door, softly, and saying your mother's name. It's the man from two doors down. The rule is that the door stays shut.",
		choices = {
			{
				label = "Beg her to open it",
				clash = chk("charisma", "A rule that's kept you alive"),
				win = { charisma = 2, sanity = 3, setFlags = { "sl_sw_opened" }, goal = "Your mother opened the door once, for you. The street knows.", log = "She had it open and shut again in the time it takes to breathe in. He sat on your floor until it got light, shaking." },
				lose = { sanity = -5, goal = "The door stayed shut. The knocking stopped.", log = "She held you and didn't move. After a while the knocking stopped. In the morning she scrubbed the step." },
			},
			{ label = "Keep quiet", result = { mind = 2, sanity = -4, goal = "The door stayed shut. The knocking stopped.", log = "You put your hands over your ears. It didn't last long." } },
			{ label = "Look through the gap", result = { mind = 1, sanity = -6, setFlags = { "knows_sweepers", "sl_sw_saw" }, goal = "You saw what works the street at night. You don't sleep facing the door.", log = "You saw the street, very clean, and something tall going slowly from door to door." } },
		},
	}),
	beat(SW, 11, {
		id = "sl_sw_clock",
		title = "The Street Clock",
		art = "home",
		text = "The only clock on your street that keeps time is in your window. People set their evenings by it. Tonight at half past two, it stops.",
		choices = {
			{
				label = "Fix it",
				clash = chk("intelligence", "A clock older than the building"),
				win = { intelligence = 2, sanity = 2, setFlags = { "sl_sw_keeper" }, goal = "You keep the street's clock now. People nod to you.", log = "A dry spring. You had it going by a quarter to. Nobody outside ever knew." },
				lose = { sanity = -2, intelligence = 1, goal = "The clock stopped on your watch. You got everyone in another way.", log = "You couldn't. You ran out with a pan and a spoon instead." },
			},
			{
				label = "Run the street calling the time",
				clash = chk("speed", "Forty doors and half an hour"),
				win = { speed = 2, charisma = 1, setFlags = { "sl_sw_keeper" }, goal = "You ran the whole street in. People nod to you.", log = "Forty doors. You were back inside with four minutes left and no voice." },
				lose = { speed = 1, sanity = -3, goal = "You got most of the street in.", log = "You got to thirty-one doors. You've counted the other nine every night since." },
			},
			{ label = "Bang a pan in the window", result = { charisma = 1, sanity = 1, goal = "You got the street in with a pan.", log = "Every light on the street went out one by one, which is how you knew they'd heard." } },
		},
	}),
	beat(SW, 13, {
		id = "sl_sw_seventy",
		title = "Out",
		art = "night",
		text = "You misjudged it. It's 3:09 and you're nine streets from home. Somewhere a shutter comes down, and the street goes quiet all at once.",
		choices = {
			{
				label = "Run",
				clash = chk("speed", "Nine streets", true),
				win = { speed = 2, sanity = -2, goal = "You ran nine streets in four minutes. Your mother counted you twice.", log = "You hit your own door as the bolt was going across. She pulled you through by the collar." },
				lose = { sanity = -8, setFlags = { "knows_sweepers" }, goal = "A stranger pulled you inside at 3:12. You never learned their name.", log = "A door opened that wasn't yours and a hand pulled you in. You sat in a stranger's kitchen until the birds started." },
			},
			{
				label = "Knock on the nearest door",
				clash = chk("charisma", "A stranger's rule", true),
				win = { charisma = 2, sanity = -2, goal = "A stranger opened their door for you. The rule can be broken.", log = "\"Quick,\" a woman said, and that was all she said until morning." },
				lose = { sanity = -8, mind = 1, goal = "You spent the Night in a coal bunker.", log = "Nobody opened. You got into a coal bunker and pulled the lid down and didn't breathe for seventy minutes." },
			},
			{ label = "Get below the street", result = { mind = 2, sanity = -6, goal = "You spent the Night in a drain, listening.", log = "A drain cover, a ladder. You listened to it go by overhead, very thorough, for an hour and ten minutes." } },
		},
	}),
	beat(SW, 15, {
		id = "sl_sw_flat",
		title = "The One Short",
		art = "home",
		text = "Your mother finally says it. The night you were born, her brother went out at five to three to fetch the midwife. The midwife arrived. He didn't.",
		choices = {
			{ label = "Ask what he was like", result = { charisma = 1, sanity = 2, relationBond = { kind = "mother", amount = 12 }, goal = "The one she counts is her brother. He went out for you.", log = "He whistled. He was always late. She laughed, telling it, and then she didn't." } },
			{ label = "Say it wasn't her fault", result = { mind = 2, relationBond = { kind = "mother", amount = 8 }, goal = "The one she counts is her brother. He went out for you.", log = "\"I know,\" she said. \"I count anyway.\"" } },
			{ label = "Say it was yours", result = { mind = 1, sanity = -4, relationBond = { kind = "mother", amount = 15 }, goal = "The one she counts is her brother. He went out for you.", log = "She took you by the shoulders. \"Never. Not once. He'd have gone for anyone's.\"" } },
		},
	}),
	beat(SW, 17, {
		id = "sl_sw_end",
		title = "Ten Past Three",
		art = "night",
		text = "It's your hand on the bolt now, most nights. Ten past three. You count heads.",
		choices = {
			{ label = "Keep the clock for the whole street", result = { intelligence = 2, charisma = 2, sanity = 4, storyEnd = "The Timekeeper: your window has the clock the street comes home by", log = "You wind it every noon. Children you don't know point at your window and say, that's where the time is." } },
			{ label = "Be the door that opens", result = { mind = 3, sanity = -2, charisma = 1, storyEnd = "The Door That Opens: after the hour, yours is the one people knock on", log = "It's against every rule there is. You've had it open and shut in a breath eleven times. You count those too." } },
			{ label = "Get your family off this street", result = { strength = 1, intelligence = 2, money = 60, storyEnd = "Somewhere With a Wall: you swore your family would sleep behind a Nest's gate", log = "You started saving that week. A street where three in the morning is only three in the morning." } },
		},
	}),

	-- ════ WHAT THE SMOKE LEFT ═══════════════════════════════════════════════════
	beat(SM, 2, {
		id = "sl_sm_cough",
		title = "The Cough",
		art = "home",
		when = { hasRelation = "father", world = LCORP_AGE },
		text = "Your father coughs at night: long, dry, like something being dragged. Your mother says it's from the smoke. There hasn't been any smoke since before you were born.",
		choices = {
			{ label = "Bring him water", result = { charisma = 1, relationBond = { kind = "father", amount = 8 }, log = "He drank it and held on to the cup a while. \"Good lad,\" or \"good girl\". He was too hoarse to tell which." } },
			{ label = "Ask where the smoke went", result = { intelligence = 1, goal = "The old Wing ran on smoke. It lost a war. Ask him about the badge.", log = "\"It went when the old Wing went,\" your mother said. \"The new one's cleaner. Everyone says so.\"" } },
			{ label = "Cough like him", result = { speed = 1, sanity = 1, log = "You got it nearly right. He laughed, which set him off again." } },
		},
	}),
	beat(SM, 5, {
		id = "sl_sm_badge",
		title = "The Tin Badge",
		art = "home",
		when = { hasRelation = "father", world = LCORP_AGE },
		text = "There's a badge in the back of your father's drawer: tin, a number, a mark you don't know. Your father was in the Smoke War. He's never said for whom.",
		choices = {
			{ label = "Ask which side", result = { mind = 1, relationBond = { kind = "father", amount = -3 }, goal = "He won't say which side. Other people's fathers will.", log = "\"The one that paid,\" he said. \"Then the one that won. Put it back.\"" } },
			{ label = "Pin it on", result = { charisma = 1, sanity = 1, log = "You wore it to the end of the street. A man crossed over to avoid you. A woman saluted." } },
			{ label = "Put it back how it was", result = { intelligence = 1, relationBond = { kind = "father", amount = 4 }, log = "Face down, under the socks. He knew anyway. He always knows." } },
		},
	}),
	beat(SM, 8, {
		id = "sl_sm_stacks",
		title = "The Stacks",
		art = "ruins",
		when = { world = LCORP_AGE },
		text = "At the edge of the District the old Wing's smokestacks are still standing, black to the top. The dare is to touch the tallest one and come back.",
		choices = {
			{
				label = "Climb it",
				clash = chk("strength", "A hundred rungs, half of them rust"),
				win = { strength = 2, sanity = 2, setFlags = { "sl_sm_climbed" }, goal = "You've been to the top of the old Wing's stack. You could see the new one's tower from there.", log = "From the top you could see the new Wing's tower, very white, a long way off." },
				lose = { strength = 1, sanity = -2, log = "You got a third of the way and came down slowly. Nobody laughed. Nobody else had tried." },
			},
			{ label = "Find the way inside", result = { intelligence = 2, sanity = -2, setFlags = { "sl_sm_inside" }, goal = "There are rooms under the stacks. Your father's number is stencilled on a locker.", log = "A door, a stair, a row of lockers with numbers stencilled on. One of the numbers was on a badge you knew." } },
			{ label = "Touch it and run", result = { speed = 1, sanity = 1, log = "It was only cold brick. Your hand came away black. It took a week to wash off." } },
		},
	}),
	beat(SM, 11, {
		id = "sl_sm_recruiter",
		title = "The Recruiter",
		art = "street",
		when = { world = LCORP_AGE },
		text = "A recruiter from L Corp sets up a table at the end of your street. Clean coat, sweets for the children. On the banner: FACE THE FEAR, BUILD THE FUTURE.",
		choices = {
			{ label = "Take a leaflet", result = { intelligence = 1, setFlags = { "sl_sm_leaflet", "knows_lcorp" }, goal = "The Wing that won the war is hiring the children of the side that lost.", log = "\"We hire at eighteen,\" she said. \"We don't ask what your father did.\"" } },
			{ label = "Ask what happened to the old Wing's people", result = { mind = 2, setFlags = { "knows_lcorp" }, goal = "\"Most of them work for us now,\" the recruiter said. \"The ones who could.\"", log = "\"Most of them work for us now. The ones who could.\" She gave you two sweets." } },
			{ label = "Go and tell your father", requires = { hasRelation = "father" }, result = { charisma = 1, relationBond = { kind = "father", amount = 8 }, goal = "Your father stood at the window and watched the recruiter all afternoon.", log = "He stood at the window all afternoon with his arms folded. \"Clean coat,\" he said. That was all." } },
		},
	}),
	beat(SM, 13, {
		id = "sl_sm_pension",
		title = "The Pension",
		art = "hall",
		when = { hasRelation = "father", world = LCORP_AGE },
		text = "The old Wing promised its soldiers a pension. The old Wing is gone. The clerk at the new one says, very reasonably, that L Corp can't honour a debt it never made.",
		choices = {
			{
				label = "Argue it at the counter",
				clash = chk("charisma", "A very reasonable clerk", true),
				win = { charisma = 2, money = 40, relationBond = { kind = "father", amount = 10 }, goal = "You got your father a hardship payment. One.", log = "Not the pension. A \"hardship payment\", once. He stared at the envelope as if you'd lifted it." },
				lose = { sanity = -3, charisma = 1, goal = "The pension is gone. The cough isn't.", log = "She was sorry. She was sorry to everyone in the queue, one by one." },
			},
			{ label = "Find work, and say nothing", result = { strength = 1, money = 30, sanity = -1, goal = "You've started paying for his medicine yourself.", log = "Evenings at a loading dock. The medicine turned up in the cupboard and nobody asked." } },
			{ label = "Sit with him instead", result = { mind = 2, relationBond = { kind = "father", amount = 12 }, goal = "The pension is gone. He says he never expected it.", log = "\"I never thought they'd pay,\" he said. \"You don't lose a war and get a pension.\"" } },
		},
	}),
	beat(SM, 15, {
		id = "sl_sm_talked",
		title = "The Day He Talked",
		art = "home",
		when = { hasRelation = "father", world = LCORP_AGE },
		text = "It's a bad day for your father's chest, and for once he talks. He tells you what the smoke was like when it was a weapon, and what he did in it.",
		choices = {
			{ label = "Ask who won", result = { intelligence = 2, goal = "\"Nobody you'd know,\" he said. \"The ones who came after. They always do.\"", log = "\"Nobody who fought it,\" he said. \"A company that wasn't there took the seat. That's who wins.\"" } },
			{ label = "Ask what he did", result = { mind = 2, sanity = -3, relationBond = { kind = "father", amount = 10 }, goal = "You know what your father did in the smoke.", log = "He told you. He looked at the wall the whole time. You know why he never wears the badge." } },
			{ label = "Just listen", result = { charisma = 1, sanity = 1, relationBond = { kind = "father", amount = 14 }, goal = "He talked for an hour. You let him.", log = "He talked until his voice went. Then he said, \"Don't tell your mother I said any of that.\"" } },
		},
	}),
	beat(SM, 17, {
		id = "sl_sm_end",
		title = "What's Left",
		art = "street",
		when = { world = LCORP_AGE },
		text = "You're nearly grown. The stacks are coming down next year, the notice says. L Corp is hiring. The badge is still in the drawer.",
		choices = {
			{ label = "Sign with the Wing that won", result = { career = "lcorp_agent", intelligence = 2, sanity = -2, setFlags = { "knows_lcorp" }, storyEnd = "The Winning Side: you took a job with the Wing that came after the war", log = "A clean coat in your size. Your father pressed it for you himself, and didn't come to the door." } },
			{ label = "Keep the badge", result = { mind = 3, sanity = 3, storyEnd = "The Tin Badge: you kept the one thing the losing side left him", log = "You don't wear it either. It's in your drawer now, face down, under the socks." } },
			{ label = "Take him somewhere the air is clean", result = { money = -40, charisma = 2, sanity = 5, relationBond = { kind = "father", amount = 15 }, storyEnd = "Clean Air: you moved your father as far from the stacks as money would go", log = "Three Districts over, top floor, a window that opens. He coughs less. He says it's the stairs." } },
		},
	}),
}
