--[[
	BASE EVENTS: cards any world can use, in plain words. A game gets them unless its spec
	says `baseEvents = false` (the breaking point always stays: the engine fires it when mood
	hits the bottom). They're tagged "base", so a game's own cards outweigh them: give your
	own events the weight they deserve and these become the filler between them.

	Built per game (Base.build), because their stat ids are the game's own.
	Tokens: {first} {currency} {district} {side} {zone} {career} {rank}.
]]

local Events = {}

function Events.build(roles: any): { any }
	local fight, speed, work, charm, luck, will, health = roles.fight.id, roles.speed.id, roles.work.id, roles.charm.id, roles.luck.id, roles.will.id, roles.health.id
	local F, S, W, C, Wi = roles.fight.name, roles.speed.name, roles.work.name, roles.charm.name, roles.will.name
	return {
		-- ── the breaking point (pack.hooks.breakingPoint) ──
		{
			id = "base_breaking_point",
			title = "The Bottom",
			text = "There's no floor under it anymore. Every thought is the same thought, and it's heavy. Somewhere above you there's a way back up, if you can still find it.",
			weight = 0,
			tags = { "base" },
			art = "home",
			choices = {
				{
					label = "Hold on to who you are",
					hint = Wi .. " check. Your coins flip fair here.",
					clash = { stat = will, foe = "The weight of it all", coins = 2, base = 5, coinPower = 3, ignoreSanity = true },
					win = { sanity = 40, [will] = 4, log = "You came back up, slowly, holding on to something new." },
					lose = { sanity = 18, [health] = { -14, -6 }, condition = "night_terrors", log = "You came back, eventually. Something stayed down there.", cause = "Never came back from the bottom" },
				},
				{
					label = "Hold on to the people who need you",
					hint = "Easier, if there's still someone to hold on to.",
					requires = { hasRelation = { "child", "mother", "father", "sibling", "friend", "mentor" } },
					clash = { stat = will, foe = "The weight of it all", coins = 1, base = 4, coinPower = 3, ignoreSanity = true },
					win = { sanity = 45, relationBond = { kind = "all", amount = 12 }, log = "You thought of their faces, one by one, and climbed toward them." },
					lose = { sanity = 15, [health] = { -10, -4 }, log = "You held on to them. It was barely enough." },
				},
				{
					label = "Let someone help",
					hint = "Costs a year of savings. Always works.",
					requires = { min = { money = 150 } },
					result = { money = -150, sanity = 30, log = "You let someone help. It cost what it cost. It was worth it." },
				},
			},
		},

		-- ── childhood ──
		{
			id = "base_lost",
			title = "Lost",
			text = "You followed something interesting around a corner, and then another, and now nothing looks like home.",
			weight = 6, once = true, tags = { "base" }, art = "street",
			when = { minAge = 4, maxAge = 9 },
			choices = {
				{ label = "Ask a grown-up", hint = C .. " check.", clash = { stat = charm, foe = "A busy stranger", coins = 1, base = 2, coinPower = 2 }, win = { [charm] = 1, log = "A kind stranger walked you all the way home." }, lose = { sanity = -2, log = "Nobody stopped. You found your own way back, long after dark." } },
				{ label = "Retrace your steps", hint = W .. " check.", clash = { stat = work, foe = "Every corner looking the same", coins = 1, base = 2, coinPower = 2 }, win = { [work] = 1, log = "You remembered every turn. You were home before anyone noticed." }, lose = { sanity = -2, log = "You went in a circle twice. Someone found you crying on a step." } },
				{ label = "Sit and wait", result = { [will] = 1, log = "You sat on a step and waited. Your mother found you, furious and crying, an hour later." } },
			},
		},
		{
			id = "base_bigger_kid",
			title = "The Bigger Kid",
			text = "A bigger kid has decided that whatever you're holding is theirs now.",
			weight = 6, cooldown = 4, tags = { "base" }, art = "street",
			when = { minAge = 6, maxAge = 13 },
			choices = {
				{ label = "Stand your ground", hint = F .. " fight.", clash = { stat = fight, foe = "A bigger kid", enemy = "bully", coins = 1, base = 3, coinPower = 2, fight = true }, win = { [fight] = 2, log = "You didn't let go. Neither did they, until they did." }, lose = { [health] = { -4, -1 }, sanity = -2, log = "You lost the fight, and the thing, and a little pride." } },
				{ label = "Run", hint = S .. " check.", clash = { stat = speed, foe = "A bigger kid", coins = 1, base = 3, coinPower = 2 }, win = { [speed] = 1, log = "You were round the corner before they'd finished the threat." }, lose = { sanity = -1, log = "They were faster. They took it anyway." } },
				{ label = "Let them have it", result = { sanity = -2, log = "You let them have it. You thought about it for a week." } },
			},
		},
		{
			id = "base_fever_child",
			title = "A Fever",
			text = "A fever comes on in the night, high and frightening. The grown-ups talk in low voices outside the door.",
			weight = 4, once = true, tags = { "base" }, art = "home",
			when = { minAge = 2, maxAge = 10 },
			result = { [health] = { -6, -2 }, [will] = 1, log = "The fever broke on the third night. You were thinner, and very hungry." },
		},
		{
			id = "base_found_coin",
			title = "Something Shiny",
			text = "Something glints in the gutter: a coin, and another, and a third.",
			weight = 4, cooldown = 6, lucky = true, tags = { "base" }, art = "street",
			when = { minAge = 5, maxAge = 14 },
			choices = {
				{ label = "Keep it", result = { money = { 5, 15 }, log = "You kept it. You told nobody, and felt rich for a month." } },
				{ label = "Ask around whose it is", result = { [charm] = 1, sanity = 2, log = "Nobody claimed it. The baker gave you a bun for asking." } },
			},
		},
		{
			id = "base_lessons",
			title = "A Hard Lesson",
			text = "There's a test tomorrow, and you understand about half of it.",
			weight = 6, cooldown = 3, tags = { "base" }, art = "school",
			when = { minAge = 7, maxAge = 17 },
			choices = {
				{ label = "Study all night", hint = W .. " check.", clash = { stat = work, foe = "A hard test", coins = 1, base = 3, coinPower = 2 }, win = { [work] = 2, log = "You understood all of it by morning, and it showed." }, lose = { [work] = 1, sanity = -2, log = "You studied all night and still blanked on the second page." } },
				{ label = "Charm the teacher", hint = C .. " check.", clash = { stat = charm, foe = "A tired teacher", coins = 1, base = 3, coinPower = 2 }, win = { [charm] = 2, log = "The teacher went easy on you. You'll be paying for that charm later." }, lose = { sanity = -2, log = "The teacher had heard it all before." } },
				{ label = "Wing it", result = { sanity = 1, log = "You winged it. The result was exactly as good as that sounds." } },
			},
		},

		-- ── youth ──
		{
			id = "base_first_job_offer",
			title = "A Little Work",
			text = "Someone down the street needs an extra pair of hands for the season, and they've noticed yours.",
			weight = 5, once = true, tags = { "base" }, art = "market",
			when = { minAge = 13, maxAge = 17 },
			choices = {
				{ label = "Take the work", result = { wage = { 20, 50 }, [health] = 1, log = "A season of hard work and a few {currency} of your own." } },
				{ label = "Keep your summers", result = { sanity = 3, log = "You kept your summers. You'll be working long enough." } },
			},
		},
		{
			id = "base_dare",
			title = "The Dare",
			text = "Your friends dare you to climb the old tower at the edge of {district}. Nobody's done it this year.",
			weight = 5, once = true, tags = { "base" }, art = "rooftop",
			when = { minAge = 11, maxAge = 17 },
			choices = {
				{ label = "Climb it", hint = S .. " check.", clash = { stat = speed, foe = "A crumbling tower", coins = 2, base = 3, coinPower = 2, fixed = true }, win = { [speed] = 2, sanity = 3, log = "You touched the top and waved. They still talk about it." }, lose = { [health] = { -10, -4 }, condition = "broken_arm", log = "A stone came loose. So did you.", cause = "Fell from the old tower" } },
				{ label = "Talk your way out", hint = C .. " check.", clash = { stat = charm, foe = "A crowd of friends", coins = 1, base = 3, coinPower = 2 }, win = { [charm] = 2, log = "You turned it into a joke, and somehow the dare went to someone else." }, lose = { sanity = -3, log = "They called you a coward all summer." } },
			},
		},

		-- ── adult life ──
		{
			id = "base_robbed",
			title = "A Knife in the Dark",
			text = "Someone steps out of a doorway on your way home and shows you a knife. \"Purse,\" they say.",
			weight = 5, cooldown = 6, tags = { "base", "danger", "crime" }, art = "alley",
			when = { minAge = 16 },
			choices = {
				{ label = "Hand it over", result = { money = { -80, -15 }, sanity = -3, log = "You handed it over. They were gone before you'd finished shaking." } },
				{ label = "Fight", hint = F .. " fight.", clash = { stat = fight, foe = "A mugger with a knife", enemy = "thug", coins = 2, base = 4, coinPower = 3, fight = true }, win = { [fight] = 2, money = { 10, 40 }, log = "They dropped the knife and ran. They dropped their own purse, too." }, lose = { [health] = { -14, -6 }, money = { -80, -15 }, log = "You lost the fight and the purse.", cause = "Knifed in a robbery" } },
				{ label = "Run for it", hint = S .. " check.", clash = { stat = speed, foe = "A mugger", coins = 2, base = 4, coinPower = 3 }, win = { [speed] = 1, log = "You ran, and kept running, and they didn't follow." }, lose = { [health] = { -8, -3 }, money = { -60, -10 }, log = "They caught you two streets down." } },
			},
		},
		{
			id = "base_stranger_help",
			title = "A Stranger in Trouble",
			text = "A stranger is on the ground in the street, and everyone else is walking around them.",
			weight = 5, cooldown = 5, tags = { "base" }, art = "street",
			when = { minAge = 14 },
			choices = {
				{ label = "Help them", result = { sanity = 3, money = -10, meet = true, log = "You got them home and paid for a healer. They wrote down your name." } },
				{ label = "Walk on", result = { sanity = -2, log = "You walked on like everyone else. You looked back once." } },
			},
		},
		{
			id = "base_windfall",
			title = "A Windfall",
			text = "A letter: a relative you barely remember has left you something.",
			weight = 3, once = true, lucky = true, tags = { "base" }, art = "home",
			when = { minAge = 20 },
			result = { money = { 200, 900 }, sanity = 3, log = "A small inheritance from someone you barely knew. You raised a cup to them." },
		},
		{
			id = "base_old_friend",
			title = "An Old Face",
			text = "Someone you grew up with is standing at the market stall next to yours, older and surprised.",
			weight = 4, cooldown = 8, tags = { "base" }, art = "market",
			when = { minAge = 24 },
			choices = {
				{ label = "Catch up", result = { sanity = 4, meet = true, log = "You talked until the stall-keeper threw you both out." } },
				{ label = "Pretend you didn't see them", result = { log = "You pretended you didn't see them. They pretended too." } },
			},
		},
		{
			id = "base_promotion_test",
			title = "A Chance at Work",
			text = "There's a chance to prove yourself at work, and everybody's watching to see who takes it.",
			weight = 5, cooldown = 4, tags = { "base" }, art = "office",
			when = { minAge = 18, anyCareer = true },
			choices = {
				{ label = "Take it on", hint = W .. " check.", clash = { stat = work, foe = "Everyone watching", coins = 2, base = 4, coinPower = 3 }, win = { [work] = 2, wage = { 30, 80 }, log = "You took it on and it went better than anyone expected, you included." }, lose = { sanity = -3, log = "It went wrong in front of everyone." } },
				{ label = "Let someone else", result = { sanity = 1, log = "Someone else took it. You slept well." } },
			},
		},
		{
			id = "base_hard_winter",
			title = "A Hard Winter",
			text = "The cold comes early and stays. Fuel costs double, and everyone is coughing.",
			weight = 4, cooldown = 8, tags = { "base" }, art = "home",
			when = { minAge = 10 },
			choices = {
				{ label = "Pay for fuel", requires = { min = { money = 60 } }, result = { money = -60, log = "You paid what it cost. The winter passed." } },
				{ label = "Tough it out", hint = roles.health.name .. " check.", clash = { stat = health, foe = "A long winter", coins = 1, base = 4, coinPower = 2, fixed = true }, win = { [will] = 1, log = "You toughed it out under every blanket you had." }, lose = { condition = "fever", [health] = { -6, -2 }, log = "The cold got into your chest." } },
			},
		},

		-- ── later life ──
		{
			id = "base_aches",
			title = "Old Aches",
			text = "Your knees have started forecasting the weather.",
			weight = 4, cooldown = 10, tags = { "base" }, art = "home",
			when = { minAge = 50 },
			choices = {
				{ label = "See a healer about it", requires = { min = { money = 40 } }, result = { money = -40, [health] = { 2, 5 }, log = "The healer gave you a salve and a lecture." } },
				{ label = "Ignore it", result = { [health] = { -4, -1 }, log = "You ignored it. It didn't ignore you." } },
			},
		},
		{
			id = "base_tell_stories",
			title = "The Young Ones Ask",
			text = "The young ones on your street have started asking you what it was like, back then.",
			weight = 4, cooldown = 10, tags = { "base" }, art = "street",
			when = { minAge = 55 },
			result = { sanity = 4, [charm] = 1, log = "You told them. You made some of it up, and they knew, and they didn't mind." },
		},
		{
			id = "base_lucky_day",
			title = "A Lucky Day",
			text = "Everything goes right today, for no reason at all.",
			weight = 3, cooldown = 6, lucky = true, tags = { "base" }, art = "street",
			when = { minAge = 8 },
			choices = {
				{ label = "Push your luck", hint = "Luck check.", clash = { stat = luck, foe = "The odds", coins = 2, base = 4, coinPower = 3 }, win = { money = { 40, 120 }, log = "You pushed it, and it held. A very good day." }, lose = { sanity = -1, log = "You pushed it, and it stopped." } },
				{ label = "Enjoy it", result = { sanity = 4, log = "You just enjoyed it. Some days are like that." } },
			},
		},
	}
end

return Events
