--[[
	CARDS (events). Every ModuleScript in Events/ is a list of these; Base.build loads them all.
	The shape (full reference: docs/CONTENT_GUIDE.md):
		id, title, text            text can use {first} {currency} {district} {side} {zone}
		weight (10), once, cooldown (years), tags ({ "danger" } makes it harder and likelier)
		when = { minAge, maxAge, side, district, career, flags, notFlags, min = { stat = n }, ... }
		result = {...}             a card with no choices just happens
		choices = {
			{ label, hint, requires = {...}, result = {...} },
			{ label, hint, clash = { stat, foe, enemy, coins, base, coinPower, fight }, win = {...}, lose = {...} },
			{ label, battle = "<boss id>", clash = {...fallback...}, win = {...}, lose = {...} },
		}
		results: any stat id = n or { min, max }, sanity, money, wage, gear, condition, cure,
		         setFlags, schedule = { event, inYears }, trigger = "<event id>", addRelation,
		         career, promote, cause (what it says if this kills you), log
]]

return {
	{
		id = "st_first_friend",
		title = "The New Kid",
		text = "A new kid moved in across the street. They've been watching you play from the step all week.",
		weight = 8, once = true,
		when = { minAge = 5, maxAge = 10 },
		choices = {
			{ label = "Wave them over", result = { charm = 2, addRelation = { kind = "friend", bond = 70, age = { 5, 10 } }, log = "You waved them over. By dinner you were best friends." } },
			{ label = "Keep playing", result = { will = 1, log = "You kept playing. They went inside." } },
		},
	},
	{
		id = "st_tournament",
		title = "The Town Tournament",
		text = "The town holds its yearly tournament in the square. Anyone can enter. The prize is a purse of {currency} and your name on the board.",
		weight = 6, cooldown = 5, tags = { "danger" },
		when = { minAge = 16, maxAge = 40 },
		choices = {
			{
				label = "Enter and fight",
				hint = "A real fight. The champion is good.",
				clash = { stat = "strength", foe = "The reigning champion", enemy = "brawler", coins = 3, base = 6, coinPower = 3, fight = true },
				win = { strength = 3, money = { 150, 400 }, log = "You took the purse and your name went up on the board." },
				lose = { health = { -18, -8 }, log = "The champion kept the purse, and you kept the bruises.", cause = "Fell in the town tournament" },
			},
			{ label = "Watch from the crowd", result = { sanity = 2, log = "You watched from the crowd and cheered for the underdog." } },
		},
	},
	{
		id = "st_rat_king",
		title = "Something in the Cellar",
		text = "Something huge has been living in the cellars under the market. Tonight it came up.",
		weight = 3, cooldown = 10, tags = { "danger" },
		when = { minAge = 18 },
		choices = {
			{
				label = "Go down after it", battle = "rat_king",
				hint = "A boss, fought in turns.",
				clash = { stat = "strength", foe = "The Rat King", enemy = "rat_king", coins = 3, base = 7, coinPower = 4, fight = true, boss = true },
				win = { strength = 4, money = { 300, 700 }, log = "It's dead. The market threw you a party." },
				lose = { health = { -30, -16 }, log = "It dragged itself back into the dark, and you dragged yourself home.", cause = "Killed by the Rat King" },
			},
			{ label = "Lock your door", result = { sanity = -3, log = "You locked your door and listened to it all night." } },
		},
	},
}
