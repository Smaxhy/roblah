--[[
	Weight-0 scenes for writer D's daily events (Daily/Limbus.luau) and world events
	(WorldEvents/Limbus.luau). Daily scenes play in every era, so they never assume the
	Library or the bus exists; the world event scenes are gated by their world events.
]]

return {
	-- ── Today in the City ──
	{
		id = "lim_daily_clocks",
		title = "The Clock Mender",
		text = "A clock mender has set up her stall on your corner: a hundred clocks, all ticking, all slightly out of step. One brass clock with a cracked face ticks in an odd rhythm, like a voice that can't find the words. \"That one talks,\" she says. \"Nobody's ever understood it.\"",
		weight = 0,
		choices = {
			{
				label = "Listen to the odd clock",
				result = { mind = 2, sanity = { -1, 3 }, log = "You listened until the rhythm almost made sense: three short, a pause, one long. It felt like being asked a question. You went home and couldn't stop tapping it on the table." },
			},
			{
				label = "Help her fix the slow ones",
				clash = { stat = "intelligence", foe = "A hundred stubborn clocks", coins = 2, base = 4, coinPower = 3 },
				win = { wage = { 15, 40 }, intelligence = 1, log = "By evening every clock on the stall agreed on the time, except the brass one, which ticked at you as if to say thank you. She paid you in Ahn and a cheap watch." },
				lose = { sanity = -1, log = "You made two clocks worse and one of them started chiming. The mender laughed and told you to stick to your own trade." },
			},
			{
				label = "Buy a cheap watch",
				result = { money = -10, sanity = 2, log = "You bought a plain watch with a loud tick. Now you always know how long you have until three." },
			},
		},
	},
	{
		id = "lib_daily_pages",
		title = "Pages in the Wind",
		text = "Pages are blowing down every street in the District: handwritten, numbered, all from one person's life story. Page 40 is caught on your door handle. It's about a child learning to whistle on a rooftop, and it's very well written.",
		weight = 0,
		choices = {
			{
				label = "Collect the pages and find the writer",
				result = { sanity = 4, intelligence = 1, log = "You gathered sixty pages from gutters and windowsills and followed the numbers to an old man in a top-floor flat who'd left his window open. He'd been writing his whole life down before he forgot it. He let you read the rooftop chapter twice." },
			},
			{
				label = "Read every page you can catch",
				result = { mind = 2, sanity = -1, log = "You read a stranger's whole life out of order, in the wind. It ended badly, and then, on a page you caught last, began again." },
			},
			{
				label = "Fold the pages into birds for the kids",
				result = { sanity = 3, log = "You folded the pages into birds and the children on your street flew them off the roof all afternoon. Somewhere out there, a life story is in pieces, flying. It seemed to like it." },
			},
		},
	},
	{
		id = "lim_daily_gold",
		title = "Gold in the Gutters",
		text = "The street cleaners keep sweeping up a fine gold dust from the gutters, a little more every morning. It glints, and it hums very faintly if you hold it to your ear. A collector at the market pays by the spoonful. An old woman says it's bad luck to keep any.",
		weight = 0,
		choices = {
			{
				label = "Sweep some up and sell it",
				result = { wage = { 10, 35 }, log = "You sold three spoonfuls to the collector, who weighed them on a jeweler's scale and wouldn't say what he wanted them for." },
			},
			{
				label = "Hold some to your ear",
				result = { mind = 1, sanity = { -2, 2 }, log = "It hummed one note, very low and very patient, like something a long way underground. You let it run out between your fingers." },
			},
			{
				label = "Follow the dust to where it comes from",
				clash = { stat = "mind", foe = "A trail of gold dust", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, sanity = 1, log = "The trail led to a drain, and the drain to a sealed grate stamped with an old logo you half-recognized. You marked it on a map and kept the map." },
				lose = { sanity = -2, log = "The trail split, and split again, and ended at your own front step. You didn't like that at all." },
			},
		},
	},

	-- ── world event openers ──
	{
		id = "lib_world_reception",
		title = "The Night of the Great Reception",
		text = "Every Floor of the Library is lit at once. A whole Association Section went in at dusk, people say, thirty Fixers in matching coats. The whole City has come out to watch the tower: rooftops, balconies, the edge of District 12, everyone talking in low voices, waiting to see who comes out.",
		weight = 0,
		codex = "library_tower",
		choices = {
			{
				label = "Watch from a rooftop",
				result = { mind = 2, sanity = -2, codex = "lib_floors", log = "You watched until three in the morning, when you had to go inside. The windows were still lit, one Floor after another, like someone turning pages." },
			},
			{
				label = "Keep a vigil for the guests",
				result = { sanity = 2, intelligence = 1, log = "You lit a candle on your windowsill for thirty strangers in matching coats. Down the street, other candles came on. It didn't change anything inside the tower. It changed the street." },
			},
			{
				label = "Join the crowd at the edge of District 12",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A frightened crowd", coins = 2, base = 4, coinPower = 3 },
				win = { mind = 2, codex = "lib_hazard_grades", log = "You stood with the crowd all night. An old Fixer beside you explained Hana's hazard grades while you waited, Canard to Impurity, very quietly, the way people pray." },
				lose = { sanity = -4, health = -2, log = "The crowd surged when a window went dark, and you were nearly crushed against a fence. You went home with bruises and no news." },
			},
		},
	},
	{
		id = "lim_world_bus",
		title = "Mephistopheles in the City",
		text = "Limbus Company's bus is parked across three lanes, engine ticking as it cools. LCCB scouts in muddy boots are running cable down an access tunnel. A crowd has gathered at a safe distance, the kind of distance you keep from something you don't understand.",
		weight = 0,
		codex = "lim_lcb",
		choices = {
			{
				label = "Watch the bus",
				result = { sanity = 2, setFlags = { "lim_saw_bus" }, log = "The windows are dark red glass. Twice a shape moved behind them. Nobody got off while you watched, and the crowd went home with a story about nothing at all." },
			},
			{
				label = "Sell snacks to the crew",
				result = { wage = { 20, 50 }, log = "The scouts bought your whole tray on a company chit and ate standing up, watching the tunnel mouth. One of them took a bag to the bus door, knocked twice, and left it on the step." },
			},
			{
				label = "Ask a scout about work",
				result = { mind = 1, setFlags = { "lim_lccb_contact" }, schedule = { event = "lim_lccb_offer", inYears = 1 }, log = "The scout looked you up and down and wrote your name on a clipboard. \"Before Team is always hiring,\" she said. \"Always. Think about why.\"" },
			},
		},
	},
}
