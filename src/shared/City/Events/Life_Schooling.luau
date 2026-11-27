--[[
	Schooling (ls_): at six, somebody decides what to do with you. Nobody is "at an academy"
	unless this (or the Enroll activity, later) put them there: the flag `enrolled` opens the
	"Go to class" activity, `apprenticed` a workshop apprenticeship, `street_taught` the street.
]]

return {
	{
		id = "ls_school_backstreets",
		title = "Six Years Old",
		art = "home",
		text = "You're six, and something has to be done with you. There's an academy two streets over with evening classes and a fee. There's a workshop that takes children who can hold a broom. And there's the street, which is free.",
		always = true,
		once = true,
		when = { minAge = 6, maxAge = 6, side = "backstreets" },
		choices = {
			{ label = "The academy", result = { setFlags = { "enrolled" }, intelligence = 2, log = "Somebody found the fee. You got a slate, a seat by the window, and a rule about being home before three." } },
			{ label = "The workshop", result = { setFlags = { "apprenticed" }, health = 1, strength = 1, log = "The smith looked at your hands and said you'd do. You started with the broom." } },
			{ label = "The street", result = { setFlags = { "street_taught" }, mind = 2, log = "Nobody signed you up for anything. The street took you on anyway." } },
		},
	},
	{
		id = "ls_school_nest",
		title = "Six Years Old",
		art = "nest",
		text = "You're six, so the Nest wants to know what you'll be. The Wing's preparatory school has a place for you, if you sit its test. Your family could pay a tutor instead. Or you could do what you've been doing, which is slip out the service door.",
		always = true,
		once = true,
		when = { minAge = 6, maxAge = 6, side = "nest" },
		choices = {
			{
				label = "Sit the test",
				clash = { stat = "intelligence", foe = "The placement test", coins = 1, base = 2, coinPower = 3 },
				win = { setFlags = { "enrolled", "prep_school" }, intelligence = 2, log = "You passed. The school gave you a uniform, a number, and a desk with your number on it." },
				lose = { setFlags = { "enrolled" }, intelligence = 1, sanity = -1, log = "You failed the placement test at six years old. Your family hired a tutor and didn't talk about it." },
			},
			{ label = "A tutor at home", result = { setFlags = { "enrolled" }, mind = 1, intelligence = 1, log = "The tutor came on Tuesdays and Fridays and smelled of chalk. You learned your letters at the dining table." } },
			{ label = "The service door", result = { setFlags = { "street_taught" }, strength = 1, mind = 1, log = "You learned the service stairs before you learned your letters. Somebody will be cross about that later." } },
		},
	},
}
