--[[
	THE MONARCH PATHS (NON-CANON). Every card here says so in its text.

	Only on the world line where the player chose to keep the Gates (flag world_line_kept,
	set by cn_rewrite's "Stay on this world line (non-canon)"), after the war, and only for an
	A- or S-rank Hunter (the openers) or a survivor of the Hollow Door who left that door open
	(Saga_Hollow.luau: sg_hol_05 leads straight into a trial).

	The power of a Monarch who DIED in canon looks for a new vessel: Rakan, Monarch of Fangs
	(King of Beasts); Sillad, the Frost Monarch (King of the Snow Folk); Querehsha, Monarch of
	Plagues (Queen of Insects); Legia, Monarch of the Beginning (King of Giants); Tarnak,
	Monarch of Iron Body (King of the Monstrous Humanoids). Their names and titles are canon;
	everything they say and do here is the game's own. Not used: Ashborn (the Shadow Monarch is
	Sung Jinwoo's, never the player's), Antares, Baran and Yogumunt. No card says who killed
	any of them, or how.

	Each path: opener (_01) > the trial (_02) > the temptation (_03) > the crown (_04):
		take it          fate_monarch_<name>, then sg_mon_epilogue a year later
		refuse it        a willpower clash: win = fate_refused_crown
		                 lose = consumed (fate_fallen_vessel; the life ends)
	A life walks one path at most (sgm_any / sg_kept_arc).
]]

local HIGH = { "hunter_a", "hunter_s" }

local function beat(e)
	e.weight = 0
	e.once = true
	local w = e.when or {}
	w.minAge = w.minAge or 18
	w.notFlags = w.notFlags or {}
	table.insert(w.notFlags, "world_rewritten")
	table.insert(w.notFlags, "done_" .. e.id)
	e.when = w
	local function mark(r)
		if r then
			r.setFlags = r.setFlags or {}
			table.insert(r.setFlags, "done_" .. e.id)
		end
	end
	mark(e.result)
	for _, c in e.choices or {} do
		mark(c.result)
		mark(c.win)
		mark(c.lose)
	end
	return e
end

local function merge(a, b)
	local out = {}
	for k, v in a do
		out[k] = v
	end
	for k, v in b or {} do
		out[k] = v
	end
	return out
end

local MONARCHS = {
	{
		key = "rakan",
		openTitle = "The Hunt Calls",
		openText = "This world line kept its Gates (non-canon). Since the war you've felt it on every raid: a howl under everything, more felt than heard. Tonight, in a B-rank Gate, every beast in the dungeon stops, turns to look at you, and lowers its head. Something old and hungry speaks at the back of your skull. It calls itself Rakan, the Monarch of Fangs, King of Beasts. The king is dead, it says. The hunt is not. It needs a body that can run.",
		listenLog = "(non-canon) You didn't say yes. You didn't say no. The beasts let you walk out.",
		ignoreLog = "You cleared the Gate the hard way. The howl followed you home, and then it faded.",
		trialTitle = "The Trial of Fangs",
		trialText = "The voice sends you to an S-rank Gate in the mountains, alone, without your weapon. 'Kings don't need claws they can put down,' it says. 'Run it down.' Something enormous is waiting in the trees, and it can smell you already. (non-canon)",
		trial = { label = "Hunt it", stat = "agility", foe = "The beast in the trees", enemy = "gate_s", win = "(non-canon) You ran for a day and a night and brought it down at dawn. You weren't tired. That frightened you more than the beast.", lose = "It nearly killed you. The voice was pleased anyway: 'You didn't run away.'" },
		alt = { label = "Let it hunt you, and outlast it", stat = "willpower", foe = "Being prey", win = "You hid and waited and didn't panic, for two days. It gave up before you did. The voice approved: 'Patience is a fang too.'", lose = "It found you on the second night." },
		tempTitle = "The Temptation of Fangs",
		tempText = "You've started to smell fear on people. On raids, monsters scatter from you. The voice offers the rest of it: never tired, never slow, never afraid, every beast behind every Gate kneeling. 'All you have to give up,' it says, 'is the part of you that hesitates.' (non-canon)",
		yes = { label = "Want it", stats = { strength = 6, agility = 6 }, sanity = -10, log = "(non-canon) You said you wanted it. The hesitation started going, a little each day, like a tooth working loose." },
		no = { label = "Hold on to the hesitation", log = "You thought of every time hesitating had kept someone alive, and held on to it with both hands." },
		crownTitle = "The Crown of Fangs",
		crownText = "The voice is ready. A dead king's crown is in your hands, and all it needs is for you to close them. Take it, and you'll be the Monarch of Fangs in a world that kept its Gates (non-canon). Refuse it, and it will fight you all the way out.",
		takeLog = "(non-canon) Every beast behind every Gate in the world lifted its head at once. Somewhere a pack began to run, and you were the one it ran for.",
		refuseLog = "You opened your hands. The hunger went out of you like a tide, howling. You were only yourself again: tired, slow, afraid, and free.",
		consumedLog = "(non-canon) Your will broke, and the hunger took the rest.",
		consumed = "Consumed by the power of the Monarch of Fangs (non-canon)",
		gain = { strength = 40, agility = 40, vitality = 200 },
	},
	{
		key = "sillad",
		openTitle = "Snow Indoors",
		openText = "This world line kept its Gates (non-canon). In an A-rank Gate after the war, it starts to snow indoors. The monsters freeze where they stand. A voice like ice settling on a lake says its name: Sillad, the Frost Monarch, King of the Snow Folk. The king is dead; the cold is not. 'You'll do,' it says. 'You already know how to stop feeling things.'",
		listenLog = "(non-canon) You walked out through the snow. It didn't melt on you.",
		ignoreLog = "You walked out and stood in the sun until you could feel your hands again.",
		trialTitle = "The Trial of Frost",
		trialText = "It sends you into a frozen Gate where nothing has been warm for a thousand years: no fire, no coat, and no way out until the cold accepts you. Things made of ice watch you from between the trees. (non-canon)",
		trial = { label = "Walk to the heart of it", stat = "vitality", foe = "A thousand years of winter", enemy = "gate_s", win = "(non-canon) You walked for three days to the heart of the cold and stood there until it stopped hurting. The things of ice bowed as you walked out.", lose = "The cold nearly kept you. The voice let you go: 'Not yet, then.'" },
		alt = { label = "Keep your mind warm", stat = "willpower", foe = "The cold in your thoughts", win = "You recited every phone number you'd ever known, every address, every name. The cold couldn't find a way in.", lose = "You forgot your own name for an hour." },
		tempTitle = "The Temptation of Frost",
		tempText = "The cold offers its gift: no more fear, no more grief, no more nights awake counting the people you couldn't save. Just stillness, perfect and clear. 'Feeling is a wound,' it says. 'Let me close it.' (non-canon)",
		yes = { label = "Let it close", stats = { willpower = 6, intelligence = 6 }, sanity = 8, log = "(non-canon) The grief went first, then the fear. You slept well for the first time in years, and you didn't dream at all." },
		no = { label = "Keep the wound", log = "You kept it. It hurt. It was yours." },
		crownTitle = "The Crown of Frost",
		crownText = "The voice is ready. A dead king's crown is in your hands, cold enough to burn, and all it needs is for you to close them. Take it, and you'll be the Frost Monarch in a world that kept its Gates (non-canon). Refuse it, and it will try to freeze the refusal out of you.",
		takeLog = "(non-canon) Snow fell on every Gate in the world at once. In a thousand frozen dungeons the Snow Folk knelt, and you felt every one of them do it.",
		refuseLog = "You opened your hands. The cold left all at once, and you sat on the floor and wept for every grief it had been holding back, and it was wonderful.",
		consumedLog = "(non-canon) Your will froze before you did.",
		consumed = "Consumed by the power of the Frost Monarch (non-canon)",
		gain = { willpower = 40, intelligence = 40, vitality = 200 },
	},
	{
		key = "querehsha",
		openTitle = "The Hum",
		openText = "This world line kept its Gates (non-canon). Since the war you've heard it near every insect Gate: a hum, like a thousand voices agreeing. Today, in a nest of giant beetles, the swarm stops, parts and waits for you. 'Querehsha,' the hum says. 'The Monarch of Plagues, Queen of Insects. The queen is dead. The hive is not. It needs a mind to gather around.'",
		listenLog = "(non-canon) You walked out through a corridor of perfectly still insects. The hum followed you home, very softly.",
		ignoreLog = "You cleared the nest and stood under the shower for an hour. The hum faded.",
		trialTitle = "The Trial of the Hive",
		trialText = "It asks you to walk into an S-rank nest alone and come out leading it. The swarm will test you the only way a swarm knows how: all at once. (non-canon)",
		trial = { label = "Command it", stat = "intelligence", foe = "An S-rank swarm", enemy = "gate_s", win = "(non-canon) You found the rhythm of the hive and made it yours. When you walked out, ten thousand insects walked out behind you, and stopped at the Gate because you told them to.", lose = "The swarm closed over you. The hum pulled you out: 'Again, later.'" },
		alt = { label = "Stand still and let it judge you", stat = "willpower", foe = "Ten thousand minds", win = "You stood still while the swarm crawled over you for an hour. It decided you belonged.", lose = "You flinched, once. The swarm didn't forgive it." },
		tempTitle = "The Temptation of the Hive",
		tempText = "The hum offers you company: never alone again, a thousand minds agreeing with yours, no more doubt. You'd never have to decide anything by yourself. You'd never have to be only yourself. (non-canon)",
		yes = { label = "Let them in", stats = { intelligence = 6, charisma = 6 }, sanity = 6, log = "(non-canon) You let them in. The loneliness you'd carried for years went quiet. So did a few other things." },
		no = { label = "Stay alone in your own head", log = "You told the hum you'd rather be lonely and yourself. It didn't understand. It kept asking." },
		crownTitle = "The Crown of the Hive",
		crownText = "The hum is ready. A dead queen's crown is in your hands, and all it needs is for you to close them. Take it, and you'll be the Monarch of Plagues in a world that kept its Gates (non-canon). Refuse it, and the hive will try to drown you out.",
		takeLog = "(non-canon) Every swarm behind every Gate in the world turned at once, towards you. The hum became a song, and the song had your name in it.",
		refuseLog = "You opened your hands. The thousand voices went silent one by one, until there was only yours. It sounded very small, and you'd never been so glad to hear it.",
		consumedLog = "(non-canon) Your voice was lost among the thousand.",
		consumed = "Consumed by the power of the Monarch of Plagues (non-canon)",
		gain = { intelligence = 40, agility = 30, vitality = 200 },
	},
	{
		key = "legia",
		openTitle = "The Footstep",
		openText = "This world line kept its Gates (non-canon). The floor shakes a little when you walk now. On a raid after the war, a giant in an S-rank Gate, the kind that once walked through Tokyo, kneels in front of you instead of swinging. A voice as deep as bedrock speaks: Legia, the Monarch of the Beginning, King of Giants. The king fell, it says. The beginning has no end. It needs something to grow in.",
		listenLog = "(non-canon) The giant stayed kneeling until you'd gone. The ground hummed under your feet all the way home.",
		ignoreLog = "You backed out of the Gate and let an assault team take it. The rumbling faded over the next few weeks.",
		trialTitle = "The Trial of the Giants",
		trialText = "It wants you to hold up something that's falling: a tower collapsing over a Gate's mouth in a city at night, while the people inside get out. 'Kings carry,' it says. (non-canon)",
		trial = { label = "Hold it up", stat = "strength", foe = "Eleven floors coming down", win = "(non-canon) You held eleven floors on your shoulders for nine minutes. Everyone got out. Afterwards you weren't even breathing hard.", lose = "It came down on you. The voice dug you out: 'Stronger, next time.'" },
		alt = { label = "Carry the people out instead", stat = "vitality", foe = "A falling building", win = "You made forty trips into a falling building. The voice said nothing, but you felt it approve.", lose = "The stairwell went on your fortieth trip." },
		tempTitle = "The Temptation of the Giants",
		tempText = "It offers size: a body as big as a hill, and a strength that could hold the sky up. Nobody could ever hurt the people standing in your shadow. 'From up there,' it says, 'they're so small you'll hardly notice when you forget their names.' (non-canon)",
		yes = { label = "Grow", stats = { strength = 8, vitality = 60 }, sanity = -8, log = "(non-canon) You let it in a little. You grew a hand's width that month, and you forgot your neighbour's name, and remembered it, and forgot it again." },
		no = { label = "Stay your own size", log = "You said you'd rather be small enough to know everyone's name. The voice said that was the most human thing it had ever heard, and it didn't mean it kindly." },
		crownTitle = "The Crown of the Giants",
		crownText = "The voice is ready. A dead king's crown is in your hands, heavy as a mountain, and all it needs is for you to close them. Take it, and you'll be the Monarch of the Beginning in a world that kept its Gates (non-canon). Refuse it, and it will try to crush the refusal out of you.",
		takeLog = "(non-canon) Every giant behind every Gate in the world knelt at once. The ground everywhere shook for one long second, and the seismographs never explained it.",
		refuseLog = "You opened your hands. The weight lifted, all of it, and you were your own size again: small enough to be hurt, small enough to know everyone's name.",
		consumedLog = "(non-canon) The weight was too much, and it took you instead.",
		consumed = "Consumed by the power of the Monarch of the Beginning (non-canon)",
		gain = { strength = 50, vitality = 300 },
	},
	{
		key = "tarnak",
		openTitle = "Iron Under the Skin",
		openText = "This world line kept its Gates (non-canon). A high orc's axe broke on your arm today. You didn't feel it. Under your skin something grinds like iron on iron, and says its name: Tarnak, the Monarch of Iron Body, King of the Monstrous Humanoids. The king is dead; the iron is not. 'Your body breaks too easily,' it says. 'I can fix that.'",
		listenLog = "(non-canon) That night you leaned on the kitchen counter and the stone top cracked under your hand. The grinding sounded pleased.",
		ignoreLog = "A Healer checked the arm and couldn't find anything wrong with it, which was the problem. The grinding faded, slowly.",
		trialTitle = "The Trial of Iron",
		trialText = "It wants you to stand in an S-rank Gate's boss room and let the boss hit you, as hard as it can, for as long as it wants, without raising a hand. 'Iron doesn't dodge.' (non-canon)",
		trial = { label = "Stand there", stat = "vitality", foe = "An S-rank boss", enemy = "gate_s", win = "(non-canon) It hit you until it was tired. Then you walked up to it and ended it with one hand.", lose = "It broke something iron couldn't mend in time. The voice grumbled, and held you together." },
		alt = { label = "Stand there, and think about something else", stat = "willpower", foe = "Every blow", win = "You recited your times tables, all of them, out loud, while the boss wore itself out on you.", lose = "Somewhere past the four-hundredth blow you lost count, and then you lost more." },
		tempTitle = "The Temptation of Iron",
		tempText = "Never hurt again. Never tired, never sick, never old. A body that time and claws and Gates can't touch. 'And a heart to match,' it adds, as if that were a small thing. (non-canon)",
		yes = { label = "Take the iron", stats = { vitality = 80, strength = 6 }, sanity = -8, log = "(non-canon) Your skin went grey at the edges. When a friend called with bad news you found you felt nothing, and that frightened you, a little, for a while." },
		no = { label = "Keep the soft parts", log = "You told it you'd keep the parts of you that can break. It thought you were a fool. You thought of everyone who'd ever held your hand." },
		crownTitle = "The Crown of Iron",
		crownText = "The voice is ready. A dead king's crown is in your hands, and all it needs is for you to close them. Take it, and you'll be the Monarch of Iron Body in a world that kept its Gates (non-canon). Refuse it, and it will try to hammer the refusal out of you.",
		takeLog = "(non-canon) In every Gate in the world, the orcs and ogres and things with too many arms stopped and stood to attention. Your skin is iron now. Your heart is getting there.",
		refuseLog = "You opened your hands. The iron ran out of you like rain off a roof, and the first thing you felt was a cold wind on your face, and it was wonderful.",
		consumedLog = "(non-canon) The iron reached your heart, and then there was nobody left to refuse.",
		consumed = "Consumed by the power of the Monarch of Iron Body (non-canon)",
		gain = { vitality = 300, strength = 40 },
	},
}

local cards = {}

for _, m in MONARCHS do
	local k = m.key
	local f1, f2, f3 = "sgm_" .. k .. "_1", "sgm_" .. k .. "_2", "sgm_" .. k .. "_3"
	local id1, id2, id3, id4 = "sg_mon_" .. k .. "_01", "sg_mon_" .. k .. "_02", "sg_mon_" .. k .. "_03", "sg_mon_" .. k .. "_04"
	local TRIAL_HURT = "Killed in a Monarch's trial (non-canon)"

	-- the opener: the power finds an A- or S-rank Hunter on the kept world line
	table.insert(cards, {
		id = id1,
		title = m.openTitle,
		text = m.openText,
		weight = 3,
		once = true,
		tags = { "strange" },
		when = { minAge = 20, minYear = 13, form = HIGH, flags = { "world_line_kept", "licensed" }, notFlags = { "sg_kept_arc", "world_rewritten" } },
		choices = {
			{ label = "Listen", hint = "(non-canon) A dead Monarch's power wants you as its vessel.", result = { sanity = -4, setFlags = { "sg_kept_arc", "sgm_any", f1 }, schedule = { event = id2, inYears = 1 }, log = m.listenLog } },
			{ label = "Ignore it", result = { willpower = 3, log = m.ignoreLog } },
		},
	})

	-- the trial
	table.insert(cards, beat({
		id = id2,
		title = m.trialTitle,
		text = m.trialText,
		tags = { "danger", "strange" },
		when = { flags = { f1 } },
		choices = {
			{
				label = m.trial.label,
				hint = "S-rank. The power is testing you, not protecting you.",
				clash = { stat = m.trial.stat, foe = m.trial.foe, enemy = m.trial.enemy, coins = 4, base = 42, coinPower = 11, fight = m.trial.enemy ~= nil or nil, fixed = true },
				win = merge({ sanity = -8, setFlags = { f2, "sgm_trial_won" }, schedule = { event = id3, inYears = 1 }, log = m.trial.win }, { [m.trial.stat] = 12 }),
				lose = { vitality = { -240, -110 }, sanity = -10, setFlags = { f2 }, schedule = { event = id3, inYears = 1 }, cause = TRIAL_HURT, log = m.trial.lose },
			},
			{
				label = m.alt.label,
				hint = "Slower, safer, and it teaches you less.",
				clash = { stat = m.alt.stat, foe = m.alt.foe, coins = 3, base = 20, coinPower = 6, fixed = true },
				win = { willpower = 6, sanity = -6, setFlags = { f2 }, schedule = { event = id3, inYears = 1 }, log = m.alt.win },
				lose = { vitality = { -70, -30 }, sanity = -10, setFlags = { f2 }, schedule = { event = id3, inYears = 1 }, cause = TRIAL_HURT, log = m.alt.lose },
			},
		},
	}))

	-- the temptation
	local yes = merge(m.yes.stats, { sanity = m.yes.sanity, setFlags = { f3, "sgm_lean_in" }, schedule = { event = id4, inYears = 1 }, log = m.yes.log })
	table.insert(cards, beat({
		id = id3,
		title = m.tempTitle,
		text = m.tempText,
		tags = { "strange" },
		when = { flags = { f2 } },
		choices = {
			{ label = m.yes.label, hint = "(non-canon) It will be harder to refuse the crown.", result = yes },
			{ label = m.no.label, result = { willpower = 6, sanity = -4, setFlags = { f3 }, schedule = { event = id4, inYears = 1 }, log = m.no.log } },
		},
	}))

	-- the crown
	local take = merge(m.gain, { sanity = -20, setFlags = { "fate_monarch_" .. k, "sgm_crowned" }, schedule = { event = "sg_mon_epilogue", inYears = 1 }, log = m.takeLog })
	table.insert(cards, beat({
		id = id4,
		title = m.crownTitle,
		text = m.crownText,
		tags = { "danger", "strange" },
		when = { flags = { f3 } },
		choices = {
			{ label = "Take the crown", hint = "(non-canon) Become what it was.", result = take },
			{
				label = "Refuse it, at the last moment",
				hint = "If your will breaks, it takes you.",
				requires = { notFlags = { "sgm_lean_in" } },
				clash = { stat = "willpower", foe = "A dead king's will", coins = 4, base = 28, coinPower = 8, fixed = true },
				win = { willpower = 10, sanity = 12, setFlags = { "fate_refused_crown" }, log = m.refuseLog },
				lose = { setFlags = { "fate_fallen_vessel" }, die = m.consumed, log = m.consumedLog },
			},
			{
				label = "Refuse it, though part of you wants it",
				hint = "You let it in too far. If your will breaks, it takes you.",
				requires = { flags = { "sgm_lean_in" } },
				clash = { stat = "willpower", foe = "A dead king's will, and your own wanting", coins = 4, base = 34, coinPower = 9, fixed = true },
				win = { willpower = 12, sanity = 12, setFlags = { "fate_refused_crown" }, log = m.refuseLog },
				lose = { setFlags = { "fate_fallen_vessel" }, die = m.consumed, log = m.consumedLog },
			},
		},
	}))
end

-- a year after a crown is taken
table.insert(cards, beat({
	id = "sg_mon_epilogue",
	title = "The King's Court",
	text = "A year as a Monarch, in a world that kept its Gates (non-canon). The Association doesn't know what you are. The people who love you know something is wrong. And the far side of every Gate is calling you home.",
	tags = { "strange" },
	when = { flags = { "sgm_crowned" } },
	choices = {
		{ label = "Stay among people", result = { sanity = 4, charisma = 1, log = "(non-canon) You stayed. You go to the same noodle shop. You keep the crown where nobody can see it, and every year it's a little harder to remember why you stay, and you stay anyway." } },
		{ label = "Go through the last Gate, and rule what's on the other side", hint = "(non-canon) Your life in this world ends here.", result = { die = "Left this world through a Gate, to rule beyond it as a Monarch (non-canon)", log = "(non-canon) You walked into a Gate that had opened just for you. It closed behind you, and this world never saw you again." } },
	},
}))

return cards
